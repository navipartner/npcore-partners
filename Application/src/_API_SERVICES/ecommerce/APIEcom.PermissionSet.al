#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
permissionset 6014426 "NPR API Ecom"
{
    Access = Internal;
    Assignable = true;
    Caption = 'NPR API - Ecommerce';
    IncludedPermissionSets = "NPR API Core";
    Permissions =
        Codeunit "NPR Inc Ecom Sales Webhooks" = X;
}
#endif