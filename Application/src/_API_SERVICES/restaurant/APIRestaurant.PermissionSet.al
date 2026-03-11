#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
permissionset 6150920 "NPR API Restaurant"
{
    Access = Internal;
    Assignable = true;
    Caption = 'NPR API - Restaurant';
    IncludedPermissionSets = "NPR API Core";

    Permissions =
        Codeunit "NPR NPRE Restaurant Webhooks" = X;
}

#endif
