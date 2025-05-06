#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC21)
permissionset 6014427 "NPR API Account"
{
    Access = Internal;
    Assignable = true;
    Caption = 'NPR API - User Accounts';
    IncludedPermissionSets = "NPR API Core";
}
#endif