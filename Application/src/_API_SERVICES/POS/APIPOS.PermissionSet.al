#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
permissionset 6014412 "NPR API POS"
{
    Access = Internal;
    Assignable = true;
    Caption = 'NPR API - POS';
    IncludedPermissionSets = "NPR API Core";
    Permissions =
        Codeunit "NPR POS Webhooks" = X;
}
#endif