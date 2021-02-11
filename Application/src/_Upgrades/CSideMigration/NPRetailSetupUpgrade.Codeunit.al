codeunit 6014422 "NPR NP Retail Setup Upgrade"
{
    Subtype = Upgrade;

    var
        RemoveDefaultPostingProfileLbl: Label 'NPRetailSetup_RemoveDefaultPostingProfile', Locked = true;
        RemoveSourceCodeLbl: Label 'NPRetailSetup_RemoveSourceCodeLbl', Locked = true;


    trigger OnUpgradePerCompany()
    begin
        RemoveDefaultPostingProfile();
        RemoveSourceCode();
    end;

    local procedure DoRemoveDefaultPostingProfile()
    var
        POSUnit: Record "NPR POS Unit";
        NPRNPRetailSetup: Record "NPR NP Retail Setup";
    begin
        if not NPRNPRetailSetup.Get() then
            exit;

        if NPRNPRetailSetup."Default POS Posting Profile" = '' then
            exit;

        if not POSUnit.FindSet() then
            exit;

        repeat
            if POSUnit."POS Posting Profile" <> NPRNPRetailSetup."Default POS Posting Profile" then begin
                POSUnit."POS Posting Profile" := NPRNPRetailSetup."Default POS Posting Profile";
                POSUnit.Modify();
            end;
        until POSUnit.Next() = 0;
    end;

    local procedure RemoveDefaultPostingProfile()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(RemoveDefaultPostingProfileLbl) then
            exit;

        DoRemoveDefaultPostingProfile();

        UpgradeTag.SetUpgradeTag(RemoveDefaultPostingProfileLbl);
    end;

    local procedure RemoveSourceCode()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(RemoveSourceCodeLbl) then
            exit;

        DoRemoveSourceCode();

        UpgradeTag.SetUpgradeTag(RemoveSourceCodeLbl);
    end;

    local procedure DoRemoveSourceCode()
    var
        NPRNPRetailSetup: Record "NPR NP Retail Setup";
        NPRPOSPostingProfile: Record "NPR POS Posting Profile";
    begin
        if not NPRNPRetailSetup.Get() then
            exit;

        if not NPRPOSPostingProfile.FindSet() then
            CreatePosPostingProfile(NPRPOSPostingProfile);
        repeat
            if NPRPOSPostingProfile."Source Code" <> NPRNPRetailSetup."Source Code" then begin
                NPRPOSPostingProfile."Source Code" := NPRNPRetailSetup."Source Code";
                NPRPOSPostingProfile.Modify();
            end;
        until NPRPOSPostingProfile.Next() = 0;

    end;

    local procedure CreatePosPostingProfile(var NPRPOSPostingProfile: Record "NPR POS Posting Profile")
    begin
        NPRPOSPostingProfile.Init();
        NPRPOSPostingProfile.Code := 'DEFAULT';
        NPRPOSPostingProfile.Description := 'Default POS Posting Profile';
        NPRPOSPostingProfile.Insert();
    end;



}
