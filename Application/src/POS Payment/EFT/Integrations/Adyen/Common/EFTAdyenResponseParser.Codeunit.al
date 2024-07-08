codeunit 6184605 "NPR EFT Adyen Response Parser"
{

    //Overflows in adyen response parsing should throw error, not be silently cut.
#pragma warning disable AA0139

    Access = Internal;

    trigger OnRun()
    begin
        LockTimeout(false);
        RunParser();
    end;

    var
        ERROR_UNKNOWN_EVENT: Label 'Unknown event json';
        UNKNOWN: Label 'Unknown';
        _EftTransactionEntryNo: Integer;
        _ResponseType: Enum "NPR EFT Adyen Response Type";
        _Data: Text;

    local procedure RunParser()
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        ERROR_RESPONSE_TYPE: Label 'Unknown response type %1';
    begin
        EFTTransactionRequest.Get(_EftTransactionEntryNo);

        case _ResponseType of
            Enum::"NPR EFT Adyen Response Type"::Diagnose:
                ParseDiagnoseTransaction(_Data, EFTTransactionRequest);
            Enum::"NPR EFT Adyen Response Type"::Void:
                ParseVoidTransaction(_Data, EFTTransactionRequest);
            Enum::"NPR EFT Adyen Response Type"::Payment:
                ParsePaymentTransaction(_Data, EFTTransactionRequest);
            Enum::"NPR EFT Adyen Response Type"::TransactionStatus:
                ParseStatusTransaction(_Data, EFTTransactionRequest);
            Enum::"NPR EFT Adyen Response Type"::CardAcquisition:
                ParseCardAcquisition(_Data, EFTTransactionRequest);
            Enum::"NPR EFT Adyen Response Type"::AbortAcquireCard:
                ParseAbortAcquireCard(_Data, EFTTransactionRequest);
            Enum::"NPR EFT Adyen Response Type"::RejectNotification:
                ParseRejectNotification(_Data, EFTTransactionRequest);
            Enum::"NPR EFT Adyen Response Type"::DisableContract:
                ParseDisableContract(_Data, EFTTransactionRequest);
            else
                Error(ERROR_RESPONSE_TYPE, _ResponseType);
        end;

        EFTTransactionRequest.Modify();
    end;

    procedure SetResponseData(ResponseTypeIn: Enum "NPR EFT Adyen Response Type"; DataIn: Text; EntryNo: Integer)
    begin
        _ResponseType := ResponseTypeIn;
        _Data := DataIn;
        _EftTransactionEntryNo := EntryNo;
    end;

    local procedure ParsePaymentTransaction(Response: Text; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        JObject.ReadFrom(Response);

        if TrySelectToken(JObject, 'SaleToPOIResponse', JToken, false) then begin
            //Assume direct payment response.
            JObject := JToken.AsObject();

            TrySelectToken(JObject, 'MessageHeader', JToken, true);
            ValidateHeader(JToken.AsObject(), EFTTransactionRequest);
        end else begin
            //Assume indirect transaction request response acted as payment response, so we are in JSON element RepeatedMessageResponse
            TrySelectToken(JObject, 'MessageHeader', JToken, true);
            ValidateHeader(JToken.AsObject(), EFTTransactionRequest);

            TrySelectToken(JObject, 'RepeatedResponseMessageBody', JToken, true);
            JObject := JToken.AsObject();
        end;

        TrySelectToken(JObject, 'PaymentResponse', JToken, true);
        JObject := JToken.AsObject();

        ParsePaymentResponse(JObject, EFTTransactionRequest);

        case EFTTransactionRequest."Processing Type" of
            EFTTransactionRequest."Processing Type"::PAYMENT:
                EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output";
            EFTTransactionRequest."Processing Type"::REFUND:
                EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output" * -1;
        end;
        EFTTransactionRequest."External Result Known" := true;
    end;

    local procedure ParseVoidTransaction(Response: Text; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        JObject.ReadFrom(Response);

        if TrySelectToken(JObject, 'SaleToPOIResponse', JToken, false) then begin
            //Assume direct payment response.
            JObject := JToken.AsObject();

            TrySelectToken(JObject, 'MessageHeader', JToken, true);
            ValidateHeader(JToken.AsObject(), EFTTransactionRequest);
        end else begin
            //Assume indirect transaction request response acted as reverse response, so we are in JSON element RepeatedMessageResponse
            TrySelectToken(JObject, 'MessageHeader', JToken, true);
            ValidateHeader(JToken.AsObject(), EFTTransactionRequest);

            TrySelectToken(JObject, 'RepeatedResponseMessageBody', JToken, true);
            JObject := JToken.AsObject();
        end;

        TrySelectToken(JObject, 'ReversalResponse', JToken, true);
        JObject := JToken.AsObject();
        ParseReversalResponse(JObject, EFTTransactionRequest);

        EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output";
        EFTTransactionRequest."External Result Known" := true;
    end;

    local procedure ParseStatusTransaction(Response: Text; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        JObject.ReadFrom(Response);
        TrySelectToken(JObject, 'SaleToPOIResponse', JToken, true);
        JObject := JToken.AsObject();

        TrySelectToken(JObject, 'MessageHeader', JToken, true);
        ValidateHeader(JToken.AsObject(), EFTTransactionRequest);

        TrySelectToken(JObject, 'TransactionStatusResponse', JToken, true);
        JObject := JToken.AsObject();
        ParseStatusResponse(JObject, EFTTransactionRequest);

        EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output";
        EFTTransactionRequest."External Result Known" := true;
    end;

    local procedure ParseDiagnoseTransaction(Response: Text; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        JObject.ReadFrom(Response);

        JObject.Get('SaleToPOIResponse', JToken);
        JObject := JToken.AsObject();

        TrySelectToken(JObject, 'MessageHeader', JToken, true);
        ValidateHeader(JToken.AsObject(), EFTTransactionRequest);

        TrySelectToken(JObject, 'DiagnosisResponse', JToken, true);
        JObject := JToken.AsObject();
        EFTTransactionRequest."Result Display Text" := CopyStr(ParseDiagnoseResponse(JObject), 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));

        EFTTransactionRequest.Successful := true;
        EFTTransactionRequest."External Result Known" := true;
    end;

    local procedure ParseCardAcquisition(Response: Text; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        JObject.ReadFrom(Response);
        TrySelectToken(JObject, 'SaleToPOIResponse', JToken, true);
        JObject := JToken.AsObject();

        TrySelectToken(JObject, 'MessageHeader', JToken, true);
        ValidateHeader(JToken.AsObject(), EFTTransactionRequest);

        TrySelectToken(JObject, 'CardAcquisitionResponse', JToken, true);
        JObject := JToken.AsObject();
        ParseCardAcquisitionResponse(JObject, EFTTransactionRequest);

        EFTTransactionRequest."External Result Known" := true;
    end;

    local procedure ParseAbortAcquireCard(Response: Text; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        JObject.ReadFrom(Response);
        TrySelectToken(JObject, 'SaleToPOIResponse', JToken, true);
        JObject := JToken.AsObject();

        TrySelectToken(JObject, 'MessageHeader', JToken, true);
        ValidateHeader(JToken.AsObject(), EFTTransactionRequest);

        TrySelectToken(JObject, 'EnableServiceResponse.Response', JToken, true);
        ParseResponse(JToken.AsObject(), EFTTransactionRequest);

        EFTTransactionRequest."External Result Known" := true;
    end;

    local procedure ParseRejectNotification(Response: Text; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        JObject.ReadFrom(Response);

        TrySelectToken(JObject, 'SaleToPOIRequest.MessageHeader.ServiceID', JToken, true);
        EFTTransactionRequest.TestField("Reference Number Input", Format(JToken.AsValue().AsText()));

        TrySelectToken(JObject, 'SaleToPOIRequest.MessageHeader.MessageType', JToken, true);
        if Format(JToken.AsValue().AsText()) <> 'Notification' then
            Error(ERROR_UNKNOWN_EVENT);

        TrySelectToken(JObject, 'SaleToPOIRequest.EventNotification.EventToNotify', JToken, true);
        if Format(JToken.AsValue().AsText()) <> 'Reject' then
            Error(ERROR_UNKNOWN_EVENT);

        if TrySelectToken(JObject, 'SaleToPOIRequest.EventNotification.EventDetails', JToken, false) then
            ParseAdditionalDataString(JToken.AsValue().AsText(), EFTTransactionRequest);
    end;

    local procedure ParseDisableContract(Response: Text; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JObject: JsonObject;
        JToken: JsonToken;
        ErrorMsg: Text;
    begin
        JObject.ReadFrom(Response);

        if TrySelectToken(JObject, 'response', JToken, false) then begin
            case JToken.AsValue().AsText() of
                '[all-details-successfully-disabled]':
                    ;
                '[detail-successfully-disabled]':
                    ;
                else
                    Error('Unknown recurring API "response" type');
            end;

            EFTTransactionRequest.Successful := true;
            EFTTransactionRequest."External Result Known" := true;
        end else begin
            TrySelectToken(JObject, 'errorCode', JToken, true);
            ErrorMsg += JToken.AsValue().AsText();
            TrySelectToken(JObject, 'message', JToken, true);
            ErrorMsg += ' ' + JToken.AsValue().AsText();

            EFTTransactionRequest."Result Description" := CopyStr(ErrorMsg, 1, MaxStrLen(EFTTransactionRequest."Result Description"));
            ;
            EFTTransactionRequest.Successful := false;
            EFTTransactionRequest."External Result Known" := true;
        end;
    end;

    local procedure ParsePaymentResponse(JObject: JsonObject; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JToken: JsonToken;
        JValue: JsonValue;
        DCCObject: JsonObject;
        EFTAdyenSignatureBuffer: Codeunit "NPR EFT Adyen Signature Buffer";
    begin
        TrySelectToken(JObject, 'Response', JToken, true);
        ParseResponse(JToken.AsObject(), EFTTransactionRequest);

        if TrySelectToken(JObject, 'PaymentReceipt', JToken, false) then
            ParseReceipts(JToken.AsArray(), EFTTransactionRequest);

        TrySelectToken(JObject, 'POIData', JToken, true);
        ParsePOIData(JToken.AsObject(), EFTTransactionRequest);

        if TrySelectToken(JToken.AsObject(), 'POIReconciliationID', JToken, false) then
            EFTTransactionRequest."Reconciliation ID" := JToken.AsValue().AsText();

        if TrySelectToken(JObject, 'PaymentResult.PaymentInstrumentData', JToken, false) then
            ParsePaymentInstrumentData(JToken.AsObject(), EFTTransactionRequest);

        if TrySelectToken(JObject, 'PaymentResult.PaymentAcquirerData.AcquirerID', JToken, false) then
            EFTTransactionRequest."Acquirer ID" := JToken.AsValue().AsText();

        if TrySelectToken(JObject, 'PaymentResult.PaymentAcquirerData.ApprovalCode', JToken, false) then
            EFTTransactionRequest."Authorisation Number" := JToken.AsValue().AsText();

        if EFTTransactionRequest.Successful then begin
            if TrySelectToken(JObject, 'PaymentResult.CurrencyConversion[0]', JToken, false) then begin
                DCCObject := JToken.AsObject();
                TrySelectToken(DCCObject, 'CustomerApprovedFlag', JToken, true);
                EFTTransactionRequest."DCC Used" := JToken.AsValue().AsBoolean();
                if EFTTransactionRequest."DCC Used" then begin
                    TrySelectToken(DCCObject, 'ConvertedAmount.AmountValue', JToken, true);
                    EFTTransactionRequest."DCC Amount" := JToken.AsValue().AsDecimal();
                    TrySelectToken(DCCObject, 'ConvertedAmount.Currency', JToken, true);
                    EFTTransactionRequest."DCC Currency Code" := JToken.AsValue().AsText();
                end;
            end;

            if TrySelectToken(JObject, 'PaymentResult.CapturedSignature', JToken, false) then begin
                EFTTransactionRequest."Signature Type" := EFTTransactionRequest."Signature Type"::"On Terminal";
                EFTAdyenSignatureBuffer.SetSignatureData(Format(JToken), EFTTransactionRequest."Entry No.");
            end;

            if TrySelectToken(JObject, 'PaymentResult.AuthenticationMethod', JToken, false) then
                ParseAuthenticationMethod(JToken.AsArray(), EFTTransactionRequest);

            if TrySelectValue(JObject, 'PaymentResult.AmountsResp.AuthorizedAmount', JValue, false) then
                EFTTransactionRequest."Amount Output" := JValue.AsDecimal();

            if EFTTransactionRequest."Currency Code" = '' then
                if TrySelectToken(JObject, 'PaymentResult.AmountsResp.Currency', JToken, false) then
                    EFTTransactionRequest."Currency Code" := JToken.AsValue().AsText();

            if TrySelectValue(JObject, 'PaymentResult.AmountsResp.TotalFeesAmount', JValue, false) then
                EFTTransactionRequest."Fee Amount" := JValue.AsDecimal();

            if TrySelectValue(JObject, 'PaymentResult.AmountsResp.TipAmount', JValue, false) then
                EFTTransactionRequest."Tip Amount" := JValue.AsDecimal();
        end;
    end;

    local procedure ParseReversalResponse(JObject: JsonObject; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JToken: JsonToken;
    begin
        TrySelectToken(JObject, 'Response', JToken, true);
        ParseResponse(JToken.AsObject(), EFTTransactionRequest);

        if EFTTransactionRequest.Successful then
            EFTTransactionRequest."Amount Output" := EFTTransactionRequest."Amount Input";
    end;

    local procedure ParseStatusResponse(JObject: JsonObject; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        StatusResponse: JsonObject;
        JToken: JsonToken;
    begin
        TrySelectToken(JObject, 'Response', JToken, true);
        StatusResponse := JToken.AsObject();

        if TrySelectToken(StatusResponse, 'Result', JToken, false) then begin
            if JToken.AsValue().AsText() = 'Success' then begin
                TrySelectToken(JObject, 'RepeatedMessageResponse', JToken, true);
                JObject := JToken.AsObject();

                OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
                TrySelectToken(JObject, 'MessageHeader', JToken, true);
                ValidateHeader(JToken.AsObject(), OriginalEFTTransactionRequest);

                case OriginalEFTTransactionRequest."Processing Type" of
                    OriginalEFTTransactionRequest."Processing Type"::PAYMENT,
                OriginalEFTTransactionRequest."Processing Type"::REFUND:
                        begin
                            TrySelectToken(JObject, 'RepeatedResponseMessageBody.PaymentResponse', JToken, true);
                            ParsePaymentResponse(JToken.AsObject(), EFTTransactionRequest);
                        end;


                    OriginalEFTTransactionRequest."Processing Type"::VOID:
                        begin
                            TrySelectToken(JObject, 'RepeatedResponseMessageBody.ReversalResponse', JToken, true);
                            ParseReversalResponse(JToken.AsObject(), EFTTransactionRequest);
                            if EFTTransactionRequest.Successful then begin
                                EFTTransactionRequest."Amount Output" := OriginalEFTTransactionRequest."Amount Input";
                                EFTTransactionRequest."Currency Code" := OriginalEFTTransactionRequest."Currency Code";
                            end;
                        end;
                end;
            end
        end;

        ParseResponse(StatusResponse, EFTTransactionRequest); //Sets trx record result to match the lookup response rather than the repeated response result.
    end;

    local procedure ParseDiagnoseResponse(JObject: JsonObject): Text
    var
        TerminalStatus: Text;
        TerminalCommunication: Text;
        HostStatus: Text;
        JToken: JsonToken;
        DIAGNOSE: Label 'Terminal Status: %1\Terminal Connection: %2\Host Connection: %3';
    begin
        TerminalCommunication := UNKNOWN;
        if TrySelectToken(JObject, 'POIStatus.CommunicationOKFlag', JToken, false) then
            TerminalCommunication := JToken.AsValue().AsText();

        TerminalStatus := UNKNOWN;
        if TrySelectToken(JObject, 'POIStatus.GlobalStatus', JToken, false) then
            TerminalStatus := JToken.AsValue().AsText();

        HostStatus := UNKNOWN;
        if TrySelectToken(JObject, 'HostStatus[0].IsReachableFlag', JToken, false) then
            HostStatus := JToken.AsValue().AsText();

        exit(StrSubstNo(DIAGNOSE, TerminalStatus, TerminalCommunication, HostStatus));
    end;

    local procedure ParseCardAcquisitionResponse(JObject: JsonObject; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JToken: JsonToken;
    begin
        TrySelectToken(JObject, 'Response', JToken, true);
        ParseResponse(JToken.AsObject(), EFTTransactionRequest);

        if not EFTTransactionRequest.Successful then
            exit;

        TrySelectToken(JObject, 'POIData', JToken, true);
        ParsePOIData(JToken.AsObject(), EFTTransactionRequest);

        if TrySelectToken(JObject, 'PaymentInstrumentData', JToken, false) then
            ParsePaymentInstrumentData(JToken.AsObject(), EFTTransactionRequest);
    end;

    local procedure ParseResponse(JObject: JsonObject; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JToken: JsonToken;
    begin

        TrySelectToken(JObject, 'Result', JToken, true);
        EFTTransactionRequest.Successful := JToken.AsValue().AsText() = 'Success';

        if TrySelectToken(JObject, 'AdditionalResponse', JToken, false) then
            ParseAdditionalDataString(JToken.AsValue().AsText(), EFTTransactionRequest);

        if not EFTTransactionRequest.Successful then
            if TrySelectToken(JObject, 'ErrorCondition', JToken, false) then begin
                EFTTransactionRequest."Result Description" := JToken.AsValue().AsText();
                if JToken.AsValue().AsText() in ['Busy', 'InProgress'] then begin
                    EFTTransactionRequest."Result Code" := -10;
                end;

            end;

    end;

    local procedure ParsePaymentInstrumentData(JObject: JsonObject; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        JToken: JsonToken;
        StoredValueObject: JsonObject;
    begin
        if TrySelectToken(JObject, 'PaymentInstrumentType', JToken, false) then
            EFTTransactionRequest."Payment Instrument Type" := JToken.AsValue().AsText();

        if TrySelectToken(JObject, 'CardData.MaskedPan', JToken, false) then
            EFTTransactionRequest."Card Number" := JToken.AsValue().AsText();

        if TrySelectToken(JObject, 'StoredValueAccountID', JToken, false) then begin
            StoredValueObject := JToken.AsObject();
            TrySelectToken(StoredValueObject, 'StoredValueAccountType', JToken, true);
            EFTTransactionRequest."Stored Value Account Type" := JToken.AsValue().AsText();
            TrySelectToken(StoredValueObject, 'StoredValueID', JToken, true);
            EFTTransactionRequest."Stored Value ID" := JToken.AsValue().AsText();
            if TrySelectToken(StoredValueObject, 'StoredValueProvider', JToken, false) then
                EFTTransactionRequest."Stored Value Provider" := JToken.AsValue().AsText();
        end;
    end;

    local procedure ParsePOIData(JObject: JsonObject; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        TransactionDateTime: DateTime;
        JToken: JsonToken;
    begin
        TrySelectToken(JObject, 'POITransactionID.TransactionID', JToken, true);
        EFTTransactionRequest."Reference Number Output" := JToken.AsValue().AsText();
        EFTTransactionRequest.Validate("External Transaction ID", EFTTransactionRequest."Reference Number Output");
        TrySelectToken(JObject, 'POITransactionID.TimeStamp', JToken, true);
        TransactionDateTime := JToken.AsValue().AsDateTime();
        EFTTransactionRequest."Transaction Date" := DT2Date(TransactionDateTime);
        EFTTransactionRequest."Transaction Time" := DT2Time(TransactionDateTime);
    end;

    local procedure ParseAuthenticationMethod(JArray: JsonArray; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        authMethod: JsonToken;
    begin
        foreach authMethod in JArray do begin
            case authMethod.AsValue().AsText() of
                'SignatureCapture':
                    begin
                        EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::Signature;
                    end;
            end;
        end;
    end;

    local procedure ParseReceipts(JArray: JsonArray; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EntryNo: Integer;
        ReceiptNo: Integer;
        OutStream: OutStream;
        DocumentQualifier: Text;
        JToken: JsonToken;
        Name: Text;
        Value: Text;
        ParsePrint: Boolean;
        RequiredSignature: Boolean;
        NameValuePairLbl: Label '%1  %2\', Locked = true;
        NameValueCollection: Dictionary of [Text, Text];
        printObject: JsonToken;
        ArrayElement: JsonToken;
        OutputTextArray: JsonArray;
        collectionKey: Text;
    begin
        if JArray.Count() < 1 then
            exit;

        EntryNo := GetLastReceiptLineEntryNo(EFTTransactionRequest);
        ReceiptNo := GetLastReceiptNo(EFTTransactionRequest);

        foreach printObject in JArray do begin
            ParsePrint := true;
            TrySelectToken(printObject.AsObject(), 'DocumentQualifier', JToken, true);
            DocumentQualifier := JToken.AsValue().AsText();
            case DocumentQualifier of
                'CustomerReceipt':
                    EFTTransactionRequest."Receipt 1".CreateOutStream(OutStream, TEXTENCODING::UTF8);
                'CashierReceipt':
                    begin
                        RequiredSignature := false;
                        if TrySelectToken(printObject.AsObject(), 'RequiredSignatureFlag', JToken, false) then
                            RequiredSIgnature := JTOken.AsValue().AsBoolean();

                        if RequiredSignature then begin
                            EFTTransactionRequest."Receipt 2".CreateOutStream(OutStream, TEXTENCODING::UTF8);
                            EFTTransactionRequest."Signature Type" := EFTTransactionRequest."Signature Type"::"On Receipt";
                        end else
                            ParsePrint := false;
                    end;
                else
                    ParsePrint := false;
            end;

            if ParsePrint then begin
                TrySelectToken(printObject.AsObject(), 'OutputContent.OutputFormat', JToken, true);
                if JToken.AsValue().AsText() = 'Text' then begin
                    ReceiptNo += 1;
                    TrySelectToken(printObject.AsObject(), 'OutputContent.OutputText', JToken, true);
                    OutputTextArray := JToken.AsArray();
                    foreach ArrayElement in OutputTextArray do begin
                        Name := '';
                        Value := '';
                        TrySelectToken(ArrayElement.AsObject(), 'Text', JToken, true);
                        ParseQueryString(JToken.AsValue().AsText(), NameValueCollection);
                        foreach collectionKey in NameValueCollection.Keys() do begin
                            case collectionKey of
                                'name':
                                    Name := NameValueCollection.Get(collectionKey);
                                'value':
                                    Value := NameValueCollection.Get(collectionKey);
                            end;
                        end;

                        OutStream.WriteText(StrSubstNo(NameValuePairLbl, Name, Value));

                        EntryNo += 1;
                        InsertReceiptLine(Name, Value, ReceiptNo, EntryNo, EFTTransactionRequest);
                    end;
                end;
            end;
        end;
    end;

    local procedure ParseAdditionalDataString(QueryString: Text; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        NameValueCollection: Dictionary of [Text, Text];
        "Key": Text;
    begin
        ParseQueryString(QueryString, NameValueCollection);
        foreach Key in NameValueCollection.Keys() do begin
            case Key of
                'AID':
                    EFTTransactionRequest."Card Application ID" := NameValueCollection.Get(Key);
                'applicationPreferredName':
                    EFTTransactionRequest."Card Name" := NameValueCollection.Get(Key);
                'shopperReference':
                    EFTTransactionRequest."External Customer ID" := NameValueCollection.Get(Key);
                'message':
                    EFTTransactionRequest."Result Display Text" := CopyStr(NameValueCollection.Get(Key), 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));
            end;
        end;
    end;

    local procedure ParseQueryString(QueryString: Text; var NameValueCollection: Dictionary of [Text, Text])
    var
        Query: Text;
        QueryKeyValue: List of [Text];
        TypeHelper: Codeunit "Type Helper";
        Value: Text;
    begin
        Clear(NameValueCollection);

        foreach Query in QueryString.Split('&') do begin
            QueryKeyValue := Query.Split('=');
            Value := QueryKeyValue.Get(2);
            NameValueCollection.Add(QueryKeyValue.Get(1), TypeHelper.UrlDecode(Value));
        end;
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

    local procedure ValidateHeader(JObject: JsonObject; EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        ServiceID: Integer;
        MessageCategory: Text;
        ExpectedMessageCategory: Text;
        ERROR_HEADER_CATEGORY: Label 'Error: Header category %1, expected %2';
        JToken: JsonToken;
    begin
        TrySelectToken(JObject, 'ServiceID', JToken, true);
        Evaluate(ServiceID, JToken.AsValue().AsText());
        EFTTransactionRequest.TestField("Entry No.", ServiceID);

        case EFTTransactionRequest."Processing Type" of
            EFTTransactionRequest."Processing Type"::REFUND:
                ExpectedMessageCategory := 'Payment';
            EFTTransactionRequest."Processing Type"::PAYMENT:
                ExpectedMessageCategory := 'Payment';
            EFTTransactionRequest."Processing Type"::LOOK_UP:
                ExpectedMessageCategory := 'TransactionStatus';
            EFTTransactionRequest."Processing Type"::VOID:
                ExpectedMessageCategory := 'Reversal';
            EFTTransactionRequest."Processing Type"::SETUP:
                ExpectedMessageCategory := 'Diagnosis';
            EFTTransactionRequest."Processing Type"::AUXILIARY:
                case EFTTransactionRequest."Auxiliary Operation ID" of
                    2, 4, 5:
                        ExpectedMessageCategory := 'CardAcquisition';
                    3:
                        ExpectedMessageCategory := 'EnableService';
                end;
        end;
        TrySelectToken(JObject, 'MessageCategory', JToken, true);
        MessageCategory := JToken.AsValue().AsText();
        if MessageCategory <> ExpectedMessageCategory then
            Error(ERROR_HEADER_CATEGORY, MessageCategory, ExpectedMessageCategory);
    end;

    [TryFunction]
    procedure IsConclusiveLookupResult(Response: Text; var InnerResponse: Text)
    var
        JObject: JsonObject;
        JToken: JsonToken;
        JValue: JsonValue;
        Test: Text;
    begin
        JObject.ReadFrom(Response);
        TrySelectValue(JObject, 'SaleToPOIResponse.TransactionStatusResponse.Response.Result', JValue, true);
        Test := JValue.AsText();
        if (JValue.AsText() <> 'Success') then
            Error('Inconclusive');

        TrySelectToken(JObject, 'SaleToPOIResponse.TransactionStatusResponse.RepeatedMessageResponse', JToken, true);
        InnerResponse := Format(JToken);
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

    local procedure InsertReceiptLine(Name: Text; Value: Text; ReceiptNo: Integer; EntryNo: Integer; EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        CreditCardTransaction: Record "NPR EFT Receipt";
        TotalLength: Integer;
    begin
        Name := Name.Replace('€', 'EUR');
        Value := Value.Replace('€', 'EUR');

        CreditCardTransaction.Init();
        CreditCardTransaction.Date := Today();
        CreditCardTransaction."Transaction Time" := Time;
        CreditCardTransaction."Register No." := EFTTransactionRequest."Register No.";
        CreditCardTransaction."Sales Ticket No." := EFTTransactionRequest."Sales Ticket No.";
        CreditCardTransaction."EFT Trans. Request Entry No." := EFTTransactionRequest."Entry No.";
        CreditCardTransaction."Receipt No." := ReceiptNo;

        TotalLength := StrLen(Name) + StrLen(Value) + 2;
        if TotalLength = 2 then
            CreditCardTransaction.Text := ' '
        else
            CreditCardTransaction.Text := CopyStr(Name + ' ' + Value, 1, MaxStrLen(CreditCardTransaction.Text));

        CreditCardTransaction."Entry No." := EntryNo;
        CreditCardTransaction.Insert();
    end;
#pragma warning restore AA0139
}