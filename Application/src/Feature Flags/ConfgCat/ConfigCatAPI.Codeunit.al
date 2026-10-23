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
        ResponseJson: JsonObject;
        FlagToken: JsonToken;
        PropertyName: Text;
        ValueText: Text;
        VariationID: Text;
        NotTemporaryTableErrorLbl: Label 'The provided parameter must be a temporary table.';
        NotValidJsonErrorLbl: Label 'The ConfigCat response is not valid JSON. This is a programming bug.', Locked = true;
        NoFeatureFlagsErrorLbl: Label 'The ConfigCat response contains no feature flags. This is a programming bug.', Locked = true;
        NotFlagObjectErrorLbl: Label 'The ConfigCat response entry ''%1'' is not a feature flag object. This is a programming bug.', Locked = true, Comment = '%1 = feature flag name';
    begin
        if not TempNPRFeatureFlag.IsTemporary then
            Error(NotTemporaryTableErrorLbl);

        TempNPRFeatureFlag.Reset();
        if not TempNPRFeatureFlag.IsEmpty then
            TempNPRFeatureFlag.DeleteAll();

        if not ResponseJson.ReadFrom(ResponseText) then
            Error(NotValidJsonErrorLbl);

        foreach PropertyName in ResponseJson.Keys() do begin
            ResponseJson.Get(PropertyName, FlagToken);
            if not FlagToken.IsObject() then
                Error(NotFlagObjectErrorLbl, PropertyName);

            ValueText := GetPropertyValueAsText(FlagToken.AsObject(), 'value');
            VariationID := GetPropertyValueAsText(FlagToken.AsObject(), 'variationId');

            TempNPRFeatureFlag.Init();
#pragma warning disable AA0139
            TempNPRFeatureFlag.Name := PropertyName;
            TempNPRFeatureFlag.Value := ValueText;
            TempNPRFeatureFlag."Variation ID" := VariationID;
#pragma warning restore AA0139
            TempNPRFeatureFlag.Insert();
        end;

        if TempNPRFeatureFlag.IsEmpty then
            Error(NoFeatureFlagsErrorLbl);
    end;

    local procedure GetPropertyValueAsText(FlagJson: JsonObject; PropertyName: Text): Text
    var
        PropertyToken: JsonToken;
    begin
        if not FlagJson.Get(PropertyName, PropertyToken) then
            exit('');
        if not PropertyToken.IsValue() then
            exit('');
        if PropertyToken.AsValue().IsNull() then
            exit('');
        exit(PropertyToken.AsValue().AsText());
    end;




}