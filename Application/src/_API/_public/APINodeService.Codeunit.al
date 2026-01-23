codeunit 6150902 "NPR API Node Service"
{
    [ServiceEnabled]
    procedure getnode(): Integer
    begin
        exit(ServiceInstanceId());
    end;

    internal procedure RegisterService()
    var
        WebService: Record "Web Service Aggregate";
        WebServiceMgt: Codeunit "Web Service Management";
    begin
        if ((not WebService.ReadPermission) or (not WebService.WritePermission)) then begin
            exit;
        end;

        WebServiceMgt.CreateTenantWebService(WebService."Object Type"::Codeunit, Codeunit::"NPR API Node Service", 'npr_node_service', true);
    end;
}