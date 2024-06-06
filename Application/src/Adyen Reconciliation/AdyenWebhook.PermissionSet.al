#if not BC17
permissionset 6014406 "NPR Adyen Webhook"
{
    Assignable = true;
    Caption = 'Adyen Webhook';
    IncludedPermissionSets = "D365 AUTOMATION";
    Access = Internal;

    Permissions =
        codeunit "NPR AF Rec. API Request" = X,
        codeunit "NPR Adyen Management" = X,
        tabledata "NPR AF Rec. Webhook Request" = IM,
        tabledata "NPR Adyen Setup" = R,
        tabledata "NPR Adyen Reconciliation Log" = I;
}
#endif