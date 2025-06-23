#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
permissionset 6014428 "NPR API Loyalty"
{
    Access = Internal;
    Assignable = true;
    Caption = 'NPR API - Loyalty';
    IncludedPermissionSets = "NPR API Core";
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'This API is being phased out';
}
#endif