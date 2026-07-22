codeunit 6150632 "NPR New Feature Handler"
{
    Access = Internal;

    internal procedure HandlePOSEditorFeature()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR New Feature Handler', 'POSEditorFeatureHandle');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'POSEditorFeatureHandle')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        POSEditorFeatureHandle();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'POSEditorFeatureHandle'));
        LogMessageStopwatch.LogFinish();
    end;

    internal procedure HandleScenarioObsoletedFeature()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR New Feature Handler', 'ScenarioObsoletedFeatureHandle');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'ScenarioObsoletedFeatureHandle')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        ScenarioObsoletedFeatureHandle();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'ScenarioObsoletedFeatureHandle'));
        LogMessageStopwatch.LogFinish();
    end;

    internal procedure HandlePOSStatisticsDashboardFeature()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR New Feature Handler', 'POSStatisticsDashboardFeatureHandle');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'POSStatisticsDashboardFeatureHandle')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        POSStatisticsDashboardFeatureHandle();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'POSStatisticsDashboardFeatureHandle'));
        LogMessageStopwatch.LogFinish();
    end;

    internal procedure HandleNewSalesReceiptExperience()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR New Feature Handler', 'NewSalesReceiptExperienceHandle');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'NewSalesReceiptExperienceHandle')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        NewSalesReceiptExperienceHandle();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'NewSalesReceiptExperienceHandle'));
        LogMessageStopwatch.LogFinish();
    end;

    internal procedure HandleNewEFTReceiptExperience()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR New Feature Handler', 'NewEFTReceiptExperienceHandle');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'NewEFTReceiptExperienceHandle')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        NewEFTReceiptExperienceHandle();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'NewEFTReceiptExperienceHandle'));
        LogMessageStopwatch.LogFinish();
    end;

    internal procedure HandleNewAttractionPrintExperience()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR New Feature Handler', 'NewAttractionPrintExperienceHandle');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'NewAttractionPrintExperienceHandle')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        NewAttractionPrintExperienceHandle();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'NewAttractionPrintExperienceHandle'));
        LogMessageStopwatch.LogFinish();
    end;

    internal procedure HandleNewRestaurantPrintExperience()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR New Feature Handler', 'NewRestaurantPrintExperienceHandle');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'NewRestaurantPrintExperienceHandle')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        NewRestaurantPrintExperienceHandle();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'NewRestaurantPrintExperienceHandle'));
        LogMessageStopwatch.LogFinish();
    end;

    internal procedure HandlePOSWebserviceSessionsFeature()
    var
        Feature: Record "NPR Feature";
        POSWebserviceSessions: Codeunit "NPR POS Webservice Sessions";
    begin
        if not Feature.Get(POSWebserviceSessions.GetFeatureId()) then
            exit;
        if Feature.Enabled then
            exit;
        Feature.Enabled := true;
        Feature.Modify();
    end;

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    internal procedure HandleNewEmailFeature()
    var
        NewEmailFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        NewEmailFeature.SetFeatureEnabled(true);
    end;
#endif

    internal procedure HandleNewMagentoFeature()
    var
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeStep: Text;
    begin
        UpgradeStep := 'EnableMagentoFeature';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Magento Upgrade", UpgradeStep)) then
            exit;
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Magento Upgrade", UpgradeStep));
    end;

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    internal procedure HandleNewPOSLicenseBillingFeature()
    var
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeStep: Text;
    begin
        UpgradeStep := 'AddPOSBillingFeature';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Magento Upgrade", UpgradeStep)) then
            exit;
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Magento Upgrade", UpgradeStep));
    end;
#endif

    local procedure POSEditorFeatureHandle()
    var
        Feature: Record "NPR Feature";
        NewPOSEditorFeature: Codeunit "NPR New POS Editor Feature";
    begin
        if not Feature.Get(NewPOSEditorFeature.GetFeatureId()) then
            exit;
        if Feature.Enabled then
            exit;
        Feature.Enabled := true;
        Feature.Modify();
    end;

    local procedure ScenarioObsoletedFeatureHandle()
    var
        Feature: Record "NPR Feature";
        ScenarioObsoletedFeature: Codeunit "NPR Scenario Obsoleted Feature";
    begin
        if not Feature.Get(ScenarioObsoletedFeature.GetFeatureId()) then
            exit;
        if Feature.Enabled then
            exit;
        Feature.Enabled := true;
        Feature.Modify();
    end;

    local procedure POSStatisticsDashboardFeatureHandle()
    var
        Feature: Record "NPR Feature";
        POSStatisticsDashboardFeature: Codeunit "NPR POS Stat Dashboard Feature";
    begin
        if not Feature.Get(POSStatisticsDashboardFeature.GetFeatureId()) then
            exit;
        if Feature.Enabled then
            exit;
        Feature.Enabled := true;
        Feature.Modify();
    end;

    local procedure NewSalesReceiptExperienceHandle()
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        Feature: Record "NPR Feature";
        NewSalesReceiptExp: Codeunit "NPR New Sales Receipt Exp";
    begin
        if not Feature.Get(NewSalesReceiptExp.GetFeatureId()) then
            exit;
        if Feature.Enabled then
            exit;
        Feature.Enabled := true;
        Feature.Modify();

        ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)");
        ReportSelectionRetail.ModifyAll("Print Template", '');
        ReportSelectionRetail.CleanupEmptyData();

        NewSalesReceiptExp.InsertReportSelectionRetail(Codeunit::"NPR Static Sales Receipt");
        NewSalesReceiptExp.InsertReportSelectionRetail(Codeunit::"NPR Static Signature Receipt");
    end;

    local procedure NewEFTReceiptExperienceHandle()
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        Feature: Record "NPR Feature";
        NewEFTReceiptExp: Codeunit "NPR New EFT Receipt Exp";
    begin
        if not Feature.Get(NewEFTReceiptExp.GetFeatureId()) then
            exit;
        if Feature.Enabled then
            exit;
        Feature.Enabled := true;
        Feature.Modify();

        ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Terminal Receipt");
        ReportSelectionRetail.ModifyAll("Print Template", '');
        ReportSelectionRetail.CleanupEmptyData();

        NewEFTReceiptExp.InsertStaticEFTReceipt();
    end;

    local procedure NewAttractionPrintExperienceHandle()
    var
        TicketType: Record "NPR TM Ticket Type";
        MembershipSetup: Record "NPR MM Membership Setup";
        Feature: Record "NPR Feature";
        NewAttractionPrintExp: Codeunit "NPR New Attraction Print Exp";
    begin
        if not Feature.Get(NewAttractionPrintExp.GetFeatureId()) then
            exit;
        if Feature.Enabled then
            exit;
        Feature.Enabled := true;
        Feature.Modify();

        TicketType.SetRange("Print Object Type", TicketType."Print Object Type"::TEMPLATE);
        TicketType.ModifyAll("RP Template Code", '');
        TicketType.ModifyAll("Print Object Type", TicketType."Print Object Type"::CODEUNIT);

        MembershipSetup.SetRange("Receipt Print Object Type", MembershipSetup."Receipt Print Object Type"::TEMPLATE);
        MembershipSetup.ModifyAll("Receipt Print Template Code", '');
        MembershipSetup.ModifyAll("Receipt Print Object Type", MembershipSetup."Receipt Print Object Type"::NO_PRINT);
    end;

    local procedure NewRestaurantPrintExperienceHandle()
    var
        Feature: Record "NPR Feature";
        NewRestaurantPrintExp: Codeunit "NPR New Restaurant Print Exp.";
    begin
        if not Feature.Get(NewRestaurantPrintExp.GetFeatureId()) then
            exit;
        if Feature.Enabled then
            exit;
        Feature.Enabled := true;
        Feature.Modify();
    end;

    internal procedure HandleNewVoucherReservation()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR New Feature Handler', 'NewVoucherReservationHandle');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'NewVoucherReservationHandle')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        NewVoucherReservationHandle();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'NewVoucherReservationHandle'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure NewVoucherReservationHandle()
    var
        Feature: Record "NPR Feature";
        NewVoucherReservation: Codeunit "NPR New Voucher Reservation";
    begin
        if not Feature.Get(NewVoucherReservation.GetFeatureId()) then
            exit;
        if Feature.Enabled then
            exit;
        Feature.Enabled := true;
        Feature.Modify();
    end;

    internal procedure HandleNewNpRvPrintExperience()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR New Feature Handler', 'NewNpRvPrintExperienceHandle');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'NewNpRvPrintExperienceHandle')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        NewNpRvPrintExperienceHandle();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'NewNpRvPrintExperienceHandle'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure NewNpRvPrintExperienceHandle()
    var
        Feature: Record "NPR Feature";
        NewNpRvPrintExp: Codeunit "NPR New NpRv Print Exp.";
    begin
        if not Feature.Get(NewNpRvPrintExp.GetFeatureId()) then
            exit;
        if Feature.Enabled then
            exit;
        Feature.Enabled := true;
        Feature.Modify();
    end;

    internal procedure HandleNewZReportExperience()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR New Feature Handler', 'NewZReportExperienceHandle');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'NewZReportExperienceHandle')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        NewZReportExperienceHandle();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'NewZReportExperienceHandle'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure NewZReportExperienceHandle()
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        Feature: Record "NPR Feature";
        NewZReportExp: Codeunit "NPR New Z-Report Exp";
    begin
        if not Feature.Get(NewZReportExp.GetFeatureId()) then
            exit;
        if Feature.Enabled then
            exit;
        Feature.Enabled := true;
        Feature.Modify();

        ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Balancing (POS Entry)");
        ReportSelectionRetail.ModifyAll("Print Template", '');
        ReportSelectionRetail.CleanupEmptyData();

        NewZReportExp.InsertReportSelectionRetail();
    end;

    internal procedure HandleExtJQRefresherOnly()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR New Feature Handler', 'ExtJQRefresherOnlyHandle');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'ExtJQRefresherOnlyHandle')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        ExtJQRefresherOnlyHandle();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'ExtJQRefresherOnlyHandle'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure ExtJQRefresherOnlyHandle()
    var
        Feature: Record "NPR Feature";
        ExtJQRefresherOnlyFeat: Codeunit "NPR Ext JQ Refresher Only Feat";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if EnvironmentInformation.IsOnPrem() then
            exit;
        if not Feature.Get(ExtJQRefresherOnlyFeat.GetFeatureId()) then
            exit;
        if Feature.Enabled then
            exit;
        Feature.Enabled := true;
        Feature.Modify();
    end;

    internal procedure HandleNewSalesDocConfirmationExperience()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR New Feature Handler', 'NewSalesDocConfirmationExperienceHandle');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'NewSalesDocConfirmationExperienceHandle')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        NewSalesDocConfirmationExperienceHandle();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'NewSalesDocConfirmationExperienceHandle'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure NewSalesDocConfirmationExperienceHandle()
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        Feature: Record "NPR Feature";
        NewSalesDocConfExp: Codeunit "NPR New Sales Doc Conf. Exp";
    begin
        if not Feature.Get(NewSalesDocConfExp.GetFeatureId()) then
            exit;
        if Feature.Enabled then
            exit;
        Feature.Enabled := true;
        Feature.Modify();

        ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Sales Doc. Confirmation (POS Entry)");
        ReportSelectionRetail.ModifyAll("Print Template", '');
        ReportSelectionRetail.CleanupEmptyData();

        NewSalesDocConfExp.InsertReportSelectionRetail();
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR New Feature Handler");
    end;
}
