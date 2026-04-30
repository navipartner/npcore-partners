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
        PageNumber: Integer;
        PagesTotal: Integer;
        PageSize: Integer;
    begin
        PageSize := 100;
        PageNumber := 1;
        repeat
            if not GetMerchantStores(IsTestEnvironment, MerchantId, APIKey, 10000, PageSize, PageNumber, Response, ResponseStatusCode) then
                Error(GetLastErrorText());
            Clear(StoresResponse);
            StoresResponse.ReadFrom(Response);
            StoresResponse.Get('data', JToken);
            DataArr := JToken.AsArray();
            foreach StoreToken in DataArr do begin
                StoreObj := StoreToken.AsObject();
                StoreObj.Get('id', JToken);
                StoreObj.Get('description', JToken2);
                if not Stores.ContainsKey(JToken.AsValue().AsText()) then
                    Stores.Add(JToken.AsValue().AsText(), JToken2.AsValue().AsText());
            end;
            if StoresResponse.Get('pagesTotal', JToken) then
                PagesTotal := JToken.AsValue().AsInteger()
            else
                PagesTotal := PageNumber;
            PageNumber += 1;
        until PageNumber > PagesTotal;
    end;

    [TryFunction]
    procedure GetMerchantStores(IsTestEnvironment: Boolean; MerchantId: Text; APIKey: Text; TimeoutMs: Integer; PageSize: Integer; PageNumber: Integer; var Response: Text; var ResponseStatusCode: Integer)
    var
        Http: HttpClient;
        HttpResponse: HttpResponseMessage;
        ErrorInvokeLbl: Label 'Error: Service endpoint ''/v3/merchants/%1/stores/'' responded with (%1): %2';
        ProdUrl: Label 'https://management-live.adyen.com/v3/merchants/%1/stores', Locked = true;
        TestUrl: Label 'https://management-test.adyen.com/v3/merchants/%1/stores', Locked = true;
        QueryLbl: Label '?pageSize=%1&pageNumber=%2', Locked = true;
    begin
        if (IsTestEnvironment) then
            Http.SetBaseAddress(StrSubstNo(TestUrl, MerchantId))
        else
            Http.SetBaseAddress(StrSubstNo(ProdUrl, MerchantId));

        Http.Timeout := TimeoutMs;
        Http.DefaultRequestHeaders().Add('x-api-key', APIKey);

        Http.Get(StrSubstNo(QueryLbl, PageSize, PageNumber), HttpResponse);
        ResponseStatusCode := HttpResponse.HttpStatusCode();
        HttpResponse.Content.ReadAs(Response);
        if not (HttpResponse.IsSuccessStatusCode) then begin
            Error(ErrorInvokeLbl, Format(ResponseStatusCode), HttpResponse.ReasonPhrase());
        end;
    end;
}