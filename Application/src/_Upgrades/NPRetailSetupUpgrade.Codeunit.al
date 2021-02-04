codeunit 6014422 "NPR NP Retail Setup Upgrade"
{
    Subtype = Upgrade;

    var
        RemoveDefaultPostingProfileLbl: Label 'NPRetailSetup_RemoveDefaultPostingProfile', Locked = true;


    trigger OnUpgradePerCompany()
    begin
        RemoveDefaultPostingProfile();
    end;

    local procedure DoRemoveDefaultPostingProfile()
    var
        POSUnit: Record "NPR POS Unit";
        NPRNPRetailSetup: Record "NPR NP Retail Setup";
    begin
        NPRNPRetailSetup.Get();
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



}
