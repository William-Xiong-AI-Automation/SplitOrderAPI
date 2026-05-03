table 50100 metrics
{
    Caption = 'Metrics';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Metric Code"; Code[50])
        {
            Caption = 'Metric Code';
            DataClassification = CustomerContent;
        }
        field(2; "Metric Name"; Text[100])
        {
            Caption = 'Metric Name';
            DataClassification = CustomerContent;
        }
        field(3; "Metric Version"; Code[20])
        {
            Caption = 'Metric Version';
            DataClassification = CustomerContent;
        }
        field(4; Category; Code[50])
        {
            Caption = 'Category';
            DataClassification = CustomerContent;
        }
        field(5; "Source Table"; Text[100])
        {
            Caption = 'Source Table';
            DataClassification = CustomerContent;
        }
        field(6; "Business Question"; Text[250])
        {
            Caption = 'Business Question';
            DataClassification = CustomerContent;
        }
        field(7; "Input Fields"; Text[500])
        {
            Caption = 'Input Fields';
            DataClassification = CustomerContent;
        }
        field(8; "Calculation Type"; Code[50])
        {
            Caption = 'Calculation Type';
            DataClassification = CustomerContent;
        }
        field(9; "Risk Rule Summary"; Text[500])
        {
            Caption = 'Risk Rule Summary';
            DataClassification = CustomerContent;
        }
        field(10; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(11; "Sort Order"; Integer)
        {
            Caption = 'Sort Order';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Metric Code")
        {
            Clustered = true;
        }
        key(SortOrder; "Sort Order")
        {
        }
    }
}
