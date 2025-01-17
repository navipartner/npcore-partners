#if not BC17
codeunit 6184805 "NPR Spfy Integration Public"
{
    Access = Public;

    procedure IsEnabled(IntegrationArea: Enum "NPR Spfy Integration Area"; ShopifyStoreCode: Code[20]): Boolean
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        exit(SpfyIntegrationMgt.IsEnabled(IntegrationArea, ShopifyStoreCode));
    end;

    procedure IsEnabledForAnyStore(IntegrationArea: Enum "NPR Spfy Integration Area"): Boolean
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        exit(SpfyIntegrationMgt.IsEnabledForAnyStore(IntegrationArea));
    end;

    procedure ParseItem(ShopifyJToken: JsonToken; SkuKeyPath: Text; var ItemVariant: Record "Item Variant"; var Sku: Text): Boolean
    var
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
    begin
        exit(SpfyItemMgt.ParseItem(ShopifyJToken, SkuKeyPath, ItemVariant, Sku));
    end;

    procedure GetShopifyPictureUrl(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"): Text
    var
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
    begin
        exit(SpfyItemMgt.GetShopifyPictureUrl(SpfyStoreItemLink));
    end;
}
#endif