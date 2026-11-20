#if not BC17
codeunit 6184821 "NPR Spfy Payment Gateway Hdlr" implements "NPR IPaymentGateway"
{
    Access = Internal;

    var
        _GLSetup: Record "General Ledger Setup";
        _GLSetupRetrieved: Boolean;

    procedure Capture(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        EcomSalesHeader: Record "NPR Ecom Sales Header";
#endif
        PaymentLine: Record "NPR Magento Payment Line";
        TempNcTask: Record "NPR Nc Task" temporary;
        SpfyCapturePayment: Codeunit "NPR Spfy Capture Payment";
        BlockedReason: Text;
    begin
        InitNcTaskFromPmtRequest(Request, PaymentLine, TempNcTask);
        if not CheckPrerequisites(TempNcTask, Response, BlockedReason) then begin
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
            if (PaymentLine."Date Captured" = 0D) and not PaymentLine."Capture Requested" then
                if EcomSalesHeader.GetBySystemId(PaymentLine."NPR Inc Ecom Sale Id") then
                    Error(BlockedReason);
#endif
            exit;
        end;
        if not SpfyCapturePayment.CaptureShopifyPayment(PaymentLine, TempNcTask, Response) then
            Error(GetLastErrorText());
    end;

    procedure Refund(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        TempNcTask: Record "NPR Nc Task" temporary;
        SpfyCapturePayment: Codeunit "NPR Spfy Capture Payment";
    begin
        InitNcTaskFromPmtRequest(Request, PaymentLine, TempNcTask);
        if not SpfyCapturePayment.RefundShopifyPayment(PaymentLine, TempNcTask, Response) then
            Error(GetLastErrorText());
    end;

    procedure Cancel(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        NotSupportedMsg: Label 'Cancellation requests are not supported for Shopify payments. Please try to cancel the payment directly with Shopify.';
    begin
        Message(NotSupportedMsg);
    end;

    procedure RunSetupCard(PaymentGatewayCode: Code[10])
    var
        SpfyPaymentGateway: Record "NPR Spfy Payment Gateway";
    begin
        if not SpfyPaymentGateway.Get(PaymentGatewayCode) then begin
            SpfyPaymentGateway.Init();
            SpfyPaymentGateway.Code := PaymentGatewayCode;
            SpfyPaymentGateway.Insert(true);
            Commit();
        end;

        Page.Run(Page::"NPR Spfy Payment Gateway Card", SpfyPaymentGateway);
    end;

    local procedure InitNcTaskFromPmtRequest(Request: Record "NPR PG Payment Request"; var PaymentLine: Record "NPR Magento Payment Line"; var NcTask: Record "NPR Nc Task")
    var
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        EcomSalesHeader: Record "NPR Ecom Sales Header";
#endif
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvHeader: Record "Sales Invoice Header";
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
#endif
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        SpfyEcomSalesDocPrcssr: Codeunit "NPR Spfy Event Log DocProcessr";
#endif
    begin
        if IsNullGuid(Request."Document System Id") or IsNullGuid(Request."Payment Line System Id") then
            Error('');  //usupported request

        Clear(NcTask);
        case Request."Document Table No." of
            Database::"Sales Header":
                begin
                    if not SalesHeader.GetBySystemId(Request."Document System Id") then
                        Error('');  //doc not found
                    NcTask."Record ID" := SalesHeader.RecordId();
                end;
            Database::"Sales Invoice Header":
                begin
                    SalesInvHeader.GetBySystemId(Request."Document System Id");
                    NcTask."Record ID" := SalesInvHeader.RecordId();
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    SalesCrMemoHeader.GetBySystemId(Request."Document System Id");
                    NcTask."Record ID" := SalesCrMemoHeader.RecordId();
                end;
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
            Database::"NPR Ecom Sales Header":
                begin
                    EcomSalesHeader.GetBySystemId(Request."Document System Id");
                    if SpfyEcomSalesDocPrcssr.GetShopifyLogEntry(EcomSalesHeader, SpfyEventLogEntry) then begin
                        NcTask."Store Code" := SpfyEventLogEntry."Store Code";
                        NcTask."Record Value" := EcomSalesHeader."External No.";
                    end
                end;
#endif
            else
                Error('');  //usupported request
        end;

#if not (BC18 or BC19 or BC20 or BC21)
        PaymentLine.ReadIsolation := IsolationLevel::UpdLock;
#else
        PaymentLine.LockTable();
#endif
        PaymentLine.GetBySystemId(Request."Payment Line System Id");
        if NcTask."Store Code" = '' then
            NcTask."Store Code" := CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(NcTask."Record ID", "NPR Spfy ID Type"::"Store Code"), 1, MaxStrLen(NcTask."Store Code"));
        if NcTask."Record Value" = '' then
            NcTask."Record Value" := CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(NcTask."Record ID", "NPR Spfy ID Type"::"Entry ID"), 1, MaxStrLen(NcTask."Record Value"));
        NcTask."Table No." := Database::"NPR Magento Payment Line";
        NcTask."Record ID" := PaymentLine.RecordId();
    end;

    local procedure CheckPrerequisites(NcTask: Record "NPR Nc Task"; var Response: Record "NPR PG Payment Response"; var BlockedReason: Text): Boolean
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        IntegrationNotEnabledMsg: Label 'Either sending capture requests is disabled, or Shopify integration is not enabled for store %1.', Comment = '%1 - Shopify store code';
    begin
        if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Payment Capture Requests", NcTask."Store Code") then
            exit(true);
        BlockedReason := StrSubstNo(IntegrationNotEnabledMsg, NcTask."Store Code");
        SetResponse(BlockedReason, Response, false, Enum::"NPR PG Operation Status"::Failure);
        if UpdateLastErrorText(BlockedReason) then;
        exit(false);
    end;

    [TryFunction]
    local procedure UpdateLastErrorText(ErrorMsg: Text)
    begin
        Error(ErrorMsg);
    end;

    local procedure SetResponse(ResponseMsg: Text; var Response: Record "NPR PG Payment Response"; Success: Boolean; OperationStatus: Enum "NPR PG Operation Status")
    var
        OStream: OutStream;
    begin
        Response."Response Success" := Success;
        Response."Reported Operation Status" := OperationStatus;
        Response."Response Body".CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText(ResponseMsg);
    end;

#if not (BC18 or BC19 or BC20 or BC21 or BC22)
    /// <summary>
    /// Bills the payment line when this capture attempt confirmed Shopify took the money: it found the capture done, or Shopify reported the capture succeeded.
    /// </summary>
    internal procedure RegisterBillingEventsOnCapture(var PaymentLine: Record "NPR Magento Payment Line"; xPaymentLine: Record "NPR Magento Payment Line"; Response: Record "NPR PG Payment Response"; CaptureFound: Boolean)
    begin
        if xPaymentLine."Date Captured" <> 0D then
            exit;
        if CaptureFound or
           (Response."Response Success" and (Response."Reported Operation Status" = Response."Reported Operation Status"::Success))
        then
            RegisterBillingEventsOnConfirmedCapture(PaymentLine);
    end;

    /// <summary>
    /// Bills a payment line whose capture Shopify confirmed. A posted line is skipped, because posting billed it.
    /// </summary>
    internal procedure RegisterBillingEventsOnConfirmedCapture(var PaymentLine: Record "NPR Magento Payment Line")
    begin
        if PaymentLine.Posted then
            exit;
        RegisterBillingEvents(PaymentLine);
    end;

    internal procedure RegisterBillingEvents(var PaymentLine: Record "NPR Magento Payment Line")
    var
        EventBillingClient: Codeunit "NPR Event Billing Client";
        MetadataJson: JsonObject;
        TransactionID: Text[30];
    begin
        TransactionID := GetShopifyTransactionID(PaymentLine);
        if TransactionID = '' then
            exit;

        MetadataJson.Add('shopify_store_code', GetShopifyStoreCode(PaymentLine));
        MetadataJson.Add('currency', PaymentLine.TransactionCurrencyCode(false));
        // The event ids are stored on the line, so the copy made at posting carries them and registering it again adds nothing.
        // A line re-created for a transaction whose billed line was deleted takes over the ids kept from it.
        // The presentment id is seeded with SystemId, the key used before it was stored, so a line already registered that way is not billed twice.
        if IsNullGuid(PaymentLine."NPR Spfy Ord.Amt.PCY Event Id") and IsNullGuid(PaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id") then
            TakeOverKeptBillingEventIds(PaymentLine, TransactionID);
        if IsNullGuid(PaymentLine."NPR Spfy Ord.Amt.PCY Event Id") then
            PaymentLine."NPR Spfy Ord.Amt.PCY Event Id" := PaymentLine.SystemId;
        EventBillingClient.RegisterEvent(
            PaymentLine."NPR Spfy Ord.Amt.PCY Event Id", Enum::"NPR Billing Event Type"::ECOM_SHOPIFY_ORDERS_AMOUNT_PRESENTMENT, PaymentLine.Amount, MetadataJson.AsToken());

        if PaymentLine."Amount (Store Currency)" <> 0 then begin
            MetadataJson.Replace('currency', PaymentLine."Store Currency Code");
            if IsNullGuid(PaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id") then
                PaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id" := CreateGuid();
            EventBillingClient.RegisterEvent(
                PaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id", Enum::"NPR Billing Event Type"::ECOM_SHOPIFY_ORDERS_AMOUNT_SHOP, PaymentLine."Amount (Store Currency)", MetadataJson.AsToken());
        end;
    end;

    /// <summary>
    /// Keeps the billing event ids of a billed, unposted Shopify payment line that is about to be deleted, so a line re-created for the same transaction is not billed again.
    /// </summary>
    internal procedure KeepBillingEventIds(PaymentLine: Record "NPR Magento Payment Line")
    var
        PmtLineBillingIds: Record "NPR Spfy Pmt. Line Billing Ids";
        TransactionID: Text[30];
    begin
        if PaymentLine.IsTemporary() or PaymentLine.Posted then
            exit;
        if IsNullGuid(PaymentLine."NPR Spfy Ord.Amt.PCY Event Id") and IsNullGuid(PaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id") then
            exit;
        TransactionID := GetShopifyTransactionID(PaymentLine);
        if TransactionID = '' then
            exit;
        if PmtLineBillingIds.Get(TransactionID) then
            exit;
        // With another line of the transaction left, a later line of it cannot be told apart as this one's replacement.
        if OtherUnpostedLineOfTransactionExists(PaymentLine, TransactionID) then
            exit;

        PmtLineBillingIds.Init();
        PmtLineBillingIds."Shopify Transaction ID" := TransactionID;
        PmtLineBillingIds."PCY Event Id" := PaymentLine."NPR Spfy Ord.Amt.PCY Event Id";
        PmtLineBillingIds."Shop Event Id" := PaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id";
        PmtLineBillingIds.Insert();
    end;

    /// <summary>
    /// Keeps the billing event ids of the Shopify payment lines still on an ecommerce document that is about to be deleted. Processing the order again creates new lines for the same transactions.
    /// </summary>
    internal procedure KeepBillingEventIds(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        if EcomSalesHeader.IsTemporary() then
            exit;
        PaymentLine.SetRange("Document Table No.", Database::"NPR Ecom Sales Header");
        PaymentLine.SetRange("Document No.", EcomSalesHeader."External No.");
        PaymentLine.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        if PaymentLine.FindSet() then
            repeat
                KeepBillingEventIds(PaymentLine);
            until PaymentLine.Next() = 0;
    end;

    local procedure OtherUnpostedLineOfTransactionExists(PaymentLine: Record "NPR Magento Payment Line"; TransactionID: Text[30]): Boolean
    var
        OtherPaymentLine: Record "NPR Magento Payment Line";
        SpfyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"NPR Magento Payment Line", "NPR Spfy ID Type"::"Entry ID", TransactionID, SpfyAssignedID);
        if SpfyAssignedID.FindSet() then
            repeat
                if SpfyAssignedID."BC Record ID" <> PaymentLine.RecordId() then
                    if OtherPaymentLine.Get(SpfyAssignedID."BC Record ID") then
                        if not OtherPaymentLine.Posted then
                            if not IsLeftOnDeletedEcomDocument(OtherPaymentLine) then
                                exit(true);
            until SpfyAssignedID.Next() = 0;
    end;

    /// <summary>
    /// Deleting an ecommerce document leaves its payment lines behind. Such a line is no longer a line of its transaction.
    /// </summary>
    local procedure IsLeftOnDeletedEcomDocument(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        if PaymentLine."Document Table No." <> Database::"NPR Ecom Sales Header" then
            exit(false);
        EcomSalesHeader.SetRange(SystemId, PaymentLine."NPR Inc Ecom Sale Id");
        exit(EcomSalesHeader.IsEmpty());
    end;

    /// <summary>
    /// Gives a line without billing event ids the ids kept for its transaction. Called before the line is copied onto an invoice, so the line and every invoice copy carry them.
    /// </summary>
    internal procedure TakeOverKeptBillingEventIds(var PaymentLine: Record "NPR Magento Payment Line")
    var
        PmtLineBillingIds: Record "NPR Spfy Pmt. Line Billing Ids";
        TransactionID: Text[30];
    begin
        if not (IsNullGuid(PaymentLine."NPR Spfy Ord.Amt.PCY Event Id") and IsNullGuid(PaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id")) then
            exit;
        if PmtLineBillingIds.IsEmpty() then
            exit;
        TransactionID := GetShopifyTransactionID(PaymentLine);
        if TransactionID = '' then
            exit;
        TakeOverKeptBillingEventIds(PaymentLine, TransactionID);
    end;

    local procedure TakeOverKeptBillingEventIds(var PaymentLine: Record "NPR Magento Payment Line"; TransactionID: Text[30])
    var
        PmtLineBillingIds: Record "NPR Spfy Pmt. Line Billing Ids";
    begin
        if not PmtLineBillingIds.Get(TransactionID) then
            exit;
        PaymentLine."NPR Spfy Ord.Amt.PCY Event Id" := PmtLineBillingIds."PCY Event Id";
        PaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id" := PmtLineBillingIds."Shop Event Id";
        PmtLineBillingIds.Delete();
    end;

    local procedure GetShopifyTransactionID(PaymentLine: Record "NPR Magento Payment Line"): Text[30]
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        exit(CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(PaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID"), 1, 30));
    end;

    local procedure GetShopifyStoreCode(PaymentLine: Record "NPR Magento Payment Line"): Code[20]
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyEcomSalesDocPrcssr: Codeunit "NPR Spfy Event Log DocProcessr";
        ShopifyStoreCode: Text;
    begin
        case PaymentLine."Document Table No." of
            Database::"Sales Header":
                begin
                    SalesHeader."Document Type" := PaymentLine."Document Type";
                    SalesHeader."No." := PaymentLine."Document No.";
                    ShopifyStoreCode := SpfyAssignedIDMgt.GetAssignedShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code");
                end;
            Database::"Sales Invoice Header":
                begin
                    SalesInvHeader."No." := PaymentLine."Document No.";
                    ShopifyStoreCode := SpfyAssignedIDMgt.GetAssignedShopifyID(SalesInvHeader.RecordId(), "NPR Spfy ID Type"::"Store Code");
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    SalesCrMemoHeader."No." := PaymentLine."Document No.";
                    ShopifyStoreCode := SpfyAssignedIDMgt.GetAssignedShopifyID(SalesCrMemoHeader.RecordId(), "NPR Spfy ID Type"::"Store Code");
                end;
            // A virtual item is captured while its payment line still belongs to the ecommerce document.
            Database::"NPR Ecom Sales Header":
                if EcomSalesHeader.GetBySystemId(PaymentLine."NPR Inc Ecom Sale Id") then
                    if SpfyEcomSalesDocPrcssr.GetShopifyLogEntry(EcomSalesHeader, SpfyEventLogEntry) then
                        ShopifyStoreCode := SpfyEventLogEntry."Store Code";
        end;
        exit(CopyStr(ShopifyStoreCode, 1, 20));
    end;
#endif

    internal procedure TranslateCurrencyCode(ShopifyCurrencyCode: Text): Code[10]
    var
        CurrencyIsLCY: Boolean;
    begin
        exit(TranslateCurrencyCode(ShopifyCurrencyCode, false, CurrencyIsLCY));
    end;

    internal procedure TranslateCurrencyCode(ShopifyCurrencyCode: Text; BlankIfLCY: Boolean; var CurrencyIsLCY: Boolean): Code[10]
    var
        Currency: Record Currency;
    begin
        GetGLSetup();
        if ShopifyCurrencyCode = '' then
            Currency.Code := _GLSetup."LCY Code"
        else begin
            ShopifyCurrencyCode := ShopifyCurrencyCode.ToUpper();
            Currency.SetLoadFields(Code);
            Currency.SetRange("ISO Code", CopyStr(ShopifyCurrencyCode, 1, MaxStrLen(Currency."ISO Code")));
            if not Currency.FindFirst() then
                if not Currency.Get(CopyStr(ShopifyCurrencyCode, 1, MaxStrLen(Currency.Code))) then begin
                    if CopyStr(ShopifyCurrencyCode, 1, MaxStrLen(_GLSetup."LCY Code")) = _GLSetup."LCY Code" then
                        Currency.Code := _GLSetup."LCY Code"
                    else
                        Currency.FindFirst();  //raise error
                end;
        end;
        CurrencyIsLCY := IsLCY(Currency.Code);
        if CurrencyIsLCY and BlankIfLCY then
            exit('');
        exit(Currency.Code);
    end;

    internal procedure CurrencyISOCode(CurrencyCode: Code[10]): Code[3]
    var
        Currency: Record Currency;
    begin
        if CurrencyCode = '' then begin
            GetGLSetup();
            CurrencyCode := _GLSetup."LCY Code";
        end;

        if Currency.Get(CurrencyCode) then
            if Currency."ISO Code" <> '' then
                exit(Currency."ISO Code");

        exit(CopyStr(CurrencyCode, 1, 3));
    end;

    internal procedure IsLCY(CurrencyCode: Code[10]): Boolean
    begin
        if CurrencyCode = '' then
            exit(true);

        GetGLSetup();
        exit(CurrencyCode = _GLSetup."LCY Code");
    end;

    /// <summary>
    /// Refuses a capture of more than the document total minus the other payment lines on the document.
    /// </summary>
    internal procedure CheckCaptureWithinDocumentTotal(PaymentLine: Record "NPR Magento Payment Line")
    var
        OtherPaymentLine: Record "NPR Magento Payment Line";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        DocumentCaption: Text;
        DocumentTotal: Decimal;
        CaptureBeyondDocumentTotalErr: Label 'The payment amount %1 is more than is left to pay on %2 %3: it has %4 to pay and the other payment lines already cover %5. The payment has not been captured.', Comment = '%1 = payment line amount, %2 = document table caption, %3 = document number, %4 = amount including VAT the document has to pay (for an order, the part not invoiced yet), %5 = amount of the other payment lines';
    begin
        case PaymentLine."Document Table No." of
            Database::"Sales Invoice Header":
                begin
                    if not SalesInvHeader.Get(PaymentLine."Document No.") then
                        exit;
                    SalesInvHeader.CalcFields("Amount Including VAT");
                    DocumentTotal := SalesInvHeader."Amount Including VAT";
                    DocumentCaption := SalesInvHeader.TableCaption();
                end;
            Database::"Sales Header":
                begin
                    if not SalesHeader.Get(PaymentLine."Document Type", PaymentLine."Document No.") then
                        exit;
                    DocumentTotal := AmountNotInvoiced(SalesHeader);
                    DocumentCaption := SalesHeader.TableCaption();
                end;
            else
                exit;
        end;

        OtherPaymentLine.SetRange("Document Table No.", PaymentLine."Document Table No.");
        OtherPaymentLine.SetRange("Document Type", PaymentLine."Document Type");
        OtherPaymentLine.SetRange("Document No.", PaymentLine."Document No.");
        OtherPaymentLine.SetFilter("Line No.", '<>%1', PaymentLine."Line No.");
        OtherPaymentLine.SetRange("Points Payment", false);
        OtherPaymentLine.CalcSums(Amount);
        if PaymentLine.Amount > DocumentTotal - OtherPaymentLine.Amount then
            Error(CaptureBeyondDocumentTotalErr, PaymentLine.Amount, DocumentCaption, PaymentLine."Document No.", DocumentTotal, OtherPaymentLine.Amount);
    end;

    /// <summary>
    /// What a Shopify transaction has left for the given document: what is left of it after its refunds, minus what the order's other posted
    /// invoices took from it. A refund a credit document already booked paid back goods those invoices took, so it is added back once.
    /// A refund with no credit document yet stays subtracted: either it never gets one (the goods were never invoiced), or the credit memo
    /// comes later and the refund import applies it to what this document then leaves open.
    /// </summary>
    internal procedure AmountLeftAfterOtherInvoices(SpfyTransactionBuffer: Record "NPR Spfy Transaction Buffer"; OrderTransactions: JsonArray; DocumentTableNo: Integer; DocumentNo: Code[20]): Decimal
    begin
        exit(SmallerOf(
            SpfyTransactionBuffer."Amount (PCY)",
            SpfyTransactionBuffer."Amount (PCY)" - AmountTakenOnOtherInvoices(SpfyTransactionBuffer."Transaction ID", DocumentTableNo, DocumentNo) +
                RefundsOf(OrderTransactions, SpfyTransactionBuffer."Transaction ID", true)));
    end;

    /// <summary>
    /// As AmountLeftAfterOtherInvoices, for what Shopify captured of an authorization. Shopify parents a refund of captured money to the capture, so the refunds of its
    /// captures come off what Shopify captured. While the authorization is still open, an other invoice's line counts only once BC captured it, because only then is
    /// its money among the captures.
    /// </summary>
    local procedure CapturedAmountLeft(OrderTransactions: JsonArray; AuthorizationID: Text[30]; DocumentTableNo: Integer; DocumentNo: Code[20]; AuthorizationIsOpen: Boolean): Decimal
    var
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        OrderTransaction: JsonToken;
        CaptureID: Text[30];
        BookedAmount: Decimal;
        CapturedAmount: Decimal;
        NetAmount: Decimal;
        RefundedAmount: Decimal;
        CaptureKindTok: Label 'CAPTURE', Locked = true;
    begin
        RefundedAmount := RefundsOf(OrderTransactions, AuthorizationID, false);
        BookedAmount := RefundsOf(OrderTransactions, AuthorizationID, true);
        foreach OrderTransaction in OrderTransactions do
            if IsSuccessfulChild(OrderTransaction, CaptureKindTok, AuthorizationID) then begin
                CapturedAmount += JsonHelper.GetJDecimal(OrderTransaction, 'amountSet.presentmentMoney.amount', false);
#pragma warning disable AA0139
                CaptureID := SpfyIntegrationMgt.RemoveUntil(JsonHelper.GetJText(OrderTransaction, 'id', false), '/');
#pragma warning restore AA0139
                RefundedAmount += RefundsOf(OrderTransactions, CaptureID, false);
                BookedAmount += RefundsOf(OrderTransactions, CaptureID, true);
            end;
        NetAmount := CapturedAmount - RefundedAmount;
        exit(SmallerOf(NetAmount, NetAmount - AmountTakenOnOtherInvoices(AuthorizationID, DocumentTableNo, DocumentNo, AuthorizationIsOpen) + BookedAmount));
    end;

    /// <summary>
    /// The successful refunds of a transaction, or only those a credit document already booked.
    /// </summary>
    local procedure RefundsOf(OrderTransactions: JsonArray; ParentTransactionID: Text[30]; OnlyBookedOnCreditDocuments: Boolean) RefundedAmount: Decimal
    var
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        OrderTransaction: JsonToken;
        Counted: Boolean;
        RefundKindTok: Label 'REFUND', Locked = true;
    begin
        foreach OrderTransaction in OrderTransactions do
            if IsSuccessfulChild(OrderTransaction, RefundKindTok, ParentTransactionID) then begin
                Counted := true;
                if OnlyBookedOnCreditDocuments then
#pragma warning disable AA0139
                    Counted := IsBookedOnCreditDocument(SpfyIntegrationMgt.RemoveUntil(JsonHelper.GetJText(OrderTransaction, 'id', false), '/'));
#pragma warning restore AA0139
                if Counted then
                    RefundedAmount += JsonHelper.GetJDecimal(OrderTransaction, 'amountSet.presentmentMoney.amount', false);
            end;
    end;

    /// <summary>
    /// Whether a payment line of a return order, credit memo or posted credit memo carries the refund transaction, as the refund import stamps it.
    /// </summary>
    local procedure IsBookedOnCreditDocument(RefundTransactionID: Text[30]): Boolean
    var
        PaymentLine: Record "NPR Magento Payment Line";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        if RefundTransactionID = '' then
            exit(false);
        SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"NPR Magento Payment Line", "NPR Spfy ID Type"::"Entry ID", RefundTransactionID, ShopifyAssignedID);
        if ShopifyAssignedID.FindSet() then
            repeat
                if PaymentLine.Get(ShopifyAssignedID."BC Record ID") then
                    case PaymentLine."Document Table No." of
                        Database::"Sales Cr.Memo Header":
                            exit(true);
                        Database::"Sales Header":
                            if PaymentLine."Document Type" in [PaymentLine."Document Type"::"Return Order", PaymentLine."Document Type"::"Credit Memo"] then
                                exit(true);
                    end;
            until ShopifyAssignedID.Next() = 0;
        exit(false);
    end;

    /// <summary>
    /// What the payment lines on posted invoices other than the given document already took from a Shopify transaction.
    /// A sales order's own lines are left out: they hold only what its invoices have not taken yet.
    /// </summary>
    local procedure AmountTakenOnOtherInvoices(TransactionID: Text[30]; DocumentTableNo: Integer; DocumentNo: Code[20]): Decimal
    begin
        exit(AmountTakenOnOtherInvoices(TransactionID, DocumentTableNo, DocumentNo, false));
    end;

    local procedure AmountTakenOnOtherInvoices(TransactionID: Text[30]; DocumentTableNo: Integer; DocumentNo: Code[20]; OnlyCapturedLines: Boolean) TakenAmount: Decimal
    var
        PaymentLine: Record "NPR Magento Payment Line";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"NPR Magento Payment Line", "NPR Spfy ID Type"::"Entry ID", TransactionID, ShopifyAssignedID);
        if ShopifyAssignedID.FindSet() then
            repeat
                if PaymentLine.Get(ShopifyAssignedID."BC Record ID") then
                    if (PaymentLine."Document Table No." = Database::"Sales Invoice Header") and
                       ((DocumentTableNo <> Database::"Sales Invoice Header") or (PaymentLine."Document No." <> DocumentNo))
                    then
                        if not OnlyCapturedLines or (PaymentLine."Date Captured" <> 0D) then
                            TakenAmount += PaymentLine.Amount;
            until ShopifyAssignedID.Next() = 0;
    end;

    /// <summary>
    /// What a sales document's payment lines have to cover: for an order, its total minus what its posted invoices already took.
    /// </summary>
    internal procedure AmountNotInvoiced(SalesHeader: Record "Sales Header") Amount: Decimal
    var
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        SalesHeader.CalcFields("Amount Including VAT");
        Amount := SalesHeader."Amount Including VAT";
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;

        SalesInvHeader.SetCurrentKey("Order No.");
        SalesInvHeader.SetRange("Order No.", SalesHeader."No.");
        SalesInvHeader.SetLoadFields("Order No.");
        SalesInvHeader.SetAutoCalcFields("Amount Including VAT");
        if SalesInvHeader.FindSet() then
            repeat
                Amount -= SalesInvHeader."Amount Including VAT";
            until SalesInvHeader.Next() = 0;
    end;

    /// <summary>
    /// Cuts every card line of an open authorization (as CollectOpenAuthorizations sorted them) that BC has not captured yet down to what
    /// the authorization has left, so the lines are sized against what they can really take.
    /// </summary>
    internal procedure CapUncapturedLinesToAuthorizations(var DocPaymentLine: Record "NPR Magento Payment Line"; OpenAuthorizations: Dictionary of [Text, Decimal])
    var
        PaymentLine: Record "NPR Magento Payment Line";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        AuthorizationAmountLeft: Decimal;
    begin
        FilterFittableLines(DocPaymentLine, PaymentLine);
        if PaymentLine.FindSet(true) then
            repeat
                if OpenAuthorizations.Get(SpfyAssignedIDMgt.GetAssignedShopifyID(PaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID"), AuthorizationAmountLeft) then begin
                    if AuthorizationAmountLeft < 0 then
                        AuthorizationAmountLeft := 0;
                    if PaymentLine.Amount > AuthorizationAmountLeft then
                        SetUncapturedLineAmount(PaymentLine, AuthorizationAmountLeft);
                end;
            until PaymentLine.Next() = 0;
    end;

    /// <summary>
    /// Brings the lines of money Shopify already took (gift cards, sales, captured authorizations, and what BC captured of an open authorization)
    /// in line with what each transaction has left after its refunds and other invoices, on an unposted order or invoice. While the lines exceed
    /// what the document has left to invoice, a transaction's lines are cut, last line first, until together they hold no more than the transaction
    /// has left. A voucher line BC already redeemed at capture counts toward its transaction but is never cut. Card lines BC may still fit
    /// (uncaptured, unrequested open authorizations) are fitted afterwards, so they are left out. A refund within the order total stays for its
    /// credit memo. Whether or not anything was cut, no line asks for more than its transaction has left, so a release cannot grow it back.
    /// </summary>
    internal procedure CutRefundedSettledLines(var DocPaymentLine: Record "NPR Magento Payment Line"; DocumentTableNo: Integer; DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]; DocumentTotal: Decimal; var SpfyTransactionBuffer: Record "NPR Spfy Transaction Buffer"; OrderTransactions: JsonArray; OpenAuthorizations: Dictionary of [Text, Decimal]; CapturedAuthorizations: Dictionary of [Text, Decimal])
    var
        PaymentLine: Record "NPR Magento Payment Line";
        TransactionHeld: Dictionary of [Text, Decimal];
        TransactionLeft: Dictionary of [Text, Decimal];
        CapturedOpenAuthorizations: List of [Text];
        TransactionIDs: List of [Text];
        TransactionID: Text[30];
        TransactionKey: Text;
        Cut: Decimal;
        Excess: Decimal;
        Pass: Integer;
    begin
        // A posted invoice's lines are booked; a refund after posting goes through a credit memo. A credit document's lines are refunds.
        if DocumentTableNo <> Database::"Sales Header" then
            exit;
        if not (DocumentType in [DocumentType::Order, DocumentType::Invoice]) then
            exit;

        foreach TransactionKey in OpenAuthorizations.Keys() do
            if SuccessfullyCapturedAmount(OrderTransactions, CopyStr(TransactionKey, 1, MaxStrLen(TransactionID))) > 0 then
                CapturedOpenAuthorizations.Add(TransactionKey);

        // One transaction can have several lines on the document, for example a gift card line BC captured for virtual items and one for the rest.
        PaymentLine.CopyFilters(DocPaymentLine);
        PaymentLine.SetRange(Posted, false);
        PaymentLine.Ascending(false);
        if PaymentLine.FindSet() then
            repeat
                if SettledTransactionOfLine(PaymentLine, SpfyTransactionBuffer, OpenAuthorizations, CapturedAuthorizations, CapturedOpenAuthorizations, TransactionID) then begin
                    if not TransactionLeft.ContainsKey(TransactionID) then begin
                        TransactionLeft.Add(TransactionID, SettledAmountLeft(TransactionID, DocumentTableNo, DocumentNo, SpfyTransactionBuffer, OrderTransactions, OpenAuthorizations, CapturedAuthorizations));
                        TransactionHeld.Add(TransactionID, 0);
                        TransactionIDs.Add(TransactionID);
                    end;
                    TransactionHeld.Set(TransactionID, TransactionHeld.Get(TransactionID) + PaymentLine.Amount);
                end;
            until PaymentLine.Next() = 0;

        DocPaymentLine.CalcSums(Amount);
        Excess := DocPaymentLine.Amount - AmountOnOpenAuthorizationLines(DocPaymentLine, OpenAuthorizations) - DocumentTotal;
        // Transactions with nothing left give way first, so their room is never taken from a partly refunded one.
        for Pass := 1 to 2 do
            foreach TransactionKey in TransactionIDs do
                if (Excess > 0) and ((Pass = 1) = (TransactionLeft.Get(TransactionKey) = 0)) then begin
                    Cut := CutTransactionLines(DocPaymentLine, TransactionKey, SmallerOf(TransactionHeld.Get(TransactionKey) - TransactionLeft.Get(TransactionKey), Excess), SpfyTransactionBuffer, OpenAuthorizations, CapturedAuthorizations, CapturedOpenAuthorizations);
                    TransactionHeld.Set(TransactionKey, TransactionHeld.Get(TransactionKey) - Cut);
                    Excess -= Cut;
                end;

        foreach TransactionKey in TransactionIDs do
            CapRequestedAmounts(DocPaymentLine, TransactionKey, TransactionLeft.Get(TransactionKey) - TransactionHeld.Get(TransactionKey), SpfyTransactionBuffer, OpenAuthorizations, CapturedAuthorizations, CapturedOpenAuthorizations);
    end;

    /// <summary>
    /// The Shopify transaction of money already taken that the line holds. On an authorization Shopify still holds open, only a line BC captured
    /// holds money taken, and only once Shopify reports a capture of it (a line marked captured with no capture took nothing yet); the other
    /// lines are fitted to the document afterwards. False for a line without a transaction in the buffer.
    /// </summary>
    local procedure SettledTransactionOfLine(PaymentLine: Record "NPR Magento Payment Line"; var SpfyTransactionBuffer: Record "NPR Spfy Transaction Buffer"; OpenAuthorizations: Dictionary of [Text, Decimal]; CapturedAuthorizations: Dictionary of [Text, Decimal]; CapturedOpenAuthorizations: List of [Text]; var TransactionID: Text[30]): Boolean
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        TransactionID := CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(PaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID"), 1, MaxStrLen(TransactionID));
        if TransactionID = '' then
            exit(false);
        if OpenAuthorizations.ContainsKey(TransactionID) then
            exit((PaymentLine."Date Captured" <> 0D) and CapturedOpenAuthorizations.Contains(TransactionID));
        if CapturedAuthorizations.ContainsKey(TransactionID) then
            exit(true);
        exit(SpfyTransactionBuffer.Get(TransactionID));
    end;

    /// <summary>
    /// What a transaction of money Shopify has already taken has left for the document after its refunds and other invoices, never below zero.
    /// </summary>
    local procedure SettledAmountLeft(TransactionID: Text[30]; DocumentTableNo: Integer; DocumentNo: Code[20]; var SpfyTransactionBuffer: Record "NPR Spfy Transaction Buffer"; OrderTransactions: JsonArray; OpenAuthorizations: Dictionary of [Text, Decimal]; CapturedAuthorizations: Dictionary of [Text, Decimal]) AmountLeft: Decimal
    begin
        if OpenAuthorizations.ContainsKey(TransactionID) then
            AmountLeft := CapturedAmountLeft(OrderTransactions, TransactionID, DocumentTableNo, DocumentNo, true)
        else
            if CapturedAuthorizations.ContainsKey(TransactionID) then
                AmountLeft := CapturedAmountLeft(OrderTransactions, TransactionID, DocumentTableNo, DocumentNo, false)
            else begin
                SpfyTransactionBuffer.Get(TransactionID);
                AmountLeft := AmountLeftAfterOtherInvoices(SpfyTransactionBuffer, OrderTransactions, DocumentTableNo, DocumentNo);
            end;
        if AmountLeft < 0 then
            AmountLeft := 0;
    end;

    /// <summary>
    /// Cuts the transaction's lines, last line first, by up to the given amount, and returns what was cut.
    /// </summary>
    local procedure CutTransactionLines(var DocPaymentLine: Record "NPR Magento Payment Line"; TransactionKey: Text; CutWanted: Decimal; var SpfyTransactionBuffer: Record "NPR Spfy Transaction Buffer"; OpenAuthorizations: Dictionary of [Text, Decimal]; CapturedAuthorizations: Dictionary of [Text, Decimal]; CapturedOpenAuthorizations: List of [Text]) Cut: Decimal
    var
        PaymentLine: Record "NPR Magento Payment Line";
        TransactionID: Text[30];
        LineCut: Decimal;
    begin
        if CutWanted <= 0 then
            exit(0);
        PaymentLine.CopyFilters(DocPaymentLine);
        PaymentLine.SetRange(Posted, false);
        PaymentLine.Ascending(false);
        if PaymentLine.FindSet(true) then
            repeat
                if IsCuttable(PaymentLine) and (PaymentLine.Amount > 0) then
                    if SettledTransactionOfLine(PaymentLine, SpfyTransactionBuffer, OpenAuthorizations, CapturedAuthorizations, CapturedOpenAuthorizations, TransactionID) then
                        if TransactionID = TransactionKey then begin
                            LineCut := SmallerOf(PaymentLine.Amount, CutWanted - Cut);
                            CutSettledLine(PaymentLine, LineCut);
                            Cut += LineCut;
                        end;
            until (PaymentLine.Next() = 0) or (Cut >= CutWanted);
    end;

    /// <summary>
    /// Lowers the requested amount of the transaction's lines, first line first, so that together they ask for no more than the transaction has
    /// left beyond what they hold. A line keeps asking for at least its amount: a refund within the order total stays for its credit memo.
    /// </summary>
    local procedure CapRequestedAmounts(var DocPaymentLine: Record "NPR Magento Payment Line"; TransactionKey: Text; Room: Decimal; var SpfyTransactionBuffer: Record "NPR Spfy Transaction Buffer"; OpenAuthorizations: Dictionary of [Text, Decimal]; CapturedAuthorizations: Dictionary of [Text, Decimal]; CapturedOpenAuthorizations: List of [Text])
    var
        PaymentLine: Record "NPR Magento Payment Line";
        TransactionID: Text[30];
        NewRequestedAmount: Decimal;
        RequestedAmount: Decimal;
    begin
        if Room < 0 then
            Room := 0;
        PaymentLine.CopyFilters(DocPaymentLine);
        PaymentLine.SetRange(Posted, false);
        if PaymentLine.FindSet(true) then
            repeat
                if IsCuttable(PaymentLine) then
                    if SettledTransactionOfLine(PaymentLine, SpfyTransactionBuffer, OpenAuthorizations, CapturedAuthorizations, CapturedOpenAuthorizations, TransactionID) then
                        if TransactionID = TransactionKey then begin
                            RequestedAmount := PaymentLine."Requested Amount";
                            if RequestedAmount = 0 then
                                RequestedAmount := PaymentLine.Amount;
                            NewRequestedAmount := SmallerOf(RequestedAmount, PaymentLine.Amount + Room);
                            if NewRequestedAmount < PaymentLine.Amount then
                                NewRequestedAmount := PaymentLine.Amount;
                            Room -= NewRequestedAmount - PaymentLine.Amount;
                            if NewRequestedAmount < RequestedAmount then begin
                                FillUnsetRequestedAmounts(PaymentLine);
                                SetRequestedAmount(PaymentLine, NewRequestedAmount);
                                PaymentLine.Modify(true);
                            end;
                        end;
            until PaymentLine.Next() = 0;
    end;

    /// <summary>
    /// A voucher line BC captured has been redeemed from the voucher already, so its amount is booked.
    /// </summary>
    local procedure IsCuttable(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    begin
        exit(not ((PaymentLine."Payment Type" = PaymentLine."Payment Type"::Voucher) and (PaymentLine."Date Captured" <> 0D)));
    end;

    /// <summary>
    /// Shopify gave the cut back, so the line asks for no more than it still holds and a release cannot grow it back. A voucher's reservation
    /// follows the line.
    /// </summary>
    local procedure CutSettledLine(var PaymentLine: Record "NPR Magento Payment Line"; Cut: Decimal)
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        SalesHeader: Record "Sales Header";
        NpRvModulePayPartial: Codeunit "NPR NpRv Module Pay. - Partial";
    begin
        FillUnsetRequestedAmounts(PaymentLine);
        PaymentLine.SetAmountKeepingStoreCurrency(PaymentLine.Amount - Cut);
        SetRequestedAmount(PaymentLine, PaymentLine.Amount);
        PaymentLine.Modify(true);

        if PaymentLine."Payment Type" <> PaymentLine."Payment Type"::Voucher then
            exit;
        NpRvSalesLine.SetCurrentKey("Document Source", "Document Type", "Document No.", "Document Line No.");
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLine.SetRange("Document Type", PaymentLine."Document Type");
        NpRvSalesLine.SetRange("Document No.", PaymentLine."Document No.");
        NpRvSalesLine.SetRange("Document Line No.", PaymentLine."Line No.");
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
        NpRvSalesLine.SetRange(Posted, false);
        if NpRvSalesLine.FindFirst() then
            if SalesHeader.Get(PaymentLine."Document Type", PaymentLine."Document No.") then
                NpRvModulePayPartial.KeepReservationInStep(NpRvSalesLine, PaymentLine, SalesHeader);
    end;

    /// <summary>
    /// A line that never had its requested amounts set asks for its amounts, as the voucher release reads it. The Ecommerce document creates
    /// voucher lines that way.
    /// </summary>
    local procedure FillUnsetRequestedAmounts(var PaymentLine: Record "NPR Magento Payment Line")
    begin
        if PaymentLine."Requested Amount" = 0 then
            PaymentLine."Requested Amount" := PaymentLine.Amount;
        if PaymentLine."Requested Amt. (Store Curr.)" = 0 then
            PaymentLine."Requested Amt. (Store Curr.)" := PaymentLine."Amount (Store Currency)";
    end;

    /// <summary>
    /// Sets the requested amount and scales the requested store currency amount with it, at the rate of the requested amounts.
    /// </summary>
    local procedure SetRequestedAmount(var PaymentLine: Record "NPR Magento Payment Line"; NewRequestedAmount: Decimal)
    begin
        if PaymentLine."Requested Amount" <> 0 then
            PaymentLine."Requested Amt. (Store Curr.)" := PaymentLine.RoundStoreCurrencyAmount(PaymentLine."Requested Amt. (Store Curr.)" * NewRequestedAmount / PaymentLine."Requested Amount");
        PaymentLine."Requested Amount" := NewRequestedAmount;
    end;

    /// <summary>
    /// Fits the card lines of open authorizations that BC has not captured yet to what the document has to pay: cuts them, last line first,
    /// while the payment lines add up to more, and on a sales order grows them back, first line first and up to their requested amount and
    /// what the authorization has left, while they add up to less.
    /// </summary>
    internal procedure FitUncapturedLinesToDocumentTotal(var DocPaymentLine: Record "NPR Magento Payment Line"; DocumentTotal: Decimal; DocumentTableNo: Integer; OpenAuthorizations: Dictionary of [Text, Decimal])
    var
        PaymentLine: Record "NPR Magento Payment Line";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        AuthorizationAmountLeft: Decimal;
        Change: Decimal;
        Difference: Decimal;
    begin
        DocPaymentLine.CalcSums(Amount);
        Difference := DocumentTotal - DocPaymentLine.Amount;
        // An invoice's total never grows after posting, so only an order's lines are grown back.
        if (Difference = 0) or ((Difference > 0) and (DocumentTableNo <> Database::"Sales Header")) then
            exit;

        FilterFittableLines(DocPaymentLine, PaymentLine);
        PaymentLine.Ascending(Difference > 0);
        if PaymentLine.FindSet(true) then
            repeat
                if OpenAuthorizations.Get(SpfyAssignedIDMgt.GetAssignedShopifyID(PaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID"), AuthorizationAmountLeft) then begin
                    if Difference < 0 then
                        Change := -SmallerOf(PaymentLine.Amount, -Difference)
                    else
                        Change := SmallerOf(SmallerOf(PaymentLine."Requested Amount", AuthorizationAmountLeft) - PaymentLine.Amount, Difference);
                    if ((Difference < 0) and (Change < 0)) or ((Difference > 0) and (Change > 0)) then begin
                        SetUncapturedLineAmount(PaymentLine, PaymentLine.Amount + Change);
                        Difference -= Change;
                    end;
                end;
            until (PaymentLine.Next() = 0) or (Difference = 0);
    end;

    /// <summary>
    /// Sorts the authorizations, each with what is left of it for this document after what the order's other invoices already took.
    /// Open ones, whose lines BC may still fit to the document, are limited to what Shopify reports unsettled; one with nothing unsettled
    /// and nothing captured (voided or expired) is open with nothing left. Captured ones are money taken, limited to what Shopify captured.
    /// </summary>
    internal procedure CollectOpenAuthorizations(var SpfyTransactionBuffer: Record "NPR Spfy Transaction Buffer"; OrderTransactions: JsonArray; DocumentTableNo: Integer; DocumentNo: Code[20]; var OpenAuthorizations: Dictionary of [Text, Decimal]; var CapturedAuthorizations: Dictionary of [Text, Decimal])
    var
        IStream: InStream;
        Transaction: JsonToken;
        UnsettledToken: JsonToken;
        AmountLeft: Decimal;
        CapturedAmount: Decimal;
        AuthorizationKindTok: Label 'AUTHORIZATION', Locked = true;
    begin
        SpfyTransactionBuffer.SetFilter("Amount (PCY)", '>0');
        SpfyTransactionBuffer.SetRange(Kind, AuthorizationKindTok);
        if SpfyTransactionBuffer.FindSet() then
            repeat
                SpfyTransactionBuffer.CalcFields("Transaction Json");
                SpfyTransactionBuffer."Transaction Json".CreateInStream(IStream, TextEncoding::UTF8);
                Transaction.ReadFrom(IStream);
                AmountLeft := AmountLeftAfterOtherInvoices(SpfyTransactionBuffer, OrderTransactions, DocumentTableNo, DocumentNo);
                if not Transaction.SelectToken('totalUnsettledSet.presentmentMoney.amount', UnsettledToken) then
                    OpenAuthorizations.Set(SpfyTransactionBuffer."Transaction ID", AmountLeft)
                else
                    if UnsettledToken.AsValue().IsNull() then
                        OpenAuthorizations.Set(SpfyTransactionBuffer."Transaction ID", AmountLeft)
                    else
                        if UnsettledToken.AsValue().AsDecimal() > 0 then
                            OpenAuthorizations.Set(SpfyTransactionBuffer."Transaction ID", SmallerOf(AmountLeft, UnsettledToken.AsValue().AsDecimal()))
                        else begin
                            CapturedAmount := SuccessfullyCapturedAmount(OrderTransactions, SpfyTransactionBuffer."Transaction ID");
                            if CapturedAmount > 0 then
                                CapturedAuthorizations.Set(SpfyTransactionBuffer."Transaction ID", CapturedAmount - AmountTakenOnOtherInvoices(SpfyTransactionBuffer."Transaction ID", DocumentTableNo, DocumentNo))
                            else
                                OpenAuthorizations.Set(SpfyTransactionBuffer."Transaction ID", 0);
                        end;
            until SpfyTransactionBuffer.Next() = 0;
        SpfyTransactionBuffer.Reset();
    end;

    local procedure SuccessfullyCapturedAmount(OrderTransactions: JsonArray; AuthorizationID: Text[30]) CapturedAmount: Decimal
    var
        JsonHelper: Codeunit "NPR Json Helper";
        OrderTransaction: JsonToken;
        CaptureKindTok: Label 'CAPTURE', Locked = true;
    begin
        foreach OrderTransaction in OrderTransactions do
            if IsSuccessfulChild(OrderTransaction, CaptureKindTok, AuthorizationID) then
                CapturedAmount += JsonHelper.GetJDecimal(OrderTransaction, 'amountSet.presentmentMoney.amount', false);
    end;

    /// <summary>
    /// Whether an order transaction is a successful transaction of the given kind made against the given parent transaction.
    /// </summary>
    local procedure IsSuccessfulChild(OrderTransaction: JsonToken; Kind: Text; ParentTransactionID: Text[30]): Boolean
    var
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SuccessStatusTok: Label 'SUCCESS', Locked = true;
    begin
        if JsonHelper.GetJText(OrderTransaction, 'kind', false).ToUpper() <> Kind then
            exit(false);
        if JsonHelper.GetJText(OrderTransaction, 'status', false).ToUpper() <> SuccessStatusTok then
            exit(false);
        exit(SpfyIntegrationMgt.RemoveUntil(JsonHelper.GetJText(OrderTransaction, 'parentTransaction.id', false), '/') = ParentTransactionID);
    end;

    /// <summary>
    /// What the lines the fitting step may cut hold on the document, which money Shopify has already taken may use before they are cut.
    /// </summary>
    internal procedure AmountOnOpenAuthorizationLines(var DocPaymentLine: Record "NPR Magento Payment Line"; OpenAuthorizations: Dictionary of [Text, Decimal]) Amount: Decimal
    var
        PaymentLine: Record "NPR Magento Payment Line";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        FilterFittableLines(DocPaymentLine, PaymentLine);
        if PaymentLine.FindSet() then
            repeat
                if OpenAuthorizations.ContainsKey(SpfyAssignedIDMgt.GetAssignedShopifyID(PaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID")) then
                    Amount += PaymentLine.Amount;
            until PaymentLine.Next() = 0;
    end;

    local procedure FilterFittableLines(var DocPaymentLine: Record "NPR Magento Payment Line"; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        PaymentLine.CopyFilters(DocPaymentLine);
        PaymentLine.SetRange("Payment Type", PaymentLine."Payment Type"::"Payment Method");
        PaymentLine.SetRange(Posted, false);
        PaymentLine.SetRange("Date Captured", 0D);
        PaymentLine.SetRange("Capture Requested", false);
    end;

    local procedure SetUncapturedLineAmount(var PaymentLine: Record "NPR Magento Payment Line"; NewAmount: Decimal)
    var
        Currency: Record Currency;
    begin
        if not Currency.Get(PaymentLine."Store Currency Code") then
            Currency.InitRoundingPrecision();
        if (PaymentLine."Requested Amount" <> 0) and (PaymentLine."Requested Amt. (Store Curr.)" <> 0) then
            PaymentLine."Amount (Store Currency)" := Round(PaymentLine."Requested Amt. (Store Curr.)" * NewAmount / PaymentLine."Requested Amount", Currency."Amount Rounding Precision")
        else
            if PaymentLine.Amount <> 0 then
                PaymentLine."Amount (Store Currency)" := Round(PaymentLine."Amount (Store Currency)" * NewAmount / PaymentLine.Amount, Currency."Amount Rounding Precision");
        PaymentLine.Amount := NewAmount;
        PaymentLine.Modify(true);
    end;

    local procedure SmallerOf(A: Decimal; B: Decimal): Decimal
    begin
        if A < B then
            exit(A);
        exit(B);
    end;

    local procedure GetGLSetup()
    begin
        if _GLSetupRetrieved then
            exit;
        _GLSetupRetrieved := true;
        if not _GLSetup.Get() then
            _GLSetup.Init();
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Payment Gateway", 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Payment Gateway", OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure RemoveShopifyPaymentGatewaySetup(var Rec: Record "NPR Magento Payment Gateway")
    var
        SpfyPaymentGateway: Record "NPR Spfy Payment Gateway";
    begin
        if Rec.IsTemporary() then
            exit;

        if SpfyPaymentGateway.Get(Rec.Code) then
            SpfyPaymentGateway.Delete(true);
    end;
}
#endif