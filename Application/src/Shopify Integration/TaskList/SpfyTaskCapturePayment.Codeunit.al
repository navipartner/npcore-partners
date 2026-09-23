// Native sibling of frozen codeunit "NPR Spfy Capture Payment": only sanctioned legacy defect fixes are dual-applied, new-queue behavior changes are not.
codeunit 6151485 "NPR Spfy Task Capture Payment"
{
    Access = Internal;

    TableNo = "NPR Spfy Task";

    var
        _Currency: Record Currency;
        _JsonHelper: Codeunit "NPR Json Helper";
        _SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        _SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
        _SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
        _GraphQLClient: Interface "NPR Spfy IGraphQL Client";
        _PaymentEventType: Option " ",Capture,Refund,Cancel;
        _CurrencyRetrieved: Boolean;
        _GraphQLClientSet: Boolean;

    trigger OnRun()
    var
        Success: Boolean;
    begin
        Rec.TestField("Table No.", Rec."Record ID".TableNo);
        case Rec."Table No." of
            Database::"Sales Invoice Header":
                begin
                    Success := UpdatePmtLinesIfNeededAndScheduleCapture(Rec, true, false);
                    Rec.Modify();
                    Commit();
                    if not Success then
                        Error(GetLastErrorText);
                end;
            Database::"NPR Magento Payment Line":
                begin
                    case Rec.Type of
                        Rec.type::Insert:
                            CaptureShopifyPayment(Rec);
                        Rec.type::Delete:
                            RefundShopifyPayment(Rec);
                    end;
                end;
        end;
    end;

    internal procedure SetGraphQLClient(GraphQLClient: Interface "NPR Spfy IGraphQL Client")
    begin
        _GraphQLClient := GraphQLClient;
        _GraphQLClientSet := true;
    end;

    local procedure GetGraphQLClient(): Interface "NPR Spfy IGraphQL Client"
    var
        DefaultGraphQLClient: Codeunit "NPR Spfy GraphQL Client";
    begin
        if not _GraphQLClientSet then begin
            _GraphQLClient := DefaultGraphQLClient;
            _GraphQLClientSet := true;
        end;
        exit(_GraphQLClient);
    end;

    local procedure CaptureShopifyPayment(var SpfyTask: Record "NPR Spfy Task")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PGInteractionLog: Record "NPR PG Interaction Log Entry";
        TempRequest: Record "NPR PG Payment Request" temporary;
        TempResponse: Record "NPR PG Payment Response" temporary;
        LogMgt: Codeunit "NPR PG Interactions Log Mgt.";
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
        Success: Boolean;
    begin
        if SpfyTask."Table No." <> Database::"NPR Magento Payment Line" then
            _SpfyIntegrationMgt.UnsupportedIntegrationTable(SpfyTask, StrSubstNo('CU%1.%2', Format(Codeunit::"NPR Spfy Task Capture Payment"), 'CaptureShopifyPayment'));
        PaymentLine.ReadIsolation := IsolationLevel::UpdLock;
        GetPaymentLine(SpfyTask."Record ID", PaymentLine);
        PaymentLine.TestField("Payment Gateway Code");
        PaymentLine.ToRequest(TempRequest);

        LogMgt.LogCaptureStart(PGInteractionLog, PaymentLine.SystemId);
        Success := CaptureShopifyPayment(PaymentLine, SpfyTask, TempResponse);
        TempRequest."Request Body" := SpfyTask."Data Output";
        LogMgt.LogOperationFinished(PGInteractionLog, TempRequest, TempResponse, Success, GetLastErrorText());
        SpfyTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText());

        if TempResponse."Response Success" then begin
            MagentoPmtMgt.UpdatePaymentLineWithEventResponse(PaymentLine, _PaymentEventType::Capture, TempResponse);  //has a commit
            _SpfyIntegrationEvents.OnModifyPaymentLineAfterSpfyTaskCaptureIsolated(PaymentLine, SpfyTask);
            if not PaymentLine.Posted then begin
                Commit();
                ClearLastError();
                if not Codeunit.Run(Codeunit::"NPR Magento Post Payment Line", PaymentLine) then
                    AddPostingErrorMessageToTask(SpfyTask);
            end;
        end;
    end;

    local procedure GetPaymentLine(var RecID: RecordId; var PaymentLine: Record "NPR Magento Payment Line")
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvHeader: Record "Sales Invoice Header";
        RecRef: RecordRef;
        Found: Boolean;
    begin
        if PaymentLine.Get(RecID) then
            exit;

        RecRef := RecID.GetRecord();
        RecRef.SetTable(PaymentLine);

        if (PaymentLine."Document Table No." = Database::"Sales Header") and (PaymentLine."Document No." <> '') then
            case PaymentLine."Document Type" of
                PaymentLine."Document Type"::Order,
                PaymentLine."Document Type"::Invoice:
                    begin
                        SalesInvHeader.ReadIsolation := IsolationLevel::ReadCommitted;
                        if PaymentLine."Document Type" = PaymentLine."Document Type"::Order then begin
                            SalesInvHeader.SetCurrentKey("Order No.");
                            SalesInvHeader.SetRange("Order No.", PaymentLine."Document No.");
                        end else begin
                            SalesInvHeader.SetCurrentKey("Pre-Assigned No.");
                            SalesInvHeader.SetRange("Pre-Assigned No.", PaymentLine."Document No.");
                        end;
                        SalesInvHeader.SetLoadFields("No.");
                        if SalesInvHeader.FindLast() then begin
                            PaymentLine."Document Table No." := Database::"Sales Invoice Header";
                            PaymentLine."Document Type" := Enum::"Sales Document Type".FromInteger(0);
                            PaymentLine."Document No." := SalesInvHeader."No.";
                            Found := PaymentLine.Find();
                        end;
                    end;

                PaymentLine."Document Type"::"Return Order",
                PaymentLine."Document Type"::"Credit Memo":
                    begin
                        SalesCrMemoHeader.ReadIsolation := IsolationLevel::ReadCommitted;
                        if PaymentLine."Document Type" = PaymentLine."Document Type"::"Return Order" then begin
                            SalesCrMemoHeader.SetCurrentKey("Return Order No.");
                            SalesCrMemoHeader.SetRange("Return Order No.", PaymentLine."Document No.");
                        end else begin
                            SalesCrMemoHeader.SetCurrentKey("Pre-Assigned No.");
                            SalesCrMemoHeader.SetRange("Pre-Assigned No.", PaymentLine."Document No.");
                        end;
                        SalesCrMemoHeader.SetLoadFields("No.");
                        if SalesCrMemoHeader.FindLast() then begin
                            PaymentLine."Document Table No." := Database::"Sales Cr.Memo Header";
                            PaymentLine."Document Type" := Enum::"Sales Document Type".FromInteger(0);
                            PaymentLine."Document No." := SalesCrMemoHeader."No.";
                            Found := PaymentLine.Find();
                        end;
                    end;
            end;

        if not Found then
            PaymentLine.Get(RecID);  //Raise error

        RecID := PaymentLine.RecordId();
    end;

    local procedure CaptureShopifyPayment(var PaymentLine: Record "NPR Magento Payment Line"; var SpfyTask: Record "NPR Spfy Task"; var Response: Record "NPR PG Payment Response") Success: Boolean
    var
        xPaymentLine: Record "NPR Magento Payment Line";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        Delay: Duration;
    begin
        xPaymentLine := PaymentLine;
        Success := TryCaptureShopifyPayment(PaymentLine, SpfyTask, Response);
        if Format(PaymentLine) <> Format(xPaymentLine) then
            PaymentLine.Modify();
        if Success then
            ClearLastError();
        if Success and (PaymentLine."Date Captured" = 0D) and (Response."Reported Operation Status" = Response."Reported Operation Status"::Pending) then begin
            if (SpfyTask."Not Before Date-Time" <> 0DT) and (SpfyTask."Log Date" <> 0DT) and (SpfyTask."Not Before Date-Time" > SpfyTask."Log Date") then
                Delay := (SpfyTask."Not Before Date-Time" - SpfyTask."Log Date") * 2
            else
                Delay := JobQueueManagement.MinutesToDuration(5);
            SchedulePmtLineProcessing(SpfyTask."Store Code", PaymentLine, CopyStr(SpfyTask."Record Value", 1, 30), SpfyTask.Type::Insert, CurrentDateTime() + Delay);
        end;
    end;

    [TryFunction]
    local procedure TryCaptureShopifyPayment(var PaymentLine: Record "NPR Magento Payment Line"; var SpfyTask: Record "NPR Spfy Task"; var Response: Record "NPR PG Payment Response")
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
        SendToShopify: Boolean;
    begin
        Clear(SpfyTask."Data Output");
        Clear(SpfyTask.Response);
        Clear(Response);
        Response."Reported Operation Status" := Enum::"NPR PG Operation Status"::Failure;
        ClearLastError();

        SendToShopify := PrepareShopifyPaymentCaptureRequest(PaymentLine, SpfyTask);
        if not SendToShopify then begin  //already captured or capture already requested
            Response."Response Body" := SpfyTask.Response;
            exit;
        end;

        Response."Response Success" := GetGraphQLClient().ExecuteRequest(SpfyTask, true, ShopifyResponse);
        Response."Response Body" := SpfyTask.Response;

        if Response."Response Success" then begin
            Response."Response Success" := not SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse);
            if Response."Response Success" then begin
                case _JsonHelper.GetJText(ShopifyResponse, 'data.orderCapture.transaction.status', true).ToUpper() of
                    'PENDING', 'AWAITING_RESPONSE', 'UNKNOWN':
                        Response."Reported Operation Status" := Enum::"NPR PG Operation Status"::Pending;
                    'SUCCESS':
                        Response."Reported Operation Status" := Enum::"NPR PG Operation Status"::Success;
                    else
                        Response."Response Success" := false;
                end;
                if Response."Reported Operation Status" in [Response."Reported Operation Status"::Pending, Response."Reported Operation Status"::Success] then
