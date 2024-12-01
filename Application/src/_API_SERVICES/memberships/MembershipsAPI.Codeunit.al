#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6185113 "NPR MembershipsAPI" implements "NPR API Request Handler"
{
    Access = Internal;

    var
        _ApiFunction: Enum "NPR MembershipApiFunctions";

    procedure Handle(var Request: Codeunit "NPR API Request"): Codeunit "NPR API Response"
    begin

        if (Request.Match('GET', '/membership')) then
            exit(Handle(_ApiFunction::GET_MEMBERSHIP_USING_NUMBER, Request));

        if (Request.Match('GET', '/membership/:membershipId/renewal')) then
            exit(Handle(_ApiFunction::GET_MEMBERSHIP_RENEWAL_INFO, Request));

        if (Request.Match('GET', '/membership/:membershipId/paymentmethods')) then
            exit(Handle(_ApiFunction::GET_ALL_PAYMENT_METHODS, Request));

        if (Request.Match('POST', '/membership/:membershipId/paymentmethods')) then
            exit(Handle(_ApiFunction::CREATE_PAYMENT_METHOD, Request));

        if (Request.Match('GET', '/membership/paymentmethods/:paymentMethodId')) then
            exit(Handle(_ApiFunction::GET_PAYMENT_METHOD, Request));

        if (Request.Match('PATCH', '/membership/paymentmethods/:paymentMethodId')) then
            exit(Handle(_ApiFunction::UPDATE_PAYMENT_METHOD, Request));

        if (Request.Match('DELETE', '/membership/paymentmethods/:paymentMethodId')) then
            exit(Handle(_ApiFunction::DELETE_PAYMENT_METHOD, Request));

    end;

    local procedure Handle(ApiFunction: Enum "NPR MembershipApiFunctions"; var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MembershipApiHandler: Codeunit "NPR MembershipApiHandler";
    begin
        Commit();
        MembershipApiHandler.SetRequest(ApiFunction, Request);
        if (MembershipApiHandler.Run()) then
            exit(MembershipApiHandler.GetResponse());

        Response.CreateErrorResponse(Enum::"NPR API Error Code"::generic_error, StrSubstNo('An error occurred while processing the request: %1', GetLastErrorText()));
    end;
}
#endif