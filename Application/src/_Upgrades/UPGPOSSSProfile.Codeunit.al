﻿codeunit 6150933 "NPR UPG POS SS Profile"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS SS Profile', 'OnUpgradePerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS SS Profile")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade code
        Upgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS SS Profile"));

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
            if not SSProfile.Get(POSUnit."POS Self Service Profile") then begin
                SSProfile.Code := POSUnit."No." + '_UPG';
                SSProfile.Init();
                SSProfile.Description := CopyStr('Created by running upgrade procedure', 1, MaxStrLen(SSProfile.Description));
                SSProfile."Kiosk Mode Unlock PIN" := POSUnit."Kiosk Mode Unlock PIN";
                SSProfile.Insert();

                POSUnit."POS Self Service Profile" := SSProfile.Code;
                POSUnit.Modify();
            end else begin
                SSProfile."Kiosk Mode Unlock PIN" := POSUnit."Kiosk Mode Unlock PIN";
                SSProfile.Modify();
            end;
        until POSUnit.Next() = 0;
    end;
}
