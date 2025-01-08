#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6185115 "NPR ApiSpeedgateResolver" implements "NPR API Module Resolver"
{
    Access = Internal;
    procedure Resolve(var Request: Codeunit "NPR API Request"): Interface "NPR API Request Handler"
    var
        Speedgate: Codeunit "NPR ApiSpeedgate";
    begin
        exit(Speedgate);
    end;

    procedure GetRequiredPermissionSet(): Text
    begin
        exit('NPR API Speedgate');
    end;
}
#endif