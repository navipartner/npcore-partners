#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248621 "NPR Spfy Event Log Mgt."
{
    Access = Internal;
    internal procedure InsertShopifyLog(OrderTkn: JsonToken; PSpfyEventLogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    var
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
    begin
        SpfyEventLogEntry.Init();
        SpfyEventLogEntry := PSpfyEventLogEntry;
        if not TryInsertLog(OrderTkn, SpfyEventLogEntry) then
            exit;
        exit(SpfyEventLogEntry.Insert());
    end;

    [TryFunction]
    local procedure TryInsertLog(OrderTkn: JsonToken; var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    var
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        AlreadyExistsErr: Label 'A log entry for Order ID %1 with status %2 already exists.', Comment = '%1=Order ID, %2=Order Status';
    begin
        SpfyEventLogEntry.Type := SpfyEventLogEntry.Type::"Incoming Sales Order";
        SpfyEventLogEntry."Entry No." := 0;
        SpfyEventLogEntry."Shopify ID" := OrderMgt.GetNumericId(JsonHelper.GetJText(OrderTkn, 'id', true));
        SpfyEventLogEntry."Event Date-Time" := JsonHelper.GetJDT(OrderTkn, 'createdAt', true);
        SpfyEventLogEntry."Document Name" := CopyStr(JsonHelper.GetJText(OrderTkn, 'name', false), 1, MaxStrLen(SpfyEventLogEntry."Document Name"));
        SpfyEventLogEntry."Bucket Id" := Random(100);
        if SpfyEventLogEntry."Document Type" = SpfyEventLogEntry."Document Type"::Order then
            SetCurrencyCodeOrDefer(OrderTkn, SpfyEventLogEntry);
        SetDates(SpfyEventLogEntry, SpfyEventLogEntry."Document Status", OrderTkn);
        If LogEntryExist(SpfyEventLogEntry."Shopify ID", SpfyEventLogEntry."Document Status", SpfyEventLogEntry."Store Code", SpfyEventLogEntry."Document Type") then
            Error(AlreadyExistsErr, SpfyEventLogEntry."Shopify ID", SpfyEventLogEntry."Document Status");
    end;

    internal procedure LogEntryExist(OrderId: Text[30]; OrderStatus: enum "NPR SpfyAPIDocumentStatus"; StoreCode: code[20]; DocType: enum "NPR SpfyEventLogDocType"): Boolean
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
    begin
        LogEntry.SetCurrentKey("Type", "Store Code", "Shopify ID", "Document Status", "Document Type");
        LogEntry.ReadIsolation := IsolationLevel::ReadCommitted;
        LogEntry.SetRange(Type, LogEntry.Type::"Incoming Sales Order");
        LogEntry.SetRange("Store Code", StoreCode);
        LogEntry.SetRange("Shopify ID", OrderId);
        LogEntry.SetRange("Document Type", DocType);
        LogEntry.SetFilter("Document Status", '%1|%2', OrderStatus, OrderStatus::" ");
        exit(LogEntry.FindFirst());
    end;

    local procedure SetDates(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"; OrderStatus: enum "NPR SpfyAPIDocumentStatus"; OrderToken: JsonToken)
    begin
        case true of
            OrderStatus = OrderStatus::Closed:
                SpfyEventLogEntry."Closed Date-Time" := JsonHelper.GetJDT(OrderToken, 'closedAt', true);
            OrderStatus = OrderStatus::Cancelled:
                SpfyEventLogEntry."Cancelled Date" := DT2Date(JsonHelper.GetJDT(OrderToken, 'cancelledAt', true));
        end;
    end;

    local procedure SetCurrencyCodeOrDefer(Order: JsonToken; var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    var
        CurrencyDeferredLbl: Label 'The currency of the order could not be resolved while it was logged and will be resolved when the order is processed: %1', Comment = '%1 = the error reported by the currency lookup';
    begin
        if TrySetCurrencyCode(Order, SpfyEventLogEntry) then
            exit;
        ClearCurrencyFields(SpfyEventLogEntry);
        SpfyEventLogEntry."Last Error Message" := CopyStr(StrSubstNo(CurrencyDeferredLbl, GetLastErrorText()), 1, MaxStrLen(SpfyEventLogEntry."Last Error Message"));
        ClearLastError();
    end;

    /// <summary>
    /// SetCurrencyCode writes the currency fields one after another and can fail after the first of them - the store
    /// currency may have no Currency record, or the order date no exchange rate. A failing TryFunction rolls back the
    /// database but not the in-memory state of a var parameter, so the half-written record would be stored with a
    /// non-blank "Presentment Currency Code" and "Amount (LCY)" = 0. That reads as resolved to
    /// CurrencyResolutionPending, so the deferral would never be picked up again.
    /// </summary>
    local procedure ClearCurrencyFields(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    begin
        SpfyEventLogEntry."Presentment Currency Code" := '';
        SpfyEventLogEntry."Store Currency Code" := '';
        SpfyEventLogEntry."Amount (PCY)" := 0;
        SpfyEventLogEntry."Amount (SCY)" := 0;
        SpfyEventLogEntry."Amount (LCY)" := 0;
    end;

    [TryFunction]
    local procedure TrySetCurrencyCode(Order: JsonToken; var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    begin
        SetCurrencyCode(Order, SpfyEventLogEntry);
    end;

    internal procedure ResolveCurrencyIfPending(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"; Response: JsonToken)
    var
        OrderToken: JsonToken;
        MissingOrderNodeErr: Label 'Invalid Shopify response: missing "data.order" node.', Locked = true;
    begin
        if not CurrencyResolutionPending(SpfyEventLogEntry) then
            exit;
        if not Response.SelectToken('data.order', OrderToken) then
            Error(MissingOrderNodeErr);
        // Raised, not deferred again: by the time the order is processed the currency has to resolve. The fields are
        // cleared first so the entry keeps its "not resolved yet" state and a later retry gets another attempt.
        if not TrySetCurrencyCode(OrderToken, SpfyEventLogEntry) then begin
            ClearCurrencyFields(SpfyEventLogEntry);
            Error(GetLastErrorText());
        end;
        SpfyEventLogEntry.Modify();
    end;

    local procedure CurrencyResolutionPending(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    begin
        exit((SpfyEventLogEntry."Document Type" = SpfyEventLogEntry."Document Type"::Order) and (SpfyEventLogEntry."Presentment Currency Code" = ''));
    end;

    local procedure SetCurrencyCode(Order: JsonToken; var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    var
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
        PresentmentCurrencyCodeIsLCY: Boolean;
        StoreCurrencyCodeIsLCY: Boolean;
        CurrencyFactor: Decimal;
    begin
        SpfyEventLogEntry."Amount (PCY)" := JsonHelper.GetJDecimal(Order, 'currentTotalPriceSet.presentmentMoney.amount', true);
        SpfyEventLogEntry."Presentment Currency Code" := SpfyPaymentGatewayHdlr.TranslateCurrencyCode(JsonHelper.GetJCode(Order, 'presentmentCurrencyCode', false), false, PresentmentCurrencyCodeIsLCY);
        SpfyEventLogEntry."Amount (SCY)" := JsonHelper.GetJDecimal(Order, 'currentTotalPriceSet.shopMoney.amount', true);
        SpfyEventLogEntry."Store Currency Code" := SpfyPaymentGatewayHdlr.TranslateCurrencyCode(JsonHelper.GetJCode(Order, 'currencyCode', false), false, StoreCurrencyCodeIsLCY);

        case true of
            StoreCurrencyCodeIsLCY:
                SpfyEventLogEntry."Amount (LCY)" := SpfyEventLogEntry."Amount (SCY)";
            PresentmentCurrencyCodeIsLCY:
                SpfyEventLogEntry."Amount (LCY)" := SpfyEventLogEntry."Amount (PCY)";
            else begin
                CurrencyFactor := GetCurrencyFactor(SpfyEventLogEntry);
                SpfyEventLogEntry."Amount (LCY)" :=
                    CurrExchRate.ExchangeAmtFCYToLCY(
                             DT2Date(SpfyEventLogEntry."Event Date-Time"), SpfyEventLogEntry."Presentment Currency Code", SpfyEventLogEntry."Amount (PCY)", CurrencyFactor);
            end;
        end;
        Currency.InitRoundingPrecision();
        SpfyEventLogEntry."Amount (LCY)" := Round(SpfyEventLogEntry."Amount (LCY)", Currency."Amount Rounding Precision");
    end;

    internal procedure GetCurrencyFactor(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry") CurrencyFactor: Decimal
    var
        SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
    begin
        if SpfyPaymentGatewayHdlr.IsLCY(SpfyEventLogEntry."Store Currency Code") and
           (SpfyEventLogEntry."Amount (PCY)" <> 0) and (SpfyEventLogEntry."Amount (SCY)" <> 0)
        then begin
            if SpfyEventLogEntry."Amount (SCY)" = SpfyEventLogEntry."Amount (PCY)" then
                exit(1);
            exit(SpfyEventLogEntry."Amount (PCY)" / SpfyEventLogEntry."Amount (SCY)");
        end;
        exit(CalculateCurrencyFactor(SpfyEventLogEntry));
    end;

    internal procedure CalculateCurrencyFactor(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry") CurrencyFactor: Decimal
    var
        CurrExchRate: Record "Currency Exchange Rate";
        CurrencyDate: Date;
        PostingDate: Date;
    begin
        PostingDate := DT2Date(SpfyEventLogEntry."Event Date-Time");
        if PostingDate <> 0D then
            CurrencyDate := PostingDate
        else
            CurrencyDate := WorkDate();

        CurrencyFactor := CurrExchRate.ExchangeRate(CurrencyDate, SpfyEventLogEntry."Presentment Currency Code");
    end;

    internal procedure UpdateProcessing(Success: Boolean; InputTxt: text; var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    begin
        case true of
            SpfyEventLogEntry.Postponed:
                begin
                    SpfyEventLogEntry."Last Error Date" := Today;
                    SpfyEventLogEntry."Process Retry Count" += 1;
                    if MaxRetryLimitReached(SpfyEventLogEntry) then begin
                        SpfyEventLogEntry."Processing Status" := SpfyEventLogEntry."Processing Status"::Error;
                        if (InputTxt <> '') and (SpfyEventLogEntry."Last Error Message" <> InputTxt) then
                            SpfyEventLogEntry."Last Error Message" := CopyStr(InputTxt, 1, MaxStrLen(SpfyEventLogEntry."Last Error Message"));
                    end else
                        SpfyEventLogEntry."Processing Status" := SpfyEventLogEntry."Processing Status"::Postponed;
                end;
            Success:
                begin
                    SpfyEventLogEntry."Processing Status" := SpfyEventLogEntry."Processing Status"::Processed;
                    SpfyEventLogEntry."Last Error Date" := 0D;
                    SpfyEventLogEntry."Last Error Message" := '';
                end;
            not Success:
                begin
                    SpfyEventLogEntry."Processing Status" := SpfyEventLogEntry."Processing Status"::Error;
                    SpfyEventLogEntry."Last Error Date" := Today;
                    if InputTxt <> '' then
                        SpfyEventLogEntry."Last Error Message" := CopyStr(InputTxt, 1, MaxStrLen(SpfyEventLogEntry."Last Error Message"));
                    SpfyEventLogEntry."Process Retry Count" += 1;
                end;
        end;
    end;

    internal procedure GetLogEntryStatusStyle(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry") StyleText: Text
    begin
        Case SpfyEventLogEntry."Processing Status" of
            SpfyEventLogEntry."Processing Status"::Error:
                StyleText := 'Unfavorable';
            SpfyEventLogEntry."Processing Status"::Processed:
                StyleText := 'Favorable';
            SpfyEventLogEntry."Processing Status"::Postponed:
                StyleText := 'Attention';
        End;
    end;

    internal procedure GetLogEntryErrorInformationStyle(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry") StyleText: Text
    begin
        Case SpfyEventLogEntry."Processing Status" of
            SpfyEventLogEntry."Processing Status"::Error:
                StyleText := 'Unfavorable';
        End;
    end;

    internal procedure GetMaxRetryStyleText(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry") StyleText: Text
    begin
        if MaxRetryLimitReached(SpfyEventLogEntry) then
            StyleText := 'Unfavorable';
    end;

    internal procedure MaxRetryLimitReached(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        exit(SpfyEventLogEntry."Process Retry Count" >= SpfyIntegrationMgt.GetMaxDocRetryCount());
    end;

    internal procedure GetEcommerceErrorStyleText(EcommerceErrorText: Text) StyleText: Text
    begin
        if EcommerceErrorText <> '' then
            StyleText := 'Unfavorable'
        else
            StyleText := 'Standard';
    end;

    internal procedure GetOrderData(Rec: Record "NPR Spfy Event Log Entry"): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStr: InStream;
    begin
        Rec.CalcFields("Order Data");
        if not Rec."Order Data".HasValue then
            exit('');
        Rec."Order Data".CreateInStream(InStr, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStr, TypeHelper.LFSeparator()));
    end;

    /// <summary>
    /// Gives every failed entry of one store and document type a fresh start: the cached order payload is dropped so
    /// the next attempt is downloaded from Shopify instead of replayed, and the retry state is reset, which un-parks
    /// entries that had already run out of retries.
    /// Deliberately not bounded by time: the import marker is an updated_at watermark, while the only timestamp an
    /// entry carries is "Event Date-Time", which is the order's createdAt. Bounding on it would leave the stale payload
    /// on exactly the orders a rewind is meant to refresh - the ones created long ago but updated recently.
    /// The reach is therefore every failed entry of the store, not only those of the rewound period, and the cost is
    /// not only a re-download: each un-parked entry is retried up to the maximum retry count again. That is the
    /// intended shape of the gesture - an operator rewinding the marker is asking for the store to be re-read - but it
    /// is worth showing them how many entries it touched, which is why the count is returned rather than discarded.
    /// </summary>
    internal procedure DiscardStoredOrderData(StoreCode: Code[20]; DocType: Enum "NPR SpfyEventLogDocType"): Integer
    var
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
    begin
        SpfyEventLogEntry.SetCurrentKey(Type, "Store Code", "Document Type", "Processing Status");
        SpfyEventLogEntry.SetRange(Type, SpfyEventLogEntry.Type::"Incoming Sales Order");
        SpfyEventLogEntry.SetRange("Store Code", StoreCode);
        SpfyEventLogEntry.SetRange("Document Type", DocType);
        SpfyEventLogEntry.SetRange("Processing Status", SpfyEventLogEntry."Processing Status"::Error);
        exit(DiscardStoredOrderData(SpfyEventLogEntry));
    end;

    internal procedure DiscardStoredOrderData(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry") DiscardedCount: Integer
    begin
        if not SpfyEventLogEntry.FindSet() then
            exit;
        repeat
            Clear(SpfyEventLogEntry."Order Data");
            SpfyEventLogEntry."Process Retry Count" := 0;
            SpfyEventLogEntry.Postponed := false;
            SpfyEventLogEntry."Not Before Date-Time" := 0DT;
            SpfyEventLogEntry.Modify();
            DiscardedCount += 1;
        until SpfyEventLogEntry.Next() = 0;
    end;

    internal procedure ExpandSelectionToSiblings(var SelectedEntries: Record "NPR Spfy Event Log Entry"; var ExpandedEntries: Record "NPR Spfy Event Log Entry")
    var
        SiblingEntry: Record "NPR Spfy Event Log Entry";
    begin
        ExpandedEntries.Reset();
        ExpandedEntries.ClearMarks();
        SiblingEntry.SetCurrentKey("Type", "Store Code", "Shopify ID", "Document Status", "Document Type");
        SiblingEntry.ReadIsolation := IsolationLevel::ReadCommitted;
        if SelectedEntries.FindSet() then
            repeat
                if ExpandedEntries.Get(SelectedEntries."Entry No.") then
                    ExpandedEntries.Mark(true);
                if SelectedEntries."Shopify ID" <> '' then begin
                    SiblingEntry.SetRange(Type, SelectedEntries.Type);
                    SiblingEntry.SetRange("Store Code", SelectedEntries."Store Code");
                    SiblingEntry.SetRange("Shopify ID", SelectedEntries."Shopify ID");
                    SiblingEntry.SetRange("Document Type", SelectedEntries."Document Type");
                    SiblingEntry.SetFilter("Document Status", '%1|%2', SiblingEntry."Document Status"::Open, SiblingEntry."Document Status"::Closed);
                    if SiblingEntry.FindSet() then
                        repeat
                            if ExpandedEntries.Get(SiblingEntry."Entry No.") then
                                ExpandedEntries.Mark(true);
                        until SiblingEntry.Next() = 0;
                end;
            until SelectedEntries.Next() = 0;

        ExpandedEntries.MarkedOnly(true);
    end;

    internal procedure MarkEntryCreatedOutSideEcommerceFlow(var LogEntry: Record "NPR Spfy Event Log Entry"; OrderTkn: JsonToken)
    var
        LogEntryCreatedOutSideLbl: Label 'Log Entry is created outside Ecommerce flow.';
    begin
        LogEntry."Document Name" := CopyStr(JsonHelper.GetJText(OrderTkn, 'name', false), 1, MaxStrLen(LogEntry."Document Name"));
        LogEntry."Processing Status" := LogEntry."Processing Status"::Processed;
        LogEntry."Last Error Message" := LogEntryCreatedOutSideLbl;
    end;

    internal procedure RewindImportMarker(StoreCode: Code[20]; DocType: Enum "NPR SpfyEventLogDocType"; NewDateTime: DateTime) DiscardedCount: Integer
    var
        CurrentMarker: DateTime;
        RollbackTolerance: Duration;
    begin
        if NewDateTime = 0DT then
            exit(0);
        CurrentMarker := CurrentImportMarker(StoreCode, DocType);
        if CurrentMarker = 0DT then
            exit(0);
        // Shopify's updatedAt has second-level resolution (see SpfyOrderImportTests around the
        // SetLastOrdersImportedAt_MovedBack test), so any rewind within one second of the current
        // marker is a no-op setter write, not a real backward step. RollbackTolerance guards
        // against that spurious rewind.
        RollbackTolerance := 1000;
        if NewDateTime >= CurrentMarker - RollbackTolerance then
            exit(0);
        DiscardedCount := DiscardStoredOrderData(StoreCode, DocType);
    end;

    local procedure CurrentImportMarker(StoreCode: Code[20]; DocType: Enum "NPR SpfyEventLogDocType"): DateTime
    var
        SpfyDataSyncPointer: Record "NPR Spfy Data Sync. Pointer";
    begin
        SpfyDataSyncPointer.ReadIsolation := IsolationLevel::ReadCommitted;
        if not SpfyDataSyncPointer.Get(StoreCode) then
            exit(0DT);
        case DocType of
            DocType::Order:
                exit(SpfyDataSyncPointer."Last Orders Imported At");
            DocType::"Return Order":
                exit(SpfyDataSyncPointer."Last Returns Imported At");
        end;
    end;

    var
        JsonHelper: Codeunit "NPR Json Helper";
}

#endif