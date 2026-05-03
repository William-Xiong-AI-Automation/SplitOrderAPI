pageextension 50102 "Appove ext" extends "Requests to Approve"
{

    actions
    {
        addbefore(Approve)
        {
            action(ApproveAll)
            {
                ApplicationArea = Suite;
                Caption = 'Approve All';
                ToolTip = 'Approve all open requests in the current view (based on your filters).';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    ApprovalEntry: Record "Approval Entry";
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    ApprovalEntry.Copy(Rec); // 带上当前页面过滤：Approver ID=UserId, Status=Open 等

                    if ApprovalEntry.IsEmpty() then
                        Error('No approval requests found in the current view.');

                    ApprovalsMgmt.ApproveApprovalRequests(ApprovalEntry);
                end;
            }
        }

    }
}