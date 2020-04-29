codeunit 6184529 "EFT Adyen Response Parser"
{
    // NPR5.53/MMV /20191120 CASE 377533 Created object
    // NPR5.53/MMV /20200131 CASE 377533 Added support for aborting InProgress/Busy terminal automatically
    // NPR5.54/MMV /20200213 CASE 387990 Re-wrote receipt parsing to prevent locking FIND.


    trigger OnRun()
    begin
        RunParser();
    end;

    var
        ERROR_RESPONSE_TYPE: Label 'Unknown response type %1';
        ERROR_HEADER_CATEGORY: Label 'Error: Header category %1, expected %2';
        ERROR_UNKNOWN_EVENT: Label 'Unknown event json';
        UNKNOWN: Label 'Unknown';
        DIAGNOSE: Label 'Terminal Status: %1\Terminal Connection: %2\Host Connection: %3';
        EftTransactionEntryNo: Integer;
        ResponseType: Text;
        Data: Text;

    local procedure RunParser()
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin
        EFTTransactionRequest.Get(EftTransactionEntryNo);

        case ResponseType of
          'Diagnose' : ParseDiagnoseTransaction(Data, EFTTransactionRequest);
          'Void' : ParseVoidTransaction(Data, EFTTransactionRequest);
          'Payment' : ParsePaymentTransaction(Data, EFTTransactionRequest);
          'TransactionStatus' : ParseStatusTransaction(Data, EFTTransactionRequest);
          'CardAcquisition' : ParseCardAcquisition(Data, EFTTransactionRequest);
          'AbortAcquireCard' : ParseAbortAcquireCard(Data, EFTTransactionRequest);
          'RejectNotification' : ParseRejectNotification(Data, EFTTransactionRequest);
          'DisableContract' : ParseDisableContract(Data, EFTTransactionRequest);
          else
            Error(ERROR_RESPONSE_TYPE, ResponseType);
        end;

        EFTTransactionRequest.Modify;
    end;

    procedure SetResponseData(ResponseTypeIn: Text;DataIn: Text;EntryNo: Integer)
    begin
        ResponseType := ResponseTypeIn;
        Data := DataIn;
        EftTransactionEntryNo := EntryNo;
    end;

    local procedure "// Parse"()
    begin
    end;

    local procedure ParsePaymentTransaction(Response: Text;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJObject;
    begin
        ParseJSON(Response, JObject);
        if TrySelectToken(JObject, 'SaleToPOIResponse', JToken, false) then begin
          //Assume direct payment response.
          JObject := JToken;

          TrySelectToken(JObject, 'MessageHeader', JToken, true);
          ValidateHeader(JToken, EFTTransactionRequest);
        end else begin
          //Assume indirect transaction request response acted as payment response, so we are in JSON element RepeatedMessageResponse
          TrySelectToken(JObject, 'MessageHeader', JToken, true);
          ValidateHeader(JToken, EFTTransactionRequest);

          TrySelectToken(JObject, 'RepeatedResponseMessageBody', JToken, true);
          JObject := JToken;
        end;

        JObject := JObject.Item('PaymentResponse');
        ParsePaymentResponse(JObject, EFTTransactionRequest);

        case EFTTransactionRequest."Processing Type" of
          EFTTransactionRequest."Processing Type"::PAYMENT : EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output";
          EFTTransactionRequest."Processing Type"::REFUND : EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output" * -1;
        end;
        EFTTransactionRequest."External Result Known" := true;
    end;

    local procedure ParseVoidTransaction(Response: Text;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJObject;
    begin
        ParseJSON(Response, JObject);

        if TrySelectToken(JObject, 'SaleToPOIResponse', JToken, false) then begin
          //Assume direct payment response.
          JObject := JToken;

          TrySelectToken(JObject, 'MessageHeader', JToken, true);
          ValidateHeader(JToken, EFTTransactionRequest);
        end else begin
          //Assume indirect transaction request response acted as reverse response, so we are in JSON element RepeatedMessageResponse
          TrySelectToken(JObject, 'MessageHeader', JToken, true);
          ValidateHeader(JToken, EFTTransactionRequest);

          TrySelectToken(JObject, 'RepeatedResponseMessageBody', JToken, true);
          JObject := JToken;
        end;

        JObject := JObject.Item('ReversalResponse');
        ParseReversalResponse(JObject, EFTTransactionRequest);

        EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output";
        EFTTransactionRequest."External Result Known" := true;
    end;

    local procedure ParseStatusTransaction(Response: Text;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJObject;
    begin
        ParseJSON(Response, JObject);
        JObject := JObject.Item('SaleToPOIResponse');

        TrySelectToken(JObject, 'MessageHeader', JToken, true);
        ValidateHeader(JToken, EFTTransactionRequest);

        JObject := JObject.Item('TransactionStatusResponse');
        ParseStatusResponse(JObject, EFTTransactionRequest);

        EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output";
        EFTTransactionRequest."External Result Known" := true;
    end;

    local procedure ParseDiagnoseTransaction(Response: Text;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJObject;
    begin
        ParseJSON(Response, JObject);
        JObject := JObject.Item('SaleToPOIResponse');

        TrySelectToken(JObject, 'MessageHeader', JToken, true);
        ValidateHeader(JToken,EFTTransactionRequest);

        JObject := JObject.Item('DiagnosisResponse');
        EFTTransactionRequest."Result Display Text" := CopyStr(ParseDiagnoseResponse(JObject, EFTTransactionRequest), 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));

        EFTTransactionRequest.Successful := true;
        EFTTransactionRequest."External Result Known" := true;
    end;

    local procedure ParseCardAcquisition(Response: Text;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJObject;
    begin
        ParseJSON(Response, JObject);
        JObject := JObject.Item('SaleToPOIResponse');

        TrySelectToken(JObject, 'MessageHeader', JToken, true);
        ValidateHeader(JToken,EFTTransactionRequest);

        JObject := JObject.Item('CardAcquisitionResponse');
        ParseCardAcquisitionResponse(JObject, EFTTransactionRequest);

        EFTTransactionRequest."External Result Known" := true;
    end;

    local procedure ParseAbortAcquireCard(Response: Text;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJObject;
    begin
        ParseJSON(Response, JObject);
        JObject := JObject.Item('SaleToPOIResponse');

        TrySelectToken(JObject, 'MessageHeader', JToken, true);
        ValidateHeader(JToken,EFTTransactionRequest);

        TrySelectToken(JObject, 'EnableServiceResponse.Response', JToken, true);
        ParseResponse(JToken, EFTTransactionRequest);

        EFTTransactionRequest."External Result Known" := true;
    end;

    local procedure ParseRejectNotification(Response: Text;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJObject;
    begin
        ParseJSON(Response, JObject);

        TrySelectToken(JObject, 'SaleToPOIRequest.MessageHeader.ServiceID', JToken, true);
        EFTTransactionRequest.TestField("Reference Number Input", Format(JToken.ToString()));

        TrySelectToken(JObject, 'SaleToPOIRequest.MessageHeader.MessageType', JToken, true);
        if Format(JToken.ToString()) <> 'Notification' then
          Error(ERROR_UNKNOWN_EVENT);

        TrySelectToken(JObject, 'SaleToPOIRequest.EventNotification.EventToNotify', JToken, true);
        if Format(JToken.ToString()) <> 'Reject' then
          Error(ERROR_UNKNOWN_EVENT);

        if TrySelectToken(JObject, 'SaleToPOIRequest.EventNotification.EventDetails', JToken, false) then
          ParseAdditionalDataString(JToken, EFTTransactionRequest);
    end;

    local procedure ParseDisableContract(Response: Text;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJObject;
        ErrorMsg: Text;
    begin
        ParseJSON(Response, JObject);

        if TrySelectToken(JObject, 'response', JToken, false) then begin
          case JToken.ToString() of
            '[all-details-successfully-disabled]' : ;
            '[detail-successfully-disabled]' : ;
            else
              Error('Unknown recurring API "response" type');
          end;

          EFTTransactionRequest.Successful := true;
          EFTTransactionRequest."External Result Known" := true;
        end else begin
          TrySelectToken(JObject, 'errorCode', JToken, true);
          ErrorMsg += JToken.ToString();
          TrySelectToken(JObject, 'message', JToken, true);
          ErrorMsg += ' ' + JToken.ToString();

          EFTTransactionRequest."Result Description" := CopyStr(ErrorMsg,1,MaxStrLen(EFTTransactionRequest."Result Description"));;
          EFTTransactionRequest.Successful := false;
          EFTTransactionRequest."External Result Known" := true;
        end;
    end;

    local procedure ParsePaymentResponse(JObject: DotNet npNetJObject;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        JToken: DotNet npNetJObject;
        TransactionDateTime: DateTime;
        EFTAdyenCloudSignDialog: Codeunit "EFT Adyen Cloud Sign Dialog";
        CultureInfo: DotNet npNetCultureInfo;
        JValue: DotNet npNetJValue;
    begin
        TrySelectToken(JObject, 'Response', JToken, true);
        ParseResponse(JToken, EFTTransactionRequest);

        if TrySelectToken(JObject, 'PaymentReceipt', JToken, false) then
          ParseReceipts(JToken, EFTTransactionRequest);

        TrySelectToken(JObject, 'POIData', JToken, true);
        ParsePOIData(JToken, EFTTransactionRequest);

        if TrySelectToken(JToken, 'POIReconciliationID', JToken, false) then
          EFTTransactionRequest."Reconciliation ID" := JToken.ToString();

        if TrySelectToken(JObject, 'PaymentResult.PaymentInstrumentData', JToken, false) then
          ParsePaymentInstrumentData(JToken, EFTTransactionRequest);

        if TrySelectToken(JObject, 'PaymentResult.PaymentAcquirerData.AcquirerID', JToken, false) then
          EFTTransactionRequest."Acquirer ID" := JToken.ToString();

        if TrySelectToken(JObject, 'PaymentResult.PaymentAcquirerData.ApprovalCode', JToken, false) then
          EFTTransactionRequest."Authorisation Number" := JToken.ToString();

        if EFTTransactionRequest.Successful then begin
          if TrySelectToken(JObject, 'PaymentResult.CurrencyConversion[0]', JToken, false) then begin
            Evaluate(EFTTransactionRequest."DCC Used", JToken.Item('CustomerApprovedFlag').ToString());
            if EFTTransactionRequest."DCC Used" then begin
              JValue := JToken.Item('ConvertedAmount').Item('AmountValue');
              Evaluate(EFTTransactionRequest."DCC Amount", JValue.ToString(CultureInfo.InvariantCulture), 9);
              EFTTransactionRequest."DCC Currency Code" := JToken.Item('ConvertedAmount').Item('Currency').ToString();
            end;
          end;

          if TrySelectToken(JObject, 'PaymentResult.CapturedSignature', JToken, false) then begin
            EFTTransactionRequest."Signature Type" := EFTTransactionRequest."Signature Type"::"On Terminal";
            EFTAdyenCloudSignDialog.SetSignatureData(EFTTransactionRequest, JToken.ToString()); //Store signature data in global state for rendering later.
          end;

          if TrySelectToken(JObject, 'PaymentResult.AuthenticationMethod', JToken, false) then
            ParseAuthenticationMethod(JToken, EFTTransactionRequest);

          if TrySelectValue(JObject, 'PaymentResult.AmountsResp.AuthorizedAmount', JValue, false) then
            Evaluate(EFTTransactionRequest."Amount Output", JValue.ToString(CultureInfo.InvariantCulture), 9);

          if EFTTransactionRequest."Currency Code" = '' then
            if TrySelectToken(JObject, 'PaymentResult.AmountsResp.Currency', JToken, false) then
              EFTTransactionRequest."Currency Code" := JToken.ToString();

          if TrySelectValue(JObject, 'PaymentResult.AmountsResp.TotalFeesAmount', JValue, false) then
            Evaluate(EFTTransactionRequest."Fee Amount", JValue.ToString(CultureInfo.InvariantCulture), 9);

          if TrySelectValue(JObject, 'PaymentResult.AmountsResp.TipAmount', JValue, false) then
            Evaluate(EFTTransactionRequest."Tip Amount", JValue.ToString(CultureInfo.InvariantCulture), 9);
        end;
    end;

    local procedure ParseReversalResponse(JObject: DotNet npNetJObject;var EFTTransactionRequest: Record "EFT Transaction Request")
    begin
        ParseResponse(JObject.Item('Response'), EFTTransactionRequest);

        if EFTTransactionRequest.Successful then
          EFTTransactionRequest."Amount Output" := EFTTransactionRequest."Amount Input";
    end;

    local procedure ParseStatusResponse(JObject: DotNet npNetJObject;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        OriginalEFTTransactionRequest: Record "EFT Transaction Request";
        StatusResponse: DotNet npNetJObject;
    begin
        StatusResponse := JObject.Item('Response');

        if (StatusResponse.Item('Result').ToString = 'Success') then begin
          JObject := JObject.Item('RepeatedMessageResponse');

          OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
          ValidateHeader(JObject.Item('MessageHeader'), OriginalEFTTransactionRequest);

          case OriginalEFTTransactionRequest."Processing Type" of
            OriginalEFTTransactionRequest."Processing Type"::PAYMENT,
            OriginalEFTTransactionRequest."Processing Type"::REFUND :
              ParsePaymentResponse(JObject.Item('RepeatedResponseMessageBody').Item('PaymentResponse'), EFTTransactionRequest);

            OriginalEFTTransactionRequest."Processing Type"::VOID :
              begin
                ParseReversalResponse(JObject.Item('RepeatedResponseMessageBody').Item('ReversalResponse'), EFTTransactionRequest);
                if EFTTransactionRequest.Successful then begin
                  EFTTransactionRequest."Amount Output" := OriginalEFTTransactionRequest."Amount Input";
                  EFTTransactionRequest."Currency Code" := OriginalEFTTransactionRequest."Currency Code";
                end;
              end;
          end
        end;

        ParseResponse(StatusResponse, EFTTransactionRequest); //Sets trx record result to match the lookup response rather than the repeated response result.
    end;

    local procedure ParseDiagnoseResponse(JObject: DotNet npNetJObject;var EFTTransactionRequest: Record "EFT Transaction Request"): Text
    var
        TerminalStatus: Text;
        TerminalCommunication: Text;
        HostStatus: Text;
        JToken: DotNet npNetJObject;
    begin
        TerminalCommunication := UNKNOWN;
        if TrySelectToken(JObject, 'POIStatus.CommunicationOKFlag', JToken, false) then
          TerminalCommunication := JToken.ToString();

        TerminalStatus := UNKNOWN;
        if TrySelectToken(JObject, 'POIStatus.GlobalStatus', JToken, false) then
          TerminalStatus := JToken.ToString();

        HostStatus := UNKNOWN;
        if TrySelectToken(JObject, 'HostStatus[0].IsReachableFlag', JToken, false) then
          HostStatus := JToken.ToString();

        exit(StrSubstNo(DIAGNOSE, TerminalStatus, TerminalCommunication, HostStatus));
    end;

    local procedure ParseCardAcquisitionResponse(JObject: DotNet npNetJObject;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        JToken: DotNet npNetJObject;
    begin
        TrySelectToken(JObject, 'Response', JToken, true);
        ParseResponse(JToken, EFTTransactionRequest);

        if not EFTTransactionRequest.Successful then
          exit;

        TrySelectToken(JObject, 'POIData', JToken, true);
        ParsePOIData(JToken, EFTTransactionRequest);

        if TrySelectToken(JObject, 'PaymentInstrumentData', JToken, false) then
          ParsePaymentInstrumentData(JToken, EFTTransactionRequest);
    end;

    local procedure ParseResponse(JObject: DotNet npNetJObject;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        JToken: DotNet npNetJObject;
    begin
        EFTTransactionRequest.Successful := (JObject.Item('Result').ToString = 'Success');

        if TrySelectToken(JObject, 'AdditionalResponse', JToken, false) then
          ParseAdditionalDataString(JToken, EFTTransactionRequest);

        if not EFTTransactionRequest.Successful then
          if TrySelectToken(JObject, 'ErrorCondition', JToken, false) then
            EFTTransactionRequest."Result Description" := JToken.ToString();
    end;

    local procedure ParsePaymentInstrumentData(JObject: DotNet npNetJObject;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        JToken: DotNet npNetJObject;
    begin
        if TrySelectToken(JObject, 'PaymentInstrumentType', JToken, false) then
          EFTTransactionRequest."Payment Instrument Type" := JToken.ToString();

        if TrySelectToken(JObject, 'CardData.MaskedPan', JToken, false) then
          EFTTransactionRequest."Card Number" := JToken.ToString();

        if TrySelectToken(JObject, 'StoredValueAccountID', JToken, false) then begin
          EFTTransactionRequest."Stored Value Account Type" := JToken.Item('StoredValueAccountType').ToString();
          EFTTransactionRequest."Stored Value ID" := JToken.Item('StoredValueID').ToString();
          if TrySelectToken(JToken, 'StoredValueProvider', JToken, false) then
            EFTTransactionRequest."Stored Value Provider" := JToken.ToString();
        end;
    end;

    local procedure ParsePOIData(JObject: DotNet npNetJObject;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        TransactionDateTime: DateTime;
    begin
        EFTTransactionRequest."Reference Number Output" := JObject.Item('POITransactionID').Item('TransactionID').ToString();
        EFTTransactionRequest."External Transaction ID" := EFTTransactionRequest."Reference Number Output";
        Evaluate(TransactionDateTime, JObject.Item('POITransactionID').Item('TimeStamp').ToString(), 9);
        EFTTransactionRequest."Transaction Date" := DT2Date(TransactionDateTime);
        EFTTransactionRequest."Transaction Time" := DT2Time(TransactionDateTime);
    end;

    local procedure ParseAuthenticationMethod(JObject: DotNet npNetJObject;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        i: Integer;
    begin
        if JObject.Count = 0 then
          exit;

        for i := 0 to JObject.Count-1 do begin
          case JObject.Item(i).ToString() of
            'SignatureCapture' :
              begin
                EFTTransactionRequest."Authentication Method" := EFTTransactionRequest."Authentication Method"::Signature;
              end;
          end;
        end;
    end;

    local procedure ParseReceipts(JObject: DotNet npNetJObject;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        i: Integer;
        EntryNo: Integer;
        ReceiptNo: Integer;
        OutStream: OutStream;
        DocumentQualifier: Text;
        JToken: DotNet npNetJObject;
        OutputFormat: Text;
        j: Integer;
        Line: Text;
        NameValueCollection: DotNet npNetNameValueCollection;
        "Key": Text;
        Name: Text;
        Value: Text;
        ParsePrint: Boolean;
        TotalLength: Integer;
        RequiredSignature: Boolean;
        CreditCardTransaction: Record "EFT Receipt";
    begin
        if JObject.Count() < 1 then
          exit;

        //-NPR5.54 [387990]
        EntryNo := GetLastReceiptLineEntryNo(EFTTransactionRequest);
        ReceiptNo := GetLastReceiptNo(EFTTransactionRequest);
        //+NPR5.54 [387990]

        for i := 0 to (JObject.Count()-1) do begin

          ParsePrint := true;
          DocumentQualifier := JObject.Item(i).Item('DocumentQualifier').ToString();
          case DocumentQualifier of
            'CustomerReceipt' : EFTTransactionRequest."Receipt 1".CreateOutStream(OutStream, TEXTENCODING::UTF8);
            'CashierReceipt' :
              begin
                RequiredSignature := false;
                if TrySelectToken(JObject.Item(i), 'RequiredSignatureFlag', JToken, false) then
                  Evaluate(RequiredSignature, JToken.ToString(), 9);

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
            if JObject.Item(i).Item('OutputContent').Item('OutputFormat').ToString() = 'Text' then begin
        //-NPR5.54 [387990]
              ReceiptNo += 1;
        //+NPR5.54 [387990]
              JToken := JObject.Item(i).Item('OutputContent').Item('OutputText');
              for j := 0 to (JToken.Count()-1) do begin

                Name := '';
                Value := '';
                ParseQueryString(JToken.Item(j).Item('Text').ToString(), NameValueCollection);
                foreach Key in NameValueCollection do begin
                  case Key of
                    'name' : Name := NameValueCollection.Get(Key);
                    'value' : Value := NameValueCollection.Get(Key);
                  end;
                end;

                OutStream.WriteText(StrSubstNo('%1  %2\', Name, Value));

        //-NPR5.54 [387990]
                EntryNo += 1;
                InsertReceiptLine(Name, Value, ReceiptNo, EntryNo, EFTTransactionRequest);
        //+NPR5.54 [387990]
              end;
            end;
          end;
        end;
    end;

    local procedure ParseAdditionalDataString(JObject: DotNet npNetJObject;var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        NameValueCollection: DotNet npNetNameValueCollection;
        "Key": Text;
    begin
        ParseQueryString(JObject.ToString(), NameValueCollection);
        foreach Key in NameValueCollection do begin
          case Key of
            'AID' : EFTTransactionRequest."Card Application ID" := NameValueCollection.Get(Key);
            'applicationPreferredName' : EFTTransactionRequest."Card Name" := NameValueCollection.Get(Key);
            'shopperReference' : EFTTransactionRequest."External Customer ID" := NameValueCollection.Get(Key);
            'message' : EFTTransactionRequest."Result Display Text" := CopyStr(NameValueCollection.Get(Key), 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));
          end;
        end;
    end;

    local procedure ParseQueryString(QueryString: Text;var NameValueCollection: DotNet npNetNameValueCollection)
    var
        HttpUtility: DotNet npNetHttpUtility;
    begin
        NameValueCollection := HttpUtility.ParseQueryString(QueryString);
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

    local procedure ValidateHeader(JObject: DotNet npNetJObject;EFTTransactionRequest: Record "EFT Transaction Request")
    var
        ServiceID: Integer;
        MessageCategory: Text;
        ExpectedMessageCategory: Text;
    begin
        Evaluate(ServiceID, JObject.Item('ServiceID').ToString());
        EFTTransactionRequest.TestField("Entry No.", ServiceID);

        case EFTTransactionRequest."Processing Type" of
          EFTTransactionRequest."Processing Type"::REFUND : ExpectedMessageCategory := 'Payment';
          EFTTransactionRequest."Processing Type"::PAYMENT : ExpectedMessageCategory := 'Payment';
          EFTTransactionRequest."Processing Type"::LOOK_UP : ExpectedMessageCategory := 'TransactionStatus';
          EFTTransactionRequest."Processing Type"::VOID : ExpectedMessageCategory := 'Reversal';
          EFTTransactionRequest."Processing Type"::SETUP : ExpectedMessageCategory := 'Diagnosis';
          EFTTransactionRequest."Processing Type"::AUXILIARY :
            case EFTTransactionRequest."Auxiliary Operation ID" of
              2,4,5 : ExpectedMessageCategory := 'CardAcquisition';
              3 : ExpectedMessageCategory := 'EnableService';
            end;
        end;
        MessageCategory := JObject.Item('MessageCategory').ToString();
        if MessageCategory <> ExpectedMessageCategory then
          Error(ERROR_HEADER_CATEGORY, MessageCategory, ExpectedMessageCategory);
    end;

    [TryFunction]
    procedure IsConclusiveLookupResult(Response: Text;var InnerResponse: Text)
    var
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJObject;
    begin
        ParseJSON(Response, JObject);
        TrySelectToken(JObject, 'SaleToPOIResponse.TransactionStatusResponse.Response.Result', JToken, true);
        if not (JToken.ToString() = 'Success') then
          Error('Inconclusive');

        TrySelectToken(JObject, 'SaleToPOIResponse.TransactionStatusResponse.RepeatedMessageResponse', JToken, true);
        InnerResponse := JToken.ToString();
    end;

    [TryFunction]
    procedure IsInProgressError(Response: Text)
    var
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJObject;
    begin
        //-NPR5.53 [377533]
        ParseJSON(Response, JObject);

        if not TrySelectToken(JObject, 'SaleToPOIResponse.PaymentResponse', JToken, false) then
          if not TrySelectToken(JObject, 'SaleToPOIResponse.TransactionStatusResponse', JToken, false) then
            if not TrySelectToken(JObject, 'SaleToPOIResponse.CardAcquisitionResponse', JToken, false) then
              if not TrySelectToken(JObject, 'SaleToPOIResponse.ReversalResponse', JToken, false) then
                Error('Not InProgress');

        JObject := JToken;

        TrySelectToken(JObject, 'Response.Result', JToken, true);
        if not (JToken.ToString() = 'Failure') then
          Error('Not InProgress');

        TrySelectToken(JObject, 'Response.ErrorCondition', JToken, true);
        if not ((JToken.ToString() = 'InProgress') or (JToken.ToString() = 'Busy'))then
          Error('Not InProgress');
        //+NPR5.53 [377533]
    end;

    local procedure "// Aux"()
    begin
    end;

    local procedure GetLastReceiptLineEntryNo(EFTTransactionRequest: Record "EFT Transaction Request"): Integer
    var
        CreditCardTransaction: Record "EFT Receipt";
    begin
        //-NPR5.54 [387990]
        CreditCardTransaction.SetRange("Register No.", EFTTransactionRequest."Register No.");
        CreditCardTransaction.SetRange("Sales Ticket No.", EFTTransactionRequest."Sales Ticket No.");
        if (CreditCardTransaction.FindLast()) then;
        exit(CreditCardTransaction."Entry No.");
        //+NPR5.54 [387990]
    end;

    local procedure GetLastReceiptNo(EFTTransactionRequest: Record "EFT Transaction Request"): Integer
    var
        CreditCardTransaction: Record "EFT Receipt";
    begin
        //-NPR5.54 [387990]
        CreditCardTransaction.SetRange("Register No.", EFTTransactionRequest."Register No.");
        CreditCardTransaction.SetRange("Sales Ticket No.", EFTTransactionRequest."Sales Ticket No.");
        if (CreditCardTransaction.FindLast()) then;
        exit(CreditCardTransaction."Receipt No.");
        //+NPR5.54 [387990]
    end;

    local procedure InsertReceiptLine(Name: Text;Value: Text;ReceiptNo: Integer;EntryNo: Integer;EFTTransactionRequest: Record "EFT Transaction Request")
    var
        CreditCardTransaction: Record "EFT Receipt";
        TotalLength: Integer;
    begin
        //-NPR5.54 [387990]
        Name := SubstituteCurrencyChars(Name);
        Value := SubstituteCurrencyChars(Value);

        CreditCardTransaction.Init;
        CreditCardTransaction.Date := Today;
        CreditCardTransaction."Transaction Time" := Time;
        CreditCardTransaction."Register No." := EFTTransactionRequest."Register No.";
        CreditCardTransaction."Sales Ticket No." := EFTTransactionRequest."Sales Ticket No.";
        CreditCardTransaction."EFT Trans. Request Entry No." := EFTTransactionRequest."Entry No.";
        CreditCardTransaction."Receipt No." := ReceiptNo;

        TotalLength := StrLen(Name) + StrLen(Value) + 2;
        if TotalLength = 2 then
          CreditCardTransaction.Text := ' '
        else if TotalLength <= 40 then
          CreditCardTransaction.Text := Name + PadStr('', 40-StrLen(Name)-StrLen(Value), ' ') + Value;

        CreditCardTransaction."Entry No." := EntryNo;
        CreditCardTransaction.Insert;
        //+NPR5.54 [387990]
    end;

    local procedure ParseJSON(JSON: Text;var JObject: DotNet npNetJObject)
    var
        MemStream: DotNet npNetMemoryStream;
        StreamReader: DotNet npNetStreamReader;
        Encoding: DotNet npNetEncoding;
        JsonTextReader: DotNet npNetJsonTextReader;
        DateParseHandling: DotNet npNetDateParseHandling;
        FloatParseHandling: DotNet npNetFloatParseHandling;
        FloatFormatHandling: DotNet npNetFloatFormatHandling;
    begin
        MemStream := MemStream.MemoryStream(Encoding.UTF8.GetBytes(JSON));
        StreamReader := StreamReader.StreamReader(MemStream,Encoding.UTF8);
        JsonTextReader := JsonTextReader.JsonTextReader(StreamReader);
        JsonTextReader.DateParseHandling := DateParseHandling.None;
        JsonTextReader.FloatParseHandling := FloatParseHandling.Decimal;
        JObject := JObject.Load(JsonTextReader);
    end;

    local procedure SubstituteCurrencyChars(Value: Text): Text
    var
        String: DotNet npNetString;
    begin
        //Make print data more encoding agnostic.
        if StrPos(Value, '�') > 0 then begin

          String := Value;
          exit(String.Replace('�', 'EUR'));
        end;

        exit(Value);
    end;
}

