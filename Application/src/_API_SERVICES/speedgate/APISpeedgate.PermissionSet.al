#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
permissionset 6014418 "NPR API Speedgate"
{
    Access = Internal;
    Assignable = true;
    Caption = 'NPR API - Speedgate';
    IncludedPermissionSets = "NPR API Core";
}
#endif