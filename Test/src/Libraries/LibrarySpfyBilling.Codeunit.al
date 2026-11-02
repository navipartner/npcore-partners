codeunit 85575 "NPR Library - Spfy Billing"
{
    // Readbacks of the Shopify order amount billing events (presentment and shop currency) in the billing queue.
    Access = Internal;

    var
        _Assert: Codeunit Assert;

    procedure LastBillingQueueEntryNo(): BigInteger
    var
        BillingQueueEntry: Record "NPR Billing Queue Entry";
    begin
        if not BillingQueueEntry.FindLast() then
            exit(0);
        exit(BillingQueueEntry."Entry No.");
    end;

    procedure AmountQueueEntriesSince(StartEntryNo: BigInteger): Integer
    var
        BillingQueueEntry: Record "NPR Billing Queue Entry";
    begin
        BillingQueueEntry.SetFilter("Entry No.", '>%1', StartEntryNo);
        BillingQueueEntry.SetFilter("Feature ID", '%1|%2',
            Enum::"NPR Billing Event Type"::ECOM_SHOPIFY_ORDERS_AMOUNT_PRESENTMENT.AsInteger(), Enum::"NPR Billing Event Type"::ECOM_SHOPIFY_ORDERS_AMOUNT_SHOP.AsInteger());
        exit(BillingQueueEntry.Count());
    end;

    procedure AssertSingleAmountQueueEntry(EventId: Guid; EventType: Enum "NPR Billing Event Type"; ExpectedQuantity: Decimal)
    var
        BillingQueueEntry: Record "NPR Billing Queue Entry";
        OneEntryPerEventIdLbl: Label 'Exactly one billing queue entry must carry event id %1', Locked = true;
    begin
        BillingQueueEntry.SetRange("Event ID", EventId);
        _Assert.AreEqual(1, BillingQueueEntry.Count(), StrSubstNo(OneEntryPerEventIdLbl, Format(EventId, 0, 4)));
        BillingQueueEntry.FindFirst();
        _Assert.AreEqual(EventType.AsInteger(), BillingQueueEntry."Feature ID", 'The queued billing event must carry the feature id of the expected event type');
        _Assert.AreEqual(ExpectedQuantity, BillingQueueEntry.Quantity, 'The queued billing event must carry the captured amount as its quantity');
    end;

    procedure AmountQueueEntryMetadata(EventId: Guid; MetadataKey: Text): Text
    var
        BillingQueueEntry: Record "NPR Billing Queue Entry";
        Metadata: JsonObject;
        MetadataValue: JsonToken;
    begin
        BillingQueueEntry.SetRange("Event ID", EventId);
        BillingQueueEntry.FindFirst();
        Metadata.ReadFrom(BillingQueueEntry.GetMetadata());
        Metadata.Get(MetadataKey, MetadataValue);
        exit(MetadataValue.AsValue().AsText());
    end;
}
