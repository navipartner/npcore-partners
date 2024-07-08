#if not BC17
codeunit 6184802 "NPR Spfy App Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeStep: Text;

    trigger OnUpgradePerCompany()
    begin
        UpdateShopifySetup();
        SetDataProcessingHandlerID();
    end;

    internal procedure UpdateShopifySetup()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        ShopifySetup2: Record "NPR Spfy Integration Setup";
    begin
        if not ShopifySetup.Get() then
            exit;
        ShopifySetup2.Init();
        if ShopifySetup2."Shopify Api Version" = '' then
            exit;
        if ShopifySetup."Shopify Api Version" >= ShopifySetup2."Shopify Api Version" then
            exit;
        ShopifySetup."Shopify Api Version" := ShopifySetup2."Shopify Api Version";
        ShopifySetup.Modify();
    end;

    internal procedure SetDataProcessingHandlerID()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        UpgradeStep := 'SetDataProcessingHandlerID';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Spfy App Upgrade', UpgradeStep);

        if ShopifySetup.Get() then
            if ShopifySetup."Data Processing Handler ID" = '' then begin
                ShopifySetup.SetDataProcessingHandlerIDToDefaultValue();
                ShopifySetup.Modify();
            end;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;
}
#endif