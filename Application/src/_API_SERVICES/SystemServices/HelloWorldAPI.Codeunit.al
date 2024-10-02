#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6185007 "NPR HelloWorld API" implements "NPR REST API Request Handler"
{
    Access = Internal;

    procedure Handle(var Request: Codeunit "NPR REST API Request"): Codeunit "NPR REST API Response"
    var
        Response: Codeunit "NPR REST API Response";
    begin
        case Request.HttpMethod() of
            "Http Method"::GET:
                exit(GET());
            else begin
                exit(Response.RespondBadRequestUnsupportedHttpMethod(Request.HttpMethod()));
            end;
        end;
    end;

    local procedure GET(): Codeunit "NPR REST API Response"
    var
        Response: Codeunit "NPR REST API Response";
        responseJson: Codeunit "NPR JSON Builder";
    begin
        exit(Response.RespondOK(responseJson.Initialize().AddProperty('message', 'Hello World!').Build()));
    end;
}
#endif