codeunit 6185030 "NPR MM Subscr.Pmt.: Adyen" implements "NPR MM Subscr.Payment IHandler", "NPR MM Subs Payment IHandler"
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
        SubscrPaymentRequest2: Record "NPR MM Subscr. Payment Request";
    begin
        case SubscrPaymentRequest.Type of
            SubscrPaymentRequest.Type::PayByLink:
                Success := ProcessNewPayByLinkStatus(SubscrPaymentRequest, SkipTryCountUpdate, Manual);
            SubscrPaymentRequest.Type::Refund:
                begin
                    If IfReversedReqIsPayByLinkRequested(SubscrPaymentRequest, SubscrPaymentRequest2) then
                        Success := CancelRequests(SubscrPaymentRequest, SubscrPaymentRequest2, SkipTryCountUpdate, Manual)
                    else
                        Success := ProcessNewRefundStatus(SubscrPaymentRequest, SkipTryCountUpdate, Manual);
                end;
            else
                Success := ProcessNewPaymentStatus(SubscrPaymentRequest, SkipTryCountUpdate, Manual);
        end;
    end;

    local procedure IfReversedReqIsPayByLinkRequested(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; var SubscrPaymentRequest2: Record "NPR MM Subscr. Payment Request"): Boolean
    begin
        SubscrPaymentRequest2.SetLoadFields("Entry No.", Reversed, "Reversed by Entry No.");
        SubscrPaymentRequest2.SetRange("Reversed by Entry No.", SubscrPaymentRequest."Entry No.");
        SubscrPaymentRequest2.Setrange(Type, SubscrPaymentRequest2.Type::PayByLink);
        SubscrPaymentRequest2.Setrange(SubscrPaymentRequest2.Status, SubscrPaymentRequest2.Status::Requested);
        exit(SubscrPaymentRequest2.FindFirst());
    end;

    local procedure CancelRequests(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; var SubscrPaymentRequest2: Record "NPR MM Subscr. Payment Request"; SkipTryCountUpdate: Boolean; Manual: Boolean) Success: Boolean
    begin
        if not ProcessCanceledStatus(SubscrPaymentRequest2, SkipTryCountUpdate, Manual) then
            exit;

        SubscrPaymentRequest.Validate(Status, SubscrPaymentRequest.Status::Cancelled);
        SubscrPaymentRequest.Modify(true);

        Success := true;
    end;

    local procedure ProcessNewPaymentStatus(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; SkipTryCountUpdate: Boolean; Manual: Boolean) Success: Boolean
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
        if POSRenewLineExist(SubscrPaymentRequest) then
            exit;

        SubsPayReqLogUtils.LogEntry(SubscrPaymentRequest,
                                    '',
                                    '',
                                    Manual,
                                    SubsPayReqLogEntry);

        ClearLastError();

        if not TryRequestTypeIsSupportedByNewStatus(SubscrPaymentRequest) then begin
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
                            '',
                            '',
                            '',
                            '',
                            0DT,
                            0);
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
                            '',
                            '',
                            '',
                            '',
                            0DT,
                            0);
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
                            '',
                            '',
                            '',
                            '',
                            0DT,
                            0);
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
                            '',
                            '',
                            '',
                            '',
                            0DT,
                            0);
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
                            '',
                            '',
                            '',
                            '',
                            0DT,
                            0);
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
                            '',
                            '',
                            '',
                            '',
                            0DT,
                            0);
            exit;
        end;


        if not TryInvokeAPI(Request, SubsAdyenPGSetup.GetApiKey(), URL, 1000 * 60 * 5, Response, StatusCode, 'POST') then begin
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
                            PSPReference,
                            '',
                            '',
                            '',
                            0DT,
                            0);
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
                            PSPReference,
                            '',
                            '',
                            '',
                            0DT,
                            0);
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
                        PSPReference,
                        '',
                        '',
                        '',
                        0DT,
                        0);

        Success := true;
    end;

    local procedure ProcessNewRefundStatus(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; SkipTryCountUpdate: Boolean; Manual: Boolean) Success: Boolean
    var
        SubsAdyenPGSetup: Record "NPR MM Subs Adyen PG Setup";
        RecurPaymSetup: Record "NPR MM Recur. Paym. Setup";
        SubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry";
        SubsPayReqLogUtils: Codeunit "NPR MM Subs Pay Req Log Utils";
        SubscrPmtOriginalRequest: Record "NPR MM Subscr. Payment Request";
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
        PaymentPSPReference: Text[16];
    begin
        SubsPayReqLogUtils.LogEntry(SubscrPaymentRequest,
                                    '',
                                    '',
                                    Manual,
                                    SubsPayReqLogEntry);

        ClearLastError();

        if not TryRequestTypeIsSupportedByNewStatus(SubscrPaymentRequest) then begin
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
                            '',
                            '',
                            '',
                            '',
                            0DT,
                            0);
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
                            '',
                            '',
                            '',
                            '',
                            0DT,
                            0);
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
                            '',
                            '',
                            '',
                            '',
                            0DT,
                            0);
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
                            '',
                            '',
                            '',
                            '',
                            0DT,
                            0);
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
                            '',
                            '',
                            '',
                            '',
                            0DT,
                            0);
            exit;
        end;

        if not TryGetOriginalPaymentRequest(SubscrPaymentRequest, SubscrPmtOriginalRequest) then begin
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
                           '',
                           '',
                           '',
                           '',
                           0DT,
                           0);
            exit;
        end;

        URL := URL + '/' + SubscrPmtOriginalRequest."PSP Reference" + '/refunds';
        if not TryGetPmtRefundRequestJsonText(SubscrPaymentRequest, Request) then begin
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
                            '',
                            '',
                            '',
                            '',
                            0DT,
                            0);
            exit;
        end;

        if not TryInvokeAPI(Request, SubsAdyenPGSetup.GetApiKey(), URL, 1000 * 60 * 5, Response, StatusCode, 'POST') then begin
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
                            PSPReference,
                            '',
                            '',
                            '',
                            0DT,
                            0);
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

        if not TryGetPaymentPSPFromRespondse(Response, PaymentPSPReference) then
            Clear(PaymentPSPReference);

        ErrorMessage := '';
        ProcessResponse(SubscrPaymentRequest,
                    SubsPayReqLogEntry,
                    Request,
                    Response,
                    ErrorMessage,
                    Enum::"NPR MM Payment Request Status"::Authorized,
                    SubsPayReqLogEntry."Processing Status"::Success,
                    RecurPaymSetup."Max. Pay. Process Try Count",
                    RejectedReasonCode,
                    RejectedReasonDescription,
                    ResultCode,
                    SubsAdyenPGSetup.Code,
                    SkipTryCountUpdate,
                    PSPReference,
                    PaymentPSPReference,
                    '',
                    '',
                    0DT,
                    0);

        Success := true;
    end;

    local procedure ProcessNewPayByLinkStatus(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; SkipTryCountUpdate: Boolean; Manual: Boolean) Success: Boolean
    var
        SubsAdyenPGSetup: Record "NPR MM Subs Adyen PG Setup";
        RecurPaymSetup: Record "NPR MM Recur. Paym. Setup";
        SubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry";
        SubsPayReqLogUtils: Codeunit "NPR MM Subs Pay Req Log Utils";
        Request: Text;
        Response: Text;
        ErrorMessage: Text;
        PSPReference: Text[16];
        PaymentPSPReference: Text[16];
        PayByLinkID: Code[20];
        PayByLinkUrl: Text[2048];
        PayByLinkExpiresAt: DateTime;
    begin
        SubsPayReqLogUtils.LogEntry(SubscrPaymentRequest,
                                    '',
                                    '',
                                    Manual,
                                    SubsPayReqLogEntry);

        ClearLastError();

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
                            '',
                            '',
                            '',
                            '',
                            0DT,
                            0);
            exit;
        end;

        if not TryGetPayByLinkRequestJsonText(SubscrPaymentRequest, SubsAdyenPGSetup."Pay by Link Rec Proc Model", SubsAdyenPGSetup."Pay By Link Exp. Duration", Request) then begin
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
                            '',
                            '',
                            '',
                            '',
                            0DT,
                            0);
            exit;
        end;

        if not SendPayByLinkRequest(Request, SubsAdyenPGSetup, Response) then begin
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
                            0,
                            '',
                            '',
                            '',
                            SubsAdyenPGSetup.Code,
                            true,
                            PSPReference,
                            '',
                            '',
                            '',
                            0DT,
                            0);
            exit;
        end;

        if not TryGetPaymentPSPFromRespondse(Response, PaymentPSPReference) then
            Clear(PaymentPSPReference);

        if not TryGetPSPReferenceFromResponse(Response, PSPReference) then
            Clear(PSPReference);

        if not TryGetPayByLinkIdFromResponse(Response, PayByLinkID) then
            Clear(PayByLinkID);

        if not TryGetPayByLinkUrlFromResponse(Response, PayByLinkUrl) then
            Clear(PayByLinkUrl);

        if not TryGetPayByLinkExpiresAtFromResponse(Response, PayByLinkExpiresAt) then
            Clear(PayByLinkExpiresAt);



        ErrorMessage := '';
        ProcessResponse(SubscrPaymentRequest,
                        SubsPayReqLogEntry,
                        Request,
                        Response,
                        ErrorMessage,
                        Enum::"NPR MM Payment Request Status"::Requested,
                        SubsPayReqLogEntry."Processing Status"::Success,
                         0,
                         '',
                         '',
                         '',
                         SubsAdyenPGSetup.Code,
                         true,
                         PSPReference,
                         PaymentPSPReference,
                         PayByLinkID,
                         PayByLinkUrl,
                         PayByLinkExpiresAt,
                         0);
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


    local procedure ProcessRejectedStatus(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; SkipTryCountUpdate: Boolean; Manual: Boolean) Success: Boolean
    var
        SubsAdyenPGSetup: Record "NPR MM Subs Adyen PG Setup";
        PayByLinkSubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        PayByLinkSubscrRequest: Record "NPR MM Subscr. Request";
        SubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry";
        RecurPaymSetup: Record "NPR MM Recur. Paym. Setup";
        SubsPayReqLogUtils: Codeunit "NPR MM Subs Pay Req Log Utils";
        ErrorMessage: Text;
    begin
        SubsPayReqLogUtils.LogEntry(SubscrPaymentRequest,
                                    '',
                                    '',
                                    Manual,
                                    SubsPayReqLogEntry);

        ClearLastError();
        if not TryGetAdyenPaymentGatewaySetup(SubsAdyenPGSetup) then begin
            ErrorMessage := GetLastErrorText();
            ProcessResponse(SubscrPaymentRequest,
                             SubsPayReqLogEntry,
                             '',
                             '',
                             ErrorMessage,
                             SubscrPaymentRequest.Status::Rejected,
                             SubsPayReqLogEntry."Processing Status"::Error,
                             RecurPaymSetup."Max. Pay. Process Try Count",
                             SubscrPaymentRequest."Rejected Reason Code",
                             SubscrPaymentRequest."Rejected Reason Description",
                             SubscrPaymentRequest."Result Code",
                             SubsAdyenPGSetup.Code,
                             SkipTryCountUpdate,
                             SubscrPaymentRequest."PSP Reference",
                             SubscrPaymentRequest."Payment PSP Reference",
                             SubscrPaymentRequest."Pay by Link ID",
                             SubscrPaymentRequest."Pay by Link URL",
                             SubscrPaymentRequest."Pay By Link Expires At",
                             0);
            exit;
        end;

        if not CheckRejectedStatusCanBeProcessed(SubscrPaymentRequest) then begin
            Success := true;
            exit;
        end;

        Commit();

        if not CreatePayByLinkSubscriptionRequest(SubscrPaymentRequest, PayByLinkSubscrPaymentRequest, PayByLinkSubscrRequest) then begin
            ErrorMessage := GetLastErrorText();
            ProcessResponse(SubscrPaymentRequest,
                            SubsPayReqLogEntry,
                            '',
                            '',
                            ErrorMessage,
                            SubscrPaymentRequest.Status::Rejected,
                            SubsPayReqLogEntry."Processing Status"::Error,
                            RecurPaymSetup."Max. Pay. Process Try Count",
                            SubscrPaymentRequest."Rejected Reason Code",
                            SubscrPaymentRequest."Rejected Reason Description",
                            SubscrPaymentRequest."Result Code",
                            SubsAdyenPGSetup.Code,
                            SkipTryCountUpdate,
                            SubscrPaymentRequest."PSP Reference",
                            SubscrPaymentRequest."Payment PSP Reference",
                            SubscrPaymentRequest."Pay by Link ID",
                            SubscrPaymentRequest."Pay by Link URL",
                            SubscrPaymentRequest."Pay By Link Expires At",
                            0);
            exit;
        end;

        Commit();

        if not ProcessPaymentRequest(PayByLinkSubscrPaymentRequest, SkipTryCountUpdate, Manual) then begin
            PayByLinkSubscrPaymentRequest.Get(PayByLinkSubscrPaymentRequest.RecordId);
            ErrorMessage := GetLastErrorText();
            ProcessResponse(SubscrPaymentRequest,
                            SubsPayReqLogEntry,
                            '',
                            '',
                            ErrorMessage,
                            SubscrPaymentRequest.Status::Rejected,
                            SubsPayReqLogEntry."Processing Status"::Error,
                            RecurPaymSetup."Max. Pay. Process Try Count",
                            SubscrPaymentRequest."Rejected Reason Code",
                            SubscrPaymentRequest."Rejected Reason Description",
                            SubscrPaymentRequest."Result Code",
                            SubsAdyenPGSetup.Code,
                            SkipTryCountUpdate,
                            SubscrPaymentRequest."PSP Reference",
                            SubscrPaymentRequest."Payment PSP Reference",
                            SubscrPaymentRequest."Pay by Link ID",
                            SubscrPaymentRequest."Pay by Link URL",
                            SubscrPaymentRequest."Pay By Link Expires At",
                            0);
            PayByLinkSubscrPaymentRequest.Validate(Status, PayByLinkSubscrPaymentRequest.Status::Cancelled);
            PayByLinkSubscrPaymentRequest.Modify(true);
            exit;
        end;

        ErrorMessage := '';
        ProcessResponse(SubscrPaymentRequest,
                        SubsPayReqLogEntry,
                        '',
                        '',
                        ErrorMessage,
                        Enum::"NPR MM Payment Request Status"::Rejected,
                        SubsPayReqLogEntry."Processing Status"::Success,
                        RecurPaymSetup."Max. Pay. Process Try Count",
                        SubscrPaymentRequest."Rejected Reason Code",
                        SubscrPaymentRequest."Rejected Reason Description",
                        SubscrPaymentRequest."Result Code",
                        SubsAdyenPGSetup.Code,
                        SkipTryCountUpdate,
                        SubscrPaymentRequest."PSP Reference",
                        SubscrPaymentRequest."Payment PSP Reference",
                        SubscrPaymentRequest."Pay by Link ID",
                        SubscrPaymentRequest."Pay by Link URL",
                        SubscrPaymentRequest."Pay By Link Expires At",
                        0);

        Success := true;
    end;

    local procedure CheckRejectedStatusCanBeProcessed(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request") CanBeProcessed: Boolean
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
    begin
        SubscriptionRequest.SetLoadFields("Processing Status");
        SubscriptionRequest.Get(SubscrPaymentRequest."Subscr. Request Entry No.");
        if SubscriptionRequest."Processing Status" = SubscriptionRequest."Processing Status"::Success then
            exit;

        SubscriptionRequest.Reset();
        SubscriptionRequest.SetRange("Created from Entry No.", SubscrPaymentRequest."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::Renew);
        SubscriptionRequest.SetFilter(Status, '<>%1', SubscriptionRequest.Status::Cancelled);
        SubscriptionRequest.SetFilter("Processing Status", '%1|%2', SubscriptionRequest."Processing Status"::Pending, SubscriptionRequest."Processing Status"::Error);
        SubscriptionRequest.SetLoadFields("Entry No.");
        if SubscriptionRequest.FindFirst() then
            exit;

        CanBeProcessed := true;
    end;

    local procedure ProcessCanceledStatus(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; SkipTryCountUpdate: Boolean; Manual: Boolean) Success: Boolean
    var
        SubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry";
        SubsPayReqLogUtils: Codeunit "NPR MM Subs Pay Req Log Utils";
    begin
        case SubscrPaymentRequest.Type of
            SubscrPaymentRequest.Type::PayByLink:
                Success := ProcessCancelledPayByLinkStatus(SubscrPaymentRequest, SkipTryCountUpdate, Manual);
            else begin
                SubsPayReqLogUtils.LogEntry(SubscrPaymentRequest,
                            '',
                            '',
                            Manual,
                            SubsPayReqLogEntry);

                Success := true;
            end;
        end;
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
                        SubscrPaymentRequest."PSP Reference",
                        SubscrPaymentRequest."Payment PSP Reference",
                        SubscrPaymentRequest."Pay by Link ID",
                        SubscrPaymentRequest."Pay by Link URL",
                        SubscrPaymentRequest."Pay By Link Expires At",
                        0);

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
                        SubscrPaymentRequest."PSP Reference",
                        SubscrPaymentRequest."Payment PSP Reference",
                        SubscrPaymentRequest."Pay by Link ID",
                        SubscrPaymentRequest."Pay by Link URL",
                        SubscrPaymentRequest."Pay By Link Expires At",
                        0);
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
                        SubscrPaymentRequest."PSP Reference",
                        SubscrPaymentRequest."Payment PSP Reference",
                        SubscrPaymentRequest."Pay by Link ID",
                        SubscrPaymentRequest."Pay by Link URL",
                        SubscrPaymentRequest."Pay By Link Expires At",
                        0);
    end;

    procedure ProcessRefundWebhook(var JsonObjectToken: JsonToken; var MMSubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; Success: Text; WebhookEntryNo: Integer) Processed: Boolean;
    var
        ErrorMessage: Text;
        JsonValueToken: JsonToken;
        SuccessTrue: Label 'true', Locked = true;
        SuccessFalse: Label 'false', Locked = true;
        MMSubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry";
        MMSubsPayReqLogUtils: Codeunit "NPR MM Subs Pay Req Log Utils";
        ProcessingStatus: Enum "NPR MM SubsPayReqLogProcStatus";
        SubsAdyenPGSetup: Record "NPR MM Subs Adyen PG Setup";
        Status: Enum "NPR MM Payment Request Status";
    begin
        MMSubsPayReqLogUtils.LogEntry(MMSubscrPaymentRequest,
                                        '',
                                        '',
                                        false,
                                        MMSubsPayReqLogEntry);
        ClearLastError();
        if not TryGetAdyenPaymentGatewaySetup(SubsAdyenPGSetup) then begin
            ErrorMessage := GetLastErrorText();
            ProcessResponse(MMSubscrPaymentRequest,
                            MMSubsPayReqLogEntry,
                            '',
                            '',
                            ErrorMessage,
                            MMSubscrPaymentRequest.Status::Error,
                            MMSubsPayReqLogEntry."Processing Status"::Error,
                            0,
                            '',
                            '',
                            '',
                            '',
                            false,
                            '',
                            '',
                            '',
                            '',
                            0DT,
                            WebhookEntryNo);
            exit;
        end;

        case Success of
            SuccessTrue:
                begin
                    Status := Status::Captured;
                    ProcessingStatus := ProcessingStatus::Success;
                end;
            SuccessFalse:
                begin
                    Status := Status::Error;
                    ProcessingStatus := ProcessingStatus::Error;
                end;
        end;
        JsonObjectToken.AsObject().Get('reason', JsonValueToken);
        ErrorMessage := JsonValueToken.AsValue().AsText();

        ProcessResponse(MMSubscrPaymentRequest,
                MMSubsPayReqLogEntry,
                '',
                '',
                ErrorMessage,
                Status,
                ProcessingStatus,
                0,
                MMSubscrPaymentRequest."Rejected Reason Code",
                '',
                MMSubscrPaymentRequest."Result Code",
                SubsAdyenPGSetup.Code,
                true,
                MMSubscrPaymentRequest."PSP Reference",
                MMSubscrPaymentRequest."Payment PSP Reference",
                '',
                '',
                0DT,
                WebhookEntryNo);

        Processed := true;
    end;

    procedure ProcessPayByLinkWebhook(JsonObjectToken: JsonToken; var AdyenWebhook: Record "NPR Adyen Webhook"; MMSubscrPaymentRequest: Record "NPR MM Subscr. Payment Request") Processed: Boolean;
    var
        JsonValueToken: JsonToken;
        JsonAddDataToken: JsonToken;
        Membership: Record "NPR MM Membership";
        TempMemberPaymentMethod: Record "NPR MM Member Payment Method" temporary;
        PaymentTokenExist: Boolean;
        MMSubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry";
        MMSubsPayReqLogUtils: Codeunit "NPR MM Subs Pay Req Log Utils";
        ProcessingStatus: Enum "NPR MM SubsPayReqLogProcStatus";
        SubsAdyenPGSetup: Record "NPR MM Subs Adyen PG Setup";
        Status: Enum "NPR MM Payment Request Status";
        ErrorMessage: Text;
        PSPReference: Text[16];
    begin
        MMSubsPayReqLogUtils.LogEntry(MMSubscrPaymentRequest,
                                       '',
                                       '',
                                       false,
                                       MMSubsPayReqLogEntry);
        ClearLastError();
        if not TryGetAdyenPaymentGatewaySetup(SubsAdyenPGSetup) then begin
            ErrorMessage := GetLastErrorText();
            ProcessResponse(MMSubscrPaymentRequest,
                            MMSubsPayReqLogEntry,
                            '',
                            '',
                            ErrorMessage,
                            MMSubscrPaymentRequest.Status::Error,
                            MMSubsPayReqLogEntry."Processing Status"::Error,
                            0,
                            '',
                            '',
                            '',
                            '',
                            false,
                            '',
                            '',
                            MMSubscrPaymentRequest."Pay by Link ID",
                            MMSubscrPaymentRequest."Pay by Link URL",
                            MMSubscrPaymentRequest."Pay By Link Expires At",
                            AdyenWebhook."Entry No.");
            exit;
        end;

        JsonObjectToken.AsObject().Get('additionalData', JsonAddDataToken);
        PaymentTokenExist := TryGetPaymentMethodData(JsonAddDataToken, TempMemberPaymentMethod);
        if PaymentTokenExist then begin
            GetMembership(MMSubscrPaymentRequest, Membership);
            InsertNewMMPaymentMethod(AdyenWebhook, Membership, TempMemberPaymentMethod);
            Status := Status::Captured;
            ProcessingStatus := ProcessingStatus::Success;
        end else
            Status := Status::Authorized;


        if Membership."Auto-Renew" <> Membership."Auto-Renew"::YES_INTERNAL then begin
            Membership."Auto-Renew" := Membership."Auto-Renew"::YES_INTERNAL;
            Membership.Modify(true);
        end;

        if JsonObjectToken.AsObject().Get('pspReference', JsonValueToken) then
            PSPReference := CopyStr(JsonValueToken.AsValue().AsText(), 1, MaxStrLen(PSPReference));

        ProcessResponse(MMSubscrPaymentRequest,
                        MMSubsPayReqLogEntry,
                        '',
                        '',
                        ErrorMessage,
                        Status,
                        ProcessingStatus,
                        0,
                        MMSubscrPaymentRequest."Rejected Reason Code",
                        MMSubscrPaymentRequest."Rejected Reason Description",
                        MMSubscrPaymentRequest."Result Code",
                        SubsAdyenPGSetup.Code,
                        true,
                        PSPReference,
                        '',
                        MMSubscrPaymentRequest."Pay by Link ID",
                        MMSubscrPaymentRequest."Pay by Link URL",
                        MMSubscrPaymentRequest."Pay By Link Expires At",
                        AdyenWebhook."Entry No.");

        Processed := true;
    end;


    local procedure GetMembership(var MMSubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; var Membership: Record "NPR MM Membership")
    var
        MMSubscription: Record "NPR MM Subscription";
        MMSubscrRequest: Record "NPR MM Subscr. Request";
    begin
        MMSubscrRequest.Get(MMSubscrPaymentRequest."Subscr. Request Entry No.");
        MMSubscription.Get(MMSubscrRequest."Subscription Entry No.");
        Membership.SetLoadFields("Entry No.");
        Membership.Get(MMSubscription."Membership Entry No.");
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

    [TryFunction]
    local procedure TryGetPmtRefundRequestJsonText(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; var RequestJsonText: Text)
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
        Json.WriteStringProperty('value', ConvertToAdyenPayAmount(-SubscrPaymentRequest.Amount));
        Json.WriteStringProperty('currency', CurrencyCode);
        Json.WriteEndObject();
        // amount

        Json.WriteStringProperty('merchantAccount', MerchantName);
        Json.WriteStringProperty('reference', Reference);

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


    local procedure GetMemberShopperReference(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; var ShopperReference: Text[50])
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
    local procedure TryInvokeAPI(Request: Text; APIKey: Text; URL: Text; TimeoutMs: Integer; var Response: Text; var ResponseStatusCode: Integer; Method: Text)
    var
        Http: HttpClient;
        Headers: HttpHeaders;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        ErrorInvokeLbl: Label 'Error: Service endpoint %1 responded with HTTP status %2';
    begin

        HttpRequest.SetRequestUri(URL);
        HttpRequest.Method := Method;
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
        MembershipSetup: Record "NPR MM Membership Setup";
    begin
        SubscriptionRequest.SetLoadFields("Subscription Entry No.", "Membership Code");
        SubscriptionRequest.Get(SubscrPaymentRequest."Subscr. Request Entry No.");

        MembershipSetup.SetLoadFields("Recurring Payment Code");
        MembershipSetup.Get(SubscriptionRequest."Membership Code");
        MembershipSetup.TestField("Recurring Payment Code");

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
                                                           SkipTryCountUpdate: Boolean;
                                                           PaymentPSPReference: Text[16];
                                                           PayByLinkId: Code[20];
                                                           PayByLinkURL: Text[2048];
                                                           PayByLinkExpiresAt: DateTime)
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

        if SubscrPaymentRequest."Payment PSP Reference" <> PaymentPSPReference then begin
            SubscrPaymentRequest."Payment PSP Reference" := PaymentPSPReference;
            IsModified := true;
        end;

        if SubscrPaymentRequest."Pay by Link ID" <> PayByLinkId then begin
            SubscrPaymentRequest."Pay by Link ID" := PayByLinkId;
            IsModified := true;
        end;

        if SubscrPaymentRequest."Pay by Link URL" <> PayByLinkURL then begin
            SubscrPaymentRequest."Pay by Link URL" := PayByLinkURL;
            IsModified := true;
        end;

        if SubscrPaymentRequest."Pay By Link Expires At" <> PayByLinkExpiresAt then begin
            SubscrPaymentRequest."Pay By Link Expires At" := PayByLinkExpiresAt;
            IsModified := true;
        end;

        if IsModified then
            SubscrPaymentRequest.Modify(true);
    end;

    local procedure UpdateSubscriptionRequestStatus(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; Status: Enum "NPR MM Payment Request Status"; ProcessingStatus: Enum "NPR MM SubsPayReqLogProcStatus")
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        Modified: Boolean;
    begin
        if not SubscriptionRequest.Get(SubscrPaymentRequest."Subscr. Request Entry No.") then
            exit;

        case Status of
            Status::Cancelled:
                begin
                    if SubscriptionRequest.Status <> SubscriptionRequest.Status::Cancelled then begin
                        SubscriptionRequest.Status := SubscriptionRequest.Status::Cancelled;
                        Modified := true;
                    end;

                    case ProcessingStatus of
                        ProcessingStatus::Error:
                            if SubscriptionRequest."Processing Status" <> SubscriptionRequest."Processing Status"::Error then begin
                                SubscriptionRequest."Processing Status" := SubscriptionRequest."Processing Status"::Error;
                                Modified := true;
                            end;
                        ProcessingStatus::Success:
                            if SubscriptionRequest."Processing Status" <> SubscriptionRequest."Processing Status"::Success then begin
                                SubscriptionRequest."Processing Status" := SubscriptionRequest."Processing Status"::Success;
                                Modified := true;
                            end;
                    end;

                    if Modified then
                        SubscriptionRequest.Modify(true);
                end;
        end;
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

    local procedure SendCancelPayByLinkRequest(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; RequestJsonText: Text; MMSubsAdyenPGSetup: Record "NPR MM Subs Adyen PG Setup"; var Response: Text) Success: Boolean
    var
        URL: Text;
        StatusCode: Integer;
    begin
        Url := MMSubsAdyenPGSetup.GetAPIPayByLinkUrl() + '/' + SubscrPaymentRequest."Pay by Link ID";

        Success := TryInvokeAPI(RequestJsonText, MMSubsAdyenPGSetup.GetApiKey(), URL, 1000 * 60 * 5, Response, StatusCode, 'Patch');
    end;

    local procedure ProcessCancelledPayByLinkStatus(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; SkipTryCountUpdate: Boolean; Manual: Boolean) Success: Boolean
    var
        SubsAdyenPGSetup: Record "NPR MM Subs Adyen PG Setup";
        RecurPaymSetup: Record "NPR MM Recur. Paym. Setup";
        SubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry";
        SubsPayReqLogUtils: Codeunit "NPR MM Subs Pay Req Log Utils";
        Request: Text;
        Response: Text;
        ErrorMessage: Text;
    begin
        SubsPayReqLogUtils.LogEntry(SubscrPaymentRequest,
                                    '',
                                    '',
                                    Manual,
                                    SubsPayReqLogEntry);

        if SubscrPaymentRequest."Pay by Link ID" = '' then begin
            ErrorMessage := '';
            ProcessResponse(SubscrPaymentRequest,
                            SubsPayReqLogEntry,
                            Request,
                            Response,
                            ErrorMessage,
                            Enum::"NPR MM Payment Request Status"::Cancelled,
                            SubsPayReqLogEntry."Processing Status"::Success,
                            RecurPaymSetup."Max. Pay. Process Try Count",
                            SubscrPaymentRequest."Rejected Reason Code",
                            SubscrPaymentRequest."Rejected Reason Description",
                            SubscrPaymentRequest."Result Code",
                            SubsAdyenPGSetup.Code,
                            SkipTryCountUpdate,
                            SubscrPaymentRequest."PSP Reference",
                            SubscrPaymentRequest."Payment PSP Reference",
                            SubscrPaymentRequest."Pay by Link ID",
                            SubscrPaymentRequest."Pay by Link URL",
                            SubscrPaymentRequest."Pay By Link Expires At",
                            0);

            Success := true;
            exit;
        end;

        ClearLastError();

        if not TryGetAdyenPaymentGatewaySetup(SubsAdyenPGSetup) then begin
            ErrorMessage := GetLastErrorText();
            ProcessResponse(SubscrPaymentRequest,
                             SubsPayReqLogEntry,
                             '',
                             '',
                             ErrorMessage,
                             SubscrPaymentRequest.Status::Cancelled,
                             SubsPayReqLogEntry."Processing Status"::Error,
                             RecurPaymSetup."Max. Pay. Process Try Count",
                             SubscrPaymentRequest."Rejected Reason Code",
                             SubscrPaymentRequest."Rejected Reason Description",
                             SubscrPaymentRequest."Result Code",
                             SubsAdyenPGSetup.Code,
                             SkipTryCountUpdate,
                             SubscrPaymentRequest."PSP Reference",
                             SubscrPaymentRequest."Payment PSP Reference",
                             SubscrPaymentRequest."Pay by Link ID",
                             SubscrPaymentRequest."Pay by Link URL",
                             SubscrPaymentRequest."Pay By Link Expires At",
                             0);
            exit;
        end;

        if not TryGetPayByLinkCancelRequestJsonText(Request) then begin
            ErrorMessage := GetLastErrorText();
            ProcessResponse(SubscrPaymentRequest,
                             SubsPayReqLogEntry,
                             '',
                             '',
                             ErrorMessage,
                             SubscrPaymentRequest.Status::Cancelled,
                             SubsPayReqLogEntry."Processing Status"::Error,
                             RecurPaymSetup."Max. Pay. Process Try Count",
                             SubscrPaymentRequest."Rejected Reason Code",
                             SubscrPaymentRequest."Rejected Reason Description",
                             SubscrPaymentRequest."Result Code",
                             SubsAdyenPGSetup.Code,
                             SkipTryCountUpdate,
                             SubscrPaymentRequest."PSP Reference",
                             SubscrPaymentRequest."Payment PSP Reference",
                             SubscrPaymentRequest."Pay by Link ID",
                             SubscrPaymentRequest."Pay by Link URL",
                             SubscrPaymentRequest."Pay By Link Expires At",
                             0);
            exit;
        end;

        if not SendCancelPayByLinkRequest(SubscrPaymentRequest, Request, SubsAdyenPGSetup, Response) then begin
            ErrorMessage := GetErrorMessageFromResponse(Response);
            if ErrorMessage = '' then
                ErrorMessage := GetLastErrorText();

            ProcessResponse(SubscrPaymentRequest,
                             SubsPayReqLogEntry,
                             '',
                             '',
                             ErrorMessage,
                             SubscrPaymentRequest.Status::Cancelled,
                             SubsPayReqLogEntry."Processing Status"::Error,
                             RecurPaymSetup."Max. Pay. Process Try Count",
                             SubscrPaymentRequest."Rejected Reason Code",
                             SubscrPaymentRequest."Rejected Reason Description",
                             SubscrPaymentRequest."Result Code",
                             SubsAdyenPGSetup.Code,
                             SkipTryCountUpdate,
                             SubscrPaymentRequest."PSP Reference",
                             SubscrPaymentRequest."Payment PSP Reference",
                             SubscrPaymentRequest."Pay by Link ID",
                             SubscrPaymentRequest."Pay by Link URL",
                             SubscrPaymentRequest."Pay By Link Expires At",
                             0);
            exit;
        end;

        ErrorMessage := '';
        ProcessResponse(SubscrPaymentRequest,
                        SubsPayReqLogEntry,
                        Request,
                        Response,
                        ErrorMessage,
                        Enum::"NPR MM Payment Request Status"::Cancelled,
                        SubsPayReqLogEntry."Processing Status"::Success,
                        RecurPaymSetup."Max. Pay. Process Try Count",
                        SubscrPaymentRequest."Rejected Reason Code",
                        SubscrPaymentRequest."Rejected Reason Description",
                        SubscrPaymentRequest."Result Code",
                        SubsAdyenPGSetup.Code,
                        SkipTryCountUpdate,
                        SubscrPaymentRequest."PSP Reference",
                        SubscrPaymentRequest."Payment PSP Reference",
                        SubscrPaymentRequest."Pay by Link ID",
                        SubscrPaymentRequest."Pay by Link URL",
                        SubscrPaymentRequest."Pay By Link Expires At",
                        0);

        Success := true;
    end;

    [TryFunction]
    local procedure TryGetPayByLinkCancelRequestJsonText(var RequestJsonText: Text)
    var
        Json: Codeunit "Json Text Reader/Writer";
    begin
        Json.WriteStartObject('');
        Json.WriteStringProperty('status', 'expired');
        Json.WriteEndObject();
        RequestJsonText := Json.GetJSonAsText();
    end;

    [TryFunction]
    local procedure TryGetPayByLinkRequestJsonText(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; RecurringProcessingModel: Enum "NPR MM SubsAdyenRecProcModel"; PayByLinkDuration: Duration; var RequestJsonText: Text)
    var
        Json: Codeunit "Json Text Reader/Writer";
        CurrencyCode: Code[10];
        Reference: Text;
        MerchantName: Text[50];
        ShopperReference: Text[50];
        ExpireDate: DateTime;
        ISO8601Date: Text[50];
    begin
        if SubscrPaymentRequest.PSP <> SubscrPaymentRequest.PSP::Adyen then
            exit;

        CurrencyCode := GetCurrencyCode(SubscrPaymentRequest);
        Reference := GetReference(SubscrPaymentRequest);
        MerchantName := GetMerchantName();

        if Format(PayByLinkDuration) <> '' then begin
            ExpireDate := CurrentDateTime + PayByLinkDuration;
            ISO8601Date := Format(ExpireDate, 0, 9);
        end;

        GetMemberShopperReference(SubscrPaymentRequest, ShopperReference);
        //root
        Json.WriteStartObject('');

        //amount
        Json.WriteStartObject('amount');
        Json.WriteStringProperty('value', ConvertToAdyenPayAmount(SubscrPaymentRequest.Amount));
        Json.WriteStringProperty('currency', CurrencyCode);
        Json.WriteEndObject();
        // amount

        Json.WriteStringProperty('reference', Reference);
        Json.WriteStringProperty('shopperInteraction', 'ContAuth');
        Json.WriteStringProperty('merchantAccount', MerchantName);
        Json.WriteStringProperty('recurringProcessingModel', RecurringProcessingModel.Names.Get(RecurringProcessingModel.Ordinals.IndexOf(RecurringProcessingModel.AsInteger())));
        Json.WriteStringProperty('shopperReference', ShopperReference);
        Json.WriteStringProperty('storePaymentMethodMode', 'enabled');
        Json.WriteStringProperty('expiresAt', ISO8601Date);
        Json.WriteStringProperty('captureDelayHours', '0');
        Json.WriteEndObject();
        //root
        RequestJsonText := Json.GetJSonAsText();
    end;

    local procedure SendPayByLinkRequest(RequestJsonText: Text; MMSubsAdyenPGSetup: Record "NPR MM Subs Adyen PG Setup"; var Response: Text) Success: Boolean
    var
        URL: Text;
        StatusCode: Integer;
    begin
        URL := MMSubsAdyenPGSetup.GetAPIPayByLinkUrl();

        Success := TryInvokeAPI(RequestJsonText, MMSubsAdyenPGSetup.GetApiKey(), URL, 1000 * 60 * 5, Response, StatusCode, 'POST');
    end;

    [TryFunction]
    local procedure TryGetPayByLinkIdFromResponse(Response: Text; var PayByLinkId: Code[20])
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        JObject.ReadFrom(Response);
        JObject.Get('id', JToken);
