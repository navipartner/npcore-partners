#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
permissionset 6014415 "NPR API Membership"
{
    Access = Internal;
    Assignable = true;
    Caption = 'NPR API - Memberships';
    IncludedPermissionSets = "NPR API Core";
}
#endif