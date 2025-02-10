#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248215 "NPR API External POS Resolver" implements "NPR API Module Resolver"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-02-05';
    ObsoleteReason = 'Segment path changed from externalpos to pos.';
    procedure Resolve(var Request: codeunit "NPR API Request"): Interface "NPR API Request Handler"
    var
        EXTPOSSaleAPI: Codeunit "NPR API External POS Sale";
    begin
        exit(EXTPOSSaleAPI);
    end;

    procedure GetRequiredPermissionSet() PermissionSetName: Text
    begin
        exit('NPR API EXT POS');
    end;
}
#endif