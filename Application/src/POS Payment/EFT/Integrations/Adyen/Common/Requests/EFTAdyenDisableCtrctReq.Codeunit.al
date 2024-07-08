codeunit 6184599 "NPR EFT Adyen DisableCtrct Req"
{
    Access = Internal;

    procedure GetRequestJson(EFTTransactionRequest: Record "NPR EFT Transaction Request"; MerchantAccount: Text): Text
    var
        Json: Codeunit "Json Text Reader/Writer";
    begin
        Json.WriteStartObject('');
        Json.WriteStringProperty('shopperReference', EFTTransactionRequest."External Customer ID");
        Json.WriteStringProperty('merchantAccount', MerchantAccount);
        Json.WriteEndObject();

        exit(Json.GetJSonAsText());
    end;
}