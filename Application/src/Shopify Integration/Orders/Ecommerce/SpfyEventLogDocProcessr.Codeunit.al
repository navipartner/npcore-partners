#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248599 "NPR Spfy Event Log DocProcessr"
{
    Access = Internal;

    local procedure ProcessEcommerceDocument(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry") Success: Boolean
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        SpfyAPIEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
    begin
        ClearLastError();
        Clear(SpfyEcomSalesDocImport);
        LogEntry.Get(SpfyEventLogEntry."Entry No.");
        Success := SpfyEcomSalesDocImport.Run(LogEntry);
        if not Success then begin
            LogEntry.Get(SpfyEventLogEntry."Entry No.");
            HandleShopifyLog(false, GetLastErrorText(), LogEntry);
            if SpfyAPIEventLogMgt.MaxRetryLimitReached(LogEntry) then
                EmitSentryError(LogEntry);
            Commit();
        end;
    end;

    local procedure EmitSentryError(LogEntry: Record "NPR Spfy Event Log Entry")
    var
        Sentry: Codeunit "NPR Sentry";
        TransactionNameLbl: Label 'Shopify document processing failed (%1): %2', Comment = '%1 = document type, %2 = Shopify store code', Locked = true;
    begin
        if not ShouldEmitSentryError(LogEntry."Store Code", LogEntry."Document Type") then
            exit;
        Sentry.InitScopeAndTransaction(StrSubstNo(TransactionNameLbl, Format(LogEntry."Document Type"), LogEntry."Store Code"), 'bc.shopify.order.process.error');
        Sentry.AddTransactionTag('shopify.store_code', LogEntry."Store Code");
        Sentry.AddTransactionTag('shopify.doc_type', Format(LogEntry."Document Type"));
        Sentry.AddLastErrorIfProgrammingBug();
        Sentry.FinalizeScope();
    end;

    local procedure ShouldEmitSentryError(StoreCode: Code[20]; DocType: Enum "NPR SpfyEventLogDocType"): Boolean
    begin
        exit(ShouldEmitSentryError(StoreCode, DocType, CurrentDateTime()));
    end;

    internal procedure ShouldEmitSentryError(StoreCode: Code[20]; DocType: Enum "NPR SpfyEventLogDocType"; NowDT: DateTime): Boolean
    var
        LastEmitAt: DateTime;
        ThrottleWindow: Duration;
        ThrottleKey: Text;
    begin
        ThrottleWindow := 60 * 60 * 1000;
        ThrottleKey := StrSubstNo('%1|%2', StoreCode, DocType.AsInteger());
        if not _LastSentryEmitAt.ContainsKey(ThrottleKey) then begin
            _LastSentryEmitAt.Add(ThrottleKey, NowDT);
            exit(true);
        end;
        LastEmitAt := _LastSentryEmitAt.Get(ThrottleKey);
        if (NowDT - LastEmitAt) < ThrottleWindow then
            exit(false);
        _LastSentryEmitAt.Set(ThrottleKey, NowDT);
        exit(true);
    end;

    [TryFunction]
    internal procedure CheckForSaleDocumentWithAssignedShopifyID(LogEntry: Record "NPR Spfy Event Log Entry")
    begin
        CheckIfSalesDocumentCreatedOutsideEcommerceFlow(LogEntry);
    end;

    internal procedure EcommerceDocAlreadyProcessed(LogEntry: Record "NPR Spfy Event Log Entry"; var EcomSalesHeader: Record "NPR Ecom Sales Header"; RaiseError: Boolean): Boolean
    var
        AlreadyExistsErr: Label 'Ecommerce document with Shopify ID %1 already exists as %2 No. %3', Comment = '%1=Shopify ID, %2=Document Type, %3=Document No.';
    begin
        Clear(EcomSalesHeader);
        EcomSalesHeader.SetCurrentKey("External No.", "Document Type");
        EcomSalesHeader.ReadIsolation := IsolationLevel::ReadUncommitted;
        EcomSalesHeader.SetRange("External No.", LogEntry."Shopify ID");
        EcomSalesHeader.SetRange("Document Type", MapSpfyDocumentTypeToEcommerce(LogEntry."Document Type"));
        if not EcomSalesHeader.FindFirst() then
            exit(false);
        if RaiseError then
            if (LogEntry."Document Status" = LogEntry."Document Status"::Open) and (EcomSalesHeader."Creation Status" = EcomSalesHeader."Creation Status"::Created) then
                exit(true)
            else
                Error(AlreadyExistsErr, LogEntry."Shopify ID", EcomSalesHeader."Document Type", EcomSalesHeader."External No.");
        exit(true);

    end;

    internal procedure HandleShopifyLog(Success: Boolean; InputTxt: text; var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    var
        SpfyAPIEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
    begin
        SpfyAPIEventLogMgt.UpdateProcessing(Success, InputTxt, SpfyEventLogEntry);
        SpfyEventLogEntry.Modify();
    end;

    internal procedure ProcessLogEntries(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    var
        PostponedCount: Integer;
    begin
        exit(ProcessLogEntries(SpfyEventLogEntry, PostponedCount));
    end;

    /// <summary>
    /// Returns whether the run finished without errors. A postponed entry is not an error, but it is not done either -
    /// nothing was imported for it yet - so it is counted separately instead of being folded into the success answer.
    /// </summary>
    internal procedure ProcessLogEntries(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"; var PostponedCount: Integer): Boolean
    var
        ProcessedEntry: Record "NPR Spfy Event Log Entry";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        AnyError: Boolean;
    begin
        PostponedCount := 0;
        SpfyIntegrationMgt.SetRereadSetup();
        if not SpfyEventLogEntry.FindSet() then
            exit(true);
        repeat
            if SpfyEventLogEntry."Processing Status" <> SpfyEventLogEntry."Processing Status"::Processed then
                TrackEntryOutcome(SpfyEventLogEntry, ProcessedEntry, AnyError, PostponedCount)
            else
                if ReopenForProcessing(SpfyEventLogEntry) then
                    TrackEntryOutcome(SpfyEventLogEntry, ProcessedEntry, AnyError, PostponedCount);
        until SpfyEventLogEntry.Next() = 0;
        exit(not AnyError);
    end;

    local procedure TrackEntryOutcome(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"; var ProcessedEntry: Record "NPR Spfy Event Log Entry"; var AnyError: Boolean; var PostponedCount: Integer)
    begin
        ProcessLogEntry(SpfyEventLogEntry);
        if not ProcessedEntry.Get(SpfyEventLogEntry."Entry No.") then begin
            // The outcome cannot be read back, so it must not be reported as a success.
            AnyError := true;
            exit;
        end;
        case ProcessedEntry."Processing Status" of
            ProcessedEntry."Processing Status"::Error:
                AnyError := true;
            ProcessedEntry."Processing Status"::Postponed:
                PostponedCount += 1;
        end;
    end;

    local procedure ReopenForProcessing(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EntryToReopen: Record "NPR Spfy Event Log Entry";
    begin
        if SpfyEventLogEntry."Processing Status" <> SpfyEventLogEntry."Processing Status"::Processed then
            exit(false);
        if not (SpfyEventLogEntry."Document Status" in [SpfyEventLogEntry."Document Status"::Open, SpfyEventLogEntry."Document Status"::Closed]) then
            exit(false);
        if AnySalesDocumentExists(SpfyEventLogEntry) then
            exit(false);
        if EcommerceDocAlreadyProcessed(SpfyEventLogEntry, EcomSalesHeader, false) then
            exit(false);
        EntryToReopen.ReadIsolation := IsolationLevel::UpdLock;
        if not EntryToReopen.Get(SpfyEventLogEntry."Entry No.") then
            exit(false);

        EntryToReopen."Processing Status" := EntryToReopen."Processing Status"::Ready;
        EntryToReopen."Process Retry Count" := 0;
        EntryToReopen.Postponed := false;
        EntryToReopen."Not Before Date-Time" := 0DT;
        EntryToReopen."Last Error Message" := '';
        EntryToReopen."Last Error Date" := 0D;
        EntryToReopen.Modify();

        Commit();
        exit(true);
    end;

    [TryFunction]
    internal procedure TryCheckForUnprocessedEntry(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    var
        PSpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        WaitingErr: label 'Unprocessed Shopify document detected (entry %1, status %2) — waiting for completion.', Comment = '%1 = Entry No. of the blocking log entry, %2 = its Document Status';
    begin
        PSpfyEventLogEntry.ReadIsolation := IsolationLevel::ReadCommitted;
        PSpfyEventLogEntry.SetCurrentKey("Shopify ID", "Document Status", "Store Code", "Processing Status");
        PSpfyEventLogEntry.SetRange("Shopify ID", SpfyEventLogEntry."Shopify ID");
        PSpfyEventLogEntry.SetFilter("Document Status", '1..%1', SpfyEventLogEntry."Document Status".AsInteger());
        PSpfyEventLogEntry.SetFilter("Entry No.", '<>%1', SpfyEventLogEntry."Entry No.");
        PSpfyEventLogEntry.SetRange("Store Code", SpfyEventLogEntry."Store Code");
        PSpfyEventLogEntry.SetRange("Document Type", SpfyEventLogEntry."Document Type");
        PSpfyEventLogEntry.SetFilter("Processing Status", '<>%1', PSpfyEventLogEntry."Processing Status"::Processed);
        PSpfyEventLogEntry.SetFilter("Process Retry Count", '<=%1', SpfyIntegrationMgt.GetMaxDocRetryCount());
        If PSpfyEventLogEntry.FindFirst() then
            Error(WaitingErr, PSpfyEventLogEntry."Entry No.", PSpfyEventLogEntry."Document Status");
    end;

    internal procedure ProcessLogEntry(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    begin
        if not ProcessEcommerceDocument(SpfyEventLogEntry) then
            LogError(GetLastErrorText());
    end;

    local procedure LogError(ErrMsg: text)
    begin
        LogTelemetry(ErrMsg, 'NPR_ShopifyAPI_OrderCreationFailed');
    end;

    internal procedure FindIncomingEcommerceDocument(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        exit(GetCreatedEcommerceDoc(SpfyEventLogEntry, EcomSalesHeader));
    end;

    internal procedure MapSpfyDocumentTypeToEcommerce(LogDocType: enum "NPR SpfyEventLogDocType") IncDocType: enum "NPR Ecom Sales Doc Type"
    begin
        case true of
            LogDocType = LogDocType::Order:
                exit(IncDocType::Order);
            LogDocType = LogDocType::"Return Order":
                exit(IncDocType::"Return Order");
            else
                Error(UnSupportedErr);
        end;
    end;

    internal procedure MapEcommerceDocumentTypeToSpfy(IncDocType: enum "NPR Ecom Sales Doc Type") LogDocType: enum "NPR SpfyEventLogDocType"
    begin
        case true of
            IncDocType = IncDocType::Order:
                exit(LogDocType::Order);
            IncDocType = IncDocType::"Return Order":
                exit(LogDocType::"Return Order");
            else
                Error(UnSupportedErr);
        end;
    end;

    internal procedure MapSalesDocumentType(LogDocType: enum "NPR SpfyEventLogDocType") DocType: enum "Sales Document Type"
    begin
        case true of
            LogDocType = LogDocType::Order:
                exit(DocType::Order);
            LogDocType = LogDocType::"Return Order":
                exit(DocType::"Return Order");
            else
                Error(UnSupportedErr);
        end;
    end;

    internal procedure LogTelemetry(MessageInput: Text; EventId: Text)
    var
        ActiveSession: Record "Active Session";
        CustomDimensions: Dictionary of [Text, Text];
    begin
        if (not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId())) then
            ActiveSession.Init();

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_SessionId', Format(Database.SessionId(), 0, 9));
        CustomDimensions.Add('NPR_ErrorText', MessageInput);
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");

        Session.LogMessage(EventId, MessageInput, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    internal procedure SetupJobQueues()
    var
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyEcomSalesImportJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
        EnableJobQueues: Boolean;
    begin
        SpfyIntegrationMgt.SetRereadSetup();
        EnableJobQueues := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Orders");
        if not EnableJobQueues then
            EnableJobQueues := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Returns");
        if EnableJobQueues then begin
            SpfyOrderImportJQ.SetupJobQueue(true);
            SpfyEcomSalesImportJQ.SetupJobQueue(true);
        end;
    end;

    internal procedure IsShopifyDocument(EcomSalesHeader: Record "NPR Ecom Sales Header"): Boolean
    begin
        exit(EcomSalesHeader."Document Source" = EcomSalesHeader."Document Source"::Shopify);
    end;

    internal procedure GetShopifyLogEntry(EcomSalesHeader: Record "NPR Ecom Sales Header"; var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    begin
        Clear(SpfyEventLogEntry);
        SpfyEventLogEntry.SetCurrentKey("Shopify ID", "Document Type", "Document Status");
        SpfyEventLogEntry.SetRange("Shopify ID", EcomSalesHeader."External No.");
        SpfyEventLogEntry.SetRange("Document Type", MapEcommerceDocumentTypeToSpfy(EcomSalesHeader."Document Type"));
        exit(SpfyEventLogEntry.FindFirst());
    end;

    internal procedure AssignShopifyIDToVoucher(NpRvVoucher: Record "NPR NpRv Voucher"; NpRvSalesLine: Record "NPR NpRv Sales Line")
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        SpfyAssignedIDMgt.AssignShopifyID(NpRvVoucher.RecordId(), "NPR Spfy ID Type"::"Entry ID", NpRvSalesLine."Spfy Gift Card ID", false);
    end;

    internal procedure RefreshShopifyPaymentLinePaymentMethodFields(var PaymentLine: Record "NPR Magento Payment Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line")
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyCapturePayment: Codeunit "NPR Spfy Capture Payment";
    begin
        PaymentLine."Amount (Store Currency)" := EcomSalesPmtLine."Amount (Store Currency)";
        PaymentLine."Requested Amt. (Store Curr.)" := PaymentLine."Amount (Store Currency)";
        PaymentLine."Store Currency Code" := EcomSalesPmtLine."Store Currency Code";
        PaymentLine."Payment Gateway Code" := SpfyCapturePayment.ShopifyPaymentGateway(PaymentLine."Store Currency Code");
        PaymentLine."External Payment Gateway" := EcomSalesPmtLine."External Payment Gateway";
        PaymentLine."External Reference No." := EcomSalesHeader."External No.";
        PaymentLine."Date Authorized" := EcomSalesPmtLine."Date Authorized";
        PaymentLine."Expires At" := EcomSalesPmtLine."Expires At";
        If PaymentLine.Amount <> EcomSalesPmtLine.Amount then
            RoundStoreCurrencyAmount(PaymentLine, EcomSalesPmtLine.Amount);
        SpfyAssignedIDMgt.AssignShopifyID(PaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", EcomSalesPmtLine."Shopify ID", false);
    end;

    internal procedure RefreshShopifyPaymentLineVoucherFields(var PaymentLine: Record "NPR Magento Payment Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; AvailableAmountToCapture: Decimal)
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        PaymentLine."Amount (Store Currency)" := EcomSalesPmtLine."Amount (Store Currency)";
        PaymentLine."Store Currency Code" := EcomSalesPmtLine."Store Currency Code";
        If PaymentLine.Amount <> AvailableAmountToCapture then
            RoundStoreCurrencyAmount(PaymentLine, AvailableAmountToCapture);
        SpfyAssignedIDMgt.AssignShopifyID(PaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", EcomSalesPmtLine."Shopify ID", false);
    end;

    internal procedure RefreshShopifyPaymentLineVoucherSalesLineFields(NpRvSalesLine: Record "NPR NpRv Sales Line")
    begin
        NpRvSalesLine."Spfy Initiated in Shopify" := true;
    end;

    local procedure RoundStoreCurrencyAmount(var PaymentLine: Record "NPR Magento Payment Line"; AvailableAmountToCapture: Decimal)
    var
        Currency: Record Currency;
    begin
        //Update when PaymentLine.Amount < AvailableAmountToCapture
        if PaymentLine."Store Currency Code" <> '' then
            Currency.Get(PaymentLine."Store Currency Code")
        else begin
            Clear(Currency);
            Currency.InitRoundingPrecision();
        end;
        PaymentLine."Amount (Store Currency)" := Round(PaymentLine."Amount (Store Currency)" * PaymentLine.Amount / AvailableAmountToCapture, Currency."Amount Rounding Precision");
        PaymentLine."Requested Amt. (Store Curr.)" := PaymentLine."Amount (Store Currency)";
    end;

    internal procedure RefreshShopifySalesHeaderPostingDate(var SalesHeader: Record "Sales Header"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
    begin
        if not GetShopifyLogEntry(EcomSalesHeader, SpfyEventLogEntry) then
            exit;
        if SpfyEventLogEntry."Closed Date-Time" > SpfyEventLogEntry."Event Date-Time" then
            SalesHeader.Validate("Posting Date", DT2Date(SpfyEventLogEntry."Closed Date-Time"))
        else
            SalesHeader.Validate("Posting Date", DT2Date(SpfyEventLogEntry."Event Date-Time"));
        SalesHeader.Validate("Order Date", DT2Date(SpfyEventLogEntry."Event Date-Time"));
    end;

    internal procedure AssignShopifyIDAndRefreshShopifySalesHeaderDimensions(var SalesHeader: Record "Sales Header"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        NpEcStore: Record "NPR NpEc Store";
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        if not GetShopifyLogEntry(EcomSalesHeader, SpfyEventLogEntry) then
            exit;
        NpEcStore.Get(EcomSalesHeader."Ecommerce Store Code");
        if NpEcStore."Salesperson/Purchaser Code" <> '' then
            SalesHeader.Validate("Salesperson Code", NpEcStore."Salesperson/Purchaser Code");
        if NpEcStore."Global Dimension 1 Code" <> '' then
            SalesHeader.Validate("Shortcut Dimension 1 Code", NpEcStore."Global Dimension 1 Code");
        if NpEcStore."Global Dimension 2 Code" <> '' then
            SalesHeader.Validate("Shortcut Dimension 2 Code", NpEcStore."Global Dimension 2 Code");

        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", EcomSalesHeader."External No.", false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", SpfyEventLogEntry."Store Code", false);
    end;

    internal procedure RefreshShopifySalesHeaderShipmentAndLocationFields(var SalesHeader: Record "Sales Header"; EcomSalesHeader: Record "NPR Ecom Sales Header"; ShipmentMapping: Record "NPR Magento Shipment Mapping")
    var
        NpEcStore: Record "NPR NpEc Store";
        LocationMapping: Record "NPR Spfy Location Mapping";
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
    begin
        SalesHeader.Validate("NPR Delivery Location");
        if ShipmentMapping."External Shipment Method Code" <> '' then
            SpfyOrderMgt.UpdateLocationFromShippingMapping(ShipmentMapping, SalesHeader);
        NpEcStore.Get(EcomSalesHeader."Ecommerce Store Code");
        if not ((ShipmentMapping."Shipping Agent Code" <> '') and (ShipmentMapping."Spfy Location Code" <> '')) then begin
            SpfyOrderMgt.FindLocationMapping(NpEcStore, LocationMapping, EcomSalesHeader."Ship-to Country Code", EcomSalesHeader."Ship-to Post Code");
            if (LocationMapping."Location Code" <> '') and (ShipmentMapping."Spfy Location Code" = '') then begin
                if SalesHeader."Location Code" = '' then
                    SalesHeader.Validate("Location Code", LocationMapping."Location Code");
                if (LocationMapping."Shipping Agent Code" <> '') and (ShipmentMapping."Shipping Agent Code" = '') then begin
                    SalesHeader.Validate("Shipping Agent Code", LocationMapping."Shipping Agent Code");
                    SalesHeader.Validate("Shipping Agent Service Code", LocationMapping."Shipping Agent Service Code");
                end;
            end;
        end;
    end;

    internal procedure AssignShopifyIdToSalesLine(var SalesLine: Record "Sales Line"; EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", EcomSalesLine."Shopify ID", false);
    end;

    internal procedure FinalizeSalesOrder(SalesHeader: Record "Sales Header"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
    begin
        if not GetShopifyLogEntry(EcomSalesHeader, SpfyEventLogEntry) then
            exit;
        SpfyEventLogEntry.Modify();
        SpfyEventLogEntry.RegisterEvent(SpfyEventLogEntry);
        SpfyOrderMgt.HandleClickCollectOrder(SpfyEventLogEntry."Store Code", SalesHeader);
    end;

    internal procedure CheckIfShouldReleaseOrder(EcomSaleHeader: Record "NPR Ecom Sales Header"): Boolean
    var
        NpEcStore: Record "NPR NpEc Store";
    begin
        if not NpEcStore.Get(EcomSaleHeader."Ecommerce Store Code") then
            exit(false);
        exit(NpEcStore."Release Order on Import");
    end;

    internal procedure IsSalesDocumentCreated(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
    begin
        if not GetShopifyLogEntry(EcomSalesHeader, SpfyEventLogEntry) then
            exit;
        CheckIfSalesDocumentCreatedOutsideEcommerceFlow(SpfyEventLogEntry);
    end;

    internal procedure MarkProcessedIfDocumentAlreadyExists(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        NothingToImportMsg: Label 'A Business Central sales document already exists for this Shopify document, so there was nothing left to import.';
    begin
        if not DocumentAlreadyHandled(SpfyEventLogEntry) then
            exit(false);
        // An Ecommerce document still around means the regular create/update paths own this entry.
        if EcommerceDocAlreadyProcessed(SpfyEventLogEntry, EcomSalesHeader, false) then
            exit(false);

        SpfyEventLogEntry."Processing Status" := SpfyEventLogEntry."Processing Status"::Processed;
        SpfyEventLogEntry."Last Error Date" := 0D;
        SpfyEventLogEntry."Last Error Message" := CopyStr(NothingToImportMsg, 1, MaxStrLen(SpfyEventLogEntry."Last Error Message"));
        SpfyEventLogEntry.Modify();
        exit(true);
    end;

    local procedure DocumentAlreadyHandled(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    var
        UnpostedExists: Boolean;
        PostedExists: Boolean;
    begin
        GetSalesDocumentState(SpfyEventLogEntry, UnpostedExists, PostedExists);
        case SpfyEventLogEntry."Document Status" of
            SpfyEventLogEntry."Document Status"::Open:
                exit(PostedExists);
            SpfyEventLogEntry."Document Status"::Closed:
                exit(PostedExists and not UnpostedExists);
        end;
        // Cancelled keeps its existing behaviour.
        exit(false);
    end;

    local procedure GetSalesDocumentState(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"; var UnpostedExists: Boolean; var PostedExists: Boolean)
    var
        PostedTableNo: Integer;
    begin
        if SpfyEventLogEntry."Document Type" = SpfyEventLogEntry."Document Type"::Order then
            PostedTableNo := Database::"Sales Invoice Header"
        else
            PostedTableNo := Database::"Sales Cr.Memo Header";

        UnpostedExists := DocumentExistsForStore(Database::"Sales Header", SpfyEventLogEntry);
        PostedExists := DocumentExistsForStore(PostedTableNo, SpfyEventLogEntry);
    end;

    local procedure DocumentExistsForStore(TableNo: Integer; SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
        DocumentStoreCode: Code[20];
    begin
        SpfyAssignedIDMgt.FilterWhereUsedInTable(TableNo, "NPR Spfy ID Type"::"Entry ID", SpfyEventLogEntry."Shopify ID", ShopifyAssignedID);
        if not ShopifyAssignedID.FindSet() then
            exit(false);
        repeat
            if RecRef.Get(ShopifyAssignedID."BC Record ID") then begin
                if SpfyEventLogEntry."Store Code" = '' then
                    exit(true);
                DocumentStoreCode := CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(ShopifyAssignedID."BC Record ID", "NPR Spfy ID Type"::"Store Code"), 1, MaxStrLen(DocumentStoreCode));
                if (DocumentStoreCode = '') or (DocumentStoreCode = SpfyEventLogEntry."Store Code") then
                    exit(true);
            end;
        until ShopifyAssignedID.Next() = 0;
        exit(false);
    end;

    local procedure AnySalesDocumentExists(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    var
        UnpostedExists: Boolean;
        PostedExists: Boolean;
    begin
        GetSalesDocumentState(SpfyEventLogEntry, UnpostedExists, PostedExists);
        exit(UnpostedExists or PostedExists);
    end;

    internal procedure CheckIfSalesDocumentCreatedOutsideEcommerceFlow(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    var
        SalesHeader: Record "Sales Header";
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        CreatedDocumentErrorLbl: Label 'This Shopify document was not created by the Ecommerce flow, so the flow will not change it. Post or cancel %1 %2 manually - once it is posted, processing this log entry again completes it.', Comment = '%1 = Sales document type, %2 = Sales document number';
        CreatedDocumentNoRefErrorLbl: Label 'This Shopify document was not created by the Ecommerce flow, so the flow will not change it. Please handle the sales document manually - once it is posted, processing this log entry again completes it.';
    begin
        if not AnySalesDocumentExists(SpfyEventLogEntry) then
            exit;
        if SpfyOrderMgt.FindSalesOrder(SpfyEventLogEntry."Store Code", SpfyEventLogEntry."Shopify ID", SalesHeader) then
            Error(CreatedDocumentErrorLbl, SalesHeader."Document Type", SalesHeader."No.");
        Error(CreatedDocumentNoRefErrorLbl);
    end;

    internal procedure EcomStatusOnDrillDown(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        if GetCreatedEcommerceDoc(SpfyEventLogEntry, EcomSalesHeader) then
            Page.Run(0, EcomSalesHeader);
    end;

    internal procedure EcommerceDocCreated(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        exit(GetCreatedEcommerceDoc(SpfyEventLogEntry, EcomSalesHeader));
    end;

    internal procedure GetCreatedEcommerceDoc(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"; var EcomSalesHeader: Record "NPR Ecom Sales Header"): Boolean
    begin
        EcomSalesHeader.Reset();
        EcomSalesHeader.SetCurrentKey("External No.", "Document Type");
        EcomSalesHeader.SetRange("External No.", SpfyEventLogEntry."Shopify ID");
        EcomSalesHeader.SetRange("Document Type", MapSpfyDocumentTypeToEcommerce(SpfyEventLogEntry."Document Type"));
        exit(EcomSalesHeader.FindFirst());
    end;

    internal procedure GetEcommerceDocumentError(EcomSalesHeader: Record "NPR Ecom Sales Header") ErrorText: text
    var
        TextBuilder: TextBuilder;
        PostingErr: Boolean;
        ErrorExistMsg: Label 'There are errors during the processing of the Ecommerce document:';
        OpenCardMsg: Label 'Please open the Ecommerce Document %1 card to view more information.', Comment = '%1=Ecommerce Sales Header No.';
        PostingVIErr: Label 'Posting of the virtual item was unsuccessful. Please review the sales order.';
    begin
        PostingErr := (EcomSalesHeader."Virtual Items Exist" and (EcomSalesHeader."Posting Status" = EcomSalesHeader."Posting Status"::Pending));

        if (EcomSalesHeader."Last Error Message" = '') and (EcomSalesHeader."Last Capture Error Message" = '') then
            if not PostingErr then
                exit;

        TextBuilder.Clear();
        TextBuilder.AppendLine(ErrorExistMsg);
        if EcomSalesHeader."Last Error Message" <> '' then begin
            TextBuilder.AppendLine('');
            TextBuilder.AppendLine(EcomSalesHeader."Last Error Message");
        end;
        if EcomSalesHeader."Last Capture Error Message" <> '' then begin
            TextBuilder.AppendLine('');
            TextBuilder.AppendLine(EcomSalesHeader."Last Capture Error Message")
        end;
        if PostingErr then begin
            TextBuilder.AppendLine('');
            TextBuilder.AppendLine(PostingVIErr);
        end;
        if TextBuilder.Length() = 0 then
            exit;
        TextBuilder.AppendLine('');
        TextBuilder.AppendLine(StrSubstNo(OpenCardMsg, EcomSalesHeader."External No."));
        ErrorText := TextBuilder.ToText();
    end;

    var
        UnSupportedErr: Label 'Unsupported document type. This is a programming issue.';
        _LastSentryEmitAt: Dictionary of [Text, DateTime];

}
#endif