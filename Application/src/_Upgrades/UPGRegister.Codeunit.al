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
                POSPostingProfile."POS Payment Bin" := POSUnit."Default POS Payment Bin";
                POSPostingProfile.Modify();
            end;
        until Register.Next() = 0;
    end;

    local procedure UpsertPOSUnitActiveEvent(Register: Record "NPR Register"; POSUnit: Record "NPR POS Unit")
    begin
        POSUnit.SetActiveEventForCurrPOSUnit(Register."Active Event No.");
    end;
}