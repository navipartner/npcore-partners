codeunit 6184542 "NPR EFT NETS BAXI Resp. Pars."
{
#pragma warning disable AA0139
    Access = Internal;

    trigger OnRun()
    begin
        ParseResponse();
    end;

    var
        _ResponseType: Text;
        _Response: Codeunit "NPR POS JSON Helper";
        _EftTransactionEntryNo: Integer;
        _ERR_RESPONSE_TYPE: Label 'Critical error:\Unknown NETS BAXI response type: %1\Cannot establish response context';
        _CARD_BALANCE: Label 'Card Balance: %1';

    local procedure ParseResponse()
    begin
        case _ResponseType of
            'Open':
                ParseOpenResponse(_Response);
            'Close':
                ParseCloseResponse(_Response);
            'GetLastResult':
                ParseGetLastResponse(_Response);
            'Transaction':
                ParseTransactionResponse(_Response);
            'Administration':
                ParseAdministrationResponse(_Response);
            else
                Error(_ERR_RESPONSE_TYPE, _ResponseType);
        end;

    end;

    procedure SetResponse(ResponseTypeIn: Text; Response: Codeunit "NPR POS JSON Helper")
    begin
        _ResponseType := ResponseTypeIn;
        _Response := Response;
    end;

    procedure TryGetEftTransactionEntryNo(var EftEntryNoOut: Integer): Boolean
    begin
        if _EftTransactionEntryNo = 0 then
            exit(false);
        EftEntryNoOut := _EftTransactionEntryNo;
        exit(true);
    end;

    local procedure ParseOpenResponse(Response: Codeunit "NPR POS JSON Helper")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        _EftTransactionEntryNo := Response.GetInteger('EntryNo');
        EFTTransactionRequest.Get(_EftTransactionEntryNo);

        Response.SetScopePath('OpenResponse');
        EFTTransactionRequest.Successful := Response.GetBoolean('Success');
        if not EFTTransactionRequest.Successful then begin
            EFTTransactionRequest."Client Error" := CopyStr(Response.GetString('ErrorMessage'), 1, MaxStrLen(EFTTransactionRequest."Client Error"));
            EFTTransactionRequest."Result Description" := CopyStr(Response.GetString('ErrorMessage'), 1, MaxStrLen(EFTTransactionRequest."Result Description"));
        end;
        EFTTransactionRequest."Client Assembly Version" := Response.GetString('ExecutingAssemblyVersion');
        EFTTransactionRequest.Modify(true);
    end;

    local procedure ParseCloseResponse(Response: Codeunit "NPR POS JSON Helper")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        _EftTransactionEntryNo := Response.GetInteger('EntryNo');
        EFTTransactionRequest.Get(_EftTransactionEntryNo);

        if (Response.TrySetScope('AdministrationResponse')) then begin
            EFTTransactionRequest.Successful := Response.GetInteger('Result') = 1;
            if not EFTTransactionRequest.Successful then begin
                EFTTransactionRequest."Client Error" := CopyStr(Response.GetString('ErrorMessage'), 1, MaxStrLen(EFTTransactionRequest."Client Error"));
                EFTTransactionRequest."Result Description" := CopyStr(Response.GetString('ErrorMessage'), 1, MaxStrLen(EFTTransactionRequest."Result Description"));
            end;
            EFTTransactionRequest."Hardware ID" := Response.GetString('TerminalID');
            EFTTransactionRequest."Reconciliation ID" := Response.GetString('SessionNumber');
            ParseReceipts(EFTTransactionRequest, Response.GetString('Receipt1'), Response.GetString('Receipt2'));
            EFTTransactionRequest."Client Assembly Version" := Response.GetString('ExecutingAssemblyVersion');
        end else begin
            Response.SetScope('CloseResponse');
            EFTTransactionRequest.Successful := Response.GetBoolean('Success');
            if not EFTTransactionRequest.Successful then begin
                EFTTransactionRequest."Client Error" := CopyStr(Response.GetString('ErrorMessage'), 1, MaxStrLen(EFTTransactionRequest."Client Error"));
                EFTTransactionRequest."Result Description" := CopyStr(Response.GetString('ErrorMessage'), 1, MaxStrLen(EFTTransactionRequest."Result Description"));
            end;
            EFTTransactionRequest."Client Assembly Version" := Response.GetString('ExecutingAssemblyVersion');
        end;

        EFTTransactionRequest.Modify(true);
    end;

    local procedure ParseTransactionResponse(Response: Codeunit "NPR POS JSON Helper")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        TrxTimestamp: Text;
        DateTime: DateTime;
        Year: Integer;
        Month: Integer;
        Day: Integer;
        TrxTime: Time;
        VoidedEftTrxReq: Record "NPR EFT Transaction Request";
        OrganisationNumber: Text;
    begin
        _EftTransactionEntryNo := Response.GetInteger('EntryNo');
        EFTTransactionRequest.Get(_EftTransactionEntryNo);

        Response.SetScope('TransactionResponse');
        EFTTransactionRequest."Result Code" := Response.GetInteger('Result');

        if EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::AUXILIARY] then begin
            EFTTransactionRequest.Successful := (EFTTransactionRequest."Result Code" = 1);
        end else begin
            EFTTransactionRequest.Successful := (EFTTransactionRequest."Result Code" = 0) and (Response.GetBoolean('ReceivedExternalResponse'));
        end;

        EFTTransactionRequest."External Result Known" :=
          ((EFTTransactionRequest."Result Code" <> 99) and (Response.GetBoolean('ReceivedExternalResponse')))
          or (not Response.GetBoolean('ExternalRequestSent'));

        EFTTransactionRequest."Card Number" := Response.GetString('TruncatedPan');
        EFTTransactionRequest."Card Issuer ID" := Format(Response.GetInteger('IssuerId'));
        EFTTransactionRequest."Reconciliation ID" := Response.GetString('SessionNumber');
        EFTTransactionRequest."Hardware ID" := Response.GetString('TerminalID');

        case Response.GetInteger('VerificationMethod') of
            0:
                EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::PIN;
            1:
                EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::Signature;
            2:
                EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::None;
            3:
                EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::Loyalty;
            4:
                EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::ConsumerDevice;
        end;

        if (EFTTransactionRequest."Authentication Method" = EFTTransactionRequest."Authentication Method"::Signature) and
            (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::PAYMENT) then begin
            EFTTransactionRequest."Signature Type" := EFTTransactionRequest."Signature Type"::"On Receipt";
        end;

        TrxTimestamp := Response.GetString('Timestamp');
        //NETS documentation does not detail when exactly they send an ISO 8601 datetime string versus purely numbers, but both were observed during development..
        if StrPos(TrxTimestamp, 'Z') > 0 then begin
            Evaluate(DateTime, TrxTimestamp, 9);

            EFTTransactionRequest."Transaction Date" := DT2Date(DateTime);
            EFTTransactionRequest."Transaction Time" := DT2Time(DateTime);
        end else
            if TrxTimestamp <> '' then begin
                Evaluate(Year, CopyStr(TrxTimestamp, 1, 4));
                Evaluate(Month, CopyStr(TrxTimestamp, 5, 2));
                Evaluate(Day, CopyStr(TrxTimestamp, 7, 2));
                Evaluate(TrxTime, CopyStr(TrxTimestamp, 9, 6));

                EFTTransactionRequest."Transaction Date" := DMY2Date(Day, Month, Year);
                EFTTransactionRequest."Transaction Time" := TrxTime;
            end;

        EFTTransactionRequest."Authorisation Number" := Response.GetString('StanAuth');
        EFTTransactionRequest."Reference Number Output" := Response.GetString('StanAuth');
        EFTTransactionRequest."External Transaction ID" := Response.GetString('StanAuth');
        EFTTransactionRequest."Card Name" := Response.GetString('CardIssuerName');
        EFTTransactionRequest."Card Application ID" := Response.GetString('AID');

        if Response.GetString('ResponseCode') <> '' then begin
            EFTTransactionRequest."Result Description" := CopyStr('(' + Response.GetString('ResponseCode') + ')', 1, MaxStrLen(EFTTransactionRequest."Result Description"));
            EFTTransactionRequest."Result Display Text" := CopyStr('(' + Response.GetString('ResponseCode') + ')', 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));
        end;

        if EFTTransactionRequest.Successful then begin
            if Response.GetInteger('TipAmount') <> 0 then begin
                EFTTransactionRequest."Tip Amount" := Response.GetInteger('TipAmount') / 100;
            end;
            if Response.GetInteger('SurchargeAmount') <> 0 then begin
                EFTTransactionRequest."Fee Amount" := Response.GetInteger('SurchargeAmount') / 100;
            end;
            EFTTransactionRequest."Amount Output" := Response.GetInteger('TotalAmount') / 100;
        end;

        ParseReceipts(EFTTransactionRequest, Response.GetString('Receipt1'), Response.GetString('Receipt2'));

        ParseOptionalData(EFTTransactionRequest, Response.GetString('OptionalData'));

        case EFTTransactionRequest."Processing Type" of
            EFTTransactionRequest."Processing Type"::PAYMENT:
                EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output";
            EFTTransactionRequest."Processing Type"::GIFTCARD_LOAD,
          EFTTransactionRequest."Processing Type"::REFUND:
                EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output" * -1;
            EFTTransactionRequest."Processing Type"::VOID:
                begin
                    VoidedEftTrxReq.Get(EFTTransactionRequest."Processed Entry No.");
                    case VoidedEftTrxReq."Processing Type" of
                        VoidedEftTrxReq."Processing Type"::PAYMENT:
                            EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output" * -1;
                        VoidedEftTrxReq."Processing Type"::GIFTCARD_LOAD:
                            EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output";
                        VoidedEftTrxReq."Processing Type"::REFUND:
                            EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output";
                    end;
                end;
            EFTTransactionRequest."Processing Type"::AUXILIARY:
                case EFTTransactionRequest."Auxiliary Operation ID" of
                    1: //Balance Enquiry
                        begin
                            if EFTTransactionRequest.Successful then begin
                                EFTTransactionRequest."Result Display Text" := CopyStr(StrSubstNo(_CARD_BALANCE, EFTTransactionRequest."Amount Output"), 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));
                                //TODO:
                                //Undocumented by NETS where balance & expiry date is located in json respose.
                                //Test gift card is currently expired so cannot be check myself at this time.
                            end;
                        end;
                end;
        end;

        EFTTransactionRequest."Client Assembly Version" := Response.GetString('ExecutingAssemblyVersion');
        EFTTransactionRequest.Modify(true);

        if EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::PAYMENT then begin
            if Response.GetString('OrganisationNumber', OrganisationNumber) then;
            EmitTelemetry(EFTTransactionRequest, OrganisationNumber);
        end;
    end;

    local procedure ParseAdministrationResponse(Response: Codeunit "NPR POS JSON Helper")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        _EftTransactionEntryNo := Response.GetInteger('EntryNo');
        EFTTransactionRequest.Get(_EftTransactionEntryNo);

        Response.SetScope('AdministrationResponse');
        EFTTransactionRequest.Successful := Response.GetInteger('Result') = 1;
        if not EFTTransactionRequest.Successful then begin
            EFTTransactionRequest."Client Error" := CopyStr(Response.GetString('ErrorMessage'), 1, MaxStrLen(EFTTransactionRequest."Client Error"));
            EFTTransactionRequest."Result Description" := CopyStr(Response.GetString('ErrorMessage'), 1, MaxStrLen(EFTTransactionRequest."Result Description"));
        end;

        EFTTransactionRequest."Hardware ID" := Response.GetString('TerminalID');
        EFTTransactionRequest."Reconciliation ID" := Response.GetString('SessionNumber');
        EFTTransactionRequest."Client Assembly Version" := Response.GetString('ExecutingAssemblyVersion');

        ParseReceipts(EFTTransactionRequest, Response.GetString('Receipt1'), Response.GetString('Receipt2'));

        EFTTransactionRequest.Modify(true);
    end;

    local procedure ParseGetLastResponse(Response: Codeunit "NPR POS JSON Helper")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        TrxTimestamp: Text;
        DateTime: DateTime;
        Year: Integer;
        Month: Integer;
        Day: Integer;
        TrxTime: Time;
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        VoidedEftTrxReq: Record "NPR EFT Transaction Request";
    begin
        _EftTransactionEntryNo := Response.GetInteger('EntryNo');
        EFTTransactionRequest.Get(_EftTransactionEntryNo);

        Response.SetScope('GetLastResultResponse');
        EFTTransactionRequest.Successful := Response.GetInteger('GetLastResult') = 1; //Lookup successful, not the actual trx.
        EFTTransactionRequest."External Result Known" := (Response.GetInteger('GetLastResult') <> 99) and (Response.GetBoolean('ExternalResponseReceived'));

        if EFTTransactionRequest.Successful then begin
            EFTTransactionRequest."Card Number" := Response.GetString('TruncatedPan');
            EFTTransactionRequest."Reconciliation ID" := Response.GetString('SessionNumber');
            EFTTransactionRequest."Card Issuer ID" := Format(Response.GetInteger('IssuerId'));
            EFTTransactionRequest."Hardware ID" := Response.GetString('TerminalID');

            case Response.GetInteger('VerificationMethod') of
                0:
                    EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::PIN;
                1:
                    EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::Signature;
                2:
                    EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::None;
                3:
                    EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::Loyalty;
                4:
                    EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::ConsumerDevice;
            end;

            if (EFTTransactionRequest."Authentication Method" = EFTTransactionRequest."Authentication Method"::Signature) and
                (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::PAYMENT) then begin
                EFTTransactionRequest."Signature Type" := EFTTransactionRequest."Signature Type"::"On Receipt";
            end;

            TrxTimestamp := Response.GetString('Timestamp');
            //NETS documentation does not detail when exactly they send an ISO 8601 datetime string versus purely numbers, but both were observed during development..
            if StrPos(TrxTimestamp, 'Z') > 0 then begin
                Evaluate(DateTime, TrxTimestamp, 9);

                EFTTransactionRequest."Transaction Date" := DT2Date(DateTime);
                EFTTransactionRequest."Transaction Time" := DT2Time(DateTime);
            end else
                if TrxTimestamp <> '' then begin
                    Evaluate(Year, CopyStr(TrxTimestamp, 1, 4));
                    Evaluate(Month, CopyStr(TrxTimestamp, 5, 2));
                    Evaluate(Day, CopyStr(TrxTimestamp, 7, 2));
                    Evaluate(TrxTime, CopyStr(TrxTimestamp, 9, 6));

                    EFTTransactionRequest."Transaction Date" := DMY2Date(Day, Month, Year);
                    EFTTransactionRequest."Transaction Time" := TrxTime;
                end;

            EFTTransactionRequest."Authorisation Number" := Response.GetString('StanAuth');
            EFTTransactionRequest."Reference Number Output" := Response.GetString('StanAuth');
            EFTTransactionRequest."External Transaction ID" := Response.GetString('StanAuth');
            EFTTransactionRequest."Card Name" := Response.GetString('CardIssuerName');
            EFTTransactionRequest."Card Application ID" := Response.GetString('AID');

            if Response.GetInteger('Result') = 0 then begin
                if Response.GetInteger('TipAmount') <> 0 then begin
                    EFTTransactionRequest."Tip Amount" := Response.GetInteger('TipAmount') / 100;
                end;
                if Response.GetInteger('SurchargeAmount') <> 0 then begin
                    EFTTransactionRequest."Fee Amount" := Response.GetInteger('SurchargeAmount') / 100;
                end;
                EFTTransactionRequest."Amount Output" := Response.GetInteger('TotalAmount') / 100;
            end else begin
                if Response.GetString('ResponseCode') <> '' then begin
                    EFTTransactionRequest."Result Description" := CopyStr('(' + Response.GetString('ResponseCode') + ')', 1, MaxStrLen(EFTTransactionRequest."Result Description"));
                    EFTTransactionRequest."Result Display Text" := CopyStr('(' + Response.GetString('ResponseCode') + ')', 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));
                end;
            end;

            ParseReceipts(EFTTransactionRequest, Response.GetString('Receipt1'), Response.GetString('Receipt2'));

            ParseOptionalData(EFTTransactionRequest, Response.GetString('OptionalData'));

            OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
            case OriginalEFTTransactionRequest."Processing Type" of
                OriginalEFTTransactionRequest."Processing Type"::PAYMENT:
                    EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output";
                OriginalEFTTransactionRequest."Processing Type"::GIFTCARD_LOAD,
              OriginalEFTTransactionRequest."Processing Type"::REFUND:
                    EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output" * -1;
                OriginalEFTTransactionRequest."Processing Type"::VOID:
                    begin
                        VoidedEftTrxReq.Get(OriginalEFTTransactionRequest."Processed Entry No.");
                        case VoidedEftTrxReq."Processing Type" of
                            VoidedEftTrxReq."Processing Type"::PAYMENT:
                                EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output" * -1;
                            VoidedEftTrxReq."Processing Type"::GIFTCARD_LOAD:
                                EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output";
                            VoidedEftTrxReq."Processing Type"::REFUND:
                                EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output";
                        end;
                    end;
            end;
        end;

        EFTTransactionRequest."Client Assembly Version" := Response.GetString('ExecutingAssemblyVersion');
        EFTTransactionRequest.Modify(true);
    end;

    local procedure ParseReceipts(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; Receipt1: Text; Receipt2: Text)
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

    local procedure ParseReceipt(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; Receipt: Text; var LastReceiptNo: Integer; var LastReceiptEntryNo: Integer; OStream: OutStream)
    var
        TempBlob: Codeunit "Temp Blob";
        OStream2: OutStream;
        IStream: InStream;
        DotNetEncoding: Codeunit DotNet_Encoding;
        DotNetStreamReader: Codeunit DotNet_StreamReader;
        ReceiptLine: Text;
    begin
        OStream.Write(Receipt);

        TempBlob.CreateOutStream(OStream2, TextEncoding::UTF8);
        OStream2.Write(Receipt);
        TempBlob.CreateInStream(IStream, TextEncoding::UTF8);

        DotNetEncoding.UTF8();
        DotNetStreamReader.StreamReader(IStream, DotNetEncoding);

        if not DotNetStreamReader.EndOfStream() then
            LastReceiptNo += 1;

        while (not DotNetStreamReader.EndOfStream()) do begin
            LastReceiptEntryNo += 1;
            ReceiptLine := DotNetStreamReader.ReadLine();
            InsertReceiptLine(ReceiptLine, LastReceiptNo, LastReceiptEntryNo, EFTTransactionRequest);
        end;
    end;

    local procedure GetLastReceiptLineEntryNo(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Integer
    var
        CreditCardTransaction: Record "NPR EFT Receipt";
    begin
        CreditCardTransaction.SetRange("Register No.", EFTTransactionRequest."Register No.");
        CreditCardTransaction.SetRange("Sales Ticket No.", EFTTransactionRequest."Sales Ticket No.");
        if (CreditCardTransaction.FindLast()) then;
        exit(CreditCardTransaction."Entry No.");
    end;

    local procedure GetLastReceiptNo(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Integer
    var
        CreditCardTransaction: Record "NPR EFT Receipt";
    begin
        CreditCardTransaction.SetRange("Register No.", EFTTransactionRequest."Register No.");
        CreditCardTransaction.SetRange("Sales Ticket No.", EFTTransactionRequest."Sales Ticket No.");
        if (CreditCardTransaction.FindLast()) then;
        exit(CreditCardTransaction."Receipt No.");
    end;

    local procedure InsertReceiptLine(Line: Text; ReceiptNo: Integer; EntryNo: Integer; EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        CreditCardTransaction: Record "NPR EFT Receipt";
    begin
        CreditCardTransaction.Init();
        CreditCardTransaction.Date := Today();
        CreditCardTransaction."Transaction Time" := Time;
        CreditCardTransaction."Register No." := EFTTransactionRequest."Register No.";
        CreditCardTransaction."Sales Ticket No." := EFTTransactionRequest."Sales Ticket No.";
        CreditCardTransaction."EFT Trans. Request Entry No." := EFTTransactionRequest."Entry No.";
        CreditCardTransaction."Receipt No." := ReceiptNo;
        CreditCardTransaction.Text := CopyStr(Line, 1, MaxStrLen(CreditCardTransaction.Text));
        CreditCardTransaction."Entry No." := EntryNo;
        CreditCardTransaction.Insert();
    end;

    local procedure ParseOptionalData(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; OptionalData: Text)
    var
        JObject: JsonObject;
        JToken: JsonToken;
        JToken2: JsonToken;
    begin
        if not JObject.ReadFrom(OptionalData) then
            exit;

        if not JObject.SelectToken('od.dcc', JToken) then
            exit;

        EFTTransactionRequest."DCC Used" := true;
        JToken.AsObject().Get('ccura', JToken2);
        EFTTransactionRequest."DCC Currency Code" := JToken2.AsValue().AsText();

        if not JToken.AsObject().Get('cam', JToken2) then
            exit;

        EFTTransactionRequest."DCC Amount" := JToken2.AsValue().AsInteger() / 100;
    end;

    local procedure EmitTelemetry(EFTTransactionRequest: Record "NPR EFT Transaction Request"; OrganizationNumber: Text)
    var
        EFTTransactionRequest2: Record "NPR EFT Transaction Request";
        LogDict: Dictionary of [Text, Text];
    begin
        //if first successful transaction of the day, call home to telemetry with terminal details for baxi terminal tracking
        if not EftTransactionRequest.Successful then
            exit;

        EFTTransactionRequest2.SetCurrentKey("Register No.", "Integration Type", "Processing Type");
        EFTTransactionRequest2.SetRange("Register No.", EftTransactionRequest."Register No.");
        EFTTransactionRequest2.SetRange("Integration Type", EftTransactionRequest."Integration Type");
        EFTTransactionRequest2.SetRange("Processing Type", EftTransactionRequest."Processing Type");
        EFTTransactionRequest2.SetFilter("Entry No.", '<%1', EftTransactionRequest."Entry No.");
        EFTTransactionRequest2.SetRange(Successful, true);

        if EFTTransactionRequest2.FindLast() then begin
            if EftTransactionRequest."Transaction Date" = EFTTransactionRequest2."Transaction Date" then
                exit;
        end;

        LogDict.Add('Hardware ID', EftTransactionRequest."Hardware ID");
        LogDict.Add('POS Unit', EftTransactionRequest."Register No.");
        LogDict.Add('OrganizationNumber', OrganizationNumber);
        Session.LogMessage('NPR_BAXI_NATIVE_METADATA', '', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, LogDict);
    end;
#pragma warning restore AA0139
}