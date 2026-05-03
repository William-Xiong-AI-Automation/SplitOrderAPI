page 50100 "Metrics List"
{
    ApplicationArea = All;
    Caption = 'Metrics Matrix';
    PageType = List;
    SourceTable = metrics;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Metrics)
            {
                field("Metric Code"; Rec."Metric Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code that identifies the metric.';
                }
                field("Metric Name"; Rec."Metric Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the display name of the metric.';
                }
                field("Metric Version"; Rec."Metric Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the metric version.';
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the category used to group the metric.';
                }
                field("Source Table"; Rec."Source Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central table used by the metric.';
                }
                field("Business Question"; Rec."Business Question")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the business question this metric answers.';
                }
                field("Input Fields"; Rec."Input Fields")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source fields used by this metric.';
                }
                field("Calculation Type"; Rec."Calculation Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the calculation implemented for this metric.';
                }
                field("Risk Rule Summary"; Rec."Risk Rule Summary")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the risk rule summary for this metric.';
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this metric is included in calculations.';
                }
                field("Sort Order"; Rec."Sort Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the display order for this metric.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(initialize)
            {
                ApplicationArea = All;
                Caption = 'Initialize Matrix';
                Image = Setup;
                ToolTip = 'Create the default Sales Header Exposure Metrics v0.5 definitions and parameters.';

                trigger OnAction()
                var
                    MetricsCalculator: Codeunit metricsexposurecalculator;
                begin
                    MetricsCalculator.InitializeDefaults();
                    Message('Metrics Matrix has been initialized.');
                end;
            }
            action(parameters)
            {
                ApplicationArea = All;
                Caption = 'Parameters';
                Image = SetupLines;
                RunObject = page "Metrics Parameters";
                RunPageLink = "Metric Code" = field("Metric Code");
                ToolTip = 'Open configurable parameters for the selected metric.';
            }
            action(calculate)
            {
                ApplicationArea = All;
                Caption = 'Calculate';
                Image = Calculate;
                ToolTip = 'Calculate Sales Header Exposure metrics and save a new snapshot.';

                trigger OnAction()
                var
                    MetricsCalculator: Codeunit metricsexposurecalculator;
                    SnapshotNo: Integer;
                begin
                    SnapshotNo := MetricsCalculator.CalculateSalesHeaderExposure();
                    Message('Metrics snapshot %1 has been created.', SnapshotNo);
                end;
            }
            action(snapshots)
            {
                ApplicationArea = All;
                Caption = 'Snapshots';
                Image = History;
                RunObject = page "Metrics Snapshots";
                ToolTip = 'Open calculated metrics snapshots.';
            }
        }
    }
}
