codeunit 6151559 "NPR API BI Resolver" implements "NPR API Module Resolver"
{
    Access = Internal;

    procedure Resolve(var Request: Codeunit "NPR API Request"): Interface "NPR API Request Handler"
    var
        BIAPI: Codeunit "NPR API BI";
    begin
        exit(BIAPI);
    end;

    procedure GetRequiredPermissionSet(): Text
    begin
        exit('NPR API BI');
    end;
}
