codeunit 6014607 "NPR Upgrade Tag Definitions"
{
    // Register the new upgrade tag for new companies when they are created.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure OnGetPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]]);
    begin
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG EFT Profile"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Tax Calc."));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Scanner Stations"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Register"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG MPOS App Setup"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Rcpt. Profile"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS View Profile"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Pass"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS SS Profile"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Pricing Profile"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Pos Menus", 'AdjustSplitBillPOSActionParameters'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Pos Menus", 'AdjustDeletePOSLinePOSActionParameters'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Cross Ref"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Master Line Map"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Gift Voucher"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Document Send. Prof."));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Distr. And Exch. Map"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Credit Voucher"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Bitmap 2 Media"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Azure Functions Data"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Salesperson Upgrade"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR POS Tax Free Data Upgrade"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG FR Audit Setup"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Payment Type POS Upgrade"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR New Prices Upgrade"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR MCS Data Upgrade"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Enable Item Ref. Upgr."));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR NP Retail Setup Upgrade", 'RemoveSourceCode'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR NP Retail Setup Upgrade", 'UpgradeFiedsToDedicatedSetups'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Aux. Tables"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Item Group"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Upgrade Magento Passwords"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Reten. Pol. Install"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR New Prices Install"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG App. Area User Exp."));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Sales Pr. Maint. Setup"));
    end;

    // Use methods to avoid hard-coding the tags. It is easy to remove afterwards because it's compiler-driven.
    procedure GetUpgradeTag(UpgradeCodeunitID: Integer): Text[250]
    begin
        exit(GetUpgradeTag(UpgradeCodeunitID, ''));
    end;

    procedure GetUpgradeTag(UpgradeCodeunitID: Integer; UpgradeStep: Text): Text[250]
    var
        POSViewProfile: Record "NPR POS View Profile";
    begin
        case UpgradeCodeunitID of
            Codeunit::"NPR UPG EFT Profile":
                exit('NPRTaxFreePOSUnit-02e65aa9-1e85-4f0a-a1ca-2c27f24b0377');
            Codeunit::"NPR UPG Tax Calc.":
                exit(CompanyName() + 'NPRPOSTaxCalc' + Format(Today(), 0, 9));
            Codeunit::"NPR UPG Scanner Stations":
                exit('ScannerStation-20212402');
            Codeunit::"NPR UPG Register":
                exit('NPRRegister-623d5a37-44aa-4244-a4c3-6d8f6b1ccd88');
            Codeunit::"NPR UPG MPOS App Setup":
                exit('NPRMPOSAppSetup-76e69e8f-d2fe-4d24-bc9f-823b60acfaad');
            Codeunit::"NPR UPG Rcpt. Profile":
                exit('NPRPOSUnitRcptTxtProfile-99e3b857-d3cf-4ff8-b9fa-4768a63e33b3');
            Codeunit::"NPR UPG POS View Profile":
                exit(POSViewProfile.TableCaption() + '-' + Format(Today(), 0, 9));
            Codeunit::"NPR UPG POS Pass":
                exit(CompanyName() + 'NPRPOSUnitPasswords' + Format(Today(), 0, 9));
            Codeunit::"NPR UPG POS SS Profile":
                exit('NPRPOSUnit-ee2acd97-c63a-479b-bbe7-4d6d10514974');
            Codeunit::"NPR UPG POS Pricing Profile":
                exit('NPRRegister-a306e4b4-b004-4ac5-8749-fcd1c8ba5d1f');
            Codeunit::"NPR UPG POS Cross Ref":
                exit(CompanyName() + 'NPRPOSCrossRef' + Format(Today(), 0, 9));
            Codeunit::"NPR UPG Master Line Map":
                exit('NPRPUGMasterLineMap_Upgrade-20210312');
            Codeunit::"NPR UPG Gift Voucher":
                exit('NPRGiftVoucher-58afcbe8-d720-4770-8e65-28e0bc15e4a8');
            Codeunit::"NPR UPG Document Send. Prof.":
                exit('NPR_DocumentProcessing_DocumentSendingProfile_20210222');
            Codeunit::"NPR UPG Distr. And Exch. Map":
                exit('NPRPUGDistrAndExchMap_Upgrade-20210312');
            Codeunit::"NPR UPG Credit Voucher":
                exit('NPRCreditVoucher-58afcbe8-d720-4770-8e65-28e0bc15e4a8');
            Codeunit::"NPR UPG Bitmap 2 Media":
                exit(CompanyName() + 'Bitmap2Media' + Format(Today(), 0, 9));
            Codeunit::"NPR UPG Azure Functions Data":
                exit('NPR_UPG_Azure_Functions_Data');
            Codeunit::"NPR Salesperson Upgrade":
                exit('NPRSalespersonUpgrade-20210414-01');
            Codeunit::"NPR POS Tax Free Data Upgrade":
                exit('NPR_POS_Tax_Free_Data_Upgrade');
            Codeunit::"NPR UPG FR Audit Setup":
                exit('NPR_UPG_FR_Audit_Setup_Upgrade-20200816');
            Codeunit::"NPR Payment Type POS Upgrade":
                exit('PaymentTypePOS_MoveToPOSPaymentMethod');
            Codeunit::"NPR New Prices Upgrade":
                exit('NPRNewPriceTableUpgrade-20210618');
            Codeunit::"NPR MCS Data Upgrade":
                exit('NPR_MCS_Data_Upgrade');
            Codeunit::"NPR Enable Item Ref. Upgr.":
                exit('AutoEnableItemReference-20210324');
            Codeunit::"NPR NP Retail Setup Upgrade":
                case UpgradeStep of
                    'RemoveSourceCode':
                        exit('NPRetailSetup_RemoveSourceCodeLbl');
                    'UpgradeFiedsToDedicatedSetups':
                        exit('NPRetailSetup_MoveFieldsToDedicatedSetups-20210303');
                end;
            Codeunit::"NPR UPG Aux. Tables":
                exit('NPRPUGAuxTables_Upgrade-20210315-01');
            Codeunit::"NPR UPG Item Group":
                exit('NPRPUGItemGroup_Upgrade-20210430');
            Codeunit::"NPR Upgrade Magento Passwords":
                exit('Magento_Password_IsolatedStorage_20210129');
            Codeunit::"NPR Reten. Pol. Install":
                exit('NPR-RetenPolTables-20210809');
            Codeunit::"NPR Job Queue Install":
                exit('NPRJobQueueInstall-20210812');
            Codeunit::"NPR New Prices Install":
                exit('NPRNewPriceTableInstall-20210618');
            Codeunit::"NPR UPG Pos Menus":
                case UpgradeStep of
                    'AdjustSplitBillPOSActionParameters':
                        exit('NPRSplitBillActionToWF2-938526df-0edf-4c2c-9db8-19e28af11c5a');
                    'AdjustDeletePOSLinePOSActionParameters':
                        exit('NPRDeletePOSLineActionToWF2-938526df-0edf-4c2c-9db8-19e28af11c5a');
                end;
            Codeunit::"NPR UPG App. Area User Exp.":
                exit('NPR-482497-AppAreaForUserExperience-20210825');
            Codeunit::"NPR UPG Sales Pr. Maint. Setup":
                exit('NPRSalesPriceMaintSetupUpgrade-20210901');
        end;
    end;
}