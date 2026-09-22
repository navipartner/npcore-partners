#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248587 "NPR Spfy Ecom Sales Doc Import"
{
    Access = Internal;
    TableNo = "NPR Spfy Event Log Entry";

    trigger OnRun()
    begin
        Rec.ReadIsolation := IsolationLevel::UpdLock;
        Rec.Get(Rec."Entry No.");
        if Rec."Processing Status" = Rec."Processing Status"::Processed then
            exit;
        Rec.Postponed := false;
        Rec.Modify();
        ClearLastError();
        if _SpfyEcomSalesDocPrcssr.MarkProcessedIfDocumentAlreadyExists(Rec) then
            exit;
        Process(Rec);
        Rec.Get(Rec."Entry No.");
        _SpfyEcomSalesDocPrcssr.HandleShopifyLog(true, GetLastErrorText(), Rec);
    end;

    local procedure Process(var LogEntry: Record "NPR Spfy Event Log Entry")
    begin
        case LogEntry."Document Status" of
            LogEntry."Document Status"::Open:
                ProcessOpenLogEntry(LogEntry);
            LogEntry."Document Status"::Closed:
                ProcessClosedLogEntry(LogEntry);
            LogEntry."Document Status"::Cancelled:
                ProcessCancelledLogEntry(LogEntry);
        end;
    end;

    local procedure ProcessOpenLogEntry(var LogEntry: Record "NPR Spfy Event Log Entry")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache";
    begin
        if _SpfyEcomSalesDocPrcssr.EcommerceDocAlreadyProcessed(LogEntry, EcomSalesHeader, true) then
            exit;
        CreateDocument(LogEntry, FulfillmentCache);
    end;

    local procedure ProcessClosedLogEntry(var LogEntry: Record "NPR Spfy Event Log Entry")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache";
        UnprocessedEntriesErr: Label 'Processing is postponed until all related event log entries are completed.';
        DelayProcessingErr: Label 'Processing is postponed because dependent Ecommerce processes are still running.';
    begin
        if not _SpfyEcomSalesDocPrcssr.TryCheckForUnprocessedEntry(LogEntry) then begin
            AddTimeForEcommerceProcessing(LogEntry, UnprocessedEntriesErr, SiblingWaitBackoff());
            exit;
        end;
        if not _SpfyEcomSalesDocPrcssr.EcommerceDocAlreadyProcessed(LogEntry, EcomSalesHeader, false) then begin
            if not CreateAndProcess(LogEntry, FulfillmentCache) then
                AddTimeForEcommerceProcessing(LogEntry, DelayProcessingErr);
            exit;
        end;
        if EcomSalesHeader."Posting Status" = EcomSalesHeader."Posting Status"::Invoiced then
            exit; // The document is posted, so the entry has done its job. Re-fetching the order from Shopify would change nothing.
        if not IsSalesDocumentReady(EcomSalesHeader, LogEntry) then
            exit;
        UpdateAndProcess(LogEntry, FulfillmentCache);
    end;

    local procedure ProcessCancelledLogEntry(var LogEntry: Record "NPR Spfy Event Log Entry")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        UnprocessedEntriesErr: Label 'Processing is postponed until all related event log entries are completed.';
        NothingToProcessErr: Label 'The order was canceled in Shopify before it was processed. There is nothing to process here.';
    begin
        if not _SpfyEcomSalesDocPrcssr.TryCheckForUnprocessedEntry(LogEntry) then begin
            AddTimeForEcommerceProcessing(LogEntry, UnprocessedEntriesErr, SiblingWaitBackoff());
            exit;
        end;
        if not _SpfyEcomSalesDocPrcssr.EcommerceDocAlreadyProcessed(LogEntry, EcomSalesHeader, false) then
            Error(NothingToProcessErr);
        if not IsSalesDocumentReady(EcomSalesHeader, LogEntry) then
            exit;
        DeleteDocument(LogEntry);
    end;

    local procedure CreateAndProcessEcommerceDocument(var LogEntry: Record "NPR Spfy Event Log Entry"; var DetailsResponse: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header"; var FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache"): Boolean
    var
        EcomSalesDocApiAgentV2: Codeunit "NPR EcomSalesDocApiAgentV2";
    begin
        _SpfyEcomSalesDocPrcssr.CheckIfSalesDocumentCreatedOutsideEcommerceFlow(LogEntry);

        if not CreateDocument(LogEntry, DetailsResponse, EcomSalesHeader, FulfillmentCache) then
            if LogEntry.Postponed then
                exit(false)
            else
                Error(GetLastErrorText());

        Commit();
        LogEntry.ReadIsolation := IsolationLevel::UpdLock;
        LogEntry.Get(LogEntry."Entry No.");
        EcomSalesDocApiAgentV2.PreProcessDocument(EcomSalesHeader);
        EcomSalesDocApiAgentV2.AssignBucketId(EcomSalesHeader); // Makes the document visible to the Ecommerce job queues.
        exit(true);
    end;

    local procedure CreateAndProcess(var LogEntry: Record "NPR Spfy Event Log Entry"; var FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache"): Boolean
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SalesHeader: Record "Sales Header";
        DetailsResponse: JsonToken;
    begin
        if not CreateAndProcessEcommerceDocument(LogEntry, DetailsResponse, EcomSalesHeader, FulfillmentCache) then
            exit(false);

        LogEntry.Get(LogEntry.RecordId);
        LogEntry.CalcFields("Creation Status");
        if LogEntry."Creation Status" <> LogEntry."Creation Status"::Created then
            exit(false);

        LogEntry.CalcFields("Posting Status");
        if LogEntry."Posting Status" = LogEntry."Posting Status"::Invoiced then
            exit(true);

        LogEntry.CalcFields("Created Sales Doc No.");
        SalesHeader.ReadIsolation := IsolationLevel::UpdLock;
        SalesHeader.Get(_SpfyEcomSalesDocPrcssr.MapSalesDocumentType(LogEntry."Document Type"), LogEntry."Created Sales Doc No.");
        if LogEntry."Document Type" = LogEntry."Document Type"::Order then
            UpdateSalesLines(LogEntry, SalesHeader, DetailsResponse, FulfillmentCache, true);

        PostAndDeleteDocument(LogEntry, SalesHeader);

        exit(true);
    end;

    internal procedure IsSalesDocumentReady(EcomSalesHeader: Record "NPR Ecom Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    var
        MissingSalesDocErr: Label 'Processing cannot continue because the related Sales Document has not been created.';
    begin
        if (EcomSalesHeader."Created Doc No." <> '') then
            exit(true);
        ClearLastError();
        if (_SpfyEcomSalesDocPrcssr.CheckForSaleDocumentWithAssignedShopifyID(LogEntry)) then
            AddTimeForEcommerceProcessing(LogEntry, MissingSalesDocErr)
        else
            Error(GetLastErrorText());
    end;

    local procedure AddTimeForEcommerceProcessing(var LogEntry: Record "NPR Spfy Event Log Entry"; LogMessage: Text)
    var
        JobQueueManagement: Codeunit "NPR Job Queue Management";
    begin
        AddTimeForEcommerceProcessing(LogEntry, LogMessage, JobQueueManagement.MinutesToDuration(1));
    end;

    local procedure AddTimeForEcommerceProcessing(var LogEntry: Record "NPR Spfy Event Log Entry"; LogMessage: Text; Backoff: Duration)
    begin
        if LogEntry.Postponed then
            exit;

        LogEntry.Postponed := true;
        LogEntry."Not Before Date-Time" := CurrentDateTime() + Backoff;
        LogEntry."Last Error Message" := CopyStr(LogMessage, 1, MaxStrLen(LogEntry."Last Error Message"));
        LogEntry.Modify();
    end;

    local procedure SiblingWaitBackoff(): Duration
    var
        JobQueueManagement: Codeunit "NPR Job Queue Management";
    begin
        // Every postponement costs a retry, so the waiter must not retry faster than what it waits for.
        exit(JobQueueManagement.MinutesToDuration(5));
    end;

    internal procedure DeleteDocument(var LogEntry: Record "NPR Spfy Event Log Entry")
    var
        SalesHeader: Record "Sales Header";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SpfyDeleteOrder: Codeunit "NPR Spfy Delete Order";
        ErrMissing: Label 'Ecommerce document not found for Shopify order %1.', Comment = 'Shopify ID';
        ErrPending: Label 'Sales document cannot be deleted because it is not created yet.';
    begin
        if not GetEcomSalesDocument(EcomSalesHeader, LogEntry) then
            Error(ErrMissing, LogEntry."Shopify ID");
        case EcomSalesHeader."Creation Status" of
            EcomSalesHeader."Creation Status"::Created:
                begin
                    if EcomSalesHeader."Posting Status" = EcomSalesHeader."Posting Status"::Invoiced then
                        exit; // Nothing to delete.
                    SalesHeader.ReadIsolation := IsolationLevel::UpdLock;
                    SalesHeader.Get(_SpfyEcomSalesDocPrcssr.MapSalesDocumentType(LogEntry."Document Type"), EcomSalesHeader."Created Doc No.");
                    SpfyDeleteOrder.DeleteOrder(SalesHeader);
                end;
            EcomSalesHeader."Creation Status"::Canceled:
                exit; // Already deleted.
            EcomSalesHeader."Creation Status"::Error,
            EcomSalesHeader."Creation Status"::Pending:
                Error(ErrPending);
        end;
    end;

    local procedure GetEcomSalesDocument(var EcomSalesHeader: Record "NPR Ecom Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    begin
        Clear(EcomSalesHeader);
        EcomSalesHeader.ReadIsolation := IsolationLevel::ReadCommitted;
        EcomSalesHeader.SetCurrentKey("External No.", "Document Type");
        EcomSalesHeader.SetRange("External No.", LogEntry."Shopify ID");
        EcomSalesHeader.SetRange("Document Type", _SpfyEcomSalesDocPrcssr.MapSpfyDocumentTypeToEcommerce(LogEntry."Document Type"));
        exit(EcomSalesHeader.FindFirst());
    end;

    local procedure CreateDocument(var LogEntry: Record "NPR Spfy Event Log Entry"; var DetailsResponse: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header"; var FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache"): Boolean
    begin
        if GetShopifyOrderDetails(LogEntry, DetailsResponse, FulfillmentCache) then
            if not LogEntry.Postponed then
                exit(CreateEcommerceDocument(LogEntry, DetailsResponse, EcomSalesHeader, FulfillmentCache));
        exit(false);
    end;

    local procedure GetShopifyOrderDetails(var LogEntry: Record "NPR Spfy Event Log Entry"; var ShopifyResponse: JsonToken; var FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache"): Boolean
    var
        SpfyAPIOrderHelper: Codeunit "NPR Spfy Order ApiHelper";
    begin
        Clear(ShopifyResponse);
        FulfillmentCache.ClearCache();
        ClearLastError();
        Commit();
        SpfyAPIOrderHelper.SetFulfillmentCache(FulfillmentCache);
        if not SpfyAPIOrderHelper.Run(LogEntry) then
            Error(GetLastErrorText());
        SpfyAPIOrderHelper.GetFulfillmentCache(FulfillmentCache);
        LogEntry.ReadIsolation := IsolationLevel::UpdLock;
        LogEntry.Get(LogEntry."Entry No.");
        ShopifyResponse := SpfyAPIOrderHelper.GetResponse();
        exit(not LogEntry.Postponed);
    end;

    local procedure CreateDocument(var LogEntry: Record "NPR Spfy Event Log Entry"; var FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache"): Boolean
    var
        DetailsResponse: JsonToken;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        exit(CreateAndProcessEcommerceDocument(LogEntry, DetailsResponse, EcomSalesHeader, FulfillmentCache));
    end;

    local procedure UpdateAndProcess(var LogEntry: Record "NPR Spfy Event Log Entry"; var FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache"): Boolean
    var
        DetailsResponse: JsonToken;
    begin
        if GetShopifyOrderDetails(LogEntry, DetailsResponse, FulfillmentCache) then
            if not LogEntry.Postponed then
                exit(UpdateFromShopifyAndProcess(LogEntry, DetailsResponse, FulfillmentCache));
        exit(false);
    end;

    internal procedure CreateEcommerceDocumentFromJson(var LogEntry: Record "NPR Spfy Event Log Entry"; Response: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header"): Boolean
    var
        FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache";
    begin
        _SpfyAPIOrderHelper.BuildFulfillmentCacheFromOrderJson(Response, FulfillmentCache);
        exit(CreateEcommerceDocument(LogEntry, Response, EcomSalesHeader, FulfillmentCache));
    end;

    internal procedure UpdateSalesLinesFromJson(var SalesHeader: Record "Sales Header"; Response: JsonToken; LogEntry: Record "NPR Spfy Event Log Entry")
    begin
        UpdateSalesLinesFromJson(SalesHeader, Response, LogEntry, false);
    end;

    internal procedure UpdateSalesLinesFromJson(var SalesHeader: Record "Sales Header"; Response: JsonToken; LogEntry: Record "NPR Spfy Event Log Entry"; IsCreatePath: Boolean)
    var
        Header: RecordRef;
        FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache";
    begin
        _SpfyAPIOrderHelper.BuildFulfillmentCacheFromOrderJson(Response, FulfillmentCache);
        SetQuantities(SalesHeader);
        Header.GetTable(SalesHeader);
        ProcessEcommerceSaleLines(Response, Header, LogEntry, FulfillmentCache, IsCreatePath);
        ProcessEcommerceShippingLines(Response, Header, LogEntry, FulfillmentCache);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    local procedure CreateEcommerceDocument(var LogEntry: Record "NPR Spfy Event Log Entry"; Response: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header"; var FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache"): Boolean
    begin
        Clear(EcomSalesHeader);
        ProcessEcommerceHeader(Response, EcomSalesHeader, LogEntry);
        ProcessLines(Response, EcomSalesHeader, LogEntry, FulfillmentCache);
        ProcessEcommercePaymentLines(Response, EcomSalesHeader, LogEntry);
        ProcessEcommerceComment(Response, EcomSalesHeader);
        exit(true);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    local procedure UpdateSalesDocument(var LogEntry: Record "NPR Spfy Event Log Entry"; Response: JsonToken; var SalesHeader: Record "Sales Header"; var FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache")
    begin
        UpdateSalesHeader(LogEntry, SalesHeader, Response);
        UpdateSalesLines(LogEntry, SalesHeader, Response, FulfillmentCache, false);
        UpdatePaymentLines(LogEntry, SalesHeader, Response);
    end;

    local procedure UpdateFromShopifyAndProcess(var LogEntry: Record "NPR Spfy Event Log Entry"; Response: JsonToken; var FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache") Success: Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        LogEntry.CalcFields("Posting Status");
        if LogEntry."Posting Status" = LogEntry."Posting Status"::Invoiced then
            exit(true);
        UpdateSalesDocument(LogEntry, Response, SalesHeader, FulfillmentCache);
        PostAndDeleteDocument(LogEntry, SalesHeader);
        Success := true;
    end;

    local procedure UpdateSalesHeader(var LogEntry: Record "NPR Spfy Event Log Entry"; var SalesHeader: Record "Sales Header"; Response: JsonToken)
    var
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        SpfyAPIEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        OrderToken: JsonToken;
        ClosedDate: Date;
    begin
        SpfyAPIEventLogMgt.ResolveCurrencyIfPending(LogEntry, Response);
        LogEntry.CalcFields("Created Sales Doc No.");
        Response.SelectToken('data.order', OrderToken);
        SalesHeader.ReadIsolation := IsolationLevel::UpdLock;
        SalesHeader.Get(_SpfyEcomSalesDocPrcssr.MapSalesDocumentType(LogEntry."Document Type"), LogEntry."Created Sales Doc No.");

        SalesHeader.SetHideValidationDialog(true);
        if SalesHeader.Status = SalesHeader.Status::Released then
            ReleaseSalesDoc.PerformManualReopen(SalesHeader);

        ClosedDate := DT2Date(LogEntry."Closed Date-Time");
        if SalesHeader."Posting Date" <> ClosedDate then begin
            SalesHeader.Validate("Posting Date", ClosedDate);
            SalesHeader.Modify();
        end;
        OrderMgt.InsertComments(OrderToken, SalesHeader);
        SpfyIntegrationEvents.OnUpdateSalesHeader(OrderToken, SalesHeader);
    end;

    local procedure UpdatePaymentLines(LogEntry: Record "NPR Spfy Event Log Entry"; var SalesHeader: Record "Sales Header"; Response: JsonToken)
    var
        Header: RecordRef;
    begin
        Header.GetTable(SalesHeader);
        ProcessPaymentLines(Response, Header, LogEntry);
    end;

    local procedure UpdateSalesLines(LogEntry: Record "NPR Spfy Event Log Entry"; SalesHeader: Record "Sales Header"; Response: JsonToken; var FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache"; IsCreatePath: Boolean)
    var
        Header: RecordRef;
    begin
        SetQuantities(SalesHeader);
        Header.GetTable(SalesHeader);
        ProcessEcommerceSaleLines(Response, Header, LogEntry, FulfillmentCache, IsCreatePath);
        ProcessEcommerceShippingLines(Response, Header, LogEntry, FulfillmentCache);
    end;

    local procedure AddNewSaleLine(var SalesLine: Record "Sales Line"; SalesLineJsonToken: JsonToken; SalesHeader: Record "Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry"; TempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary; ItemVariant: Record "Item Variant")
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        VATPct: Decimal;
    begin
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", ItemVariant."Item No.");
        SalesLine."Variant Code" := ItemVariant.Code;
        SalesLine.Validate(Quantity, _SpfyAPIOrderHelper.LineOpenQuantity(SalesLineJsonToken) + TempSpfyFulfillmentBuffer."Fulfilled Quantity");
#pragma warning disable AA0139
        SalesLine.Description := JsonHelper.GetJText(SalesLineJsonToken, 'title', MaxStrLen(SalesLine.Description), true);
        SalesLine."Description 2" := JsonHelper.GetJText(SalesLineJsonToken, 'variantTitle', MaxStrLen(SalesLine."Description 2"), false);
#pragma warning restore AA0139
        OrderMgt.SetOrderLineUnitPriceAndDiscount(SalesHeader, LogEntry."Store Code", JsonHelper.GetJDecimal(SalesLineJsonToken, 'originalUnitPriceSet.presentmentMoney.amount', true), CalcLineDiscountAmount(SalesLineJsonToken, SalesLine), SalesLine);

        // Shopify's tax data wins over the VAT posting setup, and it wins even when it reports no tax at all:
        // CalculateVAT returns 0 both for an empty taxLines array and for tax lines of zero amount, and the write stays
        // unconditional so the document always matches what the customer was charged in Shopify. Deliberate, and the
        // same as AddNewShippingLine and the Ecommerce create path do it - pinned by
        // AddNewSaleLine_ShopifyReportsNoTax_ForcesZeroVATPercent.
        VATPct := CalculateVAT(SalesLineJsonToken);
        SalesLine.Validate("VAT %", VATPct);

        if SalesHeader."Location Code" <> '' then
            SalesLine.Validate("Location Code", SalesHeader."Location Code");

        SetQuantityToShip(SalesLine, TempSpfyFulfillmentBuffer);
        SalesLine.Modify(true);
        SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", TempSpfyFulfillmentBuffer."Order Line ID", false);
    end;

    local procedure InitNewSalesLine(var SalesLine: record "Sales Line"; SalesHeader: Record "Sales Header")
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := _IncEcomSalesDocUtils.GetInternalSalesDocumentLastLineNo(SalesHeader) + 10000;
        SalesLine.Insert(true);
    end;

    local procedure SetQuantities(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.ReadIsolation := IsolationLevel::UpdLock;
        if not SalesLine.FindSet() then
            exit;

        repeat
            if not IsVirtualItemSalesLine(SalesLine) then
                if (SalesLine."Qty. to Ship" <> 0) or (SalesLine."Qty. to Invoice" <> 0) then begin
                    if SalesLine."Qty. to Ship" <> 0 then
                        SalesLine.Validate("Qty. to Ship", 0);
                    if SalesLine."Qty. to Invoice" <> 0 then
                        SalesLine.Validate("Qty. to Invoice", 0);
                    SalesLine.Modify(true);
                end;
        until SalesLine.Next() = 0;
    end;

    local procedure IsVirtualItemSalesLine(SalesLine: Record "Sales Line"): Boolean
    var
        Item: Record Item;
        MMMembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        MMMembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        // Detect vouchers via the same NpRv link pattern as MagentoSalesOrderMgt.IsRetailVoucherLine
        // (Document Source = "Sales Document" + Document Type/No./Line No.).
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Sales Document");
        NpRvSalesLine.SetRange("Document Type", SalesLine."Document Type");
        NpRvSalesLine.SetRange("Document No.", SalesLine."Document No.");
        NpRvSalesLine.SetRange("Document Line No.", SalesLine."Line No.");
        if not NpRvSalesLine.IsEmpty() then
            exit(true);

        // Detect tickets via Item."NPR Ticket Type", mirroring MagentoSalesOrderMgt.IsTicketLine.
        if SalesLine.Type = SalesLine.Type::Item then
            if Item.Get(SalesLine."No.") then
                if Item."NPR Ticket Type" <> '' then
                    exit(true);

        // Detect memberships via MM setup, mirroring MagentoSalesOrderMgt.IsMembershipLine.
        case SalesLine.Type of
            SalesLine.Type::"G/L Account":
                if MMMembershipSalesSetup.Get(MMMembershipSalesSetup.Type::ACCOUNT, SalesLine."No.") then
                    exit(true);
            SalesLine.Type::Item:
                begin
                    if MMMembershipSalesSetup.Get(MMMembershipSalesSetup.Type::ITEM, SalesLine."No.") then
                        exit(true);
                    MMMembershipAlterationSetup.SetRange("Sales Item No.", SalesLine."No.");
                    if not MMMembershipAlterationSetup.IsEmpty() then
                        exit(true);
                end;
        end;

        exit(false);
    end;

    internal procedure CalcLineDiscountAmount(OrderLine: JsonToken; SalesLine: Record "Sales Line") LineDiscountAmount: Decimal
    var
        OriginalOrderQty: Decimal;
    begin
        OriginalOrderQty := _SpfyAPIOrderHelper.LineDiscountBaseQuantity(OrderLine);
        exit(CalcProratedLineDiscount(OrderLine, SalesLine.Quantity, OriginalOrderQty));
    end;

    local procedure SetQuantityToShip(var SalesLine: Record "Sales Line"; TempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary)
    var
        QtyToShip: Decimal;
    begin
        QtyToShip := TempSpfyFulfillmentBuffer."Fulfilled Quantity" - SalesLine."Quantity Shipped";
        if QtyToShip < 0 then
            QtyToShip := 0;

        if SalesLine."Qty. to Ship" <> QtyToShip then
            SalesLine.Validate("Qty. to Ship", QtyToShip);
    end;

    local procedure ProcessEcommercePaymentLines(Response: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry");
    var
        Header: RecordRef;
    begin
        Header.GetTable(EcomSalesHeader);
        ProcessPaymentLines(Response, Header, LogEntry)
    end;

    /// <summary>
    /// If the store does not let Business Central send capture requests, the payment can only count as settled when the payment mapping declares that it is
    /// captured outside Business Central.
    /// </summary>
    internal procedure CheckVirtualItemsCanBeCaptured(EcomSalesHeader: Record "NPR Ecom Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry")
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        ShopifyStore: Record "NPR Spfy Store";
        CaptureNotAllowedErr: Label 'The order contains virtual items, which cannot be issued before the payment has been captured. "%1" is disabled for Shopify store %2, and the payment mapping of "%3"/"%4" is not marked as "%5".', Comment = '%1 - Send Payment Capture Requests fieldcaption, %2 - Shopify store code, %3 - external payment method code, %4 - external payment type, %5 - Captured Externally fieldcaption';
    begin
        if not EcomSalesHeader."Virtual Items Exist" then
            exit;
        if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Payment Capture Requests", LogEntry."Store Code") then
            exit;

        EcomSalesPmtLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesPmtLine.SetRange("Payment Method Type", EcomSalesPmtLine."Payment Method Type"::"Payment Method");
        EcomSalesPmtLine.SetFilter(Amount, '<>%1', 0);
        if not EcomSalesPmtLine.FindSet() then
            exit;
        repeat
            if FindPaymentMapping(EcomSalesPmtLine, PaymentMapping) then
                if not PaymentMapping."Captured Externally" then
                    Error(CaptureNotAllowedErr, ShopifyStore.FieldCaption("Send Payment Capture Requests"), LogEntry."Store Code", EcomSalesPmtLine."External Payment Method Code", EcomSalesPmtLine."External Payment Type", PaymentMapping.FieldCaption("Captured Externally"));
        until EcomSalesPmtLine.Next() = 0;
    end;

    local procedure FindPaymentMapping(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; var PaymentMapping: Record "NPR Magento Payment Mapping"): Boolean
    begin
        PaymentMapping.Reset();
        PaymentMapping.SetRange("External Payment Method Code", EcomSalesPmtLine."External Payment Method Code");
        PaymentMapping.SetRange("External Payment Type", EcomSalesPmtLine."External Payment Type");
        PaymentMapping.SetLoadFields("Captured Externally");
        if PaymentMapping.FindFirst() then
            exit(true);
        PaymentMapping.SetRange("External Payment Type");
        exit(PaymentMapping.FindFirst());
    end;

    local procedure ProcessPaymentLines(Response: JsonToken; Header: RecordRef; LogEntry: Record "NPR Spfy Event Log Entry");
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SalesHeader: Record "Sales Header";
        PaymentLinesJsonToken: JsonToken;
    begin
        PaymentLinesJsonToken := JsonHelper.GetJsonToken(Response, 'data.order.transactions');
        if (not PaymentLinesJsonToken.IsArray()) then
            Error(NoArrayErr, 'data.order.transactions');

        if ResolveDocumentHeader(Header, SalesHeader, EcomSalesHeader) then
            ProcessSalesPaymentLines(PaymentLinesJsonToken, SalesHeader, LogEntry)
        else
            ProcessEcommerceSalesPaymentLines(PaymentLinesJsonToken, EcomSalesHeader, LogEntry);
    end;

    local procedure ProcessEcommerceSalesPaymentLines(PaymentLinesJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry")
    var
        SpfyCapturePayment: Codeunit "NPR Spfy Capture Payment";
        PaymentLineJsonToken: JsonToken;
        ShopifyTransactionKind: Text;
        IsHandled: Boolean;
    begin
        SpfyIntegrationEvents.OnBeforeInsertEcommerceSalesPaymentLines(LogEntry."Store Code", PaymentLinesJsonToken, EcomSalesHeader, IsHandled);
        if not IsHandled then
            foreach PaymentLineJsonToken in PaymentLinesJsonToken.AsArray() do begin
                ShopifyTransactionKind := JsonHelper.GetJText(PaymentLineJsonToken, 'kind', false).ToUpper();
                if JsonHelper.GetJText(PaymentLineJsonToken, 'status', true).ToUpper() = 'SUCCESS' then
                    if SpfyCapturePayment.IsAuthorizationTransaction(ShopifyTransactionKind) or SpfyCapturePayment.IsSaleTransaction(ShopifyTransactionKind) or
                       ((EcomSalesHeader."Document Type" = EcomSalesHeader."Document Type"::"Return Order") and SpfyCapturePayment.IsRefundTransaction(ShopifyTransactionKind))
                    then
                        InsertEcommerceSalesPaymentLine(PaymentLineJsonToken, EcomSalesHeader, LogEntry);
            end;
        IsHandled := false;
        SpfyIntegrationEvents.OnAfterInsertEcommercePaymentLines(LogEntry."Store Code", PaymentLinesJsonToken, EcomSalesHeader, IsHandled);
        CheckVirtualItemsCanBeCaptured(EcomSalesHeader, LogEntry);
    end;

    local procedure ProcessSalesPaymentLines(PaymentLinesJsonToken: JsonToken; SalesHeader: Record "Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry")
    var
        SpfyCapturePayment: Codeunit "NPR Spfy Capture Payment";
        TempSpfyTransactionBuffer: Record "NPR Spfy Transaction Buffer" temporary;
        NcTask: Record "NPR Nc Task";
        PaymentLineJsonToken: JsonToken;
        Handled: Boolean;
    begin
        SpfyIntegrationEvents.OnBeforeUpdatePaymentLines(LogEntry."Store Code", PaymentLinesJsonToken, SalesHeader, Handled);
        if not Handled then begin
            NcTask."Record ID" := SalesHeader.RecordId();
            NcTask."Record Value" := LogEntry."Shopify ID";
            NcTask."Store Code" := LogEntry."Store Code";
            foreach PaymentLineJsonToken in PaymentLinesJsonToken.AsArray() do
                SpfyCapturePayment.ProcessTransaction(PaymentLineJsonToken, NcTask, TempSpfyTransactionBuffer);
            SpfyCapturePayment.UpdatePmtLines(NcTask, PaymentLinesJsonToken.AsArray(), TempSpfyTransactionBuffer);
        end;
        Handled := false;
        SpfyIntegrationEvents.OnAfterUpdatePaymentLines(LogEntry."Store Code", PaymentLinesJsonToken, SalesHeader, Handled);
    end;

    local procedure InsertEcommerceSalesPaymentLine(PaymentLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry")
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        EcomSalesDocApiAgentV2: Codeunit "NPR EcomSalesDocApiAgentV2";
        IncEcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        EcomSalesPmtLine.Init();
        EcomSalesPmtLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesPmtLine."External Document No." := EcomSalesHeader."External No.";
        EcomSalesPmtLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesPmtLine."Line No." := IncEcomSalesDocUtils.GetSalesDocLastPaymentLineLineNo(EcomSalesHeader) + 10000;
        ParseEcommerceSalesPaymentLine(PaymentLineJsonToken, EcomSalesPmtLine, LogEntry, EcomSalesHeader);
        CheckIfPaymentLineExists(EcomSalesPmtLine);
        SpfyIntegrationEvents.OnBeforeInsertEcommerceSalesPaymentLine(PaymentLineJsonToken, EcomSalesHeader, EcomSalesPmtLine);
        EcomSalesPmtLine.Insert(true);
        if EcomSalesPmtLine."Payment Method Type" = EcomSalesPmtLine."Payment Method Type"::Voucher then
            EcomSalesDocApiAgentV2.ReserveVoucher(EcomSalesHeader, EcomSalesPmtLine);
    end;

    local procedure ParseEcommerceSalesPaymentLine(PaymentLineJsonToken: JsonToken; var EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; LogEntry: Record "NPR Spfy Event Log Entry"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        SpfyCapturePayment: Codeunit "NPR Spfy Capture Payment";
        SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
        GiftCardTransaction: Boolean;
    begin
        EcomSalesPmtLine."Shopify ID" := OrderMgt.GetNumericId(JsonHelper.GetJText(PaymentLineJsonToken, 'id', true));
        EcomSalesPmtLine.Amount := JsonHelper.GetJDecimal(PaymentLineJsonToken, 'amountSet.presentmentMoney.amount', false);
        EcomSalesPmtLine."Amount (Store Currency)" := JsonHelper.GetJDecimal(PaymentLineJsonToken, 'amountSet.shopMoney.amount', true);
        EcomSalesPmtLine."Store Currency Code" := SpfyPaymentGatewayHdlr.TranslateCurrencyCode(JsonHelper.GetJText(PaymentLineJsonToken, 'amountSet.shopMoney.currencyCode', false));
        EcomSalesPmtLine."External Payment Gateway" := CopyStr(JsonHelper.GetJText(PaymentLineJsonToken, 'gateway', false), 1, MaxStrLen(EcomSalesPmtLine."External Payment Gateway"));
        if SpfyCapturePayment.IsSaleTransaction(JsonHelper.GetJText(PaymentLineJsonToken, 'kind', false).ToUpper()) then
            GiftCardTransaction := AddVoucherPaymentLine(PaymentLineJsonToken, EcomSalesPmtLine, EcomSalesHeader."External No.");
        if not GiftCardTransaction then
            InitCreditCardPaymentLine(PaymentLineJsonToken, EcomSalesPmtLine, LogEntry, EcomSalesHeader."External No.");
    end;

    local procedure InitCreditCardPaymentLine(PaymentLineJsonToken: JsonToken; var EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; LogEntry: Record "NPR Spfy Event Log Entry"; ExternalNo: Code[20])
    var
        PaymentMethod: Record "Payment Method";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        SpfyCapturePayment: Codeunit "NPR Spfy Capture Payment";
        SpfyUpdateAdyenTrInfo: Codeunit "NPR Spfy Update Adyen Tr. Info";
        CardNumber: Text;
        ExternalPaymentMethodNotSetupErr: Label 'External payment method type: %1, external payment method code: %2 is not set up for payment.', Comment = '%1 - external payment method type, %2 - external payment method code', Locked = true;
    begin
        EcomSalesPmtLine."Payment Method Type" := EcomSalesPmtLine."Payment Method Type"::"Payment Method";
        SpfyCapturePayment.GetPaymentMapping(PaymentLineJsonToken, LogEntry."Store Code", PaymentMapping);
        if not PaymentMethod.Get(PaymentMapping."Payment Method Code") then
            Error(ExternalPaymentMethodNotSetupErr, PaymentMapping."External Payment Type", PaymentMapping."External Payment Method Code");
#pragma warning disable AA0139
        EcomSalesPmtLine.Description := CopyStr(PaymentMethod.Description + ' ' + ExternalNo, 1, MaxStrLen(EcomSalesPmtLine.Description));
        EcomSalesPmtLine."External Payment Method Code" := PaymentMapping."External Payment Method Code";
        EcomSalesPmtLine."External Payment Type" := PaymentMapping."External Payment Type";
        EcomSalesPmtLine."Date Authorized" := DT2Date(JsonHelper.GetJDT(PaymentLineJsonToken, 'processedAt', false));
        if EcomSalesPmtLine."Date Authorized" = 0D then
            EcomSalesPmtLine."Date Authorized" := DT2Date(JsonHelper.GetJDT(PaymentLineJsonToken, 'createdAt', false));
        EcomSalesPmtLine."Expires At" := JsonHelper.GetJDT(PaymentLineJsonToken, 'authorizationExpiresAt', false);
        EcomSalesPmtLine."Card Brand" := JsonHelper.GetJText(PaymentLineJsonToken, 'paymentDetails.company', MaxStrLen(EcomSalesPmtLine."Card Brand"), false);
        EcomSalesPmtLine."Card Expiry Date" := StrSubstNo('%1/%2', JsonHelper.GetJText(PaymentLineJsonToken, 'paymentDetails.expirationMonth', false).PadLeft(2, '0'), JsonHelper.GetJText(PaymentLineJsonToken, 'paymentDetails.expirationYear', false));
        CardNumber := JsonHelper.GetJText(PaymentLineJsonToken, 'paymentDetails.number', false);
        if StrLen(CardNumber) <= 4 then
            EcomSalesPmtLine."Masked Card Number" := CardNumber
        else
            EcomSalesPmtLine."Masked Card Number" := CopyStr(CardNumber, StrLen(CardNumber) - 3);
        EcomSalesPmtLine."Payment Reference" := JsonHelper.GetJText(PaymentLineJsonToken, 'paymentId', MaxStrLen(EcomSalesPmtLine."Payment Reference"), true, false);
#pragma warning restore AA0139

        SpfyUpdateAdyenTrInfo.UpdatePaymentLineWithDataFromAdyen(EcomSalesPmtLine);

        SpfyIntegrationEvents.OnAfterParseEcommercePaymentMethodPaymentLine(PaymentLineJsonToken, EcomSalesPmtLine);
    end;

    local procedure AddVoucherPaymentLine(PaymentLineJsonToken: JsonToken; var EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; ExternalNo: Code[20]): Boolean
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
        ReceiptJson: JsonToken;
        ShopifyGiftCardID: Text[30];
        ReceiptJText: Text;
        NotSupportedPayMethodErr: Label 'The payment was made using the Manual Payment method %1, which is not supported.', Comment = '%1=Gateway';
        WrongFormatErr: Label 'Receipt JSON could not be parsed. Please check the data format.';
        VoucherNotFoundErr: Label 'System could not find a retail voucher with Shopify gift card ID %1';
        VoucherLbl: Label 'Voucher';
    begin
        if not ReceiptJson.ReadFrom(JsonHelper.GetJText(PaymentLineJsonToken, 'receiptJson', true)) then
            Error(WrongFormatErr);
        if not ReceiptJson.WriteTo(ReceiptJText) then
            Error(WrongFormatErr);
        if (ReceiptJText = '{}') then
            Error(NotSupportedPayMethodErr, EcomSalesPmtLine."External Payment Gateway");
        ShopifyGiftCardID := OrderMgt.GetNumericId(JsonHelper.GetJText(ReceiptJson, 'gift_card_id', false));
        if ShopifyGiftCardID = '' then
            exit(false);
        SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"NPR NpRv Voucher", "NPR Spfy ID Type"::"Entry ID", ShopifyGiftCardID, ShopifyAssignedID);
        if not ShopifyAssignedID.FindLast() then
            Error(VoucherNotFoundErr, ShopifyGiftCardID);

        RecRef.Get(ShopifyAssignedID."BC Record ID");
        RecRef.SetTable(NpRvVoucher);
        EcomSalesPmtLine."Payment Method Type" := EcomSalesPmtLine."Payment Method Type"::Voucher;
        EcomSalesPmtLine."Payment Reference" := NpRvVoucher."Reference No.";
        EcomSalesPmtLine.Description := CopyStr(VoucherLbl + ' ' + ExternalNo, 1, MaxStrLen(EcomSalesPmtLine.Description));
        SpfyIntegrationEvents.OnAfterParseEcommerceVoucherPaymentLine(PaymentLineJsonToken, EcomSalesPmtLine);
        exit(true);
    end;

    local procedure ProcessEcommerceHeader(Response: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header"; var LogEntry: Record "NPR Spfy Event Log Entry");
    var
        SpfyAPIEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        SpfyAPIEventLogMgt.ResolveCurrencyIfPending(LogEntry, Response);
        InitEcommerceHeader(LogEntry, EcomSalesHeader, Response);
        EcomSalesHeader."Requested API Version Date" := Today;
        EcomSalesHeader."API Version Date" := EcomSalesDocUtils.GetApiVersionDateByRequest(Today);
        ParseEcommerceHeader(EcomSalesHeader, Response);
        CheckIfEcommerceDocumentAlreadyExist(EcomSalesHeader);
        SpfyIntegrationEvents.OnBeforeInsertEcommerceSalesHeader(EcomSalesHeader, Response);
        EcomSalesHeader.Insert(true);
    end;

    local procedure CheckIfEcommerceDocumentAlreadyExist(EcomHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        AlreadyExistsErr: Label 'Ecommerce document for Shopify order %1 already exists.', Comment = 'Shopify ID';
    begin
        EcomSalesHeader.ReadIsolation := IsolationLevel::ReadCommitted;
        EcomSalesHeader.SetCurrentKey("External No.", "Document Type");
        EcomSalesHeader.SetRange("External No.", EcomHeader."External No.");
        EcomSalesHeader.SetRange("Document Type", EcomHeader."Document Type");
        if EcomSalesHeader.FindFirst() then
            Error(AlreadyExistsErr, EcomSalesHeader."External No.");
    end;

    local procedure ProcessLines(Response: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry"; var FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache");
    var
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        Header: RecordRef;
    begin
        Header.GetTable(EcomSalesHeader);
        ProcessEcommerceSaleLines(Response, Header, LogEntry, FulfillmentCache, false);
        ProcessEcommerceShippingLines(Response, Header, LogEntry, FulfillmentCache);
        EcomVirtualItemMgt.UpdateVirtualItemInformationInHeader(EcomSalesHeader);
    end;

    local procedure ProcessEcommerceShippingLines(Response: JsonToken; Header: RecordRef; LogEntry: Record "NPR Spfy Event Log Entry"; var FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache");
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SalesHeader: Record "Sales Header";
        LineToken: JsonToken;
        ShippingLineJsonToken: JsonToken;
        ShippingLinesJsonToken: JsonToken;
        LineType: Enum "NPR Ecom Sales Line Type";
        ApplyToSalesDocument: Boolean;
    begin
        ShippingLinesJsonToken := JsonHelper.GetJsonToken(Response, 'data.order.shippingLines');
        if ShippingLinesJsonToken.AsArray().Count = 0 then
            exit;

        ApplyToSalesDocument := ResolveDocumentHeader(Header, SalesHeader, EcomSalesHeader);

        foreach ShippingLineJsonToken in ShippingLinesJsonToken.AsArray() do begin
            ShippingLineJsonToken.SelectToken('node', LineToken);
            if JsonHelper.GetJDecimal(LineToken, 'originalPriceSet.presentmentMoney.amount', false) <> 0 then
                if ApplyToSalesDocument then
                    ProcessShippingLine(LineToken, SalesHeader)
                else
                    InsertEcommerceSalesLine(LineToken, EcomSalesHeader, LogEntry, LineType::"Shipment Fee", FulfillmentCache)
        end;
    end;

    local procedure ProcessEcommerceSaleLines(Response: JsonToken; Header: RecordRef; LogEntry: Record "NPR Spfy Event Log Entry"; var FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache"; IsCreatePath: Boolean);
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        TempPreparedFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
        SalesHeader: Record "Sales Header";
        LineToken: JsonToken;
        SalesLineJsonToken: JsonToken;
        SalesLinesJsonToken: JsonToken;
        SalesLineByOrderLineIds: Dictionary of [Text[30], RecordId];
        ApplyToSalesDocument: Boolean;
    begin
        GetSalesLinesJsonToken(SalesLinesJsonToken, Response);
        ApplyToSalesDocument := ResolveDocumentHeader(Header, SalesHeader, EcomSalesHeader);

        if ApplyToSalesDocument then begin
            GetAssignedIdsForExistingSalesLines(SalesHeader, SalesLineByOrderLineIds);
            FulfillmentCache.PrepareFulfillmentBufferSnapshot(TempPreparedFulfillmentBuffer);
        end;

        foreach SalesLineJsonToken in SalesLinesJsonToken.AsArray() do begin
            SalesLineJsonToken.SelectToken('node', LineToken);
            if not IsProductRemoved(LineToken) then
                if ApplyToSalesDocument then
                    ProcessSaleLine(LineToken, SalesHeader, LogEntry, SalesLineByOrderLineIds, TempPreparedFulfillmentBuffer, FulfillmentCache, IsCreatePath)
                else
                    ProcessEcommerceSalesLine(LineToken, EcomSalesHeader, LogEntry, FulfillmentCache);
        end;
    end;

    local procedure GetAssignedIdsForExistingSalesLines(SalesHeader: Record "Sales Header"; var SalesLineByOrderLineIds: Dictionary of [Text[30], RecordId])
    var
        SalesLine: Record "Sales Line";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyOrderLineId: Text[30];
    begin
        Clear(SalesLineByOrderLineIds);
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                SpfyOrderLineId := CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID"), 1, 30);
                if SpfyOrderLineId <> '' then
                    if not SalesLineByOrderLineIds.ContainsKey(SpfyOrderLineId) then
                        SalesLineByOrderLineIds.Add(SpfyOrderLineId, SalesLine.RecordId());
            until SalesLine.Next() = 0;
    end;

    local procedure ResolveDocumentHeader(Header: RecordRef; var SalesHeader: Record "Sales Header"; var EcomSalesHeader: Record "NPR Ecom Sales Header") UpdateSalesDoc: Boolean;
    var
        UnsupportedErr: Label 'Unsupported header type %1', Comment = '%1= table ID';
    begin
        case Header.Number() of
            Database::"NPR Ecom Sales Header":
                Header.SetTable(EcomSalesHeader);
            Database::"Sales Header":
                begin
                    Header.SetTable(SalesHeader);
                    UpdateSalesDoc := true;
                end;
            else
                Error(UnsupportedErr, Header.Number());
        end;
    end;

    local procedure ProcessSaleLine(SalesLineJsonToken: JsonToken; SalesHeader: Record "Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry"; var SalesLineByOrderLineIds: Dictionary of [Text[30], RecordId]; var PreparedFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary; var FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache"; IsCreatePath: Boolean)
    var
        SalesLine: Record "Sales Line";
        TempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
        OrderLineId: Text[30];
        IsHandled: Boolean;
        IsNewLine: Boolean;
        SalesLineResolved: Boolean;
    begin
        SpfyIntegrationEvents.OnBeforeUpdateSalesLine(SalesLineJsonToken, SalesHeader, SalesLine, IsHandled);
        if IsHandled then
            exit;

        OrderLineId := CopyStr(OrderMgt.GetNumericId(JsonHelper.GetJText(SalesLineJsonToken, 'id', true)), 1, MaxStrLen(OrderLineId));

        if FulfillmentCache.GetFulfillmentLineFromSnapshot(OrderLineId, PreparedFulfillmentBuffer, TempSpfyFulfillmentBuffer)
        then begin
            if GetSalesLineByOrderLineId(SalesLineByOrderLineIds, TempSpfyFulfillmentBuffer."Order Line ID", SalesLine)
            then
                ValidateAndUpdateExistingSalesLineFromShopify(SalesLine, TempSpfyFulfillmentBuffer, SalesLineJsonToken, SalesHeader, LogEntry, IsCreatePath)
            else begin
                HandleNewSalesLine(SalesLine, SalesLineJsonToken, SalesHeader, LogEntry, TempSpfyFulfillmentBuffer);
                IsNewLine := true;
            end;
            SalesLineResolved := true;
        end else begin
            SalesLineResolved := ResetQuantitiesForLineWithoutFulfillment(OrderLineId, SalesLineJsonToken, SalesHeader, LogEntry, SalesLineByOrderLineIds, SalesLine, IsCreatePath);
            if not SalesLineResolved then begin
                TempSpfyFulfillmentBuffer."Order Line ID" := OrderLineId;
                HandleNewSalesLine(SalesLine, SalesLineJsonToken, SalesHeader, LogEntry, TempSpfyFulfillmentBuffer);
                IsNewLine := true;
                SalesLineResolved := true;
            end;
        end;

        if SalesLineResolved then
            SpfyIntegrationEvents.OnAfterUpdateSalesLine(SalesLineJsonToken, SalesHeader, SalesLine, IsNewLine);
    end;

    local procedure HandleNewSalesLine(var SalesLine: Record "Sales Line"; SalesLineJsonToken: JsonToken; SalesHeader: Record "Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry"; TempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary)
    var
        ItemVariant: Record "Item Variant";
    begin
        if OrderLineIsVirtualItem(LogEntry."Store Code", SalesLineJsonToken, TempSpfyFulfillmentBuffer."Order Line ID", ItemVariant) then
            Error(VirtualItemExtraErr, JsonHelper.GetJText(SalesLineJsonToken, 'name', false), _SpfyAPIOrderHelper.LineOrderedQuantity(SalesLineJsonToken));

        InitNewSalesLine(SalesLine, SalesHeader);
        AddNewSaleLine(SalesLine, SalesLineJsonToken, SalesHeader, LogEntry, TempSpfyFulfillmentBuffer, ItemVariant);
    end;

    local procedure ValidateAndUpdateExistingSalesLineFromShopify(var SalesLine: Record "Sales Line"; TempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary; SalesLineJsonToken: JsonToken; SalesHeader: Record "Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry"; IsCreatePath: Boolean)
    begin
        if OrderLineIsVirtualItem(LogEntry."Store Code", SalesLineJsonToken, TempSpfyFulfillmentBuffer."Order Line ID") then begin
            if not IsCreatePath then
                if IsVirtualLineChanged(TempSpfyFulfillmentBuffer, SalesLine, SalesLineJsonToken) then
                    Error(VirtualItemExtraErr, SalesLine.Description, _SpfyAPIOrderHelper.LineOrderedQuantity(SalesLineJsonToken));
            exit;
        end;

        UpdateSalesLineFromShopify(SalesLine, TempSpfyFulfillmentBuffer, SalesLineJsonToken, SalesHeader, LogEntry);
    end;

    local procedure GetSalesLineByOrderLineId(var SalesLineByOrderLineId: Dictionary of [Text[30], RecordId]; OrderLineId: Text[30]; var SalesLine: Record "Sales Line"): Boolean
    var
        SalesLineRecId: RecordId;
    begin
        if not SalesLineByOrderLineId.Get(OrderLineId, SalesLineRecId) then
            exit(false);
        SalesLine.Get(SalesLineRecId);
        exit(true);
    end;

    local procedure ResetQuantitiesForLineWithoutFulfillment(OrderLineId: Text[30]; SalesLineJsonToken: JsonToken; SalesHeader: Record "Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry"; var SalesLineByOrderLineId: Dictionary of [Text[30], RecordId]; var SalesLine: Record "Sales Line"; IsCreatePath: Boolean): Boolean
    var
        SalesLineRecId: RecordId;
        OrderedQty: Decimal;
        PrevSalesLine: Text;
        QuantityTakenFromShopify: Boolean;
    begin
        if not SalesLineByOrderLineId.Get(OrderLineId, SalesLineRecId) then
            exit(false);

        SalesLine.Get(SalesLineRecId);
        if IsCreatePath and IsVirtualItemSalesLine(SalesLine) then
            exit(true);
        OrderedQty := QuantityForLineWithoutFulfillment(SalesLineJsonToken, LogEntry, SalesLine, QuantityTakenFromShopify);
        PrevSalesLine := Format(SalesLine);

        if SalesLine.Quantity <> OrderedQty then
            SalesLine.Validate(Quantity, OrderedQty);

        // Where the quantity came from, the price comes from too. Taking it from Shopify means re-syncing it whether or
        // not it moved, so a price or discount edit on a still-unfulfilled line reaches BC. Keeping the Business Central
        // quantity means leaving the amounts alone as well - and the virtual line is why that matters: the fulfilled
        // path refuses exactly this delta with VirtualItemExtraErr (IsVirtualLineChanged compares Unit Price and Line
        // Discount Amount), so repricing here would invoice a provisioned ticket or voucher at an amount it was never
        // issued for.
        if QuantityTakenFromShopify then begin
            GetGLSetup();
            OrderMgt.SetOrderLineUnitPriceAndDiscount(SalesHeader, LogEntry."Store Code", Round(JsonHelper.GetJDecimal(SalesLineJsonToken, 'originalUnitPriceSet.presentmentMoney.amount', true), GLSetup."Unit-Amount Rounding Precision"),
                Round(CalcLineDiscountAmount(SalesLineJsonToken, SalesLine), GLSetup."Amount Rounding Precision"), SalesLine);
        end;
        if not IsVirtualItemSalesLine(SalesLine) then begin
            if SalesLine."Qty. to Ship" <> 0 then
                SalesLine.Validate("Qty. to Ship", 0);
            if SalesLine."Qty. to Invoice" <> 0 then
                SalesLine.Validate("Qty. to Invoice", 0);
        end;

        if Format(SalesLine) <> PrevSalesLine then
            SalesLine.Modify(true);

        exit(true);
    end;

    /// <summary>
    /// The quantity the line should carry when Shopify reports no fulfillment for it. "Without fulfillment" is the
    /// precondition of the whole path, not what this flag is about: within it the quantity is either taken from Shopify
    /// (the ordinary line) or kept at what Business Central already has - for a return, for a virtual item, or when the
    /// item could not be resolved. QuantityTakenFromShopify says which of the two happened, so the caller can source
    /// the price from the same place it sourced the quantity.
    /// </summary>
    local procedure QuantityForLineWithoutFulfillment(SalesLineJsonToken: JsonToken; LogEntry: Record "NPR Spfy Event Log Entry"; SalesLine: Record "Sales Line"; var QuantityTakenFromShopify: Boolean) OrderedQty: Decimal
    var
        LineIsVirtualItem: Boolean;
        ShopifyQty: Decimal;
        VirtualItemCheckSkippedLbl: Label 'Log entry %1, store %2: the virtual item check of an order line was skipped because the item could not be resolved, so the line keeps the quantity Business Central already has. %3', Locked = true;
    begin
        QuantityTakenFromShopify := false;
        if LogEntry."Document Type" <> LogEntry."Document Type"::Order then
            exit(SalesLine.Quantity);

        if not TryOrderLineIsVirtualItem(LogEntry."Store Code", SalesLineJsonToken, LineIsVirtualItem) then begin
            // Tolerated on purpose - an unresolvable item, usually an unsynced SKU, must not block the whole order -
            // but not silently: the quantity below stays frozen at what BC has, and the virtual-item guard cannot run
            // at all, so the reason has to leave a trace before ClearLastError discards it.
            _SpfyEcomSalesDocPrcssr.LogTelemetry(
                StrSubstNo(VirtualItemCheckSkippedLbl, LogEntry."Entry No.", LogEntry."Store Code", GetLastErrorText()),
                'NPR_ShopifyAPI_VirtualItemCheckSkipped');
            ClearLastError();
            exit(SalesLine.Quantity);
        end;
        if LineIsVirtualItem then begin
            ShopifyQty := _SpfyAPIOrderHelper.LineOrderedQuantity(SalesLineJsonToken);
            if (ShopifyQty > 0) and (ShopifyQty <> SalesLine.Quantity) then
                Error(VirtualItemExtraErr, SalesLine.Description, ShopifyQty);
            exit(SalesLine.Quantity);
        end;

        QuantityTakenFromShopify := true;
        OrderedQty := _SpfyAPIOrderHelper.LineOrderedQuantity(SalesLineJsonToken);
        if OrderedQty < SalesLine."Quantity Shipped" then
            OrderedQty := SalesLine."Quantity Shipped";
    end;

    [TryFunction]
    local procedure TryOrderLineIsVirtualItem(ShopifyStoreCode: Code[20]; SalesLineJsonToken: JsonToken; var LineIsVirtualItem: Boolean)
    begin
        LineIsVirtualItem := OrderLineIsVirtualItem(ShopifyStoreCode, SalesLineJsonToken, '');
    end;

    local procedure UpdateSalesLineFromShopify(var SalesLine: Record "Sales Line"; TempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary; SalesLineJsonToken: JsonToken; SalesHeader: Record "Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry")
    var
        ExpectedUnitPrice: Decimal;
        ExpectedDiscount: Decimal;
    begin
        if SalesLine.Quantity <> TempSpfyFulfillmentBuffer."Fulfilled Quantity" then
            SalesLine.Validate(Quantity, TempSpfyFulfillmentBuffer."Fulfilled Quantity");
        SetQuantityToShip(SalesLine, TempSpfyFulfillmentBuffer);
        ExpectedUnitPrice := JsonHelper.GetJDecimal(SalesLineJsonToken, 'originalUnitPriceSet.presentmentMoney.amount', true);
        ExpectedDiscount := CalcLineDiscountAmount(SalesLineJsonToken, SalesLine);
        GetGLSetup();
        OrderMgt.SetOrderLineUnitPriceAndDiscount(
            SalesHeader, LogEntry."Store Code",
            Round(ExpectedUnitPrice, GLSetup."Unit-Amount Rounding Precision"),
            Round(ExpectedDiscount, GLSetup."Amount Rounding Precision"), SalesLine);
        SalesLine.Modify(true);
    end;

    internal procedure OrderLineIsVirtualItem(ShopifyStoreCode: Code[20]; SalesLineJsonToken: JsonToken; ShopifyOrderLineId: Text; var ItemVariant: Record "Item Variant"): Boolean
    var
        Item: Record Item;
    begin
        If EvaluateLineType(SalesLineJsonToken) = Enum::"NPR Ecom Sales Line Type"::Voucher then
            exit(true);
        ResolveShopifyItem(ShopifyStoreCode, SalesLineJsonToken, ShopifyOrderLineId, ItemVariant, Item);
        If DetermineItemSubtype(Item) in [Enum::"NPR Ecom Sales Line Subtype"::Membership, Enum::"NPR Ecom Sales Line Subtype"::Ticket, Enum::"NPR Ecom Sales Line Subtype"::Voucher] then
            exit(true);
        exit(false);
    end;

    internal procedure OrderLineIsVirtualItem(ShopifyStoreCode: Code[20]; SalesLineJsonToken: JsonToken; ShopifyOrderLineId: Text): Boolean
    var
        ItemVariant: Record "Item Variant";
    begin
        exit(OrderLineIsVirtualItem(ShopifyStoreCode, SalesLineJsonToken, ShopifyOrderLineId, ItemVariant));
    end;

    local procedure IsVirtualLineChanged(TempBuffer: Record "NPR Spfy Fulfillment Buffer" temporary; SalesLine: Record "Sales Line"; SalesLineJsonToken: JsonToken): Boolean
    begin
        if SalesLine.Quantity <> TempBuffer."Fulfilled Quantity" then
            exit(true);

        if SalesLine."Line Discount Amount" <> CalcLineDiscountAmount(SalesLineJsonToken, SalesLine) then
            exit(true);

        GetGLSetup();
        if Round(SalesLine."Unit Price", GLSetup."Unit-Amount Rounding Precision") <> Round(JsonHelper.GetJDecimal(SalesLineJsonToken, 'originalUnitPriceSet.presentmentMoney.amount', true), GLSetup."Unit-Amount Rounding Precision") then
            exit(true);

        exit(false);
    end;

    internal procedure GetGLSetup()
    begin
        if GLSetupRetrieved then
            exit;

        GLSetup.Get();
        GLSetupRetrieved := true;
    end;

    local procedure ProcessShippingLine(ShippingLineJsonToken: JsonToken; SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        ShipmentFee: Decimal;
    begin
        ShipmentFee := JsonHelper.GetJDecimal(ShippingLineJsonToken, 'originalPriceSet.presentmentMoney.amount', false);
        if ShipmentFee = 0 then
            exit;

        if not GetShippingLineAssignedId(ShippingLineJsonToken, ShopifyAssignedID) then begin
            if AddNewShippingLine(SalesLine, ShippingLineJsonToken, SalesHeader) then
                exit;
        end;

        SalesLine.Get(ShopifyAssignedID."BC Record ID");
        SetQtyAndPriceShippingLine(SalesLine, ShipmentFee, ShippingLineJsonToken);
        SalesLine.Modify(true);
        SpfyIntegrationEvents.OnAfterUpdateSalesLineShipmentFee(SalesHeader, SalesLine, false);
    end;

    local procedure GetShippingLineAssignedId(ShippingLineJsonToken: JsonToken; var ShopifyAssignedID: Record "NPR Spfy Assigned ID"): Boolean
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"Sales Line", "NPR Spfy ID Type"::"Entry ID", OrderMgt.GetNumericId(JsonHelper.GetJText(ShippingLineJsonToken, 'id', true)), ShopifyAssignedID);
        exit(ShopifyAssignedID.FindFirst());
    end;

    local procedure AddNewShippingLine(SalesLine: Record "Sales Line"; ShippingLineJsonToken: JsonToken; SalesHeader: Record "Sales Header"): Boolean
    var
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        ShipmentFee: Decimal;
        ShipmentFeeTitle: Text;
        DeliveryLocationId: Code[50];
    begin
        InitNewSalesLine(SalesLine, SalesHeader);

        ShipmentFee := JsonHelper.GetJDecimal(ShippingLineJsonToken, 'originalPriceSet.presentmentMoney.amount', false);
        OrderMgt.FindShipmentMapping(ShippingLineJsonToken, ShipmentMapping, DeliveryLocationId);
        ShipmentMapping.TestField("Shipment Fee No.");
        ShipmentFeeTitle := JsonHelper.GetJText(ShippingLineJsonToken, 'title', false);
        case ShipmentMapping."Shipment Fee Type" of
            ShipmentMapping."Shipment Fee Type"::"G/L Account":
                SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
            ShipmentMapping."Shipment Fee Type"::Item:
                SalesLine.Validate(Type, SalesLine.Type::Item);
            ShipmentMapping."Shipment Fee Type"::Resource:
                SalesLine.Validate(Type, SalesLine.Type::Resource);
            ShipmentMapping."Shipment Fee Type"::"Fixed Asset":
                SalesLine.Validate(Type, SalesLine.Type::"Fixed Asset");
            ShipmentMapping."Shipment Fee Type"::"Charge (Item)":
                SalesLine.Validate(Type, SalesLine.Type::"Charge (Item)");
        end;
        SalesLine.Validate("No.", ShipmentMapping."Shipment Fee No.");
        SalesLine.Validate(Quantity, 1);
        SetQtyAndPriceShippingLine(SalesLine, ShipmentFee, ShippingLineJsonToken);
        SalesLine.Validate("VAT %", CalculateVAT(ShippingLineJsonToken));
        if ShipmentFeeTitle <> '' then begin
            SalesLine.Description := CopyStr(ShipmentFeeTitle, 1, MaxStrLen(SalesLine.Description));
            SalesLine."Description 2" := CopyStr(ShipmentFeeTitle, MaxStrLen(SalesLine.Description) + 1, MaxStrLen(SalesLine."Description 2"));
        end;
        SalesLine.Modify(true);
        SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", OrderMgt.GetNumericId(JsonHelper.GetJText(ShippingLineJsonToken, 'id', true)), false);
        SpfyIntegrationEvents.OnAfterUpdateSalesLineShipmentFee(SalesHeader, SalesLine, true);
        exit(true);
    end;

    local procedure SetQtyAndPriceShippingLine(var SalesLine: Record "Sales Line"; ShipmentFee: Decimal; ShippingLineJsonToken: JsonToken)
    var
        LineDiscountAmount: Decimal;
    begin
        SalesLine.Validate("Qty. to Ship", SalesLine."Outstanding Quantity");
        SalesLine.Validate("Qty. to Invoice", SalesLine."Outstanding Quantity");
        if SalesLine."Unit Price" <> ShipmentFee then
            SalesLine.Validate("Unit Price", ShipmentFee);
        LineDiscountAmount := CalcLineDiscountAmount(ShippingLineJsonToken, SalesLine);
        if SalesLine."Line Discount Amount" <> LineDiscountAmount then
            SalesLine.Validate("Line Discount Amount", LineDiscountAmount);
    end;

    local procedure GetSalesLinesJsonToken(var SalesLinesJsonToken: JsonToken; Response: JsonToken)
    begin
        SalesLinesJsonToken := JsonHelper.GetJsonToken(Response, 'data.order.lineItems');
        if (not SalesLinesJsonToken.IsArray()) then
            Error(NoArrayErr, 'lineItems');
    end;

    local procedure ProcessEcommerceSalesLine(SalesLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry"; var FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache")
    var
        LineType: Enum "NPR Ecom Sales Line Type";
    begin
        LineType := EvaluateLineType(SalesLineJsonToken);
        InsertEcommerceSalesLine(SalesLineJsonToken, EcomSalesHeader, LogEntry, LineType, FulfillmentCache);
    end;

    local procedure IsProductRemoved(SalesLineJsonToken: JsonToken): Boolean
    var
        Handled: Boolean;
        Skip: Boolean;
    begin
        SpfyIntegrationEvents.OnCheckIfSkipLine(SalesLineJsonToken, Skip, Handled);
        if not Handled then
            Skip := _SpfyAPIOrderHelper.LineIsNoLongerOnOrder(SalesLineJsonToken);
        exit(Skip);
    end;

    local procedure InsertEcommerceSalesLine(SalesLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry"; LineType: Enum "NPR Ecom Sales Line Type"; var FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache")
    var
        IncEcomSalesLine: Record "NPR Ecom Sales Line";
        PropertyDict: Dictionary of [Text, Text];
    begin
        IncEcomSalesLine.Init();
        IncEcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        IncEcomSalesLine."External Document No." := EcomSalesHeader."External No.";
        IncEcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        IncEcomSalesLine.Type := LineType;
        IncEcomSalesLine."Line No." := _IncEcomSalesDocUtils.GetSalesDocLastSalesLineLineNo(EcomSalesHeader) + 10000;
        ParseEcommerceSalesLine(EcomSalesHeader, SalesLineJsonToken, IncEcomSalesLine, LogEntry, PropertyDict, FulfillmentCache);
        SpfyIntegrationEvents.OnBeforeInsertEcommerceSalesLine(SalesLineJsonToken, EcomSalesHeader, IncEcomSalesLine);
        IncEcomSalesLine.Insert(true);
        if IncEcomSalesLine.Type = IncEcomSalesLine.Type::Voucher then
            ReserveVouchers(EcomSalesHeader, IncEcomSalesLine, PropertyDict, FulfillmentCache);
    end;

    local procedure SetTicketReservationLineId(SalesLineJsonToken: JsonToken; var EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        TicketReservationLineId: Guid;
        ShopifyLineItemGid: Text;
        MissingReservationLineErr: Label 'No ticket reservation line was found for Shopify line item "%1". The order cannot be imported until ticket processing provides a reservation line for every ticket line.', Comment = '%1 = Shopify line item GID';
    begin
        ShopifyLineItemGid := JsonHelper.GetJText(SalesLineJsonToken, 'id', true);

        if not _TicketReservationLineIds.Get(ShopifyLineItemGid, TicketReservationLineId) then
            Error(MissingReservationLineErr, ShopifyLineItemGid);

        EcomSalesLine."Ticket Reservation Line Id" := TicketReservationLineId;
    end;

    local procedure PopulateItemLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesLineJsonToken: JsonToken; var IncEcomSalesLine: Record "NPR Ecom Sales Line"; LogEntry: Record "NPR Spfy Event Log Entry"; var FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache")
    begin
        ResolveItem(LogEntry."Store Code", SalesLineJsonToken, IncEcomSalesLine);

        case IncEcomSalesLine.Subtype of
            IncEcomSalesLine.Subtype::Item:
                DeserializeItemLine(EcomSalesHeader, SalesLineJsonToken, IncEcomSalesLine, LogEntry, FulfillmentCache);
            IncEcomSalesLine.Subtype::Ticket:
                DeserializeTicketLine(EcomSalesHeader, SalesLineJsonToken, IncEcomSalesLine, LogEntry, FulfillmentCache);
            IncEcomSalesLine.Subtype::Membership:
                DeserializeMembershipLine(EcomSalesHeader, SalesLineJsonToken, IncEcomSalesLine, LogEntry);
        end;
    end;

    local procedure ResolveItem(ShopifyStoreCode: Code[20]; SalesLineJsonToken: JsonToken; var EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        ResolveShopifyItem(ShopifyStoreCode, SalesLineJsonToken, EcomSalesLine."Shopify ID", ItemVariant, Item);

        EcomSalesLine."No." := ItemVariant."Item No.";
        EcomSalesLine."Variant Code" := ItemVariant.Code;
        EcomSalesLine.Subtype := DetermineItemSubtype(Item);
    end;

    local procedure ResolveShopifyItem(ShopifyStoreCode: Code[20]; SalesLineJsonToken: JsonToken; ShopifyLineId: Text; var ItemVariant: Record "Item Variant"; var Item: Record Item)
    var
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        Sku: Text;
        UnknownIdErr: Label 'Unknown %1: %2%3';
    begin
        if not SpfyItemMgt.ParseItemForDocumentImport(ShopifyStoreCode, SalesLineJsonToken, ItemVariant, Item, Sku) then
            Error(UnknownIdErr, 'sku', Sku, StrSubstNo(' (line ID: %1, name: %2)', ShopifyLineId, JsonHelper.GetJText(SalesLineJsonToken, 'name', false)));
    end;

    local procedure DeserializeTicketLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesLineJsonToken: JsonToken; var EcomSalesLine: Record "NPR Ecom Sales Line"; LogEntry: Record "NPR Spfy Event Log Entry"; var FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache")
    begin
        DeserializeItemLine(EcomSalesHeader, SalesLineJsonToken, EcomSalesLine, LogEntry, FulfillmentCache);
        SetTicketReservationLineId(SalesLineJsonToken, EcomSalesLine);
    end;

    local procedure DeserializeItemLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesLineJsonToken: JsonToken; var IncEcomSalesLine: Record "NPR Ecom Sales Line"; LogEntry: Record "NPR Spfy Event Log Entry"; var FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache")
    var
        TempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
    begin
        if not FulfillmentCache.GetLineFromCache(IncEcomSalesLine."Shopify ID", TempSpfyFulfillmentBuffer) then
            TempSpfyFulfillmentBuffer.Init();
#pragma warning disable AA0139
        IncEcomSalesLine.Quantity := _SpfyAPIOrderHelper.LineOpenQuantity(SalesLineJsonToken) + TempSpfyFulfillmentBuffer."Fulfilled Quantity";
        IncEcomSalesLine.Description := JsonHelper.GetJText(SalesLineJsonToken, 'title', MaxStrLen(IncEcomSalesLine.Description), true);
        IncEcomSalesLine."Description 2" := JsonHelper.GetJText(SalesLineJsonToken, 'variantTitle', MaxStrLen(IncEcomSalesLine."Description 2"), false);
        PopulateAmounts(EcomSalesHeader, SalesLineJsonToken, IncEcomSalesLine, LogEntry);
#pragma warning restore AA0139
    end;

    local procedure PopulateVoucherAmounts(SalesLineJsonToken: JsonToken; var EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        ActualUnitPrice: Decimal;
        VoucherUnitPrice: Decimal;
        LineDiscountAmount: Decimal;
        TotalQty: Decimal;
    begin
        TotalQty := _SpfyAPIOrderHelper.LineDiscountBaseQuantity(SalesLineJsonToken);
        ActualUnitPrice := JsonHelper.GetJDecimal(SalesLineJsonToken, 'originalUnitPriceSet.presentmentMoney.amount', true);
        VoucherUnitPrice := GetVoucherPriceInPresentmentCurrency(SalesLineJsonToken);

        LineDiscountAmount := CalcLineDiscountAmount(SalesLineJsonToken, EcomSalesLine, TotalQty);

        if VoucherUnitPrice < ActualUnitPrice then
            VoucherUnitPrice := ActualUnitPrice;

        if VoucherUnitPrice > ActualUnitPrice then
            LineDiscountAmount += Round((VoucherUnitPrice - ActualUnitPrice) * EcomSalesLine.Quantity, GLSetup."Amount Rounding Precision");

        EcomSalesLine."Unit Price" := VoucherUnitPrice;
        EcomSalesLine."Line Discount Amount" := LineDiscountAmount;
        EcomSalesLine."Line Amount" := EcomSalesLine."Unit Price" * EcomSalesLine.Quantity - EcomSalesLine."Line Discount Amount";
        EcomSalesLine."VAT %" := CalculateVAT(SalesLineJsonToken);
    end;

    local procedure GetVoucherPriceInPresentmentCurrency(SalesLineJsonToken: JsonToken): Decimal
    var
        VariantPriceInShopCurrency: Decimal;
        LinePriceInShopCurrency: Decimal;
        LinePriceInPresentmentCurrency: Decimal;
    begin
        GetGLSetup();
        VariantPriceInShopCurrency := JsonHelper.GetJDecimal(SalesLineJsonToken, 'variant.price', true);
        LinePriceInShopCurrency := JsonHelper.GetJDecimal(SalesLineJsonToken, 'originalUnitPriceSet.shopMoney.amount', true);
        LinePriceInPresentmentCurrency := JsonHelper.GetJDecimal(SalesLineJsonToken, 'originalUnitPriceSet.presentmentMoney.amount', true);
        if LinePriceInShopCurrency = 0 then
            exit(LinePriceInPresentmentCurrency);
        exit(Round(VariantPriceInShopCurrency * LinePriceInPresentmentCurrency / LinePriceInShopCurrency, GLSetup."Unit-Amount Rounding Precision"));
    end;

    local procedure DeserializeMembershipLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesLineJsonToken: JsonToken; var IncEcomSalesLine: Record "NPR Ecom Sales Line"; LogEntry: Record "NPR Spfy Event Log Entry")
    var
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        PropertyDict: Dictionary of [Text, Text];
    begin
        OrderMgt.GetOrderLineProperties(SalesLineJsonToken, PropertyDict, 'customAttributes', 'key');

        // An alteration line names the membership and the alteration option it acts on; a creation line names
        // neither. DetermineMembershipOperation tells the two apart by "Membership Id" and picks the alteration
        // type from "Alteration Option System Id", so both have to be read off the line before it is called.
        ParseMembershipAlterationFields(PropertyDict, IncEcomSalesLine);

        IncEcomSalesLine."Membership Operation" := EcomCreateMMShipImpl.DetermineMembershipOperation(IncEcomSalesLine);
        if IncEcomSalesLine."Membership Operation" = IncEcomSalesLine."Membership Operation"::CreateMembership then
#pragma warning disable AA0139
            ParseMemberCreationFields(PropertyDict, IncEcomSalesLine);

        // Membership lines are not fulfillment-driven, so they take the ordered quantity directly rather than
        // going through the fulfillment cache the item and ticket paths use.
        IncEcomSalesLine.Quantity := JsonHelper.GetJDecimal(SalesLineJsonToken, 'currentQuantity', true);
        IncEcomSalesLine.Description := JsonHelper.GetJText(SalesLineJsonToken, 'title', MaxStrLen(IncEcomSalesLine.Description), true);
        IncEcomSalesLine."Description 2" := JsonHelper.GetJText(SalesLineJsonToken, 'variantTitle', MaxStrLen(IncEcomSalesLine."Description 2"), false);
        PopulateAmounts(EcomSalesHeader, SalesLineJsonToken, IncEcomSalesLine, LogEntry);
#pragma warning restore AA0139
    end;

    local procedure ParseMembershipAlterationFields(var PropertyDict: Dictionary of [Text, Text]; var EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        PropertyValue: Text;
        InvalidAlterationOptionIdErr: Label 'The membership alteration option id ''%1'' is not a valid id.', Comment = '%1 - alteration option id received from Shopify';
        InvalidMembershipIdErr: Label 'The membership id ''%1'' is not a valid id.', Comment = '%1 - membership id received from Shopify';
    begin
        // GetOrderLineProperties strips the leading underscore Shopify uses to hide an attribute from the
        // customer and lowercases the key, so '_membershipId' and '_optionId' arrive here as shown below.
        if PropertyDict.Get('membershipid', PropertyValue) and (PropertyValue <> '') then
            if not Evaluate(EcomSalesLine."Membership Id", PropertyValue) then
                Error(InvalidMembershipIdErr, PropertyValue);

        if PropertyDict.Get('optionid', PropertyValue) and (PropertyValue <> '') then
            if not Evaluate(EcomSalesLine."Alteration Option System Id", PropertyValue) then
                Error(InvalidAlterationOptionIdErr, PropertyValue);
    end;

    local procedure ParseMemberCreationFields(var PropertyDict: Dictionary of [Text, Text]; var EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        PropertyKey: Text;
        PropertyValue: Text;
        InvalidBirthdayErr: Label 'The member date of birth is not a valid date.';
    begin
        if PropertyDict.Count() = 0 then
            exit;

        foreach PropertyKey in PropertyDict.Keys() do begin
            PropertyValue := PropertyDict.Get(PropertyKey);
            if PropertyValue <> '' then
                case PropertyKey of
                    'first_name':
                        EcomSalesLine."Member First Name" := CopyStr(PropertyValue, 1, MaxStrLen(EcomSalesLine."Member First Name"));
                    'last_name':
                        EcomSalesLine."Member Last Name" := CopyStr(PropertyValue, 1, MaxStrLen(EcomSalesLine."Member Last Name"));
                    'email':
                        EcomSalesLine."Member Email" := CopyStr(PropertyValue, 1, MaxStrLen(EcomSalesLine."Member Email"));
                    'phone':
                        EcomSalesLine."Member Phone No." := CopyStr(PropertyValue, 1, MaxStrLen(EcomSalesLine."Member Phone No."));
                    'city':
                        EcomSalesLine."Member City" := CopyStr(PropertyValue, 1, MaxStrLen(EcomSalesLine."Member City"));
                    'zip_code':
                        EcomSalesLine."Member Post Code" := CopyStr(PropertyValue, 1, MaxStrLen(EcomSalesLine."Member Post Code"));
                    'country':
                        EcomSalesLine."Member Country" := CopyStr(PropertyValue, 1, MaxStrLen(EcomSalesLine."Member Country"));
                    'date_of_birth':
                        if not Evaluate(EcomSalesLine."Member Birthday", PropertyValue, 9) then
                            Error(InvalidBirthdayErr);

                end;
        end;
    end;

    local procedure PopulateVoucherLine(SalesLineJsonToken: JsonToken; var IncEcomSalesLine: Record "NPR Ecom Sales Line"; LogEntry: Record "NPR Spfy Event Log Entry"; var PropertyDict: Dictionary of [Text, Text])
    var
        VoucherType: Record "NPR NpRv Voucher Type";
    begin
        OrderMgt.GetOrderLineProperties(SalesLineJsonToken, PropertyDict, 'customAttributes', 'key');
        OrderMgt.GetVoucherType(LogEntry."Store Code", PropertyDict, VoucherType);
        VoucherType.TestField("Reference No. Pattern");
        IncEcomSalesLine.Subtype := IncEcomSalesLine.Subtype::Voucher;
        IncEcomSalesLine."Voucher Type" := VoucherType.Code;
        IncEcomSalesLine.Description := CopyStr(JsonHelper.GetJText(SalesLineJsonToken, 'name', MaxStrLen(IncEcomSalesLine.Description), false), 1, MaxStrLen(IncEcomSalesLine.Description));
        IncEcomSalesLine.Quantity := _SpfyAPIOrderHelper.LineOrderedQuantity(SalesLineJsonToken);
        PopulateVoucherAmounts(SalesLineJsonToken, IncEcomSalesLine);
    end;

    local procedure ReserveVouchers(EcomSalesHeader: Record "NPR Ecom Sales Header"; IncEcomSalesLine: Record "NPR Ecom Sales Line"; PropertyDict: Dictionary of [Text, Text]; var FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache")
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        ReferenceNo: Code[50];
        GiftCardId: Text[30];
        Qty: Integer;
        i: Integer;
    begin
        if IncEcomSalesLine."Voucher Type" = '' then
            exit;

        VoucherType.Get(IncEcomSalesLine."Voucher Type");
        Qty := IncEcomSalesLine.Quantity;

        for i := 1 to Qty do begin
            Clear(ReferenceNo);
            Clear(GiftCardId);
            FulfillmentCache.GetVocherReferenceNo(IncEcomSalesLine."Shopify ID", ReferenceNo, GiftCardId);
            ReserveVoucher(EcomSalesHeader, IncEcomSalesLine, VoucherType, PropertyDict, ReferenceNo, GiftCardId);
        end;
    end;

    local procedure ReserveVoucher(EcomSalesHeader: Record "NPR Ecom Sales Header"; IncEcomSalesLine: Record "NPR Ecom Sales Line"; VoucherType: Record "NPR NpRv Voucher Type"; PropertyDict: Dictionary of [Text, Text]; ReferenceNo: Code[50]; GiftCardId: Text[30])
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Voucher: Record "NPR NpRv Voucher";
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
        SpfySuspendVouchRefVal: Codeunit "NPR Spfy Suspend Vouch.Ref.Val";
        VoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        EcomCreateVchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        IsTopUp: Boolean;
    begin
        IsTopUp := ResolveTopUpVoucher(GiftCardId, Voucher);

        if not IsTopUp then begin
            VoucherMgt.CheckVoucherTypeQty(VoucherType);
            BindSubscription(SpfySuspendVouchRefVal);
            VoucherMgt.InitVoucher(VoucherType, '', ReferenceNo, 0DT, false, Voucher);
            UnbindSubscription(SpfySuspendVouchRefVal);
        end;

        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        if IsTopUp then
            NpRvSalesLine.Type := NpRvSalesLine.Type::"Top-up"
        else
            NpRvSalesLine.Type := NpRvSalesLine.Type::"New Voucher";
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
        NpRvSalesLine."Voucher Type" := VoucherType.Code;
        NpRvSalesLine."Voucher No." := Voucher."No.";
        NpRvSalesLine."Reference No." := Voucher."Reference No.";
        NpRvSalesLine."NPR Inc Ecom Sales Line Id" := IncEcomSalesLine.SystemId;
#pragma warning disable AA0139
        NpRvSalesLine."External Document No." := EcomSalesHeader."External No.";
#pragma warning restore AA0139
        NpRvSalesLine.Amount := EcomCreateVchrImpl.CalculateVoucherFaceValueLCY(EcomSalesHeader, IncEcomSalesLine);
        NpRvSalesLine.Description := CopyStr(IncEcomSalesLine.Description, 1, MaxStrLen(NpRvSalesLine.Description));
        NpRvSalesLine."Spfy Initiated in Shopify" := not CheckIsNpGiftCard(PropertyDict);
        NpRvSalesLine."Spfy Gift Card ID" := GiftCardId;
        NpRvSalesLine.Validate("Customer No.", EcomSalesHeader."Sell-to Customer No.");
        if PropertyDict.Count <> 0 then
            OrderMgt.UpdateVoucherRecipient(PropertyDict, not NpRvSalesLine."Spfy Initiated in Shopify", NpRvSalesLine);
        NpRvSalesLine.UpdateIsSendViaEmail();
        NpRvSalesLine.Insert();

        NpRvSalesDocMgt.InsertNpRVSalesLineReference(NpRvSalesLine, Voucher);
    end;

    internal procedure ResolveTopUpVoucher(GiftCardId: Text[30]; var Voucher: Record "NPR NpRv Voucher"): Boolean
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        if GiftCardId = '' then
            exit(false);
        SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"NPR NpRv Voucher", "NPR Spfy ID Type"::"Entry ID", GiftCardId, ShopifyAssignedID);
        if not ShopifyAssignedID.FindLast() then
            exit(false);
        exit(Voucher.Get(ShopifyAssignedID."BC Record ID"));
    end;

    local procedure PopulateAmounts(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesLineJsonToken: JsonToken; var IncEcomSalesLine: Record "NPR Ecom Sales Line"; LogEntry: Record "NPR Spfy Event Log Entry")
    var
        TotalQty: Decimal;
    begin
        TotalQty := _SpfyAPIOrderHelper.LineDiscountBaseQuantity(SalesLineJsonToken);
        SetOrderLineUnitPriceAndDiscount(EcomSalesHeader, LogEntry."Store Code", JsonHelper.GetJDecimal(SalesLineJsonToken, 'originalUnitPriceSet.presentmentMoney.amount', true),
            CalcLineDiscountAmount(SalesLineJsonToken, IncEcomSalesLine, TotalQty), IncEcomSalesLine);
        IncEcomSalesLine."Line Amount" := IncEcomSalesLine."Unit Price" * IncEcomSalesLine.Quantity - IncEcomSalesLine."Line Discount Amount";
        IncEcomSalesLine."VAT %" := CalculateVAT(SalesLineJsonToken);
    end;


    internal procedure CalculateVAT(SalesLineJsonToken: JsonToken) VATP: Decimal
    var
        TaxLine: JsonToken;
        TaxLines: JsonToken;
    begin
        TaxLines := JsonHelper.GetJsonToken(SalesLineJsonToken, 'taxLines');
        if TaxLines.AsArray().Count = 0 then
            exit;

        foreach TaxLine in TaxLines.AsArray() do
            if JsonHelper.GetJDecimal(TaxLine, 'priceSet.presentmentMoney.amount', false) <> 0 then
                VATP += JsonHelper.GetJDecimal(TaxLine, 'ratePercentage', false);
    end;

    local procedure PopulateShipmentFeeLine(ShippingLineJsonToken: JsonToken; var IncEcomSalesLine: Record "NPR Ecom Sales Line")
    var
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        DeliveryLocationId: Code[50];
        ShipmentFee: Decimal;
        ShipmentFeeTitle: Text;
    begin
        ShipmentFee := JsonHelper.GetJDecimal(ShippingLineJsonToken, 'originalPriceSet.presentmentMoney.amount', false);
        OrderMgt.FindShipmentMapping(ShippingLineJsonToken, ShipmentMapping, DeliveryLocationId);
        ShipmentMapping.TestField("Shipment Fee No.");
        ShipmentFeeTitle := JsonHelper.GetJText(ShippingLineJsonToken, 'title', false);
        IncEcomSalesLine."No." := ShipmentMapping."External Shipment Method Code";
        if IncEcomSalesLine."No." = '' then
#pragma warning disable AA0139
            IncEcomSalesLine."No." := JsonHelper.GetJText(ShippingLineJsonToken, 'code', false);
#pragma warning restore AA0139
        IncEcomSalesLine.Quantity := 1;
        IncEcomSalesLine."Unit Price" := ShipmentFee;
        IncEcomSalesLine."Line Discount Amount" := CalcLineDiscountAmount(ShippingLineJsonToken);
        IncEcomSalesLine."Line Amount" := IncEcomSalesLine."Unit Price" * IncEcomSalesLine.Quantity - IncEcomSalesLine."Line Discount Amount";
        if ShipmentFeeTitle <> '' then begin
            IncEcomSalesLine.Description := CopyStr(ShipmentFeeTitle, 1, MaxStrLen(IncEcomSalesLine.Description));
            IncEcomSalesLine."Description 2" := CopyStr(ShipmentFeeTitle, MaxStrLen(IncEcomSalesLine.Description) + 1, MaxStrLen(IncEcomSalesLine."Description 2"));
        end;
        IncEcomSalesLine."VAT %" := CalculateVAT(ShippingLineJsonToken);
    end;

    local procedure ProcessEcommerceComment(OrderToken: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header");
    var
        RecordLink: Record "Record Link";
        RecordLinkManagement: Codeunit "Record Link Management";
        LinkID: Integer;
        CommentLine: Text;
        Note: Text;
    begin
        CommentLine := JsonHelper.GetJText(OrderToken, 'data.order.note', false);
        if CommentLine = '' then
            exit;

        LinkID := EcomSalesHeader.AddLink('', EcomSalesHeader."External No.");
        RecordLink.Get(LinkID);
        RecordLink.Type := RecordLink.Type::Note;
        RecordLink."User ID" := SpfyIntegrationMgt.DataProcessingHandlerID(true);
        Note := CommentLine;

        RecordLinkManagement.WriteNote(RecordLink, Note);
        RecordLink.Modify(true);
    end;

    local procedure ParseEcommerceSalesLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesLineJsonToken: JsonToken; var IncEcomSalesLine: Record "NPR Ecom Sales Line"; LogEntry: Record "NPR Spfy Event Log Entry"; var PropertyDict: Dictionary of [Text, Text]; var FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache")
    var
        NotSupportedLineTypeErr: Label '%1 %2 is not supported', Comment = '%1=IncEcomSalesLine.FieldCaption(Type);%2=IncEcomSalesLine.Type';
    begin
        IncEcomSalesLine."Shopify ID" := OrderMgt.GetNumericId(JsonHelper.GetJText(SalesLineJsonToken, 'id', true));

        case IncEcomSalesLine.Type of
            IncEcomSalesLine.Type::Item:
                PopulateItemLine(EcomSalesHeader, SalesLineJsonToken, IncEcomSalesLine, LogEntry, FulfillmentCache);
            IncEcomSalesLine.Type::Voucher:
                PopulateVoucherLine(SalesLineJsonToken, IncEcomSalesLine, LogEntry, PropertyDict);
            IncEcomSalesLine.Type::"Shipment Fee":
                PopulateShipmentFeeLine(SalesLineJsonToken, IncEcomSalesLine);
            else
                Error(NotSupportedLineTypeErr, IncEcomSalesLine.FieldCaption(Type), Format(IncEcomSalesLine.Type));
        end;

        SpfyIntegrationEvents.OnAfterParseEcommerceSalesLine(SalesLineJsonToken, IncEcomSalesLine);
    end;

    local procedure EvaluateLineType(SalesLineJsonToken: JsonToken) LineType: Enum "NPR Ecom Sales Line Type";
    begin
        if _SpfyAPIOrderHelper.OrderLineIsGiftCard(SalesLineJsonToken) then
            exit(LineType::Voucher);
        exit(LineType::Item);
    end;

    local procedure DetermineItemSubtype(Item: Record Item) Subtype: Enum "NPR Ecom Sales Line Subtype"
    var
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
    begin
        if Item."No." = '' then
            exit(Subtype::Item);

        if EcomVirtualItemMgt.IsTicketLine(Item) then
            exit(Subtype::Ticket);

        if EcomVirtualItemMgt.IsMembershipLine(Item."No.") then
            exit(Subtype::Membership);

        exit(Subtype::Item);
    end;

    local procedure CheckIsNpGiftCard(PropertyDict: Dictionary of [Text, Text]): Boolean
    var
        PropertyValue: Text;
    begin
        if not PropertyDict.Get('is_giftcard', PropertyValue) then
            exit(false);
        exit(PropertyValue <> '0');
    end;


    //Create path skips the check, because the SalesLine amounts differ from raw JSON amounts by design of the fold.
    local procedure SetOrderLineUnitPriceAndDiscount(EcomSalesHeader: Record "NPR Ecom Sales Header"; ShopifyStoreCode: Code[20]; ActualUnitPrice: Decimal; LineDiscountAmount: Decimal; var IncEcomSalesLine: Record "NPR Ecom Sales Line")
    var
        SpfyProductPriceCalc: Codeunit "NPR Spfy Product Price Calc.";
        LineUnitPrice: Decimal;
        CompareAtPrice: Decimal;
        IsItem: Boolean;
    begin
        IsItem := IncEcomSalesLine.Type = IncEcomSalesLine.Type::Item;
        if IsItem and (SpfyIntegrationMgt.OrderLineSalesPriceType(ShopifyStoreCode) = Enum::"NPR Spfy Order Line Price Type"::"Compare-at-Price") then
#pragma warning disable AA0139
            CompareAtPrice := SpfyProductPriceCalc.CalcCompareAtPrice(ShopifyStoreCode, EcomSalesHeader."Currency Code", IncEcomSalesLine."No.", IncEcomSalesLine."Variant Code", EcomSalesHeader."Received Date");
#pragma warning restore AA0139
        LineUnitPrice := OrderMgt.ResolveUnitPriceAndDiscount(IsItem, CompareAtPrice, ActualUnitPrice, IncEcomSalesLine.Quantity, LineDiscountAmount);

        GetGLSetup();
        if Round(IncEcomSalesLine."Unit Price", GLSetup."Unit-Amount Rounding Precision") <> Round(LineUnitPrice, GLSetup."Unit-Amount Rounding Precision") then
            IncEcomSalesLine."Unit Price" := LineUnitPrice;

        if IncEcomSalesLine."Unit Price" <> 0 then
            if Round(IncEcomSalesLine."Line Discount Amount", GLSetup."Amount Rounding Precision") <> Round(LineDiscountAmount, GLSetup."Amount Rounding Precision") then
                IncEcomSalesLine."Line Discount Amount" := LineDiscountAmount;
    end;

    local procedure CalcLineDiscountAmount(OrderLine: JsonToken; IncEcomSalesLine: Record "NPR Ecom Sales Line"; OriginalOrderQty: Decimal): Decimal
    begin
        exit(CalcProratedLineDiscount(OrderLine, IncEcomSalesLine.Quantity, OriginalOrderQty));
    end;

    internal procedure CalcLineDiscountAmount(OrderLine: JsonToken) LineDiscountAmount: Decimal
    var
        Discount: JsonToken;
        Discounts: JsonToken;
    begin
        LineDiscountAmount := 0;
        if OrderLine.SelectToken('discountAllocations', Discounts) and Discounts.IsArray() then
            foreach Discount in Discounts.AsArray() do
                LineDiscountAmount += JsonHelper.GetJDecimal(Discount, 'allocatedAmountSet.presentmentMoney.amount', false);

        exit(LineDiscountAmount);
    end;

    internal procedure CalcProratedLineDiscount(OrderLine: JsonToken; LineQty: Decimal; OriginalOrderQty: Decimal) LineDiscountAmount: Decimal
    begin
        LineDiscountAmount := CalcLineDiscountAmount(OrderLine);
        if (LineDiscountAmount = 0) or (OriginalOrderQty = 0) or (LineQty >= OriginalOrderQty) then
            exit;

        LineDiscountAmount := LineDiscountAmount / OriginalOrderQty * LineQty;
    end;

    internal procedure InitEcommerceHeader(LogEntry: Record "NPR Spfy Event Log Entry"; var EcomSalesHeader: Record "NPR Ecom Sales Header"; Response: JsonToken)
    var
        SpfyAPIEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
        OrderToken: JsonToken;
    begin
        Response.SelectToken('data.order', OrderToken);
        EcomSalesHeader.Init();
        EcomSalesHeader."Document Type" := MapDocumentType(LogEntry);
#pragma warning disable AA0139
        EcomSalesHeader."External No." := LogEntry."Shopify ID";
#pragma warning restore AA0139
        EcomSalesHeader."Ecommerce Store Code" := FindNpEcStore(LogEntry."Store Code", OrderToken);
        EcomSalesHeader."External Document No." := CopyStr(
            SpfyIntegrationMgt.BuildExternalDocumentNo(
                LogEntry."Store Code",
                _SpfyAPIOrderHelper.GetOrderNo(OrderToken, 0),
                _SpfyAPIOrderHelper.GetOrderName(OrderToken, MaxStrLen(EcomSalesHeader."External Document No.")),
                MaxStrLen(EcomSalesHeader."External Document No.")),
            1, MaxStrLen(EcomSalesHeader."External Document No."));
        EcomSalesHeader."Document Source" := EcomSalesHeader."Document Source"::"Shopify";

        if SpfyPaymentGatewayHdlr.IsLCY(LogEntry."Presentment Currency Code") then begin
            if not SpfyIntegrationMgt.CurrencyBlankForLCY(LogEntry."Store Code") then
                EcomSalesHeader."Currency Code" := LogEntry."Presentment Currency Code";
            if EcomSalesHeader."Currency Code" <> '' then
                EcomSalesHeader."Currency Exchange Rate" := 1;
        end else begin
            EcomSalesHeader."Currency Code" := LogEntry."Presentment Currency Code";
            EcomSalesHeader."Currency Exchange Rate" := SpfyAPIEventLogMgt.GetCurrencyFactor(LogEntry);
        end;

        if LogEntry."Closed Date-Time" < LogEntry."Event Date-Time" then begin
            EcomSalesHeader."Received Date" := DT2Date(LogEntry."Event Date-Time");
            EcomSalesHeader."Received Time" := DT2Time(LogEntry."Event Date-Time");
        end else begin
            EcomSalesHeader."Received Date" := DT2Date(LogEntry."Closed Date-Time");
            EcomSalesHeader."Received Time" := DT2Time(LogEntry."Closed Date-Time");
        end;
    end;

    internal procedure MapDocumentType(LogEntry: Record "NPR Spfy Event Log Entry") IncDocType: Enum "NPR Ecom Sales Doc Type"
    var
        NotMappedTypeErr: Label 'The Document Type %1 is not mapped to the Incoming Ecommerce Document Type.';
    begin
        case true of
            LogEntry."Document Type" = LogEntry."Document Type"::Order:
                exit(IncDocType::Order);
            LogEntry."Document Type" = LogEntry."Document Type"::"Return Order":
                exit(IncDocType::"Return Order");
            else
                Error(NotMappedTypeErr, Format(LogEntry."Document Type"));
        end;
    end;

    local procedure FindCustomer(NpEcStore: Record "NPR NpEc Store"; Order: JsonToken; var Customer: Record Customer)
    var
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        CountryCode: Code[10];
        ShopifyCustomerID: Text[30];
        BillingAdd1: Text;
        BillingAdd2: text;
        BillingCity: Text;
        CustomerName: Text;
        Email: Text;
        FirstName: Text;
        LastName: Text;
        PostCode: Text;
        Phone: Text;
    begin
        //GraphQL JSON Format
        OrderMgt.GetCustomerIdentifiers(Order, Email, Phone, ShopifyCustomerID, 'customer.defaultAddress.phone', true);
#pragma warning disable AA0139
        FirstName := JsonHelper.GetJText(Order, 'customer.firstName', false);
        LastName := JsonHelper.GetJText(Order, 'customer.lastName', false);
#pragma warning restore AA0139
        if OrderMgt.TryFindCustomer(NpEcStore, Order, ShopifyCustomerID, Email, Phone, FirstName, LastName, Customer, SpfyStoreCustomerLink) then
            exit;
#pragma warning disable AA0139
        CountryCode := OrderMgt.GetCountryCode(NpEcStore, Order, 'billingAddress.countryCodeV2', false);
        PostCode := JsonHelper.GetJCode(Order, 'billingAddress.zip', MaxStrLen(Customer."Post Code"), false);
        BillingAdd1 := JsonHelper.GetJText(Order, 'billingAddress.address1', MaxStrLen(Customer.Address), false);
        BillingAdd2 := JsonHelper.GetJText(Order, 'billingAddress.address2', MaxStrLen(Customer."Address 2"), false);
        BillingCity := JsonHelper.GetJText(Order, 'billingAddress.city', MaxStrLen(Customer.City), false);
        CustomerName := FirstName + ' ' + LastName.Trim();
#pragma warning restore AA0139
        OrderMgt.ResolveCustomer(NpEcStore, Email, Phone, BillingCity, BillingAdd1, BillingAdd2, CountryCode, PostCode, ShopifyCustomerID, CustomerName, Customer, SpfyStoreCustomerLink);
    end;

    local procedure FindNpEcStore(ShopifyStoreCode: Code[20]; Order: JsonToken): Code[20]
    var
        NpEcStore: Record "NPR NpEc Store";
        StoreSourceName: Text;
    begin
        StoreSourceName := JsonHelper.GetJText(Order, 'sourceName', true);
        OrderMgt.FindNpEcStore(ShopifyStoreCode, StoreSourceName, NpEcStore);
        exit(NpEcStore.Code);
    end;

    local procedure ParseEcommerceHeader(var EcomSalesHeader: Record "NPR Ecom Sales Header"; OrderJsonToken: JsonToken)
    var
        NpEcStore: Record "NPR NpEc Store";
        LocationMapping: Record "NPR Spfy Location Mapping";
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        HeaderToken: JsonToken;
        IsShpmtMappingLocation: Boolean;
        IsShpmtMappingShipAgent: Boolean;
    begin
        OrderJsonToken.SelectToken('data.order', HeaderToken);
        EcomSalesHeader."Price Excl. VAT" := not JsonHelper.GetJBoolean(HeaderToken, 'taxesIncluded', false);
        EcomSalesHeader."External Document Id" := CopyStr(JsonHelper.GetJText(HeaderToken, 'id', true), 1, MaxStrLen(EcomSalesHeader."External Document Id"));
        GetEcStore(NpEcStore, EcomSalesHeader);
        GetCustomerAndPostingDate(NpEcStore, EcomSalesHeader, HeaderToken);
        SetShipmentMethod(HeaderToken, EcomSalesHeader, IsShpmtMappingLocation, IsShpmtMappingShipAgent);
        if not (IsShpmtMappingLocation and IsShpmtMappingShipAgent) then begin
            SpfyOrderMgt.FindLocationMapping(NpEcStore, LocationMapping, OrderMgt.GetCountryCode(NpEcStore, HeaderToken, 'shippingAddress.countryCodeV2', false), JsonHelper.GetJCode(HeaderToken, 'shippingAddress.zip', MaxStrLen(LocationMapping."From Post Code"), false));
            if (LocationMapping."Location Code" <> '') and not IsShpmtMappingLocation then
                EcomSalesHeader."Location Code" := LocationMapping."Location Code";
        end;
        ParseTicketMetafields(HeaderToken, EcomSalesHeader);
        SpfyIntegrationEvents.OnAfterParseEcommerceSalesHeader(EcomSalesHeader, HeaderToken);
    end;

    local procedure ParseTicketMetafields(OrderToken: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        Clear(_TicketReservationLineIds);

        EcomSalesHeader."Ticket Reservation Token" := CopyStr(JsonHelper.GetJText(OrderToken, 'reservationToken.value', false), 1, MaxStrLen(EcomSalesHeader."Ticket Reservation Token"));
        if EcomSalesHeader."Ticket Reservation Token" = '' then
            exit;

        ParseTicketLineItemsData(JsonHelper.GetJText(OrderToken, 'lineItemsData.value', false));
    end;

    local procedure ParseTicketLineItemsData(LineItemsDataText: Text)
    var
        LineItemsData: JsonObject;
        ShopifyLineItemGid: Text;
        InvalidLineItemsDataErr: Label 'The Ticket line item data is not valid JSON.';
    begin
        if LineItemsDataText = '' then
            exit;

        if not LineItemsData.ReadFrom(LineItemsDataText) then
            Error(InvalidLineItemsDataErr);

        foreach ShopifyLineItemGid in LineItemsData.Keys() do
            ParseTicketLineItemData(LineItemsData, ShopifyLineItemGid);
    end;

    local procedure ParseTicketLineItemData(LineItemsData: JsonObject; ShopifyLineItemGid: Text)
    var
        LineItemDataToken: JsonToken;
        LineIdToken: JsonToken;
        TicketReservationLineId: Guid;
        LineIdText: Text;
        MissingReservationLineIdErr: Label 'The Ticket line item data for Shopify line item "%1" does not contain a reservation line ID.', Comment = '%1 = Shopify line item GID';
        InvalidReservationLineIdErr: Label 'The ticket reservation line ID "%1" for Shopify line item "%2" is invalid.', Comment = '%1 = reservation line ID, %2 = Shopify line item GID';
    begin
        if not LineItemsData.Get(ShopifyLineItemGid, LineItemDataToken) then
            exit;

        if not LineItemDataToken.IsObject() then
            Error(MissingReservationLineIdErr, ShopifyLineItemGid);
        if not LineItemDataToken.AsObject().Get('lineId', LineIdToken) then
            Error(MissingReservationLineIdErr, ShopifyLineItemGid);
        if not LineIdToken.IsValue() then
            Error(MissingReservationLineIdErr, ShopifyLineItemGid);
        if LineIdToken.AsValue().IsNull() then
            Error(MissingReservationLineIdErr, ShopifyLineItemGid);

        LineIdText := LineIdToken.AsValue().AsText();
        if LineIdText = '' then
            Error(MissingReservationLineIdErr, ShopifyLineItemGid);
        if not Evaluate(TicketReservationLineId, LineIdText) then
            Error(InvalidReservationLineIdErr, LineIdText, ShopifyLineItemGid);

        _TicketReservationLineIds.Set(ShopifyLineItemGid, TicketReservationLineId);
    end;

    local procedure GetCustomerAndPostingDate(NpEcStore: Record "NPR NpEc Store"; var EcomSalesHeader: Record "NPR Ecom Sales Header"; HeaderToken: JsonToken)
    var
        ClosedAt: Date;
    begin
        SetSellToCustomer(NpEcStore, HeaderToken, EcomSalesHeader);
        SetShipToCustomer(NpEcStore, HeaderToken, EcomSalesHeader);
        ClosedAt := DT2Date(JsonHelper.GetJDT(HeaderToken, 'closedAt', false));
        if ClosedAt > EcomSalesHeader."Received Date" then
            EcomSalesHeader."Received Date" := ClosedAt;
    end;

    local procedure SetShipmentMethod(Order: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header"; var IsShpmtMappingLocation: Boolean; var IsShpmtMappingShipAgent: Boolean)
    var
        CollectStore: Record "NPR NpCs Store";
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        ShippingNodeLine: JsonToken;
        ShippingLine: JsonToken;
        ShippingLines: JsonToken;
        DeliveryLocationId: Code[50];
        FoundShipmentMapping: Boolean;
    begin
        if Order.SelectToken('shippingLines', ShippingLines) and ShippingLines.IsArray() then
            foreach ShippingLine in ShippingLines.AsArray() do begin
                ShippingLine.SelectToken('node', ShippingNodeLine);
                FoundShipmentMapping := OrderMgt.FindShipmentMapping(ShippingNodeLine, ShipmentMapping, DeliveryLocationId);
                if FoundShipmentMapping then begin
                    EcomSalesHeader."Shipment Method Code" := ShipmentMapping."External Shipment Method Code";
                    if DeliveryLocationId <> '' then
                        EcomSalesHeader."Shipment Service" := DeliveryLocationId;
                    IsShpmtMappingShipAgent := ShipmentMapping."Shipping Agent Code" <> '';
                    IsShpmtMappingLocation := ShipmentMapping."Spfy Location Code" <> '';
                    if IsShpmtMappingLocation then
                        EcomSalesHeader."Location Code" := ShipmentMapping."Spfy Location Code"
                    else
                        if ShipmentMapping."Spfy Collect Store" <> '' then
                            if CollectStore.Get(ShipmentMapping."Spfy Collect Store") and (CollectStore."Location Code" <> '') then
                                EcomSalesHeader."Location Code" := CollectStore."Location Code";
                end;
            end;
    end;

    local procedure GetEcStore(var NpEcStore: Record "NPR NpEc Store"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        NpEcStore.Get(EcomSalesHeader."Ecommerce Store Code");
        NpEcStore.TestField("Salesperson/Purchaser Code")
    end;

    internal procedure SetSellToCustomer(NpEcStore: Record "NPR NpEc Store"; Order: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header"): Boolean
    var
        Customer: Record Customer;
        IsHandled: Boolean;
        BillingAddress: JsonToken;
        Company: Text;
        SellToName: Text;
    begin
        IsHandled := false;
        SpfyIntegrationEvents.OnBeforeFindCustomerInEcommerceDocument(Order, Customer, EcomSalesHeader, IsHandled);
        if not IsHandled then
            FindCustomer(NpEcStore, Order, Customer);

        if EcomSalesHeader."Sell-to Customer No." <> Customer."No." then
            EcomSalesHeader."Sell-to Customer No." := Customer."No.";
#pragma warning disable AA0139
        EcomSalesHeader."Sell-to Email" := _IncEcomSalesDocUtils.NormalizeEmail(Customer."E-Mail");
        EcomSalesHeader."Sell-to Phone No." := Customer."Phone No.";
#pragma warning restore AA0139
        if Order.SelectToken('billingAddress', BillingAddress) then begin
            SellToName := JsonHelper.GetJText(BillingAddress, 'firstName', false);
            if JsonHelper.GetJText(BillingAddress, 'lastName', false) <> '' then begin
                if SellToName <> '' then
                    SellToName += ' ';
                SellToName += JsonHelper.GetJText(BillingAddress, 'lastName', false);
            end;
            Company := JsonHelper.GetJText(BillingAddress, 'company', false);
            if Company = '' then begin
                EcomSalesHeader."Sell-to Name" := CopyStr(SellToName, 1, MaxStrLen(EcomSalesHeader."Sell-to Name"));
            end else begin
                EcomSalesHeader."Sell-to Name" := CopyStr(Company, 1, MaxStrLen(EcomSalesHeader."Sell-to Name"));
                EcomSalesHeader."Sell-to Contact" := CopyStr(SellToName, 1, MaxStrLen(EcomSalesHeader."Sell-to Contact"));
            end;
#pragma warning disable AA0139
            EcomSalesHeader."Sell-to Address" := JsonHelper.GetJText(BillingAddress, 'address1', MaxStrLen(EcomSalesHeader."Sell-to Address"), false);
            EcomSalesHeader."Sell-to Address 2" := JsonHelper.GetJText(BillingAddress, 'address2', MaxStrLen(EcomSalesHeader."Sell-to Address 2"), false);
            EcomSalesHeader."Sell-to Post Code" := JsonHelper.GetJCode(BillingAddress, 'zip', MaxStrLen(EcomSalesHeader."Sell-to Post Code"), false);
            EcomSalesHeader."Sell-to City" := JsonHelper.GetJText(BillingAddress, 'city', MaxStrLen(EcomSalesHeader."Sell-to City"), false);
            EcomSalesHeader."Sell-to Country Code" := OrderMgt.GetCountryCode(NpEcStore, BillingAddress, 'countryCodeV2', false);
#pragma warning restore AA0139
        end;
        if EcomSalesHeader."Sell-to Contact" = '' then
            EcomSalesHeader."Sell-to Contact" := CopyStr(EcomSalesHeader."Sell-to Name", 1, MaxStrLen(EcomSalesHeader."Sell-to Contact"));
#pragma warning disable AA0139
        EcomSalesHeader."Sell-to Invoice Email" := _IncEcomSalesDocUtils.NormalizeEmail(OrderMgt.GetJTextWithFallback(Order, 'email', 'customer.defaultEmailAddress.emailAddress', MaxStrLen(EcomSalesHeader."Sell-to Invoice Email")));
        EcomSalesHeader."Sell-to Invoice Phone No." := OrderMgt.GetJTextWithFallback(Order, 'phone', 'customer.defaultPhoneNumber.phoneNumber', MaxStrLen(EcomSalesHeader."Sell-to Invoice Phone No."));
#pragma warning restore AA0139
    end;

    local procedure SetShipToCustomer(NpEcStore: Record "NPR NpEc Store"; Order: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        ShippingAddress: JsonToken;
        Company: Text;
        ShipToName: Text;
    begin
        EcomSalesHeader."Ship-to Name" := EcomSalesHeader."Sell-to Name";
        EcomSalesHeader."Ship-to Contact" := EcomSalesHeader."Sell-to Contact";
        EcomSalesHeader."Ship-to Address" := EcomSalesHeader."Sell-to Address";
        EcomSalesHeader."Ship-to Address 2" := EcomSalesHeader."Sell-to Address 2";
        EcomSalesHeader."Ship-to Post Code" := EcomSalesHeader."Sell-to Post Code";
        EcomSalesHeader."Ship-to City" := EcomSalesHeader."Sell-to City";
        EcomSalesHeader."Ship-to Country Code" := EcomSalesHeader."Sell-to Country Code";
        EcomSalesHeader."Ship-to Phone No." := EcomSalesHeader."Sell-to Invoice Phone No.";
        if not Order.SelectToken('shippingAddress', ShippingAddress) or not ShippingAddress.IsObject() then
            exit;

        ShipToName := JsonHelper.GetJText(ShippingAddress, 'firstName', false);
        if JsonHelper.GetJText(ShippingAddress, 'lastName', false) <> '' then begin
            if ShipToName <> '' then
                ShipToName += ' ';
            ShipToName += JsonHelper.GetJText(ShippingAddress, 'lastName', false);
        end;
        Company := JsonHelper.GetJText(ShippingAddress, 'company', false);
        if Company = '' then begin
            EcomSalesHeader."Ship-to Name" := CopyStr(ShipToName, 1, MaxStrLen(EcomSalesHeader."Ship-to Name"));
        end else begin
            EcomSalesHeader."Ship-to Name" := CopyStr(Company, 1, MaxStrLen(EcomSalesHeader."Ship-to Name"));
            EcomSalesHeader."Ship-to Contact" := CopyStr(ShipToName, 1, MaxStrLen(EcomSalesHeader."Ship-to Contact"));
        end;
#pragma warning disable AA0139
        EcomSalesHeader."Ship-to Address" := JsonHelper.GetJText(ShippingAddress, 'address1', MaxStrLen(EcomSalesHeader."Ship-to Address"), false);
        EcomSalesHeader."Ship-to Address 2" := JsonHelper.GetJText(ShippingAddress, 'address2', MaxStrLen(EcomSalesHeader."Ship-to Address 2"), false);
        EcomSalesHeader."Ship-to Post Code" := JsonHelper.GetJCode(ShippingAddress, 'zip', MaxStrLen(EcomSalesHeader."Ship-to Post Code"), false);
        EcomSalesHeader."Ship-to City" := JsonHelper.GetJText(ShippingAddress, 'city', MaxStrLen(EcomSalesHeader."Ship-to City"), false);
#pragma warning restore AA0139
        EcomSalesHeader."Ship-to Country Code" := OrderMgt.GetCountryCode(NpEcStore, ShippingAddress, 'countryCodeV2', false);
#pragma warning disable AA0139
        EcomSalesHeader."Ship-to Phone No." := JsonHelper.GetJText(ShippingAddress, 'phone', MaxStrLen(EcomSalesHeader."Ship-to Phone No."), false);
        if EcomSalesHeader."Ship-to Phone No." = '' then
            EcomSalesHeader."Ship-to Phone No." := JsonHelper.GetJText(Order, 'phone', MaxStrLen(EcomSalesHeader."Ship-to Phone No."), false);
#pragma warning restore AA0139
        if EcomSalesHeader."Ship-to Phone No." = '' then
            EcomSalesHeader."Ship-to Phone No." := EcomSalesHeader."Sell-to Invoice Phone No.";

    end;

    local procedure PostAndDeleteDocument(var LogEntry: Record "NPR Spfy Event Log Entry"; var SalesHeader: Record "Sales Header")
    begin
        if LogEntry.Postponed then
            exit;

        if LogEntry."Posting Status" <> LogEntry."Posting Status"::Invoiced then
            if OrderMgt.CheckThereAreLinesToPost(SalesHeader) then begin
                Commit();
                if not PostSalesDocument(SalesHeader) then
                    Error(GetLastErrorText());
            end;

        if SpfyIntegrationMgt.DeleteAfterFinalPosting(LogEntry."Store Code") then begin
            Commit();
            DeleteDocument(LogEntry);
        end;
    end;

    local procedure PostSalesDocument(var SalesHeader: Record "Sales Header") Success: Boolean
    var
        SalesPost: Codeunit "Sales-Post";
        WebPostDateCheck: Codeunit "NPR Web Post Date Check";
    begin
        WebPostDateCheck.UpdatePostingDateIfWebOrder(SalesHeader);

        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                begin
                    SalesHeader.Ship := true;
                    SalesHeader.Invoice := true;
                end;
            SalesHeader."Document Type"::"Return Order":
                begin
                    SalesHeader.Receive := true;
                    SalesHeader.Invoice := true;
                end;
            else
                exit;
        end;
        Commit();
        Clear(SalesPost);
        Success := SalesPost.Run(SalesHeader);
    end;

    local procedure CheckIfPaymentLineExists(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line")
    var
        SalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        AlreadyExistsErr: Label 'A payment line with Shopify ID %1 already exists.', Comment = '%1=EcomSalesPmtLine."Shopify ID"';
    begin
        SalesPmtLine.SetRange("Shopify ID", EcomSalesPmtLine."Shopify ID");
        if SalesPmtLine.FindFirst() then
            Error(AlreadyExistsErr, EcomSalesPmtLine."Shopify ID");
    end;

    var
        GLSetup: Record "General Ledger Setup";
        JsonHelper: Codeunit "NPR Json Helper";
        _SpfyEcomSalesDocPrcssr: Codeunit "NPR Spfy Event Log DocProcessr";
        _SpfyAPIOrderHelper: Codeunit "NPR Spfy Order ApiHelper";
        _IncEcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        _TicketReservationLineIds: Dictionary of [Text, Guid];
        GLSetupRetrieved: Boolean;
        NoArrayErr: Label 'The %1 property is not an array.', Locked = true;
        VirtualItemExtraErr: Label 'It is not possible to change virtual items (gift cards, tickets, memberships) after the document has already been created. Item: %1, new quantity: %2. Please handle this change manually.', Comment = '%1 = item number or line name, %2 = new quantity reported by Shopify';

}
#endif
