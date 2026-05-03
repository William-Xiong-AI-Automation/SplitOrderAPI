codeunit 50123 "Split Sales Order Service"
{
    procedure CreateRequestAndSalesHeaders(var Hdr: Record "Split Order Req Hdr")
    var
        Existing: Record "Split Order Req Hdr";
        StockHeader: Record "Sales Header";
        PreHeader: Record "Sales Header";
    begin
        if Hdr."Customer No." = '' then
            Error('customerNo is required');
        if Hdr."Location Code" = '' then
            Error('locationCode is required');

        // 幂等：clientRequestId 已存在 → 返回旧 request（含两个 SO 号）
        if Hdr."Client Request Id" <> '' then begin
            Existing.SetRange("Client Request Id", Hdr."Client Request Id");
            if Existing.FindFirst() then begin
                Hdr := Existing;
                exit;
            end;
        end;

        // Insert header
        if System.IsNullGuid(Hdr.Id) then
            Hdr.Id := CreateGuid();

        Hdr.Status := 'DRAFT';
        Hdr."Inserted Line Count" := 0;
        Hdr."Processed Line Count" := 0;
        Hdr."Error Message" := '';
        Hdr.Insert(true);

        // 立刻创建两个 Sales Header，拿两个真实 SO No.
        CreateSalesHeader(Hdr, StockHeader);
        MarkOrderType(StockHeader, 'PENDING_STOCK', Hdr.Id);
        Hdr."Stock Order No." := StockHeader."No.";

        CreateSalesHeader(Hdr, PreHeader);
        MarkOrderType(PreHeader, 'PENDING_PREORDER', Hdr.Id);
        Hdr."Pre Order No." := PreHeader."No.";

        Hdr.Modify(true);

        // 返回最新数据给 API
        Hdr.Get(Hdr.Id);
    end;

    procedure AddRequestLine(var Line: Record "Split Order Req Line")
    var
        Hdr: Record "Split Order Req Hdr";
        ExistingLine: Record "Split Order Req Line";
    begin
        if System.IsNullGuid(Line."Request Id") then
            Error('requestId is required');
        if Line.SKU = '' then
            Error('sku is required');
        if Line.Qty <= 0 then
            Error('qty must be > 0');

        if not Hdr.Get(Line."Request Id") then
            Error('requestId not found');

        // 不允许在 RUNNING/DONE 状态下再插入 lines（你也可以放开）
        if (Hdr.Status = 'RUNNING') or (Hdr.Status = 'DONE') then
            Error('Cannot add lines when status is %1', Hdr.Status);

        // 防止同 requestId + lineNo 重复
        ExistingLine.SetRange("Request Id", Line."Request Id");
        ExistingLine.SetRange("Line No.", Line."Line No.");
        if ExistingLine.FindFirst() then
            Error('Duplicate lineNo %1 for request %2', Line."Line No.", Line."Request Id");

        Line."Assigned To" := '';
        Line."OnHand At Check" := 0;
        Line.Message := '';
        Line.Insert(true);

        Hdr."Inserted Line Count" += 1;
        Hdr.Modify(true);
    end;

    procedure SubmitRequest(RequestId: Guid)
    var
        Hdr: Record "Split Order Req Hdr";
    begin
        if not Hdr.Get(RequestId) then
            Error('requestId not found');

        if Hdr.Status = 'DONE' then
            exit;

        if Hdr."Expected Line Count" > 0 then
            if Hdr."Inserted Line Count" <> Hdr."Expected Line Count" then
                Error('Expected %1 lines, but inserted %2', Hdr."Expected Line Count", Hdr."Inserted Line Count");

        Hdr.Status := 'ACCEPTED';
        Hdr."Error Message" := '';
        Hdr.Modify(true);
        //拆分
        TryProcessOne(RequestId);
    end;

    procedure ProcessPendingRequests(MaxRequests: Integer)
    var
        Hdr: Record "Split Order Req Hdr";
        processed: Integer;
    begin
        processed := 0;

        Hdr.Reset();
        Hdr.SetRange(Status, 'ACCEPTED');
        if Hdr.FindSet(true) then
            repeat
                if processed >= MaxRequests then
                    exit;

                if TryProcessOne(Hdr.Id) then
                    processed += 1;

            until Hdr.Next() = 0;
    end;

    [TryFunction]
    local procedure TryProcessOne(RequestId: Guid)
    var
        Hdr: Record "Split Order Req Hdr";
        Line: Record "Split Order Req Line";
        StockHeader: Record "Sales Header";
        PreHeader: Record "Sales Header";

        onHandTotal: Decimal;
        remainingOnHand: Decimal;
        stockQty: Decimal;
        preQty: Decimal;

        RemainingBySku: Dictionary of [Text, Decimal];
        skuKey: Text;
    begin
        // 重新 GET + Lock，防并发
        if not Hdr.Get(RequestId) then
            exit;

        Hdr.LockTable();
        if not Hdr.Get(RequestId) then
            exit;

        if Hdr.Status <> 'ACCEPTED' then
            exit;

        Hdr.Status := 'RUNNING';
        Hdr."Error Message" := '';
        Hdr."Processed Line Count" := 0;
        Hdr.Modify(true);

        if Hdr."Stock Order No." = '' then
            Error('Stock order header not created');
        if Hdr."Pre Order No." = '' then
            Error('Preorder header not created');

        StockHeader.Get(StockHeader."Document Type"::Order, Hdr."Stock Order No.");
        PreHeader.Get(PreHeader."Document Type"::Order, Hdr."Pre Order No.");

        // 清理可能存在的旧 lines（防重跑）；如你不想删，可改成检查跳过
        DeleteSalesLines(StockHeader);
        DeleteSalesLines(PreHeader);


        Line.Reset();
        Line.SetRange("Request Id", Hdr.Id);
        if Line.FindSet(true) then
            repeat
                skuKey := Format(Line.SKU);

                // 取该 SKU 的 remainingOnHand（第一次才真正去算库存）
                if not RemainingBySku.Get(skuKey, remainingOnHand) then begin
                    onHandTotal := CalcOnHandByLocation(Line.SKU, Hdr."Location Code");
                    if onHandTotal < 0 then
                        onHandTotal := 0;

                    remainingOnHand := onHandTotal;
                    RemainingBySku.Add(skuKey, remainingOnHand);
                end;

                // 记录本行检查时“可用剩余库存”（更符合你拆分逻辑）
                Line."OnHand At Check" := remainingOnHand;

                // 核心：本行拆分
                stockQty := remainingOnHand;
                if stockQty > Line.Qty then
                    stockQty := Line.Qty;

                if stockQty < 0 then
                    stockQty := 0;

                preQty := Line.Qty - stockQty;
                if preQty < 0 then
                    preQty := 0;

                // 写回分配结果（你也可以用更细的字段记录 stockQty/preQty，如果你表里有）
                if (stockQty > 0) and (preQty > 0) then
                    Line."Assigned To" := 'SPLIT'
                else
                    if stockQty > 0 then
                        Line."Assigned To" := 'STOCK'
                    else
                        Line."Assigned To" := 'PREORDER';

                Line.Modify(true);

                // 分别写入两张 SO
                if stockQty > 0 then
                    AddSalesLine(StockHeader, Hdr."Location Code", Line.SKU, stockQty);

                if preQty > 0 then
                    AddSalesLine(PreHeader, Hdr."Location Code", Line.SKU, preQty);

                // 扣减 remainingOnHand，避免同 SKU 多行重复吃库存
                remainingOnHand := remainingOnHand - stockQty;
                if remainingOnHand < 0 then
                    remainingOnHand := 0;

                RemainingBySku.Set(skuKey, remainingOnHand);

                Hdr."Processed Line Count" += 1;
                Hdr.Modify(true);

            until Line.Next() = 0;

        // 如果某张单没有行：标记 EMPTY（不删除更安全）
        if not HasAnySalesLines(StockHeader) then
            MarkOrderType(StockHeader, 'EMPTY_STOCK', Hdr.Id);
        if not HasAnySalesLines(PreHeader) then
            MarkOrderType(PreHeader, 'EMPTY_PREORDER', Hdr.Id);

        Hdr.Status := 'DONE';
        Hdr.Modify(true);
    end;

    // -----------------------
    // Sales Order helpers
    // -----------------------
    local procedure CreateSalesHeader(Hdr: Record "Split Order Req Hdr"; var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader.Insert(true);

        SalesHeader.Validate("Sell-to Customer No.", Hdr."Customer No.");
        SalesHeader.Validate("Order Date", Today());
        SalesHeader.Validate("Location Code", Hdr."Location Code");
        SalesHeader.Modify(true);
    end;

    local procedure AddSalesLine(var SalesHeader: Record "Sales Header"; LocationCode: Code[10]; ItemNo: Code[20]; Qty: Decimal)
    var
        SalesLine: Record "Sales Line";
        nextLineNo: Integer;
    begin
        nextLineNo := GetNextLineNo(SalesHeader);

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := nextLineNo;
        SalesLine.Insert(true);

        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", ItemNo);
        SalesLine.Validate("Location Code", LocationCode);
        SalesLine.Validate(Quantity, Qty);

        // 不设置 Unit Price：让 BC 自动定价
        SalesLine.Modify(true);
    end;

    local procedure GetNextLineNo(SalesHeader: Record "Sales Header"): Integer
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindLast() then
            exit(SalesLine."Line No." + 10000);
        exit(10000);
    end;

    local procedure DeleteSalesLines(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet(true) then
            SalesLine.DeleteAll(true);
    end;

    local procedure HasAnySalesLines(SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        exit(SalesLine.FindFirst());
    end;

    local procedure MarkOrderType(var SalesHeader: Record "Sales Header"; Tag: Code[20]; RequestId: Guid)
    begin
        // 用 External Document No 存标记：PENDING_STOCK / PENDING_PREORDER / EMPTY_...
        // 你也可以换成你们自定义字段/维度
        SalesHeader.Validate("External Document No.", Tag);
        // Your Reference 里放 requestId 方便追踪
        SalesHeader.Validate("Your Reference", CopyStr(Format(RequestId), 1, 35));
        SalesHeader.Modify(true);
    end;

    // -----------------------
    // Inventory (On-hand)
    // -----------------------
    local procedure CalcOnHandByLocation(ItemNo: Code[20]; LocationCode: Code[10]): Decimal
    var
        ILE: Record "Item Ledger Entry";
    begin
        ILE.Reset();
        ILE.SetRange("Item No.", ItemNo);
        ILE.SetRange("Location Code", LocationCode);
        ILE.CalcSums("Remaining Quantity");
        exit(ILE."Remaining Quantity");
    end;
}