permissionset 50100 GeneratedPermission
{
    Assignable = true;
    Permissions = tabledata "Split Order Req Hdr"=RIMD,
        tabledata "Split Order Req Line"=RIMD,
        table "Split Order Req Hdr"=X,
        table "Split Order Req Line"=X,
        codeunit "Split Sales Order Service"=X,
        page "Split Order Req Hdr API"=X,
        page "Split Order Req Line API"=X;
}