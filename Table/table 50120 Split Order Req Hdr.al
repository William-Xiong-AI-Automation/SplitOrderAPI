table 50120 "Split Order Req Hdr"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; Guid) { DataClassification = SystemMetadata; }
        field(2; "Client Request Id"; Code[50]) { DataClassification = CustomerContent; }
        field(3; "Customer No."; Code[20]) { DataClassification = CustomerContent; }
        field(4; "Location Code"; Code[10]) { DataClassification = CustomerContent; }

        field(10; Status; Code[20]) { DataClassification = CustomerContent; } // DRAFT/READY/ACCEPTED/RUNNING/DONE/ERROR
        field(11; "Expected Line Count"; Integer) { DataClassification = CustomerContent; }
        field(12; "Inserted Line Count"; Integer) { DataClassification = CustomerContent; }
        field(13; "Processed Line Count"; Integer) { DataClassification = CustomerContent; }

        field(20; "Stock Order No."; Code[20]) { DataClassification = CustomerContent; }
        field(21; "Pre Order No."; Code[20]) { DataClassification = CustomerContent; }

        field(30; "Error Message"; Text[2048]) { DataClassification = CustomerContent; }
        field(40; "Created At"; DateTime) { DataClassification = CustomerContent; }
        field(41; "Updated At"; DateTime) { DataClassification = CustomerContent; }
    }

    keys
    {
        key(PK; Id) { Clustered = true; }
        key(K1; "Client Request Id") { }
        key(K2; Status) { }
    }

    trigger OnInsert()
    begin
        if System.IsNullGuid(Id) then
            Id := CreateGuid();

        if Status = '' then
            Status := 'DRAFT';

        if "Created At" = 0DT then
            "Created At" := CurrentDateTime();

        "Updated At" := CurrentDateTime();
    end;

    trigger OnModify()
    begin
        "Updated At" := CurrentDateTime();
    end;
}