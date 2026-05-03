page 50104 "Metrics Snapshot Lines"
{
    ApplicationArea = All;
    Caption = 'Metrics Snapshot Lines';
    Editable = false;
    PageType = ListPart;
    SourceTable = metricssnapshotline;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Metric Code"; Rec."Metric Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the metric code.';
                }
                field("Metric Name"; Rec."Metric Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the metric name.';
                }
                field("Risk Level"; Rec."Risk Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the calculated risk level.';
                }
                field("Integer Value 1"; Rec."Integer Value 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the first integer metric value.';
                }
                field("Integer Value 2"; Rec."Integer Value 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the second integer metric value.';
                }
                field("Decimal Value 1"; Rec."Decimal Value 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the first decimal metric value.';
                }
                field("Decimal Value 2"; Rec."Decimal Value 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the second decimal metric value.';
                }
                field("Decimal Value 3"; Rec."Decimal Value 3")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the third decimal metric value.';
                }
                field("Text Summary"; Rec."Text Summary")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the calculated metric summary.';
                }
                field("Rule Used"; Rec."Rule Used")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the rule and parameters used.';
                }
            }
        }
    }
}
