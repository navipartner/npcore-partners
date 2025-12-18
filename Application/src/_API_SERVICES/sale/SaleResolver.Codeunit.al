#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248357 "NPR SaleResolver" implements "NPR API Module Resolver"
{
    Access = Internal;

    procedure Resolve(var Request: Codeunit "NPR API Request"): Interface "NPR API Request Handler"
    var
        SalesAPI: Codeunit "NPR SalesAPI";
    begin
        exit(SalesAPI);
    end;

    procedure GetRequiredPermissionSet(): Text
    begin
        exit('NPR API Sale');
    end;
}
#endif