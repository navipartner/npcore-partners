#if not BC17
permissionset 6014420 "NPR Ext JQ Refresher"
{
    Caption = 'Ext JQ Refresher', MaxLength = 30;
    Assignable = true;
    IncludedPermissionSets = "D365 AUTOMATION", "SUPER (DATA)", "System App - Admin";
    Access = Internal;
    Permissions =
        tabledata User = r;
}
#endif
