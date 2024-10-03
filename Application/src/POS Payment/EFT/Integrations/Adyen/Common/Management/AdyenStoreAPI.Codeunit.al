codeunit 6185001 "NPR Adyen Store API"
{
    Access = Internal;

    [TryFunction]
    procedure GetMerchantStoresIdAndNames(IsTestEnvironment: Boolean; MerchantId: Text; APIKey: Text; var Stores: Dictionary of [Text, Text])
    var
        Response: Text;
        ResponseStatusCode: Integer;
        StoresResponse: JsonObject;
        DataArr: JsonArray;
        JToken: JsonToken;
        JToken2: JsonToken;
        StoreToken: JsonToken;
        StoreObj: JsonObject;
    begin
        GetMerchantStores(IsTestEnvironment, MerchantId, APIKey, 10000, Response, ResponseStatusCode);
        StoresResponse.ReadFrom(Response);
        StoresResponse.Get('data', JToken);
        DataArr := JToken.AsArray();
        foreach StoreToken in DataArr do begin
            StoreObj := StoreToken.AsObject();
            StoreObj.Get('id', JToken);
            StoreObj.Get('description', JToken2);
            Stores.Add(JToken.AsValue().AsText(), JToken2.AsValue().AsText());
        end;
    end;

    [TryFunction]
    procedure GetMerchantStores(IsTestEnvironment: Boolean; MerchantId: Text; APIKey: Text; TimeoutMs: Integer; var Response: Text; var ResponseStatusCode: Integer)
    var
        Http: HttpClient;
        HttpResponse: HttpResponseMessage;
        ErrorInvokeLbl: Label 'Error: Service endpoint ''/v3/merchants/%1/stores/'' responded with (%1): %2';
        ProdUrl: Label 'https://management-live.adyen.com/v3/merchants/%1/stores', Locked = true;
        TestUrl: Label 'https://management-test.adyen.com/v3/merchants/%1/stores', Locked = true;
    begin
        if (IsTestEnvironment) then
            Http.SetBaseAddress(StrSubstNo(TestUrl, MerchantId))
        else
            Http.SetBaseAddress(StrSubstNo(ProdUrl, MerchantId));

        Http.Timeout := TimeoutMs;
        Http.DefaultRequestHeaders().Add('x-api-key', APIKey);

        Http.Get('', HttpResponse);
        ResponseStatusCode := HttpResponse.HttpStatusCode();
        HttpResponse.Content.ReadAs(Response);
        if not (HttpResponse.IsSuccessStatusCode) then begin
            Error(ErrorInvokeLbl, Format(ResponseStatusCode), HttpResponse.ReasonPhrase());
        end;
    end;
}