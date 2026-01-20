codeunit 6184595 "NPR EFT Adyen AbortTrx Req"
{
    Access = Internal;

    procedure GetRequestJson(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    begin
        exit(BuildRequestJson(EFTTransactionRequest, GetMessageCategory(EFTTransactionRequest)));
    end;

    procedure GetRequestJson(EFTTransactionRequest: Record "NPR EFT Transaction Request"; ProcessedEFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    begin
        exit(BuildRequestJson(EFTTransactionRequest, GetMessageCategoryFromProcessedRequest(ProcessedEFTTransactionRequest)));
    end;

    local procedure BuildRequestJson(EFTTransactionRequest: Record "NPR EFT Transaction Request"; MessageCategory: Text): Text
    var
        Json: Codeunit "Json Text Reader/Writer";
    begin
        Json.WriteStartObject('');
        Json.WriteStartObject('SaleToPOIRequest');
        Json.WriteStartObject('AbortRequest');
        Json.WriteStringProperty('AbortReason', 'MerchantAbort');
        Json.WriteStartObject('MessageReference');
        Json.WriteStringProperty('ServiceID', EFTTransactionRequest."Processed Entry No.");
        Json.WriteStringProperty('MessageCategory', MessageCategory);
        Json.WriteStringProperty('SaleID', EFTTransactionRequest."Register No.");
        Json.WriteEndObject(); // MessageReference
        Json.WriteEndObject(); // AbortRequest
        Json.WriteStartObject('MessageHeader');
        Json.WriteStringProperty('MessageType', 'Request');
        Json.WriteStringProperty('MessageCategory', 'Abort');
        Json.WriteStringProperty('MessageClass', 'Service');
        Json.WriteStringProperty('ServiceID', EFTTransactionRequest."Reference Number Input");
        Json.WriteStringProperty('SaleID', EFTTransactionRequest."Register No.");
        Json.WriteStringProperty('POIID', EFTTransactionRequest."Hardware ID");
        Json.WriteStringProperty('ProtocolVersion', EFTTransactionRequest."Integration Version Code");
        Json.WriteEndObject(); // MessageHeader
        Json.WriteEndObject(); // SaleToPOIRequest
        Json.WriteEndObject(); // Root

        exit(Json.GetJSonAsText());
    end;

    local procedure GetMessageCategory(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    var
        ProcessedEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        ProcessedEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
        exit(GetMessageCategoryFromProcessedRequest(ProcessedEFTTransactionRequest));
    end;

    local procedure GetMessageCategoryFromProcessedRequest(ProcessedEFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    begin
        case ProcessedEFTTransactionRequest."Processing Type" of
            ProcessedEFTTransactionRequest."Processing Type"::PAYMENT,
            ProcessedEFTTransactionRequest."Processing Type"::REFUND:
                exit('Payment');
            else
                case ProcessedEFTTransactionRequest."Auxiliary Operation ID" of
                    "NPR EFT Adyen Aux Operation"::SUBSCRIPTION_CONFIRM.AsInteger(),
                    "NPR EFT Adyen Aux Operation"::ACQUIRE_SIGNATURE.AsInteger(),
                    "NPR EFT Adyen Aux Operation"::ACQUIRE_PHONE_NO.AsInteger(),
                    "NPR EFT Adyen Aux Operation"::ACQUIRE_EMAIL.AsInteger():
                        exit('Input');
                    else
                        exit('CardAcquisition');
                end;
        end;
    end;
}