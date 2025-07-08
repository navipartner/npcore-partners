#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248359 "NPR EcomResolver" implements "NPR API Module Resolver"
{
    Access = Internal;

    procedure Resolve(var Request: Codeunit "NPR API Request"): Interface "NPR API Request Handler"
    var
        EcomAPI: Codeunit "NPR EcomAPI";
    begin
        exit(EcomAPI);
    end;

    procedure GetRequiredPermissionSet(): Text
    begin
        exit('NPR API Ecom');
    end;
}
#endif