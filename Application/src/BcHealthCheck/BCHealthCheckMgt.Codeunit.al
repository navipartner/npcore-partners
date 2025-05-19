#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248444 "NPR BC Health Check Mgt."
{
    Access = Internal;

    internal procedure RegisterService()
    var
        WebService: Record "Web Service Aggregate";
        WebServiceMgt: Codeunit "Web Service Management";
        CurrCodeunit: Variant;
    begin
        if ((not WebService.ReadPermission) or (not WebService.WritePermission)) then begin
            exit;
        end;

        CurrCodeunit := Codeunit::"NPR BC Health Check Service";
        WebServiceMgt.CreateTenantWebService(WebService."Object Type"::Codeunit, CurrCodeunit, 'npr_bc_healthcheck', true);
    end;
}
#endif