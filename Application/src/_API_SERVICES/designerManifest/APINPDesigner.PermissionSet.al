#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
permissionset 6014431 "NPR API NPDesigner"
{
    Caption = 'NPR API - NPDesigner';
    Access = Internal;
    Assignable = true;
    IncludedPermissionSets = "NPR API Core";
    Permissions =
        Codeunit "NPR NPDesignerManifestWebHook" = X;
}
#endif