#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248744 "NPR ApiCompanyResolver" implements "NPR API Module Resolver"
{
    Access = Internal;

    procedure Resolve(var Request: Codeunit "NPR API Request"): Interface "NPR API Request Handler"
    var
        CompanyAPI: Codeunit "NPR ApiCompany";
    begin
        exit(CompanyAPI);
    end;

    procedure GetRequiredPermissionSet(): Text
    begin
        exit('NPR API Company');
    end;
}
#endif
