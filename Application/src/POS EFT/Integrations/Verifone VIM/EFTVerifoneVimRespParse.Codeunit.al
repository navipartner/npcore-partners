codeunit 6184528 "NPR EFT VerifoneVim Resp.Parse"
{
    Access = Internal;
    // NPR5.53/MMV /20191204 CASE 349520 Added object
    // NPR5.54/MMV /20200325 CASE 364340 Handle sign correctly whend voiding refund


    trigger OnRun()
    begin
        ParseResponse();
    end;

    var
        ResponseType: Text;
        StargateEnvelope: DotNet NPRNetResponseEnvelope0;
        SerializedResponse: Text;
        EftTransactionEntryNo: Integer;
        ERR_RESPONSE_TYPE: Label 'Critical error:\Unknown Verifone VIM response type: %1\Cannot establish response context';
        ERR_SIGNATURE_PRINT: Label 'Could not parse signature receipt response';

    local procedure ParseResponse()
    begin
        case ResponseType of
            'Login':
                ParseLoginResponse(StargateEnvelope);
            'Logout':
                ParseLogoutResponse(StargateEnvelope);
            'TransactionStatus':
                ParseTransactionStatusResponse(StargateEnvelope);
            'VerifySetup':
                ParseVerifySetupResponse();
            'TransactionResponse':
                ParseTransactionResponse(SerializedResponse);
            'SaveTrxReferenceNumber':
                ParseStoreReferenceIDResponse(SerializedResponse);
            'PrintSignatureReceipt':
                ParseSignatureReceiptResponse(SerializedResponse);
            'BalanceEnquiryResponse':
                ParseBalanceEnquiryResponse(SerializedResponse);
            'Reconciliation':
                ParseReconciliationResponse(StargateEnvelope);
            else
                Error(ERR_RESPONSE_TYPE, ResponseType);
        end;
    end;

    procedure SetResponseEnvelope(ResponseTypeIn: Text; StargateEnvelopeIn: DotNet NPRNetResponseEnvelope0)
    begin
        ResponseType := ResponseTypeIn;
        StargateEnvelope := StargateEnvelopeIn;
    end;

    procedure SetResponseEvent(ResponseTypeIn: Text; SerializedResponseIn: Text)
    begin
        ResponseType := ResponseTypeIn;
        SerializedResponse := SerializedResponseIn;
    end;

    procedure TryGetEftTransactionEntryNo(var EftEntryNoOut: Integer): Boolean
    begin
        if EftTransactionEntryNo = 0 then
            exit(false);
        EftEntryNoOut := EftTransactionEntryNo;
        exit(true);
    end;

    local procedure ParseLoginResponse(Envelope: DotNet NPRNetResponseEnvelope0)
    var
        POSStargateManagement: Codeunit "NPR POS Stargate Management";
        LoginResponse: DotNet NPRNetLoginResponse;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEndManagement, true);

        POSStargateManagement.DeserializeEnvelope(Envelope, LoginResponse, POSFrontEndManagement);
        EftTransactionEntryNo := LoginResponse.EftEntryNo;

        EFTTransactionRequest.Get(EftTransactionEntryNo);
        EFTTransactionRequest.Successful := LoginResponse.Success;
        if not EFTTransactionRequest.Successful then begin
            EFTTransactionRequest."Client Error" := CopyStr(LoginResponse.ErrorMessage, 1, MaxStrLen(EFTTransactionRequest."Client Error"));
            EFTTransactionRequest."Result Description" := CopyStr(LoginResponse.ErrorMessage, 1, MaxStrLen(EFTTransactionRequest."Result Description"));
        end;
        EFTTransactionRequest."Client Assembly Version" := LoginResponse.ExecutingAssemblyVersion;
        EFTTransactionRequest.Modify(true);
    end;

    local procedure ParseLogoutResponse(Envelope: DotNet NPRNetResponseEnvelope0)
    var
        POSStargateManagement: Codeunit "NPR POS Stargate Management";
        LogoutResponse: DotNet NPRNetLogoutResponse;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEndManagement, true);

        POSStargateManagement.DeserializeEnvelope(Envelope, LogoutResponse, POSFrontEndManagement);
        EftTransactionEntryNo := LogoutResponse.EftEntryNo;

        EFTTransactionRequest.Get(EftTransactionEntryNo);
        EFTTransactionRequest.Successful := LogoutResponse.Success;
        if not EFTTransactionRequest.Successful then begin
            EFTTransactionRequest."Client Error" := CopyStr(LogoutResponse.ErrorMessage, 1, MaxStrLen(EFTTransactionRequest."Client Error"));
            EFTTransactionRequest."Result Description" := CopyStr(LogoutResponse.ErrorMessage, 1, MaxStrLen(EFTTransactionRequest."Result Description"));
        end;
        EFTTransactionRequest."Client Assembly Version" := LogoutResponse.ExecutingAssemblyVersion;
        EFTTransactionRequest.Modify(true);
    end;

    local procedure ParseTransactionResponse(Data: Text)
    var
        TransactionResponse: DotNet NPRNetTransactionResponse1;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        JSONSerializer: DotNet NPRNetSerializer;
    begin
        TransactionResponse := JSONSerializer.DeserializeAsType(Data, GetDotNetType(TransactionResponse));
        EftTransactionEntryNo := TransactionResponse.EftEntryNo;

        EFTTransactionRequest.Get(EftTransactionEntryNo);
        EFTTransactionRequest.Successful := TransactionResponse.Success;
        EFTTransactionRequest."External Result Known" := TransactionResponse.ReceivedExternalResponse;
        EFTTransactionRequest."Client Assembly Version" := TransactionResponse.ExecutingAssemblyVersion;

        ParseTransactionResponseContents(EFTTransactionRequest, TransactionResponse);

        EFTTransactionRequest.Modify(true);
    end;

    local procedure ParseTransactionStatusResponse(Envelope: DotNet NPRNetResponseEnvelope0)
    var
        TransactionStatusResponse: DotNet NPRNetTransactionStatusResponse;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSStargateManagement: Codeunit "NPR POS Stargate Management";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        OriginalEftTrxRequest: Record "NPR EFT Transaction Request";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEndManagement, true);

        POSStargateManagement.DeserializeEnvelope(Envelope, TransactionStatusResponse, POSFrontEndManagement);
        EftTransactionEntryNo := TransactionStatusResponse.LookupEftEntryNo;

        EFTTransactionRequest.Get(EftTransactionEntryNo);
        EFTTransactionRequest.Successful := TransactionStatusResponse.LookupSuccess;
        EFTTransactionRequest."External Result Known" := TransactionStatusResponse.LookupReceivedExternalResponse;
        EFTTransactionRequest."Client Assembly Version" := TransactionStatusResponse.ExecutingAssemblyVersion;

        if EFTTransactionRequest.Successful then begin
            ParseTransactionResponseContents(EFTTransactionRequest, TransactionStatusResponse.OriginalTransactionResponse);
            OriginalEftTrxRequest.Get(EFTTransactionRequest."Processed Entry No.");
            EFTTransactionRequest."Currency Code" := OriginalEftTrxRequest."Currency Code"; //Implied, API status response does not contain the currency code.
            EFTTransactionRequest."Reference Number Output" := OriginalEftTrxRequest."Reference Number Output";
        end else begin
            EFTTransactionRequest."Result Description" := CopyStr(TransactionStatusResponse.LookupErrorReason, 1, MaxStrLen(EFTTransactionRequest."Result Description"));
            EFTTransactionRequest."Client Error" := CopyStr(TransactionStatusResponse.LookupErrorMessage, 1, MaxStrLen(EFTTransactionRequest."Client Error"));
        end;

        EFTTransactionRequest.Modify(true);
    end;

    local procedure ParseVerifySetupResponse()
    begin
    end;

    local procedure ParseBalanceEnquiryResponse(Data: Text)
    var
        BalanceEnquiryResponse: DotNet NPRNetBalanceEnquiryResponse;
        JSONSerializer: DotNet NPRNetSerializer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        BalanceEnquiryResponse := JSONSerializer.DeserializeAsType(Data, GetDotNetType(BalanceEnquiryResponse));
        EftTransactionEntryNo := BalanceEnquiryResponse.EftEntryNo;

        EFTTransactionRequest.Get(EftTransactionEntryNo);
        EFTTransactionRequest.Successful := BalanceEnquiryResponse.Success;
        EFTTransactionRequest."External Result Known" := BalanceEnquiryResponse.ReceivedExternalResponse;
        EFTTransactionRequest."Client Assembly Version" := BalanceEnquiryResponse.ExecutingAssemblyVersion;

        EFTTransactionRequest."Currency Code" := BalanceEnquiryResponse.Currency;
        EFTTransactionRequest."Amount Output" := BalanceEnquiryResponse.Balance;
        EFTTransactionRequest."Result Amount" := BalanceEnquiryResponse.Balance;
        EFTTransactionRequest."Card Number" := BalanceEnquiryResponse.Pan;
        if EFTTransactionRequest."Card Number" = '' then
            EFTTransactionRequest."Card Number" := BalanceEnquiryResponse.MaskedPan;
        EFTTransactionRequest."Hardware ID" := BalanceEnquiryResponse.TerminalID;
        EFTTransactionRequest."Force Closed" := BalanceEnquiryResponse.ForceAborted;
        EFTTransactionRequest."Card Expiry Date" := BalanceEnquiryResponse.ExpiryDate;
        EFTTransactionRequest."Card Issuer ID" := BalanceEnquiryResponse.PaymentBrand;
        EFTTransactionRequest."Card Name" := BalanceEnquiryResponse.PaymentBrand;
        EFTTransactionRequest."Result Description" := CopyStr(BalanceEnquiryResponse.ErrorReason, 1, MaxStrLen(EFTTransactionRequest."Result Description"));
        EFTTransactionRequest."Client Error" := CopyStr(BalanceEnquiryResponse.ErrorMessage, 1, MaxStrLen(EFTTransactionRequest."Client Error"));
    end;

    local procedure ParseReconciliationResponse(Envelope: DotNet NPRNetResponseEnvelope0)
    var
        POSStargateManagement: Codeunit "NPR POS Stargate Management";
        ReconciliationResponse: DotNet NPRNetReconciliationResponse;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEndManagement, true);

        POSStargateManagement.DeserializeEnvelope(Envelope, ReconciliationResponse, POSFrontEndManagement);
        EftTransactionEntryNo := ReconciliationResponse.EftEntryNo;

        EFTTransactionRequest.Get(EftTransactionEntryNo);
        EFTTransactionRequest.Successful := ReconciliationResponse.Success;
        if not EFTTransactionRequest.Successful then begin
            EFTTransactionRequest."Client Error" := CopyStr(ReconciliationResponse.ErrorMessage, 1, MaxStrLen(EFTTransactionRequest."Client Error"));
            EFTTransactionRequest."Result Description" := CopyStr(ReconciliationResponse.ErrorMessage, 1, MaxStrLen(EFTTransactionRequest."Result Description"));
        end;
        EFTTransactionRequest."Client Assembly Version" := ReconciliationResponse.ExecutingAssemblyVersion;
        EFTTransactionRequest.Modify(true);
    end;

    local procedure ParseSignatureReceiptResponse(Data: Text)
    var
        TransactionResponse: DotNet NPRNetTransactionResponse1;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        OutStream: OutStream;
        JSONSerializer: DotNet NPRNetSerializer;
    begin
        TransactionResponse := JSONSerializer.DeserializeAsType(Data, GetDotNetType(TransactionResponse));
        EftTransactionEntryNo := TransactionResponse.EftEntryNo;

        EFTTransactionRequest.Get(EftTransactionEntryNo);
        EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::Signature;
        EFTTransactionRequest."Signature Type" := EFTTransactionRequest."Signature Type"::"On Receipt";
        EFTTransactionRequest."Receipt 1".CreateOutStream(OutStream);
        if not ParseReceipt(EFTTransactionRequest, TransactionResponse.Receipt1, OutStream) then
            Error(ERR_SIGNATURE_PRINT);
        EFTTransactionRequest.Modify(true);
    end;

    local procedure ParseStoreReferenceIDResponse(Data: Text)
    var
        TransactionResponse: DotNet NPRNetTransactionResponse1;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        JSONSerializer: DotNet NPRNetSerializer;
    begin
        TransactionResponse := JSONSerializer.DeserializeAsType(Data, GetDotNetType(TransactionResponse));
        EftTransactionEntryNo := TransactionResponse.EftEntryNo;

        EFTTransactionRequest.Get(EftTransactionEntryNo);
        EFTTransactionRequest."Reference Number Output" := TransactionResponse.TrxReferenceServiceId;
        EFTTransactionRequest.Modify(true);
    end;

    local procedure ParseReceipt(EFTTransactionRequest: Record "NPR EFT Transaction Request"; Receipt: DotNet NPRNetList_Of_T; var BlobStream: OutStream): Boolean
    var
        CreditCardTransaction: Record "NPR EFT Receipt";
        EntryNo: Integer;
        ReceiptNo: Integer;
        Line: Text;
    begin
        if IsNull(Receipt) then
            exit(false);
        if Receipt.Count() = 0 then
            exit(false);

        CreditCardTransaction.SetRange("Register No.", EFTTransactionRequest."Register No.");
        CreditCardTransaction.SetRange("Sales Ticket No.", EFTTransactionRequest."Sales Ticket No.");
        EntryNo := 1;
        if (CreditCardTransaction.FindLast()) then begin
            EntryNo := CreditCardTransaction."Entry No." + 1;
            ReceiptNo := CreditCardTransaction."Receipt No." + 1;
        end;

        CreditCardTransaction.Init();
        CreditCardTransaction.Date := Today();
        CreditCardTransaction."Transaction Time" := Time;
        CreditCardTransaction.Type := 0;
        CreditCardTransaction."Register No." := EFTTransactionRequest."Register No.";
        CreditCardTransaction."Sales Ticket No." := EFTTransactionRequest."Sales Ticket No.";
        CreditCardTransaction."EFT Trans. Request Entry No." := EFTTransactionRequest."Entry No.";
        CreditCardTransaction."Receipt No." := ReceiptNo;

        foreach Line in Receipt do begin
            CreditCardTransaction."Entry No." := EntryNo;
            CreditCardTransaction.Text := Line;
            CreditCardTransaction.Insert();
            EntryNo += 1;

            BlobStream.Write(Line);
        end;

        exit(true);
    end;

    local procedure ParseTransactionResponseContents(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; TransactionResponse: DotNet NPRNetTransactionResponse1)
    var
        TrxDateTime: DateTime;
        DotNetDateTime: DotNet NPRNetDateTime;
        OutStream: OutStream;
        OriginalEftTrxReq: Record "NPR EFT Transaction Request";
        VoidedEftTrxReq: Record "NPR EFT Transaction Request";
        TextBuffer: Text;
    begin
        EFTTransactionRequest."Tip Amount" := TransactionResponse.TipAmount;
        EFTTransactionRequest."Hardware ID" := TransactionResponse.TerminalID;
        EFTTransactionRequest."Acquirer ID" := TransactionResponse.AcquirerTrxId;
        EFTTransactionRequest."Force Closed" := TransactionResponse.ForceAborted;
        EFTTransactionRequest."External Transaction ID" := TransactionResponse.TerminalTrxId;
        EFTTransactionRequest."Reconciliation ID" := TransactionResponse.TerminalReconciliationId;
        EFTTransactionRequest."Authorisation Number" := TransactionResponse.ApprovalCode;
        EFTTransactionRequest."Client Assembly Version" := TransactionResponse.ExecutingAssemblyVersion;

        //-NPR5.54 [364340]
        TextBuffer := TransactionResponse.MaskedPan;
        if TextBuffer <> '' then begin
            EFTTransactionRequest."Card Number" := TextBuffer;
        end;

        TextBuffer := TransactionResponse.PaymentBrand;
        if TextBuffer <> '' then begin
            EFTTransactionRequest."Card Issuer ID" := TextBuffer;
            EFTTransactionRequest."Card Name" := TextBuffer;
        end;
        //+NPR5.54 [364340]

        if not IsNull(TransactionResponse.TerminalTrxTimestamp) then begin
            DotNetDateTime := TransactionResponse.TerminalTrxTimestamp;
            TrxDateTime := DotNetDateTime;
            EFTTransactionRequest."Transaction Date" := DT2Date(TrxDateTime);
            EFTTransactionRequest."Transaction Time" := DT2Time(TrxDateTime);
        end;

        //-NPR5.54 [364340]
        if EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::LOOK_UP then begin
            OriginalEftTrxReq.Get(EFTTransactionRequest."Processed Entry No.");
        end else begin
            OriginalEftTrxReq.Get(EFTTransactionRequest."Entry No.");
        end;

        case OriginalEftTrxReq."Processing Type" of
            OriginalEftTrxReq."Processing Type"::PAYMENT:
                begin
                    EFTTransactionRequest."Amount Output" := TransactionResponse.AuthorizedAmount;
                    EFTTransactionRequest."Result Amount" := TransactionResponse.AuthorizedAmount;
                end;
            OriginalEftTrxReq."Processing Type"::GIFTCARD_LOAD,
            OriginalEftTrxReq."Processing Type"::REFUND:
                begin
                    EFTTransactionRequest."Amount Output" := TransactionResponse.AuthorizedAmount;
                    EFTTransactionRequest."Result Amount" := TransactionResponse.AuthorizedAmount * -1;
                end;
            OriginalEftTrxReq."Processing Type"::VOID:
                begin
                    EFTTransactionRequest."Amount Output" := TransactionResponse.AuthorizedAmount;

                    VoidedEftTrxReq.Get(OriginalEftTrxReq."Processed Entry No.");
                    case VoidedEftTrxReq."Processing Type" of
                        VoidedEftTrxReq."Processing Type"::PAYMENT:
                            EFTTransactionRequest."Result Amount" := TransactionResponse.AuthorizedAmount * -1;
                        VoidedEftTrxReq."Processing Type"::GIFTCARD_LOAD:
                            EFTTransactionRequest."Result Amount" := TransactionResponse.AuthorizedAmount;
                        VoidedEftTrxReq."Processing Type"::REFUND:
                            EFTTransactionRequest."Result Amount" := TransactionResponse.AuthorizedAmount;
                    end;
                end;
        end;
        //+NPR5.54 [364340]

        EFTTransactionRequest."Result Code" := TransactionResponse.ErrorCode;
        EFTTransactionRequest."Result Description" := CopyStr(TransactionResponse.ErrorReason, 1, MaxStrLen(EFTTransactionRequest."Result Description"));
        EFTTransactionRequest."Client Error" := CopyStr(TransactionResponse.ErrorMessage, 1, MaxStrLen(EFTTransactionRequest."Client Error"));

        case TransactionResponse.AuthenticationMethod of
            'BYPASS':
                EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::None;
            'MANUAL_VERIFICATION':
                ;
            'MERCHANT_AUTHENTICATION':
                ;
            'OFFLINE_PIN':
                EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::PIN;
            'ONLINE_PIN':
                EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::PIN;
            'PAPER_SIGNATURE':
                begin
                    EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::Signature;
                    EFTTransactionRequest."Signature Type" := EFTTransactionRequest."Signature Type"::"On Receipt";
                end;
            'SIGNATURE_CAPTURE':
                begin
                    EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::Signature;
                    EFTTransactionRequest."Signature Type" := EFTTransactionRequest."Signature Type"::"On Terminal";
                end;
            'UNKNOWN':
                ;
        end;

        if not EFTTransactionRequest."Receipt 1".HasValue() then begin //We might already have a signature merchant receipt
            EFTTransactionRequest."Receipt 1".CreateOutStream(OutStream);
            ParseReceipt(EFTTransactionRequest, TransactionResponse.Receipt1, OutStream);
        end;

        EFTTransactionRequest."Receipt 2".CreateOutStream(OutStream);
        ParseReceipt(EFTTransactionRequest, TransactionResponse.Receipt2, OutStream);
    end;
}

