#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
permissionset 6014417 "NPR API EXT POS"
{
    Access = Internal;
    Assignable = true;
    Caption = 'NPR API - External POS';
    IncludedPermissionSets = "NPR API Core";
}
#endif