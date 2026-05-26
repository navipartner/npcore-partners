#if not BC17
codeunit 6184805 "NPR Spfy Integration Public"
{
    Access = Public;

    /// <summary>
    /// Returns whether the given Shopify integration area is enabled for the given store.
    /// Combines the store-level "Enabled" flag, the area-specific setup checkbox on the store
    /// card, and any extension veto raised via the SpfyIntegrationEvents.OnCheckIntegrationIsEnabled
    /// publisher.
    /// </summary>
    /// <param name="IntegrationArea">The area to query (Items, Inventory Levels, Item Prices, Sales Orders, Retail Vouchers, BC Customer Transactions, or " " meaning "any").</param>
    /// <param name="ShopifyStoreCode">Shopify store code to test. Blank string means "any store".</param>
    /// <returns>True if the area is enabled and not vetoed.</returns>
    procedure IsEnabled(IntegrationArea: Enum "NPR Spfy Integration Area"; ShopifyStoreCode: Code[20]): Boolean
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        exit(SpfyIntegrationMgt.IsEnabled(IntegrationArea, ShopifyStoreCode));
    end;

    /// <summary>
    /// Returns whether the given Shopify integration area is enabled for at least one configured store.
    /// Use this when scheduling or filtering decisions should run as long as any store would consume the
    /// output (e.g. data-log subscriptions, job-queue gating).
    /// </summary>
    /// <param name="IntegrationArea">The area to query.</param>
    /// <returns>True if at least one enabled store has the area enabled.</returns>
    procedure IsEnabledForAnyStore(IntegrationArea: Enum "NPR Spfy Integration Area"): Boolean
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        exit(SpfyIntegrationMgt.IsEnabledForAnyStore(IntegrationArea));
    end;

    /// <summary>
    /// Minimal sanity check that a phone number is in a shape Shopify will accept (E.164-style).
    /// Shopify rejects entire customer requests when the phone is malformed, so callers should
    /// skip the phone field rather than send a known-bad value.
    /// Rules enforced:
    ///   - must start with '+'
    ///   - after the '+', only digits and the separators ' ', '-', '(', ')' are allowed
    ///   - 7..15 digits in total after the '+'
    /// Intentionally not a full E.164 validator (which would require country-specific rules
    /// or an external service); catches the common formatting mistakes that Shopify rejects.
    /// </summary>
    procedure IsValidShopifyPhoneNo(PhoneNo: Text): Boolean
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        exit(SpfyIntegrationMgt.IsValidShopifyPhoneNo(PhoneNo));
    end;

    /// <summary>
    /// Reads the SKU from the given Shopify JSON node and resolves the BC Item Variant it points to.
    /// The SKU is read from the dotted path specified by SkuKeyPath (e.g. 'sku', 'variant.sku', or
    /// 'lineItems.edges[0].node.sku') and looked up case-insensitively against Item.No. and
    /// Item Variant.Code.
    /// </summary>
    /// <param name="ShopifyJToken">JSON token containing the SKU.</param>
    /// <param name="SkuKeyPath">Dotted path inside ShopifyJToken that yields the SKU.</param>
    /// <param name="ItemVariant">Resolved Item Variant. Untouched when the lookup fails.</param>
    /// <param name="Sku">Out: the uppercased SKU that was looked up.</param>
    /// <returns>True if the SKU resolved to a BC Item Variant.</returns>
    procedure ParseItem(ShopifyJToken: JsonToken; SkuKeyPath: Text; var ItemVariant: Record "Item Variant"; var Sku: Text): Boolean
    var
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
    begin
        exit(SpfyItemMgt.ParseItem(ShopifyJToken, SkuKeyPath, ItemVariant, Sku));
    end;

    /// <summary>
    /// Returns the URL of the linked Shopify product's primary image, or '' if no image is available.
    /// Internally queries Shopify via GraphQL using the Product GID assigned to the Store-Item Link.
    /// Returns '' immediately when no Shopify Product ID has been assigned to the link record.
    /// </summary>
    /// <param name="SpfyStoreItemLink">The Store-Item Link record identifying which Shopify product to fetch the image for.</param>
    /// <returns>The first image URL from Shopify, or '' if there is none.</returns>
    procedure GetShopifyPictureUrl(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"): Text
    var
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
    begin
        exit(SpfyItemMgt.GetShopifyPictureUrl(SpfyStoreItemLink));
    end;

    /// <summary>
    /// Sends a pre-built Shopify GraphQL request and parses the response.
    /// The request payload must already be written to NcTask."Data Output" (use
    /// CreateGraphQLRequestWithOrderIdFilter or build the payload directly). NcTask."Store Code"
    /// must be set so the handler can resolve credentials and endpoints. The HTTP response is
    /// stored on NcTask.Response and parsed into ShopifyResponse for the caller.
    /// </summary>
    /// <param name="NcTask">NC task carrying the request payload, store code, and target for the response.</param>
    /// <param name="CheckIntegrationIsEnabled">When true, the call exits early if integration is disabled for the store.</param>
    /// <param name="ShopifyResponse">Out: the parsed JSON response.</param>
    /// <returns>True on a successful HTTP exchange. False on transport failure or when integration was disabled; call GetLastErrorText for details.</returns>
    procedure ExecuteShopifyGraphQLRequest(var NcTask: Record "NPR Nc Task"; CheckIntegrationIsEnabled: Boolean; var ShopifyResponse: JsonToken) Success: Boolean
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
    begin
        Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, CheckIntegrationIsEnabled, ShopifyResponse);
    end;

    /// <summary>
    /// [Obsolete] Fetches the legacy REST fulfillment_orders payload for a Shopify order.
    /// Use CreateGraphQLRequestWithOrderIdFilter + ExecuteShopifyGraphQLRequest with a fulfillmentOrders
    /// GraphQL query instead — the REST endpoint will be removed by Shopify in a future API version.
    /// </summary>
    /// <param name="ShopifyStoreCode">Shopify store code used to resolve credentials.</param>
    /// <param name="ShopifyOrderID">Numeric Shopify Order ID (no GID prefix).</param>
    /// <param name="ShopifyResponse">Out: parsed JSON response from the REST endpoint.</param>
    [Obsolete('This method uses deprecated Shopify REST fulfillment endpoints. Use CreateGraphQLRequestWithOrderIdFilter and ExecuteShopifyGraphQLRequest instead.', '2026-01-15')]
    procedure GetShopifyOrderFulfillmentOrders(ShopifyStoreCode: Code[20]; ShopifyOrderID: Text[30]; var ShopifyResponse: JsonToken)
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
    begin
        SpfyCommunicationHandler.GetShopifyOrderFulfillmentOrders(ShopifyStoreCode, ShopifyOrderID, ShopifyResponse);
    end;

    /// <summary>
    /// Sets the "Allow Backorder" flag on the NPR Spfy Item Variant Modif. record that overrides the
    /// inventory policy for a specific (Item, Variant, Store) tuple. When true, the inventory level
    /// sync will mark the variant as available even when on-hand quantity is zero.
    /// Creates the modifier record on demand when needed; deletes it when Allow=false would mean
    /// "no override" and no other fields are set.
    /// </summary>
    /// <param name="ItemNo">BC Item No.</param>
    /// <param name="VariantCode">Variant Code; blank for the base item.</param>
    /// <param name="ShopifyStoreCode">Target Shopify store.</param>
    /// <param name="Allow">True to enable backorder for this variant in this store.</param>
    /// <param name="DisableDataLog">When true, the Modify is wrapped in DisableDataLog so the change does not schedule an inventory NcTask.</param>
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

    /// <summary>
    /// Registers or removes a Shopify webhook subscription for the given topic at the given store.
    /// On Enable=true, the subscription is created at Shopify (replacing any existing one for the same
    /// topic), the BC webservice that receives webhook callbacks is registered, and the webhook-processing
    /// job queue entry is ensured. On Enable=false, the subscription is removed from Shopify, the
    /// webservice is unregistered if no other subscriptions remain, and the JQ entry is cancelled.
    /// </summary>
    /// <param name="ShopifyStoreCode">Shopify store at which to register/remove the subscription.</param>
    /// <param name="Topic">The webhook topic (e.g. orders/create, customers/update).</param>
    /// <param name="IncludeFields">List of payload fields to include in webhook notifications. Pass an empty list for the full payload.</param>
    /// <param name="Enable">True to register, false to remove.</param>
    /// <returns>The entry number of the resulting NPR Spfy Webhook Subscription row; 0 if no subscription remains.</returns>
    procedure ToggleWebhook(ShopifyStoreCode: Code[20]; Topic: Enum "NPR Spfy Webhook Topic"; IncludeFields: List of [Text]; Enable: Boolean) WebhookSubscrEntryNo: Integer
    var
        SpfyWebhookMgt: Codeunit "NPR Spfy Webhook Mgt.";
    begin
        WebhookSubscrEntryNo := SpfyWebhookMgt.ToggleWebhook(ShopifyStoreCode, Topic, IncludeFields, Enable);
    end;
}
#endif
