#if NOT BC17
permissionset 6014404 "NPR Vipps Mp Webhook"
{
    Assignable = true;
    Caption = 'Vipps Mobilepay Webhook';
    IncludedPermissionSets = "D365 READ";
    Access = Internal;


    Permissions =
        codeunit "NPR Vipps Mp WebService" = X,
        codeunit "NPR Vipps Mp Webhook Mgt." = X,
        codeunit "NPR Vipps Mp HMAC" = X,
        tabledata "NPR Vipps Mp Store" = R,
        tabledata "NPR Vipps Mp Webhook Msg" = RIMD,
        tabledata "NPR Vipps Mp Webhook" = R;

}
#endif