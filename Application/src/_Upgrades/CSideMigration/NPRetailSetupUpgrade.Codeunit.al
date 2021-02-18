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
        UpgradeFiedsToDedicatedSetups();
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

    local procedure UpgradeFiedsToDedicatedSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagLbl: Label 'NPRetailSetup_MoveFieldsToDedicatedSetups-20210217', Locked = true;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagLbl) then
            exit;

        UpgradeVarietySetup();
        UpgradeDiscountPriority();
        UpgradeNPRetailSetup();
        UpgradePOSViewProfile();
        UpgradeExchangeLabelSetup();
        UpgradeRetailItemSetup();
        UpgradeCustomerRepairSetup();
        UpgradeStaffSetup();

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

    local procedure UpgradeNPRetailSetup()
    var
        RetailSetup: Record "NPR Retail Setup";
        NPRetailSetup: Record "NPR NP Retail Setup";
    begin
        if not RetailSetup.Get() then
            exit;

        if not NPRetailSetup.Get() then begin
            NPRetailSetup.Init();
            NPRetailSetup.Insert();
        end;

        NPRetailSetup."Margin and Turnover By Shop" := RetailSetup."Margin and Turnover By Shop";
        NPRetailSetup."Costing Method Standard" := RetailSetup."Costing Method Standard";
        NPRetailSetup."Retail Journal No. Series" := RetailSetup."Retail Journal No. Management";
        NPRetailSetup."Salespersoncode on Salesdoc." := RetailSetup."Salespersoncode on Salesdoc.";
        NPRetailSetup."Check Purchase Lines if vendor" := RetailSetup."Check Purchase Lines if vendor";
        NPRetailSetup."Unit Cost Control" := RetailSetup."Unit Cost Control";
        NPRetailSetup."Password on unblock discount" := RetailSetup."Password on unblock discount";
        NPRetailSetup.Modify();
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

    local procedure UpgradeCustomerRepairSetup()
    var
        RetailSetup: Record "NPR Retail Setup";
        CustomerRepairSetup: Record "NPR Customer Repair Setup";
    begin
        if not RetailSetup.Get() then
            exit;

        if not CustomerRepairSetup.Get() then begin
            CustomerRepairSetup.Init();
            CustomerRepairSetup.Insert();
        end;

        CustomerRepairSetup."Customer Repair No. Series" := RetailSetup."Customer Repair Management";
        CustomerRepairSetup."Repair Msg." := RetailSetup."Repair Msg.";
        CustomerRepairSetup."Rep. Cust. Default" := RetailSetup."Rep. Cust. Default";
        CustomerRepairSetup."Fixed Price of Mending" := RetailSetup."Fixed Price of Mending";
        CustomerRepairSetup."Fixed Price of Denied Mending" := RetailSetup."Fixed Price of Denied Mending";
        CustomerRepairSetup.Modify();
    end;

    local procedure UpgradeStaffSetup()
    var
        RetailSetup: Record "NPR Retail Setup";
        CustomerRepairSetup: Record "NPR Staff Setup";
    begin
        if not RetailSetup.Get() then
            exit;

        if not CustomerRepairSetup.Get() then begin
            CustomerRepairSetup.Init();
            CustomerRepairSetup.Insert();
        end;

        CustomerRepairSetup."Internal Unit Price" := RetailSetup."Internal Unit Price";
        CustomerRepairSetup."Staff Disc. Group" := RetailSetup."Staff Disc. Group";
        CustomerRepairSetup."Staff Price Group" := RetailSetup."Staff Price Group";
        CustomerRepairSetup."Staff SalesPrice Calc Codeunit" := RetailSetup."Staff SalesPrice Calc Codeunit";
        CustomerRepairSetup.Modify();
    end;
}
