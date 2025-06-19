#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248249 "NPR RetailVModuleResolver" implements "NPR API Module Resolver"
{
    Access = Internal;

    procedure Resolve(var Request: Codeunit "NPR API Request"): Interface "NPR API Request Handler"
    var
        RetailVoucherApi: Codeunit "NPR RetailVouchersAPI";
    begin
        exit(RetailVoucherApi);
    end;

    procedure GetRequiredPermissionSet(): Text
    begin
        exit('NPR APIRetailVoucher');
    end;
}
#endif