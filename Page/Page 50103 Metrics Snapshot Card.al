page 50103 "Metrics Snapshot Card"
{
    ApplicationArea = All;
    Caption = 'Metrics Snapshot';
    Editable = false;
    PageType = Card;
    SourceTable = metricssnapshot;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

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
            }
            part(Lines; "Metrics Snapshot Lines")
            {
                ApplicationArea = All;
                SubPageLink = "Snapshot No." = field("Snapshot No.");
            }
            part(Details; "Metrics Snapshot Details")
            {
                ApplicationArea = All;
                SubPageLink = "Snapshot No." = field("Snapshot No.");
            }
        }
    }
}
