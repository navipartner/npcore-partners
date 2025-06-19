#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
permissionset 6014422 "NPR APIRetailVoucher"
{
    Access = Internal;
    Assignable = true;
    Caption = 'NPR API - Retail Voucher';
    IncludedPermissionSets = "NPR API Core";
    Permissions =
        Codeunit "NPR Retail Voucher Webhooks" = X;
}
#endif