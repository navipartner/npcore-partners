#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85235 "NPR Library - NPRetail API"
{
    internal procedure CallApi(Method: Text; Path: Text; Body: JsonObject; QueryParameters: Dictionary of [Text, Text]; Headers: Dictionary of [Text, Text]) Response: JsonObject
    var
        APIRequestProcessor: Codeunit "NPR API Request Processor";
        Request: JsonObject;
        JHeaders: JsonObject;
        RequestText: Text;
        TenantEnvCompanyLbl: label 'Tenant/Environment/Company', Locked = true;
    begin

        Path := Path.TrimStart('/');
        Request.Add('url', StrSubstNo('https://api.npretail.app/%1/%2', TenantEnvCompanyLbl, Path));
        Request.Add('httpMethod', Method);
        Request.Add('path', StrSubstNo('%1/%2', TenantEnvCompanyLbl, Path));
        Request.Add('relativePathSegments', CreatePathSegments(Path));
        Request.Add('queryParams', DictionaryToJObject(QueryParameters));
        Request.Add('body', Body);
        Request.Add('headers', DictionaryToJObject(Headers));
        Request.WriteTo(RequestText);
        Response.ReadFrom(APIRequestProcessor.httpmethod(RequestText));
    end;

    internal procedure IsSuccessStatusCode(Response: JsonObject): Boolean
    var
        JToken: JsonToken;
        StatusCode: Integer;
    begin
        if not Response.Get('statusCode', JToken) then
            exit(false);
        if not JToken.IsValue() then
            exit(false);
        StatusCode := JToken.AsValue().AsInteger();
        exit((StatusCode >= 200) and (StatusCode < 300));
    end;

    internal procedure GetResponseBody(Response: JsonObject): JsonObject
    var
        Base64Convert: Codeunit "Base64 Convert";
        JToken: JsonToken;
        Body: JsonObject;
    begin
        if not Response.Get('body', JToken) then
            exit(Body);
        if not JToken.IsValue() then
            exit(Body);
        if Body.ReadFrom(Base64Convert.FromBase64(JToken.AsValue().AsText())) then;
        exit(Body);
    end;

    internal procedure CreateAPIPermission(UserSecurityId: Guid; Company: Text; RoleId: Code[20])
    var
        AccessControl: Record "Access Control";
    begin
        AccessControl.SetRange("User Security ID", UserSecurityId);
        AccessControl.SetRange("Role ID", RoleId);
        AccessControl.SetFilter("Company Name", '%1|%2', '', Company);
        if AccessControl.IsEmpty() then begin
            AccessControl.Init();
            AccessControl."User Security ID" := UserSecurityId;
            AccessControl."Role ID" := RoleId;
            AccessControl."Company Name" := Company;
            AccessControl.Insert();
        end;
    end;

    local procedure CreatePathSegments(Path: Text) PathSegmentArray: JsonArray
    var
        Segment: Text;
    begin
        foreach Segment in Path.Split('/') do
            PathSegmentArray.Add(Segment);
    end;

    local procedure DictionaryToJObject(Dict: Dictionary of [Text, Text]): JsonObject
    var
        JObject: JsonObject;
        KeyValue: Text;
    begin
        foreach KeyValue in Dict.Keys() do
            JObject.Add(KeyValue, Dict.Get(KeyValue));
        exit(JObject);
    end;



}
#endif
