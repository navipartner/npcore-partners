codeunit 6014607 "NPR Upgrade Tag Definitions"
{
    Access = Internal;
    // Register the new upgrade tag for new companies when they are created.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure OnGetPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]]);
    begin
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG EFT Profile"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Scanner Stations"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Register"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG MPOS App Setup", 'NPRMPOSAppSetup'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG MPOS App Setup", 'ObsoleteMPOSProfile'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Rcpt. Profile"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS View Profile"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS View Profile", 'UpgradeTaxType'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Pass", 'UpgradePOSUnitPasswords'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Pass", 'MoveLockPassToPOSSecurityProfile'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS SS Profile"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Pricing Profile"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Pos Menus", 'AdjustSplitBillPOSActionParameters'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Pos Menus", 'AdjustDeletePOSLinePOSActionParameters'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Pos Menus", 'PosMenuPaymentButtonsAutoEnabled'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Cross Ref"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Gift Voucher"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Credit Voucher"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Bitmap 2 Media"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Azure Functions Data"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Salesperson Upgrade"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR POS Tax Free Data Upgrade"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG FR Audit Setup"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Payment Type POS Upgrade"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR New Prices Upgrade"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR MCS Data Upgrade"));
#if BC17 or BC18
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Enable Item Ref. Upgr."));
#endif
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR NP Retail Setup Upgrade", 'RemoveSourceCode'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR NP Retail Setup Upgrade", 'UpgradeFiedsToDedicatedSetups'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Item Group"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Upgrade Magento Passwords"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Reten. Pol. Install"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'POSLayoutArchive'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'POSSavedSales'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'RetenTableListUpdate_20230223'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'HeyLoyaltyWebhookRequests'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'NPRE'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'AddJobQueues'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'UpdateJobQueues1'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'AddTaskCountResetJQ'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'NotifyOnSuccessFalse'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'CustomCUforPostInvtCostToGL'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'AutoRescheduleRetenPolicy'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'TMRetentionJQCategory'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'UpdateAdjCostJobQueueTimeout'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'SetAutoRescedulePOSPostGL'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'SetEndingTimeForPOSPostGLJQ'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR New Prices Install"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG App. Area User Exp."));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Event Report Layout Upg."));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Sales Pr. Maint. Setup"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Customer Templates"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Cust. Config. Temp."));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG My Notifications"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Upgrade Retail Journal"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG NpRv Print Object Type"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Web Service Pass", 'RemoteEndpoints'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Web Service Pass", 'RetailInventorySets'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Web Service Pass", 'POSHCEndpointSetup'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Web Service Pass", 'NpXmlTemplate'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Web Service Pass", 'NpCsStore'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Web Service Pass", 'NpRvPartner'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Web Service Pass", 'NpRvGlobalVoucher'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Item Blob 2 Media"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Member Blob 2 Media"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Action Parameters", 'SalesDocExpPaymentMethodCode'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Action Parameters", 'SalesDocExpRefreshMenuButtonActions'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Action Parameters", 'SalesDocImpRefreshMenuButtonActions'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Action Parameters", 'TakePhotoRefreshMenuButtonActions'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Action Parameters", 'ItemIdentifierType'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Action Parameters", 'RefreshReverseDirectSalePOSAction'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Action Parameters", 'ItemPriceIdentifierType'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Action Parameters", 'ItemLookupSmartSearch'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Action Parameters", 'CustomerNo'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Action Parameters", 'CustomerNoParam'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Action Parameters", 'POSWorkflow1'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Action Parameters", 'UpdateSecureMethodsDiscount'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Action Parameters", 'SecurityParameter'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Fix POS Entry SystemId"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Upgrade Shipping Provider", 'NPRShippingProvider'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Upgrade Shipping Provider", 'NPRPackageDimensions'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Upgrade Shipping Provider", 'NPRPackageServices'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG E-Mail Setup"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Object Output"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG MPOS QR Code"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG DE Audit Setup"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Types"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Types", 'UpgradeKitcheRequests'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG PaymentV2"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR TM Calendar Upgrade"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Login"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Print Template", 'UpgradeReceiptText'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Print Template", 'UpgradeRJLVendorFields'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Print Template", 'UpgradeLogoAlignment'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG PG To Interface"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR HL App Upgrade", 'MoveHeyLoyaltyValueMappings'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Vend Item No Expansion", 'ItemWorksheetLine'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Vend Item No Expansion", 'RegistItemWorkshLine'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Vend Item No Expansion", 'RetailCampaignItems'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Vend Item No Expansion", 'MixedDiscountLine'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Vend Item No Expansion", 'PeriodDiscountLine'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Vend Item No Expansion", 'RetailReplDemandLine'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Vend Item No Expansion", 'ItemWorksheetExcelColumn'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Vend Item No Expansion", 'ItemWorksheetFieldSetup'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG NaviConnect", 'ImportTypeActionable'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Retail Logo"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Scenarios", 'ShowReturnAmountDialog'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Scenarios", 'AddNewOnSaleCoupons'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Scenarios", 'UpdateDisplayOnSaleLineInsert'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Scenarios", 'PrintWarrantyAfterSaleLine'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Scenarios", 'UpdateTicketOnSaleLineInsert'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Scenarios", 'UpdateMembershipOnSaleLineInsert'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Scenarios", 'MCSSaleLineUpload'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Scenarios", 'PopupDimension'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG BalanceV4"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG ItemRef. Disc Barcodes", 'UpgradeDiscBarcodes'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Pos Entry Dims", '20230515'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Enum Upgrade", 'UpgradeNPREKitchenOrderStatusEnum'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR FtpSftp Data Upgrade"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", 'UpdatePrimarySeating'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", 'UpdateKitchenRequestSeatingAndWaiter'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", 'RefreshKitchenOrderStatus'));
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
            Codeunit::"NPR UPG Scanner Stations":
                exit('ScannerStation-20212402');
            Codeunit::"NPR UPG Register":
                exit('NPRRegister-623d5a37-44aa-4244-a4c3-6d8f6b1ccd88');
            Codeunit::"NPR UPG MPOS App Setup":
                case UpgradeStep of
                    'NPRMPOSAppSetup':
                        exit('NPRMPOSAppSetup-76e69e8f-d2fe-4d24-bc9f-823b60acfaad');
                    'ObsoleteMPOSProfile':
                        exit('ObsoleteMPOSProfile_20220125')
                end;
            Codeunit::"NPR UPG Rcpt. Profile":
                exit('NPRPOSUnitRcptTxtProfile-99e3b857-d3cf-4ff8-b9fa-4768a63e33b3');
            Codeunit::"NPR UPG POS View Profile":
                case UpgradeStep of
                    '':
                        exit(CopyStr(POSViewProfile.TableCaption(), 1, 250));
                    'UpgradeTaxType':
                        exit('POSViewProfile_TaxType-20220128')
                end;
            Codeunit::"NPR UPG POS Pass":
                case UpgradeStep of
                    'UpgradePOSUnitPasswords':
                        exit('NPRPOSUnitPasswords');
                    'MoveLockPassToPOSSecurityProfile':
                        exit('MoveLockPassToPOSSecurityProfile');
                end;
            Codeunit::"NPR UPG POS SS Profile":
                exit('NPRPOSUnit-ee2acd97-c63a-479b-bbe7-4d6d10514974');
            Codeunit::"NPR UPG POS Pricing Profile":
                exit('NPRRegister-a306e4b4-b004-4ac5-8749-fcd1c8ba5d1f');
            Codeunit::"NPR UPG POS Cross Ref":
                exit(CompanyName() + 'NPRPOSCrossRef' + Format(Today(), 0, 9));
            Codeunit::"NPR UPG Gift Voucher":
                exit('NPRGiftVoucher-58afcbe8-d720-4770-8e65-28e0bc15e4a8');
            Codeunit::"NPR UPG Credit Voucher":
                exit('NPRCreditVoucher-58afcbe8-d720-4770-8e65-28e0bc15e4a8');
            Codeunit::"NPR UPG Bitmap 2 Media":
                exit('NPRBitmap2Media');
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
                exit('NPRNewPriceTableUpgrade-20210920');
            Codeunit::"NPR MCS Data Upgrade":
                exit('NPR_MCS_Data_Upgrade');
