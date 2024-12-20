codeunit 6185030 "NPR MM Subscr.Pmt.: Adyen" implements "NPR MM Subscr.Payment IHandler"
{
    Access = Internal;

    internal procedure ProcessPaymentRequest(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; SkipTryCountUpdate: Boolean; Manual: Boolean) Success: Boolean;
    begin
        if SubscrPaymentRequest.PSP <> SubscrPaymentRequest.PSP::Adyen then
            exit;

        Case SubscrPaymentRequest.Status of
            SubscrPaymentRequest.Status::New,
            SubscrPaymentRequest.Status::Error:
                Success := ProcessNewStatus(SubscrPaymentRequest, SkipTryCountUpdate, Manual);
            SubscrPaymentRequest.Status::Requested:
                Success := ProcessRequestedStatus(SubscrPaymentRequest, SkipTryCountUpdate, Manual);
            SubscrPaymentRequest.Status::Rejected:
                Success := ProcessRejectedStatus(SubscrPaymentRequest, SkipTryCountUpdate, Manual);
            SubscrPaymentRequest.Status::Cancelled:
                Success := ProcessCanceledStatus(SubscrPaymentRequest, SkipTryCountUpdate, Manual);
            SubscrPaymentRequest.Status::Authorized:
                Success := ProcessAuthorizedStatus(SubscrPaymentRequest, SkipTryCountUpdate, Manual);
            SubscrPaymentRequest.Status::Captured:
                Success := ProcessCapturedStatus(SubscrPaymentRequest, SkipTryCountUpdate, Manual);
        End;
        Commit();
    end;

    internal procedure RunSetupCard(PaymentGatewayCode: Code[10]);
    var
        SubsAdyenPGSetup: Record "NPR MM Subs Adyen PG Setup";
    begin
        if (not SubsAdyenPGSetup.Get(PaymentGatewayCode)) then begin
            SubsAdyenPGSetup.Init();
            SubsAdyenPGSetup.Code := PaymentGatewayCode;
            SubsAdyenPGSetup.Insert(true);
            Commit();
        end;

        SubsAdyenPGSetup.SetRecFilter();
        Page.Run(Page::"NPR MM Sub Adyen PG Setup Card", SubsAdyenPGSetup);
    end;

    internal procedure DeleteSetupCard(SubscriptionPaymentGateway: Code[10])
    var
        SubsAdyenPGSetup: Record "NPR MM Subs Adyen PG Setup";
    begin
        if not SubsAdyenPGSetup.Get(SubscriptionPaymentGateway) then
            exit;
        SubsAdyenPGSetup.Delete(true);
    end;

    internal procedure GetPaymentPostingAccount(var AccountType: Enum "Gen. Journal Account Type"; var AccountNo: Code[20])
    var
        SubsAdyenPGSetup: Record "NPR MM Subs Adyen PG Setup";
    begin
        if not TryGetAdyenPaymentGatewaySetup(SubsAdyenPGSetup) then
            Error(GetLastErrorText());
        SubsAdyenPGSetup.TestField("Payment Account No.");
        AccountType := SubsAdyenPGSetup."Payment Account Type";
        AccountNo := SubsAdyenPGSetup."Payment Account No.";
    end;

    local procedure ProcessNewStatus(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; SkipTryCountUpdate: Boolean; Manual: Boolean) Success: Boolean
    var
        SubsAdyenPGSetup: Record "NPR MM Subs Adyen PG Setup";
        RecurPaymSetup: Record "NPR MM Recur. Paym. Setup";
        SubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry";
        SubsPayReqLogUtils: Codeunit "NPR MM Subs Pay Req Log Utils";
        StatusCode: Integer;
        Request: Text;
        Response: Text;
        ResultCode: Text[50];
        RejectedReasonCode: Text[50];
        RejectedReasonDescription: Text[250];
        URL: Text;
        ErrorMessage: Text;
        PaymentToken: Text;
        ShopperReference: Text[50];
        PSPReference: Text[16];
    begin
        SubsPayReqLogUtils.LogEntry(SubscrPaymentRequest,
                                    '',
                                    '',
                                    Manual,
                                    SubsPayReqLogEntry);

        ClearLastError();
        if not RequestTypeIsSupported(SubscrPaymentRequest) then begin
            ErrorMessage := GetLastErrorText();
            ProcessResponse(SubscrPaymentRequest,
                            SubsPayReqLogEntry,
                            '',
                            '',
                            ErrorMessage,
                            SubscrPaymentRequest.Status::Error,
                            SubsPayReqLogEntry."Processing Status"::Error,
                            1,
                            '',
                            '',
                            '',
                            '',
                            SkipTryCountUpdate,
                            '');
            exit;
        end;

        if not TryGetRecurringPaymentSetup(SubscrPaymentRequest, RecurPaymSetup) then begin
            ErrorMessage := GetLastErrorText();
            ProcessResponse(SubscrPaymentRequest,
                            SubsPayReqLogEntry,
                            '',
                            '',
                            ErrorMessage,
                            SubscrPaymentRequest.Status::Error,
                            SubsPayReqLogEntry."Processing Status"::Error,
                            0,
                            '',
                            '',
                            '',
                            '',
                            SkipTryCountUpdate,
                            '');
            exit;
        end;

        if not TryGetAdyenPaymentGatewaySetup(SubsAdyenPGSetup) then begin
            ErrorMessage := GetLastErrorText();
            ProcessResponse(SubscrPaymentRequest,
                            SubsPayReqLogEntry,
                            '',
                            '',
                            ErrorMessage,
                            SubscrPaymentRequest.Status::Error,
                            SubsPayReqLogEntry."Processing Status"::Error,
                            RecurPaymSetup."Max. Pay. Process Try Count",
                            '',
                            '',
                            '',
                            '',
                            SkipTryCountUpdate,
                            '');
            exit;
        end;

        if not TryGetMemberPaymentMethodInformation(SubscrPaymentRequest, ShopperReference, PaymentToken) then begin
            ErrorMessage := GetLastErrorText();
            ProcessResponse(SubscrPaymentRequest,
                            SubsPayReqLogEntry,
                            '',
                            '',
                            ErrorMessage,
                            Enum::"NPR MM Payment Request Status"::Error,
                            SubsPayReqLogEntry."Processing Status"::Error,
                            RecurPaymSetup."Max. Pay. Process Try Count",
                            '',
                            '',
                            '',
                            SubsAdyenPGSetup.Code,
                            SkipTryCountUpdate,
                            '');
            exit;
        end;

        if not SubsAdyenPGSetup.TryGetAPIPaymentsURL(URL) then begin
            ErrorMessage := GetLastErrorText();
            ProcessResponse(SubscrPaymentRequest,
                            SubsPayReqLogEntry,
                            '',
                            '',
                            ErrorMessage,
                            Enum::"NPR MM Payment Request Status"::Error,
                            SubsPayReqLogEntry."Processing Status"::Error,
                            RecurPaymSetup."Max. Pay. Process Try Count",
                            '',
                            '',
                            '',
                            SubsAdyenPGSetup.Code,
                            SkipTryCountUpdate,
                            '');
            exit;
        end;

        if not TryGetPaymentRequestJsonText(SubscrPaymentRequest, ShopperReference, PaymentToken, Request) then begin
            ErrorMessage := GetLastErrorText();
            ProcessResponse(SubscrPaymentRequest,
                            SubsPayReqLogEntry,
                            '',
                            '',
                            ErrorMessage,
                            Enum::"NPR MM Payment Request Status"::Error,
                            SubsPayReqLogEntry."Processing Status"::Error,
                            RecurPaymSetup."Max. Pay. Process Try Count",
                            '',
                            '',
                            '',
                            SubsAdyenPGSetup.Code,
                            SkipTryCountUpdate,
                            '');
            exit;
        end;

        if not InvokeAPI(Request, SubsAdyenPGSetup.GetApiKey(), URL, 1000 * 60 * 5, Response, StatusCode) then begin
            ErrorMessage := GetErrorMessageFromResponse(Response);
            if ErrorMessage = '' then
                ErrorMessage := GetLastErrorText();

            if not TryGetPSPReferenceFromResponse(Response, PSPReference) then
                Clear(PSPReference);

            ProcessResponse(SubscrPaymentRequest,
                            SubsPayReqLogEntry,
                            Request,
                            Response,
                            ErrorMessage,
                            Enum::"NPR MM Payment Request Status"::Error,
                            SubsPayReqLogEntry."Processing Status"::Error,
                            RecurPaymSetup."Max. Pay. Process Try Count",
                            '',
                            '',
                            '',
                            SubsAdyenPGSetup.Code,
                            SkipTryCountUpdate,
                            PSPReference);
            exit;
        end;

        if not TryGetResultCodeFromResponse(Response, ResultCode) then
            Clear(ResultCode);

        if not TryGetRefusalReasonCode(Response, RejectedReasonCode) then
            Clear(RejectedReasonCode);

        if not TryGetRefusalReasonFromResponse(Response, RejectedReasonDescription) then
            Clear(RejectedReasonDescription);

        if not TryGetPSPReferenceFromResponse(Response, PSPReference) then
            Clear(PSPReference);

        if not TryProcessResultCode(ResultCode, RejectedReasonCode, RejectedReasonDescription) then begin
            ErrorMessage := GetLastErrorText();
            ProcessResponse(SubscrPaymentRequest,
                            SubsPayReqLogEntry,
                            Request,
                            Response,
                            ErrorMessage,
                            Enum::"NPR MM Payment Request Status"::Rejected,
                            SubsPayReqLogEntry."Processing Status"::Rejected,
                            RecurPaymSetup."Max. Pay. Process Try Count",
                            RejectedReasonCode,
                            RejectedReasonDescription,
                            ResultCode,
                            SubsAdyenPGSetup.Code,
                            SkipTryCountUpdate,
                            PSPReference);
            exit;
        end;

        ErrorMessage := '';
        ProcessResponse(SubscrPaymentRequest,
                        SubsPayReqLogEntry,
                        Request,
                        Response,
                        ErrorMessage,
                        Enum::"NPR MM Payment Request Status"::Captured,
                        SubsPayReqLogEntry."Processing Status"::Success,
                        RecurPaymSetup."Max. Pay. Process Try Count",
                        RejectedReasonCode,
                        RejectedReasonDescription,
                        ResultCode,
                        SubsAdyenPGSetup.Code,
                        SkipTryCountUpdate,
                        PSPReference);
        Success := true;
    end;

    [TryFunction]
    local procedure TryProcessResultCode(ResultCode: Text[50]; RejectedReasonCode: Text[50]; RejectedReasonDescription: Text[250])
    var
        ErrorMessage: Text;
        AuthorizationFailedErrorLbl: Label 'Authorization failed.';
        RejectedErrorLbl: Label 'Rejected Code: %1, %2', Comment = '%1 - rejected reason code, %2 rejected reason description.';
    begin
        if ResultCode = 'Authorised' then
            exit;

        if RejectedReasonCode = '' then
            ErrorMessage := AuthorizationFailedErrorLbl
        else
            ErrorMessage := StrSubstNo(RejectedErrorLbl, RejectedReasonCode, RejectedReasonDescription);

        Error(ErrorMessage);
    end;

    [TryFunction]
    local procedure TryProcessRejectedStatus(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request")
    var
        RejectedStatusErrorLbl: Label 'The status of entry no.: %1 must be New. Current status: %2.', Comment = '%1 - entry no. , %2 - Current Status';
    begin
        Error(RejectedStatusErrorLbl, SubscrPaymentRequest."Entry No.", SubscrPaymentRequest.Status);
    end;

    local procedure ProcessRejectedStatus(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; SkipTryCountUpdate: Boolean; Manual: Boolean) Success: Boolean
    var
        SubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry";
        SubsPayReqLogUtils: Codeunit "NPR MM Subs Pay Req Log Utils";
        ErrorMessage: Text;
    begin
        Success := TryProcessRejectedStatus(SubscrPaymentRequest);
        if Success then
            exit;

        SubsPayReqLogUtils.LogEntry(SubscrPaymentRequest,
                                  '',
                                  '',
                                  Manual,
                                  SubsPayReqLogEntry);

        ErrorMessage := GetLastErrorText();
        ProcessResponse(SubscrPaymentRequest,
                        SubsPayReqLogEntry,
                        '',
                        '',
                        ErrorMessage,
                        SubscrPaymentRequest.Status,
                        SubsPayReqLogEntry."Processing Status"::Error,
                        0,
                        SubscrPaymentRequest."Rejected Reason Code",
                        SubscrPaymentRequest."Rejected Reason Description",
                        SubscrPaymentRequest."Result Code",
                        '',
                        SkipTryCountUpdate,
                        SubscrPaymentRequest."PSP Reference");
    end;

    [TryFunction]
    local procedure TryProcessCanceledStatus(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request")
    var
        CanceledStatusErrorLbl: Label 'The status of entry no.: %1 must be New. Current status: %2.', Comment = '%1 - entry no. , %2 - Current Status';
    begin
        Error(CanceledStatusErrorLbl, SubscrPaymentRequest."Entry No.", SubscrPaymentRequest.Status);
    end;

    local procedure ProcessCanceledStatus(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; SkipTryCountUpdate: Boolean; Manual: Boolean) Success: Boolean
    var
        SubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry";
        SubsPayReqLogUtils: Codeunit "NPR MM Subs Pay Req Log Utils";
        ErrorMessage: Text;
    begin
        Success := TryProcessCanceledStatus(SubscrPaymentRequest);
        if Success then
            exit;

        SubsPayReqLogUtils.LogEntry(SubscrPaymentRequest,
                                  '',
                                  '',
                                  Manual,
                                  SubsPayReqLogEntry);

        ErrorMessage := GetLastErrorText();
        ProcessResponse(SubscrPaymentRequest,
                        SubsPayReqLogEntry,
                        '',
                        '',
                        ErrorMessage,
                        SubscrPaymentRequest.Status,
                        SubsPayReqLogEntry."Processing Status"::Error,
                        0,
                        SubscrPaymentRequest."Rejected Reason Code",
                        SubscrPaymentRequest."Rejected Reason Description",
                        SubscrPaymentRequest."Result Code",
                        '',
                        SkipTryCountUpdate,
                        SubscrPaymentRequest."PSP Reference");
    end;

    [TryFunction]
    local procedure TryProcessCapturedStatus(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request")
    var
        CapturedStatusErrorLbl: Label 'The status of entry no.: %1 must be New. Current status: %2.', Comment = '%1 - entry no. , %2 - Current Status';
    begin
        Error(CapturedStatusErrorLbl, SubscrPaymentRequest."Entry No.", SubscrPaymentRequest.Status);
    end;

    local procedure ProcessCapturedStatus(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; SkipTryCountUpdate: Boolean; Manual: Boolean) Success: Boolean
    var
        SubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry";
        SubsPayReqLogUtils: Codeunit "NPR MM Subs Pay Req Log Utils";
        ErrorMessage: Text;
    begin
        Success := TryProcessCapturedStatus(SubscrPaymentRequest);
        if Success then
            exit;

        SubsPayReqLogUtils.LogEntry(SubscrPaymentRequest,
                                  '',
                                  '',
                                  Manual,
                                  SubsPayReqLogEntry);

        ErrorMessage := GetLastErrorText();
        ProcessResponse(SubscrPaymentRequest,
                        SubsPayReqLogEntry,
                        '',
                        '',
                        ErrorMessage,
                        SubscrPaymentRequest.Status,
                        SubsPayReqLogEntry."Processing Status"::Error,
                        0,
                        SubscrPaymentRequest."Rejected Reason Code",
                        SubscrPaymentRequest."Rejected Reason Description",
                        SubscrPaymentRequest."Result Code",
                        '',
                        SkipTryCountUpdate,
                        SubscrPaymentRequest."PSP Reference");

    end;

    [TryFunction]
    local procedure TryProcessAuthorizedStatus(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request")
    var
        AuthorizedStatusErrorLbl: Label 'The status of entry no.: %1 must be New. Current status: %2.', Comment = '%1 - entry no. , %2 - Current Status';
    begin
        Error(AuthorizedStatusErrorLbl, SubscrPaymentRequest."Entry No.", SubscrPaymentRequest.Status);
    end;

    local procedure ProcessAuthorizedStatus(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; SkipTryCountUpdate: Boolean; Manual: Boolean) Success: Boolean
    var
        SubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry";
        SubsPayReqLogUtils: Codeunit "NPR MM Subs Pay Req Log Utils";
        ErrorMessage: Text;
    begin
        Success := TryProcessAuthorizedStatus(SubscrPaymentRequest);
        if Success then
            exit;

        SubsPayReqLogUtils.LogEntry(SubscrPaymentRequest,
                                  '',
                                  '',
                                  Manual,
                                  SubsPayReqLogEntry);

        ErrorMessage := GetLastErrorText();
        ProcessResponse(SubscrPaymentRequest,
                        SubsPayReqLogEntry,
                        '',
                        '',
                        ErrorMessage,
                        SubscrPaymentRequest.Status,
                        SubsPayReqLogEntry."Processing Status"::Error,
                        0,
                        SubscrPaymentRequest."Rejected Reason Code",
                        SubscrPaymentRequest."Rejected Reason Description",
                        SubscrPaymentRequest."Result Code",
                        '',
                        SkipTryCountUpdate,
                        SubscrPaymentRequest."PSP Reference");
    end;

    [TryFunction]
    local procedure TryProcessRequestedStatus(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request")
    var
        RequestedStatusErrorLbl: Label 'The status of entry no.: %1 must be New. Current status: %2.', Comment = '%1 - entry no. , %2 - Current Status';
    begin
        Error(RequestedStatusErrorLbl, SubscrPaymentRequest."Entry No.", SubscrPaymentRequest.Status);
    end;

    local procedure ProcessRequestedStatus(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; SkipTryCountUpdate: Boolean; Manual: Boolean) Success: Boolean
    var
        SubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry";
        SubsPayReqLogUtils: Codeunit "NPR MM Subs Pay Req Log Utils";
        ErrorMessage: Text;
    begin
        Success := TryProcessRequestedStatus(SubscrPaymentRequest);
        if Success then
            exit;
        SubsPayReqLogUtils.LogEntry(SubscrPaymentRequest,
                                  '',
                                  '',
                                  Manual,
                                  SubsPayReqLogEntry);

        ErrorMessage := GetLastErrorText();
        ProcessResponse(SubscrPaymentRequest,
                        SubsPayReqLogEntry,
                        '',
                        '',
                        ErrorMessage,
                        SubscrPaymentRequest.Status,
                        SubsPayReqLogEntry."Processing Status"::Error,
                        0,
                        SubscrPaymentRequest."Rejected Reason Code",
                        SubscrPaymentRequest."Rejected Reason Description",
                        SubscrPaymentRequest."Result Code",
                        '',
                        SkipTryCountUpdate,
                        SubscrPaymentRequest."PSP Reference");
    end;

    [TryFunction]
    local procedure TryGetPaymentRequestJsonText(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; ShopperReference: Text[50]; PaymentToken: Text; var RequestJsonText: Text)
    var
        Json: Codeunit "Json Text Reader/Writer";
        CurrencyCode: Code[10];
        Reference: Text;
        MerchantName: Text[50];
    begin
        if SubscrPaymentRequest.PSP <> SubscrPaymentRequest.PSP::Adyen then
            exit;


        CurrencyCode := GetCurrencyCode(SubscrPaymentRequest);
        Reference := GetReference(SubscrPaymentRequest);
        MerchantName := GetMerchantName();
        //root
        Json.WriteStartObject('');

        //amount
        Json.WriteStartObject('amount');
        Json.WriteStringProperty('value', ConvertToAdyenPayAmount(SubscrPaymentRequest.Amount));
        Json.WriteStringProperty('currency', CurrencyCode);
        Json.WriteEndObject();
        // amount

        //paymentMethod
        Json.WriteStartObject('paymentMethod');
        Json.WriteStringProperty('type', 'scheme');
        Json.WriteStringProperty('storedPaymentMethodId', PaymentToken);
        Json.WriteEndObject();
        // paymentMethod

        Json.WriteStringProperty('reference', Reference);
        Json.WriteStringProperty('shopperInteraction', 'ContAuth');
        Json.WriteStringProperty('recurringProcessingModel', 'Subscription');
        Json.WriteStringProperty('merchantAccount', MerchantName);
        Json.WriteStringProperty('shopperReference', ShopperReference);
        Json.WriteStringProperty('captureDelayHours', '0');

        Json.WriteEndObject();

        //root
        RequestJsonText := Json.GetJSonAsText();
    end;

    local procedure GetCurrencyCode(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request") CurrencyCode: Code[10]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        CurrencyCode := SubscrPaymentRequest."Currency Code";
        if CurrencyCode <> '' then
            exit;

        GeneralLedgerSetup.SetLoadFields("LCY Code");
        if not GeneralLedgerSetup.Get() then
            exit;

        CurrencyCode := GeneralLedgerSetup."LCY Code";
    end;

    [TryFunction]
    local procedure TryGetMemberPaymentMethodInformation(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; var ShopperReference: Text[50]; var PaymentToken: Text)
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        SubscrRequest: Record "NPR MM Subscr. Request";
        Subscription: Record "NPR MM Subscription";
        MMPaymentMethodMgt: Codeunit "NPR MM Payment Method Mgt.";

    begin
        SubscrRequest.SetLoadFields("Subscription Entry No.");
        SubscrRequest.Get(SubscrPaymentRequest."Subscr. Request Entry No.");

        Subscription.SetLoadFields("Membership Entry No.");
        Subscription.Get(SubscrRequest."Subscription Entry No.");

        MMPaymentMethodMgt.GetMemberPaymentMethod(Subscription."Membership Entry No.", MemberPaymentMethod);
        ShopperReference := MemberPaymentMethod."Shopper Reference";
        PaymentToken := MemberPaymentMethod."Payment Token";
    end;

    local procedure GetMerchantName() MerchantName: Text[50];
    var
        SubsPaymentGateway: Record "NPR MM Subs. Payment Gateway";
        SubsAdyenPGSetup: Record "NPR MM Subs Adyen PG Setup";
    begin
        SubsPaymentGateway.SetRange("Integration Type", SubsPaymentGateway."Integration Type"::Adyen);
        SubsPaymentGateway.SetRange(Status, SubsPaymentGateway.Status::Enabled);
        SubsPaymentGateway.SetLoadFields("Integration Type", Status, Code);
        SubsPaymentGateway.FindFirst();

        SubsAdyenPGSetup.SetLoadFields("Merchant Name");
        SubsAdyenPGSetup.Get(SubsPaymentGateway.Code);
        MerchantName := SubsAdyenPGSetup."Merchant Name";
    end;

    local procedure ConvertToAdyenPayAmount(Amount: Decimal) AdyenAmount: Text
    begin
        AdyenAmount := DelChr(Format(Amount * 100, 0, 9), '=', '.');
        exit(AdyenAmount);
    end;


    local procedure GetReference(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request") Reference: Text
    var
        Membership: Record "NPR MM Membership";
        Subscription: Record "NPR MM Subscription";
        SubscrRequest: Record "NPR MM Subscr. Request";
        ReferenceLbl: Label 'Membership no. %1 subs. pay. request no. %2', Comment = '%1 - Membership external no %2 - subscription payment request no.', Locked = true;
    begin
        SubscrRequest.SetLoadFields("Subscription Entry No.");
        SubscrRequest.Get(SubscrPaymentRequest."Subscr. Request Entry No.");

        Subscription.SetLoadFields("Membership Entry No.");
        Subscription.Get(SubscrRequest."Subscription Entry No.");

        Membership.SetLoadFields("External Membership No.");
        Membership.Get(Subscription."Membership Entry No.");

        Reference := StrSubstNo(ReferenceLbl, Membership."External Membership No.", SubscrPaymentRequest."Entry No.");
    end;

    [TryFunction]
    local procedure InvokeAPI(Request: Text; APIKey: Text; URL: Text; TimeoutMs: Integer; var Response: Text; var ResponseStatusCode: Integer)
    var
        Http: HttpClient;
        Headers: HttpHeaders;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        ErrorInvokeLbl: Label 'Error: Service endpoint %1 responded with HTTP status %2';
    begin

        HttpRequest.SetRequestUri(URL);
        HttpRequest.Method := 'POST';
        HttpRequest.GetHeaders(Headers);
        Headers.Add('x-api-key', APIKey);
        Http.Timeout := TimeoutMs;

        HttpRequest.Content.WriteFrom(Request);
        HttpRequest.Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json');

        Http.Send(HttpRequest, HttpResponse);
        ResponseStatusCode := HttpResponse.HttpStatusCode;

        if not (HttpResponse.IsSuccessStatusCode) then begin
            HttpResponse.Content.ReadAs(Response);
            Error(ErrorInvokeLbl, URL, Format(ResponseStatusCode));
        end;

        HttpResponse.Content.ReadAs(Response);
    end;

    [TryFunction]
    local procedure TryGetAdyenPaymentGatewaySetup(var SubsAdyenPGSetup: Record "NPR MM Subs Adyen PG Setup")
    var
        SubsPaymentGateway: Record "NPR MM Subs. Payment Gateway";
    begin
        SubsPaymentGateway.SetRange("Integration Type", SubsPaymentGateway."Integration Type"::Adyen);
        SubsPaymentGateway.SetRange(Status, SubsPaymentGateway.Status::Enabled);
        SubsPaymentGateway.SetLoadFields("Integration Type", Status, Code);
        SubsPaymentGateway.FindFirst();

        SubsAdyenPGSetup.Get(SubsPaymentGateway.Code);
    end;

    [TryFunction]
    local procedure TryGetRecurringPaymentSetup(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; var RecurPaymSetup: Record "NPR MM Recur. Paym. Setup")
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        Subscription: Record "NPR MM Subscription";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin
        SubscriptionRequest.SetLoadFields("Subscription Entry No.");
        SubscriptionRequest.Get(SubscrPaymentRequest."Subscr. Request Entry No.");

        Subscription.SetLoadFields("Membership Code");
        Subscription.Get(SubscriptionRequest."Subscription Entry No.");

        MembershipSetup.SetLoadFields("Recurring Payment Code");
        MembershipSetup.Get(Subscription."Membership Code");

        RecurPaymSetup.SetLoadFields("Max. Pay. Process Try Count");
        RecurPaymSetup.Get(MembershipSetup."Recurring Payment Code");
    end;

    local procedure UpdateSubscriptionPaymentRequestStatus(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
                                                           Status: Enum "NPR MM Payment Request Status";
                                                           PSPReference: Text[16];
                                                           MaxProcessTryCount: Integer;
                                                           RejectedReasonCode: Text[50];
                                                           RejectedReasonDescription: Text[250];
                                                           ResultCode: Text[50];
                                                           SkipTryCountUpdate: Boolean)
    var
        UpdatedStatus: Enum "NPR MM Payment Request Status";
        IsModified: Boolean;
    begin
        if not SkipTryCountUpdate then begin
            SubscrPaymentRequest."Process Try Count" += 1;
            IsModified := true;
        end;

        UpdatedStatus := Status;
        if UpdatedStatus in [UpdatedStatus::Error, UpdatedStatus::Rejected] then
            if SubscrPaymentRequest."Process Try Count" < MaxProcessTryCount then
                UpdatedStatus := SubscrPaymentRequest.Status;

        if SubscrPaymentRequest.Status <> UpdatedStatus then begin
            SubscrPaymentRequest.Validate(Status, UpdatedStatus);
            IsModified := true;
        end;

        if SubscrPaymentRequest."PSP Reference" <> PSPReference then begin
            SubscrPaymentRequest."PSP Reference" := PSPReference;
            IsModified := true;
        end;

        if SubscrPaymentRequest."Rejected Reason Code" <> RejectedReasonCode then begin
            SubscrPaymentRequest."Rejected Reason Code" := RejectedReasonCode;
            IsModified := true;
        end;

        if SubscrPaymentRequest."Rejected Reason Description" <> RejectedReasonDescription then begin
            SubscrPaymentRequest."Rejected Reason Description" := RejectedReasonDescription;
            IsModified := true;
        end;

        if SubscrPaymentRequest."Result Code" <> ResultCode then begin
            SubscrPaymentRequest."Result Code" := ResultCode;
            IsModified := true;
        end;

        if IsModified then
            SubscrPaymentRequest.Modify(true);
    end;

    local procedure GetErrorMessageFromResponse(ResponseText: Text) ErrorMessage: Text[250]
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        if ResponseText = '' then
            exit;

        if not JsonObject.ReadFrom(ResponseText) then
            exit;

        if not JsonObject.Get('message', JsonToken) then
            exit;

        ErrorMessage := Copystr(JsonToken.AsValue().AsText(), 1, MaxStrLen(ErrorMessage));
    end;

    [TryFunction]
    local procedure TryGetPSPReferenceFromResponse(ResponseText: Text; var PspReference: Text[16])
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        if ResponseText = '' then
            exit;

        if not JsonObject.ReadFrom(ResponseText) then
            exit;

        if not JsonObject.Get('pspReference', JsonToken) then
            exit;

        pspReference := Copystr(JsonToken.AsValue().AsText(), 1, MaxStrLen(pspReference));
    end;

    [TryFunction]
    local procedure TryGetResultCodeFromResponse(ResponseText: Text; var ResultCode: Text[50])
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        if ResponseText = '' then
            exit;

        if not JsonObject.ReadFrom(ResponseText) then
            exit;

        Clear(ResultCode);
        if JsonObject.Get('resultCode', JsonToken) then
            ResultCode := Copystr(JsonToken.AsValue().AsText(), 1, MaxStrLen(ResultCode));
    end;

    [TryFunction]
    local procedure TryGetRefusalReasonCode(ResponseText: Text; var RejectedReasonCode: Text[50])
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        if ResponseText = '' then
            exit;

        if not JsonObject.ReadFrom(ResponseText) then
            exit;

        Clear(RejectedReasonCode);
        if JsonObject.Get('refusalReasonCode', JsonToken) then
            RejectedReasonCode := CopyStr(JsonToken.AsValue().AsText(), 1, MaxStrLen(RejectedReasonCode));

    end;

    [TryFunction]
    local procedure TryGetRefusalReasonFromResponse(ResponseText: Text; var RejectedReasonDescription: Text[250])
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        if ResponseText = '' then
            exit;

        if not JsonObject.ReadFrom(ResponseText) then
            exit;

        Clear(RejectedReasonDescription);
        if JsonObject.Get('refusalReason', JsonToken) then
            RejectedReasonDescription := Copystr(JsonToken.AsValue().AsText(), 1, MaxStrLen(RejectedReasonDescription));
    end;

    [TryFunction]
    local procedure RequestTypeIsSupported(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request")
    var
        CannotBeProcessedErr: Label 'Requests of type %1 must be initiated directly at the PSP and can only be created in BC by the reconciliation routine.', Comment = '%1 - request type (Enum "NPR MM Payment Request Type")';
        NotSupportedErr: Label 'Requests of type %1 are not yet supported. Please confirm with your system vendor on when the support for this request type is planned.', Comment = '%1 - request type (Enum "NPR MM Payment Request Type")';
    begin
        if not (SubscrPaymentRequest.Type In [SubscrPaymentRequest.Type::Payment, SubscrPaymentRequest.Type::Refund]) then
            Error(CannotBeProcessedErr, SubscrPaymentRequest.Type);

        //TODO: implement refund processing
        if SubscrPaymentRequest.Type = SubscrPaymentRequest.Type::Refund then
            Error(NotSupportedErr, SubscrPaymentRequest.Type);
    end;

    local procedure ProcessResponse(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
                                    var SubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry";
                                    Request: Text;
                                    Response: Text;
                                    ErrorMessage: Text;
                                    Status: Enum "NPR MM Payment Request Status";
                                    ProcessingStatus: Enum "NPR MM SubsPayReqLogProcStatus";
                                    MaxProcessTryCount: Integer;
                                    RejectedReasonCode: Text[50];
                                    RejectedReasonDescription: Text[250];
                                    ResultCode: Code[50];
                                    SubscriptionsPaymentGatewayCode: Code[10];
                                    SkipTryCountUpdate: Boolean;
                                    PSPReference: Text[16])
    var
        SubsPayReqLogUtils: Codeunit "NPR MM Subs Pay Req Log Utils";

    begin
        UpdateSubscriptionPaymentRequestStatus(SubscrPaymentRequest,
                                               Status,
                                               PSPReference,
                                               MaxProcessTryCount,
                                               RejectedReasonCode,
                                               RejectedReasonDescription,
                                               ResultCode,
                                               SkipTryCountUpdate);

        case ProcessingStatus of
            ProcessingStatus::Success:
                SubsPayReqLogUtils.UpdateEntry(SubsPayReqLogEntry,
                                               Request,
                                               Response,
                                               ProcessingStatus,
                                               '',
                                               SubscriptionsPaymentGatewayCode);
            ProcessingStatus::Error,
            ProcessingStatus::Rejected:
                SubsPayReqLogUtils.UpdateEntry(SubsPayReqLogEntry,
                                               Request,
                                               Response,
                                               ProcessingStatus,
                                               Copystr(ErrorMessage, 1, MaxStrLen(SubsPayReqLogEntry."Error Message")),
                                               SubscriptionsPaymentGatewayCode);
        end;
    end;
}