page 50121 "Split Order Req Line API"
{
    PageType = API;
    APIPublisher = 'gauss';
    APIGroup = 'sales';
    APIVersion = 'v1.0';
    EntityName = 'splitOrderRequestLine';
    EntitySetName = 'splitOrderRequestLines';

    SourceTable = "Split Order Req Line";
    ODataKeyFields = "Line Id";
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            field(lineId; Rec."Line Id") { Editable = false; }
            field(requestId; Rec."Request Id") { }
            field(lineNo; Rec."Line No.") { }

            field(sku; Rec.SKU) { }
            field(qty; Rec.Qty) { }

            field(onHandAtCheck; Rec."OnHand At Check") { Editable = false; }
            field(assignedTo; Rec."Assigned To") { Editable = false; }
            field(message; Rec.Message) { Editable = false; }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        Svc: Codeunit "Split Sales Order Service";
    begin
        Svc.AddRequestLine(Rec);
        exit(false); // service 自行 Insert，避免重复插
    end;
}