#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
interface "NPR API Module Resolver"
{
    procedure Resolve(var Request: Codeunit "NPR API Request"): Interface "NPR API Request Handler"
    procedure GetRequiredPermissionSet() PermissionSetName: Text
}
#endif