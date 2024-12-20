codeunit 6150673 "NPR UPG Dragonglass Service"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeStep: Text;

    trigger OnUpgradePerCompany()
    begin
        InitPOSDragonglassService();
    end;

    internal procedure InitPOSDragonglassService()
    var
        WebService: Record "Web Service Aggregate";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        UpgradeStep := 'PublishDragonglassWebService';
        if HasUpgradeTag() then
            exit;

        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Codeunit, Codeunit::"NPR POS Dragonglass API", 'dragonglass', true);

        SetUpgradeTag()
    end;

    local procedure HasUpgradeTag(): Boolean
    begin
        exit(UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Dragonglass Service", UpgradeStep)));
    end;

    local procedure SetUpgradeTag()
    begin
        if HasUpgradeTag() then
            exit;
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Dragonglass Service", UpgradeStep));
    end;
}