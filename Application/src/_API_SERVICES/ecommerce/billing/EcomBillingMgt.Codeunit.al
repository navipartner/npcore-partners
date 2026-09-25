#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6151515 "NPR Ecom Billing Mgt."
{
    Access = Internal;
    TableNo = "NPR Ecom Sales Header";
    Permissions =
        TableData "NPR Ecom Billing Event" = RIM,
        TableData "NPR Billing Queue Entry" = R;

    var
        _MetadataStoreCodeTok: Label '%1_store_code', Locked = true;
        _MetadataExternalNoTok: Label 'external_no', Locked = true;
        _MetadataCurrencyTok: Label 'currency', Locked = true;

    trigger OnRun()
    begin
        RegisterCapturedAmount(Rec);
    end;

    /// <summary>Registers the one count event of an imported order.</summary>
    internal procedure RegisterOrderImported(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
    begin
        if EcomSalesHeader."Document Source" <> EcomSalesHeader."Document Source"::Entria then
            exit;

        if EcomSalesHeader."Document Type" <> EcomSalesHeader."Document Type"::Order then
            exit;

        if GetOrderEvent(EcomBillingEvent, EcomSalesHeader."Document Source", EcomSalesHeader."Ecommerce Store Code", EcomSalesHeader."External No.") then
            exit;

        InsertOrderEvent(EcomBillingEvent, EcomSalesHeader);
        RegisterBillingEvent(EcomBillingEvent);
    end;

    local procedure InsertOrderEvent(var EcomBillingEvent: Record "NPR Ecom Billing Event"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        EcomBillingEvent.Init();
        EcomBillingEvent.Channel := EcomSalesHeader."Document Source";
        EcomBillingEvent."Store Code" := EcomSalesHeader."Ecommerce Store Code";
        EcomBillingEvent."External No." := EcomSalesHeader."External No.";
        EcomBillingEvent."Event Type" := Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_COUNT;
        EcomBillingEvent.Amount := 1;
        EcomBillingEvent."Currency Code" := ResolveCurrencyCode(EcomSalesHeader."Currency Code", EcomSalesHeader."Ecommerce Store Code", EcomSalesHeader."External No.");
        EcomBillingEvent."Registered At" := CurrentDateTime();
        EcomBillingEvent.Insert();
    end;

    /// <summary>
    /// Resolves the currency an event row must carry, reporting rather than failing when none can be found.
    /// </summary>
    /// <remarks>
    /// A blank on the document means "same as LCY": the Entria intake writes "Currency Code" only when the payload
    /// value differs from "LCY Code" (EntriaOrderImpl), so the fallback restores the real ISO code rather than
    /// inventing one.
    ///
    /// If even "LCY Code" is blank the event is still registered, with a blank currency, and the gap goes to Sentry
    /// instead. Refusing to register would cost the charge outright over a setup problem the order has nothing to do
    /// with; registering keeps the money side whole and leaves a row that can be corrected once the company is
    /// configured. The report carries the order number so the document can be found without a query.
    ///
    /// Applied by both writers on purpose. InsertAmountEvent copies the order event's currency, so without the same
    /// resolution here a single order event written blank would hand every later amount row the same blank, and no
    /// amount of later setup would repair them.
    /// </remarks>
    local procedure ResolveCurrencyCode(CurrencyCode: Code[10]; StoreCode: Code[20]; ExternalNo: Code[20]): Code[10]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        BlankCurrencyTok: Label 'No currency could be resolved for ecommerce order %1 in store %2. The billing event is registered without a currency.', Locked = true;
    begin
        if CurrencyCode <> '' then
            exit(CurrencyCode);

        GeneralLedgerSetup.GetRecordOnce();
        if GeneralLedgerSetup."LCY Code" = '' then
            EmitSentryError(StrSubstNo(BlankCurrencyTok, ExternalNo, StoreCode), StoreCode, ExternalNo, 0D, '');

        exit(GeneralLedgerSetup."LCY Code");
    end;

    /// <summary>Registers the amount actually captured for the order.</summary>
    /// <remarks>
    /// The base is Captured Payment Amount, so anything BC never recorded as captured is never billed. Two shapes
    /// end up unbilled for that reason:
    /// 1. Payment lines whose mapping is Captured Externally: known billing gap; separate ticket tracks the shared-code fix.
    /// 2. Orders whose virtual item lines are all free: by design, nothing to bill.
    /// </remarks>
    internal procedure RegisterCapturedAmount(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        MissingOrderEventTok: Label 'No ecommerce billing order event row exists for ecommerce order %1, so no amount billing event was registered and the order is not billed.', Locked = true;
    begin
        if EcomSalesHeader."Document Source" <> EcomSalesHeader."Document Source"::Entria then
            exit;

        if EcomSalesHeader."Document Type" <> EcomSalesHeader."Document Type"::Order then
            exit;
        // A missing order event row is NOT an expected state. Every imported order has one, because
        // RegisterOrderImported is deliberately left unguarded - the order either imports whole or rolls back.
        if not GetOrderEvent(EcomBillingEvent, EcomSalesHeader."Document Source", EcomSalesHeader."Ecommerce Store Code", EcomSalesHeader."External No.") then begin
            EmitSentryError(StrSubstNo(MissingOrderEventTok, EcomSalesHeader."External No."), EcomSalesHeader."Ecommerce Store Code", EcomSalesHeader."External No.", EcomSalesHeader."Received Date", '');
            exit;
        end;

        EcomSalesHeader.CalcFields("Captured Payment Amount");
        RegisterAmountDelta(EcomBillingEvent, EcomSalesHeader."Captured Payment Amount");
    end;

    local procedure RegisterAmountDelta(OrderEvent: Record "NPR Ecom Billing Event"; TotalToBill: Decimal)
    var
        EcomBillingEvent: Record "NPR Ecom Billing Event";
        BilledAmount: Decimal;
        Delta: Decimal;
    begin
        BilledAmount := CalcBilledAmount(OrderEvent);
        Delta := TotalToBill - BilledAmount;

        // Nothing new to bill
        if Delta <= 0 then
            exit;

        InsertAmountEvent(EcomBillingEvent, OrderEvent, Delta);
        RegisterBillingEvent(EcomBillingEvent);
    end;

    /// <summary>
    /// Writes the amount event row for one delta, carrying the identity of its order event.
    /// </summary>
    local procedure InsertAmountEvent(var EcomBillingEvent: Record "NPR Ecom Billing Event"; OrderEvent: Record "NPR Ecom Billing Event"; Amount: Decimal)
    begin
        EcomBillingEvent.Init();
        EcomBillingEvent.Channel := OrderEvent.Channel;
        EcomBillingEvent."Store Code" := OrderEvent."Store Code";
        EcomBillingEvent."External No." := OrderEvent."External No.";
        EcomBillingEvent."Currency Code" := ResolveCurrencyCode(OrderEvent."Currency Code", OrderEvent."Store Code", OrderEvent."External No.");
        EcomBillingEvent."Event Type" := Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_AMOUNT_SHOP;
        EcomBillingEvent.Amount := Amount;
        EcomBillingEvent."Registered At" := CurrentDateTime();
        EcomBillingEvent.Insert();
    end;

    /// <summary>
    /// Sums the amount already billed for the order event's order from its queued amount child rows. There is no stored
    /// progress field any more - this is computed fresh every time.
    /// </summary>
    local procedure CalcBilledAmount(OrderEvent: Record "NPR Ecom Billing Event"): Decimal
    var
        EcomBillingEventProgress: Record "NPR Ecom Billing Event";
    begin
        LinkChargedAmountRows(OrderEvent);

        FilterAmountRows(EcomBillingEventProgress, OrderEvent);
        EcomBillingEventProgress.SetFilter("Billing Queue Entry No.", '<>%1', 0);
        EcomBillingEventProgress.CalcSums(Amount);
        exit(EcomBillingEventProgress.Amount);
    end;

    /// <summary>
    /// Links any amount row of the order that was charged but never got its queue entry number written back, so
    /// that the progress sum counts it. Repairs the row as a side effect.
    /// </summary>
    local procedure LinkChargedAmountRows(OrderEvent: Record "NPR Ecom Billing Event")
    var
        EcomBillingEventUnqueued: Record "NPR Ecom Billing Event";
    begin
        FilterAmountRows(EcomBillingEventUnqueued, OrderEvent);
        EcomBillingEventUnqueued.SetRange("Billing Queue Entry No.", 0);
        if not EcomBillingEventUnqueued.FindSet(true) then
            exit;

        repeat
            if LinkChargedRow(EcomBillingEventUnqueued) then;
        until EcomBillingEventUnqueued.Next() = 0;
    end;

    /// <summary>
    /// Links one event row to the billing queue entry that carries its event id, if there is one. True means the
    /// row was charged after all and now says so; false means nothing ever charged it.
    /// </summary>
    local procedure LinkChargedRow(var EcomBillingEvent: Record "NPR Ecom Billing Event"): Boolean
    var
        BillingQueueEntry: Record "NPR Billing Queue Entry";
    begin
        BillingQueueEntry.SetCurrentKey("Event ID", "Is Production Environment");
        BillingQueueEntry.SetRange("Event ID", EcomBillingEvent.SystemId);
        if not BillingQueueEntry.FindFirst() then
            exit(false);

        EcomBillingEvent."Billing Queue Entry No." := BillingQueueEntry."Entry No.";
        EcomBillingEvent.Modify();
        exit(true);
    end;

    /// <summary>
    /// Filters an event record down to the amount rows of the order event's order.
    /// </summary>
    local procedure FilterAmountRows(var EcomBillingEvent: Record "NPR Ecom Billing Event"; OrderEvent: Record "NPR Ecom Billing Event")
    begin
        EcomBillingEvent.Reset();
        EcomBillingEvent.SetRange(Channel, OrderEvent.Channel);
        EcomBillingEvent.SetRange("Store Code", OrderEvent."Store Code");
        EcomBillingEvent.SetRange("External No.", OrderEvent."External No.");
        EcomBillingEvent.SetRange("Event Type", Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_AMOUNT_SHOP);
    end;

    local procedure BuildEventMetadata(EcomBillingEvent: Record "NPR Ecom Billing Event") MetadataJson: JsonObject
    begin
        if EcomBillingEvent."Store Code" <> '' then
            MetadataJson.Add(StrSubstNo(_MetadataStoreCodeTok, GetChannelName(EcomBillingEvent.Channel)), EcomBillingEvent."Store Code");
        MetadataJson.Add(_MetadataExternalNoTok, EcomBillingEvent."External No.");
        MetadataJson.Add(_MetadataCurrencyTok, EcomBillingEvent."Currency Code");
    end;

    local procedure GetChannelName(Channel: Enum "NPR Ecom Sales Doc Source"): Text
    begin
        exit(Channel.Names().Get(Channel.Ordinals().IndexOf(Channel.AsInteger())).ToLower());
    end;

    /// <summary>
    /// Registers an event row that has already been written, and links it to the queue entry it produced. The
    /// event id handed to the transport is the row's own SystemId, never a fresh one.
    /// </summary>
    local procedure RegisterBillingEvent(var EcomBillingEvent: Record "NPR Ecom Billing Event")
    var
        EventBillingClient: Codeunit "NPR Event Billing Client";
        MetadataJson: JsonObject;
        QueueEntryNo: BigInteger;
    begin
        MetadataJson := BuildEventMetadata(EcomBillingEvent);
        QueueEntryNo := EventBillingClient.RegisterEvent(
            EcomBillingEvent.SystemId, EcomBillingEvent."Event Type", EcomBillingEvent.Amount, MetadataJson.AsToken());

        EcomBillingEvent."Billing Queue Entry No." := QueueEntryNo;
        EcomBillingEvent.Modify();
    end;

    /// <summary>
    /// Finds the order event row of an order by the full identity known while the ecommerce document is in hand:
    /// channel, store and order number. Read without an update lock, for two reasons.
    ///
    /// The row is written once and settles: RegisterOrderImported inserts it and RegisterBillingEvent writes its
    /// queue entry number back in that same call, and nothing updates the order event row after that. Only its
    /// AMOUNT_SHOP children are modified later, by LinkChargedRow.
    ///
    /// The intake race that would otherwise write two order event rows for one order is closed upstream, in
    /// EntriaOrderImpl.TryGetExistingOrder: it takes an UpdLock on the order's "NPR Entria Store" row BEFORE it
    /// looks for an existing ecommerce document, so a concurrent import of the same order serialises there, then
    /// finds the document the first import created and returns without ever reaching RegisterOrderImported. That
    /// per-store lock is the whole protection - if it is ever removed or narrowed, this read needs rethinking.
    /// </summary>
    local procedure GetOrderEvent(var EcomBillingEvent: Record "NPR Ecom Billing Event"; ChannelParam: Enum "NPR Ecom Sales Doc Source"; StoreCode: Code[20]; ExternalNo: Code[20]): Boolean
    begin
        EcomBillingEvent.Reset();
        EcomBillingEvent.SetRange(Channel, ChannelParam);
        EcomBillingEvent.SetRange("Store Code", StoreCode);
        EcomBillingEvent.SetRange("External No.", ExternalNo);
        EcomBillingEvent.SetRange("Event Type", Enum::"NPR Billing Event Type"::ECOM_ENTRIA_ORDERS_COUNT);
        if not EcomBillingEvent.FindFirst() then
            exit(false);

        CheckSingleOrderEvent(EcomBillingEvent, StoreCode, ExternalNo, StrSubstNo('%1/%2/%3', GetChannelName(ChannelParam), StoreCode, ExternalNo));
        exit(true);
    end;

    local procedure CheckSingleOrderEvent(EcomBillingEvent: Record "NPR Ecom Billing Event"; StoreCode: Code[20]; ExternalNo: Code[20]; Identity: Text)
    var
        DuplicateOrderEventTok: Label 'More than one ecommerce billing count row exists for %1. This is a programming bug.', Locked = true;
    begin
        if EcomBillingEvent.Next() = 0 then
            exit;
        EmitSentryError(StrSubstNo(DuplicateOrderEventTok, Identity), StoreCode, ExternalNo, 0D, '');
    end;

    /// <summary>
    /// The one place this feature reports to Sentry. Opens a scope only when no transaction is already active.
    /// </summary>
    /// <param name="ErrorCallStack">
    /// The English call stack of a caught error, or blank when the message is authored by the caller rather than
    /// derived from one - a caller reporting a state it found has no error to take a stack from.
    /// </param>
    local procedure EmitSentryError(ErrorText: Text; StoreCode: Code[20]; ExternalNo: Code[20]; ReceivedDate: Date; ErrorCallStack: Text)
    var
        Sentry: Codeunit "NPR Sentry";
        OwnsTransaction: Boolean;
        TransactionNameTok: Label 'Ecommerce Billing Registration: %1', Locked = true;
    begin
        OwnsTransaction := not Sentry.HasActiveTransaction();
        if OwnsTransaction then begin
            Sentry.InitScopeAndTransaction(StrSubstNo(TransactionNameTok, ExternalNo), 'bc.e-com.billing.register');
            Sentry.AddTransactionTag('e-com.store_code', StoreCode);
            Sentry.AddTransactionTag('e-com.external_no', ExternalNo);
            if ReceivedDate <> 0D then
                Sentry.AddTransactionTag('e-com.received_date', Format(ReceivedDate, 0, 9));
        end;
        Sentry.AddError(ErrorText, ErrorCallStack);

        if OwnsTransaction then
            Sentry.FinalizeScope();
    end;

    /// <summary>
    /// Registers the captured amount for an Entria order, isolated from the caller's transaction.
    /// </summary>
    /// </remarks>
    internal procedure RegisterAmountEvent(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomBillingMgt: Codeunit "NPR Ecom Billing Mgt.";
        Sentry: Codeunit "NPR Sentry";
        ErrorCallStack: Text;
        LastErrorText: Text;
        FailureFormatTok: Label 'Failed to register billing for ecommerce order %1 in store %2, so the order is under-billed by the amount that call would have registered: %3', Locked = true;
    begin
        EcomSalesHeader.ReadIsolation := EcomSalesHeader.ReadIsolation::UpdLock;
        EcomSalesHeader.Get(EcomSalesHeader.RecordId);
        if EcomSalesHeader."Document Source" <> EcomSalesHeader."Document Source"::Entria then
            exit;

        Commit();
        if EcomBillingMgt.Run(EcomSalesHeader) then
            exit;

        // Snapshot the cause in English now, before EmitSentryError opens a scope and adds tags: a TryFunction
        // along the way would replace the last error with its own.
        Sentry.GetLastErrorInEnglish(LastErrorText, ErrorCallStack);
        EmitSentryError(
            StrSubstNo(FailureFormatTok, EcomSalesHeader."External No.", EcomSalesHeader."Ecommerce Store Code", LastErrorText),
            EcomSalesHeader."Ecommerce Store Code", EcomSalesHeader."External No.", EcomSalesHeader."Received Date", ErrorCallStack);
    end;

}
#endif
