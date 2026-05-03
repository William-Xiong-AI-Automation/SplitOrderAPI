table 50104 metricssnapshotdetail
{
    Caption = 'Metrics Snapshot Detail';
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
        field(4; "Detail Type"; Code[50])
        {
            Caption = 'Detail Type';
            DataClassification = CustomerContent;
        }
        field(5; Rank; Integer)
        {
            Caption = 'Rank';
            DataClassification = CustomerContent;
        }
        field(6; "Source No."; Code[50])
        {
            Caption = 'Source No.';
            DataClassification = CustomerContent;
        }
        field(7; "Source Name"; Text[100])
        {
            Caption = 'Source Name';
            DataClassification = CustomerContent;
        }
        field(8; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(9; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(10; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }
        field(11; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(12; "Order Count"; Integer)
        {
            Caption = 'Order Count';
            DataClassification = CustomerContent;
        }
        field(13; Share; Decimal)
        {
            Caption = 'Share';
            DataClassification = CustomerContent;
        }
        field(14; Note; Text[500])
        {
            Caption = 'Note';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Snapshot No.", "Line No.")
        {
            Clustered = true;
        }
        key(MetricRank; "Snapshot No.", "Metric Code", "Detail Type", Rank)
        {
        }
        key(AmountRank; "Metric Code", "Detail Type", Amount)
        {
        }
        key(CustomerAgg; "Metric Code", "Detail Type", "Customer No.")
        {
        }
        key(LocationAgg; "Metric Code", "Detail Type", "Location Code")
        {
        }
        key(CountRank; "Metric Code", "Detail Type", "Order Count")
        {
        }
    }
}
