permissionset 50100 GeneratedPermission
{
    Assignable = true;
    Permissions = tabledata "Price Calc Request" = RIMD,
        tabledata "Split Order Req Hdr" = RIMD,
        tabledata "Split Order Req Line" = RIMD,
        table "Price Calc Request" = X,
        table "Split Order Req Hdr" = X,
        table "Split Order Req Line" = X,
        codeunit "Quote Price Simulator" = X,
        codeunit "Split Order Job Runner" = X,
        codeunit "Split Sales Order Service" = X,
        page "Price Calc API" = X,
        page "Split Order Req Hdr API" = X,
        page "Split Order Req Line API" = X;
}