#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
permissionset 6014414 "NPR API Ticketing"
{
    Access = Internal;
    Assignable = true;
    Caption = 'NPR API - Ticketing';
    IncludedPermissionSets = "NPR API Core";
    Permissions =
        Codeunit "NPR TM CapacityWebHook" = X,
        Codeunit "NPR TM Ticket Webhooks" = X;
}
#endif