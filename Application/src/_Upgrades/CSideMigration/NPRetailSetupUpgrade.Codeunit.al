codeunit 6014422 "NPR NP Retail Setup Upgrade"
{
    Subtype = Upgrade;

    var
        RemoveDefaultPostingProfileLbl: Label 'NPRetailSetup_RemoveDefaultPostingProfile', Locked = true;
        RemoveSourceCodeLbl: Label 'NPRetailSetup_RemoveSourceCodeLbl', Locked = true;

    trigger OnUpgradePerCompany()
    begin
        RemoveSourceCode();
        UpgradeFiedsToDedicatedSetups();
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
        NPRPOSPostingProfile: Record "NPR POS Posting Profile";
    begin
        if not NPRPOSPostingProfile.FindSet() then
            CreatePosPostingProfile(NPRPOSPostingProfile);
    end;

    local procedure CreatePosPostingProfile(var NPRPOSPostingProfile: Record "NPR POS Posting Profile")
    begin
        NPRPOSPostingProfile.Init();
        NPRPOSPostingProfile.Code := 'DEFAULT';
        NPRPOSPostingProfile.Description := 'Default POS Posting Profile';
        NPRPOSPostingProfile.Insert();
    end;

    local procedure UpgradeFiedsToDedicatedSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagLbl: Label 'NPRetailSetup_MoveFieldsToDedicatedSetups-20210303', Locked = true;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagLbl) then
            exit;

        UpgradeVarietySetup();
        UpgradeDiscountPriority();
        UpgradePOSViewProfile();
        UpgradeExchangeLabelSetup();
        UpgradeTag.SetUpgradeTag(UpgradeTagLbl);
    end;

    local procedure UpgradeVarietySetup()
    var
        RetailSetup: Record "NPR Retail Setup";
        VarietySetup: Record "NPR Variety Setup";
    begin
        if not RetailSetup.Get() then
            exit;

        if not VarietySetup.Get() then begin
            VarietySetup.Init();
            VarietySetup.Insert();
        end;

        VarietySetup."Internal EAN No. Series" := RetailSetup."Internal EAN No. Management";
        VarietySetup."EAN-Internal" := RetailSetup."EAN-Internal";
        VarietySetup."External EAN No. Series" := RetailSetup."External EAN-No. Management";
        VarietySetup."EAN-External" := RetailSetup."EAN-External";
        VarietySetup."Variant No. Series" := RetailSetup."Variant No. Series";
        VarietySetup.Modify();
    end;

    local procedure UpgradeDiscountPriority()
    var
        RetailSetup: Record "NPR Retail Setup";
        DiscountPriority: Record "NPR Discount Priority";
        MixedDiscountMgt: Codeunit "NPR Mixed Discount Management";
        PeriodDiscountMgt: Codeunit "NPR Period Discount Management";
        QuantityDiscountMgt: Codeunit "NPR Quantity Discount Mgt.";
    begin
        if not RetailSetup.Get() then
            exit;

        DiscountPriority.Reset();
        MixedDiscountMgt.GetOrInit(DiscountPriority);
        DiscountPriority."Discount No. Series" := RetailSetup."Mixed Discount No. Management";
        DiscountPriority.Modify();

        DiscountPriority.Reset();
        PeriodDiscountMgt.GetOrInit(DiscountPriority);
        DiscountPriority."Discount No. Series" := RetailSetup."Period Discount Management";
        DiscountPriority.Modify();

        DiscountPriority.Reset();
        QuantityDiscountMgt.GetOrInit(DiscountPriority);
        DiscountPriority."Discount No. Series" := RetailSetup."Quantity Discount Nos.";
        DiscountPriority.Modify();
    end;

    local procedure UpgradePOSViewProfile()
    var
        RetailSetup: Record "NPR Retail Setup";
        POSViewProfile: Record "NPR POS View Profile";
        ProfileCodeTok: Label 'DEFAULT', Locked = true;
    begin
        if not RetailSetup.Get() then
            exit;

        if not POSViewProfile.Get(ProfileCodeTok) then begin
            POSViewProfile.Init();
            POSViewProfile.Code := ProfileCodeTok;
            POSViewProfile.Insert();
        end;

        POSViewProfile."POS - Show discount fields" := RetailSetup."POS - Show discount fields";
        POSViewProfile.Modify();
    end;

    local procedure UpgradeExchangeLabelSetup()
    var
        RetailSetup: Record "NPR Retail Setup";
        ExchangeLabelSetup: Record "NPR Exchange Label Setup";
    begin
        if not RetailSetup.Get() then
            exit;

        if not ExchangeLabelSetup.Get() then begin
            ExchangeLabelSetup.Init();
            ExchangeLabelSetup.Insert();
        end;

        ExchangeLabelSetup."EAN Prefix Exhange Label" := RetailSetup."EAN Prefix Exhange Label";
        ExchangeLabelSetup."Exchange Label  No. Series" := RetailSetup."Exchange Label  No. Series";
        ExchangeLabelSetup."Purchace Price Code" := RetailSetup."Purchace Price Code";
        ExchangeLabelSetup."Exchange Label Exchange Period" := RetailSetup."Exchange Label Exchange Period";
        ExchangeLabelSetup."Exchange Label Default Date" := RetailSetup."Exchange label default date";
        ExchangeLabelSetup.Modify();
    end;
}
