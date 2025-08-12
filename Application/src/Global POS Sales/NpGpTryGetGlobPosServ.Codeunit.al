codeunit 6150978 "NPR NpGp Try Get Glob Pos Serv"
{
    Access = Internal;
    TableNo = "NPR NpGp POS Sales Setup";

    trigger OnRun()
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
        if Rec."Use api" then
            TestApiConnection(Rec)
        else
            GetGlobalPosSalesService(Rec);
#else
        GetGlobalPosSalesService(Rec);
#endif
    end;

    local procedure GetGlobalPosSalesService(NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup")
    var
        RequestMessage: HttpRequestMessage;
        [NonDebuggable]
        RequestHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        Client: HttpClient;
    begin
        NpGpPOSSalesSetup.TestField("Service Url");

        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Remove('Connection');

        NpGpPOSSalesSetup.SetRequestHeadersAuthorization(RequestHeaders);

        RequestMessage.Method := 'GET';
        RequestMessage.SetRequestUri(NpGpPOSSalesSetup."Service Url");

        Client.Send(RequestMessage, ResponseMessage);
        if not ResponseMessage.IsSuccessStatusCode then
            Error(ResponseMessage.ReasonPhrase);
    end;

#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
    local procedure TestApiConnection(Rec: Record "NPR NpGp POS Sales Setup")
    var
        NpGpExporttoAPI: Codeunit "NPR NpGp Export to API";
    begin
        NpGpExporttoAPI.TestEndpointConnection(Rec);
    end;
#endif
}
