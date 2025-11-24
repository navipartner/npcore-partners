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
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Pos Menus", 'POSDataSourceExtFieldSetup'));
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
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'POSPostingLog'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'POSLayoutArchive'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'POSSavedSales'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'RetenTableListUpdate_20230223'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'HeyLoyaltyWebhookRequests'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'NPRE'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'NcTask'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'Shopify'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Reten. Pol. Install", 'NpGpExportLog'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'AddJobQueues'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'UpdateJobQueues1'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'AddTaskCountResetJQ'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'NotifyOnSuccessFalse'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'AddPosSaleDocumentPostingJQ'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'CustomCUforPostInvtCostToGL'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'TMRetentionJQCategory'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'UpdateAdjCostJobQueueTimeout'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'SetAutoRescedulePOSPostGL'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'SetEndingTimeForPOSPostGLJQ'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'SetEndingTimeForAllWithStartingTime'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Install", 'SetManuallySetOnHold'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Upgrade", 'RemoveObsoleteEntraApp'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Upgrade", 'UpdateRefresherUserAssignment'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Upgrade", 'UpdateRefresherUserSettings'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Job Queue Upgrade", 'UpdateJobQueueFieldsFromMonitoredEntry'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR New Prices Install"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Event Report Layout Upg."));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Sales Pr. Maint. Setup"));
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Customer Templates"));
#endif
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
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Action Parameters", 'UpgradePOSNamedActionsProfileItemActionParameters'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Action Parameters", 'UpgradeIssueReturnVoucherContactInfoParameter'));
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
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR HL App Upgrade", 'SetHLSetupDefaultValues'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR HL App Upgrade", 'RemoveDeletedCheckmark'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR HL App Upgrade", 'UpdateHeyLoyaltyDataLogSubscribers'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR HL App Upgrade", 'SetDataProcessingHandlerID'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR HL App Upgrade", 'DisableIntegrationInNonProdutionEnvironments'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR HL App Upgrade", 'ResendMissingUnsubscribeRequestsToHL'));
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
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Scenarios", 'EjectPaymentBinOnCreditSale'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Scenarios", 'SelectionReqParam'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Scenarios", 'DimPopupEvery'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Scenarios", 'PrintCreditVoucherOnSale'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Scenarios", 'EmailReceiptOnSale'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Scenarios", 'UpgradeAuditProfile'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Scenarios", 'DeliverCollectDocument'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Scenarios", 'UpgradeMemberProfile'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Scenarios", 'UpgradeLoyaltyProfile'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Scenarios", 'UpgradeTicketProfile'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Scenarios", 'DeleteFinishSaleWorkflowSteps'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Scenarios", 'DeleteFinishCreditSaleWorkflowSteps'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Scenarios", 'TestItemInventory'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG BalanceV4"));
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG ItemRef. Disc Barcodes", 'UpgradeDiscBarcodes'));
#endif
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Pos Entry Dims", '20230515'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Enum Upgrade", 'UpgradeNPREKitchenOrderStatusEnum'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR FtpSftp Data Upgrade"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Tax Free", 'NPRTaxFreePOSProfileTable'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Tax Free", 'NPRTaxFreePOSProfile'));
#IF NOT (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Item Upgrade", 'PopulateItemVariantNewField'));
#ENDIF
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", 'UpdatePrimarySeating'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", 'UpdateKitchenRequestSeatingAndWaiter'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", 'RefreshKitchenOrderStatus'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", 'UpdateDefaultNumberOfGuests'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", 'SetPrintOnSaleCancel'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", 'UpdateKitchenRequestProductionStatuses'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", 'UpdateOrderFinishedDT'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", 'UpdateRVNewWaiterPadPosActionParams'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Feature Management Install", 'AddFeatures'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Obsolete Tables Cleanup"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Obsolete Tables Cleanup", 'CleanupAuxGLEntry'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Obsolete Tables Cleanup", 'CleanupAuditRoll'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Posting Profile", 'MoveAsyncPostingSetup'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Feature Flags Install", 'PrepareFeatureFlags'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Feature Flags Upgrade", 'PrepareFeatureFlags'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Feature Flags Upgrade", 'CleanAndRecreateGetFeatureFlagJobQueueEntry'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Input Box Events", 'UpgradeTicketArrivalActionCode'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR BG SIS Upgrade", 'add-salesperson-to-bg-sis-audit-log'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR BG SIS Upgrade", 'blank-item-description'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR BG SIS Upgrade", 'init-customer-id-no-type-on-bg-sis-audit-log'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Rcpt. Profile", 'CreatePOSRcptProfileAssignToPOSUnits'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POSMenu Actions v3", 'MM_MEMBERMGT'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POSMenu Actions v3", 'MM_MEMBERMGMT_WF2'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POSMenu Actions v3", 'SCAN_VOUCHER'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POSMenu Actions v3", 'ISSUE_RETURN_VOUCHER'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POSMenu Actions v3", 'PAYIN_PAYOUT'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POSMenu Actions v3", 'TM_TICKETMGMT'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POSMenu Actions v3", 'TM_TICKETMGMT_2'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Vipps Mp Setup", 'VippsMobilepaySetup'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Standard Exch. Rate", 'UpdateStandardExchangeRateForBalancing'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG BG Vision", 'UpdateBGVisionVatSubject'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR POS Layout Upgrade", 'UpgradePOSLayoutEncoding'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR POS Layout Upgrade", 'UpgradeArchivedPOSLayoutEncoding'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POSMenu Actions v3", 'MM_MEMBERMGT-1'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POSMenu Actions v3", 'MM_MEMBERMGMT_WF2-1'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POSMenu Actions v3", 'UpgradeOSMenuButtonParameterActionCodes'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", 'UpdatePSPReferenceForEFTTrans'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", 'UpdateAdyenSetupCompanyID'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", 'UpdateAdyenReconLinePostingAllowed'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", 'UpdateAdyenReconciliationStatus'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", 'UpdateAdyenReconciliationDocumentProcessingStatus'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", 'UpdateAdyenReconciliationRelation'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", 'UpdateManuallyMatchedLines'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", 'FixMagentoPaymentLines'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", 'UpgradeMerchantAccountSetups'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", 'FixUnreconciledMagentoRefundPaymentLines'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", 'RecreateForeignCurrencyDocuments'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Entry Posting", 'UpgradePOSEntryDeferralSchedule'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Entry Posting", 'UpgradeMembershipEntryLinkDates'));

