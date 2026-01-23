#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
permissionset 6014434 "NPR API System"
{
    Access = Internal;
    Assignable = true;
    Caption = 'NPR API - System';
    IncludedPermissionSets = "NPR API Core";
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-23';
    ObsoleteReason = 'Unsused API as the only service GetNodeId() is handled directly via OData.';
}
#endif