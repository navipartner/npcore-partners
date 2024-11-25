#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6185106 "NPR MembershipsModuleResolver" implements "NPR API Module Resolver"
{
    Access = Internal;

    procedure Resolve(var Request: Codeunit "NPR API Request"): Interface "NPR API Request Handler"
    var
        MembershipsAPI: Codeunit "NPR MembershipsAPI";
    begin
        exit(MembershipsAPI);
    end;

    procedure GetRequiredPermissionSet(): Text
    begin
        exit('NPR Memberships API');
    end;
}
#endif