#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
permissionset 6014408 "NPR REST API"
{
    Assignable = true;
    Caption = 'NPR REST API';
    Access = Internal;
    IncludedPermissionSets = "D365 AUTOMATION";

    Permissions =
        codeunit "NPR REST API Request" = X,
        codeunit "NPR REST API Request Processor" = X,
        codeunit "NPR REST API Response" = X,
        codeunit "NPR HelloWorld API" = X,
        codeunit "NPR HelloWorld Module Resolver" = X;
}
#endif