#if BC17 or BC18                
            Codeunit::"NPR Enable Item Ref. Upgr.":
                exit('AutoEnableItemReference-20210324');
#endif                
            Codeunit::"NPR NP Retail Setup Upgrade":
                case UpgradeStep of
                    'RemoveSourceCode':
                        exit('NPRetailSetup_RemoveSourceCodeLbl');
                    'UpgradeFiedsToDedicatedSetups':
                        exit('NPRetailSetup_MoveFieldsToDedicatedSetups-20210303');
                end;
            Codeunit::"NPR UPG Item Group":
                exit('NPRPUGItemGroup_Upgrade-20210430');
            Codeunit::"NPR Upgrade Magento Passwords":
                exit('Magento_Password_IsolatedStorage_20210129');
            Codeunit::"NPR Reten. Pol. Install":
                case UpgradeStep of
                    '':
                        exit('NPR-RetenPolTables-20221020');
                    'POSLayoutArchive':
                        exit('NPR-RetenPolTables-POSLayoutArchive-20221207');
                    'POSSavedSales':
                        exit('NPR-RetenPolTables-POSSavedSales-20221223');
                    'RetenTableListUpdate_20230223':
                        exit('NPR-RetenPolTables-Update-20230223');
                    'HeyLoyaltyWebhookRequests':
                        exit('HeyLoyaltyWebhookRequests-20230525');
                    'M2RecordChangeLogTable':
                        exit('NPR-RetPol-M2RecordChangeLogTable-20230510');
                    'NPRE':
                        exit('NPRE-20230720');
                end;
            Codeunit::"NPR Job Queue Install":
                Case UpgradeStep of
                    'AddJobQueues':
                        exit('NPRJobQueueInstall-20210924');
                    'UpdateJobQueues1':
                        exit('NPRJobQueueUpdate-20211020');
                    'AddTaskCountResetJQ':
                        exit('NPRJobQueueInstall-20211125');
                    'NotifyOnSuccessFalse':
                        exit('NotifyOnSuccessFalse-20220304');
                    'CustomCUforPostInvtCostToGL':
                        exit('CustomCUforPostInvtCostToGL-20220530');
                    'AutoRescheduleRetenPolicy':
                        exit('AutoRescheduleRetenPolicy-20230509');
                    'TMRetentionJQCategory':
                        exit('TMRetentionJQCategory-20220707');
                    'AutoScheduleMembershipStatistics':
                        exit('AutoScheduleMembershipStatistics-20221011');
                    'UpdateAdjCostJobQueueTimeout':
                        exit('UpdateAdjCostJobQueueTimeout-20221216');
                    'SetAutoRescedulePOSPostGL':
                        exit('SetAutoRescedulePOSPostGL-20230131');
                    'SetEndingTimeForPOSPostGLJQ':
                        exit('SetEndingTimeForPOSPostGLJQ-20230809');
                end;
            Codeunit::"NPR New Prices Install":
                exit('NPRNewPriceTableInstall-20210920');
            Codeunit::"NPR UPG Pos Menus":
                case UpgradeStep of
                    'AdjustSplitBillPOSActionParameters':
                        exit('NPRSplitBillActionParamFix_20221201');
                    'AdjustDeletePOSLinePOSActionParameters':
                        exit('NPRDeletePOSLineActionToWF2-938526df-0edf-4c2c-9db8-19e28af11c5a');
                    'PosMenuPaymentButtonsAutoEnabled':
                        exit('NPRPosMenuPaymentButtonsAutoEnabled-20220608');
                end;
            Codeunit::"NPR Event Report Layout Upg.":
                exit('NPREventReportLayoutUpg-20210803');
            Codeunit::"NPR UPG App. Area User Exp.":
                exit('NPR-482497-AppAreaForUserExperience-20210825');
            Codeunit::"NPR UPG Sales Pr. Maint. Setup":
                exit('NPRSalesPriceMaintSetupUpgrade-20210901');
            Codeunit::"NPR UPG Cust. Config. Temp.":
                exit('NPRCustConfigTemplates-20221109');
            Codeunit::"NPR UPG My Notifications":
                exit('NPRRemovePOSNotifications-20230106');
            Codeunit::"NPR UPG Customer Templates":
                exit('NPRCustomerTemplates-20210906');
            Codeunit::"NPR Upgrade Retail Journal":
                exit('NPRRetailJournal-20210912');
            Codeunit::"NPR UPG NpRv Print Object Type":
                exit('InitializeVoucherPrintObjectType_20211021');
            Codeunit::"NPR UPG Web Service Pass":
                case UpgradeStep of
                    'RemoteEndpoints':
                        exit('RemoteEndpointsPasswordUpg-20211029');
                    'RetailInventorySets':
                        exit('RetailInventorySetsPasswordUpg-20211029');
                    'POSHCEndpointSetup':
                        exit('POSHCEndpointSetupPasswordUpg-20211029');
                    'NpXmlTemplate':
                        exit('NpXmlTemplatePasswordUpg-20211029');
                    'NpCsStore':
                        exit('NpCsStorePasswordUpg-20211029');
                    'NpRvPartner':
                        exit('NpRvPartnerPasswordUpg-20211029');
                    'NpRvGlobalVoucher':
                        exit('NpRvGlobalVoucherPasswordUpg-20211029');
                end;
            Codeunit::"NPR Enum Upgrade":
                case UpgradeStep of
                    '':
                        exit('NPREnumUpgrade-20211110');
                    'UpgradeNPREKitchenOrderStatusEnum':
                        exit('NPREKitchenOrderStatusEnumUpgrade_20230601');
                end;
            Codeunit::"NPR UPG Item Blob 2 Media":
                exit('NPRMagentoDescription2Media');
            Codeunit::"NPR UPG Member Blob 2 Media":
                exit('NPMMemberBlob2Media');
            Codeunit::"NPR UPG POS Action Parameters":
                case UpgradeStep of
                    'SalesDocExpPaymentMethodCode':
                        exit('NPR-POSActionPaymentMethodUpgrade-20220127');
                    'SalesDocExpRefreshMenuButtonActions':
                        exit('NPR-POSActionSalesDocExpRefreshMenuButtonActions-20230529');
                    'SalesDocImpRefreshMenuButtonActions':
                        exit('NPR-POSActionSalesDocImpRefreshMenuButtonActions-20230529');
                    'TakePhotoRefreshMenuButtonActions':
                        exit('NPR-TakePhotoRefreshMenuButtonActions-20230622');
                    'ItemIdentifierType':
                        exit('NPR-POSActionItemIdentifierType-20220623');
                    'RefreshReverseDirectSalePOSAction':
                        exit('NPR-POSActionRefreshReverseDirectSalePOSAction-20230628');
                    'ItemPriceIdentifierType':
                        exit('NPR-POSActionItemPriceIdentifierType-20220623');
                    'ItemLookupSmartSearch':
                        exit('NPR-POSActionItemLookupSmartSearch-20220711');
                    'CustomerNo':
                        exit('NPR-POSActionCustomerNo-20221104');
                    'CustomerNoParam':
                        exit('NPR-POSActionCustomerParam-20221115');
                    'POSWorkflow':
                        exit('NPR-POSWorkflow-20221202');
                    'UpdateSecureMethodsDiscount':
                        exit('NPR-POSUpdateSecureMethodsDiscount-20230530');
                    'SecurityParameter':
                        exit('NPR-SecurityParameter-20230711');
                end;
            Codeunit::"NPR Fix POS Entry SystemId":
                exit('NPRFixPOSEntrySystemId_20220126');
            Codeunit::"NPR Upgrade Shipping Provider":
                case UpgradeStep of
                    'NPRShippingProvider':
                        Exit('NPRShippingProvider');
                    'NPRPackageDimensions':
                        Exit('NPRPackageDimensions');
                    'NPRPackageServices':
                        Exit('NPRPackageServices');
                end;
            Codeunit::"NPR UPG E-Mail Setup":
                Exit('NPRUPGUPGEMailSetup-20220312');
            Codeunit::"NPR UPG Object Output":
                Exit('NPRUPGObjectOutput-6e45a4a7887c4210be8059396b7ac71c');
            Codeunit::"NPR UPG MPOS QR Code":
                Exit('NPRUPGMPOSQRCode');
            Codeunit::"NPR UPG DE Audit Setup":
                Exit('RemoveDEFiskalyPOSWorkflowStep');
            Codeunit::"NPR UPG Types":
                case UpgradeStep of
                    '':
                        Exit('NPRUPGTypes-5b2bdcc7-e8b0-4099-8581-aeef6f231f1c');
                    'UpgradeKitcheRequests':
                        Exit('UpgradeKitcheRequests_20230323');
                end;
            Codeunit::"NPR Job Queue Upgrade":
                Exit('NPRUpgradePriceLogTaskQue');
            Codeunit::"NPR UPG PaymentV2":
                Exit('NPRUPGPaymentV2-20220913');
            Codeunit::"NPR POS Display Profile Upg.":
                Exit('NPRPOSDisplayProfileUpg.');
            Codeunit::"NPR UPG FR Audit Setup 2":
                Exit('NPRFRAuditSetup2UPG-2022-08-03');
            Codeunit::"NPR UPG NpXml Template":
                Exit('NPRUPGNpXmlTemplateFtpFieldsToNcEndpoint');
            Codeunit::"NPR TM Calendar Upgrade":
                Exit('NPR_TMCalendarUpgrade_20221011');
            Codeunit::"NPR Rep. Timestamp Upgrade":
                Exit('NPR_RepCounterToSQLTimestampUPG_20221025');
            Codeunit::"NPR UPG Login":
                exit('NPRUPGLogin-20230310');
            CodeUnit::"NPR UPG Print Template":
                case UpgradeStep of
                    'UpgradeReceiptText':
                        exit('UpgradeReceiptText');
                    'UpgradeRJLVendorFields':
                        exit('UpgradeRJLVendorFields');
                    'UpgradeLogoAlignment':
                        exit('UpgradeLogoAlignment');
                end;
            Codeunit::"NPR UPG PG To Interface":
                Exit('NPR_UPG_PG_To_Interface_20221204');
            Codeunit::"NPR HL App Upgrade":
                case UpgradeStep of
                    'MoveHeyLoyaltyValueMappings':
                        exit('MoveHeyLoyaltyValueMappings_20230314');
                end;
            Codeunit::"NPR UPG Vend Item No Expansion":
                case UpgradeStep of
                    'ItemWorksheetLine':
                        exit('NPR-VendItemNo_ItemWorksheetLine-20230105');
                    'RegistItemWorkshLine':
                        exit('NPR-VendItemNo_RegistItemWorkshLine-20230105');
                    'RetailCampaignItems':
                        exit('NPR-VendItemNo_RetailCampaignItems-20230105');
                    'MixedDiscountLine':
                        exit('NPR-VendItemNo_MixedDiscountLine-20230105');
                    'PeriodDiscountLine':
                        exit('NPR-VendItemNo_PeriodDiscountLine-20230105');
                    'RetailReplDemandLine':
                        exit('NPR-VendItemNo_RetailReplDemandLine-20230105');
                    'ItemWorksheetExcelColumn':
                        exit('NPR-VendItemNo_ItemWorksheetExcelColumn-20230105');
                    'ItemWorksheetFieldSetup':
                        exit('NPR-VendItemNo_ItemWorksheetFieldSetup-20230105');
                end;
            Codeunit::"NPR UPG NaviConnect":
                case UpgradeStep of
                    'ImportTypeActionable':
                        exit('NPR-NC-ImportTypeActionable-20230324');
                end;
            Codeunit::"NPR UPG POS Scenarios":
                case UpgradeStep of
                    'ShowReturnAmountDialog':
                        exit('NPR-POSSalesWorkflowStepShowReturnAmountDialog-20230324');
                    'AddNewOnSaleCoupons':
                        exit('NPR-AddNewOnSaleCoupons-20230420');
                    'UpdateDisplayOnSaleLineInsert':
                        exit('NPR-UpdateDisplayOnSaleLineInsert-20230420');
                    'PrintWarrantyAfterSaleLine':
                        exit('NPR-PrintWarrantyAfterSaleLine-20230420');
                    'UpdateTicketOnSaleLineInsert':
                        exit('NPR-UpdateTicketOnSaleLineInsert-20230420');
                    'UpdateMembershipOnSaleLineInsert':
                        exit('NPR-UpdateMembershipOnSaleLineInsert-20230420');
                    'MCSSaleLineUpload':
                        exit('NPR-MCSSaleLineUpload-20230420');
                    'PopupDimension':
                        exit('NPR-PopupDimension-20230531');
                end;
            Codeunit::"NPR Upgrade Variety Setup":
                exit('NPR_Upgrade_Variety_Setup_20230314');
            Codeunit::"NPR UPG Retail Logo":
                exit('NPR_retail_logo_UPG_2023-04-03');
            Codeunit::"NPR UPG BalanceV4":
                exit('NPR_UPG_Balance-20230425');
            Codeunit::"NPR UPG ItemRef. Disc Barcodes":
                case UpgradeStep of
                    'UpgradeDiscBarcodes':
                        exit('UpgradeDiscBarcodes');
                end;
            Codeunit::"NPR UPG Pos Entry Dims":
                case UpgradeStep of
                    '20230515':
                        exit('PosEntryLineDimFix_20230515');
                end;
#IF NOT BC17
            Codeunit::"NPR UPG Permission Set":
                exit('NPRUPGPermissionSet');
#ENDIF
            Codeunit::"NPR FtpSftp Data Upgrade":
                exit('NPR_FTP_SFTP_CONNECTION_UPGRADE');
            Codeunit::"NPR NPRE Upgrade":
                case UpgradeStep of
                    'UpdatePrimarySeating':
                        exit('NPRE_PrimarySeating_20230704');
                    'UpdateKitchenRequestSeatingAndWaiter':
                        exit('NPRE_KitchReqSeatWaiter_20230704');
                    'RefreshKitchenOrderStatus':
                        exit('NPRE_RefreshKitchenOrderStatus_20230704');
                end;
        end;
    end;
}
