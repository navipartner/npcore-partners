codeunit 6184538 "NPR EFT NETSCloud Resp. Parser"
{
#pragma warning disable AA0139
    Access = Internal;

    trigger OnRun()
    begin
        RunParser();
    end;

    var
        _EftTransactionEntryNo: Integer;
        _ResponseType: Text;
        _Data: Text;
        _OrganizationNumber: Text;
        _SiteId: Text;

    local procedure RunParser()
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        ErrorResponseTypeLbl: Label 'Unknown response type %1';
    begin
        EFTTransactionRequest.Get(_EftTransactionEntryNo);

        case _ResponseType of
            'Payment':
                ParseTransaction(_Data, EFTTransactionRequest);
            'Refund':
                ParseTransaction(_Data, EFTTransactionRequest);
            'VoidLast':
                ParseTransaction(_Data, EFTTransactionRequest);
            'LookupLast':
                ParseTransaction(_Data, EFTTransactionRequest);
            'BalanceEnquiry':
                ParseBalanceEnquiry(_Data, EFTTransactionRequest);
            'TerminalSoftware':
                ParseTerminalSoftware(_Data, EFTTransactionRequest);
            'TerminalDataset':
                ParseTerminalDataset(_Data, EFTTransactionRequest);
            'Reconciliation':
                ParseReconciliation(_Data, EFTTransactionRequest);
            'Cancel':
                ParseCancel(EFTTransactionRequest);
            'GiftCardLoad':
                ParseTransaction(_Data, EFTTransactionRequest);
            else
                Error(ErrorResponseTypeLbl, _ResponseType);
        end;

        EFTTransactionRequest.Modify();

        if _ResponseType = 'Payment' then begin
            EmitTelemetry(EFTTransactionRequest);
        end;


    end;

    procedure SetResponseData(ResponseTypeIn: Text; DataIn: Text; EntryNo: Integer)
    begin
        _ResponseType := ResponseTypeIn;
        _Data := DataIn;
        _EftTransactionEntryNo := EntryNo;
    end;

    local procedure ParseTransaction(Response: Text; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JObject: JsonObject;
        JToken: JsonToken;
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        InvalidJsonLbl: Label 'Invalid JSON, expected "%1"';
    begin
        JObject.ReadFrom(Response);

        case true of
            TrySelectToken(JObject, 'result', JToken, false):
                begin
                    ParseTransactionResult(JToken, EFTTransactionRequest);
                    if EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::LOOK_UP then begin
                        EFTTransactionRequest.Successful := true; //The lookup itself was successful.
                    end;
                end;
            TrySelectToken(JObject, 'failure', JToken, false):
                begin
                    ParseTransactionFailure(JToken.AsObject(), EFTTransactionRequest);
                end;
            else
                Error(InvalidJsonLbl, 'result');
        end;

        if EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::LOOK_UP then begin
            OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
        end else begin
            OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");
        end;

        case OriginalEFTTransactionRequest."Processing Type" of
            OriginalEFTTransactionRequest."Processing Type"::PAYMENT:
                EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output";
            OriginalEFTTransactionRequest."Processing Type"::REFUND:
                EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output" * -1;
            OriginalEFTTransactionRequest."Processing Type"::VOID:
                begin
                    OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Processed Entry No.");
                    case OriginalEFTTransactionRequest."Processing Type" of
                        OriginalEFTTransactionRequest."Processing Type"::PAYMENT:
                            EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output" * -1;
                        OriginalEFTTransactionRequest."Processing Type"::REFUND:
                            EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output";
                    end;
                end;
        end;
    end;

    local procedure ParseTransactionResult(TransactionResult: JsonToken; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JToken: JsonToken;
        ResultObject: JsonObject;
    begin
        if (TransactionResult.IsObject) then begin
            if TrySelectToken(TransactionResult.AsObject(), 'latestTransactionResult', JToken, false) then begin
                //Is a GetLastTransaction result rather than a normal result
                ParseTransactionLookup(TransactionResult.AsObject(), EFTTransactionRequest);
                exit;
            end;
        end;

        TransactionResult.AsArray().Get(0, JToken); //Result is an array with 1 element inside for some reason.
        ResultObject := JToken.AsObject();

        TrySelectToken(ResultObject, 'localModeEventArgs', JToken, true);
        ParseLocalModeArgs(JToken.AsObject(), EFTTransactionRequest);
        ParseTransactionReceipts(ResultObject, EFTTransactionRequest);
    end;

    local procedure ParseTransactionFailure(JObject: JsonObject; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JToken: JsonToken;
    begin
        if JObject.Values.Count = 0 then begin
            //Error can be directly in a string. Undocumented by NETS but observed during development.
            EFTTransactionRequest."Result Description" := CopyStr(JObject.AsToken().AsValue().AsText(), 1, MaxStrLen(EFTTransactionRequest."Result Description"));
            EFTTransactionRequest."Result Display Text" := CopyStr(JObject.AsToken().AsValue().AsText(), 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));
            EFTTransactionRequest."External Result Known" := true;
            exit;
        end;

        if TrySelectToken(JObject, 'error', JToken, false) then begin
            EFTTransactionRequest."Result Description" := CopyStr((EFTTransactionRequest."Result Description" + JToken.AsValue().AsText() + ' '), 1, MaxStrLen(EFTTransactionRequest."Result Description"));
            EFTTransactionRequest."Result Display Text" := CopyStr((EFTTransactionRequest."Result Display Text" + JToken.AsValue().AsText() + ' '), 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));
        end;

        if TrySelectToken(JObject, 'localModeEventArgs', JToken, false) then begin
            ParseLocalModeArgs(JToken.AsObject(), EFTTransactionRequest);
        end;

        ParseTransactionReceipts(JObject, EFTTransactionRequest);
    end;

    local procedure ParseTransactionLookup(JObject: JsonObject; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JToken: JsonToken;
        ReceiptNo: Integer;
        EntryNo: Integer;
        OutStream: OutStream;
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        TrySelectToken(JObject, 'latestTransactionResult', JToken, true);
        ParseLocalModeArgs(JToken.AsObject(), EFTTransactionRequest);

        if TrySelectToken(JObject, 'printText', JToken, false) then begin
            ReceiptNo := GetLastReceiptNo(EFTTransactionRequest);
            EntryNo := GetLastReceiptLineEntryNo(EFTTransactionRequest);
            EFTTransactionRequest."Receipt 2".CreateOutStream(OutStream);
            ParseReceipt(JToken.AsObject(), EFTTransactionRequest, 'Text', ReceiptNo, EntryNo, OutStream);
        end;

        if EFTTransactionRequest.Successful and (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::LOOK_UP) then begin
            //Implicit same currency code as original.
            OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
            EFTTransactionRequest."Currency Code" := OriginalEFTTransactionRequest."Currency Code";
        end;
    end;

    local procedure ParseLocalModeArgs(JObject: JsonObject; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JToken: JsonToken;
        JValue: JsonValue;
        CVM: Integer;
        Timestamp: DateTime;
    begin
        TrySelectToken(JObject, 'Result', JToken, true);
        Evaluate(EFTTransactionRequest."Result Code", JToken.AsValue().AsText());

        if EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::CLOSE, EFTTransactionRequest."Processing Type"::AUXILIARY] then begin
            EFTTransactionRequest.Successful := (EFTTransactionRequest."Result Code" = 1);
        end else begin
            EFTTransactionRequest.Successful := (EFTTransactionRequest."Result Code" = 0);
        end;

        EFTTransactionRequest."External Result Known" := (EFTTransactionRequest."Result Code" <> 99);

        if TrySelectToken(JObject, 'TruncatedPAN', JToken, false) then begin
            EFTTransactionRequest."Card Number" := JToken.AsValue().AsText();
        end;

        if TrySelectToken(JObject, 'SessionNumber', JToken, false) then begin
            EFTTransactionRequest."Reconciliation ID" := JToken.AsValue().AsText();
        end;

        if TrySelectToken(JObject, 'IssuerID', JToken, false) then begin
            EFTTransactionRequest."Card Issuer ID" := JToken.AsValue().AsText();
        end;

        if TrySelectToken(JObject, 'TerminalID', JToken, false) then begin
            EFTTransactionRequest."Hardware ID" := JToken.AsValue().AsText();
        end;

        if TrySelectToken(JObject, 'CVM', JToken, false) then begin
            if Evaluate(CVM, JToken.AsValue().AsText()) then begin //CVM was suddenly observed as an empty string rather than an integer after NETS backend upgrade.
                case CVM of
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
            end;

            if (EFTTransactionRequest."Authentication Method" = EFTTransactionRequest."Authentication Method"::Signature) and
               (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::PAYMENT) then begin
                EFTTransactionRequest."Signature Type" := EFTTransactionRequest."Signature Type"::"On Receipt";
            end;
        end;

        if TrySelectToken(JObject, 'TimeStamp', JToken, false) then begin
            Timestamp := ParseTimestamp(JToken);
            EFTTransactionRequest."Transaction Date" := DT2Date(Timestamp);
            EFTTransactionRequest."Transaction Time" := DT2Time(Timestamp);
        end;

        if TrySelectToken(JObject, 'StanAuth', JToken, false) then begin
            EFTTransactionRequest."Authorisation Number" := JToken.AsValue().AsText();
            EFTTransactionRequest."Reference Number Output" := JToken.AsValue().AsText();
            EFTTransactionRequest."External Transaction ID" := JToken.AsValue().AsText();
        end;

        if TrySelectToken(JObject, 'CardIssuerName', JToken, false) then begin
            EFTTransactionRequest."Card Name" := JToken.AsValue().AsText();
        end;

        if TrySelectToken(JObject, 'AID', JToken, false) then begin
            EFTTransactionRequest."Card Application ID" := JToken.AsValue().AsText();
        end;
        if TrySelectToken(JObject, 'OptionalData', JToken, false) then begin
            ParseOptionalData(EFTTransactionRequest, JValTextOrDefault(JToken.AsValue(), ''));
        end;

        if TrySelectToken(JObject, 'ResponseCode', JToken, false) then begin
            if JToken.AsValue().AsText() <> '' then begin
                EFTTransactionRequest."Result Description" := CopyStr(EFTTransactionRequest."Result Description" + '(' + JToken.AsValue().AsText() + ')', 1, MaxStrLen(EFTTransactionRequest."Result Description"));
                EFTTransactionRequest."Result Display Text" := CopyStr(EFTTransactionRequest."Result Display Text" + '(' + JToken.AsValue().AsText() + ')', 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));
            end;
        end;

        if EFTTransactionRequest.Successful then begin
            if TrySelectValue(JObject, 'TipAmount', JValue, false) then begin
                if JValue.AsInteger() <> 0 then
                    EFTTransactionRequest."Tip Amount" := JValue.AsInteger() / 100;
            end;

            if TrySelectValue(JObject, 'SurchargeAmount', JValue, false) then begin
                if JValue.AsInteger() <> 0 then
                    EFTTransactionRequest."Fee Amount" := JValue.AsInteger() / 100;
            end;

            if TrySelectValue(JObject, 'TotalAmount', JValue, false) then begin
                EFTTransactionRequest."Amount Output" := JValue.AsInteger() / 100;
            end;
        end;

        if TrySelectToken(JObject, 'SiteID', JToken, false) then begin
            _SiteId := JToken.AsValue().AsText();
        end;

        if TrySelectToken(JObject, 'OrganisationNumber', JToken, false) then begin
            _OrganizationNumber := JToken.AsValue().AsText();
        end;

    end;

    local procedure ParseTimestamp(JToken: JsonToken): DateTime
    var
        Year: Integer;
        Month: Integer;
        Day: Integer;
        DateTime: DateTime;
        TrxTime: Time;
        TrxTimestamp: Text;
    begin
        TrxTimestamp := JToken.AsValue().AsText();
        //NETS documentation does not detail when exactly they send an ISO 8601 datetime string versus purely numbers, but both were observed during development..
        if StrPos(TrxTimestamp, 'Z') > 0 then begin
            Evaluate(DateTime, TrxTimestamp, 9);
            exit(DateTime);
        end else
            if TrxTimestamp <> '' then begin
                Evaluate(Year, CopyStr(TrxTimestamp, 1, 4));
                Evaluate(Month, CopyStr(TrxTimestamp, 5, 2));
                Evaluate(Day, CopyStr(TrxTimestamp, 7, 2));
                Evaluate(TrxTime, CopyStr(TrxTimestamp, 9, 6));

                exit(CreateDateTime(DMY2Date(Day, Month, Year), TrxTime));
            end;
    end;

    local procedure ParseReconciliation(Response: Text; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JObject: JsonObject;
        JToken: JsonToken;
        TrxTimestamp: DateTime;
        OutStream: OutStream;
        ReceiptNo: Integer;
        EntryNo: Integer;
        JValue: JsonValue;
    begin
        JObject.ReadFrom(Response);

        TrySelectToken(JObject, 'result.reconciliation', JToken, true);
        JObject := JToken.AsObject();

        TrySelectValue(JObject, 'header.timestamp', JValue, true);
        TrxTimestamp := JValue.AsDateTime();
        EFTTransactionRequest."Transaction Date" := DT2Date(TrxTimestamp);
        EFTTransactionRequest."Transaction Time" := DT2Time(TrxTimestamp);

        TrySelectToken(JObject, 'header.sessionNumber', JToken, true);
        EFTTransactionRequest."Reconciliation ID" := JToken.AsValue().AsText();

        ReceiptNo := GetLastReceiptNo(EFTTransactionRequest);
        EntryNo := GetLastReceiptLineEntryNo(EFTTransactionRequest);
        EFTTransactionRequest."Receipt 1".CreateOutStream(OutStream);
        ParseReceipt(JObject, EFTTransactionRequest, 'printText.Text', ReceiptNo, EntryNo, OutStream);

        EFTTransactionRequest.Successful := true;
        EFTTransactionRequest."External Result Known" := true;
    end;

    local procedure ParseTransactionReceipts(JObject: JsonObject; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        ReceiptNo: Integer;
        EntryNo: Integer;
        OutStream: OutStream;
    begin
        ReceiptNo := GetLastReceiptNo(EFTTransactionRequest);
        EntryNo := GetLastReceiptLineEntryNo(EFTTransactionRequest);

        EFTTransactionRequest."Receipt 1".CreateOutStream(OutStream);
        ParseReceipt(JObject, EFTTransactionRequest, 'customerReceipt', ReceiptNo, EntryNo, OutStream);
        Clear(OutStream);

        EFTTransactionRequest."Receipt 2".CreateOutStream(OutStream);
        ParseReceipt(JObject, EFTTransactionRequest, 'merchantReceipt', ReceiptNo, EntryNo, OutStream);
        Clear(OutStream);
    end;

    local procedure ParseCancel(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        EFTTransactionRequest.Successful := true;
        EFTTransactionRequest."External Result Known" := true;
    end;

    local procedure ParseTerminalDataset(Response: Text; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JObject: JsonObject;
        JToken: JsonToken;
        ReceiptNo: Integer;
        EntryNo: Integer;
        OutStream: OutStream;
    begin
        JObject.ReadFrom(Response);
        TrySelectToken(JObject, 'result.localModeEventArgs', JToken, true);
        ParseLocalModeArgs(JToken.AsObject(), EFTTransactionRequest);

        if TrySelectToken(JObject, 'printText', JToken, false) then begin
            ReceiptNo := GetLastReceiptNo(EFTTransactionRequest);
            EntryNo := GetLastReceiptLineEntryNo(EFTTransactionRequest);
            EFTTransactionRequest."Receipt 2".CreateOutStream(OutStream);
            ParseReceipt(JToken.AsObject(), EFTTransactionRequest, 'Text', ReceiptNo, EntryNo, OutStream);
        end;
    end;

    local procedure ParseTerminalSoftware(Response: Text; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JObject: JsonObject;
        JToken: JsonToken;
        ReceiptNo: Integer;
        EntryNo: Integer;
        OutStream: OutStream;
    begin
        JObject.ReadFrom(Response);
        TrySelectToken(JObject, 'result.localModeEventArgs', JToken, true);
        ParseLocalModeArgs(JToken.AsObject(), EFTTransactionRequest);

        if TrySelectToken(JObject, 'printText', JToken, false) then begin
            ReceiptNo := GetLastReceiptNo(EFTTransactionRequest);
            EntryNo := GetLastReceiptLineEntryNo(EFTTransactionRequest);
            EFTTransactionRequest."Receipt 2".CreateOutStream(OutStream);
            ParseReceipt(JToken.AsObject(), EFTTransactionRequest, 'Text', ReceiptNo, EntryNo, OutStream);
        end;
    end;

    local procedure ParseBalanceEnquiry(Response: Text; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JObject: JsonObject;
        JToken: JsonToken;
        ReceiptNo: Integer;
        EntryNo: Integer;
        OutStream: OutStream;
        CardBalanceLbl: Label 'Card Balance: %1';
    begin
        JObject.ReadFrom(Response);
        TrySelectToken(JObject, 'result.localModeEventArgs', JToken, true);
        ParseLocalModeArgs(JToken.AsObject(), EFTTransactionRequest);

        if TrySelectToken(JObject, 'printText', JToken, false) then begin
            ReceiptNo := GetLastReceiptNo(EFTTransactionRequest);
            EntryNo := GetLastReceiptLineEntryNo(EFTTransactionRequest);
            EFTTransactionRequest."Receipt 2".CreateOutStream(OutStream);
            ParseReceipt(JToken.AsObject(), EFTTransactionRequest, 'Text', ReceiptNo, EntryNo, OutStream);
        end;

        if EFTTransactionRequest.Successful then begin
            EFTTransactionRequest."Result Display Text" := CopyStr(StrSubstNo(CardBalanceLbl, EFTTransactionRequest."Amount Output"), 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));
        end;
        //TODO:
        //Undocumented by NETS where balance & expiry date is located in json respose.
        //Test gift card is currently expired so cannot be check myself at this time.
    end;

    local procedure JValTextOrDefault(JVal: JsonValue; Default: Text): Text
    var
        Txt: Text;
    begin
        if (JVal.IsNull() or JVal.IsUndefined() or not TryJValText(JVal, Txt)) then
            exit(Default)
        else
            exit(Txt);
    end;

    [TryFunction]
    local procedure TryJValText(JVal: JsonValue; var Txt: Text)
    begin
        Txt := JVal.AsText();
    end;

    local procedure TrySelectToken(JObject: JsonObject; Path: Text; var JToken: JsonToken; WithError: Boolean): Boolean
    begin
        if WithError then begin
            JObject.SelectToken(Path, JToken);
        end else begin
            if not JObject.SelectToken(Path, JToken) then
                exit(false);
        end;
        exit(true);
    end;

    local procedure TrySelectValue(JObject: JsonObject; Path: Text; var JValue: JsonValue; WithError: Boolean): Boolean
    var
        JToken: JsonToken;
    begin
        if WithError then begin
            JObject.SelectToken(Path, JToken);
            JValue := JToken.AsValue();
        end else begin
            if not JObject.SelectToken(Path, JToken) then
                exit(false);
            if not JToken.IsValue then
                exit(false);
            JValue := JToken.AsValue();
        end;
        exit(true);
    end;

    local procedure ParseReceipt(JObject: JsonObject; var EFTTransactionRequest: Record "NPR EFT Transaction Request"; ReceiptElement: Text; LastReceiptNo: Integer; var LastReceiptEntryNo: Integer; OStream: OutStream)
    var
        JToken: JsonToken;
        Receipt: Text;
        DotNetStreamReader: Codeunit DotNet_StreamReader;
        IStream: InStream;
        DotNetEncoding: Codeunit DotNet_Encoding;
        ReceiptLine: Text;
        TempBlob: Codeunit "Temp Blob";
        OStream2: OutStream;
    begin
        if TrySelectToken(JObject, ReceiptElement, JToken, false) then begin
            Receipt := JToken.AsValue().AsText();
            TempBlob.CreateOutStream(OStream2, TextEncoding::UTF8);
            OStream.Write(Receipt);
            OStream2.Write(Receipt);
            TempBlob.CreateInStream(IStream, TextEncoding::UTF8);

            DotNetEncoding.UTF8();
            DotNetStreamReader.StreamReader(IStream, DotNetEncoding);
            while (not DotNetStreamReader.EndOfStream()) do begin
                LastReceiptEntryNo += 1;
                ReceiptLine := DotNetStreamReader.ReadLine();
                InsertReceiptLine(ReceiptLine, LastReceiptNo, LastReceiptEntryNo, EFTTransactionRequest);
            end;
        end;
    end;

    [TryFunction]
    procedure IsLookupResponseRelatedToTransaction(Response: Text; EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JObject: JsonObject;
        JToken: JsonToken;
        InvalidLookupStanLbl: Label 'Invalid transaction lookup response. %1 %2 matches an earlier transaction.';
        InvalidLookupTimeLbl: Label 'Invalid transaction lookup response. %1 %2 is too far from expected value %3';
        InvalidLookupOrderIdLbl: Label 'Invalid transaction lookup response. %1 %2 does not match expected value %3';
        Timestamp: DateTime;
    begin
        // Gap in NETS API has been reported to them. Since we cannot send them our ID in request that they mirror in their response, there is no simple robust check here.
        // We have invented our own safeguard: If transaction timestamp (from NETS. And not UTC formatted but best we have..) varies more than 10 minutes from our timestamp (logged before we invoked them) OR StanAuth field already matches an
        // earlier transaction in NAV, then we ignore the Lookup result as a duplicate/invalid response.

        JObject.ReadFrom(Response);
        TrySelectToken(JObject, 'result', JToken, true);
        JObject := JToken.AsObject();
        TrySelectToken(JObject, 'latestTransactionResult.StanAuth', JToken, true);

        if IsAuthorizationIdKnown(EFTTransactionRequest, JToken.AsValue().AsText()) then begin
            Error(InvalidLookupStanLbl, EFTTransactionRequest.FieldCaption("Authorisation Number"), EFTTransactionRequest."Authorisation Number");
        end;

        TrySelectToken(JObject, 'latestTransactionResult.TimeStamp', JToken, true);
        Timestamp := ParseTimestamp(JToken);
        if (Timestamp < (EFTTransactionRequest.Started - (1000 * 60 * 10))) or (Timestamp > (EFTTransactionRequest.Started + (1000 * 60 * 10))) then begin
            Error(InvalidLookupTimeLbl, EFTTransactionRequest.FieldCaption("Transaction Time"), Timestamp, EFTTransactionRequest.Started);
        end;

        // Update: NETS has added a better-than-nothing request ID: "orderId". We populate it in requests, they mirror it back to us in responses.
        // The problem is that they only mirror it back to us for successful transactions, meaning we still need our hacks above to check
        // if a lookup result indicating a failed transaction seems to be matching the trx we are looking up. But at least successful lookups are now 100% safe:
        if TrySelectToken(JObject, 'orderId', JToken, false) then begin
            if JToken.AsValue().AsText() <> Format(EFTTransactionRequest."Entry No.") then begin
                Error(InvalidLookupOrderIdLbl, 'orderID', JToken.AsValue().AsText(), EFTTransactionRequest."Entry No.");
            end;
        end;
    end;

    local procedure IsAuthorizationIdKnown(EftTransactionRequestIn: Record "NPR EFT Transaction Request"; STAN: Text): Boolean
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EftTransactionRequestIn.TestField("Hardware ID");

        if STAN = '' then
            exit(false); //early cancellations have no stan. This is safe, since we know they also carry no financial impact, so we can never accidentally recover money by allowing them.

        EFTTransactionRequest.SetFilter("Entry No.", '<>%1', EftTransactionRequestIn."Entry No.");
        EFTTransactionRequest.SetRange("Hardware ID", EftTransactionRequestIn."Hardware ID");
        EFTTransactionRequest.SetRange("Reference Number Output", STAN);

        exit(not EFTTransactionRequest.IsEmpty());
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
        JValue: JsonValue;
        JToken2: JsonToken;
    begin
        if not TryParseOptionalData(JObject, OptionalData) then
            exit;

        if TrySelectToken(JObject, 'od.dcc', JToken, false) then begin
            EFTTransactionRequest."DCC Used" := true;
            JToken.SelectToken('ccura', JToken2);
            EFTTransactionRequest."DCC Currency Code" := JToken2.AsValue().AsText();

            if TrySelectValue(JToken.AsObject(), 'cam', JValue, false) then begin
                EFTTransactionRequest."DCC Amount" := JValue.AsDecimal() / 100;
            end;
        end;
    end;

    local procedure EmitTelemetry(EFTTransactionRequest: Record "NPR EFT Transaction Request")
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
        LogDict.Add('OrganizationNumber', _OrganizationNumber);
        LogDict.Add('SiteId', _SiteId);
        Session.LogMessage('NPR_BAXI_CLOUD_METADATA', '', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, LogDict);
    end;

    [TryFunction]
    local procedure TryParseOptionalData(var JObject: JsonObject; OptionalData: Text)
    begin
        JObject.ReadFrom(OptionalData);
    end;
#pragma warning restore AA0139
}