#if not BC17
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", 'SetDataProcessingHandlerID'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", 'PhaseOutShopifyCCIntegration'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", 'StoreSpecificIntegrationSetups'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", 'UpdateShopifyPaymentModule'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", 'UpdateShopifyStoreDoNotSyncSalesPrices'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", 'EnableItemRelatedDataLogSubscribers'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", 'RemoveIncorrectlyAssignedIDs'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", 'RegisterShopifyAppRequestListenerWebservice'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", 'UpgradeAllowedFinancialStatuses'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", 'RescheduleInventorySync'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", 'UpdateMetafieldDataLogSetup'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", 'SetDefaultProductStatus'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", 'RemoveOrphanShopifyAssignedIDs'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", 'UpdateGetPaymentLinesFromShopifyOption'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", 'MoveMetafieldValueToBlobField'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", 'UpdateMetafieldTaskSetup'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", 'CreateSOIntegrationRelatedDataLogSetups'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", 'MoveCustomerAssignedIDs'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", 'MoveLastOrdersImportedAt'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", 'UpdateShopifyInventoryLocations'));
#endif
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Dig. Rcpt. Enable", 'UpgradeDigitalReceiptSetupEnable'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Dig. Rcpt. Enable", 'UpdateDigitalReceiptSetupTable'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR New Feature Handler", 'POSEditorFeatureHandle'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR New Feature Handler", 'ScenarioObsoletedFeatureHandle'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR New Feature Handler", 'POSStatisticsDashboardFeatureHandle'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR New Feature Handler", 'NewSalesReceiptExperienceHandle'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR New Feature Handler", 'NewEFTReceiptExperienceHandle'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR New Feature Handler", 'NewAttractionPrintExperienceHandle'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG New Feature Handler", 'POSEditorFeatureHandle'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG New Feature Handler", 'ScenarioObsoletedFeatureHandle'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG New Feature Handler", 'POSStatisticsDashboardFeatureHandle'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG New Feature Handler", 'NewSalesReceiptExperienceHandle'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG New Feature Handler", 'NewEFTReceiptExperienceHandle'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG New Feature Handler", 'NewAttractionPrintExperienceHandle'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Pay By Link Setup", 'UpdatePayByLinkSetup'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS EFT Pay Res. Setup", 'UpdatePOSEFTPayResSetup'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Update Wizards", 'UpdateWizardFiscalization'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Subscriptions", 'CreateSubscriptions'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Subscriptions", 'ScheduleSubscriptionRequestCreationJobQueue'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Subscriptions", 'ScheduleSubscriptionPaymentRequestProcessingJobQueue'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Subscriptions", 'ScheduleSubscriptionRequestProcessingJobQueue'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Subscriptions", 'SetMaxRecurringPaymentProcessingTryCount'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Subscriptions", 'SetMaxSubscriptionRequestProcessingTryCount'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Subscriptions", 'UpdateSubscriptionAutoRenewStatus'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Subscriptions", 'UpdateSubscriptionRenewProcJobStartTime'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Subscriptions", 'UpdateSubscriptionRenewReqJobStartTime'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Subscriptions", 'UpgradeTerminationSubsRequest'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Subscriptions Install", 'ScheduleSubscriptionRequestCreationJobQueue'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Subscriptions Install", 'ScheduleSubscriptionPaymentRequestProcessingJobQueue'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Subscriptions Install", 'ScheduleSubscriptionRequestProcessingJobQueue'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Pay View Dimension", 'SetDimensionMandatoryTrueForListOption'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Dragonglass Service", 'PublishDragonglassWebService'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Global Sales", 'SetIsReturnOnGlobalPOSSalesLine'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Adyen Refund", 'CreateAdyenRefundjobs'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR VoucherAmtReserve Upgrade"));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Adyen Api Key", 'UpgradeEFTAdyenPaymentTypeApiKey'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Adyen Api Key", 'UpgradeAdyenManagmentApiKey'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Adyen Api Key", 'UpgradeAdyenDownloadReportApiKey'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR POS Audit Log Upgrade", 'update-additional-information-in-pos-audit-log'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG NP Pay POSPaymentSetup", 'UpgradeNPPayPOSPaymentSetupApiKey'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR Magento Upgrade", 'EnableMagentoFeature'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Adyen Warning Days", 'UpdateAdyenSetup'));
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Inc Ecom Sales Docs", 'CreateIncEcomSalesDocSetup'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Inc Ecom Sales Docs", 'UpgradeDocumentsToNewTables'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Inc Ecom Sales Docs", 'UpgradeSalesOrderJQ'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Inc Ecom Sales Docs", 'UpgradeSalesReturnOrderJQ'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Ecom Sales Docs", 'UpgradeEcomSalesDocJQ'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Ecom Sales Docs", 'UpgradeEcomSalesReturnDocJQ'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG Ecom Sales Docs", 'UpgradeBucketId'));
#endif
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG No Series Experience", 'UpgradeImplementationFieldOnNoSeries'));
#ENDIF
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POSSalDigRcpEntrTransf", 'UpgradePOSSaleDigitalReceiptEntryTransfer'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPG POS Customer Input", 'UpgradePOSCustomerInputEntryInputTransfer'));
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR POS License Billing Upgrd.", 'AddPOSBillingFeature'));
#endif
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR RS Retail Calculation Upg.", 'MatchRemainingQtyToRSRetailValueEntryMapping'));
        PerCompanyUpgradeTags.Add(GetUpgradeTag(Codeunit::"NPR UPGUserAccounts", 'UpgradeBCRecordSystemIdInMemberPaymentMethods'));
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
                    'POSPostingLog':
                        exit('NPR-RetenPolTables-POSPostingLog-20230922');
                    'POSLayoutArchive':
                        exit('NPR-RetenPolTables-POSLayoutArchive-20221207');
                    'POSSavedSales':
                        exit('NPR-RetenPolTables-POSSavedSales-20221223');
                    'RetenTableListUpdate_20230223':
                        exit('NPR-RetenPolTables-Update-20231115');
                    'HeyLoyaltyWebhookRequests':
                        exit('HeyLoyaltyWebhookRequests-20230525');
                    'M2RecordChangeLogTable':
                        exit('NPR-RetPol-M2RecordChangeLogTable-20230510');
                    'NPRE':
                        exit('NPRE-20230720');
                    'NcTask':
                        exit('NcTask-20231017');
                    'SalesPriceMaintenance':
                        exit('SalesPriceMaintenance-20240523');
                    'Shopify':
                        exit('Shopify-20250204');
                    'NpGpExportLog':
                        exit('NpGpExportLog-20250210');
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
                    'AddPosSaleDocumentPostingJQ':
                        exit('AddPosSaleDocumentPostingJQ-20230802');
                    'CustomCUforPostInvtCostToGL':
                        exit('CustomCUforPostInvtCostToGL-20220530');
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
                    'SetEndingTimeForAllWithStartingTime':
                        exit('SetEndingTimeForAllWithStartingTime-20231010');
                    'SetManuallySetOnHold':
                        exit('SetManuallySetOnHold-20230818');
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
                    'POSDataSourceExtFieldSetup':
                        exit('NPRGeneratePOSDataSourceExtFieldSetup-20231003');
                end;
            Codeunit::"NPR Event Report Layout Upg.":
                exit('NPREventReportLayoutUpg-20210803');
            Codeunit::"NPR UPG Sales Pr. Maint. Setup":
                exit('NPRSalesPriceMaintSetupUpgrade-20210901');
            Codeunit::"NPR UPG Cust. Config. Temp.":
                exit('NPRCustConfigTemplates-20221109');
            Codeunit::"NPR UPG My Notifications":
                exit('NPRRemovePOSNotifications-20230106');
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25
            Codeunit::"NPR UPG Customer Templates":
                exit('NPRCustomerTemplates-20210906');
