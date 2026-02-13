codeunit 6150743 "NPR MMMembershipRestApi"
{
    Access = Internal;
    // Currently no api endpoint for request member update
    // internal procedure RequestMemberUpdateWorker(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; CardNumber: Text[100]; var NotValidReason: Text): Boolean
    // begin
    // end;

    internal procedure ValidateRemoteCardNumber(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; Prefix: Code[10]; ForeignMemberCardNumber: Text[100]; var RemoteInfoCapture: Record "NPR MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        Request: JsonObject;
        WebResponse: HttpResponseMessage;
    begin
        NPRRemoteEndpointSetup.TestField("Rest Api Endpoint URI");
        WebServiceApi(NPRRemoteEndpointSetup, 'GET', StrSubstNo('/membership/card?cardNumber=%1&withDetails=true', ForeignMemberCardNumber), "NPR MMMembershipRestApiCache"::MemberCardNumberDetails, NotValidReason, Request, WebResponse);
        if WebResponse.HttpStatusCode() in [200, 400] then
            IsValid := MemberCardNumberValidationResponse(Prefix, ForeignMemberCardNumber, WebResponse, NotValidReason, RemoteInfoCapture)
        else
            IsValid := false;

        if (not IsValid) then
            if (NotValidReason = '') then
                NotValidReason := EndpointCardValidationError(NPRRemoteEndpointSetup, '/membership/card', ForeignMemberCardNumber);
        exit(IsValid);

    end;

    internal procedure GetRemoteMembership(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; Prefix: Code[10]; ForeignMemberCardNumber: Text[100]; var ForeignMembershipNumber: Code[20]; var RemoteInfoCapture: Record "NPR MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        Response: JsonObject;
    begin
        if not GetRemoteCardWithDetails(NPRRemoteEndpointSetup, ForeignMemberCardNumber, NotValidReason, Response) then
            exit(false);
        IsValid := ValidateMembershipResponse(Prefix, ForeignMembershipNumber, Response, RemoteInfoCapture);
        if (StrLen(RemoteInfoCapture."External Card No.") >= 4) then
#pragma warning disable AA0139
            RemoteInfoCapture."External Card No. Last 4" := CopyStr(RemoteInfoCapture."External Card No.", StrLen(RemoteInfoCapture."External Card No.") - 4 + 1);
#pragma warning restore AA0139
        exit(IsValid);
    end;

    internal procedure GetRemoteMember(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; Prefix: Code[10]; ForeignMemberCardNumber: Text[100]; ForeignMembershipNumber: Code[20]; IncludeMemberImage: Boolean; var RemoteInfoCapture: Record "NPR MM Member Info Capture"; var TempRequestMemberFieldUpdate: Record "NPR MM Request Member Update" temporary; var NotValidReason: Text) IsValid: Boolean
    var
        Response: JsonObject;
    begin
        if not GetRemoteCardWithDetails(NPRRemoteEndpointSetup, ForeignMemberCardNumber, NotValidReason, Response) then
            exit(false);
        IsValid := ValidateMemberResponse(NPRRemoteEndpointSetup, Prefix, ForeignMembershipNumber, IncludeMemberImage, Response, RemoteInfoCapture);
        exit(IsValid);
    end;

    internal procedure UpdateLocalMembershipPoints(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; MembershipEntryNo: Integer; ForeignMemberCardNumber: Text[100]; var NotValidReason: Text) IsValid: Boolean
    var
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        Request, Response : JsonObject;
        MembershipId: Guid;
        PointBalance: Integer;
    begin
        if (MembershipEntryNo = 0) then
            exit(false);

        MembershipId := GetExternalMembershipIdForRemoteCard(NPRRemoteEndpointSetup, ForeignMemberCardNumber);
        if IsNullGuid(MembershipId) then begin
            NotValidReason := EndpointCardValidationError(NPRRemoteEndpointSetup, '/membership/card', ForeignMemberCardNumber);
            exit(false);
        end;

        if not WebServiceApi(NPRRemoteEndpointSetup, 'GET', StrSubstNo('/membership/%1/points', Format(MembershipId, 0, 4)), "NPR MMMembershipRestApiCache"::LoyaltyPoints, Request, Response) then
            exit(false);
        IsValid := ValidatePointBalanceResponse(Response, PointBalance);
        if IsValid then
            LoyaltyPointManagement.SynchronizePointsAbsolute(MembershipEntryNo, PointBalance, Today);

        exit(IsValid);

    end;

    internal procedure CreateRemoteMembershipWorker(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; var MembershipInfo: Record "NPR MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        Request: JsonObject;
        ResponseMessage: HttpResponseMessage;
        ErrorText: Text;
    begin
        Request := CreateMembershipRequest(MembershipInfo);
        if not WebServiceApi(NPRRemoteEndpointSetup, 'POST', '/membership', NotValidReason, Request, ResponseMessage) then begin
            ErrorText := GetErrorResponseMessage(ResponseMessage);
            if ErrorText <> '' then
                NotValidReason := StrSubstNo('%1\\%2', ErrorText, NotValidReason);
            exit(false);
        end;
        exit(ValidateCreateMembershipResponse(ResponseMessage, MembershipInfo, NotValidReason));
    end;

    internal procedure CreateRemoteMemberWorker(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; var MembershipInfo: Record "NPR MM Member Info Capture"; var NotValidReason: Text) IsValid: Boolean
    var
        Request: JsonObject;
        ResponseMessage: HttpResponseMessage;
        ErrorText: Text;
    begin
        if IsNullGuid(MembershipInfo.ExternalMembershipSystemId) then
            MembershipInfo.ExternalMembershipSystemId := GetExternalMembershipIdFromExternalMembershipNumber(NPRRemoteEndpointSetup, MembershipInfo."External Membership No.");
        if IsNullGuid(MembershipInfo.ExternalMembershipSystemId) then
            exit(false);

        Request := CreateMembershipMemberRequest(MembershipInfo);
        if not WebServiceApi(NPRRemoteEndpointSetup, 'POST', StrSubstNo('/membership/%1/addMember', Format(MembershipInfo.ExternalMembershipSystemId, 0, 4)), NotValidReason, Request, ResponseMessage) then begin
            ErrorText := GetErrorResponseMessage(ResponseMessage);
            if ErrorText <> '' then
                NotValidReason := StrSubstNo('%1\\%2', ErrorText, NotValidReason);
            exit(false);
        end;
        exit(ValidateCreateMembershipMemberResponse(ResponseMessage, MembershipInfo, NotValidReason));
    end;

    internal procedure CreateRemoteAddCardWorker(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; var MembershipInfo: Record "NPR MM Member Info Capture"; ReplaceCard: Boolean; var NotValidReason: Text) IsValid: Boolean
    begin
        if ReplaceCard then
            exit(RemoteReplaceCard(NPRRemoteEndpointSetup, MembershipInfo, NotValidReason))
        else
            exit(RemoteAddCard(NPRRemoteEndpointSetup, MembershipInfo, NotValidReason))

    end;

    // Currently no api endpoint for update member fields
    // internal procedure UpdateMemberFieldWorker(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; var RequestMemberFieldUpdate: Record "NPR MM Request Member Update"; var NotValidReason: Text) IsValid: Boolean
    // var
    // begin
    // end;

    internal procedure SearchMemberWorker(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; var MembershipInfo: Record "NPR MM Member Info Capture"; var TmpSearchResult: Record "NPR MM Member Info Capture" temporary; var NotValidReason: Text) IsValid: Boolean
    var
        Request, Response : JsonObject;
        ErrorResponseLbl: Label 'Error response from %1 endpoint %2: %3', Comment = '%1 = api url, %2 = Endpoint, %3 = Error message';
    begin
        if not WebServiceApi(NPRRemoteEndpointSetup, 'GET', '/membership/member?' + MakeMemberSearchQuery(MembershipInfo), Request, Response) then begin
            NotValidReason := StrSubstNo(ErrorResponseLbl, NPRRemoteEndpointSetup."Rest Api Endpoint URI", '/membership/member', GetErrorMessage(Response));
            exit(false);
        end;
        exit(ValidateMemberSearchResponse(Response, TmpSearchResult, NotValidReason));
    end;

    procedure TestEndpointConnection(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"): Text
    var
        ReasonText: Text;
        Request: JsonObject;
        WebResponse: HttpResponseMessage;
    begin
        NPRRemoteEndpointSetup.TestField("Rest Api Endpoint URI");
        if not WebServiceApi(NPRRemoteEndpointSetup, 'GET', '/membership/list?pageSize=1', ReasonText, Request, WebResponse) then
            exit(ReasonText);
        exit('Connection OK');
    end;

    internal procedure WebServiceApi(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; HttpMethod: Text; Path: Text; var ReasonText: Text; var Request: JsonObject; var WebResponse: HttpResponseMessage): Boolean
    begin
        exit(WebServiceApi(NPRRemoteEndpointSetup, HttpMethod, Path, "NPR MMMembershipRestApiCache"::NoCache, ReasonText, Request, WebResponse));
    end;

    internal procedure WebServiceApi(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; HttpMethod: Text; Path: Text; CacheType: Enum "NPR MMMembershipRestApiCache"; var ReasonText: Text; var Request: JsonObject; var WebResponse: HttpResponseMessage): Boolean
    begin
        ReasonText := '';
        if (TryWebServiceApi(NPRRemoteEndpointSetup, HttpMethod, Path, CacheType, ReasonText, Request, WebResponse)) then
            exit(true);

        if (ReasonText = '') then
            ReasonText := GetLastErrorText();
        exit(false);
    end;

    internal procedure WebServiceApi(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; HttpMethod: Text; Path: Text; var Request: JsonObject; var Response: JsonObject): Boolean
    begin
        exit(WebServiceApi(NPRRemoteEndpointSetup, HttpMethod, Path, "NPR MMMembershipRestApiCache"::NoCache, Request, Response));
    end;

    internal procedure WebServiceApi(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; HttpMethod: Text; Path: Text; CacheType: Enum "NPR MMMembershipRestApiCache"; var Request: JsonObject; var Response: JsonObject): Boolean
    var
        ResponseMessage: HttpResponseMessage;
        ReasonText: Text;
        Success: Boolean;
    begin
        Success := TryWebServiceApi(NPRRemoteEndpointSetup, HttpMethod, Path, CacheType, ReasonText, Request, ResponseMessage);
        GetResponseBody(ResponseMessage, Response);
        exit(Success);
    end;

    [TryFunction]
    internal procedure TryWebServiceApi(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; HttpMethod: Text; Path: Text; CacheType: Enum "NPR MMMembershipRestApiCache"; var ReasonText: Text; var Request: JsonObject; var WebResponse: HttpResponseMessage)
    var
        MembershipRestApiCache: Codeunit "NPR MMMembershipRestApiCache";
        Sentry: Codeunit "NPR Sentry";
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        WebRequest: HttpRequestMessage;
        WebClient: HttpClient;
        [NonDebuggable]
        Headers: HttpHeaders;
        RequestText: Text;
        Uri: Text;
    begin
        ReasonText := '';
        Request.WriteTo(RequestText);
        RequestContent.WriteFrom(RequestText);
        RequestContent.GetHeaders(ContentHeader);
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'application/json');
        if IsCraneUrl(NPRRemoteEndpointSetup."Rest Api Endpoint URI") then
            ContentHeader.Add('x-npr-api-remote-type', 'crane');

        WebRequest.Content(RequestContent);
        WebRequest.GetHeaders(Headers);

        WebRequest.Method := HttpMethod;
        Uri := NPRRemoteEndpointSetup."Rest Api Endpoint URI".TrimEnd('/') + '/' + Path.TrimStart('/');
        WebRequest.SetRequestUri(Uri);
        if not MembershipRestApiCache.GetResponse(CacheType, WebRequest, WebResponse) then begin
            SetRequestHeadersAuthorization(NPRRemoteEndpointSetup, Headers);
            if (NPRRemoteEndpointSetup."Connection Timeout (ms)" < 100) then
                NPRRemoteEndpointSetup."Connection Timeout (ms)" := 10 * 1000;
            WebClient.Timeout := NPRRemoteEndpointSetup."Connection Timeout (ms)";
            Sentry.HttpInvoke(WebClient, WebRequest, WebResponse, false, true);
        end;
        if (WebResponse.IsSuccessStatusCode()) then begin
            MembershipRestApiCache.SetResponse(CacheType, WebRequest, WebResponse);
            exit;
        end;

        ReasonText := StrSubstNo('[%1] (%2) %3: %4', NPRRemoteEndpointSetup.Code, WebResponse.HttpStatusCode(), WebResponse.ReasonPhrase(), Uri);
        Error(ReasonText);
    end;

    internal procedure GetResponseBody(ResponseMessage: HttpResponseMessage; var ResponseBody: JsonObject): Boolean
    var
        ResponseText: Text;
    begin
        if ResponseMessage.Content.ReadAs(ResponseText) then
            if ResponseBody.ReadFrom(ResponseText) then
                exit(true);
        exit(false);
    end;

    internal procedure InvalidResponseError(ResponseMessage: HttpResponseMessage): Text
    var
        ResponseText: Text;
        InvalidResponseLbl: Label 'Invalid response received: %1';
    begin
        if ResponseMessage.Content.ReadAs(ResponseText) then;
        exit(StrSubstNo(InvalidResponseLbl, ResponseText));
    end;

    local procedure SetRequestHeadersAuthorization(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; var RequestHeaders: HttpHeaders)
    var
        AuthParamsBuff: Record "NPR Auth. Param. Buffer";
        iAuth: Interface "NPR API IAuthorization";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        iAuth := NPRRemoteEndpointSetup.AuthType;
        case NPRRemoteEndpointSetup.AuthType of
            NPRRemoteEndpointSetup.AuthType::Basic:
                WebServiceAuthHelper.GetBasicAuthorizationParamsBuff(NPRRemoteEndpointSetup."User Account", NPRRemoteEndpointSetup."User Password Key", AuthParamsBuff);
            NPRRemoteEndpointSetup.AuthType::OAuth2:
                WebServiceAuthHelper.GetOpenAuthorizationParamsBuff(NPRRemoteEndpointSetup."OAuth2 Setup Code", AuthParamsBuff);
        end;
        iAuth.CheckMandatoryValues(AuthParamsBuff);
        iAuth.SetAuthorizationValue(RequestHeaders, AuthParamsBuff);
    end;

    local procedure IsCraneUrl(RestApiEndpointURI: Text[200]): Boolean
    var
        BaseUrlLbl: Label 'api.npretail.app/';
        Position: Integer;
        TestValue: Text;
        GuidValue: Guid;
    begin
        Position := StrPos(RestApiEndpointURI.ToLower(), BaseUrlLbl);
        if Position = 0 then
            exit(false);
#pragma warning disable AA0139
        RestApiEndpointURI := CopyStr(RestApiEndpointURI, Position + StrLen(BaseUrlLbl));
#pragma warning restore AA0139
        if not RestApiEndpointURI.Split('/').Get(1, TestValue) then
            exit(false);
        Exit(not Evaluate(GuidValue, TestValue));
    end;

    local procedure MemberCardNumberValidationResponse(Prefix: Code[10]; ForeignMemberCardNumber: Text[100]; WebResponse: HttpResponseMessage; var NotValidReason: Text; var RemoteInfoCapture: Record "NPR MM Member Info Capture"): Boolean
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Response: JsonObject;
        ResponseText: Text;
        CardBlocked: Boolean;
        InvalidResponseLbl: Label 'Invalid response received: %1';
    begin
        NotValidReason := '';
        if WebResponse.IsSuccessStatusCode() then begin
            WebResponse.Content.ReadAs(ResponseText);
            Response.ReadFrom(ResponseText);
            if not Response.Contains('card') then begin
                NotValidReason := StrSubstNo(InvalidResponseLbl, ResponseText);
                exit(false);
            end;
            //Blocked cards was not returned in soap ws
            CardBlocked := JsonHelper.GetJBoolean(Response.AsToken(), 'card.blocked', false);
            if CardBlocked then
                NotValidReason := '';
            if Evaluate(RemoteInfoCapture.ExternalCardSystemId, JsonHelper.GetJText(Response.AsToken(), 'card.cardId', false)) then;
            if Evaluate(RemoteInfoCapture.ExternalMembershipSystemId, JsonHelper.GetJText(Response.AsToken(), 'card.membership.membershipId', false)) then;
            if Evaluate(RemoteInfoCapture.ExternalMemberSystemId, JsonHelper.GetJText(Response.AsToken(), 'card.member.memberId', false)) then;
        end;
#pragma warning disable AA0139
        RemoteInfoCapture."External Card No." := Prefix + ForeignMemberCardNumber;
        if (StrLen(ForeignMemberCardNumber) >= 4) then
            RemoteInfoCapture."External Card No. Last 4" := CopyStr(ForeignMemberCardNumber, StrLen(ForeignMemberCardNumber) - 4 + 1);
#pragma warning restore AA0139
        exit(WebResponse.IsSuccessStatusCode() and (not CardBlocked));
    end;

    local procedure GetExternalIdForRemoteCard(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; ForeignMemberCardNumber: Text[100]): Guid
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Request: JsonObject;
        Response: JsonObject;
        ExternalCardId: Guid;
    begin
        NPRRemoteEndpointSetup.TestField("Rest Api Endpoint URI");
        if not WebServiceApi(NPRRemoteEndpointSetup, 'GET', StrSubstNo('/membership/card?cardNumber=%1', ForeignMemberCardNumber), "NPR MMMembershipRestApiCache"::MemberCardNumber, Request, Response) then
            exit(ExternalCardId);
        if JsonHelper.GetJBoolean(Response.AsToken(), 'card.blocked', false) then
            exit(ExternalCardId);
        if Evaluate(ExternalCardId, JsonHelper.GetJText(Response.AsToken(), 'card.cardId', false)) then;
        exit(ExternalCardId);
    end;

    local procedure GetExternalMembershipIdForRemoteCard(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; ForeignMemberCardNumber: Text[100]): Guid
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Request, Response : JsonObject;
        MembershipId: Guid;
    begin
        NPRRemoteEndpointSetup.TestField("Rest Api Endpoint URI");
        if not WebServiceApi(NPRRemoteEndpointSetup, 'GET', StrSubstNo('/membership/card?cardNumber=%1&withDetails=true', ForeignMemberCardNumber), "NPR MMMembershipRestApiCache"::MemberCardNumberDetails, Request, Response) then
            exit(MembershipId);
        if Evaluate(MembershipId, JsonHelper.GetJText(Response.AsToken(), 'card.membership.membershipId', false)) then;
        exit(MembershipId);
    end;

    local procedure GetExternalMembershipIdFromExternalMembershipNumber(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; ExternalMembershipNumber: Text): Guid
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Request, Response : JsonObject;
        MembershipId: Guid;
    begin
        if not WebServiceApi(NPRRemoteEndpointSetup, 'GET', StrSubstNo('/membership?membershipNumber=%1', ExternalMembershipNumber), Request, Response) then
            exit(MembershipId);
        if Evaluate(MembershipId, JsonHelper.GetJText(Response.AsToken(), 'membership.membershipId', false)) then;
        exit(MembershipId);
    end;

    local procedure GetExternalMemberIdFromExternalMemberNumber(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; ExternalMemberNumber: Text): Guid
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Request, Response : JsonObject;
        MembershipId: Guid;
    begin
        if not WebServiceApi(NPRRemoteEndpointSetup, 'GET', StrSubstNo('/membership/member?memberNumber=%1', ExternalMemberNumber), Request, Response) then
            exit(MembershipId);
        if Evaluate(MembershipId, JsonHelper.GetJText(Response.AsToken(), 'members[0].memberId', false)) then;
        exit(MembershipId);
    end;

    internal procedure GetRemoteCardWithDetails(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; ForeignMemberCardNumber: Text[100]; var NotValidReason: Text; var Response: JsonObject): Boolean
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Request: JsonObject;
    begin
        NPRRemoteEndpointSetup.TestField("Rest Api Endpoint URI");
        if not WebServiceApi(NPRRemoteEndpointSetup, 'GET', StrSubstNo('/membership/card?cardNumber=%1&withDetails=true', ForeignMemberCardNumber), "NPR MMMembershipRestApiCache"::MemberCardNumberDetails, Request, Response) then begin
            NotValidReason := EndpointCardValidationError(NPRRemoteEndpointSetup, '/membership/card', ForeignMemberCardNumber);
            exit(false);
        end;
        if JsonHelper.GetJBoolean(Response.AsToken(), 'card.blocked', false) then begin
            NotValidReason := EndpointCardValidationError(NPRRemoteEndpointSetup, '/membership/card', ForeignMemberCardNumber);
            exit(false);
        end;
        exit(true);
    end;

    local procedure EndpointCardValidationError(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; Path: Text; ForeignMemberCardNumber: Text[100]): Text
    var
        MemberCardValidationLbl: Label 'Endpoint %1 could not validate membercard %2.';

    begin
        exit(StrSubstNo(MemberCardValidationLbl, NPRRemoteEndpointSetup."Rest Api Endpoint URI".TrimEnd('/') + Path, ForeignMemberCardNumber));
    end;

    internal procedure InvalidJsonResponseError(Response: JsonObject): Text
    var
        ResponseText: Text;
        InvalidResponseLbl: Label 'Invalid response received: %1';
    begin
        if Response.WriteTo(ResponseText) then;
        exit(StrSubstNo(InvalidResponseLbl, ResponseText));
    end;

    local procedure ValidateMembershipResponse(Prefix: Code[10]; var ForeignMembershipNumber: Code[20]; Response: JsonObject; var RemoteInfoCapture: Record "NPR MM Member Info Capture"): Boolean
    var
        JsonHelper: Codeunit "NPR Json Helper";
    begin
#pragma warning disable AA0139
        RemoteInfoCapture."Membership Code" := Prefix + JsonHelper.GetJText(Response.AsToken(), 'card.membership.membershipCode', false);
        if RemoteInfoCapture."Membership Code" = Prefix then
            exit(false);
        ForeignMembershipNumber := JsonHelper.GetJText(Response.AsToken(), 'card.membership.membershipNumber', true);
        if foreignMembershipNumber = '' then
            exit(false);
        RemoteInfoCapture."External Membership No." := Prefix + ForeignMembershipNumber;
#pragma warning restore AA0139
        if Evaluate(RemoteInfoCapture.ExternalMembershipSystemId, JsonHelper.GetJText(Response.AsToken(), 'card.membership.membershipId', false)) then;
        if Evaluate(RemoteInfoCapture.ExternalMemberSystemId, JsonHelper.GetJText(Response.AsToken(), 'card.member.memberId', false)) then;
        if Evaluate(RemoteInfoCapture.ExternalCardSystemId, JsonHelper.GetJText(Response.AsToken(), 'card.cardId', false)) then;
        exit(true);
    end;

    local procedure ValidateMemberResponse(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; Prefix: Code[10]; ForeignMembershipNumber: Code[20]; IncludeMemberImage: Boolean; Response: JsonObject; var RemoteInfoCapture: Record "NPR MM Member Info Capture"): Boolean
    var
        CountryRegion: Record "Country/Region";
        JsonHelper: Codeunit "NPR Json Helper";
    begin
        if JsonHelper.GetJText(Response.AsToken(), 'card.membership.membershipNumber', true) <> ForeignMembershipNumber then
            exit(false);
#pragma warning disable AA0139
        RemoteInfoCapture."External Member No" := Prefix + JsonHelper.GetJText(Response.AsToken(), 'card.member.memberNumber', true);
        if RemoteInfoCapture."External Member No" = Prefix then
            exit(false);
        RemoteInfoCapture."First Name" := JsonHelper.GetJText(Response.AsToken(), 'card.member.firstName', false);
        RemoteInfoCapture."Middle Name" := JsonHelper.GetJText(Response.AsToken(), 'card.member.middleName', false);
        RemoteInfoCapture."Last Name" := JsonHelper.GetJText(Response.AsToken(), 'card.member.lastName', false);
        RemoteInfoCapture.Address := JsonHelper.GetJText(Response.AsToken(), 'card.member.address', false);
        RemoteInfoCapture."Post Code Code" := JsonHelper.GetJText(Response.AsToken(), 'card.member.postCode', false);
        RemoteInfoCapture.City := JsonHelper.GetJText(Response.AsToken(), 'card.member.city', false);
        RemoteInfoCapture.Country := JsonHelper.GetJText(Response.AsToken(), 'card.member.country', false);
        CountryRegion.SetRange(Name, RemoteInfoCapture.Country);
        if CountryRegion.FindFirst() then
            RemoteInfoCapture."Country Code" := CountryRegion.Code;

        RemoteInfoCapture.Birthday := JsonHelper.GetJDate(Response.AsToken(), 'card.member.birthday', false);
        RemoteInfoCapture.Gender := GenderAsOption(JsonHelper.GetJText(Response.AsToken(), 'card.member.gender', false));
        RemoteInfoCapture."News Letter" := NewsLetterAsOption(JsonHelper.GetJText(Response.AsToken(), 'card.member.newsletter', false));

        RemoteInfoCapture."Phone No." := JsonHelper.GetJText(Response.AsToken(), 'card.member.phoneNo', false);
        RemoteInfoCapture."E-Mail Address" := JsonHelper.GetJText(Response.AsToken(), 'card.member.email', false);
        RemoteInfoCapture."Store Code" := JsonHelper.GetJText(Response.AsToken(), 'card.member.storeCode', false);
        if Evaluate(RemoteInfoCapture.ExternalCardSystemId, JsonHelper.GetJText(Response.AsToken(), 'card.cardId', false)) then;
#pragma warning restore AA0139
        if IncludeMemberImage then
            if JsonHelper.GetJBoolean(Response.AsToken(), 'card.member.hasPicture', false) then
                GetMemberImage(NPRRemoteEndpointSetup, JsonHelper.GetJText(Response.AsToken(), 'card.member.memberId', false), RemoteInfoCapture);

        exit(true);
    end;

    local procedure ValidatePointBalanceResponse(Response: JsonObject; var PointBalance: Integer): Boolean
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Token: JsonToken;
    begin
        if not JsonHelper.GetJsonToken(Response.AsToken(), 'balance', Token) then
            exit(false);
        if not Token.IsValue() then
            exit(false);
        PointBalance := Token.AsValue().AsInteger();
        exit(true);
    end;

    local procedure CreateMembershipRequest(var MembershipInfo: Record "NPR MM Member Info Capture") RequestBody: JsonObject
    begin
        RequestBody.Add('itemNumber', MembershipInfo."Item No.");
        if (MembershipInfo."Document Date" > 0D) then
            RequestBody.Add('activationDate', Format(MembershipInfo."Document Date", 0, 9));
    end;

    local procedure ValidateCreateMembershipResponse(ResponseMessage: HttpResponseMessage; var MembershipInfo: Record "NPR MM Member Info Capture"; var NotValidReason: Text): Boolean
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Response: JsonObject;
    begin
        if not GetResponseBody(ResponseMessage, Response) then begin
            NotValidReason := InvalidResponseError(ResponseMessage);
            exit(false);
        end;

#pragma warning disable AA0139
        MembershipInfo."Membership Code" := JsonHelper.GetJCode(Response.AsToken(), 'membership.membershipCode', false);
        MembershipInfo."External Membership No." := JsonHelper.GetJCode(Response.AsToken(), 'membership.membershipNumber', false);
#pragma warning restore AA0139        
        if (MembershipInfo."Membership Code" = '') or (MembershipInfo."External Membership No." = '') then begin
            NotValidReason := InvalidJsonResponseError(Response);
            exit(false);
        end;
        if Evaluate(MembershipInfo.ExternalMembershipSystemId, JsonHelper.GetJText(Response.AsToken(), 'membership.membershipId', false)) then;
        NotValidReason := '';
        exit(true);
    end;

    local procedure CreateMembershipMemberRequest(var MembershipInfo: Record "NPR MM Member Info Capture") RequestBody: JsonObject
    var
        MembershipEvents: Codeunit "NPR MM Membership Events";
        Member: JsonObject;
    begin
        Member.Add('firstName', MembershipInfo."First Name");
        Member.Add('middleName', MembershipInfo."Middle Name");
        Member.Add('lastName', MembershipInfo."Last Name");
        Member.Add('address', MembershipInfo.Address);
        Member.Add('postCode', MembershipInfo."Post Code Code");
        Member.Add('city', MembershipInfo.City);
        Member.Add('country', MembershipInfo.Country);
        Member.Add('phoneNo', MembershipInfo."Phone No.");
        Member.Add('email', MembershipInfo."E-Mail Address");
        Member.Add('gender', Format(MembershipInfo.Gender, 0, 9));
        Member.Add('newsletter', Format(MembershipInfo."News Letter", 0, 9));
        Member.Add('storeCode', MembershipInfo."Store Code");
        if (MembershipInfo.Birthday > 0D) then
            Member.Add('birthday', Format(MembershipInfo.Birthday, 0, 9));
        if MembershipInfo."External Card No." <> '' then begin
            Member.Add('card', MembershipMemberCardRequest(MembershipInfo));
        end;
        RequestBody.Add('member', Member);
        MembershipEvents.OnAfterCreateMemberRestRequest(MembershipInfo, RequestBody);

    end;

    local procedure MembershipMemberCardRequest(var MembershipInfo: Record "NPR MM Member Info Capture"): JsonObject
    var
        Card: JsonObject;
    begin
        Card.Add('cardNumber', MembershipInfo."External Card No.");
        Card.Add('temporary', MembershipInfo."Temporary Member Card");
        if (MembershipInfo."Valid Until" > 0D) then
            Card.Add('expiryDate', Format(MembershipInfo."Valid Until", 0, 9));

        exit(Card);
    end;

    local procedure ValidateCreateMembershipMemberResponse(ResponseMessage: HttpResponseMessage; var MembershipInfo: Record "NPR MM Member Info Capture"; var NotValidReason: Text): Boolean
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Response: JsonObject;
    begin
        if not GetResponseBody(ResponseMessage, Response) then begin
            NotValidReason := InvalidResponseError(ResponseMessage);
            exit(false);
        end;

#pragma warning disable AA0139
        MembershipInfo."External Member No" := JsonHelper.GetJCode(Response.AsToken(), 'member.memberNumber', false);
        if MembershipInfo."External Member No" = '' then begin
            NotValidReason := InvalidJsonResponseError(Response);
            exit(false);
        end;
        MembershipInfo."External Card No." := JsonHelper.GetJCode(Response.AsToken(), 'member.cards[0].cardNumber', false);
#pragma warning restore AA0139
        MembershipInfo."Valid Until" := JsonHelper.GetJDate(Response.AsToken(), 'member.cards[0].expiryDate', false);

        NotValidReason := '';
        exit(true);

    end;

    local procedure RemoteAddCard(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; var MembershipInfo: Record "NPR MM Member Info Capture"; var NotValidReason: Text): Boolean
    var
        Request, Response : JsonObject;
        MembershipId, MemberId : Guid;
        NotFoundLbl: Label 'Endpoint %1 could not validate %2 %3.', Comment = '%1 = Endpoint URL, %2 = Type (Membership/Card/Member), %3 = external No';
        ErrorResponseLbl: Label 'Error response from %1 endpoint %2: %3', Comment = '%1 = api url, %2 = Endpoint, %3 = Error message';
    begin
        MembershipId := GetExternalMembershipIdFromExternalMembershipNumber(NPRRemoteEndpointSetup, MembershipInfo."External Membership No.");
        if IsNullGuid(MembershipId) then begin
            NotValidReason := StrSubstNo(NotFoundLbl, NPRRemoteEndpointSetup."Rest Api Endpoint URI".TrimEnd('/') + '/membership', MembershipInfo.FieldCaption("External Membership No."), MembershipInfo."External Membership No.");
            exit(false);
        end;
        MemberId := GetExternalMemberIdFromExternalMemberNumber(NPRRemoteEndpointSetup, MembershipInfo."External Member No");
        if IsNullGuid(MemberId) then begin
            NotValidReason := StrSubstNo(NotFoundLbl, NPRRemoteEndpointSetup."Rest Api Endpoint URI".TrimEnd('/') + '/membership/member', MembershipInfo.FieldCaption("External Member No"), MembershipInfo."External Member No");
            exit(false);
        end;
        Request.Add('cardNumber', MembershipInfo."External Card No.");
        if not WebServiceApi(NPRRemoteEndpointSetup, 'POST', StrSubstNo('/membership/%1/member/%2/addCard', Format(MembershipId, 0, 4), Format(MemberId, 0, 4)), Request, Response) then begin
            NotValidReason := StrSubstNo(ErrorResponseLbl, NPRRemoteEndpointSetup."Rest Api Endpoint URI", 'addCard', GetErrorMessage(Response));
            exit(false);
        end;
        exit(ValidateAddReplaceCardResponse(Response, MembershipInfo));
    end;

    local procedure RemoteReplaceCard(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; var MembershipInfo: Record "NPR MM Member Info Capture"; var NotValidReason: Text): Boolean
    var
        Request, Response : JsonObject;
        CardId: Guid;
        ErrorResponseLbl: Label 'Error response from %1 endpoint %2: %3', Comment = '%1 = api url, %2 = Endpoint, %3 = Error message';
    begin
        CardId := GetExternalIdForRemoteCard(NPRRemoteEndpointSetup, MembershipInfo."Replace External Card No.");
        if IsNullGuid(CardId) then begin
            NotValidReason := EndpointCardValidationError(NPRRemoteEndpointSetup, '/membership/card', MembershipInfo."Replace External Card No.");
            exit(false);
        end;
        Request.Add('cardNumber', MembershipInfo."External Card No.");
        if not WebServiceApi(NPRRemoteEndpointSetup, 'POST', StrSubstNo('/membership/card/%1/replaceCard', Format(CardId, 0, 4)), Request, Response) then begin
            NotValidReason := StrSubstNo(ErrorResponseLbl, NPRRemoteEndpointSetup."Rest Api Endpoint URI", 'replaceCard', GetErrorMessage(Response));
            exit(false);
        end;
        exit(ValidateAddReplaceCardResponse(Response, MembershipInfo));
    end;

    local procedure ValidateAddReplaceCardResponse(Response: JsonObject; var MembershipInfo: Record "NPR MM Member Info Capture"): Boolean
    var
        JsonHelper: Codeunit "NPR Json Helper";
    begin
#pragma warning disable AA0139
        MembershipInfo."External Card No." := JsonHelper.GetJCode(Response.AsToken(), 'card.cardNumber', false);
        if StrLen(MembershipInfo."External Card No.") >= 4 then
            MembershipInfo."External Card No. Last 4" := CopyStr(MembershipInfo."External Card No.", StrLen(MembershipInfo."External Card No.") - 4 + 1);
#pragma warning restore AA0139
        MembershipInfo."Valid Until" := JsonHelper.GetJDate(Response.AsToken(), 'card.expiryDate', false);
        MembershipInfo."Temporary Member Card" := JsonHelper.GetJBoolean(Response.AsToken(), 'card.temporary', false);
        exit(true);
    end;

    local procedure MakeMemberSearchQuery(var MembershipInfo: Record "NPR MM Member Info Capture"): Text
    var
        QueryString: Text;
    begin
        if MembershipInfo."First Name" <> '' then
            QueryString += 'firstName=' + UrlEncode(MembershipInfo."First Name") + '&';
        if MembershipInfo."Last Name" <> '' then
            QueryString += 'lastName=' + UrlEncode(MembershipInfo."Last Name") + '&';
        if MembershipInfo."Phone No." <> '' then
            QueryString += 'phone=' + UrlEncode(MembershipInfo."Phone No.") + '&';
        if MembershipInfo."E-Mail Address" <> '' then
            QueryString += 'email=' + UrlEncode(MembershipInfo."E-Mail Address") + '&';
        if MembershipInfo."External Member No" <> '' then
            QueryString += 'memberNumber=' + UrlEncode(MembershipInfo."External Member No") + '&';
        if MembershipInfo.Birthday <> 0D then
            QueryString += 'birthday=' + Format(MembershipInfo.Birthday, 0, 9) + '&';
        if MembershipInfo.Quantity <> 0 then
            QueryString += 'limit=' + Format(MembershipInfo.Quantity, 0, 9) + '&';
        QueryString += 'withDetails=true';
        exit(QueryString);
    end;

    local procedure ValidateMemberSearchResponse(Response: JsonObject; var TempSearchResult: Record "NPR MM Member Info Capture" temporary; var NotValidReason: Text): Boolean
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Members: JsonToken;
        Member: JsonToken;
        EntryNo: Integer;
        ServerResponseLbl: Label 'Message from Server: Member not found.';
    begin
        NotValidReason := '';
        if not JsonHelper.GetJsonToken(Response.AsToken(), 'members', Members) then
            NotValidReason := ServerResponseLbl;
        if Members.AsArray().Count() = 0 then
            NotValidReason := ServerResponseLbl;
        if NotValidReason <> '' then
            exit(false);
        foreach Member in Members.AsArray() do
            AddMemberSearchResult(Member, TempSearchResult, EntryNo);
        if TempSearchResult.Count() = 0 then begin
            NotValidReason := ServerResponseLbl;
            exit(false);
        end;
        exit(true);

    end;

    local procedure AddMemberSearchResult(Member: JsonToken; var TempSearchResult: Record "NPR MM Member Info Capture" temporary; var EntryNo: Integer)
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Membership, Memberships : JsonToken;
    begin
        if not JsonHelper.GetJsonToken(Member, 'memberships', Memberships) then
            exit;
        if Memberships.AsArray().Count() = 0 then
            exit;
        TempSearchResult.Init();
#pragma warning disable AA0139
        TempSearchResult."External Member No" := JsonHelper.GetJText(Member, 'memberNumber', false);
        TempSearchResult."First Name" := JsonHelper.GetJText(Member, 'firstName', false);
        TempSearchResult."Last Name" := JsonHelper.GetJText(Member, 'lastName', false);
        TempSearchResult."E-Mail Address" := JsonHelper.GetJText(Member, 'email', false);
        TempSearchResult.Address := JsonHelper.GetJText(Member, 'address', false);
        TempSearchResult.City := JsonHelper.GetJText(Member, 'city', false);
        TempSearchResult."Phone No." := JsonHelper.GetJText(Member, 'phoneNo', false);
        TempSearchResult."Post Code Code" := JsonHelper.GetJText(Member, 'postCode', false);
#pragma warning restore AA0139
        foreach Membership in Memberships.AsArray() do
            AddSearchResultForMembership(Membership, TempSearchResult, EntryNo);
    end;

    local procedure AddSearchResultForMembership(Membership: JsonToken; var TempSearchResult: Record "NPR MM Member Info Capture" temporary; var EntryNo: Integer)
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Card, Cards : JsonToken;
    begin
        if not JsonHelper.GetJsonToken(Membership, 'membership.cards', Cards) then
            exit;
        if Cards.AsArray().Count() = 0 then
            exit;
#pragma warning disable AA0139        
        TempSearchResult."External Membership No." := JsonHelper.GetJCode(Membership, 'membership.membershipNumber', false);
        TempSearchResult."Membership Code" := JsonHelper.GetJCode(Membership, 'membership.membershipCode', false);
#pragma warning restore AA0139
        if (TempSearchResult."External Membership No." = '') or (TempSearchResult."Membership Code" = '') then
            exit;
        foreach Card in Cards.AsArray() do
            AddSearchResultForCard(Card, TempSearchResult, EntryNo);
    end;

    local procedure AddSearchResultForCard(Card: JsonToken; var TempSearchResult: Record "NPR MM Member Info Capture" temporary; var EntryNo: Integer)
    var
        JsonHelper: Codeunit "NPR Json Helper";
    begin
        if JsonHelper.GetJBoolean(Card, 'blocked', false) then
            exit;
        TempSearchResult."Valid Until" := JsonHelper.GetJDate(Card, 'expiryDate', false);
        IF (TempSearchResult."Valid Until" <> 0D) and (TempSearchResult."Valid Until" < WorkDate()) then
            exit;
#pragma warning disable AA0139        
        TempSearchResult."External Card No." := JsonHelper.GetJCode(Card, 'cardNumber', false);
#pragma warning restore AA0139
        EntryNo += 1;
        TempSearchResult."Entry No." := EntryNo;
        TempSearchResult.Insert();
    end;

    local procedure GetMemberImage(NPRRemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup"; MemberId: Text; var RemoteInfoCapture: Record "NPR MM Member Info Capture")
    var
        JsonHelper: Codeunit "NPR Json Helper";
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        Request, Response : JsonObject;
        Base64Image: Text;
        OutStr: OutStream;
        InStr: InStream;
    begin
        if not WebServiceApi(NPRRemoteEndpointSetup, 'GET', StrSubstNo('/membership/member/%1/image', MemberId), Request, Response) then
            exit;
        Base64Image := JsonHelper.GetJText(Response.AsToken(), 'image', false);
        if Base64Image = '' then
            exit;
        TempBlob.CreateOutStream(OutStr);
        Base64Convert.FromBase64(Base64Image, OutStr);
        TempBlob.CreateInStream(InStr);
        RemoteInfoCapture.Image.ImportStream(InStr, RemoteInfoCapture.FieldName(Image));
    end;

    local procedure GenderAsOption(Gender: Text): Option
    var
        Member: Record "NPR MM Member";
    begin
        case Gender of
            'female':
                exit(Member.Gender::FEMALE);
            'male':
                exit(Member.Gender::MALE);
            'other':
                exit(Member.Gender::OTHER);
            else
                exit(Member.Gender::NOT_SPECIFIED);
        end;
    end;

    local procedure NewsLetterAsOption(NewsLetter: Text): Option
    var
        Member: Record "NPR MM Member";
    begin
        case NewsLetter of
            'yes':
                exit(Member."E-Mail News Letter"::YES);
            'no':
                exit(Member."E-Mail News Letter"::NO);
            else
                exit(Member."E-Mail News Letter"::NOT_SPECIFIED);
        end;
    end;

    local procedure GetErrorMessage(Response: JsonObject): Text
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Code: Text;
        Message: Text;
    begin
        Code := JsonHelper.GetJText(Response.AsToken(), 'code', false);
        Message := JsonHelper.GetJText(Response.AsToken(), 'message', false);
        if Code = 'generic_error' then
            exit(Message);
        exit(StrSubstNo('%1: %2', Code, Message));
    end;

    local procedure GetErrorResponseMessage(ResponseMessage: HttpResponseMessage): Text
    var
        ResponseJson: JsonObject;
    begin
        if GetResponseBody(ResponseMessage, ResponseJson) then
            exit(GetErrorMessage(ResponseJson));
    end;

    local procedure UrlEncode(Input: Text): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.UrlEncode(Input));
    end;
}