#pragma warning disable AA0139
                    Response."Response Operation Id" := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ShopifyResponse, 'data.orderCapture.transaction.id', true), '/');
#pragma warning restore AA0139
            end else
                Error(_JsonHelper.GetJText(ShopifyResponse, 'data.orderCapture.userErrors[0].message', true));
        end else
            Error(GetLastErrorText());
    end;

    local procedure RefundShopifyPayment(var SpfyTask: Record "NPR Spfy Task")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        TempResponse: Record "NPR PG Payment Response" temporary;
        Success: Boolean;
    begin
        if SpfyTask."Table No." <> Database::"NPR Magento Payment Line" then
            _SpfyIntegrationMgt.UnsupportedIntegrationTable(SpfyTask, StrSubstNo('CU%1.%2', Format(Codeunit::"NPR Spfy Task Capture Payment"), 'RefundShopifyPayment'));
        PaymentLine.Get(SpfyTask."Record ID");
        Success := RefundShopifyPayment(PaymentLine, SpfyTask, TempResponse);
        if not Success then
            Error(GetLastErrorText());
    end;

    local procedure RefundShopifyPayment(var PaymentLine: Record "NPR Magento Payment Line"; var SpfyTask: Record "NPR Spfy Task"; var Response: Record "NPR PG Payment Response") Success: Boolean
    var
        xPaymentLine: Record "NPR Magento Payment Line";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        Delay: Duration;
    begin
        xPaymentLine := PaymentLine;
        Success := TryRefundShopifyPayment(PaymentLine, SpfyTask, Response);
        if Format(PaymentLine) <> Format(xPaymentLine) then
            PaymentLine.Modify();
        if Success and (PaymentLine."Date Refunded" = 0D) and (Response."Reported Operation Status" = Response."Reported Operation Status"::Pending) then begin
            if (SpfyTask."Not Before Date-Time" <> 0DT) and (SpfyTask."Log Date" <> 0DT) and (SpfyTask."Not Before Date-Time" > SpfyTask."Log Date") then
                Delay := (SpfyTask."Not Before Date-Time" - SpfyTask."Log Date") * 2
            else
                Delay := JobQueueManagement.MinutesToDuration(5);
            SchedulePmtLineProcessing(SpfyTask."Store Code", PaymentLine, CopyStr(SpfyTask."Record Value", 1, 30), SpfyTask.Type::Delete, CurrentDateTime() + Delay);
        end;
    end;

    [TryFunction]
    local procedure TryRefundShopifyPayment(var PaymentLine: Record "NPR Magento Payment Line"; var SpfyTask: Record "NPR Spfy Task"; var Response: Record "NPR PG Payment Response")
    var
        RefundNotSupportedErr: Label 'Refunding Shopify payments from Business Central is not supported yet. Please use the Shopify admin interface to process refunds.';
    begin
        //TODO: Implement refunding of Shopify payments
        Clear(SpfyTask."Data Output");
        Clear(SpfyTask.Response);
        Clear(Response);
        Response."Reported Operation Status" := Enum::"NPR PG Operation Status"::Failure;
        PaymentLine.TestField("Date Refunded", 0D);
        Error(RefundNotSupportedErr);
    end;

    [TryFunction]
    local procedure TryGetShopifyOrderTransactions(var SpfyTask: Record "NPR Spfy Task"; var ShopifyResponse: JsonToken)
    begin
        GetShopifyOrderTransactions(SpfyTask, ShopifyResponse);
    end;

    local procedure GetShopifyOrderTransactions(var SpfyTask: Record "NPR Spfy Task"; var ShopifyResponse: JsonToken): Boolean
    var
        OStream: OutStream;
        Request: JsonObject;
        Variables: JsonObject;
        QueryTok: Label 'query OrderTransactions($orderId: ID!) {order(id: $orderId){currencyCode presentmentCurrencyCode transactions(first: 250){id kind amountSet{presentmentMoney{amount currencyCode} shopMoney{amount currencyCode}} amountRoundingSet{presentmentMoney{amount currencyCode} shopMoney{amount currencyCode}} authorizationCode authorizationExpiresAt createdAt formattedGateway gateway multiCapturable parentTransaction{id kind} paymentId processedAt settlementCurrency settlementCurrencyRate status test totalUnsettledSet{presentmentMoney{amount currencyCode} shopMoney{amount currencyCode}} paymentDetails {... on CardPaymentDetails{avsResultCode bin company expirationMonth expirationYear name number paymentMethodName wallet} ... on LocalPaymentMethodsPaymentDetails{paymentDescriptor paymentMethodName}} receiptJson}}}', Locked = true;
    begin
        Variables.Add('orderId', 'gid://shopify/Order/' + SpfyTask."Record Value");
        Request.Add('query', QueryTok);
        Request.Add('variables', Variables);

        SpfyTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        Request.WriteTo(OStream);
        ClearLastError();
        if not GetGraphQLClient().ExecuteRequest(SpfyTask, false, ShopifyResponse) then
            Error(GetLastErrorText);
    end;

    local procedure PrepareShopifyPaymentCaptureRequest(var PaymentLine: Record "NPR Magento Payment Line"; var SpfyTask: Record "NPR Spfy Task") SendToShopify: Boolean
    var
        SpfyPaymentGateway: Record "NPR Spfy Payment Gateway";
        EcomSalesDocProcess: Codeunit "NPR EcomSalesDocProcess";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        Request: JsonObject;
        Variables: JsonObject;
        Transaction: JsonObject;
        QueryStream: OutStream;
        TransactionID: Text[30];
        AlreadyCapturedErr: Label 'The payment transaction capture has already been requested or processed directly in Shopify.';
        AlreadyMarkedAsCapturedErr: Label 'The payment line has already been marked as captured (the "%1" field is not empty).', Comment = '%1 - "Date Captured" field caption.';
        IsNotShopifyPmtLineErr: Label '%1 does not seem to be a Shopify related payment transaction', Comment = '%1 - Payment Line record Id';
        QueryTok: Label 'mutation TransactionCreate($input: OrderCaptureInput!) {orderCapture(input: $input) {transaction {id kind status parentTransaction{id} amountSet{presentmentMoney{amount currencyCode} shopMoney{amount currencyCode}} paymentId receiptJson settlementCurrency settlementCurrencyRate test} userErrors {message}}}', Locked = true;
    begin
        if not IsShopifyCapturablePaymentLine(PaymentLine) then
            Error(IsNotShopifyPmtLineErr, PaymentLine.RecordId());
        TransactionID := SpfyAssignedIDMgt.GetAssignedShopifyID(PaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if TransactionID = '' then
            Error(IsNotShopifyPmtLineErr, PaymentLine.RecordId());
        if PaymentLine."Date Captured" <> 0D then begin
            _SpfyIntegrationMgt.SetResponse(SpfyTask, StrSubstNo(AlreadyMarkedAsCapturedErr, PaymentLine.FieldCaption("Date Captured")));
            EcomSalesDocProcess.UpdateSalesDocPaymentLineCaptureInformation(PaymentLine);
            exit;
        end;
        if TransactionAlreadyCaptured(SpfyTask, TransactionID, PaymentLine) then begin
            _SpfyIntegrationMgt.SetResponse(SpfyTask, AlreadyCapturedErr);
            EcomSalesDocProcess.UpdateSalesDocPaymentLineCaptureInformation(PaymentLine);
            exit;
        end;
        PaymentLine.TestField(Amount);
        PaymentLine.TestField("Payment Gateway Code");
        if not SpfyPaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            SpfyPaymentGateway.Init();

        Transaction.Add('amount', PaymentLine.Amount);
        Transaction.Add('currency', _SpfyPaymentGatewayHdlr.CurrencyISOCode(PaymentLine.TransactionCurrencyCode(true)));
        if SpfyPaymentGateway."Identify Final Capture" then
            Transaction.Add('finalCapture', IsFinalCapture(PaymentLine, TransactionID));
        Transaction.Add('id', 'gid://shopify/Order/' + SpfyTask."Record Value");
        Transaction.Add('parentTransactionId', 'gid://shopify/OrderTransaction/' + TransactionID);

        Variables.Add('input', Transaction);
        Request.Add('query', QueryTok);
        Request.Add('variables', Variables);

        SpfyTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        Request.WriteTo(QueryStream);
        SendToShopify := true;
    end;

    local procedure TransactionAlreadyCaptured(SpfyTask: Record "NPR Spfy Task"; TransactionID: Text[30]; var PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        ShopifyResponse: JsonToken;
        Transaction: JsonToken;
        Transactions: JsonToken;
    begin
        GetShopifyOrderTransactions(SpfyTask, ShopifyResponse);
        ShopifyResponse.SelectToken('data.order.transactions', Transactions);
        if Transactions.IsArray() then begin
            if PaymentLine."Charge ID" <> '' then
                foreach Transaction in Transactions.AsArray() do
                    if PaymentLine."Charge ID" = _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(Transaction, 'id', true), '/') then begin
                        case _JsonHelper.GetJText(Transaction, 'status', false).ToUpper() of
                            'PENDING', 'AWAITING_RESPONSE', 'UNKNOWN':
                                begin
                                    //capture requested but not yet processed by the PSP
                                    PaymentLine."Capture Requested" := true;
                                    exit(true);
                                end;
                            'SUCCESS':
                                begin
                                    SetDateCaptured(Transaction, PaymentLine);
                                    EnsureCaptureDateIsSet(PaymentLine);
                                    exit(true);
                                end;
                            else begin
                                //transaction status is either ERROR or FAILURE - we clear the Charge ID to allow re-capturing
                                PaymentLine."Charge ID" := '';
                                PaymentLine."Capture Requested" := false;
                            end;
                        end;
                    end;

            foreach Transaction in Transactions.AsArray() do
                if TransactionID = _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(Transaction, 'id', true), '/') then begin
                    PaymentLine."External Payment Gateway" := CopyStr(_JsonHelper.GetJText(Transaction, 'gateway', false), 1, MaxStrLen(PaymentLine."External Payment Gateway"));
                    SetDateAuthorized(Transaction, PaymentLine);
                    SetPaymentCardDetails(Transaction, PaymentLine);
                    if PaymentLine."Transaction ID" = '' then
