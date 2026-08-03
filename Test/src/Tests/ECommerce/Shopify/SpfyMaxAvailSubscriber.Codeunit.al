#if not BC17
codeunit 85342 "NPR Spfy Max Avail Subscriber"
{
    // Test double for the public OnCalculateFulfillmentQuantity seam: forces the FulfillMaxAvailableQty path so a test can
    // pin that the retry deduction never blocks a subscriber that wants Shopify's live remaining quantity fulfilled.
    // Manual-binding so it affects only the single test that binds it, never the rest of the suite.
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Spfy Integration Events", 'OnCalculateFulfillmentQuantity', '', false, false)]
    local procedure SetFulfillMaxAvailable(RecID: RecordId; SpfyOrderLineId: Text[30]; var FulfillmentQty: Decimal; var FulfillMaxAvailableQty: Boolean)
    begin
        FulfillMaxAvailableQty := true;
    end;
}
#endif
