codeunit 50124 "Split Order Job Runner"
{
    trigger OnRun()
    var
        Svc: Codeunit "Split Sales Order Service";
    begin
        // 每次跑最多处理 20 个请求（你自己调）
        Svc.ProcessPendingRequests(20);
    end;
}
