codeunit 6150931 "NPR UPG POS View Profile"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS View Profile', 'OnUpgradePerCompany');

        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS View Profile")) then begin
            Upgrade();
            UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS View Profile"));
        end;

        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS View Profile", 'UpgradeTaxType')) then begin
            UpgradeTaxType();
            UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS View Profile", 'UpgradeTaxType'));
        end;

        LogMessageStopwatch.LogFinish();
    end;

    local procedure Upgrade()
    begin
        UpgradePOSViewProfile();
        UpgradePOSViewProfileImage();
    end;

    local procedure UpgradePOSViewProfile()
    var
        POSUnit: Record "NPR POS Unit";
        POSViewProfile: Record "NPR POS View Profile";
        ModifyProfile: Boolean;
    begin
        if not POSUnit.FindSet(true) then
            exit;
        repeat
            if not POSUnit.GetProfile(POSViewProfile) then begin
                POSViewProfile.Code := CopyStr(POSUnit."No." + '_UPG', 1, MaxStrLen(POSViewProfile.Code));
                if not POSViewProfile.Find() then begin
                    POSViewProfile.Init();
                    POSViewProfile.Insert();
                end;
            end;
            if POSViewProfile."Lock Timeout" = POSViewProfile."Lock Timeout"::NEVER then begin
                POSViewProfile."Lock Timeout" := "NPR POS View LockTimeout".FromInteger(POSUnit."Lock Timeout");
                ModifyProfile := true;
            end;

            if ModifyProfile then
                POSViewProfile.Modify();

            if POSUnit."POS View Profile" = '' then begin
                POSUnit."POS View Profile" := POSViewProfile.Code;
                POSUnit.Modify();
            end;
        until POSUnit.Next() = 0;
    end;

    local procedure UpgradePOSViewProfileImage()
    var
        POSViewProfile: Record "NPR POS View Profile";
        TenantMedia: Record "Tenant Media";
        Formats: JsonObject;
        InStr: InStream;
        TenantMediaDesc: Text;
        ModifyProfile: Boolean;
        MimeLbl: Label 'image/%1', locked = true;
    begin
        if not POSViewProfile.FindSet(true) then
            exit;
        repeat
            if not POSViewProfile.Image.HasValue() then begin
                if POSViewProfile.Picture.HasValue() then begin
                    POSViewProfile.CalcFields(Picture);
                    POSViewProfile.Picture.CreateInStream(InStr);
                    TenantMediaDesc := POSViewProfile.Code + ' ' + POSViewProfile.Description;
                    POSViewProfile.Image.ImportStream(InStr, CopyStr(TenantMediaDesc, 1, MaxStrLen(TenantMedia.Description)), StrSubstNo(MimeLbl, POSViewProfile.GetDefaultExtension()));
                    ModifyProfile := true;
                end;
            end;
            if POSViewProfile."Culture Info (Serialized)".HasValue() then begin
                POSViewProfile.CalcFields("Culture Info (Serialized)");
                POSViewProfile."Culture Info (Serialized)".CreateInStream(InStr);
                if Formats.ReadFrom(InStr) then begin
                    POSViewProfile.SetFormats(Formats);
                    ModifyProfile := true;
                end;
            end;
            if ModifyProfile then
                POSViewProfile.Modify();
        until POSViewProfile.Next() = 0;
    end;

    local procedure UpgradeTaxType()
    var
        POSViewProfile: Record "NPR POS View Profile";
        ActivateSalesTax: Boolean;
        ActivateVAT: Boolean;
    begin
        if POSViewProfile.FindSet(true) then
            repeat
                POSViewProfile."Show Prices Including VAT" := POSViewProfile."Tax Type" = POSViewProfile."Tax Type"::VAT;

                case POSViewProfile."Tax Type" of
                    POSViewProfile."Tax Type"::VAT:
                        ActivateVAT := true;
                    POSViewProfile."Tax Type"::"Sales Tax":
                        ActivateSalesTax := true;
                end;
            until POSViewProfile.Next() = 0;

        if not (ActivateSalesTax or ActivateVAT) then
            ActivateVAT := true;

        ActivateApplicationArea(ActivateSalesTax, ActivateVAT);
    end;

    local procedure ActivateApplicationArea(ActivateSalesTax: Boolean; ActivateVAT: Boolean)
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        Experience: Text;
    begin
        if not (ActivateSalesTax or ActivateVAT) then
            exit;

        if not ApplicationAreaMgmtFacade.GetExperienceTierCurrentCompany(Experience) then
            exit;
        ApplicationAreaSetup.SetRange("Company Name", CompanyName());
        if ApplicationAreaSetup.IsEmpty() then
            exit;

        if ActivateSalesTax then
            ApplicationAreaSetup.ModifyAll("Sales Tax", ActivateSalesTax);
        if ActivateVAT then
            ApplicationAreaSetup.ModifyAll(VAT, ActivateVAT);
    end;
}
