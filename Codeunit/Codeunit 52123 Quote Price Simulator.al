codeunit 52123 "Quote Price Simulator"
{
    procedure CalcQuoteLine(
        CustomerNo: Code[20];
        ItemNo: Code[20];
        Qty: Decimal;
        CurrencyCode: Code[10];
        var UnitPrice: Decimal;
        var LineDiscPct: Decimal;
        var LineAmount: Decimal;
        var AmountInclVAT: Decimal
    )
    var
        SalesHeaderNo: Code[20];
        SalesHeader: Record "Sales Header";
    begin
        UnitPrice := 0;
        LineDiscPct := 0;
        LineAmount := 0;
        AmountInclVAT := 0;

        // TryFunction：失败也尽量清理掉临时 Quote
        if not TryDoCalc(CustomerNo, ItemNo, Qty, CurrencyCode,
                         UnitPrice, LineDiscPct, LineAmount, AmountInclVAT, SalesHeaderNo)
        then begin
            if SalesHeaderNo <> '' then
                if SalesHeader.Get(SalesHeader."Document Type"::Quote, SalesHeaderNo) then
                    SalesHeader.Delete(true); // 级联删除 Lines

            Error('Price simulation failed for Customer=%1, Item=%2.', CustomerNo, ItemNo);
        end;
    end;

    [TryFunction]
    local procedure TryDoCalc(
        CustomerNo: Code[20];
        ItemNo: Code[20];
        Qty: Decimal;
        CurrencyCode: Code[10];
        var UnitPrice: Decimal;
        var LineDiscPct: Decimal;
        var LineAmount: Decimal;
        var AmountInclVAT: Decimal;
        var SalesHeaderNo: Code[20]
    )
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        if Qty <= 0 then
            Error('Quantity must be > 0.');

        // 1) Create Quote Header
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Quote;
        SalesHeader.Insert(true);
        SalesHeaderNo := SalesHeader."No.";

        SalesHeader.Validate("Sell-to Customer No.", CustomerNo);
        SalesHeader.Validate("Currency Code", CurrencyCode);
        SalesHeader.Modify(true);

        // 2) Create Quote Line (Sales Line with Document Type = Quote)
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 10000;
        SalesLine.Insert(true);

        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", ItemNo);
        SalesLine.Validate(Quantity, Qty);

        // 关键：让标准逻辑跑完（价格/折扣/金额）
        SalesLine.Modify(true);

        // 3) Read results
        UnitPrice := SalesLine."Unit Price";
        LineDiscPct := SalesLine."Line Discount %";
        LineAmount := SalesLine."Line Amount";                  // 净额，不含 invoice discount
        AmountInclVAT := SalesLine."Amount Including VAT";      // 若你也要含税金额

        // 4) Cleanup (delete header => cascades lines)
        SalesHeader.Delete(true);
        SalesHeaderNo := '';
    end;
}