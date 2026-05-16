#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6151047 "NPR ChannelMgrModuleResolver" implements "NPR API Module Resolver"
{
    Access = Internal;

    procedure Resolve(var Request: Codeunit "NPR API Request"): Interface "NPR API Request Handler"
    var
        Api: Codeunit "NPR ChannelMgrApi";
    begin
        exit(Api);
    end;

    procedure GetRequiredPermissionSet(): Text
    begin
        exit('NPR API Channel Mgr');
    end;
}
#endif
