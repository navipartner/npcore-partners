#if not BC17
codeunit 6184824 "NPR Spfy Integration Events"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterCreateDataLogSetup(IntegrationArea: Enum "NPR Spfy Integration Area")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSetupDataLogSubsriberDataProcessingParams(IntegrationArea: Enum "NPR Spfy Integration Area"; TableID: Integer; var DataLogSubscriber: Record "NPR Data Log Subscriber"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCheckIfStoreIntegrationAreaIsEnabled(IntegrationArea: Enum "NPR Spfy Integration Area"; ShopifyStoreCode: Code[20]; var AreaIsEnabled: Boolean; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCheckIfStoreIntegrationAreaIsEnabled(IntegrationArea: Enum "NPR Spfy Integration Area"; ShopifyStoreCode: Code[20]; var AreaIsEnabled: Boolean; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeFindCustomer(Order: JsonToken; var Customer: Record Customer; var SalesHeader: Record "Sales Header"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnUpdateSalesHeader(Order: JsonToken; var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeFillInSalesLine(OrderLine: JsonToken; FulfilledQty: Decimal; ForPosting: Boolean; ItemVariant: Record "Item Variant"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterUpsertSalesLine(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; IsNewLine: Boolean; xSalesLine: Record "Sales Line"; var LastLineNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterUpsertSalesLineShipmentFee(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; IsNewLine: Boolean; xSalesLine: Record "Sales Line"; var LastLineNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertPaymentLines(ShopifyStoreCode: Code[20]; Order: JsonToken; var SalesHeader: Record "Sales Header"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInsertPaymentLines(ShopifyStoreCode: Code[20]; Order: JsonToken; var SalesHeader: Record "Sales Header"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCheckIfSkipLine(OrderLine: JsonToken; var SkipLine: Boolean; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCheckIfIsEligibleForFulfillmentSending(RecID: RecordId; SpfyOrderLineId: Text[30]; var Eligible: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCalculateFulfillmentQuantity(RecID: RecordId; SpfyOrderLineId: Text[30]; var FulfillmentQty: Decimal; var FulfillMaxAvailableQty: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInitCreditCardPaymentLine(var PaymentLine: Record "NPR Magento Payment Line"; PaymentMapping: Record "NPR Magento Payment Mapping"; ShopifyTransactionJToken: JsonToken)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterAddGiftCardPaymentLine(var PaymentLine: Record "NPR Magento Payment Line"; var NpRvSalesLine: Record "NPR NpRv Sales Line"; ShopifyTransactionJToken: JsonToken)
    begin
    end;

#if (BC18 or BC19)
    [IntegrationEvent(false, false)]
#else
    [IntegrationEvent(false, false, true)]  //isolated event
#endif
    internal procedure OnModifyPaymentLineAfterCaptureIsolated(var PaymentLine: Record "NPR Magento Payment Line"; var NcTask: Record "NPR Nc Task")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure LocationCardOnCheckIfShopifyIntegrationIsEnabled(Rec: Record Location; var IsEnabled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterCalculateUnitPrice(Item: Record Item; VariantCode: Code[20]; UnitOfMeasure: Code[20]; ShopifyStoreCode: Code[20]; CurrencyCode: Code[10]; var Price: Decimal; var ComparePrice: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCalculateUnitPrice(Item: Record Item; VariantCode: Code[20]; UnitOfMeasure: Code[20]; ShopifyStoreCode: Code[20]; CurrencyCode: Code[10]; var Price: Decimal; var ComparePrice: Decimal; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnTreatSuccessfulResponseAsError(NcTask: Record "NPR Nc Task"; ResponseMsg: HttpResponseMessage; ResponseJToken: JsonToken; var ErrorTxt: Text; var IsError: Boolean; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnTreatErroneousResponseAsSuccess(NcTask: Record "NPR Nc Task"; ResponseMsg: HttpResponseMessage; ResponseJToken: JsonToken; var ErrorTxt: Text; var IsSuccess: Boolean; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterGenerateVariantJObject(ItemVariant: Record "Item Variant"; var VariantJObject: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterUpdateAllowBackorder(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; Allow: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterUpdateDoNotTrackInventory(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; DoNotTrack: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCalculateInventoryLevel(ShopifyStoreCode: Code[20]; LocationFilter: Text; ItemNo: Code[20]; VariantCode: Code[10]; IncludeTransferOrders: Option No,Outbound,All; var StockQty: Decimal; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGetTrackingCompanyName(SalesShipmentHeader: Record "Sales Shipment Header"; var TrackingCompanyName: Text; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGetTrackingUrl(SalesShipmentHeader: Record "Sales Shipment Header"; var TrackingUrl: Text; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCheckIfShouldSkipOrderImport(ShopifyStoreCode: Code[20]; Order: JsonToken; var SkipImport: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterSetPaymentCardDetails(Transaction: JsonToken; var PaymentLine: Record "NPR Magento Payment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCheckIfShopifyVoucherReferenceNoValidationSuspended(var Suspended: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSpfyWebhookTopicName(Topic: Enum "NPR Spfy Webhook Topic"; GraphQLName: Boolean; var Result: Text)
    begin
    end;

#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeFindCustomerInEcommerceDocument(OrderJsonToken: JsonToken; var Customer: Record Customer; var EcomSalesHeader: Record "NPR Ecom Sales Header"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterParseEcommerceSalesLine(SalesLineJsonToken: JsonToken; var EcomSalesLine: Record "NPR Ecom Sales Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertEcommerceSalesLine(SalesLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesLine: Record "NPR Ecom Sales Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertEcommerceSalesPaymentLine(PaymentLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterParseEcommerceSalesPaymentLine(PaymentLineJsonToken: JsonToken; var EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterParseEcommerceSalesHeader(var EcomSalesHeader: Record "NPR Ecom Sales Header"; RequestBody: JsonToken);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertEcommerceSalesPaymentLines(ShopifyStoreCode: Code[20]; OrderJsonToken: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInsertEcommercePaymentLines(ShopifyStoreCode: Code[20]; OrderJsonToken: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCheckShouldSkipEcommerceDocumentImport(ShopifyStoreCode: Code[20]; OrderJsonToken: JsonToken; var SkipImport: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertEcommerceSalesHeader(var EcomSalesHeader: Record "NPR Ecom Sales Header"; OrderJsonToken: JsonToken);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterParseEcommerceVoucherPaymentLine(PaymentLineJsonToken: JsonToken; var EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterParseEcommercePaymentMethodPaymentLine(PaymentLineJsonToken: JsonToken; var EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeUpdateSalesLine(OrderLine: JsonToken; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterUpdateSalesLine(OrderLine: JsonToken; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; NewLine: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterUpdateSalesLineShipmentFee(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; NewLine: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeUpdatePaymentLines(ShopifyStoreCode: Code[20]; PaymentLinesJsonToken: JsonToken; var SalesHeader: Record "Sales Header"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterUpdatePaymentLines(ShopifyStoreCode: Code[20]; PaymentLinesJsonToken: JsonToken; var SalesHeader: Record "Sales Header"; var Handled: Boolean)
    begin
    end;
#endif
}
#endif