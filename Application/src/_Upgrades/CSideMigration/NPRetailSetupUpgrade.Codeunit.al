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
        UpgradeTagLbl: Label 'NPRetailSetup_MoveFieldsToDedicatedSetups-20210217', Locked = true;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagLbl) then
            exit;

        UpgradeVarietySetup();
        UpgradeDiscountPriority();
        UpgradePOSViewProfile();
        UpgradeExchangeLabelSetup();
        UpgradeRetailItemSetup();
        UpgradeStaffSetup();
        UpgradePOSUnit();
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

    local procedure UpgradeRetailItemSetup()
    var
        RetailSetup: Record "NPR Retail Setup";
        RetailItemSetup: Record "NPR Retail Item Setup";
    begin
        if not RetailSetup.Get() then
            exit;

        if not RetailItemSetup.Get() then begin
            RetailItemSetup.Init();
            RetailItemSetup.Insert();
        end;

        RetailItemSetup."Item Group on Creation" := RetailSetup."Item Group on Creation";
        RetailItemSetup."Item Description at 1 star" := RetailSetup."Item Description at 1 star";
        RetailItemSetup."EAN No. at 1 star" := RetailSetup."EAN No. at 1 star";
        RetailItemSetup."Transfer SeO Item Entry" := RetailSetup."Transfer SeO Item Entry";
        RetailItemSetup."EAN-No. at Item Create" := RetailSetup."EAN-No. at Item Create";
        RetailItemSetup."Autocreate EAN-Number" := RetailSetup."Autocreate EAN-Number";
        RetailItemSetup."Itemgroup Pre No. Serie" := RetailSetup."Itemgroup Pre No. Serie";
        RetailItemSetup."Itemgroup No. Serie StartNo." := RetailSetup."Itemgroup No. Serie StartNo.";
        RetailItemSetup."Itemgroup No. Serie EndNo." := RetailSetup."Itemgroup No. Serie EndNo.";
        RetailItemSetup."Itemgroup No. Serie Warning" := RetailSetup."Itemgroup No. Serie Warning";
        RetailItemSetup."Reason for Return Mandatory" := RetailSetup."Reason for Return Mandatory";
        RetailItemSetup."Description Control" := RetailSetup."Description control";
        RetailItemSetup."Not use Dim filter SerialNo" := RetailSetup."Not use Dim filter SerialNo";
        RetailItemSetup.Modify();
    end;

    local procedure UpgradeStaffSetup()
    var
        RetailSetup: Record "NPR Retail Setup";
        StaffSetup: Record "NPR Staff Setup";
    begin
        if not RetailSetup.Get() then
            exit;

        if not StaffSetup.Get() then begin
            StaffSetup.Init();
            StaffSetup.Insert();
        end;

        StaffSetup."Internal Unit Price" := RetailSetup."Internal Unit Price";
        StaffSetup."Staff Disc. Group" := RetailSetup."Staff Disc. Group";
        StaffSetup."Staff Price Group" := RetailSetup."Staff Price Group";
        StaffSetup."Staff SalesPrice Calc Codeunit" := RetailSetup."Staff SalesPrice Calc Codeunit";
        StaffSetup.Modify();
    end;

    local procedure UpgradePOSUnit()
    var
        POSUnit: Record "NPR POS Unit";
        RetailSetup: Record "NPR Retail Setup";
    begin
        if not RetailSetup.Get() then
            exit;

        if (RetailSetup."Open Register Password" = '') and (RetailSetup."Password on unblock discount" = '') then
            exit;

        if not POSUnit.FindSet() then
            exit;

        repeat
            POSUnit."Password on unblock discount" := RetailSetup."Password on unblock discount";
            POSUnit."Open Register Password" := RetailSetup."Open Register Password";
            POSUnit.Modify();
        until POSUnit.Next() = 0;
    end;
}
