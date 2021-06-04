codeunit 6150933 "NPR UPG POS SS Profile"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR UPG POS SS Prof Tag Def";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS SS Profile', 'OnUpgradePerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag()) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade code
        Upgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag());

        LogMessageStopwatch.LogFinish();
    end;

    local procedure Upgrade()
    begin
        UpgradePOSSelfServiceProfile();
    end;

    local procedure UpgradePOSSelfServiceProfile()
    var
        POSUnit: Record "NPR POS Unit";
        SSProfile: Record "NPR SS Profile";
    begin
        if not POSUnit.FindSet() then
            exit;
        repeat
            if not POSUnit.GetProfile(SSProfile) then begin
                SSProfile.Code := POSUnit."No." + '_UPG';
                SSProfile.Init();
                SSProfile.Description := CopyStr('Created by running upgrade procedure', 1, MaxStrLen(SSProfile.Description));
                SSProfile.Insert();
            end;
            SSProfile."Kiosk Mode Unlock PIN" := POSUnit."Kiosk Mode Unlock PIN";
            SSProfile.Modify();

            POSUnit."POS Self Service Profile" := SSProfile.Code;
            POSUnit.Modify();
        until POSUnit.Next() = 0;
    end;


}