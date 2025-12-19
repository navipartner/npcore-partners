#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248599 "NPR Spfy Event Log DocProcessr"
{
    Access = Internal;

    local procedure ProcessEcommerceDocument(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry") Success: Boolean
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
    begin
        ClearLastError();
        Clear(SpfyEcomSalesDocImport);
        LogEntry.Get(SpfyEventLogEntry."Entry No.");
        Success := SpfyEcomSalesDocImport.Run(LogEntry);
        if not Success then begin
            LogEntry.Get(SpfyEventLogEntry."Entry No.");
            HandleShopifyLog(false, GetLastErrorText(), LogEntry);
            Commit();
        end;
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
        PSpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
    begin
        PSpfyEventLogEntry.CopyFilters(SpfyEventLogEntry);
        PSpfyEventLogEntry.SetFilter("Processing Status", '<>%1', PSpfyEventLogEntry."Processing Status"::Processed);
        if not PSpfyEventLogEntry.FindSet() then
            exit(true);
        repeat
            ProcessLogEntry(PSpfyEventLogEntry);
        until PSpfyEventLogEntry.Next() = 0;

        exit(CompletedSuccessfully(SpfyEventLogEntry));
    end;

    local procedure CompletedSuccessfully(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    var
        pSpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
    begin
        pSpfyEventLogEntry.Copy(SpfyEventLogEntry);
        pSpfyEventLogEntry.SetRange("Processing Status", pSpfyEventLogEntry."Processing Status"::Error);
        exit(not pSpfyEventLogEntry.FindFirst());
    end;

    [TryFunction]
    internal procedure TryCheckForUnprocessedEntry(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    var
        PSpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
        WaitingErr: label 'Unprocessed open Shopify document detected — waiting for completion.';
    begin
        PSpfyEventLogEntry.ReadIsolation := IsolationLevel::ReadCommitted;
        PSpfyEventLogEntry.SetCurrentKey("Shopify ID", "Document Status", "Store Code", "Processing Status");
        PSpfyEventLogEntry.SetRange("Shopify ID", SpfyEventLogEntry."Shopify ID");
        PSpfyEventLogEntry.SetFilter("Document Status", '1..%1', SpfyEventLogEntry."Document Status".AsInteger());
        PSpfyEventLogEntry.SetFilter("Entry No.", '<>%1', SpfyEventLogEntry."Entry No.");
        PSpfyEventLogEntry.SetRange("Store Code", SpfyEventLogEntry."Store Code");
        PSpfyEventLogEntry.SetFilter("Processing Status", '<>%1', PSpfyEventLogEntry."Processing Status"::Processed);
        If PSpfyEventLogEntry.FindFirst() then
            Error(WaitingErr);
    end;

    internal procedure ProcessLogEntry(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    begin
        ClearLastError();
        if not ProcessEcommerceDocument(SpfyEventLogEntry) then
            LogError(GetLastErrorText());
    end;

    local procedure LogError(ErrMsg: text)
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
        CustomDimensions.Add('NPR_ErrorText', ErrMsg);
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");

        Session.LogMessage('NPR_ShopifyAPI_OrderCreationFailed', ErrMsg, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
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

    internal procedure EmitMessage(MessageInput: Text; EventId: Text)
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
    begin
        SpfyIntegrationMgt.SetRereadSetup();
        if SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Orders") then begin
            SpfyOrderImportJQ.SetupJobQueue(true);
            SpfyEcomSalesImportJQ.SetupJobQueue(true);
        end;
    end;

    internal procedure ShouldSoftExit(JobQueueEntryId: Guid): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        ///When the status of the Job Queue that’s running in a loop is changed to On Hold - active session won't be stopped.
        ///Job Queue will still run in background until loop finishes or exits on its own.
        ///This way, we’ll exit the loop and stop further execution.
        ///The Error status is handled in case of unexpected behavior after an app upgrade — the JQ might get stuck in an error state while the log still shows it as being in process.
        if not JobQueueEntry.Get(JobQueueEntryId) then
            exit(true);

        if JobQueueEntry.Status in [JobQueueEntry.Status::"On Hold", JobQueueEntry.Status::Error] then
            exit(true);
        exit(false);
    end;

    internal procedure IsShopifyDocument(EcomSalesHeader: Record "NPR Ecom Sales Header"): Boolean
    var
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
    begin
        exit(IsShopifyDocument(EcomSalesHeader, SpfyEventLogEntry));
    end;

    local procedure IsShopifyDocument(EcomSalesHeader: Record "NPR Ecom Sales Header"; var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    begin
        Clear(SpfyEventLogEntry);
        SpfyEventLogEntry.SetCurrentKey("Shopify ID", "Document Type", "Document Status");
        SpfyEventLogEntry.SetRange("Shopify ID", EcomSalesHeader."External No.");
        SpfyEventLogEntry.SetRange("Document Type", MapEcommerceDocumentTypeToSpfy(EcomSalesHeader."Document Type"));
        exit(SpfyEventLogEntry.FindFirst());
    end;

    internal procedure GetShopifyLogEntry(EcomSalesHeader: Record "NPR Ecom Sales Header"; var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    begin
        exit(IsShopifyDocument(EcomSalesHeader, SpfyEventLogEntry));
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
    end;

    internal procedure RefreshShopifySalesHeaderPostingDate(var SalesHeader: Record "Sales Header"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
    begin
        if not IsShopifyDocument(EcomSalesHeader, SpfyEventLogEntry) then
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
        if not IsShopifyDocument(EcomSalesHeader, SpfyEventLogEntry) then
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
        if SalesHeader."Shipment Method Code" <> '' then
            SpfyOrderMgt.UpdateLocationFromShippingMapping(ShipmentMapping, SalesHeader);
        NpEcStore.Get(EcomSalesHeader."Ecommerce Store Code");
        if not ((ShipmentMapping."Shipping Agent Code" <> '') and (ShipmentMapping."Spfy Location Code" <> '')) then begin // After sh is created check for mapping
            SpfyOrderMgt.FindLocationMapping(NpEcStore, LocationMapping, EcomSalesHeader."Ship-to Country Code", EcomSalesHeader."Ship-to Post Code");
            if (LocationMapping."Location Code" <> '') and not (ShipmentMapping."Spfy Location Code" <> '') then begin
                if SalesHeader."Location Code" = '' then
                    SalesHeader.Validate("Location Code", LocationMapping."Location Code");
                if (LocationMapping."Shipping Agent Code" <> '') and not (ShipmentMapping."Shipping Agent Code" <> '') then begin
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
        if not IsShopifyDocument(EcomSalesHeader, SpfyEventLogEntry) then
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
        if not IsShopifyDocument(EcomSalesHeader, SpfyEventLogEntry) then
            exit;
        CheckIfSalesDocumentCreatedOutsideEcommerceFlow(SpfyEventLogEntry);
    end;

    internal procedure CheckIfSalesDocumentCreatedOutsideEcommerceFlow(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    var
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        CreatedDocumentErrorLbl: Label 'The Shopify document was created outside of the Ecommerce flow and cannot be processed. Please handle the sales document manually.';
    begin
        if SpfyOrderMgt.SalesOrderExists(SpfyEventLogEntry."Store Code", SpfyEventLogEntry."Shopify ID") or
            SpfyOrderMgt.PostedDocumentExists(SpfyEventLogEntry."Store Code", SpfyEventLogEntry."Shopify ID", SpfyEventLogEntry."Document Type" = SpfyEventLogEntry."Document Type"::Order) then
            Error(CreatedDocumentErrorLbl);
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

}
#endif