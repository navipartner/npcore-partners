codeunit 6151378 "NPR UPG JQ Notif NP Email"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        NewFeatureHandler: Codeunit "NPR New Feature Handler";
    begin
        NewFeatureHandler.HandleJQNotifNPEmail();
    end;
}