#endif
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
                    'UpgradePOSNamedActionsProfileItemActionParameters':
                        exit('NPR-UpgradePOSNamedActionsProfileItemActionParameters-20231006');
                    'UpgradeIssueReturnVoucherContactInfoParameter':
                        exit('NPR-UpgradeIssueReturnVoucherContactInfoParameter-20231114');
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
                case UpgradeStep of
                    '':
                        Exit('NPRUpgradePriceLogTaskQue');
                    'RemoveObsoleteEntraApp':
                        Exit('NPRRemoveObsoleteEntraApp-20250319');
                    'UpdateRefresherUserAssignment':
                        Exit('UpdateRefresherUserAssignment-20250614');
                    'UpdateRefresherUserSettings':
                        Exit('UpdateRefresherUserSettings-20250615');
                    'UpdateJobQueueFieldsFromMonitoredEntry':
                        Exit('UpdateJobQueueFieldsFromMonitoredEntry-20250710');
                end;
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
                    'SetHLSetupDefaultValues':
                        exit('SetHLSetupDefaultValues_20231019');
                    'RemoveDeletedCheckmark':
                        exit('RemoveDeletedCheckmark_20231024');
                    'UpdateHeyLoyaltyDataLogSubscribers':
                        exit('UpdateHeyLoyaltyDataLogSubscribers_20231024');
                    'SetDataProcessingHandlerID':
                        exit('NPR-HL-SetDataProcessingHandlerID-20240610');
                    'DisableIntegrationInNonProdutionEnvironments':
                        exit('NPR-HL-DisableIntegrationInNonProdutionEnvironments-20240712');
                    'ResendMissingUnsubscribeRequestsToHL':
                        exit('NPR-HL-ResendMissingUnsubscribeRequestsToHL-20240712');
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
                    'SelectionReqParam':
                        exit('NPR-SelectionReqParam-20231017');
                    'DimPopupEvery':
                        exit('NPR-DimPopupEvery-20231031');
                    'EjectPaymentBinOnCreditSale':
                        exit('NPR-EjectPaymentBinOnCreditSale-20231129');
                    'PrintCreditVoucherOnSale':
                        exit('NPR-PrintCreditVoucherOnSale-20231204');
                    'EmailReceiptOnSale':
                        exit('NPR-EmailReceiptOnSale-20240430');
                    'UpgradeAuditProfile':
                        exit('NPR-UpgradeAuditProfile-20240507');
                    'DeliverCollectDocument':
                        exit('NPR-DeliverCollectDocument-20240507');
                    'UpgradeMemberProfile':
                        exit('NPR-UpgradeMemberProfile-20240507');
                    'UpgradeLoyaltyProfile':
                        exit('NPR-UpgradeLoyaltyProfile-20240507');
                    'UpgradeTicketProfile':
                        exit('NPR-UpgradeTicketProfile-20240507');
                    'DeleteFinishSaleWorkflowSteps':
                        exit('NPR-DeleteFinishSaleWorkflowSteps-20240507');
                    'DeleteFinishCreditSaleWorkflowSteps':
                        exit('NPR-DeleteFinishCreditSaleWorkflowSteps-20240507');
                    'TestItemInventory':
                        exit('NPR-TestItemInventory-20251409');
                end;
            Codeunit::"NPR Upgrade Variety Setup":
                case UpgradeStep of
                    '':
                        exit('NPR_Upgrade_Variety_Setup_20230314');
                    'MoveVariantValueCode':
                        exit('NPR_Move_VariantValueCode_20230711');
                end;
            Codeunit::"NPR UPG Retail Logo":
                exit('NPR_retail_logo_UPG_2023-04-03');
            Codeunit::"NPR UPG BalanceV4":
                exit('NPR_UPG_Balance-20230425');
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25
            Codeunit::"NPR UPG ItemRef. Disc Barcodes":
                case UpgradeStep of
                    'UpgradeDiscBarcodes':
                        exit('UpgradeDiscBarcodes');
                end;
