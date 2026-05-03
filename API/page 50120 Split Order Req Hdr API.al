page 50120 "Split Order Req Hdr API"
{
    PageType = API;
    APIPublisher = 'gauss';
    APIGroup = 'sales';
    APIVersion = 'v1.0';
    EntityName = 'splitOrderRequest';
    EntitySetName = 'splitOrderRequests';

    SourceTable = "Split Order Req Hdr";
    ODataKeyFields = Id;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            field(id; Rec.Id) { Editable = false; }

            field(clientRequestId; Rec."Client Request Id") { }
            field(customerNo; Rec."Customer No.") { }
            field(locationCode; Rec."Location Code") { }
            field(expectedLineCount; Rec."Expected Line Count") { }

            field(status; Rec.Status) { Editable = false; }
            field(insertedLineCount; Rec."Inserted Line Count") { Editable = false; }
            field(processedLineCount; Rec."Processed Line Count") { Editable = false; }

            field(stockOrderNo; Rec."Stock Order No.") { Editable = false; }
            field(preOrderNo; Rec."Pre Order No.") { Editable = false; }

            field(errorMessage; Rec."Error Message") { Editable = false; }
            field(createdAt; Rec."Created At") { Editable = false; }
            field(updatedAt; Rec."Updated At") { Editable = false; }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        Svc: Codeunit "Split Sales Order Service";
    begin
        // POST Header 时：立刻创建两张 Sales Header 并返回两个单号
        Svc.CreateRequestAndSalesHeaders(Rec);
        exit(false); // 我们在 service 内自行 Insert/Modify，并把 Rec 更新为最终值
    end;

    /// <summary>
    /// OData bound action: POST .../splitOrderRequests({id})/Microsoft.NAV.submit
    /// </summary>
    [ServiceEnabled]
    procedure Submit(var ActionContext: WebServiceActionContext)
    var
        Svc: Codeunit "Split Sales Order Service";
    begin
        // Rec 是当前 bound 的那条记录（由 URL 的 {id} 定位）
        Svc.SubmitRequest(Rec.Id);
        Rec.Get(Rec.Id);

        // 返回 200 + 当前实体（可让调用方立即看到最新 status）
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"Split Order Req Hdr API");
        ActionContext.AddEntityKey(Rec.FieldNo(Id), Rec.Id);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;
}