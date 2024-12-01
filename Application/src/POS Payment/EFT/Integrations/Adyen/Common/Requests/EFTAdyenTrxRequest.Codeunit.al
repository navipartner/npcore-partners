codeunit 6184589 "NPR EFT Adyen Trx Request"
{
    Access = Internal;

    procedure GetRequestJson(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"): Text
    var
        Json: Codeunit "Json Text Reader/Writer";
        TransactionConditions: Text;
        AcquireCardRequest: Record "NPR EFT Transaction Request";
        JsonText: Text;
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
    begin
        Json.WriteStartObject('');

        Json.WriteStartObject('SaleToPOIRequest');

        Json.WriteStartObject('MessageHeader');
        Json.WriteStringProperty('ProtocolVersion', EFTTransactionRequest."Integration Version Code");
        Json.WriteStringProperty('MessageClass', 'Service');
        Json.WriteStringProperty('MessageCategory', 'Payment');
        Json.WriteStringProperty('MessageType', 'Request');
        Json.WriteStringProperty('ServiceID', EFTTransactionRequest."Reference Number Input");
        Json.WriteStringProperty('SaleID', EFTTransactionRequest."Register No.");
        Json.WriteStringProperty('POIID', EFTTransactionRequest."Hardware ID");
        Json.WriteEndObject(); // MessageHeader

        Json.WriteStartObject('PaymentRequest');
        Json.WriteStartObject('SaleData');
        Json.WriteStringProperty('SaleToAcquirerData', GetSaleToAcquirerData(EFTTransactionRequest, EFTSetup));
        Json.WriteStartObject('SaleTransactionID');
        Json.WriteStringProperty('TransactionID', EFTTransactionRequest."Sales Ticket No.");
        Json.WriteStringProperty('TimeStamp', Format(CurrentDateTime(), 0, 9));
        Json.WriteEndObject(); // SaleTransactionID
        Json.WriteStringProperty('SaleReferenceID', EFTTransactionRequest.Token);
        Json.WriteEndObject(); // SaleData
        Json.WriteStartObject('PaymentTransaction');
        Json.WriteStartObject('AmountsReq');
        Json.WriteStringProperty('Currency', EFTTransactionRequest."Currency Code");
        Json.WriteStringProperty('RequestedAmount', Format(EFTTransactionRequest."Amount Input", 0, '<Precision,2:3><Standard Format,9>'));
        if EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::PAYMENT then
            Json.WriteStringProperty('CashBackAmount', Format(EFTTransactionRequest."Cashback Amount", 0, '<Precision,2:3><Standard Format,9>'));
        Json.WriteEndObject(); // AmountsReq
        TransactionConditions := GetTransactionConditions(EFTSetup);
        if TransactionConditions <> '' then begin
            Json.WriteStartObject('TransactionConditions');
            Json.WriteStartArray('AllowedPaymentBrand');
            Json.WriteValue(TransactionConditions);
            Json.WriteEndArray();
            Json.WriteEndObject(); // TransactionConditions
        end;
        Json.WriteEndObject(); // PaymentTransaction

        Json.WriteStartObject('PaymentData');
        if EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::REFUND then
            Json.WriteStringProperty('PaymentType', 'Refund');
        if GetLinkedCardAcquisition(EFTTransactionRequest, AcquireCardRequest) then begin
            Json.WriteStartObject('CardAcquisitionReference');
            Json.WriteStringProperty('TransactionID', AcquireCardRequest."Reference Number Output");
            Json.WriteStringProperty('TimeStamp', Format(CreateDateTime(AcquireCardRequest."Transaction Date", AcquireCardRequest."Transaction Time"), 0, 9));
            Json.WriteEndObject(); // CardAcquisitionReference
        end;
        Json.WriteEndObject(); // PaymentData

        Json.WriteEndObject(); // PaymentRequest
        Json.WriteEndObject(); // SaleToPOIRequest
        Json.WriteEndObject(); // Root

        JsonText := EFTAdyenIntegration.RewriteAmountFromStringToNumberWithoutRounding(Json.GetJSonAsText(), 'RequestedAmount');
        JsonText := EFTAdyenIntegration.RewriteAmountFromStringToNumberWithoutRounding(JsonText, 'CashBackAmount');

        exit(JsonText);
    end;


    local procedure GetSaleToAcquirerData(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        Value: Text;
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
        CaptureDelayHours: Integer;
    begin
        if (EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND]) then begin
            Value := 'tenderOption=ReceiptHandler&tenderOption=GetAdditionalData';

            if (
                (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::PAYMENT) and
                (EFTAdyenIntegration.GetEnableTipping(EFTSetup))
            ) then
                Value += '&tenderOption=AskGratuity';

            case EFTAdyenIntegration.GetCreateRecurringContract(EFTSetup) of
                EFTAdyenPaymentTypeSetup."Create Recurring Contract"::NO:
                    ;
                EFTAdyenPaymentTypeSetup."Create Recurring Contract"::ONECLICK:
                    Value += '&recurringProcessingModel=CardOnFile&shopperReference=' + EFTTransactionRequest."Internal Customer ID";
                EFTAdyenPaymentTypeSetup."Create Recurring Contract"::RECURRING:
                    Value += '&recurringProcessingModel=Subscription&shopperReference=' + EFTTransactionRequest."Internal Customer ID";
                EFTAdyenPaymentTypeSetup."Create Recurring Contract"::RECURRING_ONECLICK:
                    Value += '&recurringProcessingModel=UnscheduledCardOnFile,RECURRING&shopperReference=' + EFTTransactionRequest."Internal Customer ID";
            end;

            if not EFTTransactionRequest."Manual Capture" then begin
                CaptureDelayHours := EFTAdyenIntegration.GetCaptureDelayHours(EFTSetup);
                if CaptureDelayHours >= 0 then
                    Value += '&captureDelayHours=' + Format(CaptureDelayHours);
            end else
                Value += '&manualCapture=true';

        end else
            if EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::VOID then begin
                Value := 'tenderOption=ReceiptHandler';
            end;

        exit(Value);
    end;

    local procedure GetTransactionConditions(EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        Condition: Integer;
    begin
        Condition := EFTAdyenIntegration.GetTransactionCondition(EFTSetup);
        case Condition of
            1:
                exit('alipay');
            2:
                exit('wechat');
        end;

        exit('');
    end;

    procedure GetLinkedCardAcquisition(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var AcquireCardRequestOut: Record "NPR EFT Transaction Request"): Boolean
    begin
        AcquireCardRequestOut.SetRange("Initiated from Entry No.", EFTTransactionRequest."Entry No.");
        AcquireCardRequestOut.SetRange("Processing Type", AcquireCardRequestOut."Processing Type"::AUXILIARY);
        AcquireCardRequestOut.SetRange("Auxiliary Operation ID", 2);
        AcquireCardRequestOut.SetRange(Successful, true);
        exit(AcquireCardRequestOut.FindFirst());
    end;
}