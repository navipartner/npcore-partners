codeunit 6150929 "NPR UPG MPOS App Setup"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG MPOS App Setup', 'OnUpgradePerCompany');

        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG MPOS App Setup", 'NPRMPOSAppSetup')) then begin
            Upgrade();
            UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG MPOS App Setup", 'NPRMPOSAppSetup'));
        end;

        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG MPOS App Setup", 'ObsoleteMPOSProfile')) then begin
            MoveTicketAdmissionWebUrl();
            SetPOSUnitTypeMpos();
            UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG MPOS App Setup", 'ObsoleteMPOSProfile'));
        end;

        LogMessageStopwatch.LogFinish();
    end;

    local procedure Upgrade()
    begin
        UpgradeMPOSAppSetup();
    end;

    local procedure UpgradeMPOSAppSetup()
    var
        Register: Record "NPR Register";
        POSUnit: Record "NPR POS Unit";
        MPOSProfile: Record "NPR MPOS Profile";
        MPOSAppSetup: Record "NPR MPOS App Setup";
    begin
        if not Register.FindSet() then
            exit;
        repeat
            POSUnit."No." := Register."Register No.";
            MPOSAppSetup."Register No." := Register."Register No.";
            if POSUnit.Find() and MPOSAppSetup.Find() then begin
                MPOSProfile.Code := POSUnit."No.";
                if not MPOSProfile.Find() then begin
                    MPOSProfile.Init();
                    MPOSProfile.Description := CopyStr('Upgrade from NPR Register', 1, MaxStrLen(MPOSProfile.Description));
                    MPOSProfile."Ticket Admission Web Url" := MPOSAppSetup."Ticket Admission Web Url";
                    MPOSProfile.Insert();
                    POSUnit."MPOS Profile" := MPOSProfile.Code;
                    POSUnit.Modify();
                end;
            end;
        until Register.Next() = 0;
    end;

    local procedure MoveTicketAdmissionWebUrl()
    var
        MPOSProfile: Record "NPR MPOS Profile";
        TicketSetup: Record "NPR TM Ticket Setup";
    begin
        MPOSProfile.SetFilter("Ticket Admission Web Url", '<>%1', '');
        if not MPOSProfile.FindFirst() then
            exit;
        if not TicketSetup.Get() then
            TicketSetup.Insert();
        TicketSetup."Ticket Admission Web Url" := MPOSProfile."Ticket Admission Web Url";
        TicketSetup.Modify();
    end;

    local procedure SetPOSUnitTypeMpos()
    var
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.SetFilter("MPOS Profile", '<>%1', '');
        if not POSUnit.IsEmpty then begin
            POSUnit.ModifyAll("POS Type", POSUnit."POS Type"::MPOS);
            POSUnit.ModifyAll("MPOS Profile", '');
        end;
    end;
}
