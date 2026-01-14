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

    [Obsolete('This method uses deprecated Shopify REST fulfillment endpoints. Use CreateGraphQLRequestWithOrderIdFilter and ExecuteShopifyGraphQLRequest instead.', '2026-01-15')]
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

    /// <summary>
    /// Builds a Shopify GraphQL request for queries filtered by a specific Order GID (e.g. gid://shopify/Order/...).
    /// The generated request payload is written to NcTask."Data Output" and can be executed using the Shopify
    /// GraphQL communication handler.
    /// </summary>
    /// <param name="NcTask">NC task record used to store the generated GraphQL request payload.</param>
    /// <param name="endCursor">Paging cursor (endCursor) from the previous page; leave empty if this is the first page.</param>
    /// <param name="ShopifyStoreCode">Shopify store code used to resolve credentials and endpoints.</param>
    /// <param name="RequestQueryString">GraphQL query text.</param>
    /// <param name="OrderGID">Shopify GraphQL global ID (e.g. gid://shopify/Order/...).</param>
    /// <param name="IncludeCursor">Specifies whether the paging cursor should be included in the request as Header-level queries do not support pagination parameters.</param>
    procedure CreateGraphQLRequestWithOrderIdFilter(var NcTask: Record "NPR Nc Task"; endCursor: Text; ShopifyStoreCode: Code[20]; RequestQueryString: Text; OrderGID: Text[100]; IncludeCursor: Boolean)
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
    begin
        SpfyCommunicationHandler.CreateGraphQLRequestWithOrderIdFilter(NcTask, endCursor, ShopifyStoreCode, RequestQueryString, OrderGID, IncludeCursor);
    end;

}
#endif