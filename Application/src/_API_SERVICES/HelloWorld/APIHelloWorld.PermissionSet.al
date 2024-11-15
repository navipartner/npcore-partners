#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
permissionset 6014411 "NPR API HelloWorld"
{
    Access = Internal;
    Assignable = true;
    Caption = 'NPR API - Hello World';
    IncludedPermissionSets = "NPR API Core";
}
#endif