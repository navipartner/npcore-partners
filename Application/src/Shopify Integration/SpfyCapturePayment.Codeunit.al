#if not BC17
codeunit 6184804 "NPR Spfy Capture Payment"
{
    Access = Internal;

    TableNo = "NPR Nc Task";

    var
        Currency: Record Currency;
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
        SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
        CurrencyRetrieved: Boolean;

    trigger OnRun()
    var
        Success: Boolean;
    begin
        Rec.TestField("Table No.", Rec."Record ID".TableNo);
        case Rec."Table No." of
            Database::"Sales Invoice Header":
                begin
                    Success := UpdatePmtLinesAndScheduleCapture(Rec, true, false);
                    Rec.Modify();
                    Commit();
                    if not Success then
                        Error(GetLastErrorText);
                end;
            Database::"NPR Magento Payment Line":
                begin
                    case Rec.Type of
                        Rec.type::Insert:
                            CaptureShopifyPayment(Rec, true);
                        Rec.type::Delete:
                            RefundShopifyPayment(Rec, true);
                    end;
                end;
        end;
    end;

    internal procedure CaptureShopifyPayment(var NcTask: Record "NPR Nc Task"; SaveToDb: Boolean) Success: Boolean
    var
        PaymentLine: Record "NPR Magento Payment Line";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        RecRef: RecordRef;
        ShopifyResponse: JsonToken;
        SendToShopify: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();
        Success := false;

        SendToShopify := PrepareShopifyPaymentCaptureRequest(NcTask);
        if SendToShopify then
            Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, true, ShopifyResponse);

        if SaveToDb then begin
            NcTask.Modify();
            Commit();
            if Success then begin
                if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
                    Error('');
                if JsonHelper.GetJText(ShopifyResponse, 'data.orderCapture.transaction.status', true).ToUpper() <> 'SUCCESS' then
                    Error('');

                RecRef.Get(NcTask."Record ID");
                RecRef.SetTable(PaymentLine);
                if PaymentLine.Find() then begin
                    PaymentLine."Date Captured" := Today();
                    PaymentLine.Modify();
                    Commit();
                    SpfyIntegrationEvents.OnModifyPaymentLineAfterCaptureIsolated(PaymentLine, NcTask);
                    if not PaymentLine.Posted then begin
                        Commit();
                        ClearLastError();
                        if not Codeunit.Run(Codeunit::"NPR Magento Post Payment Line", PaymentLine) then
                            AddPostingErrorMessageToNcTask(NcTask);
                    end;
                end;
            end;
        end;

        if SendToShopify and not Success then
            Error(GetLastErrorText());
        ClearLastError();
        if SaveToDb then
            exit;

        if SendToShopify and Success then begin
            Success := not SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse);
            if Success then
                Success := JsonHelper.GetJText(ShopifyResponse, 'data.orderCapture.transaction.status', true).ToUpper() = 'SUCCESS';
        end;
    end;

    internal procedure RefundShopifyPayment(var NcTask: Record "NPR Nc Task"; SaveToDb: Boolean) Success: Boolean
    var
        RefundNotSupportedErr: Label 'Refunding Shopify payments from Business Central is not supported yet. Please use the Shopify admin interface to process refunds.';
    begin
        //TODO: Implement refunding of Shopify payments
        Error(RefundNotSupportedErr);
    end;

    [TryFunction]
    local procedure TryGetShopifyOrderTransactions(var NcTask: Record "NPR Nc Task"; var ShopifyResponse: JsonToken)
    begin
        GetShopifyOrderTransactions(NcTask, ShopifyResponse);
    end;

    local procedure GetShopifyOrderTransactions(var NcTask: Record "NPR Nc Task"; var ShopifyResponse: JsonToken): Boolean
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        OStream: OutStream;
        Request: JsonObject;
        Variables: JsonObject;
        QueryTok: Label 'query OrderTransactions($orderId: ID!) {order(id: $orderId){currencyCode presentmentCurrencyCode transactions(first: 250){id kind amountSet{presentmentMoney{amount currencyCode} shopMoney{amount currencyCode}} amountRoundingSet{presentmentMoney{amount currencyCode} shopMoney{amount currencyCode}} authorizationCode authorizationExpiresAt createdAt formattedGateway gateway multiCapturable parentTransaction{id kind} paymentId processedAt settlementCurrency settlementCurrencyRate status test totalUnsettledSet{presentmentMoney{amount currencyCode} shopMoney{amount currencyCode}} paymentDetails {... on CardPaymentDetails{avsResultCode bin company expirationMonth expirationYear name number paymentMethodName wallet} ... on LocalPaymentMethodsPaymentDetails{paymentDescriptor paymentMethodName}} receiptJson}}}', Locked = true;
    begin
        Variables.Add('orderId', 'gid://shopify/Order/' + NcTask."Record Value");
        Request.Add('query', QueryTok);
        Request.Add('variables', Variables);

        NcTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        Request.WriteTo(OStream);
        ClearLastError();
        if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse) then
            Error(GetLastErrorText);
    end;

    local procedure PrepareShopifyPaymentCaptureRequest(var NcTask: Record "NPR Nc Task") SendToShopify: Boolean
    var
        PaymentLine: Record "NPR Magento Payment Line";
        SpfyPaymentGateway: Record "NPR Spfy Payment Gateway";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
        Request: JsonObject;
        Variables: JsonObject;
        Transaction: JsonObject;
        QueryStream: OutStream;
        TransactionID: Text[30];
        AlreadyCapturedErr: Label 'The payment transaction has already been marked as captured in Shopify.';
        IsNotShopifyPmtLineErr: Label '%1 does not seem to be a Shopify related payment transaction', Comment = '%1 - Payment Line record Id';
        QueryTok: Label 'mutation TransactionCreate($input: OrderCaptureInput!) {orderCapture(input: $input) {transaction {id kind status parentTransaction{id} amountSet{presentmentMoney{amount currencyCode} shopMoney{amount currencyCode}} paymentId receiptJson settlementCurrency settlementCurrencyRate test} userErrors {message}}}', Locked = true;
    begin
        if NcTask."Table No." <> Database::"NPR Magento Payment Line" then
            SpfyIntegrationMgt.UnsupportedIntegrationTable(NcTask, StrSubstNo('CU%1.%2', Format(Codeunit::"NPR Spfy Capture Payment"), 'PrepareCaptureRequest'));

        RecRef.Get(NcTask."Record ID");
        RecRef.SetTable(PaymentLine);
        if not IsShopifyPaymentLine(PaymentLine) then
            Error(IsNotShopifyPmtLineErr, PaymentLine.RecordId());
        TransactionID := SpfyAssignedIDMgt.GetAssignedShopifyID(PaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if TransactionID = '' then
            Error(IsNotShopifyPmtLineErr, PaymentLine.RecordId());

        PaymentLine.TestField("Date Captured", 0D);
        if TransactionAlreadyCaptured(NcTask, TransactionID, PaymentLine) then begin
            SpfyIntegrationMgt.SetResponse(NcTask, AlreadyCapturedErr);
            exit;
        end;
        PaymentLine.TestField(Amount);
        PaymentLine.TestField("Payment Gateway Code");
        if not SpfyPaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            SpfyPaymentGateway.Init();

        Transaction.Add('amount', PaymentLine.Amount);
        Transaction.Add('currency', SpfyPaymentGatewayHdlr.CurrencyISOCode(PaymentLine.TransactionCurrencyCode(true)));
        if SpfyPaymentGateway."Identify Final Capture" then
            Transaction.Add('finalCapture', IsFinalCapture(PaymentLine, TransactionID));
        Transaction.Add('id', 'gid://shopify/Order/' + NcTask."Record Value");
        Transaction.Add('parentTransactionId', 'gid://shopify/OrderTransaction/' + TransactionID);

        Variables.Add('input', Transaction);
        Request.Add('query', QueryTok);
        Request.Add('variables', Variables);

        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        Request.WriteTo(QueryStream);
        SendToShopify := true;
    end;

    local procedure TransactionAlreadyCaptured(NcTask: Record "NPR Nc Task"; TransactionID: Text[30]; var PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        ShopifyResponse: JsonToken;
        Transaction: JsonToken;
        Transactions: JsonToken;
    begin
        GetShopifyOrderTransactions(NcTask, ShopifyResponse);
        ShopifyResponse.SelectToken('data.order.transactions', Transactions);
        if Transactions.IsArray() then
            foreach Transaction in Transactions.AsArray() do
                if TransactionID = SpfyIntegrationMgt.RemoveUntil(JsonHelper.GetJText(Transaction, 'id', true), '/') then begin
                    SetDateAuthorized(Transaction, PaymentLine);
                    SetPaymentCardDetails(Transaction, PaymentLine);
                    if PaymentLine."Transaction ID" = '' then
#pragma warning disable AA0139
                        PaymentLine."Transaction ID" := JsonHelper.GetJText(Transaction, 'paymentId', false);
#pragma warning restore AA0139
                    if PaymentLine."Posting Date" = 0D then
                        PaymentLine."Posting Date" := Today();
                    exit(SetPmtLineAsCaptured(Transaction, Transactions.AsArray(), '', TransactionID, PaymentLine));
                end;
    end;

    local procedure IsFinalCapture(PaymentLine: Record "NPR Magento Payment Line"; TransactionID: Text[30]): Boolean
    var
        PaymentLine2: Record "NPR Magento Payment Line";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"NPR Magento Payment Line", "NPR Spfy ID Type"::"Entry ID", TransactionID, ShopifyAssignedID);
        if ShopifyAssignedID.FindSet() then
            repeat
                if PaymentLine2.Get(ShopifyAssignedID."BC Record ID") then
                    if (PaymentLine2."Date Captured" = 0D) and (PaymentLine2.SystemId <> PaymentLine.SystemId) and (PaymentLine2.Amount <> 0) then
                        exit(false);
            until ShopifyAssignedID.Next() = 0;
        exit(true);
    end;

    internal procedure UpdatePmtLinesAndScheduleCapture(var NcTask: Record "NPR Nc Task"; ScheduleCapture: Boolean; StopOnRequestError: Boolean) Success: Boolean
    var
        TempSpfyTransactionBuffer: Record "NPR Spfy Transaction Buffer" temporary;
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        OStream: OutStream;
        ShopifyResponse: JsonToken;
        Transaction: JsonToken;
        Transactions: JsonToken;
        ParentTransactionID: Text[30];
        TransactionID: Text[30];
        ShopifyTransactionKind: Text;
        AmountFactor: Integer;
        NewBufferEntry: Boolean;
    begin
        if NcTask."Store Code" = '' then
            NcTask."Store Code" :=
                CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(NcTask."Record ID", "NPR Spfy ID Type"::"Store Code"), 1, MaxStrLen(NcTask."Store Code"));

        ClearLastError();
        if StopOnRequestError then begin
            GetShopifyOrderTransactions(NcTask, ShopifyResponse);
            Success := true;
        end else
            Success := TryGetShopifyOrderTransactions(NcTask, ShopifyResponse);
        if not Success then
            exit;

        ShopifyResponse.SelectToken('data.order.transactions', Transactions);
        if not Transactions.IsArray() then
            exit;
        foreach Transaction in Transactions.AsArray() do begin
            ShopifyTransactionKind := JsonHelper.GetJText(Transaction, 'kind', MaxStrLen(TempSpfyTransactionBuffer.Kind), false).ToUpper();
            if IsAuthorizationTransaction(ShopifyTransactionKind) or IsSaleTransaction(ShopifyTransactionKind) or IsRefundTransaction(ShopifyTransactionKind) then
                if JsonHelper.GetJText(Transaction, 'status', false).ToUpper() = 'SUCCESS' then begin
