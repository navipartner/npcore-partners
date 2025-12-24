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
        Process(Rec);
        Rec.Get(Rec."Entry No.");
        _SpfyEcomSalesDocPrcssr.HandleShopifyLog(true, GetLastErrorText(), Rec);
    end;

    local procedure Process(var LogEntry: Record "NPR Spfy Event Log Entry")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        UnprocessedEntriesErr: Label 'Processing is postponed until all related event log entries are completed.';
        DelayProcessingErr: Label 'Processing is postponed because dependent Ecommerce processes are still running.';
        NothingToProcessErr: Label 'The order was canceled in Shopify before it was processed. There is nothing to process here.';
    begin
        case LogEntry."Document Status" of
            LogEntry."Document Status"::Open:
                if not _SpfyEcomSalesDocPrcssr.EcommerceDocAlreadyProcessed(LogEntry, EcomSalesHeader, true) then
                    CreateDocument(LogEntry);
            LogEntry."Document Status"::Closed:
                if not _SpfyEcomSalesDocPrcssr.TryCheckForUnprocessedEntry(LogEntry) then
                    AddTimeForEcommerceProcessing(LogEntry, UnprocessedEntriesErr)// make time for Ecommerce processes to finish
                else
                    if not _SpfyEcomSalesDocPrcssr.EcommerceDocAlreadyProcessed(LogEntry, EcomSalesHeader, false) then begin
                        if not CreateAndProcess(LogEntry) then
                            AddTimeForEcommerceProcessing(LogEntry, DelayProcessingErr)// make time 
                    end else
                        if IsSalesDocumentReady(EcomSalesHeader, LogEntry) then
                            UpdateAndProcess(LogEntry);
            LogEntry."Document Status"::Cancelled:
                if (not _SpfyEcomSalesDocPrcssr.TryCheckForUnprocessedEntry(LogEntry)) then
                    AddTimeForEcommerceProcessing(LogEntry, UnprocessedEntriesErr)// make time 
                else
                    if (not _SpfyEcomSalesDocPrcssr.EcommerceDocAlreadyProcessed(LogEntry, EcomSalesHeader, false)) then
                        Error(NothingToProcessErr)
                    else
                        if IsSalesDocumentReady(EcomSalesHeader, LogEntry) then
                            DeleteDocument(LogEntry);
        end;
    end;

    local procedure CreateAndProcessEcommerceDocument(var LogEntry: Record "NPR Spfy Event Log Entry"; var DetailsResponse: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header"): Boolean
    var
        EcomSalesDocApiAgentV2: Codeunit "NPR EcomSalesDocApiAgentV2";
    begin
        _SpfyEcomSalesDocPrcssr.CheckIfSalesDocumentCreatedOutsideEcommerceFlow(LogEntry);

        if not CreateDocument(LogEntry, DetailsResponse, EcomSalesHeader) then
            if LogEntry.Postponed then
                exit(false)
            else
                Error(GetLastErrorText());

        Commit();
        LogEntry.ReadIsolation := IsolationLevel::UpdLock;
        LogEntry.Get(LogEntry."Entry No.");
        EcomSalesDocApiAgentV2.PreProcessDocument(EcomSalesHeader);
        EcomSalesDocApiAgentV2.AssignBucketId(EcomSalesHeader);//makes it visible for ecom jqs
        exit(true);
    end;

    local procedure CreateAndProcess(var LogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SalesHeader: Record "Sales Header";
        DetailsResponse: JsonToken;
        OrderToken: JsonToken;
    begin
        if not CreateAndProcessEcommerceDocument(LogEntry, DetailsResponse, EcomSalesHeader) then
            exit(false);

        LogEntry.Get(LogEntry.RecordId);
        LogEntry.CalcFields("Creation Status");
        if LogEntry."Creation Status" <> LogEntry."Creation Status"::Created then
            exit(false);

        ClearCache();
        LogEntry.CalcFields("Posting Status");
        if LogEntry."Posting Status" = LogEntry."Posting Status"::Invoiced then
            exit(true);

        LogEntry.CalcFields("Created Sales Doc No.");
        DetailsResponse.SelectToken('data.order', OrderToken);
        SalesHeader.ReadIsolation := IsolationLevel::UpdLock;
        SalesHeader.Get(_SpfyEcomSalesDocPrcssr.MapSalesDocumentType(LogEntry."Document Type"), LogEntry."Created Sales Doc No.");

        PostAndDeleteDocument(LogEntry, SalesHeader);

        exit(true);
    end;

    internal procedure IsSalesDocumentReady(EcomSalesHeader: Record "NPR Ecom Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    var
        MissingSalesDocErr: Label 'Processing cannot continue because the related Sales Document has not been created.';
    begin
        If (EcomSalesHeader."Created Doc No." <> '') then
            exit(true);
        ClearLastError();
        if (_SpfyEcomSalesDocPrcssr.CheckForSaleDocumentWithAssignedShopifyID(LogEntry)) then
            AddTimeForEcommerceProcessing(LogEntry, MissingSalesDocErr)
        else
            Error(GetLastErrorText());
    end;

    local procedure AddTimeForEcommerceProcessing(var LogEntry: Record "NPR Spfy Event Log Entry"; LogMessage: text): Boolean
    begin
        if not LogEntry.Postponed then begin
            LogEntry.Postponed := true;
            LogEntry."Not Before Date-Time" := CurrentDateTime + 1000 * 60;//1min
            LogEntry."Last Error Message" := CopyStr(LogMessage, 1, MaxStrLen(LogEntry."Last Error Message"));
            LogEntry.Modify();
        end;
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
                        exit;//nothing to delete
                    SalesHeader.ReadIsolation := IsolationLevel::UpdLock;
                    SalesHeader.Get(_SpfyEcomSalesDocPrcssr.MapSalesDocumentType(LogEntry."Document Type"), EcomSalesHeader."Created Doc No.");
                    SpfyDeleteOrder.DeleteOrder(SalesHeader);
                end;
            EcomSalesHeader."Creation Status"::Canceled:
                exit;//already deleted
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

    local procedure CreateDocument(var LogEntry: Record "NPR Spfy Event Log Entry"; var DetailsResponse: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header"): Boolean
    begin
        ClearCache();
        If GetShopifyOrderDetails(LogEntry, DetailsResponse) then
            if not LogEntry.Postponed then
                exit(CreateEcommerceDocument(LogEntry, DetailsResponse, EcomSalesHeader));
        exit(false);
    end;

    local procedure GetShopifyOrderDetails(var LogEntry: Record "NPR Spfy Event Log Entry"; var ShopifyResponse: JsonToken): Boolean
    var
        SpfyAPIOrderHelper: Codeunit "NPR Spfy Order ApiHelper";
    begin
        Clear(ShopifyResponse);
        ClearCache();
        ClearLastError();
        Commit();
        if not SpfyAPIOrderHelper.Run(LogEntry) then
            Error(GetLastErrorText());

        LogEntry.ReadIsolation := IsolationLevel::UpdLock;
        LogEntry.Get(LogEntry."Entry No.");
        ShopifyResponse := SpfyAPIOrderHelper.GetResponse();
        exit(not LogEntry.Postponed);
    end;

    local procedure CreateDocument(var LogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    var
        DetailsResponse: JsonToken;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        exit(CreateAndProcessEcommerceDocument(LogEntry, DetailsResponse, EcomSalesHeader));
    end;

    local procedure UpdateAndProcess(var LogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    var
        DetailsResponse: JsonToken;
    begin
        ClearCache();
        If GetShopifyOrderDetails(LogEntry, DetailsResponse) then
            if not LogEntry.Postponed then
                exit(UpdateFromShopifyAndProcess(LogEntry, DetailsResponse));
        exit(false);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    local procedure CreateEcommerceDocument(var LogEntry: Record "NPR Spfy Event Log Entry"; Response: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header"): Boolean
    begin
        Clear(EcomSalesHeader);
        ProcessEcommerceHeader(Response, EcomSalesHeader, LogEntry);
        ProcessLines(Response, EcomSalesHeader, LogEntry);
        ProcessEcommercePaymentLines(Response, EcomSalesHeader, LogEntry);
        ProcessEcommerceComment(Response, EcomSalesHeader);
        exit(true);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    local procedure UpdateSalesDocument(var LogEntry: Record "NPR Spfy Event Log Entry"; Response: JsonToken; var SalesHeader: Record "Sales Header")
    begin
        UpdateSalesHeader(LogEntry, SalesHeader, Response);
        UpdateSalesLines(LogEntry, SalesHeader, Response);
        UpdatePaymentLines(LogEntry, SalesHeader, Response);
    end;

    local procedure UpdateFromShopifyAndProcess(var LogEntry: Record "NPR Spfy Event Log Entry"; Response: JsonToken) Success: Boolean
    var
        SalesHeader: Record "Sales Header";
        AlreadyPostedMsg: Label 'The order has already been posted. Further processing has been skipped.';
    begin
        LogEntry.CalcFields("Posting Status");
        if LogEntry."Posting Status" = LogEntry."Posting Status"::Invoiced then
            Error(AlreadyPostedMsg);
        UpdateSalesDocument(LogEntry, Response, SalesHeader);
        PostAndDeleteDocument(LogEntry, SalesHeader);
        Success := true;
    end;

    local procedure UpdateSalesHeader(LogEntry: Record "NPR Spfy Event Log Entry"; var SalesHeader: Record "Sales Header"; Response: JsonToken)
    var
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        OrderToken: JsonToken;
        ClosedDate: date;
    begin
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

    local procedure UpdateSalesLines(LogEntry: Record "NPR Spfy Event Log Entry"; SalesHeader: Record "Sales Header"; Response: JsonToken)
    var
        Header: RecordRef;
    begin
        SetQuantities(SalesHeader);
        Header.GetTable(SalesHeader);
        ProcessEcommerceSaleLines(Response, Header, LogEntry);
        ProcessEcommerceShippingLines(Response, Header, LogEntry);
    end;

    local procedure AddNewSaleLine(SalesLine: Record "Sales Line"; SalesLineJsonToken: JsonToken; SalesHeader: Record "Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry"; TempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary): Boolean
    var
        ItemVariant: Record "Item Variant";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        VATP: Decimal;
        Sku: Text;
        UnknownIdErr: Label 'Unknown %1: %2%3';
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := _IncEcomSalesDocUtils.GetInternalSalesDocumentLastLineNo(SalesHeader) + 10000;
        SalesLine.Insert(true);
        if not SpfyItemMgt.ParseItem(SalesLineJsonToken, ItemVariant, Sku) then
            Error(UnknownIdErr, 'sku', Sku, StrSubstNo(' (line ID: %1, name: %2)', TempSpfyFulfillmentBuffer."Order Line ID", JsonHelper.GetJText(SalesLineJsonToken, 'name', false)));
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", ItemVariant."Item No.");
        SalesLine."Variant Code" := ItemVariant.Code;
        SalesLine.Validate(Quantity, (JsonHelper.GetJDecimal(SalesLineJsonToken, 'unfulfilledQuantity', true) + TempSpfyFulfillmentBuffer."Fulfilled Quantity"));
#pragma warning disable AA0139
        SalesLine.Description := JsonHelper.GetJText(SalesLineJsonToken, 'title', MaxStrLen(SalesLine.Description), true);
        SalesLine."Description 2" := JsonHelper.GetJText(SalesLineJsonToken, 'variantTitle', MaxStrLen(SalesLine."Description 2"), false);
#pragma warning restore AA0139
        OrderMgt.SetOrderLineUnitPriceAndDiscount(SalesHeader, LogEntry."Store Code", JsonHelper.GetJDecimal(SalesLineJsonToken, 'originalUnitPriceSet.presentmentMoney.amount', true),
             CalcLineDiscountAmount(SalesLineJsonToken, SalesLine), SalesLine);
        VATP := CalculateVAT(SalesLineJsonToken);
        if VATP <> 0 then
            SalesLine.Validate("VAT %", VATP);
        if SalesHeader."Location Code" <> '' then
            SalesLine.Validate("Location Code", SalesHeader."Location Code");
        SetQuantityToShip(SalesLine, TempSpfyFulfillmentBuffer);
        SalesLine.Modify(true);
        SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", TempSpfyFulfillmentBuffer."Order Line ID", false);

        SpfyIntegrationEvents.OnAfterUpdateSalesLine(SalesLineJsonToken, SalesHeader, SalesLine, true);
        exit(true);
    end;

    local procedure SetQuantities(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.ReadIsolation := IsolationLevel::UpdLock;
        if SalesLine.FindSet() then
            repeat
                SalesLine.Validate("Qty. to Ship", 0);
                SalesLine.Validate("Qty. to Invoice", 0);
                SalesLine.Modify(true);
            until SalesLine.Next() = 0;
    end;

    internal procedure CalcLineDiscountAmount(OrderLine: JsonToken; SalesLine: Record "Sales Line") LineDiscountAmount: Decimal
    var
        OriginalOrderQty: Decimal;
    begin
        LineDiscountAmount := CalcLineDiscountAmount(OrderLine);
        if LineDiscountAmount = 0 then
            exit;

        OriginalOrderQty := JsonHelper.GetJDecimal(OrderLine, 'quantity', false) - JsonHelper.GetJDecimal(OrderLine, 'nonFulfillableQuantity', false);
        if (SalesLine.Quantity < OriginalOrderQty) and (OriginalOrderQty <> 0) then
            LineDiscountAmount := LineDiscountAmount / OriginalOrderQty * SalesLine.Quantity;
    end;

    local procedure SetQuantityToShip(var SalesLine: record "Sales Line"; TempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary)
    begin
        if SalesLine."Qty. to Ship" <> TempSpfyFulfillmentBuffer."Fulfilled Quantity" - SalesLine."Quantity Shipped" then
            if TempSpfyFulfillmentBuffer."Fulfilled Quantity" - SalesLine."Quantity Shipped" <= 0 then
                SalesLine.Validate("Qty. to Ship", 0)
            else
                SalesLine.Validate("Qty. to Ship", TempSpfyFulfillmentBuffer."Fulfilled Quantity" - SalesLine."Quantity Shipped");
    end;

    local procedure CheckGiftCardQtyChanges(ShopifyLineId: Text[30]): Integer
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        IssuedVouchers: Integer;
    begin
        _SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"Sales Line", "NPR Spfy ID Type"::"Entry ID", ShopifyLineId, ShopifyAssignedID);
        if ShopifyAssignedID.Count = 1 then
            exit(1);
        if ShopifyAssignedID.FindSet() then
            repeat
                IssuedVouchers += 1;
            until ShopifyAssignedID.Next() = 0;
        exit(IssuedVouchers);
    end;

    local procedure ProcessEcommercePaymentLines(Response: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry");
    var
        Header: RecordRef;
    begin
        Header.GetTable(EcomSalesHeader);
        ProcessPaymentLines(Response, Header, LogEntry)
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
                If JsonHelper.GetJText(PaymentLineJsonToken, 'status', true).ToUpper() = 'SUCCESS' then
                    if SpfyCapturePayment.IsAuthorizationTransaction(ShopifyTransactionKind) or SpfyCapturePayment.IsSaleTransaction(ShopifyTransactionKind) then
                        InsertEcommerceSalesPaymentLine(PaymentLineJsonToken, EcomSalesHeader, LogEntry);
            end;
        IsHandled := false;
        SpfyIntegrationEvents.OnAfterInsertEcommercePaymentLines(LogEntry."Store Code", PaymentLinesJsonToken, EcomSalesHeader, IsHandled);
    end;

    local procedure ProcessSalesPaymentLines(PaymentLinesJsonToken: JsonToken; SalesHeader: Record "Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry")
    var
        SpfyCapturePayment: Codeunit "NPR Spfy Capture Payment";
        TempSpfyTransactionBuffer: Record "NPR Spfy Transaction Buffer" temporary;
        NcTask: Record "NPR Nc Task";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        PaymentLineJsonToken: JsonToken;
        Handled: Boolean;
    begin
        SpfyIntegrationEvents.OnBeforeUpdatePaymentLines(LogEntry."Store Code", PaymentLinesJsonToken, SalesHeader, Handled);
        if not Handled then begin
            NcTask."Record ID" := SalesHeader.RecordId();
            NcTask."Record Value" := CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID"), 1, MaxStrLen(NcTask."Record Value"));
            NcTask."Store Code" := LogEntry."Store Code";
            foreach PaymentLineJsonToken in PaymentLinesJsonToken.AsArray() do
                SpfyCapturePayment.ProcessTransaction(PaymentLineJsonToken, NcTask, TempSpfyTransactionBuffer);
            SpfyCapturePayment.UpdatePmtLinesAndScheduleCapture(NcTask, PaymentLinesJsonToken.AsArray(), TempSpfyTransactionBuffer, false);
        end;
        Handled := false;
        SpfyIntegrationEvents.OnAfterUpdatePaymentLines(LogEntry."Store Code", PaymentLinesJsonToken, SalesHeader, Handled);
    end;

    local procedure InsertEcommerceSalesPaymentLine(PaymentLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry")
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
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
    end;

    local procedure ParseEcommerceSalesPaymentLine(PaymentLineJsonToken: JsonToken; var EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; LogEntry: Record "NPR Spfy Event Log Entry"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        SpfyCapturePayment: Codeunit "NPR Spfy Capture Payment";
        SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
        GiftCardTransaction: Boolean;
    begin
        EcomSalesPmtLine."Shopify ID" := _SpfyAPIOrderHelper.GetNumericId(JsonHelper.GetJText(PaymentLineJsonToken, 'id', true));
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
            Error(ExternalPaymentMethodNotSetupErr, EcomSalesPmtLine."External Payment Type", EcomSalesPmtLine."External Payment Method Code");
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
        ReceiptJText: text;
        NotSupportedPayMethodErr: Label 'The payment was made using the Manual Payment method %1, which is not supported.', Comment = '%1=Gateway';
        WrongFormatErr: Label 'Receipt JSON could not be serialized. Please check the data format.';
        VoucherNotFoundErr: Label 'System could not find a retail voucher with Shopify gift card ID %1';
        VoucherLbl: Label 'Voucher';
    begin
        ReceiptJson.ReadFrom(JsonHelper.GetJText(PaymentLineJsonToken, 'receiptJson', true));
        if not ReceiptJson.WriteTo(ReceiptJText) then
            Error(WrongFormatErr);
        if (ReceiptJText = '{}') then
            Error(NotSupportedPayMethodErr, EcomSalesPmtLine."External Payment Gateway");
#pragma warning disable AA0139
        ShopifyGiftCardID := SpfyIntegrationMgt.RemoveUntil(JsonHelper.GetJText(ReceiptJson, 'gift_card_id', false), '/');
#pragma warning restore AA0139
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

    local procedure ProcessEcommerceHeader(Response: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry");
    var
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        InitEcommerceHeader(LogEntry, EcomSalesHeader, Response);
        EcomSalesHeader."Requested API Version Date" := Today;
        EcomSalesHeader."API Version Date" := EcomSalesDocUtils.GetApiVersionDateByRequest(Today);
        EcomSalesHeader."Price Excl. VAT" := true;
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
        EcomSalesHeader.ReadIsolation := IsolationLevel::ReadUnCommitted;
        EcomSalesHeader.SetRange("External No.", EcomHeader."External No.");
        EcomSalesHeader.SetRange("Document Type", EcomHeader."Document Type");
        if EcomSalesHeader.FindFirst() then
            Error(AlreadyExistsErr, EcomSalesHeader."External No.");
    end;

    local procedure ProcessLines(Response: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry");
    var
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        Header: RecordRef;
    begin
        Header.GetTable(EcomSalesHeader);
        ProcessEcommerceSaleLines(Response, Header, LogEntry);
        ProcessEcommerceShippingLines(Response, Header, LogEntry);
        EcomVirtualItemMgt.UpdateVirtualItemInformationInHeader(EcomSalesHeader);
    end;

    local procedure ProcessEcommerceShippingLines(Response: JsonToken; Header: RecordRef; LogEntry: Record "NPR Spfy Event Log Entry");
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
                if not ApplyToSalesDocument then
                    InsertEcommerceSalesLine(LineToken, EcomSalesHeader, LogEntry, LineType::"Shipment Fee")
                else
                    ProcessShippingLine(LineToken, SalesHeader);
        end;
    end;

    local procedure ProcessEcommerceSaleLines(Response: JsonToken; Header: RecordRef; LogEntry: Record "NPR Spfy Event Log Entry");
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SalesHeader: Record "Sales Header";
        LineToken: JsonToken;
        SalesLineJsonToken: JsonToken;
        SalesLinesJsonToken: JsonToken;
        ApplyToSalesDocument: Boolean;
    begin
        GetSalesLinesJsonToken(SalesLinesJsonToken, Response);
        ApplyToSalesDocument := ResolveDocumentHeader(Header, SalesHeader, EcomSalesHeader);

        foreach SalesLineJsonToken in SalesLinesJsonToken.AsArray() do begin
            SalesLineJsonToken.SelectToken('node', LineToken);
            if not IsProductRemoved(LineToken) then
                if ApplyToSalesDocument then
                    ProcessSaleLine(LineToken, SalesHeader, LogEntry)
                else
                    ProcessEcommerceSaleLine(LineToken, EcomSalesHeader, LogEntry);
        end;
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

    local procedure ProcessSaleLine(SalesLineJsonToken: JsonToken; SalesHeader: Record "Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry")
    var
        SalesLine: Record "Sales Line";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        TempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        IsHandled: Boolean;
        GiftCardExtraErr: label 'It is not possible to change gift cards after the document has already been created. Please handle this change manually.';
    begin
        SpfyIntegrationEvents.OnBeforeUpdateSalesLine(SalesLineJsonToken, SalesHeader, SalesLine, IsHandled);
        if IsHandled then
            exit;
        if _SpfyFulfillmentCache.GetLineFromCache(_SpfyAPIOrderHelper.GetNumericId(JsonHelper.GetJText(SalesLineJsonToken, 'id', true)), TempSpfyFulfillmentBuffer) then begin
            SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"Sales Line", "NPR Spfy ID Type"::"Entry ID", TempSpfyFulfillmentBuffer."Order Line ID", ShopifyAssignedID);
            if not ShopifyAssignedID.FindFirst() then begin
                if TempSpfyFulfillmentBuffer."Gift Card" then
                    Error(GiftCardExtraErr);
                if AddNewSaleLine(SalesLine, SalesLineJsonToken, SalesHeader, LogEntry, TempSpfyFulfillmentBuffer) then
                    exit;
            end;
            SalesLine.Get(ShopifyAssignedID."BC Record ID");
            if TempSpfyFulfillmentBuffer."Gift Card" and IsGiftCardLineChanged(TempSpfyFulfillmentBuffer, SalesLine, SalesLineJsonToken) then
                Error(GiftCardExtraErr)
            else
                UpdateSalesLineFromShopify(SalesLine, TempSpfyFulfillmentBuffer, SalesLineJsonToken, SalesHeader, LogEntry);
        end else begin
            SalesLine.Validate("Qty. to Ship", 0);
            SalesLine.Modify(true);
        end;
        SpfyIntegrationEvents.OnAfterUpdateSalesLine(SalesLineJsonToken, SalesHeader, SalesLine, false);
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
        OrderMgt.SetOrderLineUnitPriceAndDiscount(SalesHeader, LogEntry."Store Code", Round(ExpectedUnitPrice, GLSetup."Unit-Amount Rounding Precision"), Round(ExpectedDiscount, GLSetup."Amount Rounding Precision"), SalesLine);
        SalesLine.Modify(true);
    end;

    local procedure IsGiftCardLineChanged(TempBuffer: Record "NPR Spfy Fulfillment Buffer" temporary; SalesLine: Record "Sales Line"; SalesLineJsonToken: JsonToken): Boolean
    begin
        if CheckGiftCardQtyChanges(TempBuffer."Order Line ID") <> TempBuffer."Fulfilled Quantity" then
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
        if not GLSetupRetrived then
            GLSetup.Get();
        GLSetupRetrived := true;
    end;

    local procedure ProcessShippingLine(ShippingLineJsonToken: JsonToken; SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        ShipmentFee: Decimal;
    begin
        ShipmentFee := JsonHelper.GetJDecimal(ShippingLineJsonToken, 'originalPriceSet.presentmentMoney.amount', false);
        if ShipmentFee = 0 then
            exit;
        SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"Sales Line", "NPR Spfy ID Type"::"Entry ID", _SpfyAPIOrderHelper.GetNumericId(JsonHelper.GetJText(ShippingLineJsonToken, 'id', true)), ShopifyAssignedID);
        if not ShopifyAssignedID.FindFirst() then
            if AddNewShippingLine(SalesLine, ShippingLineJsonToken, SalesHeader) then
                exit;
        SalesLine.Get(ShopifyAssignedID."BC Record ID");
        SetQtyAndPriceShippingLine(SalesLine, ShipmentFee, ShippingLineJsonToken);
        SalesLine.Modify(true);
        SpfyIntegrationEvents.OnAfterUpdateSalesLineShipmentFee(SalesHeader, SalesLine, false);
    end;

    local procedure AddNewShippingLine(SalesLine: Record "Sales Line"; ShippingLineJsonToken: JsonToken; SalesHeader: Record "Sales Header"): Boolean
    var
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        ShipmentFee: Decimal;
        ShipmentFeeTitle: Text;
        DeliveryLocationId: Code[50];
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := _IncEcomSalesDocUtils.GetInternalSalesDocumentLastLineNo(SalesHeader) + 10000;
        SalesLine.Insert(true);

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
        SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", _SpfyAPIOrderHelper.GetNumericId(JsonHelper.GetJText(ShippingLineJsonToken, 'id', true)), false);
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

    local procedure ProcessEcommerceSaleLine(SalesLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry")
    var
        LineType: Enum "NPR Ecom Sales Line Type";
    begin
        LineType := EvaluateLineType(SalesLineJsonToken);
        if LineType = LineType::Voucher then
            SplitEcommerceSalesLine(SalesLineJsonToken, EcomSalesHeader, LogEntry, LineType)
        else
            InsertEcommerceSalesLine(SalesLineJsonToken, EcomSalesHeader, LogEntry, LineType);
    end;

    local procedure SplitEcommerceSalesLine(SalesLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry"; LineType: Enum "NPR Ecom Sales Line Type")
    var
        i: Integer;
    begin
        for i := 1 to JsonHelper.GetJInteger(SalesLineJsonToken, 'currentQuantity', true) do
            InsertEcommerceSalesLine(SalesLineJsonToken, EcomSalesHeader, LogEntry, LineType);
    end;

    local procedure IsProductRemoved(SalesLineJsonToken: JsonToken): Boolean
    var
        Handled: Boolean;
        Skip: Boolean;
    begin
        SpfyIntegrationEvents.OnCheckIfSkipLine(SalesLineJsonToken, Skip, Handled);
        if not Handled then
            Skip := (JsonHelper.GetJDecimal(SalesLineJsonToken, 'currentQuantity', false) = 0) and (JsonHelper.GetJInteger(SalesLineJsonToken, 'unfulfilledQuantity', false) = 0);
        exit(Skip);
    end;

    local procedure InsertEcommerceSalesLine(SalesLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; LogEntry: Record "NPR Spfy Event Log Entry"; LineType: enum "NPR Ecom Sales Line Type")
    var
        IncEcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        IncEcomSalesLine.Init();
        IncEcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        IncEcomSalesLine."External Document No." := EcomSalesHeader."External No.";
        IncEcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        IncEcomSalesLine.Type := LineType;
        IncEcomSalesLine."Line No." := _IncEcomSalesDocUtils.GetSalesDocLastSalesLineLineNo(EcomSalesHeader) + 10000;
        ParseEcommerceSalesLine(EcomSalesHeader, SalesLineJsonToken, IncEcomSalesLine, LogEntry);
        SpfyIntegrationEvents.OnBeforeInsertEcommerceSalesLine(SalesLineJsonToken, EcomSalesHeader, IncEcomSalesLine);
        IncEcomSalesLine.Insert(true);
    end;

    local procedure PopulateVoucherLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesLineJsonToken: JsonToken; var IncEcomSalesLine: Record "NPR Ecom Sales Line"; LogEntry: Record "NPR Spfy Event Log Entry")
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        PropertyDict: Dictionary of [Text, Text];
        GiftCardId: Text[30];
    begin
        OrderMgt.GetOrderLineProperties(SalesLineJsonToken, PropertyDict, 'customAttributes', 'key');
        OrderMgt.GetVoucherType(LogEntry."Store Code", PropertyDict, VoucherType);
        VoucherType.TestField("Reference No. Pattern");
        IncEcomSalesLine."Voucher Type" := VoucherType.Code;
        _SpfyFulfillmentCache.GetVocherReferenceNo(IncEcomSalesLine."Shopify ID", IncEcomSalesLine."Barcode No.", GiftCardId);
        IncEcomSalesLine.Description := CopyStr(JsonHelper.GetJText(SalesLineJsonToken, 'name', MaxStrLen(IncEcomSalesLine.Description), false), 1, MaxStrLen(IncEcomSalesLine.Description));
        IncEcomSalesLine.Quantity := 1;
        PopulateAmounts(EcomSalesHeader, SalesLineJsonToken, IncEcomSalesLine, LogEntry);
        ReserveVoucher(EcomSalesHeader, IncEcomSalesLine, VoucherType, PropertyDict, GiftCardId);
    end;

    local procedure PopulateItemLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesLineJsonToken: JsonToken; var IncEcomSalesLine: Record "NPR Ecom Sales Line"; LogEntry: Record "NPR Spfy Event Log Entry")
    var
        ItemVariant: Record "Item Variant";
        TempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
        SpfyFulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        Sku: Text;
        UnknownIdErr: Label 'Unknown %1: %2%3';
    begin
        if not SpfyFulfillmentCache.GetLineFromCache(IncEcomSalesLine."Shopify ID", TempSpfyFulfillmentBuffer) then
            TempSpfyFulfillmentBuffer.Init();
        if not SpfyItemMgt.ParseItem(SalesLineJsonToken, ItemVariant, Sku) then
            Error(UnknownIdErr, 'sku', Sku, StrSubstNo(' (line ID: %1, name: %2)', IncEcomSalesLine."Shopify ID", JsonHelper.GetJText(SalesLineJsonToken, 'name', false)));
        IncEcomSalesLine."No." := ItemVariant."Item No.";
        IncEcomSalesLine."Variant Code" := ItemVariant.Code;
#pragma warning disable AA0139
        IncEcomSalesLine.Quantity := JsonHelper.GetJDecimal(SalesLineJsonToken, 'unfulfilledQuantity', true) + TempSpfyFulfillmentBuffer."Fulfilled Quantity";
        IncEcomSalesLine.Description := JsonHelper.GetJText(SalesLineJsonToken, 'title', MaxStrLen(IncEcomSalesLine.Description), true);
        IncEcomSalesLine."Description 2" := JsonHelper.GetJText(SalesLineJsonToken, 'variantTitle', MaxStrLen(IncEcomSalesLine."Description 2"), false);
        PopulateAmounts(EcomSalesHeader, SalesLineJsonToken, IncEcomSalesLine, LogEntry);
#pragma warning restore AA0139
    end;

    local procedure PopulateMembershipLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesLineJsonToken: JsonToken; var IncEcomSalesLine: Record "NPR Ecom Sales Line"; LogEntry: Record "NPR Spfy Event Log Entry")
    begin
        FindMembershipItem(SalesLineJsonToken, LogEntry, IncEcomSalesLine."No.", IncEcomSalesLine."Variant Code");
#pragma warning disable AA0139
        IncEcomSalesLine.Quantity := JsonHelper.GetJDecimal(SalesLineJsonToken, 'currentQuantity', true);
        IncEcomSalesLine.Description := JsonHelper.GetJText(SalesLineJsonToken, 'title', MaxStrLen(IncEcomSalesLine.Description), true);
        IncEcomSalesLine."Description 2" := JsonHelper.GetJText(SalesLineJsonToken, 'variantTitle', MaxStrLen(IncEcomSalesLine."Description 2"), false);
        PopulateAmounts(EcomSalesHeader, SalesLineJsonToken, IncEcomSalesLine, LogEntry);
#pragma warning restore AA0139
    end;

    local procedure PopulateAmounts(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesLineJsonToken: JsonToken; var IncEcomSalesLine: Record "NPR Ecom Sales Line"; LogEntry: Record "NPR Spfy Event Log Entry")
    var
        TotalQty: Decimal;
    begin
        TotalQty := JsonHelper.GetJDecimal(SalesLineJsonToken, 'quantity', false) - JsonHelper.GetJDecimal(SalesLineJsonToken, 'nonFulfillableQuantity', false);
        SetOrderLineUnitPriceAndDiscount(EcomSalesHeader, LogEntry."Store Code", JsonHelper.GetJDecimal(SalesLineJsonToken, 'originalUnitPriceSet.presentmentMoney.amount', true),
            CalcLineDiscountAmount(SalesLineJsonToken, IncEcomSalesLine, TotalQty), IncEcomSalesLine);
        IncEcomSalesLine."Line Amount" := IncEcomSalesLine."Unit Price" * IncEcomSalesLine.Quantity - IncEcomSalesLine."Line Discount Amount";
        IncEcomSalesLine."VAT %" := CalculateVAT(SalesLineJsonToken);
    end;

    local procedure FindMembershipItem(SalesLineJsonToken: JsonToken; LogEntry: Record "NPR Spfy Event Log Entry"; var ItemNo: Text[50]; var VariantCode: Code[10])
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        ProductId: Text[30];
        WrongItemErr: Label 'The selected item %1 is not configured as a membership.', Comment = '%1=Item No.';
        NotFoundItemErr: Label 'Item not found for Shopify Product ID %1', Comment = '%1= ShopifyProductID';
    begin
        ProductId := _SpfyAPIOrderHelper.GetNumericId(JsonHelper.GetJText(SalesLineJsonToken, 'product.id', true));
        if not SpfyItemMgt.FindItemByShopifyProductID(LogEntry."Store Code", ProductId, SpfyStoreItemLink) then
            Error(NotFoundItemErr);
        if not IsMembershipItem(SpfyStoreItemLink."Item No.") then
            Error(WrongItemErr);
        ItemNo := SpfyStoreItemLink."Item No.";
        VariantCode := SpfyStoreItemLink."Variant Code";
    end;

    local procedure CalculateVAT(SalesLineJsonToken: JsonToken) VATP: Decimal
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

    local procedure ParseEcommerceSalesLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesLineJsonToken: JsonToken; var IncEcomSalesLine: Record "NPR Ecom Sales Line"; LogEntry: Record "NPR Spfy Event Log Entry")
    var
        NotSupportedLineTypeErr: Label '%1 %2 is not suported', Comment = '%1=IncEcomSalesLine.FieldCaption(Type);%2=IncEcomSalesLine.Type';
    begin
        IncEcomSalesLine."Shopify ID" := _SpfyAPIOrderHelper.GetNumericId(JsonHelper.GetJText(SalesLineJsonToken, 'id', true));
        case IncEcomSalesLine.Type of
            IncEcomSalesLine.Type::Voucher:
                PopulateVoucherLine(EcomSalesHeader, SalesLineJsonToken, IncEcomSalesLine, LogEntry);
            IncEcomSalesLine.Type::Item:
                PopulateItemLine(EcomSalesHeader, SalesLineJsonToken, IncEcomSalesLine, LogEntry);
            IncEcomSalesLine.Type::Membership:
                PopulateMembershipLine(EcomSalesHeader, SalesLineJsonToken, IncEcomSalesLine, LogEntry);
            IncEcomSalesLine.Type::"Shipment Fee":
                PopulateShipmentFeeLine(SalesLineJsonToken, IncEcomSalesLine);
            else
                Error(NotSupportedLineTypeErr, IncEcomSalesLine.FieldCaption(Type), Format(IncEcomSalesLine.Type));
        end;
        SpfyIntegrationEvents.OnAfterParseEcommerceSalesLine(SalesLineJsonToken, IncEcomSalesLine);
    end;

    local procedure EvaluateLineType(SalesLineJsonToken: JsonToken) LineType: Enum "NPR Ecom Sales Line Type";
    begin
        If _SpfyAPIOrderHelper.OrderLineIsGiftCard(SalesLineJsonToken) then
            exit(LineType::Voucher);

        if _SpfyAPIOrderHelper.OrderLineIsMembership(SalesLineJsonToken) then
            exit(LineType::Membership);
        //TODO- TICKET
        exit(LineType::Item);
    end;

    local procedure ReserveVoucher(EcomSalesHeader: Record "NPR Ecom Sales Header"; var IncEcomSalesLine: Record "NPR Ecom Sales Line"; VoucherType: Record "NPR NpRv Voucher Type"; PropertyDict: Dictionary of [Text, Text]; GiftCardId: Text[30])
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        TempVoucher: Record "NPR NpRv Voucher" temporary;
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
        SpfySuspendVouchRefVal: Codeunit "NPR Spfy Suspend Vouch.Ref.Val";
        VoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        VoucherMgt.CheckVoucherTypeQty(VoucherType);
        BindSubscription(SpfySuspendVouchRefVal);
        VoucherMgt.InitVoucher(VoucherType, '', IncEcomSalesLine."Barcode No.", 0DT, false, TempVoucher);
        UnbindSubscription(SpfySuspendVouchRefVal);

        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine.Type := NpRvSalesLine.Type::"New Voucher";
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
        NpRvSalesLine."Voucher Type" := VoucherType.Code;
        NpRvSalesLine."Voucher No." := TempVoucher."No.";
        if IncEcomSalesLine."Barcode No." = '' then
            IncEcomSalesLine."Barcode No." := TempVoucher."Reference No.";
        NpRvSalesLine."Reference No." := IncEcomSalesLine."Barcode No.";
#pragma warning disable AA0139
        NpRvSalesLine."External Document No." := EcomSalesHeader."External No.";
#pragma warning restore AA0139
        NpRvSalesLine.Amount := IncEcomSalesLine."Line Amount";
        NpRvSalesLine.Description := CopyStr(IncEcomSalesLine.Description, 1, MaxStrLen(NpRvSalesLine.Description));
        NpRvSalesLine."Spfy Initiated in Shopify" := not CheckIsNpGiftCard(PropertyDict);
        NpRvSalesLine."Spfy Gift Card ID" := GiftCardId;
        NpRvSalesLine.Validate("Customer No.", EcomSalesHeader."Sell-to Customer No.");
        if PropertyDict.Count <> 0 then
            OrderMgt.UpdateVoucherRecipient(PropertyDict, not NpRvSalesLine."Spfy Initiated in Shopify", NpRvSalesLine);
        NpRvSalesLine.UpdateIsSendViaEmail();
        NpRvSalesLine.Insert();

        NpRvSalesDocMgt.InsertNpRVSalesLineReference(NpRvSalesLine, TempVoucher);
    end;

    local procedure CheckIsNpGiftCard(PropertyDict: Dictionary of [Text, Text]): Boolean
    var
        PropertyValue: Text;
    begin
        if not PropertyDict.Get('is_giftcard', PropertyValue) then
            exit(false);
        exit(PropertyValue <> '0');
    end;

    local procedure SetOrderLineUnitPriceAndDiscount(EcomSalesHeader: Record "NPR Ecom Sales Header"; ShopifyStoreCode: Code[20]; ActualUnitPrice: Decimal; LineDiscountAmount: Decimal; var IncEcomSalesLine: Record "NPR Ecom Sales Line")
    var
        SpfyProductPriceCalc: Codeunit "NPR Spfy Product Price Calc.";
        LineUnitPrice: Decimal;
    begin
        if IncEcomSalesLine.Type = IncEcomSalesLine.Type::Item then begin
            if SpfyIntegrationMgt.OrderLineSalesPriceType(ShopifyStoreCode) = Enum::"NPR Spfy Order Line Price Type"::"Compare-at-Price" then
#pragma warning disable AA0139
                LineUnitPrice := SpfyProductPriceCalc.CalcCompareAtPrice(ShopifyStoreCode, EcomSalesHeader."Currency Code", IncEcomSalesLine."No.", IncEcomSalesLine."Variant Code", EcomSalesHeader."Received Date");
#pragma warning restore AA0139
            if LineUnitPrice < ActualUnitPrice then
                LineUnitPrice := ActualUnitPrice;
            if LineUnitPrice > ActualUnitPrice then
                LineDiscountAmount := LineDiscountAmount + LineUnitPrice * IncEcomSalesLine.Quantity - ActualUnitPrice * IncEcomSalesLine.Quantity;
        end else
            LineUnitPrice := ActualUnitPrice;

        GetGLSetup();
        if Round(IncEcomSalesLine."Unit Price", GLSetup."Unit-Amount Rounding Precision") <> Round(LineUnitPrice, GLSetup."Unit-Amount Rounding Precision") then
            IncEcomSalesLine."Unit Price" := LineUnitPrice;

        if IncEcomSalesLine."Unit Price" <> 0 then
            if Round(IncEcomSalesLine."Line Discount Amount", GLSetup."Amount Rounding Precision") <> Round(LineDiscountAmount, GLSetup."Amount Rounding Precision") then
                IncEcomSalesLine."Line Discount Amount" := LineDiscountAmount;
    end;

    local procedure CalcLineDiscountAmount(OrderLine: JsonToken; var IncEcomSalesLine: Record "NPR Ecom Sales Line"; OriginalOrderQty: Decimal): Decimal
    var
        LineDiscountAmount: Decimal;
    begin
        LineDiscountAmount := CalcLineDiscountAmount(OrderLine);
        if LineDiscountAmount = 0 then
            exit;
        IncEcomSalesLine."Line Discount Amount" := LineDiscountAmount;
        if (IncEcomSalesLine.Quantity < OriginalOrderQty) and (OriginalOrderQty <> 0) then
            IncEcomSalesLine."Line Discount Amount" := LineDiscountAmount / OriginalOrderQty * IncEcomSalesLine.Quantity;

        exit(IncEcomSalesLine."Line Discount Amount");
    end;

    local procedure CalcLineDiscountAmount(OrderLine: JsonToken) LineDiscountAmount: Decimal
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

    local procedure IsMembershipItem(ItemNo: Text[50]): Boolean
    var
        MMMembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        MMMembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        ItemCode: Code[20];
        Found: Boolean;
        NotSupportedItemErr: Label 'Item %1 is setup as both Account and Item type in Membership Sales Setup.';
    begin
        if not Evaluate(ItemCode, ItemNo) then
            exit;
        if MMMembershipSalesSetup.Get(MMMembershipSalesSetup.Type::ACCOUNT, ItemCode) then
            Found := true;

        if MMMembershipSalesSetup.Get(MMMembershipSalesSetup.Type::ITEM, ItemCode) then
            if Found then
                Error(NotSupportedItemErr, ItemNo)
            else
                exit(true);

        MMMembershipAlterationSetup.SetRange("Sales Item No.", ItemCode);
        if MMMembershipAlterationSetup.FindFirst() then
            exit(true);

        exit(false)
    end;

    local procedure InitEcommerceHeader(LogEntry: Record "NPR Spfy Event Log Entry"; var EcomSalesHeader: Record "NPR Ecom Sales Header"; Response: JsonToken)
    var
        SpfyAPIEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        OrderToken: JsonToken;
    begin
        Response.SelectToken('data.order', OrderToken);
        EcomSalesHeader.Init();
        EcomSalesHeader."Document Type" := MapDocumentType(LogEntry);
#pragma warning disable AA0139
        EcomSalesHeader."External No." := LogEntry."Shopify ID";
#pragma warning restore AA0139
        EcomSalesHeader."Ecommerce Store Code" := FindNpEcStore(LogEntry."Store Code", OrderToken);
        EcomSalesHeader."External Document No." := CopyStr((LogEntry."Store Code" + '-' + _SpfyAPIOrderHelper.GetOrderNo(OrderToken)), 1, MaxStrLen(EcomSalesHeader."External Document No."));
        SpfyAPIEventLogMgt.CalculateCurrencyFactor(EcomSalesHeader."Currency Exchange Rate", LogEntry);
        EcomSalesHeader."Currency Code" := LogEntry."Presentment Currency Code";
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

    local procedure ParseEcommerceHeader(var EcomSalesHeader: Record "NPR Ecom Sales Header"; OrderJsonToken: JsonToken): Boolean
    var
        NpEcStore: Record "NPR NpEc Store";
        LocationMapping: Record "NPR Spfy Location Mapping";
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        HeaderToken: JsonToken;
        IsShpmtMappingLocation: Boolean;
        IsShpmtMappingShipAgent: Boolean;
    begin
        OrderJsonToken.SelectToken('data.order', HeaderToken);
        GetEcStore(NpEcStore, EcomSalesHeader);
        GetCustomerAndPostingDate(NpEcStore, EcomSalesHeader, HeaderToken);
        SetShipmentMethod(HeaderToken, EcomSalesHeader, IsShpmtMappingLocation, IsShpmtMappingShipAgent);
        if not (IsShpmtMappingLocation and IsShpmtMappingShipAgent) then begin
            SpfyOrderMgt.FindLocationMapping(NpEcStore, LocationMapping, OrderMgt.GetCountryCode(NpEcStore, HeaderToken, 'shippingAddress.countryCodeV2', false), JsonHelper.GetJCode(HeaderToken, 'shippingAddress.zip', MaxStrLen(LocationMapping."From Post Code"), false));
            if (LocationMapping."Location Code" <> '') and not IsShpmtMappingLocation then
                EcomSalesHeader."Location Code" := LocationMapping."Location Code";
        end;
        SpfyIntegrationEvents.OnAfterParseEcommerceSalesHeader(EcomSalesHeader, HeaderToken);
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

    local procedure SetSellToCustomer(NpEcStore: Record "NPR NpEc Store"; Order: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header"): Boolean
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
        EcomSalesHeader."Sell-to Email" := JsonHelper.GetJText(Order, 'email', MaxStrLen(Customer."E-Mail"), false);
        EcomSalesHeader."Sell-to Phone No." := JsonHelper.GetJText(Order, 'phone', MaxStrLen(Customer."Phone No."), false);
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
        EcomSalesHeader."Sell-to Email" := JsonHelper.GetJText(Order, 'email', MaxStrLen(Customer."E-Mail"), false);
        EcomSalesHeader."Sell-to Phone No." := JsonHelper.GetJText(Order, 'phone', MaxStrLen(Customer."Phone No."), false);
#pragma warning restore AA0139
    end;

    local procedure SetShipToCustomer(NpEcStore: Record "NPR NpEc Store"; Order: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header"): Boolean
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
        EcomSalesHeader."Ship-to Post Code" := EcomSalesHeader."Sell-to Post Code";

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
    end;

    local procedure ClearCache()
    begin
        _SpfyFulfillmentCache.ClearCache();
    end;

    local procedure PostAndDeleteDocument(var LogEntry: Record "NPR Spfy Event Log Entry"; var SalesHeader: Record "Sales Header")
    begin
        if LogEntry.Postponed then
            exit;

        if LogEntry."Posting Status" <> LogEntry."Posting Status"::Invoiced then
            if OrderMgt.CheckThereAreLinesToPost(SalesHeader) then
                if not PostSalesOrder(SalesHeader) then
                    Error(GetLastErrorText());

        if SpfyIntegrationMgt.DeleteAfterFinalPosting(LogEntry."Store Code") then begin
            Commit();
            DeleteDocument(LogEntry);
        end;
    end;

    local procedure PostSalesOrder(var SalesHeader: Record "Sales Header") Success: Boolean
    var
        SalesPost: Codeunit "Sales-Post";
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;

        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        Commit();
        Clear(SalesPost);
        Success := SalesPost.Run(SalesHeader);
    end;

    local procedure CheckIfPaymentLineExists(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line")
    var
        SalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        AlreadyExistsErr: Label 'A payment line with Shopify ID %1 already exists.', comment = '%1=EcomSalesPmtLine."Shopify ID"';
    begin
        SalesPmtLine.SetRange("Shopify ID", EcomSalesPmtLine."Shopify ID");
        if SalesPmtLine.FindFirst() then
            Error(AlreadyExistsErr, EcomSalesPmtLine."Shopify ID");
    end;

    var
        GLSetup: Record "General Ledger Setup";
        JsonHelper: Codeunit "NPR Json Helper";
        _SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        _SpfyEcomSalesDocPrcssr: Codeunit "NPR Spfy Event Log DocProcessr";
        _SpfyAPIOrderHelper: Codeunit "NPR Spfy Order ApiHelper";
        _SpfyFulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache";
        _IncEcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";

        GLSetupRetrived: Boolean;
        NoArrayErr: Label 'The %1 property is not an array.', Locked = true;
}
#endif