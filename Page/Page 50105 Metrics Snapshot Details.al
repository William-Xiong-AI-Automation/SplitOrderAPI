page 50105 "Metrics Snapshot Details"
{
    ApplicationArea = All;
    Caption = 'Metrics Snapshot Details';
    Editable = false;
    PageType = ListPart;
    SourceTable = metricssnapshotdetail;

    layout
    {
        area(Content)
        {
            repeater(Details)
            {
                field("Metric Code"; Rec."Metric Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the metric code.';
                }
                field("Detail Type"; Rec."Detail Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the detail type.';
                }
                field(Rank; Rec.Rank)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the detail rank.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source document or entity number.';
                }
                field("Source Name"; Rec."Source Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source name.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer number.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer name.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the location code.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the detail amount.';
                }
                field("Order Count"; Rec."Order Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order count.';
                }
                field(Share; Rec.Share)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the share of total open amount or order count.';
                }
                field(Note; Rec.Note)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the detail note.';
                }
            }
        }
    }
}
