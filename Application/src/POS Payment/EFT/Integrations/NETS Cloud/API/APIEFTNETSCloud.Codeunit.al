#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248752 "NPR API EFT NETS Cloud" implements "NPR API EFT Provider"
{
    Access = Internal;

    var
        _Sentry: Codeunit "NPR Sentry";
        _MissingCredentialsLbl: Label 'Payment method ''%1'' has no %2 configured in %3', Comment = '%1 = POS Payment Method Code, %2 = API Username field caption, %3 = NETS Cloud Payment Setup table caption';
        _MissingTerminalIdLbl: Label 'POS Unit ''%1'' has no NETS Cloud %2 configured for payment method ''%3''. NETS Cloud requires an %4 on the POS Unit itself', Comment = '%1 = POS Unit No., %2 = Terminal ID field caption, %3 = POS Payment Method Code, %4 = EFT Setup table caption';
        _TerminalBusyLbl: Label 'NETS Cloud terminal ''%1'' on POS Unit ''%2'' is still processing an earlier payment', Comment = '%1 = Terminal ID, %2 = POS Unit No.';
        _LaterTransactionStartedLbl: Label 'A later transaction has already been started on NETS Cloud terminal ''%1''. Prepare a new transaction', Comment = '%1 = Terminal ID';
        _UnresolvedPaymentLbl: Label 'An earlier payment on NETS Cloud terminal ''%1'' has an unknown result. Staff must look it up or void it in Business Central before the terminal can be used again', Comment = '%1 = Terminal ID';
        _SignatureVoidedLbl: Label 'The terminal requested a signature, which a self-service unit cannot verify. The payment was voided.';
        _SignatureVoidUnknownLbl: Label 'The terminal requested a signature and the attempt to void the payment has an unknown result.';
        _RecoveredVoidedLbl: Label 'The payment was recovered after NETS Cloud did not answer and voided, because the self-service sale was never completed.';
        _RecoveredVoidUnknownLbl: Label 'The payment was recovered after NETS Cloud did not answer and the attempt to void it has an unknown result.';
        _ErrorLogLbl: Label 'Error: %1 \\%2', Locked = true;

    procedure IntegrationType(): Code[20]
    var
        EFTNETSCloudIntegration: Codeunit "NPR EFT NETSCloud Integrat.";
    begin
        exit(EFTNETSCloudIntegration.IntegrationType());
    end;

    procedure Flow(): Enum "NPR API EFT Flow"
    begin
        exit(Enum::"NPR API EFT Flow"::Cloud);
    end;

    procedure ValidateSetup(EFTSetup: Record "NPR EFT Setup"; POSUnitNo: Code[10]; var ErrorMessage: Text): Boolean
    var
        EFTNETSCloudPaymentSetup: Record "NPR EFT NETS Cloud Paym. Setup";
        EFTNETSCloudUnitSetup: Record "NPR EFT NETSCloud Unit Setup";
    begin
        EFTNETSCloudPaymentSetup.SetLoadFields("API Username");
        if not EFTNETSCloudPaymentSetup.Get(EFTSetup."Payment Type POS") or (EFTNETSCloudPaymentSetup."API Username" = '') then begin
            ErrorMessage := StrSubstNo(_MissingCredentialsLbl, EFTSetup."Payment Type POS", EFTNETSCloudPaymentSetup.FieldCaption("API Username"), EFTNETSCloudPaymentSetup.TableCaption());
            exit(false);
        end;

        EFTNETSCloudUnitSetup.SetLoadFields("Terminal ID");
        if (EFTSetup."POS Unit No." <> POSUnitNo) or not EFTNETSCloudUnitSetup.Get(EFTSetup."POS Unit No.") or (EFTNETSCloudUnitSetup."Terminal ID" = '') then begin
            ErrorMessage := StrSubstNo(_MissingTerminalIdLbl, POSUnitNo, EFTNETSCloudUnitSetup.FieldCaption("Terminal ID"), EFTSetup."Payment Type POS", EFTSetup.TableCaption());
            exit(false);
        end;

        ErrorMessage := TerminalBlockedMessage(EFTNETSCloudUnitSetup."Terminal ID", POSUnitNo, 0);
        exit(ErrorMessage = '');
    end;

    procedure ValidateStart(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var ErrorMessage: Text): Boolean
    begin
        ErrorMessage := TerminalBlockedMessage(EFTTransactionRequest."Hardware ID", EFTSetup."POS Unit No.", EFTTransactionRequest."Entry No.");
        if ErrorMessage <> '' then
            exit(false);

        if LaterTransactionStarted(EFTTransactionRequest) then begin
            ErrorMessage := StrSubstNo(_LaterTransactionStartedLbl, EFTTransactionRequest."Hardware ID");
            exit(false);
        end;

        exit(true);
    end;

    procedure StartCloudPayment(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; POSSale: Record "NPR POS Sale")
    var
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
        Token: Text;
        Response: Text;
        LookupResponse: Text;
        ErrorText: Text;
    begin
        if not TryGetToken(EFTSetup, Token) then begin
            ErrorText := GetLastErrorText();
            EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, true, 'API Start (Login Error)', ErrorText);
            MarkNeverSentToTerminal(EFTTransactionRequest."Entry No.");
            Commit();
            EFTNETSCloudProtocol.ProcessAsyncResponse(EFTTransactionRequest."Entry No.", false, '', CopyStr(ErrorText, 1, MaxStrLen(EFTTransactionRequest."NST Error")));
            exit;
        end;

        ClearLastError();
        if not EFTNETSCloudProtocol.InvokeTransaction(EFTTransactionRequest, EFTSetup, Token, Response) then begin
            ErrorText := GetLastErrorText();
            EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, true, 'API Start (Error)', StrSubstNo(_ErrorLogLbl, ErrorText, EFTNETSCloudProtocol.GetLogBuffer()));
            Commit();

            if TryLookupResult(EFTTransactionRequest, EFTSetup, Token, EFTNETSCloudProtocol, LookupResponse) then begin
                EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, false, 'API Start (Lookup Complete)', EFTNETSCloudProtocol.GetLogBuffer());
                CompletePayment(EFTTransactionRequest."Entry No.", LookupResponse);
                exit;
            end;

            EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, true, 'API Start (Lookup Error)', StrSubstNo(_ErrorLogLbl, GetLastErrorText(), EFTNETSCloudProtocol.GetLogBuffer()));
            Commit();
            EFTNETSCloudProtocol.ProcessAsyncResponse(EFTTransactionRequest."Entry No.", false, Response, CopyStr(ErrorText, 1, MaxStrLen(EFTTransactionRequest."NST Error")));
            exit;
        end;

        EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, false, 'API Start (Complete)', EFTNETSCloudProtocol.GetLogBuffer());
        CompletePayment(EFTTransactionRequest."Entry No.", Response);
    end;

    procedure CancelCloudPayment(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup")
    var
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
        Token: Text;
        Response: Text;
        ErrorText: Text;
    begin
        if not TryGetToken(EFTSetup, Token) then begin
            ErrorText := GetLastErrorText();
            EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, true, 'API Cancel (Login Error)', ErrorText);
            _Sentry.AddLastErrorIfProgrammingBug();
            exit;
        end;

        ClearLastError();
        if EFTNETSCloudProtocol.InvokeCancelAction(EFTTransactionRequest, Token, Response) then begin
            EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, false, 'API Cancel (Complete)', EFTNETSCloudProtocol.GetLogBuffer());
            exit;
        end;

        ErrorText := GetLastErrorText();
        EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, true, 'API Cancel (Error)', StrSubstNo(_ErrorLogLbl, ErrorText, EFTNETSCloudProtocol.GetLogBuffer()));
        _Sentry.AddLastErrorIfProgrammingBug();
    end;

    local procedure CompletePayment(EntryNo: Integer; Response: Text)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
    begin
        if IsSignatureApproval(Response) then
            SetReversalStatus(EntryNo, EFTTransactionRequest."Selfservice Reversal Status"::Pending, '');
        Commit();
        EFTNETSCloudProtocol.ProcessAsyncResponse(EntryNo, true, Response, '');

        VoidIfSignatureRequired(EntryNo);
    end;

    local procedure TerminalBlockedMessage(TerminalID: Text; POSUnitNo: Code[10]; ExcludeEntryNo: Integer): Text
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        FilterFinancialTransactionsOnTerminal(EFTTransactionRequest, TerminalID);
        if ExcludeEntryNo <> 0 then
            EFTTransactionRequest.SetFilter("Entry No.", '<>%1', ExcludeEntryNo);

        EFTTransactionRequest.SetFilter(Started, '>%1', CurrentDateTime - InFlightWindowMs());
        EFTTransactionRequest.SetRange(Finished, 0DT);
        if not EFTTransactionRequest.IsEmpty() then
            exit(StrSubstNo(_TerminalBusyLbl, TerminalID, POSUnitNo));

        EFTTransactionRequest.SetRange(Finished);
        EFTTransactionRequest.SetRange(Started);
        EFTTransactionRequest.SetRange("Selfservice Reversal Status", EFTTransactionRequest."Selfservice Reversal Status"::Pending);
        if not EFTTransactionRequest.IsEmpty() then
            exit(StrSubstNo(_TerminalBusyLbl, TerminalID, POSUnitNo));

        EFTTransactionRequest.SetRange("Selfservice Reversal Status");
        EFTTransactionRequest.SetRange("Self Service", true);
        EFTTransactionRequest.SetFilter(Started, '<>%1', 0DT);
        EFTTransactionRequest.SetFilter(Finished, '<>%1', 0DT);
        EFTTransactionRequest.SetRange("External Result Known", false);
        EFTTransactionRequest.SetRange(Recovered, false);
        if EFTTransactionRequest.FindSet() then
            repeat
                TryResolveUnknownPayment(EFTTransactionRequest);
            until EFTTransactionRequest.Next() = 0;
        if not EFTTransactionRequest.IsEmpty() then
            exit(StrSubstNo(_UnresolvedPaymentLbl, TerminalID));

        exit('');
    end;

    local procedure TryResolveUnknownPayment(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
    begin
        Commit();
        if Codeunit.Run(Codeunit::"NPR API EFT NETS Resolve", EFTTransactionRequest) then
            exit;
        EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, true, 'API Resolve (Error)', GetLastErrorText());
        _Sentry.AddLastErrorIfProgrammingBug();
        Commit();
    end;

    local procedure MarkNeverSentToTerminal(EntryNo: Integer)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.Get(EntryNo);
        EFTTransactionRequest."External Result Known" := true;
        EFTTransactionRequest.Successful := false;
        EFTTransactionRequest.Modify();
    end;

    local procedure LaterTransactionStarted(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        LaterEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        FilterFinancialTransactionsOnTerminal(LaterEFTTransactionRequest, EFTTransactionRequest."Hardware ID");
        LaterEFTTransactionRequest.SetFilter("Entry No.", '>%1', EFTTransactionRequest."Entry No.");
        LaterEFTTransactionRequest.SetFilter(Started, '<>%1', 0DT);
        exit(not LaterEFTTransactionRequest.IsEmpty());
    end;

    local procedure FilterFinancialTransactionsOnTerminal(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; TerminalID: Text)
    begin
        EFTTransactionRequest.SetRange("Hardware ID", TerminalID);
        EFTTransactionRequest.SetRange("Integration Type", IntegrationType());
        EFTTransactionRequest.SetFilter("Processing Type", '%1|%2|%3',
            EFTTransactionRequest."Processing Type"::PAYMENT,
            EFTTransactionRequest."Processing Type"::REFUND,
            EFTTransactionRequest."Processing Type"::GIFTCARD_LOAD);
    end;

    local procedure InFlightWindowMs(): Integer
    begin
        exit(6 * 60 * 1000);
    end;

    [TryFunction]
    local procedure TryLookupResult(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; Token: Text; var EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol"; var LookupResponse: Text)
    var
        EFTNETSCloudRespParser: Codeunit "NPR EFT NETSCloud Resp. Parser";
    begin
        Sleep(5 * 1000);

        ClearLastError();
        if not EFTNETSCloudProtocol.InvokeLookupLastTransaction(EFTTransactionRequest, EFTSetup, EFTTransactionRequest, 60 * 1000, Token, LookupResponse) then
            Error(GetLastErrorText());
        if not EFTNETSCloudRespParser.IsLookupResponseRelatedToTransaction(LookupResponse, EFTTransactionRequest) then
            Error(GetLastErrorText());
    end;

    local procedure VoidIfSignatureRequired(EntryNo: Integer)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTNETSCloudIntegration: Codeunit "NPR EFT NETSCloud Integrat.";
    begin
        EFTTransactionRequest.Get(EntryNo);
        if not EFTNETSCloudIntegration.SignaturePrompt(EFTTransactionRequest) then begin
            if EFTTransactionRequest."Selfservice Reversal Status" = EFTTransactionRequest."Selfservice Reversal Status"::Pending then
                SetReversalStatus(EntryNo, EFTTransactionRequest."Selfservice Reversal Status"::" ", '');
            exit;
        end;

        VoidPayment(EntryNo, 'API Signature Void', _SignatureVoidedLbl, _SignatureVoidUnknownLbl);
    end;

    procedure VoidRecoveredPayment(EntryNo: Integer)
    begin
        VoidPayment(EntryNo, 'API Recovered Payment Void', _RecoveredVoidedLbl, _RecoveredVoidUnknownLbl);
    end;

    local procedure VoidPayment(EntryNo: Integer; LogTitle: Text; VoidedText: Text; VoidUnknownText: Text)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        VoidEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
        ErrorText: Text;
    begin
        EFTTransactionRequest.Get(EntryNo);
        SetReversalStatus(EntryNo, EFTTransactionRequest."Selfservice Reversal Status"::Pending, '');
        Commit();

        if not Codeunit.Run(Codeunit::"NPR API EFT NETS Sig. Void", EFTTransactionRequest) then begin
            ErrorText := GetLastErrorText();
            EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, true, LogTitle + ' (Error)', ErrorText);
            _Sentry.AddLastErrorIfProgrammingBug();
        end;

        EFTTransactionRequest.Get(EntryNo);
        case true of
            EFTTransactionRequest.Reversed:
                begin
                    SetReversalStatus(EntryNo, EFTTransactionRequest."Selfservice Reversal Status"::Reversed, VoidedText);
                    EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, false, LogTitle + ' (Complete)', '');
                end;
            FindVoidRequest(EntryNo, VoidEFTTransactionRequest) and VoidResultIsUnknown(VoidEFTTransactionRequest):
                begin
                    SetReversalStatus(EntryNo, EFTTransactionRequest."Selfservice Reversal Status"::Unknown, VoidUnknownText);
                    EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, true, LogTitle + ' (Unknown)', '');
                end;
            else begin
                SetReversalStatus(EntryNo, EFTTransactionRequest."Selfservice Reversal Status"::Failed, '');
                EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, true, LogTitle + ' (Failed)', '');
            end;
        end;
    end;

    local procedure VoidResultIsUnknown(VoidEFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin
        if not VoidEFTTransactionRequest."External Result Known" then
            exit(true);
        exit(VoidEFTTransactionRequest.Successful);
    end;

    local procedure FindVoidRequest(EntryNo: Integer; var VoidEFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin
        VoidEFTTransactionRequest.SetRange("Processed Entry No.", EntryNo);
        VoidEFTTransactionRequest.SetRange("Processing Type", VoidEFTTransactionRequest."Processing Type"::VOID);
        exit(VoidEFTTransactionRequest.FindLast());
    end;

    local procedure SetReversalStatus(EntryNo: Integer; ReversalStatus: Integer; ResultDisplayText: Text)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.Get(EntryNo);
        EFTTransactionRequest."Selfservice Reversal Status" := ReversalStatus;
        if ResultDisplayText <> '' then
            EFTTransactionRequest."Result Display Text" := CopyStr(ResultDisplayText, 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));
        EFTTransactionRequest.Modify();
    end;

    local procedure IsSignatureApproval(Response: Text): Boolean
    var
        JObject: JsonObject;
        ResultToken: JsonToken;
        ArgsToken: JsonToken;
        JToken: JsonToken;
        ResultCode: Integer;
        CVM: Integer;
    begin
        if not JObject.ReadFrom(Response) then
            exit(false);
        if not JObject.Get('result', ResultToken) then
            exit(false);
        if not TryGetLocalModeArgs(ResultToken, ArgsToken) then
            exit(false);
        if not ArgsToken.AsObject().Get('Result', JToken) then
            exit(false);
        if not Evaluate(ResultCode, JToken.AsValue().AsText()) then
            exit(false);
        if not ArgsToken.AsObject().Get('CVM', JToken) then
            exit(false);
        if not Evaluate(CVM, JToken.AsValue().AsText()) then
            exit(false);
        exit((ResultCode = 0) and (CVM = 1));
    end;

    local procedure TryGetLocalModeArgs(ResultToken: JsonToken; var ArgsToken: JsonToken): Boolean
    var
        FirstResult: JsonToken;
    begin
        if ResultToken.IsArray() then begin
            if ResultToken.AsArray().Count() = 0 then
                exit(false);
            ResultToken.AsArray().Get(0, FirstResult);
            if not FirstResult.IsObject() then
                exit(false);
            if not FirstResult.AsObject().Get('localModeEventArgs', ArgsToken) then
                exit(false);
            exit(ArgsToken.IsObject());
        end;
        if not ResultToken.IsObject() then
            exit(false);
        if not ResultToken.AsObject().Get('latestTransactionResult', ArgsToken) then
            exit(false);
        exit(ArgsToken.IsObject());
    end;

    [TryFunction]
    local procedure TryGetToken(EFTSetup: Record "NPR EFT Setup"; var Token: Text)
    var
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
    begin
        Token := EFTNETSCloudProtocol.GetToken(EFTSetup);
    end;
}
#endif
