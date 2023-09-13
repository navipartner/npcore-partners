codeunit 6151498 "NPR ConfigCat API"
{
    Access = Internal;

    var
        _Response: HttpResponseMessage;

    [TryFunction]
    internal procedure TryCallApi()
    var
        ResponseText: Text;
        ResponseErrorLbl: Label 'Received a bad response from the API.\Status Code: %1 - %2\Body: %3', Comment = '%1 = status code, %2 = reason phrase, %3 = body';
    begin
        ClearLastError();
        Clear(_Response);
        if not TryCallAPI(_Response) then
            Error(GetLastErrorText());

        if _Response.IsSuccessStatusCode() then
            exit;

        _Response.Content.ReadAs(ResponseText);
        Error(ResponseErrorLbl, _Response.HttpStatusCode(), _Response.ReasonPhrase(), ResponseText);
    end;

    [TryFunction]
    local procedure TryCallAPI(var Response: HttpResponseMessage)
    var
        Client: HttpClient;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        Request: Text;
        Url: Text;
    begin
        CreateBodyAsJsonObject().WriteTo(Request);
        Content.WriteFrom(Request);

        Content.GetHeaders(ContentHeaders);
        if (ContentHeaders.Contains('Content-Type')) then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        Url := ConstructEndPointUrl();
        Client.Post(Url, Content, Response);
    end;

    internal procedure GetResponse(var Response: HttpResponseMessage)
    begin
        Response := _Response;
    end;

    internal procedure GetResponseAsBuffer(var TempFeatureFlag: Record "NPR Feature Flag" temporary)
    var
        ResponseText: Text;
    begin
        _Response.Content.ReadAs(ResponseText);
        ParseResponseToFeatureFlagTemp(ResponseText, TempFeatureFlag);
    end;

    local procedure GetBaseUrl() BaseUrl: Text
    begin
        BaseUrl := 'https://npconfigcatproxy.azurewebsites.net/api/%1/eval-all';
    end;

    local procedure GetStagingIdentifier() Identifier: Text
    begin
        Identifier := 'npcore_staging_npcoreconfig';
    end;

    local procedure GetProductionIdentifier() Identifier: Text;
    begin
        Identifier := 'npcore_production_npcoreconfig';
    end;

    local procedure ConstructEndPointUrl() Url: Text;
    var
        NPRFeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        EnvironmentIdentifier: Text;
    begin
        if NPRFeatureFlagsManagement.IsProdutionEnvironment() then
            EnvironmentIdentifier := GetProductionIdentifier()
        else
            EnvironmentIdentifier := GetStagingIdentifier();

        Url := StrSubstNo(GetBaseUrl(), EnvironmentIdentifier);
    end;

    local procedure CreateBodyAsJsonObject() BodyJsonObject: JsonObject;
    var
        NPRFeatureFlagsSetup: Record "NPR Feature Flags Setup";
        UserJsonObject: JsonObject;
    begin
        NPRFeatureFlagsSetup.Get();
        NPRFeatureFlagsSetup.TestField(Identifier);

        UserJsonObject.Add('Identifier', NPRFeatureFlagsSetup.Identifier);
        BodyJsonObject.Add('user', UserJsonObject);
    end;

    local procedure ParseResponseToFeatureFlagTemp(ResponseText: Text; var TempNPRFeatureFlag: Record "NPR Feature Flag" temporary)
    var
        JsonResponse: Codeunit "JSON Management";
        JsonProperty: Codeunit "JSON Management";
        PropertyName: Text;
        PropertyValueJsonText: Text;
        ValueText: Text;
        VariationID: Text;
        NotTemporaryTableErrorLbl: Label 'The provided parameter must be a temporary table.';
    begin
        if not TempNPRFeatureFlag.IsTemporary then
            Error(NotTemporaryTableErrorLbl);

        TempNPRFeatureFlag.Reset();
        if not TempNPRFeatureFlag.IsEmpty then
            TempNPRFeatureFlag.DeleteAll();

        JsonResponse.InitializeFromString(ResponseText);

        JsonResponse.ReadProperties();
        while JsonResponse.GetNextProperty(PropertyName, PropertyValueJsonText) do begin

            Clear(JsonProperty);
            JsonProperty.InitializeFromString(PropertyValueJsonText);
            JsonProperty.GetStringPropertyValueByName('value', ValueText);
            JsonProperty.GetStringPropertyValueByName('variationId', VariationID);

            TempNPRFeatureFlag.Init();
#pragma warning disable AA0139
            TempNPRFeatureFlag.Name := PropertyName;
            TempNPRFeatureFlag.Value := ValueText;
            TempNPRFeatureFlag."Variation ID" := VariationID;
#pragma warning restore AA0139
            TempNPRFeatureFlag.Insert();
        end;
    end;




}