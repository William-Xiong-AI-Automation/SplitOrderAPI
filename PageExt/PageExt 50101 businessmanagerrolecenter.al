pageextension 50101 businessmanagerrolecenter extends "Business Manager Role Center"
{
    actions
    {
        addafter(Action41)
        {
            group(ai)
            {
                Caption = 'AI';
                Image = Administration;

                action(matrix)
                {
                    ApplicationArea = All;
                    Caption = 'Matrix';
                    Image = View;
                    RunObject = page "Metrics List";
                    ToolTip = 'Open the matrix page.';
                }
            }
        }
    }
}
