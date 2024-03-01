codeunit 6184717 "NPR Vipps Mp WebService"
{
    Access = Public;

    local procedure GetWebServiceType(): Integer
    begin
        exit(Codeunit::"NPR Vipps Mp WebService");
    end;

    local procedure GetWebServiceName(): Text
    begin
        exit('vippsmobilepay_service');
    end;

    trigger OnRun()
    var
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateTenantWebService(5, GetWebServiceType(), GetWebServiceName(), true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Web Service Aggregate", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWebServiceAggregate(var Rec: Record "Web Service Aggregate"; RunTrigger: Boolean)
    var
    begin
        if Rec."Object Type" <> Rec."Object Type"::Codeunit then
            exit;
        if Rec."Service Name" <> GetWebServiceName() then
            exit;

        Rec."All Tenants" := false;
    end;

    internal procedure InitMpVippsWebserviceWebService()
    var
        WebServiceAggregate: Record "Web Service Aggregate";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        if not WebServiceAggregate.ReadPermission then
            exit;

        if not WebServiceAggregate.WritePermission then
            exit;

        WebServiceManagement.CreateTenantWebService(WebServiceAggregate."Object Type"::Codeunit, GetWebServiceType(), GetWebServiceName(), true);
    end;

    procedure ReceiveWebhook(json: Text): Text
    var
        VippsMpWebhookMgt: Codeunit "NPR Vipps Mp Webhook Mgt.";
    begin
        VippsMpWebhookMgt.WriteWebhookMessage(json);
        exit('');
    end;
}