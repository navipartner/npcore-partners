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
    internal procedure OnCheckIfIntegrationAreaIsEnabled(IntegrationArea: Enum "NPR Spfy Integration Area"; var AreaIsEnabled: Boolean; var Handled: Boolean)
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

    [Obsolete('Use event OnAfterInsertPaymentLines instead', 'NPR33.0')]
    [IntegrationEvent(false, false)]
    internal procedure OnInsertPaymentLines(var SalesHeader: Record "Sales Header"; var Handled: Boolean)
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
}
#endif