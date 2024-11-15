#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6185007 "NPR API Hello World" implements "NPR API Request Handler"
{
    Access = Internal;

    procedure Handle(var Request: Codeunit "NPR API Request"): Codeunit "NPR API Response"
    begin
        case true of
            Request.Match('GET', '/helloworld'):
                Exit(HelloWorld());
        end;
    end;

    local procedure HelloWorld() Response: Codeunit "NPR API Response"
    var
        Json: Codeunit "NPR JSON Builder";
    begin
        exit(Response.RespondOK(Json.AddProperty('message', 'Hello World!')));
    end;
}
#endif