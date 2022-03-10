codeunit 6059814 "NPR Stripe REST Web Service"
{
    Access = Internal;

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
        exit(ResponseMessage.IsSuccessStatusCode());
    end;
}