#endif
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
            Codeunit::"NPR UPG Tax Free":
                case UpgradeStep of
                    'NPRTaxFreePOSProfileTable':
                        Exit('NPRTaxFreePOSProfileTables');
                    'NPRTaxFreePOSProfile':
                        Exit('NPRTaxFreePOSProfiles');
                end;
            Codeunit::"NPR NPRE Upgrade":
                case UpgradeStep of
                    'UpdatePrimarySeating':
                        exit('NPRE_PrimarySeating_20230704');
                    'UpdateKitchenRequestSeatingAndWaiter':
                        exit('NPRE_KitchReqSeatWaiter_20230704');
                    'RefreshKitchenOrderStatus':
                        exit('NPRE_RefreshKitchenOrderStatus_20230704');
                    'UpdateDefaultNumberOfGuests':
                        exit('NPRE_UpdateDefaultNumberOfGuests_20230919');
                    'SetPrintOnSaleCancel':
                        exit('NPRE_SetPrintOnSaleCancel_20231026');
                    'UpdateKitchenRequestProductionStatuses':
                        exit('NPRE_UpdateKitchenRequestProductionStatuses_20240208');
                    'UpdateOrderFinishedDT':
                        exit('NPRE_UpdateOrderFinishedDT_20240528');
                    'UpdateRVNewWaiterPadPosActionParams':
                        exit('NPRE_UpdateRVNewWaiterPadPosActionParams_20240808');
                end;

            Codeunit::"NPR Item Upgrade":
                case UpgradeStep of
#IF NOT (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
                    'PopulateItemVariantNewField':
                        exit('Item_PopulateItemVariant_20240213');
