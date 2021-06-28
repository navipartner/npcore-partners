codeunit 6184538 "NPR EFT NETSCloud Resp. Parser"
{
    // NPR5.54/JAKUBV/20200408  CASE 364340 Transport NPR5.54 - 8 April 2020
    // NPR5.55/MMV /20200525 CASE 405984 Fixed undocumented breaking change in NETS backend update.


    trigger OnRun()
    begin
        RunParser();
    end;

    var
        INVALID_JSON: Label 'Invalid JSON, expected "%1"';
        EftTransactionEntryNo: Integer;
        ResponseType: Text;
        Data: Text;
        ERROR_RESPONSE_TYPE: Label 'Unknown response type %1';
        INVALID_LOOKUP_STAN: Label 'Invalid transaction lookup response. %1 %2 matches an earlier transaction.';
        IVNALID_LOOKUP_TIME: Label 'Invalid transaction lookup response. %1 %2 is too far from expected value %3';
        CARD_BALANCE: Label 'Card Balance: %1';

    local procedure RunParser()
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.Get(EftTransactionEntryNo);

        case ResponseType of
            'Payment':
                ParseTransaction(Data, EFTTransactionRequest);
            'Refund':
                ParseTransaction(Data, EFTTransactionRequest);
            'VoidLast':
                ParseTransaction(Data, EFTTransactionRequest);
            'LookupLast':
                ParseTransaction(Data, EFTTransactionRequest);
            'BalanceEnquiry':
                ParseBalanceEnquiry(Data, EFTTransactionRequest);
            'TerminalSoftware':
                ParseTerminalSoftware(Data, EFTTransactionRequest);
            'TerminalDataset':
                ParseTerminalDataset(Data, EFTTransactionRequest);
            'Reconciliation':
                ParseReconciliation(Data, EFTTransactionRequest);
            'Cancel':
                ParseCancel(EFTTransactionRequest);
            else
                Error(ERROR_RESPONSE_TYPE, ResponseType);
        end;

        EFTTransactionRequest.Modify();
    end;

    procedure SetResponseData(ResponseTypeIn: Text; DataIn: Text; EntryNo: Integer)
    begin
        ResponseType := ResponseTypeIn;
        Data := DataIn;
        EftTransactionEntryNo := EntryNo;
    end;

    local procedure ParseTransaction(Response: Text; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JObject: DotNet NPRNetJObject;
        JToken: DotNet NPRNetJObject;
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        ParseJSON(Response, JObject);
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
                    ParseTransactionFailure(JToken, EFTTransactionRequest);
                end;
            else
                Error(INVALID_JSON, 'result');
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

    local procedure ParseTransactionResult(JObject: DotNet NPRNetJObject; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JToken: DotNet NPRNetJToken;
    begin
        if TrySelectToken(JObject, 'latestTransactionResult', JToken, false) then begin
            //Is a GetLastTransaction result rather than a normal result
            ParseTransactionLookup(JObject, EFTTransactionRequest);
            exit;
        end;

        JObject := JObject.Item(0); //Result is an array with 1 element inside for some reason.

        TrySelectToken(JObject, 'localModeEventArgs', JToken, true);
        ParseLocalModeArgs(JToken, EFTTransactionRequest);

        ParseTransactionReceipts(JObject, EFTTransactionRequest);
    end;

    local procedure ParseTransactionFailure(JObject: DotNet NPRNetJObject; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JToken: DotNet NPRNetJToken;
    begin
        if not JObject.HasValues() then begin
            //Error can be directly in a string. Undocumented by NETS but observed during development.
            EFTTransactionRequest."Result Description" := CopyStr(JObject.ToString(), 1, MaxStrLen(EFTTransactionRequest."Result Description"));
            EFTTransactionRequest."Result Display Text" := CopyStr(JObject.ToString(), 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));
            EFTTransactionRequest."External Result Known" := true;
            exit;
        end;

        if TrySelectToken(JObject, 'error', JToken, false) then begin
            EFTTransactionRequest."Result Description" := CopyStr((EFTTransactionRequest."Result Description" + JToken.ToString() + ' '), 1, MaxStrLen(EFTTransactionRequest."Result Description"));
            EFTTransactionRequest."Result Display Text" := CopyStr((EFTTransactionRequest."Result Display Text" + JToken.ToString() + ' '), 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));
        end;

        //-NPR5.55 [405984]
        if TrySelectToken(JObject, 'localModeEventArgs', JToken, false) then begin
            ParseLocalModeArgs(JToken, EFTTransactionRequest);
        end;
        //+NPR5.55 [405984]

        ParseTransactionReceipts(JObject, EFTTransactionRequest);
    end;

    local procedure ParseTransactionLookup(JObject: DotNet NPRNetJObject; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JToken: DotNet NPRNetJToken;
        ReceiptNo: Integer;
        EntryNo: Integer;
        OutStream: OutStream;
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        TrySelectToken(JObject, 'latestTransactionResult', JToken, true);
        ParseLocalModeArgs(JToken, EFTTransactionRequest);

        if TrySelectToken(JObject, 'printText', JToken, false) then begin
            ReceiptNo := GetLastReceiptNo(EFTTransactionRequest);
            EntryNo := GetLastReceiptLineEntryNo(EFTTransactionRequest);
            EFTTransactionRequest."Receipt 2".CreateOutStream(OutStream);
            ParseReceipt(JToken, EFTTransactionRequest, 'Text', ReceiptNo, EntryNo, OutStream);
        end;

        if EFTTransactionRequest.Successful then begin
            //Implicit same currency code as original.
            OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
            EFTTransactionRequest."Currency Code" := OriginalEFTTransactionRequest."Currency Code";
        end;
    end;

    local procedure ParseLocalModeArgs(JObject: DotNet NPRNetJObject; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JToken: DotNet NPRNetJToken;
        JValue: DotNet NPRNetJValue;
        CVM: Integer;
        CultureInfo: DotNet NPRNetCultureInfo;
        DecimalBuffer: Decimal;
        Year: Integer;
        Month: Integer;
        Day: Integer;
        DateTime: DateTime;
        TrxTime: Time;
        TrxTimestamp: Text;
    begin
        TrySelectToken(JObject, 'Result', JToken, true);
        Evaluate(EFTTransactionRequest."Result Code", JToken.ToString());

        if EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::CLOSE, EFTTransactionRequest."Processing Type"::AUXILIARY] then begin
            EFTTransactionRequest.Successful := (EFTTransactionRequest."Result Code" = 1);
        end else begin
            EFTTransactionRequest.Successful := (EFTTransactionRequest."Result Code" = 0);
        end;

        EFTTransactionRequest."External Result Known" := (EFTTransactionRequest."Result Code" <> 99);

        if TrySelectToken(JObject, 'TruncatedPAN', JToken, false) then begin
            EFTTransactionRequest."Card Number" := JToken.ToString();
        end;

        if TrySelectToken(JObject, 'SessionNumber', JToken, false) then begin
            EFTTransactionRequest."Reconciliation ID" := JToken.ToString();
        end;

        if TrySelectToken(JObject, 'IssuerID', JToken, false) then begin
            EFTTransactionRequest."Card Issuer ID" := JToken.ToString();
        end;

        if TrySelectToken(JObject, 'TerminalID', JToken, false) then begin
            EFTTransactionRequest."Hardware ID" := JToken.ToString();
        end;

        if TrySelectToken(JObject, 'CVM', JToken, false) then begin
            //-NPR5.55 [405984]
            if Evaluate(CVM, JToken.ToString()) then begin //CVM was suddenly observed as an empty string rather than an integer after NETS backend upgrade.
                                                           //+NPR5.55 [405984]
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
            TrxTimestamp := JToken.ToString();
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
        end;

        if TrySelectToken(JObject, 'StanAuth', JToken, false) then begin
            EFTTransactionRequest."Authorisation Number" := JToken.ToString();
            EFTTransactionRequest."Reference Number Output" := JToken.ToString();
            EFTTransactionRequest."External Transaction ID" := JToken.ToString();
        end;

        if TrySelectToken(JObject, 'CardIssuerName', JToken, false) then begin
            EFTTransactionRequest."Card Name" := JToken.ToString();
        end;

        if TrySelectToken(JObject, 'AID', JToken, false) then begin
            EFTTransactionRequest."Card Application ID" := JToken.ToString();
        end;

        if TrySelectToken(JObject, 'OptionalData', JToken, false) then begin
            ParseOptionalData(EFTTransactionRequest, JToken.ToString());
        end;

        if TrySelectToken(JObject, 'ResponseCode', JToken, false) then begin
            if JToken.ToString() <> '' then begin
                EFTTransactionRequest."Result Description" := CopyStr(EFTTransactionRequest."Result Description" + '(' + JToken.ToString() + ')', 1, MaxStrLen(EFTTransactionRequest."Result Description"));
                EFTTransactionRequest."Result Display Text" := CopyStr(EFTTransactionRequest."Result Display Text" + '(' + JToken.ToString() + ')', 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));
            end;
        end;

        if EFTTransactionRequest.Successful then begin
            if TrySelectValue(JObject, 'TipAmount', JValue, false) then begin
                Evaluate(DecimalBuffer, JValue.ToString(CultureInfo.InvariantCulture), 9);
                EFTTransactionRequest."Tip Amount" := DecimalBuffer / 100;
            end;

            if TrySelectValue(JObject, 'SurchargeAmount', JValue, false) then begin
                Evaluate(DecimalBuffer, JValue.ToString(CultureInfo.InvariantCulture), 9);
                EFTTransactionRequest."Fee Amount" := DecimalBuffer / 100;
            end;

            if TrySelectValue(JObject, 'TotalAmount', JValue, false) then begin
                Evaluate(DecimalBuffer, JValue.ToString(CultureInfo.InvariantCulture), 9);
                EFTTransactionRequest."Amount Output" := DecimalBuffer / 100;
            end;
        end;
    end;

    local procedure ParseReconciliation(Response: Text; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JObject: DotNet NPRNetJObject;
        JToken: DotNet NPRNetJToken;
        TrxTimestamp: DateTime;
        OutStream: OutStream;
        ReceiptNo: Integer;
        EntryNo: Integer;
        JValue: DotNet NPRNetJValue;
        CultureInfo: DotNet NPRNetCultureInfo;
    begin
        ParseJSON(Response, JObject);

        TrySelectToken(JObject, 'result.reconciliation', JObject, true);

        TrySelectValue(JObject, 'header.timestamp', JValue, true);
        Evaluate(TrxTimestamp, JValue.ToString(CultureInfo.InvariantCulture), 9);
        EFTTransactionRequest."Transaction Date" := DT2Date(TrxTimestamp);
        EFTTransactionRequest."Transaction Time" := DT2Time(TrxTimestamp);

        TrySelectToken(JObject, 'header.sessionNumber', JToken, true);
        EFTTransactionRequest."Reconciliation ID" := JToken.ToString();

        ReceiptNo := GetLastReceiptNo(EFTTransactionRequest);
        EntryNo := GetLastReceiptLineEntryNo(EFTTransactionRequest);
        EFTTransactionRequest."Receipt 1".CreateOutStream(OutStream);
        ParseReceipt(JObject, EFTTransactionRequest, 'printText.Text', ReceiptNo, EntryNo, OutStream);

        EFTTransactionRequest.Successful := true;
        EFTTransactionRequest."External Result Known" := true;
    end;

    local procedure ParseTransactionReceipts(JObject: DotNet NPRNetJObject; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
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
        JObject: DotNet NPRNetJObject;
        JToken: DotNet NPRNetJToken;
        ReceiptNo: Integer;
        EntryNo: Integer;
        OutStream: OutStream;
    begin
        ParseJSON(Response, JObject);
        TrySelectToken(JObject, 'result.localModeEventArgs', JToken, true);
        ParseLocalModeArgs(JToken, EFTTransactionRequest);

        if TrySelectToken(JObject, 'printText', JToken, false) then begin
            ReceiptNo := GetLastReceiptNo(EFTTransactionRequest);
            EntryNo := GetLastReceiptLineEntryNo(EFTTransactionRequest);
            EFTTransactionRequest."Receipt 2".CreateOutStream(OutStream);
            ParseReceipt(JToken, EFTTransactionRequest, 'Text', ReceiptNo, EntryNo, OutStream);
        end;
    end;

    local procedure ParseTerminalSoftware(Response: Text; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JObject: DotNet NPRNetJObject;
        JToken: DotNet NPRNetJToken;
        ReceiptNo: Integer;
        EntryNo: Integer;
        OutStream: OutStream;
    begin
        ParseJSON(Response, JObject);
        TrySelectToken(JObject, 'result.localModeEventArgs', JToken, true);
        ParseLocalModeArgs(JToken, EFTTransactionRequest);

        if TrySelectToken(JObject, 'printText', JToken, false) then begin
            ReceiptNo := GetLastReceiptNo(EFTTransactionRequest);
            EntryNo := GetLastReceiptLineEntryNo(EFTTransactionRequest);
            EFTTransactionRequest."Receipt 2".CreateOutStream(OutStream);
            ParseReceipt(JToken, EFTTransactionRequest, 'Text', ReceiptNo, EntryNo, OutStream);
        end;
    end;

    local procedure ParseBalanceEnquiry(Response: Text; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JObject: DotNet NPRNetJObject;
        JToken: DotNet NPRNetJToken;
        ReceiptNo: Integer;
        EntryNo: Integer;
        OutStream: OutStream;
    begin
        ParseJSON(Response, JObject);
        TrySelectToken(JObject, 'result.localModeEventArgs', JToken, true);
        ParseLocalModeArgs(JToken, EFTTransactionRequest);

        if TrySelectToken(JObject, 'printText', JToken, false) then begin
            ReceiptNo := GetLastReceiptNo(EFTTransactionRequest);
            EntryNo := GetLastReceiptLineEntryNo(EFTTransactionRequest);
            EFTTransactionRequest."Receipt 2".CreateOutStream(OutStream);
            ParseReceipt(JToken, EFTTransactionRequest, 'Text', ReceiptNo, EntryNo, OutStream);
        end;

        if EFTTransactionRequest.Successful then begin
            EFTTransactionRequest."Result Display Text" := CopyStr(StrSubstNo(CARD_BALANCE, EFTTransactionRequest."Amount Output"), 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));
        end;
        //TODO:
        //Undocumented by NETS where balance & expiry date is located in json respose.
        //Test gift card is currently expired so cannot be check myself at this time.
    end;

    local procedure TrySelectToken(JObject: DotNet NPRNetJObject; Path: Text; var JToken: DotNet NPRNetJToken; WithError: Boolean): Boolean
    begin
        JToken := JObject.SelectToken(Path, WithError);
        exit(not IsNull(JToken));
    end;

    local procedure TrySelectValue(JObject: DotNet NPRNetJObject; Path: Text; var JValue: DotNet NPRNetJValue; WithError: Boolean): Boolean
    begin
        JValue := JObject.SelectToken(Path, WithError);
        exit(not IsNull(JValue));
    end;

    local procedure ParseReceipt(JObject: DotNet NPRNetJObject; var EFTTransactionRequest: Record "NPR EFT Transaction Request"; ReceiptElement: Text; var LastReceiptNo: Integer; var LastReceiptEntryNo: Integer; WriteToStream: OutStream)
    var
        JToken: DotNet NPRNetJToken;
        StringReader: DotNet NPRNetStringReader;
        ReceiptLine: DotNet NPRNetString;
        Receipt: Text;
    begin
        if TrySelectToken(JObject, ReceiptElement, JToken, false) then begin
            Receipt := JToken.ToString();
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
    end;

    local procedure ParseJSON(JSON: Text; var JObject: DotNet NPRNetJObject)
    var
        MemStream: DotNet NPRNetMemoryStream;
        StreamReader: DotNet NPRNetStreamReader;
        Encoding: DotNet NPRNetEncoding;
        JsonTextReader: DotNet NPRNetJsonTextReader;
        DateParseHandling: DotNet NPRNetDateParseHandling;
        FloatParseHandling: DotNet NPRNetFloatParseHandling;
    begin
        MemStream := MemStream.MemoryStream(Encoding.UTF8.GetBytes(JSON));
        StreamReader := StreamReader.StreamReader(MemStream, Encoding.UTF8);
        JsonTextReader := JsonTextReader.JsonTextReader(StreamReader);
        JsonTextReader.DateParseHandling := DateParseHandling.None;
        JsonTextReader.FloatParseHandling := FloatParseHandling.Decimal;
        JObject := JObject.Load(JsonTextReader);
    end;

    [TryFunction]
    procedure IsConclusiveLookupResult(Response: Text; InnerResponse: Text)
    var
        JObject: DotNet NPRNetJObject;
    begin
        ParseJSON(Response, JObject);
    end;

    [TryFunction]
    procedure IsInProgressError(Response: Text)
    var
        JObject: DotNet NPRNetJObject;
    begin
        ParseJSON(Response, JObject);
    end;

    [TryFunction]
    procedure IsLookupResponseRelatedToTransaction(Response: Text; EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JObject: DotNet NPRNetJObject;
        JToken: DotNet NPRNetJToken;
        TransactionDateTime: DateTime;
    begin
        // Gap in NETS API has been reported to them. Since we cannot send them our ID in request that they mirror in their response, there is no simple robust check here.
        // We have invented our own safeguard: If transaction timestamp (from NETS) varies more than 10 minutes from our timestamp (logged before we invoked them) OR StanAuth field already matches an
        // earlier transaction in NAV, then we ignore the Lookup result as a duplicate/invalid response.

        ParseJSON(Response, JObject);
        TrySelectToken(JObject, 'result', JObject, true);
        TrySelectToken(JObject, 'latestTransactionResult.StanAuth', JToken, true);

        if IsAuthorizationIdKnown(EFTTransactionRequest, JToken.ToString()) then begin
            Error(INVALID_LOOKUP_STAN, EFTTransactionRequest.FieldCaption("Authorisation Number"), EFTTransactionRequest."Authorisation Number");
        end;

        TransactionDateTime := CreateDateTime(EFTTransactionRequest."Transaction Date", EFTTransactionRequest."Transaction Time");
        if (TransactionDateTime < (EFTTransactionRequest.Started - (1000 * 60 * 10))) or (TransactionDateTime > (EFTTransactionRequest.Started + (1000 * 60 * 10))) then begin
            Error(IVNALID_LOOKUP_TIME, EFTTransactionRequest.FieldCaption("Transaction Time"), TransactionDateTime, EFTTransactionRequest.Started);
        end;
    end;

    local procedure IsAuthorizationIdKnown(EftTransactionRequestIn: Record "NPR EFT Transaction Request"; STAN: Text): Boolean
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EftTransactionRequestIn.TestField("Hardware ID");

        if STAN = '' then
            exit(false); //early cancellations have no stan. This is safe, since we know they also carry no financial impact, so we can never accidentally recover money by allowing them.

        if (EftTransactionRequestIn."Processing Type" = EftTransactionRequestIn."Processing Type"::LOOK_UP) and (EftTransactionRequestIn."Processed Entry No." <> 0) then begin
            EFTTransactionRequest.SetFilter("Entry No.", '<>%1', EftTransactionRequestIn."Processed Entry No.");
        end else begin
            EFTTransactionRequest.SetFilter("Entry No.", '<>%1', EftTransactionRequestIn."Entry No.");
        end;
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
        JObject: DotNet NPRNetJObject;
        JToken: DotNet NPRNetJToken;
        DecimalBuffer: Decimal;
        JValue: DotNet NPRNetJValue;
        CultureInfo: DotNet NPRNetCultureInfo;
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
    local procedure TryParseOptionalData(var JObject: DotNet NPRNetJObject; OptionalData: Text)
    begin
        JObject := JObject.Parse(OptionalData);
    end;
}

