table 50101 metricsparameter
{
    Caption = 'Metrics Parameter';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Metric Code"; Code[50])
        {
            Caption = 'Metric Code';
            DataClassification = CustomerContent;
            TableRelation = metrics."Metric Code";
        }
        field(2; "Parameter Code"; Code[50])
        {
            Caption = 'Parameter Code';
            DataClassification = CustomerContent;
        }
        field(3; "Parameter Type"; Option)
        {
            Caption = 'Parameter Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Decimal,Integer,Text,Boolean';
            OptionMembers = DecimalValue,IntegerValue,TextValue,BooleanValue;
        }
        field(4; "Decimal Value"; Decimal)
        {
            Caption = 'Decimal Value';
            DataClassification = CustomerContent;
        }
        field(5; "Integer Value"; Integer)
        {
            Caption = 'Integer Value';
            DataClassification = CustomerContent;
        }
        field(6; "Text Value"; Text[100])
        {
            Caption = 'Text Value';
            DataClassification = CustomerContent;
        }
        field(7; "Boolean Value"; Boolean)
        {
            Caption = 'Boolean Value';
            DataClassification = CustomerContent;
        }
        field(8; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(9; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
            InitValue = true;
        }
    }

    keys
    {
        key(PK; "Metric Code", "Parameter Code")
        {
            Clustered = true;
        }
    }
}
