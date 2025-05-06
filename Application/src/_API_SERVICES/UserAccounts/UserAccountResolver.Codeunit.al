#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248415 "NPR UserAccountResolver" implements "NPR API Module Resolver"
{
    Access = Internal;

    procedure Resolve(var Request: Codeunit "NPR API Request"): Interface "NPR API Request Handler"
    var
        UserAccountAPI: Codeunit "NPR UserAccountAPI";
    begin
        exit(UserAccountAPI);
    end;

    procedure GetRequiredPermissionSet() PermissionSetName: Text
    begin
        exit('NPR API Account');
    end;
}
#endif