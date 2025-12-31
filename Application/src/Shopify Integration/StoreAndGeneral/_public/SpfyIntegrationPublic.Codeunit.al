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

    procedure ExecuteShopifyGraphQLRequest(var NcTask: Record "NPR Nc Task"; CheckIntegrationIsEnabled: Boolean; var ShopifyResponse: JsonToken) Success: Boolean
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
    begin
        Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, CheckIntegrationIsEnabled, ShopifyResponse);
    end;

    procedure GetShopifyOrderFulfillmentOrders(ShopifyStoreCode: Code[20]; ShopifyOrderID: Text[30]; var ShopifyResponse: JsonToken)
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
    begin
        SpfyCommunicationHandler.GetShopifyOrderFulfillmentOrders(ShopifyStoreCode, ShopifyOrderID, ShopifyResponse);
    end;

    procedure SetAllowBackorder(ItemNo: Code[20]; VariantCode: Code[10]; ShopifyStoreCode: Code[20]; Allow: Boolean; DisableDataLog: Boolean)
    var
        SpfyItemVariantModifMgt: Codeunit "NPR Spfy ItemVariantModif Mgt.";
    begin
        SpfyItemVariantModifMgt.SetAllowBackorder(ItemNo, VariantCode, ShopifyStoreCode, Allow, DisableDataLog);
    end;
}
#endif