#pragma warning disable AA0139
                    TransactionID := SpfyIntegrationMgt.RemoveUntil(JsonHelper.GetJText(Transaction, 'id', true), '/');
                    ParentTransactionID := SpfyIntegrationMgt.RemoveUntil(JsonHelper.GetJText(Transaction, 'parentTransaction.id', false), '/');
#pragma warning restore AA0139
                    if IsRefundTransaction(ShopifyTransactionKind) then
                        AmountFactor := -1
                    else
                        AmountFactor := 1;

                    TempSpfyTransactionBuffer.Init();
                    if ParentTransactionID <> '' then
                        TempSpfyTransactionBuffer."Transaction ID" := ParentTransactionID
                    else
                        TempSpfyTransactionBuffer."Transaction ID" := TransactionID;
                    NewBufferEntry := not TempSpfyTransactionBuffer.Find();
                    if not IsRefundTransaction(ShopifyTransactionKind) or NewBufferEntry then begin
#pragma warning disable AA0139
                        TempSpfyTransactionBuffer.Kind := ShopifyTransactionKind;
#pragma warning restore AA0139
                        Clear(TempSpfyTransactionBuffer."Transaction Json");
                        TempSpfyTransactionBuffer."Transaction Json".CreateOutStream(OStream, TextEncoding::UTF8);
                        Transaction.WriteTo(OStream);
                    end;
                    if NewBufferEntry then begin
                        TempSpfyTransactionBuffer."Presentment Currency Code" := SpfyPaymentGatewayHdlr.TranslateCurrencyCode(JsonHelper.GetJText(Transaction, 'amountSet.presentmentMoney.currencyCode', false));
                        TempSpfyTransactionBuffer."Store Currency Code" := SpfyPaymentGatewayHdlr.TranslateCurrencyCode(JsonHelper.GetJText(Transaction, 'amountSet.shopMoney.currencyCode', false));
                        TempSpfyTransactionBuffer.Insert();
                    end else begin
                        TempSpfyTransactionBuffer.TestField("Presentment Currency Code", SpfyPaymentGatewayHdlr.TranslateCurrencyCode(JsonHelper.GetJText(Transaction, 'amountSet.presentmentMoney.currencyCode', false)));
                        TempSpfyTransactionBuffer.TestField("Store Currency Code", SpfyPaymentGatewayHdlr.TranslateCurrencyCode(JsonHelper.GetJText(Transaction, 'amountSet.shopMoney.currencyCode', false)));
                    end;
                    TempSpfyTransactionBuffer."Amount (PCY)" += JsonHelper.GetJDecimal(Transaction, 'amountSet.presentmentMoney.amount', false) * AmountFactor;
                    TempSpfyTransactionBuffer."Amount (SCY)" += JsonHelper.GetJDecimal(Transaction, 'amountSet.shopMoney.amount', true) * AmountFactor;
                    TempSpfyTransactionBuffer.Modify();
                end;
        end;
        UpdatePmtLinesAndScheduleCapture(NcTask, Transactions.AsArray(), TempSpfyTransactionBuffer, ScheduleCapture);
    end;

    local procedure UpdatePmtLinesAndScheduleCapture(NcTask: Record "NPR Nc Task"; OrderTransactions: JsonArray; var SpfyTransactionBuffer: Record "NPR Spfy Transaction Buffer"; ScheduleCapture: Boolean)
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentLine2: Record "NPR Magento Payment Line";
        PaymentLineParam: Record "NPR Magento Payment Line";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
        IStream: InStream;
        Transaction: JsonToken;
        AlreadyAssigned: Boolean;
        GiftCardTransaction: Boolean;
    begin
        if SpfyTransactionBuffer.IsEmpty() then
            exit;

        RecRef.Get(NcTask."Record ID");
        case RecRef.Number of
            Database::"Sales Header":
                begin
                    RecRef.SetTable(SalesHeader);
                    SalesHeader.CalcFields("Amount Including VAT");
                    PaymentLineParam."Document Type" := SalesHeader."Document Type";
                    PaymentLineParam."Document No." := SalesHeader."No.";
                    PaymentLineParam."Posting Date" := SalesHeader."Posting Date";
                    PaymentLineParam."External Reference No." := SalesHeader."NPR External Order No.";
                    PaymentLineParam.Amount := SalesHeader."Amount Including VAT";
                end;

            Database::"Sales Invoice Header":
                begin
                    RecRef.SetTable(SalesInvHeader);
                    SalesInvHeader.CalcFields("Amount Including VAT");
                    PaymentLineParam."Document No." := SalesInvHeader."No.";
                    PaymentLineParam."Posting Date" := SalesInvHeader."Posting Date";
                    PaymentLineParam."External Reference No." := SalesInvHeader."NPR External Order No.";
                    PaymentLineParam.Amount := SalesInvHeader."Amount Including VAT";
                end;
            else
                SpfyIntegrationMgt.UnsupportedIntegrationTable(NcTask, StrSubstNo('CU%1.%2', Format(Codeunit::"NPR Spfy Capture Payment"), 'UpdatePmtLinesAndScheduleCapture'));
        end;
        if PaymentLineParam."Posting Date" = 0D then
            PaymentLineParam."Posting Date" := Today();
        PaymentLineParam."Document Table No." := RecRef.Number();
        PaymentLineParam."Source No." := NcTask."Store Code";

        PaymentLine := PaymentLineParam;
        PaymentLine.SetRecFilter();
        PaymentLine.SetRange("Line No.");

        SpfyTransactionBuffer.FindSet();
        repeat
            AlreadyAssigned := false;
            SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"NPR Magento Payment Line", "NPR Spfy ID Type"::"Entry ID", SpfyTransactionBuffer."Transaction ID", ShopifyAssignedID);
            if ShopifyAssignedID.FindSet() then
                repeat
                    if RecRef.Get(ShopifyAssignedID."BC Record ID") then begin
                        RecRef.SetTable(PaymentLine2);
                        AlreadyAssigned :=
                            (PaymentLine2."Document Table No." = PaymentLineParam."Document Table No.") and
                            ((PaymentLine2."Document Type" = PaymentLineParam."Document Type") or (PaymentLineParam."Document Table No." = Database::"Sales Invoice Header")) and
                            (PaymentLine2."Document No." = PaymentLineParam."Document No.");
                        if AlreadyAssigned then
                            PaymentLine := PaymentLine2;
                    end;
                until (ShopifyAssignedID.Next() = 0) or AlreadyAssigned;

            if SpfyTransactionBuffer."Amount (PCY)" <= 0 then begin
                if AlreadyAssigned then
                    PaymentLine.Delete(true);
            end else begin
                SpfyTransactionBuffer.CalcFields("Transaction Json");
                SpfyTransactionBuffer."Transaction Json".CreateInStream(IStream, TextEncoding::UTF8);
                Transaction.ReadFrom(IStream);

                if not AlreadyAssigned then begin
                    if not PaymentLine.FindLast() then
                        PaymentLine."Line No." := 0;

                    GiftCardTransaction := false;
                    if IsSaleTransaction(SpfyTransactionBuffer.Kind) then
                        GiftCardTransaction := AddGiftCardPaymentLine(Transaction, PaymentLineParam, PaymentLine);
                    if not GiftCardTransaction then begin
                        InitCreditCardPaymentLine(Transaction, PaymentLineParam, PaymentLine);
                        PaymentLine."No." := SpfyTransactionBuffer."Transaction ID";
                        PaymentLine.Insert(true);
                    end;
                    SpfyAssignedIDMgt.AssignShopifyID(PaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", SpfyTransactionBuffer."Transaction ID", false);
                end;

                if PaymentLine."Posting Date" = 0D then
                    PaymentLine."Posting Date" := PaymentLineParam."Posting Date";
                SetPmtLineAsCaptured(Transaction, OrderTransactions, SpfyTransactionBuffer.Kind, SpfyTransactionBuffer."Transaction ID", PaymentLine);

                if ScheduleCapture and IsAuthorizationTransaction(SpfyTransactionBuffer.Kind) and (PaymentLine."Date Captured" = 0D) then
                    SchedulePmtLineProcessing(NcTask."Store Code", PaymentLine, CopyStr(NcTask."Record Value", 1, 30), NcTask.Type::Insert);

                PaymentLineParam.Amount := PaymentLineParam.Amount - PaymentLine.Amount;
                if PaymentLineParam.Amount <= 0 then
                    exit;
            end;
        until SpfyTransactionBuffer.Next() = 0;
    end;

    local procedure InitCreditCardPaymentLine(Transaction: JsonToken; PaymentLineParam: Record "NPR Magento Payment Line"; var PaymentLine: Record "NPR Magento Payment Line")
    var
        PaymentMapping: Record "NPR Magento Payment Mapping";
        PaymentMethod: Record "Payment Method";
    begin
        GetPaymentMapping(Transaction, PaymentLineParam."Source No.", PaymentMapping);
        PaymentMapping.TestField("Payment Method Code");
        PaymentMethod.Get(PaymentMapping."Payment Method Code");

        PaymentLine.Init();
        PaymentLine."Line No." := PaymentLine."Line No." + 10000;
        PaymentLine.Description := CopyStr(PaymentMethod.Description + ' ' + PaymentLineParam."External Reference No.", 1, MaxStrLen(PaymentLine.Description));
        PaymentLine."Payment Type" := PaymentLine."Payment Type"::"Payment Method";
        PaymentLine."Account Type" := PaymentMethod."Bal. Account Type";
        PaymentLine."Account No." := PaymentMethod."Bal. Account No.";
        PaymentLine."Posting Date" := PaymentLineParam."Posting Date";
        PaymentLine."Source Table No." := Database::"Payment Method";
        PaymentLine."Source No." := PaymentMethod.Code;
        SetPaymentAmounts(Transaction, PaymentLine);
        AdjustAmounts(PaymentLineParam.Amount, PaymentLine);
        PaymentLine."Allow Adjust Amount" := PaymentMapping."Allow Adjust Payment Amount";
        PaymentLine."Payment Gateway Code" := ShopifyPaymentGateway(PaymentLine."Store Currency Code");
#pragma warning disable AA0139
        PaymentLine."Transaction ID" := JsonHelper.GetJText(Transaction, 'paymentId', false);
#pragma warning restore AA0139
        SetDateAuthorized(Transaction, PaymentLine);
        SetPaymentCardDetails(Transaction, PaymentLine);

        SpfyIntegrationEvents.OnAfterInitCreditCardPaymentLine(PaymentLine, PaymentMapping, Transaction);
    end;

    local procedure GetPaymentMapping(Transaction: JsonToken; ShopifyStoreCode: Code[20]; var PaymentMapping: Record "NPR Magento Payment Mapping")
    var
        ExternalPaymentTypeID: Record "NPR External Payment Type ID";
        CreditCardCompany: Text;
        ShopifyPmtGateway: Text;
        ExternalPmtTypeFormatTok: Label '%1_%2', Locked = true;
        MappingNotFoundErr: Label 'There is no payment mapping set for Shopify store %1, payment gateway "%2" and credit card company "%3".', Comment = '%1 - Shopify store code, %2 - payment gateway, %3 - credit card company';
    begin
        Clear(PaymentMapping);
        ShopifyPmtGateway := JsonHelper.GetJText(Transaction, 'gateway', false);
        CreditCardCompany := JsonHelper.GetJText(Transaction, 'paymentDetails.company', false);

        ExternalPaymentTypeID.SetCurrentKey("Store Code", "Payment Gateway", "Credit Card Company");
        ExternalPaymentTypeID.SetRange("Store Code", ShopifyStoreCode);
        ExternalPaymentTypeID.SetRange("Payment Gateway", CopyStr(ShopifyPmtGateway, 1, MaxStrLen(ExternalPaymentTypeID."Payment Gateway")));
        ExternalPaymentTypeID.SetRange("Credit Card Company", CopyStr(CreditCardCompany, 1, MaxStrLen(ExternalPaymentTypeID."Credit Card Company")));
        if ExternalPaymentTypeID.FindFirst() then
            if PaymentMapping.Get('Shopify', ExternalPaymentTypeID."External Payment Type ID") then
                exit;

        if not PaymentMapping.Get('Shopify', LowerCase(StrSubstNo(ExternalPmtTypeFormatTok, ShopifyStoreCode, ShopifyPmtGateway))) then
            Error(MappingNotFoundErr, ShopifyStoreCode, ShopifyPmtGateway, CreditCardCompany);
    end;

    local procedure SetDateAuthorized(Transaction: JsonToken; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        PaymentLine."Date Authorized" := DT2Date(JsonHelper.GetJDT(Transaction, 'processedAt', false));
        if PaymentLine."Date Authorized" = 0D then
            PaymentLine."Date Authorized" := DT2Date(JsonHelper.GetJDT(Transaction, 'createdAt', false));
        PaymentLine."Expires At" := JsonHelper.GetJDT(Transaction, 'authorizationExpiresAt', false);
    end;

    local procedure SetPaymentAmounts(Transaction: JsonToken; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        PaymentLine.Amount := JsonHelper.GetJDecimal(Transaction, 'amountSet.presentmentMoney.amount', false);
        PaymentLine."Amount (Store Currency)" := JsonHelper.GetJDecimal(Transaction, 'amountSet.shopMoney.amount', true);
        PaymentLine."Store Currency Code" := SpfyPaymentGatewayHdlr.TranslateCurrencyCode(JsonHelper.GetJText(Transaction, 'amountSet.shopMoney.currencyCode', false));
    end;

    local procedure AdjustAmounts(ExpectedPaymentAmount: Decimal; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        If PaymentLine.Amount <= ExpectedPaymentAmount then
            exit;

        GetCurrency(PaymentLine."Store Currency Code");
        PaymentLine."Amount (Store Currency)" := Round(PaymentLine."Amount (Store Currency)" * ExpectedPaymentAmount / PaymentLine.Amount, Currency."Amount Rounding Precision");
        PaymentLine.Amount := ExpectedPaymentAmount;
    end;

    local procedure SetPaymentCardDetails(Transaction: JsonToken; var PaymentLine: Record "NPR Magento Payment Line")
    var
        CardNumber: Text;
    begin
        CardNumber := JsonHelper.GetJText(Transaction, 'paymentDetails.number', false);
        if StrLen(CardNumber) <= 4 then
#pragma warning disable AA0139
            PaymentLine."Card Summary" := CardNumber
#pragma warning restore AA0139
        else
            PaymentLine."Card Summary" := CopyStr(CardNumber, StrLen(CardNumber) - 3, 4);
#pragma warning disable AA0139
        PaymentLine.Brand := JsonHelper.GetJText(Transaction, 'paymentDetails.company', MaxStrLen(PaymentLine.Brand), false);
        PaymentLine."Expiry Date Text" := StrSubstNo('%1/%2', JsonHelper.GetJText(Transaction, 'paymentDetails.expirationMonth', false).PadLeft(2, '0'), JsonHelper.GetJText(Transaction, 'paymentDetails.expirationYear', false));
#pragma warning restore AA0139
    end;

    local procedure SetPmtLineAsCaptured(CurrentTransaction: JsonToken; Transactions: JsonArray; ShopifyTransactionKind: Text; CurrentTransactionID: Text[30]; var PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        ShopifyOrderTransaction: JsonToken;
        ShopifyOrderTransactionsAsArray: JsonArray;
        DateCaptured: Date;
    begin
        if (PaymentLine."Payment Type" <> PaymentLine."Payment Type"::"Payment Method") or (PaymentLine."Date Captured" <> 0D) then
            exit;

        if ShopifyTransactionKind = '' then
            ShopifyTransactionKind := JsonHelper.GetJText(CurrentTransaction, 'kind', false).ToUpper();
        case true of
            IsSaleTransaction(ShopifyTransactionKind):
                begin
                    PaymentLine."Date Captured" := PaymentLine."Date Authorized";
                    if PaymentLine."Date Captured" = 0D then
                        PaymentLine."Date Captured" := PaymentLine."Posting Date";
                end;

            IsAuthorizationTransaction(ShopifyTransactionKind):
                if JsonHelper.GetJDecimal(CurrentTransaction, 'totalUnsettledSet.presentmentMoney.amount', true) = 0 then begin
                    ShopifyOrderTransactionsAsArray := Transactions.Clone().AsArray();
                    foreach ShopifyOrderTransaction in ShopifyOrderTransactionsAsArray do
                        if JsonHelper.GetJText(ShopifyOrderTransaction, 'kind', false).ToUpper() = 'CAPTURE' then
                            if JsonHelper.GetJText(ShopifyOrderTransaction, 'status', false).ToUpper() = 'SUCCESS' then
                                if SpfyIntegrationMgt.RemoveUntil(JsonHelper.GetJText(ShopifyOrderTransaction, 'parentTransaction.id', false), '/') = CurrentTransactionID then begin
                                    DateCaptured := DT2Date(JsonHelper.GetJDT(ShopifyOrderTransaction, 'processedAt', false));
                                    if DateCaptured = 0D then
                                        DateCaptured := DT2Date(JsonHelper.GetJDT(ShopifyOrderTransaction, 'createdAt', false));
                                    if (DateCaptured <> 0D) and (DateCaptured > PaymentLine."Date Captured") then
                                        PaymentLine."Date Captured" := DateCaptured;
                                end;
                    if PaymentLine."Date Captured" = 0D then
                        PaymentLine."Date Captured" := PaymentLine."Posting Date";
                end;

            else
                exit;
        end;

        if PaymentLine."Date Captured" = 0D then
            exit;
        PaymentLine.Modify();
        exit(true);
    end;

    local procedure AddGiftCardPaymentLine(Transaction: JsonToken; PaymentLineParam: Record "NPR Magento Payment Line"; var PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucher: Record "NPR NpRv Voucher";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
        ReceiptJson: JsonToken;
        ShopifyGiftCardID: Text[30];
        VoucherNotFoundErr: Label 'System could not find a retail voucher with Shopify gift card ID %1';
    begin
        if not ReceiptJson.ReadFrom(JsonHelper.GetJText(Transaction, 'receiptJson', false)) then
            exit;
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

        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Sales Document");
        NpRvSalesLine.SetRange("External Document No.", PaymentLineParam."External Reference No.");
        NpRvSalesLine.SetRange("Voucher Type", NpRvVoucher."Voucher Type");
        NpRvSalesLine.SetRange("Voucher No.", NpRvVoucher."No.");
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
        if not NpRvSalesLine.FindFirst() then begin
            NpRvSalesLine.Init();
            NpRvSalesLine.Id := CreateGuid();
            NpRvSalesLine."External Document No." := PaymentLineParam."External Reference No.";
            NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
            NpRvSalesLine."Document Type" := PaymentLineParam."Document Type";
            NpRvSalesLine."Document No." := PaymentLineParam."Document No.";
            NpRvSalesLine.Type := NpRvSalesLine.Type::Payment;
            NpRvSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
            NpRvSalesLine."Voucher No." := NpRvVoucher."No.";
            NpRvSalesLine."Reference No." := NpRvVoucher."Reference No.";
            NpRvSalesLine.Description := NpRvVoucher.Description;
            NpRvSalesLine."Spfy Initiated in Shopify" := true;
            NpRvSalesLine.Insert(true);
        end;

        PaymentLine.Init();
        PaymentLine."Line No." := PaymentLine."Line No." + 10000;
        PaymentLine."Payment Type" := PaymentLine."Payment Type"::Voucher;
        PaymentLine.Description := NpRvVoucher.Description;
        PaymentLine."Account No." := NpRvVoucher."Account No.";
        PaymentLine."No." := NpRvVoucher."Reference No.";
        PaymentLine."Posting Date" := PaymentLineParam."Posting Date";
        PaymentLine."Source Table No." := Database::"NPR NpRv Voucher";
        PaymentLine."Source No." := NpRvVoucher."No.";
        PaymentLine."External Reference No." := PaymentLineParam."External Reference No.";
        SetPaymentAmounts(Transaction, PaymentLine);
        AdjustAmounts(PaymentLineParam.Amount, PaymentLine);
        PaymentLine.Insert(true);

        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Payment Line";
        NpRvSalesLine."Document Line No." := PaymentLine."Line No.";
        NpRvSalesLine.Amount := PaymentLine.Amount;
        NpRvSalesLine."Reservation Line Id" := PaymentLine.SystemId;
        NpRvSalesLine.Modify(true);

        SpfyIntegrationEvents.OnAfterAddGiftCardPaymentLine(PaymentLine, NpRvSalesLine, Transaction);

        exit(true);
    end;

    local procedure SchedulePmtLineProcessing(ShopifyStoreCode: Code[20]; PaymentLine: Record "NPR Magento Payment Line"; OrderID: Text[30]; TaskType: Option)
    var
        NcTask: Record "NPR Nc Task";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(PaymentLine);
        SpfyScheduleSend.InitNcTask(ShopifyStoreCode, RecRef, OrderID, TaskType, NcTask);
    end;

    local procedure ShopifyPaymentGateway(StoreCurrencyCode: Text): Code[10]
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        SpfyPaymentGateway: Record "NPR Spfy Payment Gateway";
        ShopifyPmtGatewayCode: Label 'SPFY', Locked = true;
    begin
        PaymentGateway.Code := CopyStr(StrSubstNo('%1-%2', ShopifyPmtGatewayCode, UpperCase(StoreCurrencyCode)), 1, MaxStrLen(PaymentGateway.Code));
        if not PaymentGateway.Find() then begin
            PaymentGateway.Init();
            PaymentGateway."Integration Type" := PaymentGateway."Integration Type"::Shopify;
            PaymentGateway."Enable Capture" := true;
            PaymentGateway.Insert();

            SpfyPaymentGateway.Init();
            SpfyPaymentGateway.Code := PaymentGateway.Code;
            SpfyPaymentGateway."Currency Code" := CopyStr(UpperCase(StoreCurrencyCode), 1, MaxStrLen(SpfyPaymentGateway."Currency Code"));
            SpfyPaymentGateway."Identify Final Capture" := true;
            SpfyPaymentGateway.Insert();
        end else begin
            PaymentGateway.TestField("Integration Type", PaymentGateway."Integration Type"::Shopify);
        end;
        exit(PaymentGateway.Code);
    end;

    local procedure IsShopifyPaymentLine(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        if PaymentLine."Payment Gateway Code" = '' then
            exit(false);
        if not PaymentGateway.get(PaymentLine."Payment Gateway Code") then
            exit(false);
        exit(PaymentGateway."Enable Capture" and (PaymentGateway."Integration Type" = PaymentGateway."Integration Type"::Shopify));
    end;

    local procedure AddPostingErrorMessageToNcTask(var NcTask: Record "NPR Nc Task")
    var
        TypeHelper: Codeunit "Type Helper";
        IStream: InStream;
        OStream: OutStream;
        Tb: TextBuilder;
        PostingErr: Label 'The payment capture process completed successfully.\However, the payment posting routine has ended with the following error: %1.\You will need to post the payment manually.\\The payment capture response:';
    begin
        Tb.Append(StrSubstNo(PostingErr, GetLastErrorText()));
        Tb.Append(TypeHelper.CRLFSeparator());
        If NcTask.Response.HasValue() then begin
            NcTask.Response.CreateInStream(IStream, TextEncoding::UTF8);
            Tb.Append(TypeHelper.ReadAsTextWithSeparator(IStream, TypeHelper.CRLFSeparator()));
        end;
        Clear(NcTask.Response);
        NcTask.Response.CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText(Tb.ToText());
        NcTask.Modify();
        Commit();
    end;

    local procedure GetCurrency(CurrencyCode: Code[10])
    begin
        if CurrencyRetrieved and (Currency.Code = CurrencyCode) then
            exit;

        if CurrencyCode <> '' then
            Currency.Get(CurrencyCode)
        else begin
            Clear(Currency);
            Currency.InitRoundingPrecision();
        end;
        CurrencyRetrieved := true;
    end;

    local procedure IsAuthorizationTransaction(TransactionKind: Text): Boolean
    begin
        exit(TransactionKind = 'AUTHORIZATION');
    end;

    local procedure IsSaleTransaction(TransactionKind: Text): Boolean
    begin
        exit(TransactionKind = 'SALE');
    end;

    local procedure IsRefundTransaction(TransactionKind: Text): Boolean
    begin
        exit(TransactionKind = 'REFUND');
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnRunOnBeforeFinalizePosting', '', true, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnRunOnBeforeFinalizePosting, '', true, false)]
#endif
    local procedure ScheduleCaptureShopifyPayment(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        NcTask: Record "NPR Nc Task";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
        ShopifyOrderID: Text[30];
    begin
        if not SalesHeader.Invoice then
            exit;
        NcTask."Store Code" :=
            CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code"), 1, MaxStrLen(NcTask."Store Code"));
        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Payment Capture Requests", NcTask."Store Code") then
            exit;

        ShopifyOrderID := SpfyAssignedIDMgt.GetAssignedShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyOrderID = '' then
            exit;

        case true of
            SalesInvoiceHeader."No." <> '':
                RecRef.GetTable(SalesInvoiceHeader);
            else
                exit;
        end;
        SpfyScheduleSend.InitNcTask(NcTask."Store Code", RecRef, ShopifyOrderID, NcTask.Type::Insert, NcTask);
    end;
}
#endif