#ENDIF
                end;
            Codeunit::"NPR Feature Flags Install":
                case UpgradeStep of
                    'PrepareFeatureFlags':
                        exit('Install_PrepareFeatureFlags-20230830');
                end;
            Codeunit::"NPR Feature Flags Upgrade":
                case UpgradeStep of
                    'PrepareFeatureFlags':
                        exit('Upgrade_PrepareFeatureFlags-20240521');
                    'CleanAndRecreateGetFeatureFlagJobQueueEntry':
                        exit('Upgrade_CleanAndRecreateGetFeatureFlagJobQueueEntry-20231122');
                end;
            Codeunit::"NPR Feature Management Install":
                case UpgradeStep of
                    'AddFeatures':
                        exit('FeaturesInstall-20230818');
                end;
            Codeunit::"NPR Obsolete Tables Cleanup":
                case UpgradeStep of
                    '':
                        exit('NPR-ObsoleteTablesCleanup');
                    'CleanupAuxGLEntry':
                        exit('NPR-ObsoleteTablesCleanup_CleanupAuxGLEntry');
                    'CleanupAuditRoll':
                        exit('NPR-ObsoleteTablesCleanup_AuditRoll');
                end;
            Codeunit::"NPR Upgrade Access Tokens":
                case UpgradeStep of
                    'ClearAccessToken':
                        exit('ClearAccessToken-02102023');
                end;
            Codeunit::"NPR Upg NC Import List Process":
                case UpgradeStep of
                    'UpdateImportTypeFields':
                        exit('UpdateImportTypeFields-17102023');
                end;
            Codeunit::"NPR UPG POS Posting Profile":
                case UpgradeStep of
                    'MoveAsyncPostingSetup':
                        exit('MoveAsyncPostingSetup_20231011');
                end;
            Codeunit::"NPR UPG POS Input Box Events":
                case UpgradeStep of
                    'UpgradeTicketArrivalActionCode':
                        exit('NPR-UpgradeTicketArrivalActionCode-20240111');
                end;
            Codeunit::"NPR BG SIS Upgrade":
                case UpgradeStep of
                    'add-salesperson-to-bg-sis-audit-log':
                        exit('NPR-add-salesperson-to-bg-sis-audit-log-20240111');
                    'blank-item-description':
                        exit('NPR-blank-item-description-20240115');
                    'init-customer-id-no-type-on-bg-sis-audit-log':
                        exit('NPR-init-customer-id-no-type-on-bg-sis-audit-log-20240226');
                end;
            Codeunit::"NPR UPG POS Rcpt. Profile":
                case UpgradeStep of
                    'CreatePOSRcptProfileAssignToPOSUnits':
                        exit('NPR-CreatePOSRcptProfileAssignToPOSUnits-20240124');
                end;
            Codeunit::"NPR UPG POSMenu Actions v3":
                case UpgradeStep of
                    'MM_MEMBERMGT':
                        exit('NPR-MM_MEMBERMGT-20241602');
                    'MM_MEMBERMGT-1':
                        exit('NPR-MM_MEMBERMGT-20240515');
                    'MM_MEMBERMGMT_WF2':
                        exit('NPR-MM_MEMBERMGMT_WF2-20241602');
                    'MM_MEMBERMGMT_WF2-1':
                        exit('NPR-MM_MEMBERMGMT_WF2-20240515');
                    'ISSUE_RETURN_VOUCHER':
                        exit('NPR-ISSUE_RETURN_VOUCHER-20241602');
                    'PAYIN_PAYOUT':
                        exit('NPR-PAYIN_PAYOUT-20241602');
                    'TM_TICKETMGMT':
                        exit('NPR-TM_TICKETMGMT-20241602');
                    'TM_TICKETMGMT_2':
                        exit('NPR-TM_TICKETMGMT_2-20241602');
                    'TM_TICKETMGMT-1':
                        exit('NPR-TM_TICKETMGMT-20240515');
                    'TM_TICKETMGMT_2-1':
                        exit('NPR-TM_TICKETMGMT_2-2024015');
                    'SCAN_VOUCHER':
                        exit('NPR-SCAN_VOUCHER-20241602');
                    'UpgradeOSMenuButtonParameterActionCodes':
                        exit('UpgradeOSMenuButtonParameterActionCodes-20240605');
                end;
            Codeunit::"NPR UPG Vipps Mp Setup":
                begin
                    exit('VippsMobilepaySetup');
                end;
            Codeunit::"NPR UPG Standard Exch. Rate":
                case UpgradeStep of
                    'UpdateStandardExchangeRateForBalancing':
                        exit('NPR-UpdateStandardExchangeRateForBalancing-20240304');
                end;
            Codeunit::"NPR Shipping Provider Upgrade":
                case UpgradeStep of
                    'UpgradeShippingProviderCodePackageShippingAgent':
                        exit('NPR-UpgradeShippingProviderCodePackageShippingAgent-20240314');
                end;
            Codeunit::"NPR UPG BG Vision":
                case UpgradeStep of
                    'UpdateBGVisionVatSubject':
                        exit('NPR-UpdateBGVisionVatSubject-20240315')
                end;
            Codeunit::"NPR POS Layout Upgrade":
                case UpgradeStep of
                    'UpgradePOSLayoutEncoding':
                        exit('NPR-UpgradePOSLayoutEncoding-20240402');
                    'UpgradeArchivedPOSLayoutEncoding':
                        exit('NPR-UpgradeArchivedPOSLayoutEncoding-20240405');
                end;
            Codeunit::"NPR Adyen Recon. Upgrade":
                case UpgradeStep of
                    'UpdatePSPReferenceForEFTTrans':
                        exit('NPR-UpdatePSPReferenceForEFTTrans-20240603');
                    'UpdateAdyenSetupCompanyID':
                        exit('NPR-UpdateAdyenSetupCompanyID-20240614');
                    'UpdateAdyenReconLinePostingAllowed':
                        exit('NPR-UpdateAdyenReconLinePostingAllowed-20240626');
                    'UpdateAdyenReconciliationStatus':
                        exit('NPR-UpdateAdyenReconciliationStatus-20241112');
                    'UpdateAdyenReconciliationDocumentProcessingStatus':
                        exit('NPR-UpdateAdyenReconciliationDocumentProcessingStatus-20241004');
                    'UpdateAdyenReconciliationRelation':
                        exit('NPR-UpdateAdyenReconciliationRelation-20241204');
                    'UpdateManuallyMatchedLines':
                        exit('NPR-UpdateManuallyMatchedLines-20241224');
                    'FixMagentoPaymentLines':
                        exit('NPR-FixMagentoPaymentLines-20250303');
                    'UpgradeMerchantAccountSetups':
                        exit('NPR-UpgradeMerchantAccountSetups-20250408');
                    'FixUnreconciledMagentoRefundPaymentLines':
                        exit('NPR-FixUnreconciledMagentoRefundPaymentLines-20250716');
                    'RecreateForeignCurrencyDocuments':
                        exit('NPR-RecreateForeignCurrencyDocuments-20250710');
                end;
            Codeunit::"NPR UPG POS Entry Posting":
                case UpgradeStep of
                    'UpgradePOSEntryDeferralSchedule':
                        exit('NPR-UpgradePOSEntryDeferralSchedule-20250924');
                    'UpgradeMembershipEntryLinkDates':
                        exit('NPR-UpgradeMembershipEntryLinkDates-20251006');
                end;
