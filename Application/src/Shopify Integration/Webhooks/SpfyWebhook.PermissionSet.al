#if not BC17
permissionset 6014407 "NPR Spfy Webhook"
{
    Assignable = true;
    Caption = 'Shopify Webhook';
    IncludedPermissionSets = "D365 AUTOMATION";
    Access = Internal;

    Permissions =
        codeunit "NPR Spfy Webhook Webservice" = X,
        codeunit "NPR Spfy Webhook Notif. Parser" = X,
        tabledata "NPR Spfy Webhook Notification" = RIM;
}
#endif