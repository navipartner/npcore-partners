#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248748 "NPR MemberSignupApiAgent"
{
    Access = Internal;

    internal procedure ProcessSignup(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MembershipRole: Record "NPR MM Membership Role";
        CFMemberRegistration: Codeunit "NPR MM CFMemberRegistration";
        ResponseJson: Codeunit "NPR JSON Builder";
        Body: JsonToken;
        DataToken: JsonToken;
        SignupIdToken: JsonToken;
        DataSubjectIdText: Text;
        DataSubjectId: Text[64];
        SignupDataB64: Text;
        SignupId: Text[64];
        FailureReason: Text;
        Success: Boolean;
        TransientFailure: Boolean;
    begin
        DataSubjectIdText := Request.Paths().Get(3);
        if (DataSubjectIdText = '') then
            exit(Response.RespondBadRequest('The data subject id must not be blank.'));
        if (StrLen(DataSubjectIdText) > MaxStrLen(MembershipRole."GDPR Data Subject Id")) then
            exit(Response.RespondBadRequest(StrSubstNo('The data subject id exceeds the maximum length of %1.', MaxStrLen(MembershipRole."GDPR Data Subject Id"))));
        DataSubjectId := CopyStr(DataSubjectIdText, 1, MaxStrLen(DataSubjectId));

        Body := Request.BodyJson();
        if (not Body.IsObject()) then
            exit(Response.RespondBadRequest('The request body must be a JSON object.'));
        if (not Body.AsObject().Get('data', DataToken)) then
            exit(Response.RespondBadRequest('Missing data property.'));
        if (not DataToken.IsValue()) then
            exit(Response.RespondBadRequest('The data property must be a base64 string.'));
        SignupDataB64 := DataToken.AsValue().AsText();
        if (SignupDataB64 = '') then
            exit(Response.RespondBadRequest('The data property must not be blank.'));

        if (Body.AsObject().Get('signupId', SignupIdToken)) then begin
            if (not SignupIdToken.IsValue()) then
                exit(Response.RespondBadRequest('The signupId property must be a string.'));
            if (StrLen(SignupIdToken.AsValue().AsText()) > MaxStrLen(SignupId)) then
                exit(Response.RespondBadRequest(StrSubstNo('The signupId property exceeds the maximum length of %1.', MaxStrLen(SignupId))));
            SignupId := CopyStr(SignupIdToken.AsValue().AsText(), 1, MaxStrLen(SignupId));
        end;

        Success := CFMemberRegistration.ProcessPushedSignup(DataSubjectId, SignupDataB64, SignupId, FailureReason, TransientFailure);
        if (TransientFailure) then
            exit(Response.CreateErrorResponse(Enum::"NPR API Error Code"::generic_error, FailureReason, Enum::"NPR API HTTP Status Code"::"Service Unavailable"));

        ResponseJson.StartObject()
            .AddProperty('dataSubjectId', DataSubjectId)
            .AddProperty('success', Success)
            .AddProperty('failureReason', FailureReason)
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;
}
#endif