#if not BC17
            Codeunit::"NPR Spfy App Upgrade":
                case UpgradeStep of
                    'SetDataProcessingHandlerID':
                        exit('NPR-Spfy-SetDataProcessingHandlerID-20240610');
                    'PhaseOutShopifyCCIntegration':
                        exit('NPR-Spfy-PhaseOutShopifyCCIntegration-20240814');
                    'StoreSpecificIntegrationSetups':
                        exit('NPR-Spfy-StoreSpecificIntegrationSetups-20240821');
                    'UpdateShopifyPaymentModule':
                        exit('NPR-Spfy-UpdateShopifyPaymentModule-20240919');
                    'UpdateShopifyStoreDoNotSyncSalesPrices':
                        exit('NPR-Spfy-UpdateShopifyStoreDoNotSyncSalesPrices-20241031');
                    'EnableItemRelatedDataLogSubscribers':
                        exit('NPR-Spfy-EnableItemRelatedDataLogSubscribers-20250204');
                    'RemoveIncorrectlyAssignedIDs':
                        exit('NPR-Spfy-RemoveIncorrectlyAssignedIDs-20241118');
                    'RegisterShopifyAppRequestListenerWebservice':
                        exit('NPR-Spfy-RegisterShopifyAppRequestListenerWebservice-20250130');
                    'UpgradeAllowedFinancialStatuses':
                        exit('NPR-Spfy-UpgradeAllowedFinancialStatuses-20250216');
                    'RescheduleInventorySync':
                        exit('NPR-Spfy-RescheduleInventorySync-20250225');
                    'UpdateMetafieldDataLogSetup':
                        exit('NPR-Spfy-UpdateMetafieldDataLogSetup-20250316');
                    'SetDefaultProductStatus':
                        exit('NPR-Spfy-SetDefaultProductStatus-20250321');
                    'RemoveOrphanShopifyAssignedIDs':
                        exit('NPR-Spfy-RemoveOrphanShopifyAssignedIDs-20250515');
                    'UpdateGetPaymentLinesFromShopifyOption':
                        exit('NPR-Spfy-UpdateGetPaymentLinesFromShopifyOption-20250730');
                    'MoveMetafieldValueToBlobField':
                        exit('NPR-Spfy-MoveMetafieldValueToBlobField-20250803');
                    'UpdateMetafieldTaskSetup':
                        exit('NPR-Spfy-UpdateMetafieldTaskSetup-20250915');
                    'CreateSOIntegrationRelatedDataLogSetups':
                        exit('NPR-Spfy-CreateSOIntegrationRelatedDataLogSetups-20250915');
                    'MoveCustomerAssignedIDs':
                        exit('NPR-Spfy-MoveCustomerAssignedIDs-20250915');
                    'MoveLastOrdersImportedAt':
                        exit('NPR-Spfy-MoveLastOrdersImportedAt-20251031');
                    'UpdateShopifyInventoryLocations':
                        exit('NPR-Spfy-UpdateShopifyInventoryLocations-20251120');
                end;
