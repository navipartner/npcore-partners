codeunit 6184542 "EFT NETS BAXI Resp. Parser"
{

    trigger OnRun()
    begin
        ParseResponse();
    end;

    var
        ResponseType: Text;
        StargateEnvelope: DotNet npNetResponseEnvelope0;
        SerializedResponse: Text;
        EftTransactionEntryNo: Integer;
        ERR_RESPONSE_TYPE: Label 'Critical error:\Unknown NETS BAXI response type: %1\Cannot establish response context';
        ERR_SIGNATURE_PRINT: Label 'Could not parse signature receipt response';
        CARD_BALANCE: Label 'Card Balance: %1';

    local procedure ParseResponse()
    begin
        case ResponseType of
          'Open' : ParseOpenResponse(StargateEnvelope);
          'Close' : ParseCloseResponse(StargateEnvelope);
          'GetLastResult' : ParseGetLastResponse(StargateEnvelope);
          'TransactionResponse' : ParseTransactionResponse(SerializedResponse);
          'BalanceEnquiry' : ParseTransactionResponse(SerializedResponse);
          'Deposit' : ParseTransactionResponse(SerializedResponse);
          'Reconciliation' : ParseAdministrationResponse(StargateEnvelope);
          'DownloadDataset' : ParseAdministrationResponse(StargateEnvelope);
          'DownloadSoftware' : ParseAdministrationResponse(StargateEnvelope);
          else
            Error(ERR_RESPONSE_TYPE, ResponseType);
        end;
    end;

    procedure SetResponseEnvelope(ResponseTypeIn: Text;StargateEnvelopeIn: DotNet npNetResponseEnvelope0)
    begin
        ResponseType := ResponseTypeIn;
        StargateEnvelope := StargateEnvelopeIn;
    end;

    procedure SetResponseEvent(ResponseTypeIn: Text;SerializedResponseIn: Text)
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

    local procedure ParseOpenResponse(Envelope: DotNet npNetResponseEnvelope0)
    var
        POSStargateManagement: Codeunit "POS Stargate Management";
        OpenResponse: DotNet npNetOpenResponse;
        POSSession: Codeunit "POS Session";
        POSFrontEndManagement: Codeunit "POS Front End Management";
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEndManagement, true);

        POSStargateManagement.DeserializeEnvelope(Envelope, OpenResponse, POSFrontEndManagement);
        EftTransactionEntryNo := OpenResponse.EftEntryNo;

        EFTTransactionRequest.Get(EftTransactionEntryNo);
        EFTTransactionRequest.Successful := OpenResponse.Success;
        if not EFTTransactionRequest.Successful then begin
          EFTTransactionRequest."Client Error" := CopyStr(OpenResponse.ErrorMessage,1,MaxStrLen(EFTTransactionRequest."Client Error"));
          EFTTransactionRequest."Result Description" := CopyStr(OpenResponse.ErrorMessage,1,MaxStrLen(EFTTransactionRequest."Result Description"));
        end;
        EFTTransactionRequest."Client Assembly Version" := OpenResponse.ExecutingAssemblyVersion;
        EFTTransactionRequest.Modify(true);
    end;

    local procedure ParseCloseResponse(Envelope: DotNet npNetResponseEnvelope0)
    var
        POSStargateManagement: Codeunit "POS Stargate Management";
        CloseResponse: DotNet npNetCloseResponse;
        POSSession: Codeunit "POS Session";
        POSFrontEndManagement: Codeunit "POS Front End Management";
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEndManagement, true);

        POSStargateManagement.DeserializeEnvelope(Envelope, CloseResponse, POSFrontEndManagement);
        EftTransactionEntryNo := CloseResponse.EftEntryNo;

        EFTTransactionRequest.Get(EftTransactionEntryNo);

        if (not IsNull(CloseResponse.AutoReconciliationResponse)) then begin
          EFTTransactionRequest.Successful := CloseResponse.AutoReconciliationResponse.Result = 1;
          if not EFTTransactionRequest.Successful then begin
            EFTTransactionRequest."Client Error" := CopyStr(CloseResponse.AutoReconciliationResponse.ErrorMessage,1,MaxStrLen(EFTTransactionRequest."Client Error"));
            EFTTransactionRequest."Result Description" := CopyStr(CloseResponse.AutoReconciliationResponse.ErrorMessage,1,MaxStrLen(EFTTransactionRequest."Result Description"));
          end;
          EFTTransactionRequest."Hardware ID" := CloseResponse.AutoReconciliationResponse.TerminalID;
          EFTTransactionRequest."Reconciliation ID" := CloseResponse.AutoReconciliationResponse.SessionNumber;
          ParseReceipts(EFTTransactionRequest, CloseResponse.AutoReconciliationResponse.Receipt1, CloseResponse.AutoReconciliationResponse.Receipt2);
        end else begin
          EFTTransactionRequest.Successful := CloseResponse.Success;
          if not EFTTransactionRequest.Successful then begin
            EFTTransactionRequest."Client Error" := CopyStr(CloseResponse.ErrorMessage,1,MaxStrLen(EFTTransactionRequest."Client Error"));
            EFTTransactionRequest."Result Description" := CopyStr(CloseResponse.ErrorMessage,1,MaxStrLen(EFTTransactionRequest."Result Description"));
          end;
        end;

        EFTTransactionRequest."Client Assembly Version" := CloseResponse.ExecutingAssemblyVersion;
        EFTTransactionRequest.Modify(true);
    end;

    local procedure ParseTransactionResponse(Data: Text)
    var
        TransactionResponse: DotNet npNetTransactionResponse2;
        EFTTransactionRequest: Record "EFT Transaction Request";
        JSONSerializer: DotNet npNetSerializer;
        TrxTimestamp: Text;
        DateTime: DateTime;
        Year: Integer;
        Month: Integer;
        Day: Integer;
        TrxTime: Time;
        VoidedEftTrxReq: Record "EFT Transaction Request";
    begin
        TransactionResponse := JSONSerializer.DeserializeAsType(Data, GetDotNetType(TransactionResponse));
        EftTransactionEntryNo := TransactionResponse.EftEntryNo;

        EFTTransactionRequest.Get(EftTransactionEntryNo);
        EFTTransactionRequest."Result Code" := TransactionResponse.Result;

        if EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::AUXILIARY] then begin
          EFTTransactionRequest.Successful := (EFTTransactionRequest."Result Code" = 1);
        end else begin
          EFTTransactionRequest.Successful := (EFTTransactionRequest."Result Code" = 0) and (TransactionResponse.ReceivedExternalResponse);
        end;

        EFTTransactionRequest."External Result Known" :=
          ((EFTTransactionRequest."Result Code" <> 99) and (TransactionResponse.ReceivedExternalResponse))
          or (not TransactionResponse.ExternalRequestSent);

        EFTTransactionRequest."Card Number" := TransactionResponse.TruncatedPan;
        EFTTransactionRequest."Card Issuer ID" := Format(TransactionResponse.IssuerId);
        EFTTransactionRequest."Reconciliation ID" := TransactionResponse.SessionNumber;
        EFTTransactionRequest."Hardware ID" := TransactionResponse.TerminalID;

        case TransactionResponse.VerificationMethod of
          0 : EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::PIN;
          1 : EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::Signature;
          2 : EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::None;
          3 : EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::Loyalty;
          4 : EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::ConsumerDevice;
        end;

        if (EFTTransactionRequest."Authentication Method" = EFTTransactionRequest."Authentication Method"::Signature) and
            (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::PAYMENT) then begin
            EFTTransactionRequest."Signature Type" := EFTTransactionRequest."Signature Type"::"On Receipt";
        end;

        TrxTimestamp := TransactionResponse.Timestamp;
        //NETS documentation does not detail when exactly they send an ISO 8601 datetime string versus purely numbers, but both were observed during development..
        if StrPos(TrxTimestamp, 'Z') > 0 then begin
          Evaluate(DateTime, TrxTimestamp, 9);

          EFTTransactionRequest."Transaction Date" := DT2Date(DateTime);
          EFTTransactionRequest."Transaction Time" := DT2Time(DateTime);
        end else if TrxTimestamp <> '' then begin
          Evaluate(Year, CopyStr(TrxTimestamp, 1, 4));
          Evaluate(Month, CopyStr(TrxTimestamp, 5, 2));
          Evaluate(Day, CopyStr(TrxTimestamp, 7, 2));
          Evaluate(TrxTime, CopyStr(TrxTimestamp, 9, 6));

          EFTTransactionRequest."Transaction Date" := DMY2Date(Day, Month, Year);
          EFTTransactionRequest."Transaction Time" := TrxTime;
        end;

        EFTTransactionRequest."Authorisation Number" := TransactionResponse.StanAuth;
        EFTTransactionRequest."Reference Number Output" := TransactionResponse.StanAuth;
        EFTTransactionRequest."External Transaction ID" := TransactionResponse.StanAuth;
        EFTTransactionRequest."Card Name" := TransactionResponse.CardIssuerName;
        EFTTransactionRequest."Card Application ID" := TransactionResponse.AID;

        if TransactionResponse.ResponseCode <> '' then begin
          EFTTransactionRequest."Result Description" := CopyStr('(' + TransactionResponse.ResponseCode + ')',1,MaxStrLen(EFTTransactionRequest."Result Description"));
          EFTTransactionRequest."Result Display Text" := CopyStr('(' + TransactionResponse.ResponseCode + ')',1,MaxStrLen(EFTTransactionRequest."Result Display Text"));
        end;

        if EFTTransactionRequest.Successful then begin
          if TransactionResponse.TipAmount <> 0 then begin
            EFTTransactionRequest."Tip Amount" := TransactionResponse.TipAmount / 100;
          end;
          if TransactionResponse.SurchargeAmount <> 0 then begin
            EFTTransactionRequest."Fee Amount" := TransactionResponse.SurchargeAmount / 100;
          end;
          EFTTransactionRequest."Amount Output" := TransactionResponse.TotalAmount / 100;
        end;

        ParseReceipts(EFTTransactionRequest, TransactionResponse.Receipt1, TransactionResponse.Receipt2);

        ParseOptionalData(EFTTransactionRequest, TransactionResponse.OptionalData);

        case EFTTransactionRequest."Processing Type" of
          EFTTransactionRequest."Processing Type"::PAYMENT : EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output";
          EFTTransactionRequest."Processing Type"::GIFTCARD_LOAD,
          EFTTransactionRequest."Processing Type"::REFUND : EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output" * -1;
          EFTTransactionRequest."Processing Type"::VOID :
            begin
              VoidedEftTrxReq.Get(EFTTransactionRequest."Processed Entry No.");
              case VoidedEftTrxReq."Processing Type" of
                VoidedEftTrxReq."Processing Type"::PAYMENT : EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output" * -1;
                VoidedEftTrxReq."Processing Type"::GIFTCARD_LOAD : EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output";
                VoidedEftTrxReq."Processing Type"::REFUND : EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output";
              end;
            end;
          EFTTransactionRequest."Processing Type"::AUXILIARY :
            case EFTTransactionRequest."Auxiliary Operation ID" of
              1 : //Balance Enquiry
                begin
                  if EFTTransactionRequest.Successful then begin
                    EFTTransactionRequest."Result Display Text" := CopyStr(StrSubstNo(CARD_BALANCE, EFTTransactionRequest."Amount Output"),1,MaxStrLen(EFTTransactionRequest."Result Display Text"));
                    //TODO:
                    //Undocumented by NETS where balance & expiry date is located in json respose.
                    //Test gift card is currently expired so cannot be check myself at this time.
                  end;
                end;
            end;
        end;

        EFTTransactionRequest."Client Assembly Version" := TransactionResponse.ExecutingAssemblyVersion;
        EFTTransactionRequest.Modify(true);
    end;

    local procedure ParseAdministrationResponse(Envelope: DotNet npNetResponseEnvelope0)
    var
        POSStargateManagement: Codeunit "POS Stargate Management";
        AdminResponse: DotNet npNetAdministrationResponse;
        POSSession: Codeunit "POS Session";
        POSFrontEndManagement: Codeunit "POS Front End Management";
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEndManagement, true);

        POSStargateManagement.DeserializeEnvelope(Envelope, AdminResponse, POSFrontEndManagement);
        EftTransactionEntryNo := AdminResponse.EftEntryNo;

        EFTTransactionRequest.Get(EftTransactionEntryNo);
        EFTTransactionRequest.Successful := AdminResponse.Result = 1;
        if not EFTTransactionRequest.Successful then begin
          EFTTransactionRequest."Client Error" := CopyStr(AdminResponse.ErrorMessage,1,MaxStrLen(EFTTransactionRequest."Client Error"));
          EFTTransactionRequest."Result Description" := CopyStr(AdminResponse.ErrorMessage,1,MaxStrLen(EFTTransactionRequest."Result Description"));
        end;

        EFTTransactionRequest."Hardware ID" := AdminResponse.TerminalID;
        EFTTransactionRequest."Reconciliation ID" := AdminResponse.SessionNumber;
        EFTTransactionRequest."Client Assembly Version" := AdminResponse.ExecutingAssemblyVersion;

        ParseReceipts(EFTTransactionRequest, AdminResponse.Receipt1, AdminResponse.Receipt2);

        EFTTransactionRequest.Modify(true);
    end;

    local procedure ParseGetLastResponse(Envelope: DotNet npNetResponseEnvelope0)
    var
        POSStargateManagement: Codeunit "POS Stargate Management";
        GetLastResponse: DotNet npNetGetLastResponse;
        POSSession: Codeunit "POS Session";
        POSFrontEndManagement: Codeunit "POS Front End Management";
        EFTTransactionRequest: Record "EFT Transaction Request";
        TrxTimestamp: Text;
        DateTime: DateTime;
        Year: Integer;
        Month: Integer;
        Day: Integer;
        TrxTime: Time;
        OriginalEFTTransactionRequest: Record "EFT Transaction Request";
        VoidedEftTrxReq: Record "EFT Transaction Request";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEndManagement, true);

        POSStargateManagement.DeserializeEnvelope(Envelope, GetLastResponse, POSFrontEndManagement);
        EftTransactionEntryNo := GetLastResponse.EftEntryNo;
        EFTTransactionRequest.Get(EftTransactionEntryNo);

        EFTTransactionRequest.Successful := GetLastResponse.GetLastResult = 1; //Lookup successful, not the actual trx.
        EFTTransactionRequest."External Result Known" := (GetLastResponse.GetLastResult <> 99) and (GetLastResponse.ExternalResponseReceived);

        if EFTTransactionRequest.Successful then begin
          EFTTransactionRequest."Card Number" := GetLastResponse.TruncatedPan;
          EFTTransactionRequest."Reconciliation ID" := GetLastResponse.SessionNumber;
          EFTTransactionRequest."Card Issuer ID" := Format(GetLastResponse.IssuerId);
          EFTTransactionRequest."Hardware ID" := GetLastResponse.TerminalID;

          case GetLastResponse.VerificationMethod of
            0 : EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::PIN;
            1 : EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::Signature;
            2 : EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::None;
            3 : EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::Loyalty;
            4 : EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::ConsumerDevice;
          end;

          if (EFTTransactionRequest."Authentication Method" = EFTTransactionRequest."Authentication Method"::Signature) and
              (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::PAYMENT) then begin
              EFTTransactionRequest."Signature Type" := EFTTransactionRequest."Signature Type"::"On Receipt";
          end;

          TrxTimestamp := GetLastResponse.Timestamp;
          //NETS documentation does not detail when exactly they send an ISO 8601 datetime string versus purely numbers, but both were observed during development..
          if StrPos(TrxTimestamp, 'Z') > 0 then begin
            Evaluate(DateTime, TrxTimestamp, 9);

            EFTTransactionRequest."Transaction Date" := DT2Date(DateTime);
            EFTTransactionRequest."Transaction Time" := DT2Time(DateTime);
          end else if TrxTimestamp <> '' then begin
            Evaluate(Year, CopyStr(TrxTimestamp, 1, 4));
            Evaluate(Month, CopyStr(TrxTimestamp, 5, 2));
            Evaluate(Day, CopyStr(TrxTimestamp, 7, 2));
            Evaluate(TrxTime, CopyStr(TrxTimestamp, 9, 6));

            EFTTransactionRequest."Transaction Date" := DMY2Date(Day, Month, Year);
            EFTTransactionRequest."Transaction Time" := TrxTime;
          end;

          EFTTransactionRequest."Authorisation Number" := GetLastResponse.StanAuth;
          EFTTransactionRequest."Reference Number Output" := GetLastResponse.StanAuth;
          EFTTransactionRequest."External Transaction ID" := GetLastResponse.StanAuth;
          EFTTransactionRequest."Card Name" := GetLastResponse.CardIssuerName;
          EFTTransactionRequest."Card Application ID" := GetLastResponse.AID;

          if GetLastResponse.Result = 0 then begin
            if GetLastResponse.TipAmount <> 0 then begin
              EFTTransactionRequest."Tip Amount" := GetLastResponse.TipAmount / 100;
            end;
            if GetLastResponse.SurchargeAmount <> 0 then begin
              EFTTransactionRequest."Fee Amount" := GetLastResponse.SurchargeAmount / 100;
            end;
            EFTTransactionRequest."Amount Output" := GetLastResponse.TotalAmount / 100;
          end else begin
            if GetLastResponse.ResponseCode <> '' then begin
              EFTTransactionRequest."Result Description" := CopyStr('(' + GetLastResponse.ResponseCode + ')',1,MaxStrLen(EFTTransactionRequest."Result Description"));
              EFTTransactionRequest."Result Display Text" := CopyStr('(' + GetLastResponse.ResponseCode + ')',1,MaxStrLen(EFTTransactionRequest."Result Display Text"));
            end;
          end;

          ParseReceipts(EFTTransactionRequest, GetLastResponse.Receipt1, GetLastResponse.Receipt2);

          ParseOptionalData(EFTTransactionRequest, GetLastResponse.OptionalData);

          OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
          case OriginalEFTTransactionRequest."Processing Type" of
            OriginalEFTTransactionRequest."Processing Type"::PAYMENT : EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output";
            OriginalEFTTransactionRequest."Processing Type"::GIFTCARD_LOAD,
            OriginalEFTTransactionRequest."Processing Type"::REFUND : EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output" * -1;
            OriginalEFTTransactionRequest."Processing Type"::VOID :
              begin
                VoidedEftTrxReq.Get(OriginalEFTTransactionRequest."Processed Entry No.");
                case VoidedEftTrxReq."Processing Type" of
                  VoidedEftTrxReq."Processing Type"::PAYMENT : EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output" * -1;
                  VoidedEftTrxReq."Processing Type"::GIFTCARD_LOAD : EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output";
                  VoidedEftTrxReq."Processing Type"::REFUND : EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output";
                end;
              end;
          end;
        end;

        EFTTransactionRequest."Client Assembly Version" := GetLastResponse.ExecutingAssemblyVersion;
        EFTTransactionRequest.Modify(true);
    end;

    local procedure ParseReceipts(var EFTTransactionRequest: Record "EFT Transaction Request";Receipt1: Text;Receipt2: Text)
    var
        ReceiptNo: Integer;
        EntryNo: Integer;
        OutStream: OutStream;
    begin
        ReceiptNo := GetLastReceiptNo(EFTTransactionRequest);
        EntryNo := GetLastReceiptLineEntryNo(EFTTransactionRequest);

        if Receipt1 <> '' then begin
          EFTTransactionRequest."Receipt 1".CreateOutStream(OutStream);
          ParseReceipt(EFTTransactionRequest, Receipt1, ReceiptNo, EntryNo, OutStream);
          Clear(OutStream);
        end;

        if Receipt2 <> '' then begin
          EFTTransactionRequest."Receipt 2".CreateOutStream(OutStream);
          ParseReceipt(EFTTransactionRequest, Receipt2, ReceiptNo, EntryNo, OutStream);
          Clear(OutStream);
        end;
    end;

    local procedure ParseReceipt(var EFTTransactionRequest: Record "EFT Transaction Request";Receipt: Text;var LastReceiptNo: Integer;var LastReceiptEntryNo: Integer;WriteToStream: OutStream)
    var
        JToken: DotNet npNetJToken;
        StringReader: DotNet npNetStringReader;
        ReceiptLine: DotNet npNetString;
    begin
        WriteToStream.Write(Receipt);

        StringReader := StringReader.StringReader(Receipt);
        ReceiptLine := StringReader.ReadLine();
        if not IsNull(ReceiptLine) then begin
          LastReceiptNo += 1;
        end;

        while (not IsNull(ReceiptLine)) do begin
          LastReceiptEntryNo += 1;
          InsertReceiptLine(ReceiptLine, LastReceiptNo, LastReceiptEntryNo, EFTTransactionRequest);
          ReceiptLine := StringReader.ReadLine();
        end;
    end;

    local procedure GetLastReceiptLineEntryNo(EFTTransactionRequest: Record "EFT Transaction Request"): Integer
    var
        CreditCardTransaction: Record "EFT Receipt";
    begin
        CreditCardTransaction.SetRange("Register No.", EFTTransactionRequest."Register No.");
        CreditCardTransaction.SetRange("Sales Ticket No.", EFTTransactionRequest."Sales Ticket No.");
        if (CreditCardTransaction.FindLast()) then;
        exit(CreditCardTransaction."Entry No.");
    end;

    local procedure GetLastReceiptNo(EFTTransactionRequest: Record "EFT Transaction Request"): Integer
    var
        CreditCardTransaction: Record "EFT Receipt";
    begin
        CreditCardTransaction.SetRange("Register No.", EFTTransactionRequest."Register No.");
        CreditCardTransaction.SetRange("Sales Ticket No.", EFTTransactionRequest."Sales Ticket No.");
        if (CreditCardTransaction.FindLast()) then;
        exit(CreditCardTransaction."Receipt No.");
    end;

    local procedure InsertReceiptLine(Line: Text;ReceiptNo: Integer;EntryNo: Integer;EFTTransactionRequest: Record "EFT Transaction Request")
    var
        CreditCardTransaction: Record "EFT Receipt";
    begin
        CreditCardTransaction.Init;
        CreditCardTransaction.Date := Today;
        CreditCardTransaction."Transaction Time" := Time;
        CreditCardTransaction."Register No." := EFTTransactionRequest."Register No.";
        CreditCardTransaction."Sales Ticket No." := EFTTransactionRequest."Sales Ticket No.";
        CreditCardTransaction."EFT Trans. Request Entry No." := EFTTransactionRequest."Entry No.";
        CreditCardTransaction."Receipt No." := ReceiptNo;
        CreditCardTransaction.Text := CopyStr(Line, 1, MaxStrLen(CreditCardTransaction.Text));
        CreditCardTransaction."Entry No." := EntryNo;
        CreditCardTransaction.Insert;
    end;

    local procedure ParseOptionalData(var EFTTransactionRequest: Record "EFT Transaction Request";OptionalData: Text)
    var
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJToken;
        DecimalBuffer: Decimal;
        JValue: DotNet npNetJValue;
        CultureInfo: DotNet npNetCultureInfo;
    begin
        if not TryParseOptionalData(JObject, OptionalData) then
          exit;

        if TrySelectToken(JObject, 'od.dcc', JToken, false) then begin
          EFTTransactionRequest."DCC Used" := true;
          EFTTransactionRequest."DCC Currency Code" := Format(JToken.Item('ccura'));

          if TrySelectValue(JToken, 'cam', JValue, false) then begin
            Evaluate(DecimalBuffer, JValue.ToString(CultureInfo.InvariantCulture), 9);
            EFTTransactionRequest."DCC Amount" := DecimalBuffer / 100;
          end;
        end;
    end;

    [TryFunction]
    local procedure TryParseOptionalData(var JObject: DotNet npNetJObject;OptionalData: Text)
    begin
        JObject := JObject.Parse(OptionalData);
    end;

    local procedure TrySelectToken(JObject: DotNet npNetJObject;Path: Text;var JToken: DotNet npNetJToken;WithError: Boolean): Boolean
    begin
        JToken := JObject.SelectToken(Path, WithError);
        exit(not IsNull(JToken));
    end;

    local procedure TrySelectValue(JObject: DotNet npNetJObject;Path: Text;var JValue: DotNet npNetJValue;WithError: Boolean): Boolean
    begin
        JValue := JObject.SelectToken(Path, WithError);
        exit(not IsNull(JValue));
    end;
}

