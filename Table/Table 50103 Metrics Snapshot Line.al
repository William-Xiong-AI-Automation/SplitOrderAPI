table 50103 metricssnapshotline
{
    Caption = 'Metrics Snapshot Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Snapshot No."; Integer)
        {
            Caption = 'Snapshot No.';
            DataClassification = SystemMetadata;
            TableRelation = metricssnapshot."Snapshot No.";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Metric Code"; Code[50])
        {
            Caption = 'Metric Code';
            DataClassification = CustomerContent;
            TableRelation = metrics."Metric Code";
        }
        field(4; "Metric Name"; Text[100])
        {
            Caption = 'Metric Name';
            DataClassification = CustomerContent;
        }
        field(5; "Risk Level"; Code[20])
        {
            Caption = 'Risk Level';
            DataClassification = CustomerContent;
        }
        field(6; "Decimal Value 1"; Decimal)
        {
            Caption = 'Decimal Value 1';
            DataClassification = CustomerContent;
        }
        field(7; "Decimal Value 2"; Decimal)
        {
            Caption = 'Decimal Value 2';
            DataClassification = CustomerContent;
        }
        field(8; "Decimal Value 3"; Decimal)
        {
            Caption = 'Decimal Value 3';
            DataClassification = CustomerContent;
        }
        field(9; "Integer Value 1"; Integer)
        {
            Caption = 'Integer Value 1';
            DataClassification = CustomerContent;
        }
        field(10; "Integer Value 2"; Integer)
        {
            Caption = 'Integer Value 2';
            DataClassification = CustomerContent;
        }
        field(11; "Text Summary"; Text[500])
        {
            Caption = 'Text Summary';
            DataClassification = CustomerContent;
        }
        field(12; "Rule Used"; Text[500])
        {
            Caption = 'Rule Used';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Snapshot No.", "Line No.")
        {
            Clustered = true;
        }
        key(Metric; "Snapshot No.", "Metric Code")
        {
        }
    }
}
