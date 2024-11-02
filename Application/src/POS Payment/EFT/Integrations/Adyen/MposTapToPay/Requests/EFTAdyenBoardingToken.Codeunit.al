codeunit 6184995 "NPR EFT Adyen Boarding Token"
{
    Access = Internal;
    [TryFunction]
    procedure RequestBoardingToken(EFTAdyenPaymTypeSetup: Record "NPR EFT Adyen Paym. Type Setup"; StoreId: Text; BoardingRequestToken: Text; var BoardingTokenB64: Text)
    var
        Url: Text;
        Request: Text;
        Response: Text;
        StatusCode: Integer;
        Json: JsonObject;
        JToken: JsonToken;
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Protocol";
        Base64Convert: Codeunit "Base64 Convert";
    begin
        if (EFTAdyenPaymTypeSetup."Merchant Account" = '') then Error('Merchant Account was not specified!');
        if (StoreId = '') then Error('Store was not specified!');
        if (EFTAdyenPaymTypeSetup."API Key" = '') then Error('API Key was not specified!');
        if (BoardingRequestToken = '') then Error('Boarding Request Token was not empty!');
        Url := GetBoardingUrl(EFTAdyenPaymTypeSetup.Environment = EFTAdyenPaymTypeSetup.Environment::TEST, EFTAdyenPaymTypeSetup."Merchant Account", StoreId);
        JsonTextReaderWriter.WriteStartObject('');
        JsonTextReaderWriter.WriteStringProperty('boardingRequestToken', BoardingRequestToken);
        JsonTextReaderWriter.WriteEndObject();//Root
        Request := JsonTextReaderWriter.GetJSonAsText();
        EFTAdyenCloudProtocol.InvokeAPI(Request, EFTAdyenPaymTypeSetup."API Key", Url, 5000, Response, StatusCode);
        if (StatusCode <> 200) then
            Error('Requesting BoardingToken failed (%1): %2', StatusCode, Response);
        Json.ReadFrom(Response);
        Json.Get('boardingToken', JToken);
        BoardingTokenB64 := Base64Convert.ToBase64(JToken.AsValue().AsText());
    end;

    local procedure GetBoardingUrl(Sandbox: Boolean; Merchant: Text; Store: Text): Text
    var
        Url: Text;
        Env: Text;
        StoreUrl: Label 'https://management-%1.adyen.com/v1/merchants/%2/stores/%3/generatePaymentsAppBoardingToken', Locked = true;
    begin

        if (Sandbox) then
            Env := 'test'
        else
            Env := 'live';
        Url := StrSubstNo(StoreUrl, Env, Merchant, Store);
        exit(Url);
    end;
}