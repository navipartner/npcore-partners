#if not BC17
codeunit 6184805 "NPR Spfy Integration Public"
{
    Access = Public;

    [Obsolete('The setups are now store-specific. Use the overload with a Shopify store code passed as a parameter instead', '2024-08-25')]
    procedure IsEnabled(IntegrationArea: Enum "NPR Spfy Integration Area"): Boolean
    var
        ObsoleteFunctionErr: Label 'Procedure "IsEnabled" of codeunit 6184805 "NPR Spfy Integration Public" is obsolete. The setups are now store-specific. Use the overload with a Shopify store code passed as a parameter instead.';
    begin
        Error(ObsoleteFunctionErr);
    end;

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

    [Obsolete('The setups are now store-specific. Use the "IsEnabled(IntegrationArea: Enum "NPR Spfy Integration Area"; ShopifyStoreCode: Code[20]): Boolean" procedure instead', '2024-08-25')]
    procedure ShopifyStoreIsEnabled(ShopifyStoreCode: Code[20]): Boolean
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        exit(SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::" ", ShopifyStoreCode));
    end;

    procedure ParseItem(ShopifyJToken: JsonToken; SkuKeyPath: Text; var ItemVariant: Record "Item Variant"; var Sku: Text): Boolean
    var
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
    begin
        exit(SpfyItemMgt.ParseItem(ShopifyJToken, SkuKeyPath, ItemVariant, Sku));
    end;
}
#endif