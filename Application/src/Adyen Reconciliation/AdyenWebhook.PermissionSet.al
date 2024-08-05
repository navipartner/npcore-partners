#if not BC17
permissionset 6014406 "NPR Adyen Webhook"
{
    Assignable = true;
    Caption = 'NP Pay Webhook';
    IncludedPermissionSets = "D365 AUTOMATION";
    Access = Internal;

    Permissions =
        codeunit "NPR AF Rec. API Request" = X,
        codeunit "NPR Adyen Management" = X,
        tabledata "NPR Adyen Webhook" = RIM,
        tabledata "NPR Adyen Setup" = R,
        tabledata "NPR Adyen Webhook Log" = I,
        tabledata "NPR Adyen Merchant Account" = RIMD;
}
#endif