#pragma warning disable AA0139
                        PaymentLine."Transaction ID" := _JsonHelper.GetJText(Transaction, 'paymentId', false);
#pragma warning restore AA0139
                    if PaymentLine."Posting Date" = 0D then
                        PaymentLine."Posting Date" := Today();
                    exit(SetPmtLineAsCaptured(Transaction, Transactions.AsArray(), '', TransactionID, PaymentLine));
                end;
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

    local procedure GetTransactionsAndUpdatePmtLines(var SpfyTask: Record "NPR Spfy Task"; StopOnRequestError: Boolean) Success: Boolean
    var
        TempSpfyTransactionBuffer: Record "NPR Spfy Transaction Buffer" temporary;
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        ShopifyResponse: JsonToken;
        Transaction: JsonToken;
        Transactions: JsonToken;
    begin
        if SpfyTask."Store Code" = '' then
            SpfyTask."Store Code" :=
                CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyTask."Record ID", "NPR Spfy ID Type"::"Store Code"), 1, MaxStrLen(SpfyTask."Store Code"));

        ClearLastError();
        if StopOnRequestError then begin
            GetShopifyOrderTransactions(SpfyTask, ShopifyResponse);
            Success := true;
        end else
            Success := TryGetShopifyOrderTransactions(SpfyTask, ShopifyResponse);
        if not Success then
            exit;

        ShopifyResponse.SelectToken('data.order.transactions', Transactions);
        if not Transactions.IsArray() then
            exit;
        foreach Transaction in Transactions.AsArray() do
            ProcessTransaction(Transaction, SpfyTask, TempSpfyTransactionBuffer);
        UpdatePmtLines(SpfyTask, Transactions.AsArray(), TempSpfyTransactionBuffer);
    end;

    internal procedure ProcessTransaction(Transaction: JsonToken; var SpfyTask: Record "NPR Spfy Task"; var TempSpfyTransactionBuffer: Record "NPR Spfy Transaction Buffer" temporary) Success: Boolean
    var
        ParentTransactionID: Text[30];
        TransactionID: Text[30];
        ShopifyTransactionKind: Text;
        OStream: OutStream;
        AmountFactor: Integer;
        NewBufferEntry: Boolean;
    begin
        ShopifyTransactionKind := _JsonHelper.GetJText(Transaction, 'kind', MaxStrLen(TempSpfyTransactionBuffer.Kind), false).ToUpper();
        if IsAuthorizationTransaction(ShopifyTransactionKind) or IsSaleTransaction(ShopifyTransactionKind) or IsRefundTransaction(ShopifyTransactionKind) then
            if _JsonHelper.GetJText(Transaction, 'status', false).ToUpper() = 'SUCCESS' then begin