#endif
            Codeunit::"NPR UPG Dig. Rcpt. Enable":
                case UpgradeStep of
                    'UpgradeDigitalReceiptSetupEnable':
                        exit('NPR-UpgradeDigitalReceiptSetupEnable-20240721');
                    'UpdateDigitalReceiptSetupTable':
                        exit('NPR-UpdateDigitalReceiptSetupTable-20240821')
                end;
            Codeunit::"NPR New Feature Handler":
                case UpgradeStep of
                    'POSEditorFeatureHandle':
                        exit('NPR-POSEditorFeatureHandle-20240821');
                    'ScenarioObsoletedFeatureHandle':
                        exit('NPR-ScenarioObsoletedFeatureHandle-20240821');
                    'POSStatisticsDashboardFeatureHandle':
                        exit('NPR-POSStatisticsDashboardFeatureHandle-20241014');
                    'NewSalesReceiptExperienceHandle':
                        exit('NPR-NewSalesReceiptExperienceHandle-20250316');
                    'NewEFTReceiptExperienceHandle':
                        exit('NPR-NewEFTReceiptExperienceHandle-20250316');
                    'NewAttractionPrintExperienceHandle':
                        exit('NPR-NewAttractionPrintExperienceHandle-20250924');
                end;
            Codeunit::"NPR UPG New Feature Handler":
                case UpgradeStep of
                    'POSEditorFeatureHandle':
                        exit('NPR-POSEditorFeatureHandle-20240821');
                    'ScenarioObsoletedFeatureHandle':
                        exit('NPR-ScenarioObsoletedFeatureHandle-20240821');
                    'POSStatisticsDashboardFeatureHandle':
                        exit('NPR-POSStatisticsDashboardFeatureHandle-20241014');
                    'NewSalesReceiptExperienceHandle':
                        exit('NPR-NewSalesReceiptExperienceHandle-20250316');
                    'NewEFTReceiptExperienceHandle':
                        exit('NPR-NewEFTReceiptExperienceHandle-20250316');
                    'NewAttractionPrintExperienceHandle':
                        exit('NPR-NewAttractionPrintExperienceHandle-20250924');
                end;
            Codeunit::"NPR UPG Pay By Link Setup":
                case UpgradeStep of
                    'UpdatePayByLinkSetup':
                        exit('NPR-UpdatePayByLinkSetup-20240913');
                end;
            Codeunit::"NPR UPG POS EFT Pay Res. Setup":
                case UpgradeStep of
                    'UpdatePOSEFTPayResSetup':
                        exit('NPR-UpdatePOSEFTPayResSetup-20240916');
                end;
            Codeunit::"NPR UPG Update Wizards":
                case UpgradeStep of
                    'UpdateWizardFiscalization':
                        exit('NPR-UpdateWizardFiscalization-20240926');
                end;
            Codeunit::"NPR Subscriptions Install":
                case UpgradeStep of
                    'CreateSubscriptions':
                        exit('NPR-CreateSubscriptions-20241015');
                    'ScheduleSubscriptionRequestCreationJobQueue':
                        exit('NPR-ScheduleSubscriptionRequestCreationJobQueue-20241015');
                    'ScheduleSubscriptionPaymentRequestProcessingJobQueue':
                        exit('NPR-ScheduleSubscriptionPaymentRequestProcessingJobQueue-20241015');
                    'ScheduleSubscriptionRequestProcessingJobQueue':
                        exit('NPR-ScheduleSubscriptionRequestProcessingJobQueue-20241015');
                end;
            Codeunit::"NPR UPG Subscriptions":
                case UpgradeStep of
                    'CreateSubscriptions':
                        exit('NPR-CreateSubscriptions-20241015');
                    'ScheduleSubscriptionRequestCreationJobQueue':
                        exit('NPR-ScheduleSubscriptionRequestCreationJobQueue-20241015');
                    'ScheduleSubscriptionPaymentRequestProcessingJobQueue':
                        exit('NPR-ScheduleSubscriptionPaymentRequestProcessingJobQueue-20241015');
                    'ScheduleSubscriptionRequestProcessingJobQueue':
                        exit('NPR-ScheduleSubscriptionRequestProcessingJobQueue-20241015');
                    'SetMaxRecurringPaymentProcessingTryCount':
                        exit('NPR-SetMaxRecurringPaymentProcessingTryCount-20241015');
                    'SetMaxSubscriptionRequestProcessingTryCount':
                        exit('NPR-SetMaxSubscriptionRequestProcessingTryCount-20241015');
                    'UpdateSubscriptionAutoRenewStatus':
                        exit('NPR-UpdateSubscriptionAutoRenewStatus-20241112');
                    'UpdateSubscriptionRenewReqJobStartTime':
                        exit('NPR-UpdateSubscriptionRenewReqJobStartTime-20250227');
                    'UpdateSubscriptionRenewProcJobStartTime':
                        exit('NPR-UpdateSubscriptionRenewProcJobStartTime-20250227');
                    'UpgradeTerminationSubsRequest':
                        exit('NPR-UpgradeTerminationSubsRequest-20251103');
                end;
            Codeunit::"NPR UPG POS Pay View Dimension":
                case UpgradeStep of
                    'SetDimensionMandatoryTrueForListOption':
                        exit('NPR-SetDimensionMandatoryTrueForListOption-20241105');
                end;
            Codeunit::"NPR UPG Dragonglass Service":
                case UpgradeStep of
                    'PublishDragonglassWebService':
                        exit('NPR-PublishDragonglassWebService-20241218')
                end;
            Codeunit::"NPR UPG Global Sales":
                case UpgradeStep of
                    'SetIsReturnOnGlobalPOSSalesLine':
                        exit('NPR-SetIsReturnOnGlobalPOSSalesLine-20241227')
                end;
            Codeunit::"NPR UPG Adyen Refund":
                case UpgradeStep of
                    'CreateAdyenRefundJobs':
                        exit('NPR-CreateAdyenRefundJobs-20250128')
                end;
            Codeunit::"NPR VoucherAmtReserve Upgrade":
                exit('NPRVoucherAmtReserveUpgrade-20250327');
            Codeunit::"NPR UPG Adyen Api Key":
                case UpgradeStep of
                    'UpgradeEFTAdyenPaymentTypeApiKey':
                        exit('NPR-UpgradeEFTAdyenPaymentTypeApiKey-20250403');
                    'UpgradeAdyenManagmentApiKey':
                        exit('NPR-UpgradeAdyenManagmentApiKey-20250403');
                    'UpgradeAdyenDownloadReportApiKey':
                        exit('NPR-UpgradeAdyenDownloadReportApiKey-20250403');
                end;
            Codeunit::"NPR POS Audit Log Upgrade":
                case UpgradeStep of
                    'update-additional-information-in-pos-audit-log':
                        exit('NPR-update-additional-information-in-pos-audit-log-20250411');
                end;
            Codeunit::"NPR UPGTicket":
                case UpgradeStep of
                    'CouponProfileForceAmountBoolToEnum':
                        exit('NPR-Update-TicketCouponProfile-ForceAmountBoolToEnum-20250416');
                end;
            Codeunit::"NPR UPG NP Pay POSPaymentSetup":
                case UpgradeStep of
                    'UpgradeNPPayPOSPaymentSetupApiKey':
                        exit('NPR-UpgradeNPPayPOSPaymentSetupApiKey-20250511');
                end;
            Codeunit::"NPR UPG BC Health Check WS":
                case UpgradeStep of
                    'RegisterService':
                        exit('NPR-RegisterBCHealthCheckWebService-20250515');
                end;
            Codeunit::"NPR UPG API WS":
                case UpgradeStep of
                    'APIWS_041224_MMV':
                        exit('NPR-RegisterRestApiWs-20250515');
                end;
            Codeunit::"NPR Magento Upgrade":
                case UpgradeStep of
                    'EnableMagentoFeature':
                        exit('NPR-EnableMagentoFeature-20250610');
                end;
            Codeunit::"NPR UPG Adyen Warning Days":
                case UpgradeStep of
                    'UpdateAdyenSetup':
                        exit('NPR-UpdateAdyenSetup-20250523');
                end;

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
            Codeunit::"NPR UPG Inc Ecom Sales Docs":
                case UpgradeStep of
                    'CreateIncEcomSalesDocSetup':
                        exit('NPR-CreateIncEcomSalesDocSetup-20250608');
                    'UpgradeDocumentsToNewTables':
                        exit('NPR-UpgradeDocumentsToNewTables-20251022');
                    'UpgradeSalesOrderJQ':
                        exit('NPR-UpgradeSalesOrderJQ-20251022');
                    'UpgradeSalesReturnOrderJQ':
                        exit('NPR-UpgradeSalesReturnOrderJQ-20251022');
                    'UpgradeRetryCounts':
                        exit('NPR-UpgradeRetryCounts-20251109');
                end;
            Codeunit::"NPR UPG Ecom Sales Docs":
                case UpgradeStep of
                    'UpgradeEcomSalesDocJQ':
                        exit('NPR-UpgradeEcomSalesDocJQ-20251117');
                    'UpgradeEcomSalesReturnDocJQ':
                        exit('NPR-UpgradeEcomSalesReturnDocJQ-20251117');
                    'UpgradeBucketId':
                        exit('NPR-UpgradeBucketId-20251117');
                end;
