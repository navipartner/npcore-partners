#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6184831 "NPR API EFT NETS Resolve"
{
    Access = Internal;
    TableNo = "NPR EFT Transaction Request";

    var
        _NotSelfServicePaymentErr: Label 'Only NETS Cloud card payments on a self-service sale can be resolved here.';
        _NotSentErr: Label 'This transaction was never sent to the terminal, so there is nothing to resolve.';
        _ResultAlreadyKnownErr: Label 'The result of this transaction is already known.';
        _CannotVoidErr: Label 'Only an approved NETS Cloud payment that has not been reversed can be voided.';
        _SaleGoneErr: Label 'The sale of this payment no longer exists, so the payment cannot be voided from Business Central. Refund the customer in the NETS portal.';
        _NoAnswerMsg: Label 'NETS Cloud did not answer. Try again later, or mark the transaction as resolved after checking it in the NETS portal.';
        _OtherTransactionMsg: Label 'The last transaction on terminal %1 is not this one, so NETS Cloud cannot confirm its result. Check it in the NETS portal and mark the transaction as resolved if the customer was not charged.', Comment = '%1 = Terminal ID';
        _DeclinedMsg: Label 'NETS Cloud reports the payment as not approved. The terminal accepts new payments again.';
        _SaleGoneMsg: Label 'The payment was approved but its sale no longer exists, so it cannot be voided from Business Central. Refund the customer in the NETS portal.';
        _VoidRecoveredQst: Label 'NETS Cloud reports the payment of %1 %2 as approved, but the self-service sale was never completed. Void the payment now so the customer can pay again?', Comment = '%1 = Amount, %2 = Currency Code';
        _PaymentStandsMsg: Label 'The approved payment has been recorded on the sale and stands. Use Void Payment if the customer should get the money back.';
        _VoidedMsg: Label 'The payment has been voided. The terminal accepts new payments again.';
        _VoidUnknownMsg: Label 'The void was sent, but its result is unknown. Check the NETS portal.';
        _VoidFailedMsg: Label 'NETS Cloud refused the void. The payment stands.';
        _MarkedResolvedLbl: Label 'Marked as resolved by %1 without a result from NETS Cloud', Comment = '%1 = User ID';
        _ErrorLogLbl: Label 'Error: %1 \\%2', Locked = true;

    trigger OnRun()
    begin
        LookUp(Rec, 10 * 1000, true);
    end;

    procedure LookUp(var EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    begin
        exit(LookUp(EFTTransactionRequest, 60 * 1000, false));
    end;

    procedure VoidPayment(var EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    var
        POSSale: Record "NPR POS Sale";
        APIEFTNETSCloud: Codeunit "NPR API EFT NETS Cloud";
        APIPOSSale: Codeunit "NPR API POS Sale";
    begin
        CheckNETSCloudPayment(EFTTransactionRequest);
        if not (EFTTransactionRequest."External Result Known" and EFTTransactionRequest.Successful) or EFTTransactionRequest.Reversed then
            Error(_CannotVoidErr);
        if not POSSale.GetBySystemId(EFTTransactionRequest."Sales ID") then
            Error(_SaleGoneErr);

        APIPOSSale.ReconstructSession(POSSale.SystemId);
        Commit();
        APIEFTNETSCloud.VoidRecoveredPayment(EFTTransactionRequest."Entry No.");
        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");
        exit(ReversalMessage(EFTTransactionRequest));
    end;

    procedure MarkResolved(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
        ResolvedText: Text;
    begin
        CheckResultUnknown(EFTTransactionRequest);
        ResolvedText := StrSubstNo(_MarkedResolvedLbl, UserId());

        EFTTransactionRequest."External Result Known" := true;
        EFTTransactionRequest.Successful := false;
        EFTTransactionRequest."Result Display Text" := CopyStr(ResolvedText, 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));
        EFTTransactionRequest.Modify();
        AddComment(EFTTransactionRequest, ResolvedText);
        EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, false, 'API Resolve (Marked Resolved)', ResolvedText);
    end;

    local procedure LookUp(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; TimeoutMs: Integer; VoidWithoutAsking: Boolean): Text
    var
        EFTSetup: Record "NPR EFT Setup";
        POSSale: Record "NPR POS Sale";
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
        APIEFTNETSCloud: Codeunit "NPR API EFT NETS Cloud";
        APIPOSSale: Codeunit "NPR API POS Sale";
        Token: Text;
        LookupResponse: Text;
    begin
        CheckResultUnknown(EFTTransactionRequest);
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        ClearLastError();
        if not TryGetToken(EFTSetup, Token) then begin
            EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, true, 'API Resolve (Login Error)', GetLastErrorText());
            Commit();
            exit(_NoAnswerMsg);
        end;

        ClearLastError();
        if not TryLookup(EFTTransactionRequest, EFTSetup, TimeoutMs, Token, EFTNETSCloudProtocol, LookupResponse) then begin
            EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, true, 'API Resolve (Lookup Error)', StrSubstNo(_ErrorLogLbl, GetLastErrorText(), EFTNETSCloudProtocol.GetLogBuffer()));
            Commit();
            exit(_NoAnswerMsg);
        end;

        ClearLastError();
        if not TryCheckLookupIsThisTransaction(LookupResponse, EFTTransactionRequest) then begin
            EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, true, 'API Resolve (Other Transaction)', StrSubstNo(_ErrorLogLbl, GetLastErrorText(), EFTNETSCloudProtocol.GetLogBuffer()));
            Commit();
            exit(StrSubstNo(_OtherTransactionMsg, EFTTransactionRequest."Hardware ID"));
        end;

        if not POSSale.GetBySystemId(EFTTransactionRequest."Sales ID") then
            exit(RecordResultWithoutSale(EFTTransactionRequest, EFTNETSCloudProtocol, LookupResponse));

        APIPOSSale.ReconstructSession(POSSale.SystemId);
        EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, false, 'API Resolve (Lookup Complete)', EFTNETSCloudProtocol.GetLogBuffer());
        Commit();
        EFTNETSCloudProtocol.ProcessAsyncResponse(EFTTransactionRequest."Entry No.", true, LookupResponse, '');
        Commit();

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");
        if not EFTTransactionRequest.Successful then
            exit(_DeclinedMsg);

        if not VoidWithoutAsking then
            if not Confirm(StrSubstNo(_VoidRecoveredQst, EFTTransactionRequest."Result Amount", EFTTransactionRequest."Currency Code"), true) then
                exit(_PaymentStandsMsg);

        APIEFTNETSCloud.VoidRecoveredPayment(EFTTransactionRequest."Entry No.");
        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");
        exit(ReversalMessage(EFTTransactionRequest));
    end;

    local procedure RecordResultWithoutSale(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; var EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol"; LookupResponse: Text): Text
    var
        EFTNETSCloudRespParser: Codeunit "NPR EFT NETSCloud Resp. Parser";
    begin
        EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, false, 'API Resolve (Lookup Complete, Sale Gone)', EFTNETSCloudProtocol.GetLogBuffer());
        Commit();

        EFTNETSCloudRespParser.SetResponseData('Payment', LookupResponse, EFTTransactionRequest."Entry No.");
        if not EFTNETSCloudRespParser.Run() then
            Error(GetLastErrorText());

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");
        if not EFTTransactionRequest.Successful then
            exit(_DeclinedMsg);

        EFTTransactionRequest."Selfservice Reversal Status" := EFTTransactionRequest."Selfservice Reversal Status"::Failed;
        EFTTransactionRequest."Result Display Text" := CopyStr(_SaleGoneMsg, 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));
        EFTTransactionRequest.Modify();
        EFTNETSCloudProtocol.WriteLogEntry(EFTTransactionRequest, true, 'API Resolve (Approved, Sale Gone)', _SaleGoneMsg);
        Commit();
        exit(_SaleGoneMsg);
    end;

    [TryFunction]
    local procedure TryGetToken(EFTSetup: Record "NPR EFT Setup"; var Token: Text)
    var
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
    begin
        Token := EFTNETSCloudProtocol.GetToken(EFTSetup);
    end;

    [TryFunction]
    local procedure TryLookup(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; TimeoutMs: Integer; Token: Text; var EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol"; var LookupResponse: Text)
    begin
        if not EFTNETSCloudProtocol.InvokeLookupLastTransaction(EFTTransactionRequest, EFTSetup, EFTTransactionRequest, TimeoutMs, Token, LookupResponse) then
            Error(GetLastErrorText());
    end;

    [TryFunction]
    local procedure TryCheckLookupIsThisTransaction(LookupResponse: Text; EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTNETSCloudRespParser: Codeunit "NPR EFT NETSCloud Resp. Parser";
    begin
        EFTNETSCloudRespParser.IsLookupResponseRelatedToTransaction(LookupResponse, EFTTransactionRequest);
    end;

    local procedure CheckResultUnknown(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        CheckNETSCloudPayment(EFTTransactionRequest);
        if EFTTransactionRequest.Started = 0DT then
            Error(_NotSentErr);
        if EFTTransactionRequest."External Result Known" or EFTTransactionRequest.Recovered then
            Error(_ResultAlreadyKnownErr);
    end;

    local procedure CheckNETSCloudPayment(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTNETSCloudIntegration: Codeunit "NPR EFT NETSCloud Integrat.";
    begin
        if (EFTTransactionRequest."Integration Type" <> EFTNETSCloudIntegration.IntegrationType()) or
           (EFTTransactionRequest."Processing Type" <> EFTTransactionRequest."Processing Type"::PAYMENT) or
           (not EFTTransactionRequest."Self Service")
        then
            Error(_NotSelfServicePaymentErr);
    end;

    local procedure ReversalMessage(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    begin
        case EFTTransactionRequest."Selfservice Reversal Status" of
            EFTTransactionRequest."Selfservice Reversal Status"::Reversed:
                exit(_VoidedMsg);
            EFTTransactionRequest."Selfservice Reversal Status"::Unknown:
                exit(_VoidUnknownMsg);
            else
                exit(_VoidFailedMsg);
        end;
    end;

    local procedure AddComment(EFTTransactionRequest: Record "NPR EFT Transaction Request"; CommentText: Text)
    var
        EFTTransactReqComment: Record "NPR EFT Transact. Req. Comment";
    begin
        EFTTransactReqComment.SetRange("Entry No.", EFTTransactionRequest."Entry No.");
        if EFTTransactReqComment.FindLast() then;
        EFTTransactReqComment.Init();
        EFTTransactReqComment."Entry No." := EFTTransactionRequest."Entry No.";
        EFTTransactReqComment."Line No." += 10000;
        EFTTransactReqComment.Comment := CopyStr(CommentText, 1, MaxStrLen(EFTTransactReqComment.Comment));
        EFTTransactReqComment.Insert();
    end;
}
#endif
