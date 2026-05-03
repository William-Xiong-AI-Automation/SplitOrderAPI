table 52200 "Price Calc Request"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; ID; Guid) { DataClassification = SystemMetadata; }
        field(10; "Customer No."; Code[20]) { DataClassification = CustomerContent; }
        field(20; "Item No."; Code[20]) { DataClassification = CustomerContent; }
        field(30; Quantity; Decimal) { DataClassification = CustomerContent; }
        field(40; "Currency Code"; Code[10]) { DataClassification = CustomerContent; }

        field(100; "Unit Price"; Decimal) { DataClassification = CustomerContent; }
        field(110; "Line Discount %"; Decimal) { DataClassification = CustomerContent; }
        field(120; "Line Amount"; Decimal) { DataClassification = CustomerContent; }
        field(130; "Amount Including VAT"; Decimal) { DataClassification = CustomerContent; }

        field(200; "Created At"; DateTime) { DataClassification = SystemMetadata; }
    }

    keys
    {
        key(PK; ID) { Clustered = true; }
    }

    trigger OnInsert()
    var
        Sim: Codeunit "Quote Price Simulator";
        UnitPrice: Decimal;
        LineDiscPct: Decimal;
        LineAmount: Decimal;
        AmountInclVAT: Decimal;
    begin
        if IsNullGuid(ID) then
            ID := CreateGuid();

        "Created At" := CurrentDateTime();

        // 这里直接算并赋值（不要 Modify）
        Sim.CalcQuoteLine(
            "Customer No.",
            "Item No.",
            Quantity,
            "Currency Code",
            UnitPrice, LineDiscPct, LineAmount, AmountInclVAT);

        "Unit Price" := UnitPrice;
        "Line Discount %" := LineDiscPct;
        "Line Amount" := LineAmount;
        "Amount Including VAT" := AmountInclVAT;
    end;
}