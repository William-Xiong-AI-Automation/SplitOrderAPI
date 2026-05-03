table 50121 "Split Order Req Line"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Line Id"; Guid) { DataClassification = SystemMetadata; }
        field(2; "Request Id"; Guid) { DataClassification = SystemMetadata; }
        field(3; "Line No."; Integer) { DataClassification = CustomerContent; }

        field(10; SKU; Code[20]) { DataClassification = CustomerContent; }
        field(11; Qty; Decimal) { DataClassification = CustomerContent; }

        field(20; "OnHand At Check"; Decimal) { DataClassification = CustomerContent; }
        field(21; "Assigned To"; Code[20]) { DataClassification = CustomerContent; } // STOCK/PREORDER/ERROR
        field(22; Message; Text[250]) { DataClassification = CustomerContent; }
    }

    keys
    {
        key(PK; "Line Id") { Clustered = true; }
        key(K1; "Request Id", "Line No.") { }
    }

    trigger OnInsert()
    begin
        if System.IsNullGuid("Line Id") then
            "Line Id" := CreateGuid();
    end;
}