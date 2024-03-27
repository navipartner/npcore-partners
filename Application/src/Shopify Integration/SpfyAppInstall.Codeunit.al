#if not BC17
codeunit 6184801 "NPR Spfy App Install"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        SpfyAppUpgrade: Codeunit "NPR Spfy App Upgrade";
    begin
        SpfyAppUpgrade.UpdateShopifySetup();
    end;
}
#endif