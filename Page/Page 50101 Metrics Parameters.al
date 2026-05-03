page 50101 "Metrics Parameters"
{
    ApplicationArea = All;
    Caption = 'Metrics Parameters';
    PageType = List;
    SourceTable = metricsparameter;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Parameters)
            {
                field("Metric Code"; Rec."Metric Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the metric that owns this parameter.';
                }
                field("Parameter Code"; Rec."Parameter Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the parameter code.';
                }
                field("Parameter Type"; Rec."Parameter Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which value field is used by this parameter.';
                }
                field("Decimal Value"; Rec."Decimal Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the decimal parameter value.';
                }
                field("Integer Value"; Rec."Integer Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the integer parameter value.';
                }
                field("Text Value"; Rec."Text Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the text parameter value.';
                }
                field("Boolean Value"; Rec."Boolean Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the boolean parameter value.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies what this parameter controls.';
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this parameter is used.';
                }
            }
        }
    }
}
