table 50102 metricssnapshot
{
    Caption = 'Metrics Snapshot';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Snapshot No."; Integer)
        {
            Caption = 'Snapshot No.';
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(2; "Context Type"; Code[50])
        {
            Caption = 'Context Type';
            DataClassification = CustomerContent;
        }
        field(3; "As Of DateTime"; DateTime)
        {
            Caption = 'As Of DateTime';
            DataClassification = SystemMetadata;
        }
        field(4; "Source Table"; Text[100])
        {
            Caption = 'Source Table';
            DataClassification = CustomerContent;
        }
        field(5; "Status Filter"; Text[50])
        {
            Caption = 'Status Filter';
            DataClassification = CustomerContent;
        }
        field(6; "Open Order Count"; Integer)
        {
            Caption = 'Open Order Count';
            DataClassification = CustomerContent;
        }
        field(7; "Open Amount"; Decimal)
        {
            Caption = 'Open Amount';
            DataClassification = CustomerContent;
        }
        field(8; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(9; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Snapshot No.")
        {
            Clustered = true;
        }
        key(CreatedAt; "Created At")
        {
        }
    }

    trigger OnInsert()
    begin
        if "As Of DateTime" = 0DT then
            "As Of DateTime" := CurrentDateTime();

        if "Created At" = 0DT then
            "Created At" := CurrentDateTime();

        if "Created By" = '' then
            "Created By" := CopyStr(UserId(), 1, MaxStrLen("Created By"));
    end;
}
