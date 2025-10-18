#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248598 "NPR NPDesignerManifestResolver" implements "NPR API Module Resolver"
{
    Access = Internal;

    procedure Resolve(var Request: Codeunit "NPR API Request"): Interface "NPR API Request Handler"
    var
        NpDesigner: Codeunit "NPR NpDesignerManifestAPI";
    begin
        exit(NpDesigner);
    end;

    procedure GetRequiredPermissionSet() PermissionSetName: Text
    begin
        exit('NPR API NPDesigner');
    end;
}
#endif