#endif
            Codeunit::"NPR UPGUserAccounts":
                case UpgradeStep of
                    'UpgradeSubscriptionsToAccounts':
                        exit('NPR-UpgradeSubscriptionsToAccounts-20250613');
                    'UpgradeBCRecordSystemIdInMemberPaymentMethods':
                        exit('NPR-UpgradeBCRecordSystemIdInMemberPaymentMethods-20251116');
                end;
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            Codeunit::"NPR UPG No Series Experience":
                case UpgradeStep of
                    'UpgradeImplementationFieldOnNoSeries':
                        exit('NPR-UpgradeImplementationFieldOnNoSeries-20250608');
                end;
#ENDIF
#if not BC17
            Codeunit::"NPR UPG NpEc Config. Templates":
                Exit('NPREcTransferConfigTemplToCustTempl');
#endif
            Codeunit::"NPR UPG POS Customer Input":
                case UpgradeStep of
                    'UpgradePOSCustomerInputEntryInputTransfer':
                        exit('NPR-UpgradePOSCustomerInputEntryInputTransfer-20250713');
                end;
            Codeunit::"NPR UPG POSSalDigRcpEntrTransf":
                case UpgradeStep of
                    'UpgradePOSSaleDigitalReceiptEntryTransfer':
                        exit('NPR-UpgradePOSSaleDigitalReceiptEntryTransfer-20250720');
                end;
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
            Codeunit::"NPR UPG NP Email":
                case UpgradeStep of
                    'RemoveSenderIdentityUpdateJQ':
                        exit('NPR-RemoveSenderIdentityUpdateJQ-20250827')
                end;
#endif
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
            Codeunit::"NPR POS License Billing Upgrd.":
                case UpgradeStep of
                    'AddPOSBillingFeature':
                        exit('NPR-AddPOSBillingFeature-20250911');
                end;
#endif
            Codeunit::"NPR RS Retail Calculation Upg.":
                case UpgradeStep of
                    'MatchRemainingQtyToRSRetailValueEntryMapping':
                        exit('NPR-MatchRemainingQtyToRSRetailValueEntryMapping-20251102');
                end;
            Codeunit::"NPR BINMatching Upgrade":
                case UpgradeStep of
                    'UpgradeBINGroupPaymentLink':
                        exit('NPR-UpgradeBINGroupPaymentLinks-20251711');
                end;
        end;
    end;
}