#pragma warning disable AA0139
                TransactionID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(Transaction, 'id', true), '/');
                ParentTransactionID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(Transaction, 'parentTransaction.id', false), '/');
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
                    TempSpfyTransactionBuffer."Presentment Currency Code" := _SpfyPaymentGatewayHdlr.TranslateCurrencyCode(_JsonHelper.GetJText(Transaction, 'amountSet.presentmentMoney.currencyCode', false));
                    TempSpfyTransactionBuffer."Store Currency Code" := _SpfyPaymentGatewayHdlr.TranslateCurrencyCode(_JsonHelper.GetJText(Transaction, 'amountSet.shopMoney.currencyCode', false));
                    TempSpfyTransactionBuffer.Insert();
                end else begin
                    TempSpfyTransactionBuffer.TestField("Presentment Currency Code", _SpfyPaymentGatewayHdlr.TranslateCurrencyCode(_JsonHelper.GetJText(Transaction, 'amountSet.presentmentMoney.currencyCode', false)));
                    TempSpfyTransactionBuffer.TestField("Store Currency Code", _SpfyPaymentGatewayHdlr.TranslateCurrencyCode(_JsonHelper.GetJText(Transaction, 'amountSet.shopMoney.currencyCode', false)));
                end;
                TempSpfyTransactionBuffer."Amount (PCY)" += _JsonHelper.GetJDecimal(Transaction, 'amountSet.presentmentMoney.amount', false) * AmountFactor;
                TempSpfyTransactionBuffer."Amount (SCY)" += _JsonHelper.GetJDecimal(Transaction, 'amountSet.shopMoney.amount', true) * AmountFactor;
                TempSpfyTransactionBuffer.Modify();
            end;
    end;

    local procedure UpdatePmtLines(SpfyTask: Record "NPR Spfy Task"; OrderTransactions: JsonArray; var SpfyTransactionBuffer: Record "NPR Spfy Transaction Buffer")
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
        DisplayReference: Code[50];
        AlreadyAssigned: Boolean;
        GiftCardTransaction: Boolean;
    begin
        if SpfyTransactionBuffer.IsEmpty() then
            exit;

        RecRef.Get(SpfyTask."Record ID");
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
                    DisplayReference := GetDisplayReference(SalesHeader."External Document No.", SalesHeader."NPR External Order No.", PaymentLineParam."External Reference No.");
                end;

            Database::"Sales Invoice Header":
                begin
                    RecRef.SetTable(SalesInvHeader);
                    SalesInvHeader.CalcFields("Amount Including VAT");
                    PaymentLineParam."Document No." := SalesInvHeader."No.";
                    PaymentLineParam."Posting Date" := SalesInvHeader."Posting Date";
                    PaymentLineParam."External Reference No." := SalesInvHeader."NPR External Order No.";
                    PaymentLineParam.Amount := SalesInvHeader."Amount Including VAT";
                    DisplayReference := GetDisplayReference(SalesInvHeader."External Document No.", SalesInvHeader."NPR External Order No.", PaymentLineParam."External Reference No.");
                end;
            else
                _SpfyIntegrationMgt.UnsupportedIntegrationTable(SpfyTask, StrSubstNo('CU%1.%2', Format(Codeunit::"NPR Spfy Task Capture Payment"), 'UpdatePmtLinesAndScheduleCapture'));
        end;
        if PaymentLineParam."Posting Date" = 0D then
            PaymentLineParam."Posting Date" := Today();
        PaymentLineParam."Document Table No." := RecRef.Number();
        PaymentLineParam."Source No." := SpfyTask."Store Code";

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
                        InitCreditCardPaymentLine(Transaction, PaymentLineParam, PaymentLine, DisplayReference);
                        PaymentLine."No." := SpfyTransactionBuffer."Transaction ID";
                        PaymentLine.Insert(true);
                    end;
                    SpfyAssignedIDMgt.AssignShopifyID(PaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", SpfyTransactionBuffer."Transaction ID", false);
                end;

                if PaymentLine."Posting Date" = 0D then
                    PaymentLine."Posting Date" := PaymentLineParam."Posting Date";
                SetPmtLineAsCaptured(Transaction, OrderTransactions, SpfyTransactionBuffer.Kind, SpfyTransactionBuffer."Transaction ID", PaymentLine);

                PaymentLineParam.Amount := PaymentLineParam.Amount - PaymentLine.Amount;
                if PaymentLineParam.Amount <= 0 then
                    exit;
            end;
        until SpfyTransactionBuffer.Next() = 0;
    end;

    local procedure UpdatePmtLinesIfNeededAndScheduleCapture(SpfyTask: Record "NPR Spfy Task"; ScheduleCapture: Boolean; StopOnRequestError: Boolean) Success: Boolean
    begin
        Success := true;
        if _SpfyIntegrationMgt.ShouldUpdatePaymentLinesOnCapture(SpfyTask."Store Code") then
            Success := GetTransactionsAndUpdatePmtLines(SpfyTask, StopOnRequestError);

        if not Success then
            exit(false);

        if ScheduleCapture then
            ScheduleCaptureFromPaymentLines(SpfyTask);
    end;

    local procedure ScheduleCaptureFromPaymentLines(var SpfyTask: Record "NPR Spfy Task")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        PreparePaymentLinesForCapture(SpfyTask, PaymentLine, 'ScheduleCaptureFromPaymentLines');
        if not PaymentLine.FindSet() then
            exit;

        repeat
            if SpfyAssignedIDMgt.GetAssignedShopifyID(PaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID") <> '' then
                SchedulePmtLineProcessing(SpfyTask."Store Code", PaymentLine, CopyStr(SpfyTask."Record Value", 1, 30), SpfyTask.Type::Insert, 0DT);
        until PaymentLine.Next() = 0;
    end;

    local procedure PreparePaymentLinesForCapture(var SpfyTask: Record "NPR Spfy Task"; var PaymentLine: Record "NPR Magento Payment Line"; CallerFunction: Text): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        RecRef: RecordRef;
    begin
        RecRef.Get(SpfyTask."Record ID");

        PaymentLine.Reset();
        PaymentLine.ReadIsolation := IsolationLevel::ReadCommitted;
        PaymentLine.SetRange("Document Table No.", RecRef.Number());
        PaymentLine.SetFilter("Payment Gateway Code", '<>%1', '');
        PaymentLine.SetFilter(Amount, '>0');
        PaymentLine.SetRange("Date Captured", 0D);
        case RecRef.Number of
            Database::"Sales Header":
                begin
                    RecRef.SetTable(SalesHeader);
                    PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
                    PaymentLine.SetRange("Document No.", SalesHeader."No.");
                end;
            Database::"Sales Invoice Header":
                begin
                    RecRef.SetTable(SalesInvHeader);
                    PaymentLine.SetRange("Document No.", SalesInvHeader."No.");
                end;
            else
                _SpfyIntegrationMgt.UnsupportedIntegrationTable(SpfyTask, StrSubstNo('CU%1.%2', Format(Codeunit::"NPR Spfy Task Capture Payment"), CallerFunction));
        end;
    end;

    local procedure GetDisplayReference(ExternalDocumentNo: Code[35]; ExternalOrderNo: Code[20]; ExternalReferenceNo: Code[50]): Code[50]
    begin
        // Prefer the human-readable Shopify order number
        if (ExternalDocumentNo <> '') and (ExternalDocumentNo <> ExternalOrderNo) then
            exit(ExternalDocumentNo);
        exit(ExternalReferenceNo);
    end;

    local procedure InitCreditCardPaymentLine(Transaction: JsonToken; PaymentLineParam: Record "NPR Magento Payment Line"; var PaymentLine: Record "NPR Magento Payment Line"; DisplayReference: Code[50])
    var
        PaymentMapping: Record "NPR Magento Payment Mapping";
        PaymentMethod: Record "Payment Method";
    begin
        GetPaymentMapping(Transaction, PaymentLineParam."Source No.", PaymentMapping);
        PaymentMapping.TestField("Payment Method Code");
        PaymentMethod.Get(PaymentMapping."Payment Method Code");

        PaymentLine.Init();
        PaymentLine."Line No." := PaymentLine."Line No." + 10000;
        PaymentLine.Description := CopyStr(PaymentMethod.Description + ' ' + DisplayReference, 1, MaxStrLen(PaymentLine.Description));
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
        PaymentLine."Transaction ID" := _JsonHelper.GetJText(Transaction, 'paymentId', false);
#pragma warning restore AA0139
        PaymentLine."External Payment Gateway" := CopyStr(_JsonHelper.GetJText(Transaction, 'gateway', false), 1, MaxStrLen(PaymentLine."External Payment Gateway"));
        SetDateAuthorized(Transaction, PaymentLine);
        SetPaymentCardDetails(Transaction, PaymentLine);

        _SpfyIntegrationEvents.OnAfterInitCreditCardPaymentLine(PaymentLine, PaymentMapping, Transaction);
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
        ShopifyPmtGateway := _JsonHelper.GetJText(Transaction, 'gateway', false);
        CreditCardCompany := _JsonHelper.GetJText(Transaction, 'paymentDetails.company', false);

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
        PaymentLine."Date Authorized" := DT2Date(_JsonHelper.GetJDT(Transaction, 'processedAt', false));
        if PaymentLine."Date Authorized" = 0D then
            PaymentLine."Date Authorized" := DT2Date(_JsonHelper.GetJDT(Transaction, 'createdAt', false));
        PaymentLine."Expires At" := _JsonHelper.GetJDT(Transaction, 'authorizationExpiresAt', false);
    end;

    local procedure SetPaymentAmounts(Transaction: JsonToken; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        PaymentLine.Amount := _JsonHelper.GetJDecimal(Transaction, 'amountSet.presentmentMoney.amount', false);
        PaymentLine."Requested Amount" := PaymentLine.Amount;
        PaymentLine."Amount (Store Currency)" := _JsonHelper.GetJDecimal(Transaction, 'amountSet.shopMoney.amount', true);
        PaymentLine."Requested Amt. (Store Curr.)" := PaymentLine."Amount (Store Currency)";
        PaymentLine."Store Currency Code" := _SpfyPaymentGatewayHdlr.TranslateCurrencyCode(_JsonHelper.GetJText(Transaction, 'amountSet.shopMoney.currencyCode', false));
    end;

    local procedure AdjustAmounts(ExpectedPaymentAmount: Decimal; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        If PaymentLine.Amount <= ExpectedPaymentAmount then
            exit;

        GetCurrency(PaymentLine."Store Currency Code");
        PaymentLine."Amount (Store Currency)" := Round(PaymentLine."Amount (Store Currency)" * ExpectedPaymentAmount / PaymentLine.Amount, _Currency."Amount Rounding Precision");
        PaymentLine.Amount := ExpectedPaymentAmount;
    end;

    local procedure SetPaymentCardDetails(Transaction: JsonToken; var PaymentLine: Record "NPR Magento Payment Line")
    var
        CardNumber: Text;
    begin
        CardNumber := _JsonHelper.GetJText(Transaction, 'paymentDetails.number', false);
        if StrLen(CardNumber) <= 4 then
#pragma warning disable AA0139
            PaymentLine."Card Summary" := CardNumber
#pragma warning restore AA0139
        else
            PaymentLine."Card Summary" := CopyStr(CardNumber, StrLen(CardNumber) - 3, 4);
#pragma warning disable AA0139
        PaymentLine.Brand := _JsonHelper.GetJText(Transaction, 'paymentDetails.company', MaxStrLen(PaymentLine.Brand), false);
        PaymentLine."Expiry Date Text" := StrSubstNo('%1/%2', _JsonHelper.GetJText(Transaction, 'paymentDetails.expirationMonth', false).PadLeft(2, '0'), _JsonHelper.GetJText(Transaction, 'paymentDetails.expirationYear', false));
#pragma warning restore AA0139

        _SpfyIntegrationEvents.OnAfterSetPaymentCardDetails(Transaction, PaymentLine);
    end;

    local procedure SetPmtLineAsCaptured(CurrentTransaction: JsonToken; Transactions: JsonArray; ShopifyTransactionKind: Text; CurrentTransactionID: Text[30]; var PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        ShopifyOrderTransaction: JsonToken;
        ShopifyOrderTransactionsAsArray: JsonArray;
    begin
        if (PaymentLine."Payment Type" <> PaymentLine."Payment Type"::"Payment Method") or (PaymentLine."Date Captured" <> 0D) then
            exit;

        if ShopifyTransactionKind = '' then
            ShopifyTransactionKind := _JsonHelper.GetJText(CurrentTransaction, 'kind', false).ToUpper();
        case true of
            IsSaleTransaction(ShopifyTransactionKind):
                begin
                    PaymentLine."Date Captured" := PaymentLine."Date Authorized";
                    if PaymentLine."Date Captured" = 0D then
                        PaymentLine."Date Captured" := PaymentLine."Posting Date";
                end;

            IsAuthorizationTransaction(ShopifyTransactionKind):
                if _JsonHelper.GetJDecimal(CurrentTransaction, 'totalUnsettledSet.presentmentMoney.amount', true) = 0 then begin
                    ShopifyOrderTransactionsAsArray := Transactions.Clone().AsArray();
                    foreach ShopifyOrderTransaction in ShopifyOrderTransactionsAsArray do
                        if _JsonHelper.GetJText(ShopifyOrderTransaction, 'kind', false).ToUpper() = 'CAPTURE' then
                            if _JsonHelper.GetJText(ShopifyOrderTransaction, 'status', false).ToUpper() = 'SUCCESS' then
                                if _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ShopifyOrderTransaction, 'parentTransaction.id', false), '/') = CurrentTransactionID then
                                    SetDateCaptured(ShopifyOrderTransaction, PaymentLine);
                    EnsureCaptureDateIsSet(PaymentLine);
                end;

            else
                exit;
        end;

        exit(PaymentLine."Date Captured" <> 0D);
    end;

    local procedure SetDateCaptured(ShopifyOrderTransaction: JsonToken; var PaymentLine: Record "NPR Magento Payment Line")
    var
        DateCaptured: Date;
    begin
        DateCaptured := DT2Date(_JsonHelper.GetJDT(ShopifyOrderTransaction, 'processedAt', false));
        if DateCaptured = 0D then
            DateCaptured := DT2Date(_JsonHelper.GetJDT(ShopifyOrderTransaction, 'createdAt', false));
        if (DateCaptured <> 0D) and (DateCaptured > PaymentLine."Date Captured") then
            PaymentLine."Date Captured" := DateCaptured;
    end;

    local procedure EnsureCaptureDateIsSet(var PaymentLine: Record "NPR Magento Payment Line")
    begin
        if PaymentLine."Date Captured" = 0D then
            PaymentLine."Date Captured" := PaymentLine."Posting Date";
        if PaymentLine."Date Captured" = 0D then
            PaymentLine."Date Captured" := Today();
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
        CurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        VoucherNotFoundErr: Label 'System could not find a retail voucher with Shopify gift card ID %1';
    begin
        if not ReceiptJson.ReadFrom(_JsonHelper.GetJText(Transaction, 'receiptJson', false)) then
            exit;
#pragma warning disable AA0139
        ShopifyGiftCardID := _SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(ReceiptJson, 'gift_card_id', false), '/');
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
        PaymentLineParam.TransactionCurrencyCodeAndFactor(true, CurrencyCode, CurrencyFactor);
        NpRvSalesLine.Amount := PaymentLine.AmountLCY(CurrencyCode, CurrencyFactor);
        NpRvSalesLine."Reservation Line Id" := PaymentLine.SystemId;
        NpRvSalesLine.Modify(true);

        _SpfyIntegrationEvents.OnAfterAddGiftCardPaymentLine(PaymentLine, NpRvSalesLine, Transaction);

        exit(true);
    end;

    local procedure SchedulePmtLineProcessing(ShopifyStoreCode: Code[20]; PaymentLine: Record "NPR Magento Payment Line"; OrderID: Text[30]; TaskType: Enum "NPR Spfy Task Op"; NotBeforeDateTime: DateTime)
    var
        NcTask: Record "NPR Nc Task";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(PaymentLine);
        SpfyScheduleSend.InitNcTask(ShopifyStoreCode, RecRef, RecRef.RecordId(), OrderID, TaskType.AsInteger(), CurrentDateTime(), NotBeforeDateTime, Enum::"NPR Spfy Reuse Delayed NC Task"::Later, NcTask);
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

    local procedure IsShopifyCapturablePaymentLine(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        if PaymentLine."Payment Gateway Code" = '' then
            exit(false);
        if not PaymentGateway.get(PaymentLine."Payment Gateway Code") then
            exit(false);
        exit(PaymentGateway."Enable Capture" and (PaymentGateway."Integration Type" = PaymentGateway."Integration Type"::Shopify));
    end;

    local procedure AddPostingErrorMessageToTask(var SpfyTask: Record "NPR Spfy Task")
    var
        TypeHelper: Codeunit "Type Helper";
        IStream: InStream;
        OStream: OutStream;
        Tb: TextBuilder;
        PostingErr: Label 'The payment capture has been successfully requested.\However, the payment posting routine has ended with the following error: %1.\You will need to post the payment manually.\\The payment capture response:';
    begin
        Tb.Append(StrSubstNo(PostingErr, GetLastErrorText()));
        Tb.Append(TypeHelper.CRLFSeparator());
        If SpfyTask.Response.HasValue() then begin
            SpfyTask.Response.CreateInStream(IStream, TextEncoding::UTF8);
            Tb.Append(TypeHelper.ReadAsTextWithSeparator(IStream, TypeHelper.CRLFSeparator()));
        end;
        Clear(SpfyTask.Response);
        SpfyTask.Response.CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText(Tb.ToText());
        SpfyTask.Modify();
        Commit();
    end;

    local procedure GetCurrency(CurrencyCode: Code[10])
    begin
        if _CurrencyRetrieved and (_Currency.Code = CurrencyCode) then
            exit;

        if CurrencyCode <> '' then
            _Currency.Get(CurrencyCode)
        else begin
            Clear(_Currency);
            _Currency.InitRoundingPrecision();
        end;
        _CurrencyRetrieved := true;
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
}
