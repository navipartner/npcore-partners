codeunit 6151382 "NPR UPG PayByLink NP Email"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        NewFeatureHandler: Codeunit "NPR New Feature Handler";
    begin
        NewFeatureHandler.HandlePayByLinkNPEmail();
    end;
}
