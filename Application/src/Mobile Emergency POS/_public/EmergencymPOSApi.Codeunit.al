codeunit 6248184 "NPR Emergency mPOS Api"
{
    Access = Public;

    trigger OnRun()
    var
        WebServiceMgt: Codeunit "Web Service Management";
    begin
        WebServiceMgt.CreateTenantWebService(5, Codeunit::"NPR Emergency mPOS Api", WebServiceName(), true);
    end;

    local procedure WebServiceName(): Text
    begin
        exit('emergency_mpos_service');
    end;

    procedure InitEmergencyMPOSWebService()
    var
        WebService: Record "Web Service Aggregate";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        if not WebService.ReadPermission then
            exit;

        if not WebService.WritePermission then
            exit;

        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Codeunit, WebServiceCodeunitId(), WebServiceName(), true);
    end;

    procedure WebServiceCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Emergency mPOS Api");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Web Service Aggregate", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWebServiceAggregate(var Rec: Record "Web Service Aggregate"; RunTrigger: Boolean)
    var
    begin
        if Rec."Object Type" <> Rec."Object Type"::Codeunit then
            exit;
        if Rec."Service Name" <> WebServiceName() then
            exit;

        Rec."All Tenants" := false;
    end;


    procedure GetSetup(setupCode: Text): Text
    var
        EmergencymPOSSetup: Record "NPR Emergency mPOS Setup";
    begin
        EmergencymPOSSetup.Get(setupCode);
        exit(EmergencymPOSSetup.GetSetup());
    end;

    procedure GetSetupCodes(): Text
    var
        Arr: JsonArray;
        JsonResp: Text;
        EmergencymPOSSetup: Record "NPR Emergency mPOS Setup";
    begin
        while EmergencymPOSSetup.Next() = 1 do begin
            Arr.Add(EmergencymPOSSetup.Code);
        end;
        Arr.WriteTo(JsonResp);
        exit(JsonResp);
    end;
}