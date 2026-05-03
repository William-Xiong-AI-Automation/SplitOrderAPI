page 50102 "Metrics Snapshots"
{
    ApplicationArea = All;
    Caption = 'Metrics Snapshots';
    CardPageId = "Metrics Snapshot Card";
    Editable = false;
    PageType = List;
    SourceTable = metricssnapshot;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Snapshots)
            {
                field("Snapshot No."; Rec."Snapshot No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the snapshot number.';
                }
                field("Context Type"; Rec."Context Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the context type calculated by this snapshot.';
                }
                field("As Of DateTime"; Rec."As Of DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the source data was calculated.';
                }
                field("Source Table"; Rec."Source Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source table.';
                }
                field("Status Filter"; Rec."Status Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status filter used.';
                }
                field("Open Order Count"; Rec."Open Order Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of open orders included.';
                }
                field("Open Amount"; Rec."Open Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total open amount included.';
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who created the snapshot.';
                }
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the snapshot was created.';
                }
            }
        }
    }
}
