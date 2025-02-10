#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6185057 "NPR API POS Resolver" implements "NPR API Module Resolver"
{
    Access = Internal;

    procedure Resolve(var Request: Codeunit "NPR API Request"): Interface "NPR API Request Handler"
    var
        APIPOSHandler: Codeunit "NPR API POS Handler";
    begin
        exit(APIPOSHandler);
    end;

    procedure GetRequiredPermissionSet(): Text
    begin
        exit('NPR API POS');
    end;
}
#endif