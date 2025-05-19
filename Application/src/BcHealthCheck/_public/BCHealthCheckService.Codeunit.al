#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248440 "NPR BC Health Check Service"
{
    Permissions =
        tabledata "Company Information" = R;

    procedure healthcheck()
    var
        CompanyInfo: Record "Company Information";
    begin
        SelectLatestVersion();

        CompanyInfo.Get();
    end;
}
#endif