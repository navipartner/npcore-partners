codeunit 6184830 "NPR DocLXCityCard"
{
    Access = Internal;

    var
        _ErrorJsonLabel: Label '{"state": {"code": %1, "message": "%2"}}', Locked = true;
        _ValidationFailed: Label 'Card validation failed %1:';

    internal procedure ValidateCityCard(CardNumber: Code[20]; CityCode: Code[10]; LocationCode: Code[10]; PosUnitNo: Code[10]) Result: JsonObject
    var
        CityCardLocation: Record "NPR DocLXCityCardLocation";

        EntryNo: Integer;
    begin
        if (not ValidateSetup(CardNumber, CityCode, LocationCode, Result)) then
            exit;

        CityCardLocation.Get(CityCode, LocationCode);

        EntryNo := CreateValidationLog(CardNumber, CityCode, LocationCode, PosUnitNo);
        if (ValidateCard(CardNumber, CityCode, CityCardLocation.CityCardLocationId, Result)) then begin
            UpdateLogValidate(EntryNo, Result);
        end else begin
            Result.ReadFrom(StrSubstNo(_ErrorJsonLabel, 5100, StrSubstNo(_ValidationFailed, StripQuotes(GetLastErrorText()))));
            UpdateLogValidate(EntryNo, Result);
        end;

    end;

    internal procedure RedeemCityCard(CardNumber: Code[20]; CityCode: Code[10]; LocationCode: Code[10]) Result: JsonObject
    var
        CityCardLocation: Record "NPR DocLXCityCardLocation";
        LogEntry: Record "NPR DocLXCityCardHistory";
        NotFound: Label 'Card validation entry not found for card: %1';
    begin
        if (not ValidateSetup(CardNumber, CityCode, LocationCode, Result)) then
            exit;

        CityCardLocation.Get(CityCode, LocationCode);

        LogEntry.LockTable(true);
        LogEntry.SetCurrentKey(CardNumber, CityCode, LocationCode);
        LogEntry.SetFilter(CardNumber, '=%1', CardNumber);
        LogEntry.SetFilter(CityCode, '=%1', CityCode);
        LogEntry.SetFilter(LocationCode, '=%1', LocationCode);
        LogEntry.SetFilter(ValidationResultCode, '=%1', '200');
        LogEntry.SetFilter(RedemptionResultCode, '=%1', '');
        if (not LogEntry.FindLast()) then begin
            Result.ReadFrom(StrSubstNo(_ErrorJsonLabel, 5200, StrSubstNo(NotFound, CardNumber)));
            exit;
        end;

        if (RedeemCard(CardNumber, CityCode, CityCardLocation.CityCardLocationId, LogEntry.ValidatedAtDateTimeUtc, LogEntry.POSUnitNo, Result)) then begin
            UpdateLogRedemption(LogEntry.EntryNo, Result);
        end else begin
            Result.ReadFrom(StrSubstNo(_ErrorJsonLabel, 5200, StrSubstNo(_ValidationFailed, StripQuotes(GetLastErrorText()))));
            UpdateLogRedemption(LogEntry.EntryNo, Result);
        end;
        Commit();
    end;

    internal procedure AcquireCoupon(CardNumber: Code[20]; CityCode: Code[10]; LocationCode: Code[10]; SalesDocumentNo: Code[20]) Result: JsonObject
    var
        CityCardLocation: Record "NPR DocLXCityCardLocation";
        LogEntry: Record "NPR DocLXCityCardHistory";
        CityCardItems: Record "NPR DocLXCityCardItem";
        CouponType: Code[10];
        CouponNo: Code[20];
        CouponReferenceNo: Text[50];
        ArticleNotFound: Label 'Article %1 not found for city: %2';
        CouponTypeNotFound: Label 'Coupon type not found for city: %1, location %2, article %3';
        GeneralError: Label 'There was a problem when redeeming the city card %1';
    begin
        if (not ValidateSetup(CardNumber, CityCode, LocationCode, Result)) then
            exit;

        CityCardLocation.Get(CityCode, LocationCode);

        LogEntry.SetCurrentKey(CardNumber, CityCode, LocationCode);
        LogEntry.SetFilter(CardNumber, '=%1', CardNumber);
        LogEntry.SetFilter(CityCode, '=%1', CityCode);
        LogEntry.SetFilter(LocationCode, '=%1', LocationCode);
        LogEntry.SetFilter(ValidationResultCode, '=%1', '200');
        LogEntry.SetFilter(RedemptionResultCode, '=%1', '200');

        // Create a new coupon
        LogEntry.SetFilter(CouponResultCode, '=%1', '');
        if (LogEntry.FindLast()) then begin
            CouponType := CityCardLocation.CouponType;
            if (CityCardLocation.CouponSelection = CityCardLocation.CouponSelection::ITEM) then begin
                if (not CityCardItems.Get(CityCode, LocationCode, LogEntry.ArticleId)) then begin
                    Result.ReadFrom(StrSubstNo(_ErrorJsonLabel, 5300, StrSubstNo(ArticleNotFound, LogEntry.ArticleId, CityCode)));
                    exit;
                end;
                CouponType := CityCardItems.CouponType;
            end;

            if (CouponType = '') then begin
                Result.ReadFrom(StrSubstNo(_ErrorJsonLabel, 5301, StrSubstNo(CouponTypeNotFound, CityCode, LocationCode, LogEntry.ArticleId)));
                exit;
            end;

            // Create a new coupon
            IssueCoupon(CouponType, CouponNo, CouponReferenceNo, LogEntry.ValidTimeSpan);
            Result.ReadFrom(StrSubstNo('{"state": {"code": 200, "message": "Coupon acquired"}, "coupon": {"type": "%1", "no": "%2", "reference_no": "%3", "sales_document_no": "%4"}}', CityCardLocation.CouponType, CouponNo, CouponReferenceNo, SalesDocumentNo));
            UpdateLogCoupon(LogEntry.EntryNo, Result);
            exit;
        end;

        // Reattempting same city card multiple times
        // Note that coupon application will fail if the coupon is already used.
        LogEntry.SetFilter(CouponResultCode, '=%1', '200');
        if (LogEntry.FindLast()) then begin
            Result.ReadFrom(StrSubstNo('{"state": {"code": 200, "message": "Attempt coupon reuse"}, "coupon": {"type": "%1", "no": "%2", "reference_no": "%3", "sales_document_no": "%4"}}', LogEntry.CouponType, LogEntry.CouponNo, LogEntry.CouponReferenceNo, SalesDocumentNo));
            LogEntry.Reset();
            LogEntry.SetCurrentKey(CardNumber, CityCode, LocationCode);
            LogEntry.SetFilter(CardNumber, '=%1', CardNumber);
            LogEntry.SetFilter(CityCode, '=%1', CityCode);
            LogEntry.SetFilter(LocationCode, '=%1', LocationCode);
            LogEntry.SetFilter(ValidationResultCode, '=%1', '523'); // City Card already redeemed
            LogEntry.SetFilter(CouponResultCode, '=%1', '');
            if (LogEntry.FindLast()) then begin
                UpdateLogCoupon(LogEntry.EntryNo, Result);
                exit
            end;
        end;

        LogEntry.Reset();
        LogEntry.SetCurrentKey(CardNumber, CityCode, LocationCode);
        LogEntry.SetFilter(CardNumber, '=%1', CardNumber);
        LogEntry.SetFilter(CityCode, '=%1', CityCode);
        LogEntry.SetFilter(LocationCode, '=%1', LocationCode);
        if (not LogEntry.FindLast()) then begin
            Result.ReadFrom(StrSubstNo(_ErrorJsonLabel, 5302, StrSubstNo(GeneralError, CardNumber)));
            exit;
        end;

        if (LogEntry.ValidationResultCode <> '200') then begin
            Result.ReadFrom(StrSubstNo(_ErrorJsonLabel, 5303, StrSubstNo(GeneralError, CardNumber)));
            UpdateLogCoupon(LogEntry.EntryNo, Result);
            Result.ReadFrom(StrSubstNo(_ErrorJsonLabel, 5304, LogEntry.ValidationResultMessage));
            exit;
        end;

        Result.ReadFrom(StrSubstNo(_ErrorJsonLabel, 5305, StrSubstNo(GeneralError, CardNumber)));
    end;

    local procedure IssueCoupon(CouponTypeCode: Code[20]; var CouponNo: Code[20]; var CouponReferenceNo: Text[50]; ValidTimeSpanHours: Integer)
    var
        CouponType: Record "NPR NpDc Coupon Type";
        Coupon: Record "NPR NpDc Coupon";
        CouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
    begin

        CouponType.Get(CouponTypeCode);

        Coupon.Init();
        Coupon.Validate("Coupon Type", CouponTypeCode);
        Coupon."No." := '';
        Coupon."Starting Date" := CreateDateTime(Today(), 0T);
        Coupon."Ending Date" := CreateDateTime(DT2Date(Coupon."Starting Date" + ValidTimeSpanHours * 3600 * 1000), 235959T);
        Coupon.Insert(true);
        CouponMgt.PostIssueCoupon(Coupon);

        if (CouponType."Print on Issue") then
            CouponMgt.PrintCoupon(Coupon);

        CouponNo := Coupon."No.";
        CouponReferenceNo := Coupon."Reference No.";
    end;


    local procedure ValidateSetup(CardNumber: Code[20]; CityCode: Code[10]; LocationCode: Code[10]; var Result: JsonObject): Boolean
    var
        CityCardLocation: Record "NPR DocLXCityCardLocation";
        CityCardSetup: Record "NPR DocLXCityCardSetup";
        CardNumberRequired: Label 'Card number is required';
        CityCardSetupNotFound: Label 'City Card setup not found for city: %1';
        CityCardCityNotActivated: Label 'City Card city setup is not activated';
        InvalidLocationCode: Label 'Invalid location code: %1';
        InvalidLocationId: Label 'Invalid location id for location code %1';
        CouponTypeNotFound: Label 'Coupon type is required for city %1, location %2';
    begin
        if (CardNumber = '') then begin
            Result.ReadFrom(StrSubstNo(_ErrorJsonLabel, 5400, CardNumberRequired));
            exit(false);
        end;

        if (not CityCardSetup.Get(CityCode)) then begin
            Result.ReadFrom(StrSubstNo(_ErrorJsonLabel, 5401, StrSubstNo(CityCardSetupNotFound, CityCode)));
            exit(false);
        end;

        if (CityCardSetup.City = CityCardSetup.City::NOT_SELECTED) then begin
            Result.ReadFrom(StrSubstNo(_ErrorJsonLabel, 5402, CityCardCityNotActivated));
            exit(false);
        end;

        if (not CityCardLocation.Get(CityCode, LocationCode)) then begin
            Result.ReadFrom(StrSubstNo(_ErrorJsonLabel, 5403, StrSubstNo(InvalidLocationCode, LocationCode)));
            exit(false);
        end;

        if (CityCardLocation.CityCardLocationId = 0) then begin
            Result.ReadFrom(StrSubstNo(_ErrorJsonLabel, 5405, StrSubstNo(InvalidLocationId, LocationCode)));
            exit(false);
        end;

        if (CityCardLocation.CouponSelection = CityCardLocation.CouponSelection::LOCATION) then begin
            if (CityCardLocation.CouponType = '') then begin
                Result.ReadFrom(StrSubstNo(_ErrorJsonLabel, 5406, StrSubstNo(CouponTypeNotFound, CityCode, LocationCode)));
                exit(false);
            end;
        end;

        exit(true);
    end;

    local procedure CreateValidationLog(CardNumber: Code[20]; CityCode: Code[10]; LocationCode: Code[10]; PosUnitNo: Code[10]): Integer
    var
        LogEntry: Record "NPR DocLXCityCardHistory";
        TypeHelper: Codeunit "Type Helper";
    begin

        LogEntry.Init();
        LogEntry.EntryNo := 0;
        LogEntry.CardNumber := CardNumber;
        LogEntry.CityCode := CityCode;
        LogEntry.LocationCode := LocationCode;
        LogEntry.PosUnitNo := PosUnitNo;
        LogEntry.ValidatedAtDateTime := CurrentDateTime();
        LogEntry.ValidatedAtDateTimeUtc := Format(TypeHelper.GetCurrUTCDateTime(), 0, 9);
        LogEntry.Insert(true);

        exit(LogEntry.EntryNo);
    end;

    local procedure UpdateLogValidate(EntryNo: Integer; var Result: JsonObject)
    var
        LogEntry: Record "NPR DocLXCityCardHistory";
        State, DataToken : JsonToken;
        DataObject: JsonObject;
    begin
        LogEntry.Get(EntryNo);

        if (Result.Get('state', State)) then begin
            LogEntry.ValidationResultCode := CopyStr(Get(State.AsObject(), 'code').AsCode(), 1, MaxStrLen(LogEntry.ValidationResultCode));
            LogEntry.ValidationResultMessage := CopyStr(Get(State.AsObject(), 'message').AsText(), 1, MaxStrLen(LogEntry.ValidationResultMessage));
        end;

        if (Result.Get('data', DataToken)) then begin
            DataObject := DataToken.AsObject();
            LogEntry.ArticleName := CopyStr(Get(DataObject, 'article_name').AsText(), 1, MaxStrLen(LogEntry.ArticleName));
            LogEntry.ArticleId := CopyStr(Get(DataObject, 'article_id').AsText(), 1, MaxStrLen(LogEntry.ArticleId));
            LogEntry.ShopKey := CopyStr(Get(DataObject, 'shop_key').AsCode(), 1, MaxStrLen(LogEntry.ShopKey));
            LogEntry.CategoryName := CopyStr(Get(DataObject, 'category_name').AsText(), 1, MaxStrLen(LogEntry.CategoryName));
            LogEntry.ActivationDate := CopyStr(Get(DataObject, 'activation_date').AsText(), 1, MaxStrLen(LogEntry.ActivationDate));
            LogEntry.ValidUntilDate := CopyStr(Get(DataObject, 'valid_until').AsText(), 1, MaxStrLen(LogEntry.ValidUntilDate));
            LogEntry.ValidTimeSpan := Get(DataObject, 'valid_time_span').AsInteger();
        end;
        LogEntry.Modify();

    end;

    local procedure UpdateLogRedemption(EntryNo: Integer; var Result: JsonObject)
    var
        LogEntry: Record "NPR DocLXCityCardHistory";
        StateToken: JsonToken;
    begin
        LogEntry.Get(EntryNo);

        if (Result.Get('state', StateToken)) then begin
            LogEntry.RedemptionResultCode := CopyStr(Get(StateToken.AsObject(), 'code').AsCode(), 1, MaxStrLen(LogEntry.RedemptionResultCode));
            LogEntry.RedemptionResultMessage := CopyStr(Get(StateToken.AsObject(), 'message').AsText(), 1, MaxStrLen(LogEntry.RedemptionResultMessage));
            LogEntry.RedeemedAtDateTime := CurrentDateTime();
        end;
        LogEntry.Modify();
    end;

    local procedure UpdateLogCoupon(EntryNo: Integer; var Result: JsonObject)
    var
        LogEntry: Record "NPR DocLXCityCardHistory";
        StateToken, CouponToken : JsonToken;
        DataObject: JsonObject;
    begin
        LogEntry.Get(EntryNo);

        if (Result.Get('state', StateToken)) then begin
            LogEntry.CouponResultCode := CopyStr(Get(StateToken.AsObject(), 'code').AsCode(), 1, MaxStrLen(LogEntry.CouponResultCode));
            LogEntry.CouponResultMessage := CopyStr(Get(StateToken.AsObject(), 'message').AsText(), 1, MaxStrLen(LogEntry.CouponResultMessage));
        end;

        if (Result.Get('coupon', CouponToken)) then begin
            DataObject := CouponToken.AsObject();
            LogEntry.CouponType := CopyStr(Get(DataObject, 'type').AsCode(), 1, MaxStrLen(LogEntry.CouponType));
            LogEntry.CouponNo := CopyStr(Get(DataObject, 'no').AsText(), 1, MaxStrLen(LogEntry.CouponNo));
            LogEntry.CouponReferenceNo := CopyStr(Get(DataObject, 'reference_no').AsText(), 1, MaxStrLen(LogEntry.CouponReferenceNo));
            LogEntry.SalesDocumentNo := CopyStr(Get(DataObject, 'sales_document_no').AsCode(), 1, MaxStrLen(LogEntry.SalesDocumentNo));
        end;
        LogEntry.Modify();
    end;


    internal procedure AppendArticlesFromCityCard(CityCode: Code[10]; LocationCode: Code[10])
    var
        Articles: JsonObject;
    begin
        Articles := GetArticles(CityCode);
        AppendArticles(CityCode, LocationCode, Articles);
    end;

    local procedure GetArticles(CityCode: Code[10]) Result: JsonObject
    var
        FailedFetchArticle: Label 'Failed to get articles from City Card Solution';
    begin
        if (not SendGetRequest(GetArticleEndpoint(CityCode), Result)) then
            Error(FailedFetchArticle);
    end;

    local procedure AppendArticles(CityCode: Code[10]; LocationCode: Code[10]; Articles: JsonObject)
    var
        Article: Record "NPR DocLXCityCardItem";
        ResultToken, ArticleToken, CategoryToken : JsonToken;
        ArticleObject: JsonObject;
    begin
        if (not Articles.Get('result', ResultToken)) then
            exit;

        foreach ArticleToken in ResultToken.AsArray() do begin
            ArticleObject := ArticleToken.AsObject();

            if (not Article.Get(CityCode, LocationCode, CopyStr(Get(ArticleObject, 'id').AsCode(), 1, MaxStrLen(Article.ArticleId)))) then begin
                Article.Init();
                Article.CityCode := CityCode;
                Article.LocationCode := LocationCode;
                Article.ArticleId := CopyStr(Get(ArticleObject, 'id').AsCode(), 1, MaxStrLen(Article.ArticleId));
                Article.Insert();
            end;

            Article.ArticleName := CopyStr(Get(ArticleObject, 'title').AsText(), 1, MaxStrLen(Article.ArticleName));
            Article.ShopKey := CopyStr(Get(ArticleObject, 'shop_key').AsCode(), 1, MaxStrLen(Article.ShopKey));
            Article.ValidTimeSpan := Get(ArticleObject, 'validationTime').AsInteger();
            if (ArticleObject.Get('category', CategoryToken)) then
                Article.CategoryName := CopyStr(Get(CategoryToken.AsObject(), 'description').AsText(), 1, MaxStrLen(Article.CategoryName));

            Article.Modify();
        end;
    end;

    local procedure Get(Obj: JsonObject; KeyName: Text): JsonValue
    var
        JToken: JsonToken;
    begin
        if (Obj.Get(KeyName, JToken)) then
            exit(JToken.AsValue());
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure ValidateCard(CardNumber: Code[20]; CityCode: Code[10]; LocationId: Integer; var Result: JsonObject)
    var
        MessageBody: JsonObject;
        ProxyUrl: Text;
        CityCardHostName: Text;
        CipherKey: Text;
        ValidationPath: Text;
        PayloadText: Text;
    begin
        GetValidationEndpointAndKeys(CityCode, ProxyUrl, CityCardHostName, ValidationPath, CipherKey);

        MessageBody.Add('function', 'validateCard');
        MessageBody.Add('cardId', CardNumber);
        MessageBody.Add('admissionId', LocationId);
        MessageBody.Add('clientSecret', CipherKey); // The cipher key is used to encrypt the message and should be kept secret on City Card Solution request
        MessageBody.Add('hostname', CityCardHostName);
        MessageBody.Add('path', ValidationPath);
        MessageBody.WriteTo(PayloadText);

        SendProxyRequest(ProxyUrl, PayloadText, Result);
    end;


    [TryFunction]
    [NonDebuggable]
    local procedure RedeemCard(CardNumber: Code[20]; CityCode: Code[10]; LocationId: Integer; ValidationTimeUtc: Text[30]; PosUnitNo: Code[20]; var Result: JsonObject)
    var
        MessageBody: JsonObject;
        ProxyUrl: Text;
        CityCardHostName: Text;
        CipherKey: Text;
        RedeemPath: Text;
        PayloadText: Text;
    begin
        GetRedemptionEndpointAndKeys(CityCode, ProxyUrl, CityCardHostName, RedeemPath, CipherKey);

        MessageBody.Add('function', 'redeemCard');
        MessageBody.Add('cardId', CardNumber);
        MessageBody.Add('admissionId', LocationId);
        MessageBody.Add('dateTime', ValidationTimeUtc);
        MessageBody.Add('deviceId', PosUnitNo);
        MessageBody.Add('clientSecret', CipherKey); // The cipher key is used to encrypt the message and should be kept secret on City Card Solution request
        MessageBody.Add('hostname', CityCardHostName);
        MessageBody.Add('path', RedeemPath);
        MessageBody.WriteTo(PayloadText);

        SendProxyRequest(ProxyUrl, PayloadText, Result);
    end;

    internal procedure CheckServiceHealth(CityCode: Code[10]; var StateCode: Code[10]; var StateMessage: Text)
    var
        Result: JsonObject;
        State: JsonToken;
        RequestInfo: JsonToken;
    begin
        Result := CheckServiceHealth(CityCode);

        if (Result.Get('state', State)) then begin
            Result.Get('request', RequestInfo);
            StateCode := CopyStr(Get(State.AsObject(), 'code').AsCode(), 1, MaxStrLen(StateCode));
            StateMessage := StrSubstNo('Response from: %1 via %2 was %3',
                Get(RequestInfo.AsObject(), 'hostname').AsText(),
                Get(RequestInfo.AsObject(), 'helloUrl').AsText(),
                Get(State.AsObject(), 'message').AsText()
            );
        end;
    end;

    internal procedure CheckServiceHealth(CityCode: Code[10]) Result: JsonObject
    var
        MessageBody: JsonObject;
        HelloUrl: Text;
        CityCardHostName: Text;
        Path: Text;
        PayloadText: Text;
    begin

        GetHelloEndpointAndKeys(CityCode, HelloUrl, CityCardHostName, Path);

        MessageBody.Add('hostname', CityCardHostName);
        MessageBody.Add('path', Path);
        MessageBody.WriteTo(PayloadText);

        SendProxyRequest(HelloUrl, PayloadText, Result);

        MessageBody.Add('helloUrl', HelloUrl);
        Result.Add('request', MessageBody);

    end;

    [NonDebuggable]
    local procedure SendProxyRequest(ProxyUrl: Text; PayloadText: Text; var Result: JsonObject)
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
        ContentHeader: HttpHeaders;
        Content: HttpContent;
        ResponseText: Text;
    begin

        Content.WriteFrom(PayloadText);
        Content.GetHeaders(ContentHeader);

        ContentHeader.Clear();
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'application/json; charset=utf-8');

        Request.GetHeaders(Headers);
        Headers.Add('Accept', '*/*');

        Request.Method('POST');
        Request.SetRequestUri(ProxyUrl);
        Request.Content(Content);

        Client.Timeout(15000);
        if (not Client.Send(Request, Response)) then
            Error(GetLastErrorText());

        if (not Response.IsSuccessStatusCode()) then
            Error('%1 - %2', Response.HttpStatusCode, Response.ReasonPhrase);

        Response.Content.ReadAs(ResponseText);
        if (not Result.ReadFrom(ResponseText)) then
            Error('Invalid response from City Card Solution: %1', ResponseText);

    end;

    [TryFunction]
    local procedure SendGetRequest(Url: Text; var Result: JsonObject)
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
        ResponseText: Text;
    begin

        Request.GetHeaders(Headers);
        Headers.Add('Accept', '*/*');

        Request.Method('GET');
        Request.SetRequestUri(Url);

        Client.Timeout(15000);
        if (not Client.Send(Request, Response)) then
            Error(GetLastErrorText());

        if (not Response.IsSuccessStatusCode()) then
            Error('%1 - %2', Response.HttpStatusCode, Response.ReasonPhrase);

        Response.Content.ReadAs(ResponseText);
        if (not Result.ReadFrom(ResponseText)) then
            Error('Invalid response from City Card Solution: %1', ResponseText);

    end;

    [NonDebuggable]
    local procedure GetArticleEndpoint(CityCode: Code[10]) ArticleUrl: Text
    var
        CityName: Text;
        EnvironmentName: Text;
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        ArticleRestEndpoint: Label 'DocLXCityCard%1%2Article', Locked = true, Comment = 'The key name in Azure Key Vault for the validation endpoint, 1=CityName, 2=Environment';
    begin
        if (not GetSetup(CityCode, CityName, EnvironmentName)) then
            Error('City Card setup not found or not valid for city: %1', CityCode);

        // https://api.copenhagen.citycardsolutions.com/v1.1/article/mobileList/EN?passkey=80ca508e25d506f810440f58050d00a400b64e91e9bc1289ebc310fe161dd61e
        ArticleUrl := AzureKeyVaultMgt.GetAzureKeyVaultSecret(StrSubstNo(ArticleRestEndpoint, CityName, EnvironmentName));
    end;


    [NonDebuggable]
    local procedure GetHelloEndpointAndKeys(
        CityCode: Code[10];
        var HelloUrl: Text;
        var CityCardHostName: Text;
        var CityCardValidatePath: Text)
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        CityName: Text;
        EnvironmentName: Text;
        HostKeyName: Label 'DocLXCityCard%1%2Host', Locked = true, Comment = 'The key name in Azure Key Vault for the validation endpoint, 1=CityName, 2=Environment';
    begin
        if (not GetSetup(CityCode, CityName, EnvironmentName)) then
            Error('City Card setup not found or not valid for city: %1', CityCode);

        // https://npdoclxcitycardapi.azurewebsites.net/api/hello?code=CK1D15x70aFgCG_ZoAx4jvSLfgMLHHkoMBFDtrYgBQcdAzFuWTfhpA==
        HelloUrl := AzureKeyVaultMgt.GetAzureKeyVaultSecret('DocLXCityCardHelloUrl');

        // api.copenhagen.citycardsolutions.com
        CityCardHostName := AzureKeyVaultMgt.GetAzureKeyVaultSecret(StrSubstNo(HostKeyName, CityName, EnvironmentName));
        CityCardValidatePath := '/v1.1/coupon/validate/';
    end;

    [NonDebuggable]
    local procedure GetValidationEndpointAndKeys(
        CityCode: Code[10];
        var ProxyUrl: Text;
        var CityCardHostName: Text;
        var CityCardValidatePath: Text;
        var CityCardCipherKey: Text)
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        CityName: Text;
        EnvironmentName: Text;
        HostKeyName: Label 'DocLXCityCard%1%2Host', Locked = true, Comment = 'The key name in Azure Key Vault for the validation endpoint, 1=CityName, 2=Environment';
        CipherKeyName: Label 'DocLXCityCard%1%2CipherKey', Locked = true, Comment = 'The key name in Azure Key Vault for the cipher key, 1=CityName, 2=Environment';
    begin
        if (not GetSetup(CityCode, CityName, EnvironmentName)) then
            Error('City Card setup not found or not valid for city: %1', CityCode);

        // https://npdoclxcitycardapi.azurewebsites.net/api/cityCard?code=VxwU2MIlZlULkvMF2ugheeM27BvARbJWXtscRdaEE2d6AzFuvIGYBQ==
        ProxyUrl := AzureKeyVaultMgt.GetAzureKeyVaultSecret('DocLXCityCardProxyUrl');

        // api.copenhagen.citycardsolutions.com
        CityCardHostName := AzureKeyVaultMgt.GetAzureKeyVaultSecret(StrSubstNo(HostKeyName, CityName, EnvironmentName));
        CityCardCipherKey := AzureKeyVaultMgt.GetAzureKeyVaultSecret(StrSubstNo(CipherKeyName, CityName, EnvironmentName));

        CityCardValidatePath := '/v1.1/coupon/validate/';
    end;

    [NonDebuggable]
    local procedure GetRedemptionEndpointAndKeys(
        CityCode: Code[10];
        var ProxyUrl: Text;
        var CityCardHostName: Text;
        var CityCardRedeemPath: Text;
        var CityCardCipherKey: Text)
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        CityName: Text;
        EnvironmentName: Text;
        HostKeyName: Label 'DocLXCityCard%1%2Host', Locked = true, Comment = 'The key name in Azure Key Vault for the validation endpoint, 1=CityName, 2=Environment';
        CipherKeyName: Label 'DocLXCityCard%1%2CipherKey', Locked = true, Comment = 'The key name in Azure Key Vault for the cipher key, 1=CityName, 2=Environment';
    begin
        if (not GetSetup(CityCode, CityName, EnvironmentName)) then
            Error('City Card setup not found or not valid for city: %1', CityCode);

        // https://npdoclxcitycardapi.azurewebsites.net/api/cityCard?code=VxwU2MIlZlULkvMF2ugheeM27BvARbJWXtscRdaEE2d6AzFuvIGYBQ==
        ProxyUrl := AzureKeyVaultMgt.GetAzureKeyVaultSecret('DocLXCityCardProxyUrl');

        // api.copenhagen.citycardsolutions.com
        CityCardHostName := AzureKeyVaultMgt.GetAzureKeyVaultSecret(StrSubstNo(HostKeyName, CityName, EnvironmentName));
        CityCardCipherKey := AzureKeyVaultMgt.GetAzureKeyVaultSecret(StrSubstNo(CipherKeyName, CityName, EnvironmentName));

        CityCardRedeemPath := '/v1.1/coupon/redeem/';
    end;

    local procedure GetSetup(CityCode: Code[10]; var CityName: Text; var EnvironmentName: Text): Boolean
    var
        CityCardSetup: Record "NPR DocLXCityCardSetup";
    begin
        if not CityCardSetup.Get(CityCode) then
            exit;

        if (CityCardSetup.City = CityCardSetup.City::NOT_SELECTED) then
            exit;

        // Set the city name based on the selected city - must not be translated
        case CityCardSetup.City of
            CityCardSetup.City::COPENHAGEN:
                CityName := 'Copenhagen';
            CityCardSetup.City::OSLO:
                CityName := 'Oslo';
            else
                exit;
        end;

        // Set the environment - must not be translated
        case CityCardSetup.Environment of
            CityCardSetup.Environment::DEMO:
                EnvironmentName := 'Demo';
            CityCardSetup.Environment::PRODUCTION:
                EnvironmentName := 'Prod';
            else
                exit
        end;

        exit(true);
    end;

    local procedure StripQuotes(Text: Text): Text
    begin
        exit(Text.Replace('"', ''''));
    end;

}