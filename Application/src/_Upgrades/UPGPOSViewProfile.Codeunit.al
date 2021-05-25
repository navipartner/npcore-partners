codeunit 6150931 "NPR UPG POS View Profile"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        UpgTagDef: Codeunit "NPR UPG POS View Prof Tag Def";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag()) then
            exit;

        // Run upgrade code
        Upgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag());
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
                POSViewProfile.Code := POSUnit."No." + '_UPG';
                POSViewProfile.Init();
                POSViewProfile.Insert();
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
    begin
        if not POSViewProfile.FindSet(true) then
            exit;
        repeat
            if not POSViewProfile.Image.HasValue() then begin
                if POSViewProfile.Picture.HasValue() then begin
                    POSViewProfile.CalcFields(Picture);
                    POSViewProfile.Picture.CreateInStream(InStr);
                    TenantMediaDesc := POSViewProfile.Code + ' ' + POSViewProfile.Description;
                    POSViewProfile.Image.ImportStream(InStr, CopyStr(TenantMediaDesc, 1, MaxStrLen(TenantMedia.Description)), StrSubstNo('image/%1', POSViewProfile.GetDefaultExtension()));
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
}