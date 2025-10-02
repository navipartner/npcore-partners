codeunit 6059814 "NPR Stripe REST Web Service"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-09-03';
    ObsoleteReason = 'Not used. Using POS Billing API integration to control licenses.';

    internal procedure CallRESTWebService(var TempStripeRESTWSArgument: Record "NPR Stripe REST WS Argument" temporary; var HttpStatusCode: Integer): Boolean
    var
        Base64Convert: Codeunit "Base64 Convert";
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        UsernameAndPasswordLbl: Label '%1:%2', Locked = true, Comment = '%1 = Username, %2 = password';
        BasicAuthorizationLbl: Label 'Basic %1', Locked = true, Comment = '%1 = Username and password in base64 string';
        AuthText: Text;
    begin
        RequestMessage.Method := TempStripeRESTWSArgument.GetRestMethod();
        RequestMessage.SetRequestUri(TempStripeRESTWSArgument.URL);

        RequestMessage.GetHeaders(Headers);

        if TempStripeRESTWSArgument.Accept <> '' then
            Headers.Add('Accept', TempStripeRESTWSArgument.Accept);

        if TempStripeRESTWSArgument.Username <> '' then begin
            AuthText := StrSubstNo(UsernameAndPasswordLbl, TempStripeRESTWSArgument.Username, TempStripeRESTWSArgument.Password);
            Headers.Add('Authorization', StrSubstNo(BasicAuthorizationLbl, Base64Convert.ToBase64(AuthText)));
        end;

        if TempStripeRESTWSArgument.ETag <> '' then
            Headers.Add('If-Match', TempStripeRESTWSArgument.ETag);

        if TempStripeRESTWSArgument.HasRequestContent() then begin
            TempStripeRESTWSArgument.GetRequestContent(Content);
            RequestMessage.Content := Content;
        end;

        Client.Send(RequestMessage, ResponseMessage);

        Headers := ResponseMessage.Headers();
        TempStripeRESTWSArgument.SetResponseHeaders(Headers);

        Content := ResponseMessage.Content();
        TempStripeRESTWSArgument.SetResponseContent(Content);

        HttpStatusCode := ResponseMessage.HttpStatusCode();
        if HttpStatusCode in [400 .. 599] then
            EmitTelemetryDataOnError(ResponseMessage.ReasonPhrase);
        exit(ResponseMessage.IsSuccessStatusCode());
    end;

    local procedure EmitTelemetryDataOnError(ErrorMessageText: Text)
    var
        ActiveSession: Record "Active Session";
        CustomDimensions: Dictionary of [Text, Text];
    begin
        if not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId()) then
            Clear(ActiveSession);

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', UserId());
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");
        CustomDimensions.Add('NPR_ST_Response', ErrorMessageText);

        Session.LogMessage('NPR_Stripe', 'Stripe Response Error', Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;
}