#pragma warning disable AA0139
        PayByLinkId := JToken.AsValue().AsText();
#pragma warning restore AA0139
    end;

    [TryFunction]
    local procedure TryGetPayByLinkURLFromResponse(Response: Text; var PayByLinkURL: Text[2048])
    var
        JsonO: JsonObject;
        JsonT: JsonToken;
    begin
        JsonO.ReadFrom(Response);
        JsonO.Get('url', JsonT);
#pragma warning disable AA0139
        PayByLinkUrl := JsonT.AsValue().AsText();
#pragma warning restore AA0139
    end;

    [TryFunction]
    local procedure TryGetPayByLinkExpiresAtFromResponse(Response: Text; var PayByExpiresAt: DateTime)
    var
        JsonO: JsonObject;
        JsonT: JsonToken;
        ExipresAtISO8601: Text;
    begin
        JsonO.ReadFrom(Response);
        JsonO.Get('expiresAt', JsonT);
        ExipresAtISO8601 := JsonT.AsValue().AsText();
        Evaluate(PayByExpiresAt, ExipresAtISO8601, 9);
    end;

    [TryFunction]
    internal procedure TryGetPaymentMethodData(JsonObjectToken: JsonToken; var TempMMPaymentMethod: Record "NPR MM Member Payment Method" temporary)
    var
        JsonValueToken: JsonToken;
    begin
        TempMMPaymentMethod.Init();

        JsonObjectToken.AsObject().Get('recurring.recurringDetailReference', JsonValueToken);
        TempMMPaymentMethod."Payment Token" := CopyStr(JsonValueToken.AsValue().AsText(), 1, MaxStrLen(TempMMPaymentMethod."Payment Token"));

        JsonObjectToken.AsObject().Get('recurring.shopperReference', JsonValueToken);
        TempMMPaymentMethod."Shopper Reference" := CopyStr(JsonValueToken.AsValue().AsText(), 1, MaxStrLen(TempMMPaymentMethod."Shopper Reference"));

        if JsonObjectToken.AsObject().Get('cardSummary', JsonValueToken) then
            TempMMPaymentMethod."PAN Last 4 Digits" := CopyStr(JsonValueToken.AsValue().AsText(), 1, MaxStrLen(TempMMPaymentMethod."PAN Last 4 Digits"));

        if JsonObjectToken.AsObject().Get('expiryDate', JsonValueToken) then
            TempMMPaymentMethod."Expiry Date" := GetLastDayOfExpiryMonth(JsonValueToken.AsValue().AsText());

        if JsonObjectToken.AsObject().Get('cardPaymentMethod', JsonValueToken) then
            TempMMPaymentMethod."Payment Brand" := CopyStr(JsonValueToken.AsValue().AsText(), 1, MaxStrLen(TempMMPaymentMethod."Payment Brand"));

        TempMMPaymentMethod.Insert();
    end;

    procedure InsertNewMMPaymentMethod(var AdyenWebhook: Record "NPR Adyen Webhook"; var Membership: Record "NPR MM Membership"; var TempMemberPaymentMethod: Record "NPR MM Member Payment Method" temporary)
    var
        MMMemberPaymentMethod: Record "NPR MM Member Payment Method";
        CardInstrumentTypeLbl: Label 'Card', Locked = true;
    begin
        MMMemberPaymentMethod.SetRange("Payment Token", TempMemberPaymentMethod."Payment Token");
        MMMemberPaymentMethod.SetRange("Shopper Reference", TempMemberPaymentMethod."Shopper Reference");
        MMMemberPaymentMethod.SetRange("BC Record ID", Membership.RecordId);
        if MMMemberPaymentMethod.FindFirst() then begin //MMPayment Method already exist
            if not MMMemberPaymentMethod.Default then begin
                MMMemberPaymentMethod.Validate(Default, true);
                MMMemberPaymentMethod.Validate(Status, MMMemberPaymentMethod.Status::Active);
                MMMemberPaymentMethod.Modify();
            end;
            exit;
        end;

        MMMemberPaymentMethod.Init();
        MMMemberPaymentMethod."BC Record ID" := Membership.RecordId;
        MMMemberPaymentMethod."Table No." := Database::"NPR MM Membership";
        MMMemberPaymentMethod.Insert(true);

        MMMemberPaymentMethod."Payment Token" := TempMemberPaymentMethod."Payment Token";
        MMMemberPaymentMethod."Payment Instrument Type" := CardInstrumentTypeLbl;
        MMMemberPaymentMethod."Shopper Reference" := TempMemberPaymentMethod."Shopper Reference";
        MMMemberPaymentMethod."PAN Last 4 Digits" := TempMemberPaymentMethod."PAN Last 4 Digits";
        MMMemberPaymentMethod."Expiry Date" := TempMemberPaymentMethod."Expiry Date";
        MMMemberPaymentMethod."Payment Brand" := TempMemberPaymentMethod."Payment Brand";
        MMMemberPaymentMethod.PSP := MMMemberPaymentMethod.PSP::Adyen;
        MMMemberPaymentMethod."Created from System Id" := AdyenWebhook.SystemId;
        MMMemberPaymentMethod.Validate(Default, true);
        MMMemberPaymentMethod.Validate(Status, MMMemberPaymentMethod.Status::Active);
        MMMemberPaymentMethod.Modify(true);
    end;

    procedure GetLastDayOfExpiryMonth(expiryDateStr: Text): Date
    var
        monthText: Text[2];
        yearText: Text[4];
        month: Integer;
        year: Integer;
        lastDayDate: Date;
        separatorPos: Integer;
    begin
        // Find the position of the "/" separator
        separatorPos := StrPos(expiryDateStr, '/');

        // Extract the month and year as text
        monthText := CopyStr(CopyStr(expiryDateStr, 1, separatorPos - 1), 1, MaxStrLen(monthText));
        yearText := CopyStr(CopyStr(expiryDateStr, separatorPos + 1), 1, MaxStrLen(yearText));

        // Convert month and year text to integer using Evaluate
        Evaluate(month, monthText);
        Evaluate(year, yearText);

        // Use DMY2Date to get the first day of the next month, then subtract 1 day
        if month = 12 then
            lastDayDate := DMY2Date(31, month, year) // December case
        else
            lastDayDate := DMY2Date(1, month + 1, year) - 1;

        exit(lastDayDate);
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
    local procedure TryRequestTypeIsSupportedByNewStatus(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request")
    var
        MustBeProcessedByReconciliationErr: Label 'Requests of type %1 must be initiated directly at the PSP and can only be created in BC by the reconciliation routine.', Comment = '%1 - request type (Enum "NPR MM Payment Request Type")';
        MustBeProcessedByWebhookEventErr: Label 'Requests of type %1 and status %2 cannot be processed directly. It needs to be processed by a webhook event issued by a PSP.', Comment = '%1 - request type (Enum "NPR MM Payment Request Type"), %2 - status';
    begin
        if not (SubscrPaymentRequest.Type In [SubscrPaymentRequest.Type::Payment, SubscrPaymentRequest.Type::Refund, SubscrPaymentRequest.Type::PayByLink]) then
            Error(MustBeProcessedByReconciliationErr, SubscrPaymentRequest.Type);

        if SubscrPaymentRequest.Type = SubscrPaymentRequest.Type::PayByLink then
            Error(MustBeProcessedByWebhookEventErr, SubscrPaymentRequest.Type, SubscrPaymentRequest.Status);
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
                                    PSPReference: Text[16];
                                    PaymentPSPReference: Text[16];
                                    PayByLinkId: Code[20];
                                    PayByLinkURL: Text[2048];
                                    PayByLinkExpiresAt: DateTime;
                                    WebhookEntryNo: Integer)
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
                                               SkipTryCountUpdate,
                                               PaymentPSPReference,
                                               PayByLinkId,
                                               PayByLinkURL,
                                               PayByLinkExpiresAt);

        UpdateSubscriptionRequestStatus(SubscrPaymentRequest,
                                        Status,
                                        ProcessingStatus);
        case ProcessingStatus of
            ProcessingStatus::Success:
                SubsPayReqLogUtils.UpdateEntry(SubsPayReqLogEntry,
                                               Request,
                                               Response,
                                               ProcessingStatus,
                                               '',
                                               SubscriptionsPaymentGatewayCode,
                                               WebhookEntryNo);
            ProcessingStatus::Error,
            ProcessingStatus::Rejected:
                begin
                    SubsPayReqLogUtils.UpdateEntry(SubsPayReqLogEntry,
                                                   Request,
                                                   Response,
                                                   ProcessingStatus,
                                                   Copystr(ErrorMessage, 1, MaxStrLen(SubsPayReqLogEntry."Error Message")),
                                                   SubscriptionsPaymentGatewayCode,
                                                   WebhookEntryNo);
                end;

        end;
    end;


    local procedure CreatePayByLinkSubscriptionRequest(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; var PayByLinkSubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; var PayByLinkSubscriptionRequest: Record "NPR MM Subscr. Request") Success: Boolean
    var
        SubsTryMethods: Codeunit "NPR MM Subs Try Methods";
    begin
        Clear(SubsTryMethods);
        SubsTryMethods.SetSubscriptionRequestEntryNo(SubscrPaymentRequest."Subscr. Request Entry No.");
        SubsTryMethods.SetSubscriptionPaymentRequestEntryNo(SubscrPaymentRequest."Entry No.");
        SubsTryMethods.SetProcessingOption(1);
        Success := SubsTryMethods.Run();
        if not Success then
            exit;

        SubsTryMethods.GetPayByLinkSubscriptionRequest(PayByLinkSubscriptionRequest);
        SubsTryMethods.GetPayByLinkSubscriptionPaymentRequest(PayByLinkSubscrPaymentRequest);
    end;

    [TryFunction]
    local procedure TryGetOriginalPaymentRequest(var SubscrPmtRefundRequest: Record "NPR MM Subscr. Payment Request"; var SubscrPmtOriginalRequest: Record "NPR MM Subscr. Payment Request")
    begin
        SubscrPmtOriginalRequest.SetRange("Reversed by Entry No.", SubscrPmtRefundRequest."Entry No.");
        SubscrPmtOriginalRequest.FindLast();
    end;

    [TryFunction]
    local procedure TryGetPaymentPSPFromRespondse(ResponseText: Text; var PaymentPSPReference: Text[16])
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        if ResponseText = '' then
            exit;

        if not JsonObject.ReadFrom(ResponseText) then
            exit;

        if not JsonObject.Get('paymentPspReference', JsonToken) then
            exit;

        PaymentPSPReference := Copystr(JsonToken.AsValue().AsText(), 1, MaxStrLen(PaymentPSPReference));
    end;

    procedure EnableIntegration(var SubsPaymentGateway: Record "NPR MM Subs. Payment Gateway")
    var
        SubsAdyenPGSetup: Record "NPR MM Subs Adyen PG Setup";
    begin
        if SubsPaymentGateway."Integration Type" <> SubsPaymentGateway."Integration Type"::Adyen then
            exit;

        SubsAdyenPGSetup.SetLoadFields("Merchant Name");
        SubsAdyenPGSetup.Get(SubsPaymentGateway.Code);
        SubsAdyenPGSetup.TestField("Merchant Name");

        EnsureAdyenSetup();
        SetupPayByLink();

        if SubsPaymentGateway.Status <> SubsPaymentGateway.Status::Enabled then begin
            SubsPaymentGateway.Status := SubsPaymentGateway.Status::Enabled;
            SubsPaymentGateway.Modify(true);
        end;
    end;

    local procedure SetupPayByLink()
    var
        AdyenWebhookType: Enum "NPR Adyen Webhook Type";
        AdyenManagement: Codeunit "NPR Adyen Management";
        MerchantAccount: Record "NPR Adyen Merchant Account";
        AuthorisationEventFilter: Label 'AUTHORISATION', Locked = true;
        RecurringContractFilter: Label 'RECURRING_CONTRACT', Locked = true;
        RefundEventFilter: Label 'REFUND', Locked = true;
    begin
        AdyenManagement.SchedulePayByLinkStatusJQ();
        AdyenManagement.ScheduleRecurringContractJQ();
        AdyenManagement.SchedulePayByLinkCancelJQ();
        AdyenManagement.ScheduleRefundStatusJQ();

        AdyenManagement.UpdateMerchantList(0);
        if MerchantAccount.FindSet() then
            repeat
                AdyenManagement.EnsureAdyenWebhookSetup(AuthorisationEventFilter, MerchantAccount.Name, AdyenWebhookType::standard);
                AdyenManagement.EnsureAdyenWebhookSetup(RecurringContractFilter, MerchantAccount.Name, AdyenWebhookType::standard);
                AdyenManagement.EnsureAdyenWebhookSetup(RefundEventFilter, MerchantAccount.Name, AdyenWebhookType::standard);
            until MerchantAccount.Next() = 0;
    end;

    local procedure EnsureAdyenSetup()
    var
        NPPaySetup: Record "NPR Adyen Setup";
    begin
        if not NPPaySetup.Get() then begin
            NPPaySetup.Init();
            NPPaySetup.Insert();
        end;

        if not NPPaySetup."Enable Reconciliation" then begin
            NPPaySetup.Validate("Enable Reconciliation", true);
            NPPaySetup.Modify();
        end;
    end;

    local procedure POSRenewLineExist(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request") LineExist: Boolean
    var
        Membership: Record "NPR MM Membership";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin
        GetMembership(SubscrPaymentRequest, Membership);

        MemberInfoCapture.SetRange("Membership Entry No.", Membership."Entry No.");
        MemberInfoCapture.SetRange("Response Status", MemberInfoCapture."Response Status"::REGISTERED);
        MemberInfoCapture.SetFilter("Receipt No.", '<>%1', '');
        MemberInfoCapture.SetFilter("Line No.", '<>%1', 0);
        LineExist := not MemberInfoCapture.IsEmpty();
    end;

    internal procedure CreateRefundWebhook(MerchantName: Text[50])
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
        RefundEventFilter: Label 'REFUND', Locked = true;
        AdyenWebhookType: Enum "NPR Adyen Webhook Type";
    begin
        AdyenManagement.EnsureAdyenWebhookSetup(RefundEventFilter, MerchantName, AdyenWebhookType::standard);
    end;

    procedure DisableIntegration(var SubsPaymentGateway: Record "NPR MM Subs. Payment Gateway")
    begin


    end;
}