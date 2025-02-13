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
    internal procedure OnUpdateSalesHeader(Order: JsonToken; var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeFillInSalesLine(OrderLine: JsonToken; FulfilledQty: Decimal; ForPosting: Boolean; ItemVariant: Record "Item Variant"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInsertSalesLine(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; var LastLineNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInsertSalesLineShipmentFee(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; var LastLineNo: Integer)
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

    [IntegrationEvent(false, false)]
    internal procedure OnModifyPaymentLineAfterCapture(var PaymentLine: Record "NPR Magento Payment Line"; var NcTask: Record "NPR Nc Task")
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
}
#endif