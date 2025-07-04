#if not BC17
codeunit 6184804 "NPR Spfy Capture Payment"
{
    Access = Internal;

    TableNo = "NPR Nc Task";

    var
        PaymentMapping: Record "NPR Magento Payment Mapping";
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";

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
        SendToShopify: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();
        Success := false;

        SendToShopify := PrepareShopifyTransactionRequest(NcTask, 0);
        if SendToShopify then
            Success := SpfyCommunicationHandler.SendTransactionRequest(NcTask);

        if SaveToDb then begin
            NcTask.Modify();
            Commit();
            if Success then begin
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
                        if not Codeunit.Run(Codeunit::"NPR Spfy Post Payment Line", PaymentLine) then
                            AddPostingErrorMessageToNcTask(NcTask);
                    end;
                end;
            end;
        end;

        if SendToShopify and not Success then
            Error(GetLastErrorText);
        ClearLastError();
    end;

    internal procedure RefundShopifyPayment(var NcTask: Record "NPR Nc Task"; SaveToDb: Boolean) Success: Boolean
    var
        PaymentLine: Record "NPR Magento Payment Line";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        RecRef: RecordRef;
        SendToShopify: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();
        Success := false;

        SendToShopify := PrepareShopifyTransactionRequest(NcTask, 1);
        if SendToShopify then
            Success := SpfyCommunicationHandler.SendTransactionRequest(NcTask);

        if SaveToDb then begin
            if Success then begin
                RecRef.Get(NcTask."Record ID");
                RecRef.SetTable(PaymentLine);
                if PaymentLine.Find() then begin
                    PaymentLine."Date Refunded" := Today();
                    PaymentLine.Modify();
                end;
            end;
            NcTask.Modify();
            Commit();
        end;

        if SendToShopify and not Success then
            Error(GetLastErrorText);
    end;

    local procedure PrepareShopifyTransactionRequest(var NcTask: Record "NPR Nc Task"; RequestType: Option Capture,Refund) SendToShopify: Boolean
    var
        PaymentLine: Record "NPR Magento Payment Line";
        SpfyPaymentGateway: Record "NPR Spfy Payment Gateway";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
        JObject: JsonObject;
        JChildObject: JsonObject;
        OutStr: OutStream;
        TransactionID: Text[30];
        AlreadyCapturedErr: Label 'The payment transaction has already been marked as captured in Shopify.';
        IsNotShopifyPmtLineErr: Label '%1 does not seem to be a Shopify related payment transaction', Comment = '%1 - Payment Line record Id';
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
        case RequestType of
            RequestType::Capture:
                begin
                    PaymentLine.TestField("Date Captured", 0D);
                    if TransactionAlreadyCaptured(NcTask, TransactionID, PaymentLine) then begin
                        SpfyIntegrationMgt.SetResponse(NcTask, AlreadyCapturedErr);
                        exit;
                    end;
                end;
            RequestType::Refund:
                begin
                    PaymentLine.TestField("Date Refunded", 0D);
                    //TODO: Check if the payment line is already refunded
                end;
        end;
        PaymentLine.TestField("Payment Gateway Code");
        if not SpfyPaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            SpfyPaymentGateway.Init();

        JChildObject.Add('currency', SpfyPaymentGateway."Currency Code");
        JChildObject.Add('amount', PaymentLine.Amount);
        JChildObject.Add('kind', Format(RequestType, 0, 1));
        JChildObject.Add('parent_id', TransactionID);
        JObject.Add('transaction', JChildObject);
        NcTask."Data Output".CreateOutStream(OutStr, TextEncoding::UTF8);
        JObject.WriteTo(OutStr);
        SendToShopify := true;
    end;

    local procedure TransactionAlreadyCaptured(NcTask: Record "NPR Nc Task"; TransactionID: Text[30]; var PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonObject;
        Transaction: JsonToken;
        Transactions: JsonToken;
    begin
        SpfyCommunicationHandler.GetShopifyOrderTransactions(NcTask, ShopifyResponse);
        ShopifyResponse.SelectToken('transactions', Transactions);
        if Transactions.IsArray() then
            foreach Transaction in Transactions.AsArray() do
                if TransactionID = JsonHelper.GetJText(Transaction, 'id', true) then begin
                    SetDateAuthorized(Transaction, PaymentLine);
                    if PaymentLine."Transaction ID" = '' then
#pragma warning disable AA0139
                        PaymentLine."Transaction ID" := JsonHelper.GetJText(Transaction, 'payment_id', false);
#pragma warning restore AA0139
                    if PaymentLine."Posting Date" = 0D then
                        PaymentLine."Posting Date" := Today();
                    exit(SetPmtLineAsCaptured(Transaction, Transactions.AsArray(), '', TransactionID, PaymentLine));
                end;
    end;

    internal procedure UpdatePmtLinesAndScheduleCapture(var NcTask: Record "NPR Nc Task"; ScheduleCapture: Boolean; StopOnRequestError: Boolean) Success: Boolean
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentLine2: Record "NPR Magento Payment Line";
        PaymentLineParam: Record "NPR Magento Payment Line";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        RecRef: RecordRef;
        ShopifyResponse: JsonObject;
        Transaction: JsonToken;
        Transactions: JsonToken;
        ShopifyOrderID: Text[30];
        ShopifyTransactionID: Text[30];
        ShopifyTransactionKind: Text;
        AlreadyAssigned: Boolean;
        GiftCardTransaction: Boolean;
    begin
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

        PaymentLine := PaymentLineParam;
        PaymentLine.SetRecFilter();
        PaymentLine.SetRange("Line No.");

        ShopifyOrderID := CopyStr(NcTask."Record Value", 1, MaxStrLen(ShopifyOrderID));
        if NcTask."Store Code" = '' then
            NcTask."Store Code" :=
                CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(NcTask."Record ID", "NPR Spfy ID Type"::"Store Code"), 1, MaxStrLen(NcTask."Store Code"));

        ClearLastError();
        if StopOnRequestError then begin
            SpfyCommunicationHandler.GetShopifyOrderTransactions(NcTask, ShopifyResponse);
            Success := true;
        end else
            Success := SpfyCommunicationHandler.TryGetShopifyOrderTransactions(NcTask, ShopifyResponse);
        if Success then begin
            ShopifyResponse.SelectToken('transactions', Transactions);
            if Transactions.IsArray() then
                foreach Transaction in Transactions.AsArray() do begin
                    ShopifyTransactionKind := JsonHelper.GetJText(Transaction, 'kind', false).ToLower();
                    if ShopifyTransactionKind in ['authorization', 'sale'] then
                        if JsonHelper.GetJText(Transaction, 'status', false) = 'success' then begin
#pragma warning disable AA0139
                            ShopifyTransactionID := JsonHelper.GetJText(Transaction, 'id', MaxStrLen(ShopifyTransactionID), true);
#pragma warning restore AA0139

                            AlreadyAssigned := false;
                            SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"NPR Magento Payment Line", "NPR Spfy ID Type"::"Entry ID", ShopifyTransactionID, ShopifyAssignedID);
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

                            if not AlreadyAssigned then begin
                                if not PaymentLine.FindLast() then
                                    PaymentLine."Line No." := 0;

                                GiftCardTransaction := false;
                                if ShopifyTransactionKind = 'sale' then
                                    GiftCardTransaction := AddGiftCardPaymentLine(Transaction, PaymentLineParam, PaymentLine);
                                if not GiftCardTransaction then begin
                                    InitCreditCardPaymentLine(Transaction, NcTask."Store Code", PaymentLineParam, PaymentLine);
                                    PaymentLine."No." := ShopifyTransactionID;
                                    PaymentLine.Insert(true);
                                end;
                                SpfyAssignedIDMgt.AssignShopifyID(PaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyTransactionID, false);
                            end;
                            if PaymentLine."Posting Date" = 0D then
                                PaymentLine."Posting Date" := PaymentLineParam."Posting Date";
                            SetPmtLineAsCaptured(Transaction, Transactions.AsArray(), ShopifyTransactionKind, ShopifyTransactionID, PaymentLine);

                            if ScheduleCapture and (ShopifyTransactionKind = 'authorization') and (PaymentLine."Date Captured" = 0D) then
                                SchedulePmtLineProcessing(NcTask."Store Code", PaymentLine, ShopifyOrderID, NcTask.Type::Insert);

                            PaymentLineParam.Amount := PaymentLineParam.Amount - PaymentLine.Amount;
                            if PaymentLineParam.Amount <= 0 then
                                exit;
                        end;
                end;
        end;
    end;

    local procedure InitCreditCardPaymentLine(Transaction: JsonToken; ShopifyStoreCode: Code[20]; PaymentLineParam: Record "NPR Magento Payment Line"; var PaymentLine: Record "NPR Magento Payment Line")
    var
        PaymentMethod: Record "Payment Method";
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
    begin
        SpfyOrderMgt.GetPaymentMapping(Transaction, ShopifyStoreCode, PaymentMapping);
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
        PaymentLine.Amount := JsonHelper.GetJDecimal(Transaction, 'amount', true);
        If PaymentLine.Amount > PaymentLineParam.Amount then
            PaymentLine.Amount := PaymentLineParam.Amount;
        PaymentLine."Allow Adjust Amount" := PaymentMapping."Allow Adjust Payment Amount";
        PaymentLine."Payment Gateway Code" := ShopifyPaymentGateway(JsonHelper.GetJText(Transaction, 'currency', false));
