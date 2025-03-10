
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
permissionset 6014408 "NPR API Core"
{
    Assignable = false; // Make dedicated permission sets that includes this one.
    Caption = 'NPR API - Core';
    Access = Public;
    IncludedPermissionSets =
        "D365 AUTOMATION",
        "Ext. Events - Subscr";
    ExcludedPermissionSets =
        "NPR All Webhooks"; // Removes all our webhooks upfront so only the specific modules added on an Entra App can be used

    Permissions =
        tabledata * = rimd;

}
#endif