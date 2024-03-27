#if not BC17
codeunit 6184802 "NPR Spfy App Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpdateShopifySetup();
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
}
#endif