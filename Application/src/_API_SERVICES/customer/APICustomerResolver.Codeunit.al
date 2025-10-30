#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248371 "NPR API Customer Resolver" implements "NPR API Module Resolver"
{
    Access = Internal;

    procedure Resolve(var Request: Codeunit "NPR API Request"): Interface "NPR API Request Handler"
    var
        APICustomer: Codeunit "NPR API Customer";
    begin
        exit(APICustomer);
    end;

    procedure GetRequiredPermissionSet(): Text
    begin
        exit('NPR API Customer');
    end;
}
#endif