#pragma warning disable AA0139
        PaymentLine."Transaction ID" := JsonHelper.GetJText(Transaction, 'payment_id', false);
#pragma warning restore AA0139
        SetDateAuthorized(Transaction, PaymentLine);

        SpfyIntegrationEvents.OnAfterInitCreditCardPaymentLine(PaymentLine, PaymentMapping, Transaction);
    end;

    local procedure SetDateAuthorized(Transaction: JsonToken; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        PaymentLine."Date Authorized" := DT2Date(JsonHelper.GetJDT(Transaction, 'processed_at', false));
        if PaymentLine."Date Authorized" = 0D then
            PaymentLine."Date Authorized" := DT2Date(JsonHelper.GetJDT(Transaction, 'created_at', false));
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
            ShopifyTransactionKind := JsonHelper.GetJText(CurrentTransaction, 'kind', false).ToLower();
        case ShopifyTransactionKind of
            'sale':
                begin
                    PaymentLine."Date Captured" := PaymentLine."Date Authorized";
                    if PaymentLine."Date Captured" = 0D then
                        PaymentLine."Date Captured" := PaymentLine."Posting Date";
                end;

            'authorization':
                if JsonHelper.GetJDecimal(CurrentTransaction, 'total_unsettled_set.presentment_money.amount', true) = 0 then begin
                    ShopifyOrderTransactionsAsArray := Transactions.Clone().AsArray();
                    foreach ShopifyOrderTransaction in ShopifyOrderTransactionsAsArray do
                        if JsonHelper.GetJText(ShopifyOrderTransaction, 'kind', false) = 'capture' then
                            if JsonHelper.GetJText(ShopifyOrderTransaction, 'status', false) = 'success' then
                                if JsonHelper.GetJText(ShopifyOrderTransaction, 'parent_id', false) = CurrentTransactionID then begin
                                    DateCaptured := DT2Date(JsonHelper.GetJDT(ShopifyOrderTransaction, 'processed_at', false));
                                    if DateCaptured = 0D then
                                        DateCaptured := DT2Date(JsonHelper.GetJDT(ShopifyOrderTransaction, 'created_at', false));
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

    local procedure AddGiftCardPaymentLine(ShopifyTransactionJToken: JsonToken; PaymentLineParam: Record "NPR Magento Payment Line"; var PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucher: Record "NPR NpRv Voucher";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
        ShopifyGiftCardID: Text[30];
        VoucherNotFoundErr: Label 'System could not find a retail voucher with Shopify gift card ID %1';
    begin
#pragma warning disable AA0139
        ShopifyGiftCardID := JsonHelper.GetJText(ShopifyTransactionJToken, 'receipt.gift_card_id', MaxStrLen(ShopifyGiftCardID), false);
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
        PaymentLine.Amount := JsonHelper.GetJDecimal(ShopifyTransactionJToken, 'amount', true);
        If PaymentLine.Amount > PaymentLineParam.Amount then
            PaymentLine.Amount := PaymentLineParam.Amount;
        PaymentLine.Insert(true);

        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Payment Line";
        NpRvSalesLine."Document Line No." := PaymentLine."Line No.";
        NpRvSalesLine.Amount := PaymentLine.Amount;
        NpRvSalesLine."Reservation Line Id" := PaymentLine.SystemId;
        NpRvSalesLine.Modify(true);

        SpfyIntegrationEvents.OnAfterAddGiftCardPaymentLine(PaymentLine, NpRvSalesLine, ShopifyTransactionJToken);

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

    local procedure ShopifyPaymentGateway(CurrencyCode: Text): Code[10]
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        SpfyPaymentGateway: Record "NPR Spfy Payment Gateway";
        ShopifyPmtGatewayCode: Label 'SPFY', Locked = true;
    begin
        PaymentGateway.Code := CopyStr(StrSubstNo('%1-%2', ShopifyPmtGatewayCode, UpperCase(CurrencyCode)), 1, MaxStrLen(PaymentGateway.Code));
        if not PaymentGateway.Find() then begin
            PaymentGateway.Init();
            PaymentGateway."Integration Type" := PaymentGateway."Integration Type"::Shopify;
            PaymentGateway."Enable Capture" := true;
            PaymentGateway.Insert();

            SpfyPaymentGateway.Init();
            SpfyPaymentGateway.Code := PaymentGateway.Code;
            SpfyPaymentGateway."Currency Code" := CopyStr(UpperCase(CurrencyCode), 1, MaxStrLen(SpfyPaymentGateway."Currency Code"));
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