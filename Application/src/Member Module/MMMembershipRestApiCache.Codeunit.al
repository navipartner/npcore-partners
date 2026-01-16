codeunit 6150879 "NPR MMMembershipRestApiCache"
{
    Access = Internal;
    SingleInstance = true;

    var
        _MemberCardNumberRequest, _MemberCardNumberDetailsRequest, _LoyaltyPointsRequest : HttpRequestMessage;
        _MemberCardNumberResponse, _MemberCardNumberDetailsResponse, _LoyaltyPointsResponse : HttpResponseMessage;
        _MemberCardNumberDatetime, _MemberCardNumberDetailsDatetime, _LoyaltyPointsDateTime : DateTime;

    internal procedure GetResponse(CacheType: Enum "NPR MMMembershipRestApiCache"; Request: HttpRequestMessage; var Response: HttpResponseMessage): Boolean
    begin
        case CacheType of
            "NPR MMMembershipRestApiCache"::NoCache:
                exit(false);
            "NPR MMMembershipRestApiCache"::MemberCardNumber:
                exit(MemberCardNumberResponse(Request, Response));
            "NPR MMMembershipRestApiCache"::MemberCardNumberDetails:
                exit(MemberCardNumberDetailsResponse(Request, Response));
            "NPR MMMembershipRestApiCache"::LoyaltyPoints:
                exit(LoyaltyPointsResponse(Request, Response));
        end;
    end;

    internal procedure SetResponse(CacheType: Enum "NPR MMMembershipRestApiCache"; Request: HttpRequestMessage; Response: HttpResponseMessage)
    begin
        case CacheType of
            "NPR MMMembershipRestApiCache"::NoCache:
                exit;
            "NPR MMMembershipRestApiCache"::MemberCardNumber:
                SetMemberCardNumberResponse(Request, Response);
            "NPR MMMembershipRestApiCache"::MemberCardNumberDetails:
                SetMemberCardNumberDetailsResponse(Request, Response);
            "NPR MMMembershipRestApiCache"::LoyaltyPoints:
                SetLoyaltyPointsResponse(Request, Response);
        end;
    end;

    local procedure MemberCardNumberResponse(Request: HttpRequestMessage; var Response: HttpResponseMessage): Boolean
    begin
        if _MemberCardNumberDatetime = 0DT then
            exit(false);
        if CurrentDateTime > _MemberCardNumberDatetime + 10000 then
            exit(false);
        if Request.GetRequestUri() <> _MemberCardNumberRequest.GetRequestUri() then
            exit(false);
        if Request.Method <> _MemberCardNumberRequest.Method then
            exit(false);
        Response := _MemberCardNumberResponse;
        exit(true);
    end;

    local procedure MemberCardNumberDetailsResponse(Request: HttpRequestMessage; var Response: HttpResponseMessage): Boolean
    begin
        if _MemberCardNumberDetailsDatetime = 0DT then
            exit(false);
        if CurrentDateTime > _MemberCardNumberDetailsDatetime + 10000 then
            exit(false);
        if Request.GetRequestUri() <> _MemberCardNumberDetailsRequest.GetRequestUri() then
            exit(false);
        if Request.Method <> _MemberCardNumberDetailsRequest.Method then
            exit(false);
        Response := _MemberCardNumberDetailsResponse;
        exit(true);
    end;

    local procedure LoyaltyPointsResponse(Request: HttpRequestMessage; var Response: HttpResponseMessage): Boolean
    begin
        if _LoyaltyPointsDatetime = 0DT then
            exit(false);
        if CurrentDateTime > _LoyaltyPointsDatetime + 10000 then
            exit(false);
        if Request.GetRequestUri() <> _LoyaltyPointsRequest.GetRequestUri() then
            exit(false);
        if Request.Method <> _LoyaltyPointsRequest.Method then
            exit(false);
        Response := _LoyaltyPointsResponse;
        exit(true);
    end;

    local procedure SetMemberCardNumberResponse(Request: HttpRequestMessage; Response: HttpResponseMessage)
    begin
        _MemberCardNumberRequest := Request;
        _MemberCardNumberResponse := Response;
        _MemberCardNumberDatetime := CurrentDateTime;
    end;

    local procedure SetMemberCardNumberDetailsResponse(Request: HttpRequestMessage; Response: HttpResponseMessage)
    begin
        _MemberCardNumberDetailsRequest := Request;
        _MemberCardNumberDetailsResponse := Response;
        _MemberCardNumberDetailsDatetime := CurrentDateTime;
    end;

    local procedure SetLoyaltyPointsResponse(Request: HttpRequestMessage; Response: HttpResponseMessage)
    begin
        _LoyaltyPointsRequest := Request;
        _LoyaltyPointsResponse := Response;
        _LoyaltyPointsDatetime := CurrentDateTime;
    end;
}
