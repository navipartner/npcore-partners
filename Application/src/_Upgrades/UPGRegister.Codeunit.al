codeunit 6150925 "NPR UPG Register"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        UpgTagDef: Codeunit "NPR UPG Register Tag Def";
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
        UpgradeRegister();
    end;

    local procedure UpgradeRegister()
    var
        Register: Record "NPR Register";
        POSUnit: Record "NPR POS Unit";
        POSPostingProfile: Record "NPR POS POsting Profile";
        POSStore: Record "NPR POS Store";
        DisplaySetup: Record "NPR Display Setup";
    begin
        if not Register.FindSet() then
            exit;
        repeat
            POSUnit."No." := Register."Register No.";
            if POSUnit.Find() then begin
                case Register.Status of
                    Register.Status::" ":
                        ;
                    Register.Status::Afsluttet:
                        begin
                            POSUnit.Status := POSUnit.Status::CLOSED;
                        end;
                    Register.Status::Ekspedition:
                        begin
                            POSUnit.Status := POSUnit.Status::OPEN;
                        end;
                    Register.Status::"Under afslutning":
                        begin
                            POSUnit.Status := POSUnit.Status::EOD;
                        end;
                end;
                if POSUnit."POS Display Profile" = '' then begin
                    DisplaySetup."Register No." := POSUnit."No.";
                    if DisplaySetup.Find() then begin
                        POSUnit."POS Display Profile" := DisplaySetup."Register No.";
                    end;
                end;
                POSUnit.Modify();
                UpsertPOSUnitActiveEvent(Register, POSUnit);
            end;
            POSPostingProfile.Code := POSUnit."POS Posting Profile";
            if POSPostingProfile.Code <> '' then begin
                if not POSPostingProfile.Find() then begin
                    POSPostingProfile.Init();
                    POSPostingProfile.Insert();
                end;
                POSPostingProfile."POS Posting Diff. Account" := Register."Difference Account";
                POSPostingProfile."Posting Diff. Account (Neg.)" := Register."Difference Account - Neg.";
                if POSStore.Get(POSUnit."POS Store Code") then begin
                    POSPostingProfile."Gen. Bus. Posting Group" := POSStore."Gen. Bus. Posting Group";
                    POSPostingProfile."VAT Bus. Posting Group" := POSStore."VAT Bus. Posting Group";
                    POSPostingProfile."POS Period Register No. Series" := POSStore."POS Period Register No. Series";
                    POSPostingProfile."Tax Area Code" := POSStore."Tax Area Code";
                    POSPostingProfile."Tax Liable" := POSStore."Tax Liable";
                    POSPostingProfile."Default POS Posting Setup" := POSStore."Default POS Posting Setup";
                    POSPostingProfile."VAT Customer No." := POSStore."VAT Customer No.";
                    POSPostingProfile."Posting Compression" := POSStore."Posting Compression";

                    POSStore."POS Posting Profile" := POSPostingProfile.Code;
                    POSStore.Modify();
                end;
                POSPostingProfile.Modify();
            end;
        until Register.Next() = 0;
    end;

    local procedure UpsertPOSUnitActiveEvent(Register: Record "NPR Register"; POSUnit: Record "NPR POS Unit")
    var
        POSViewProfile: Record "NPR POS View Profile";
    begin
        POSUnit.SetActiveEventForCurrPOSUnit(Register."Active Event No.");
    end;
}