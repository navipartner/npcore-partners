codeunit 6150638 "NPR UPG New Feature Handler"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        POSEditorFeatureHandleUpgradeStepLbl: Label 'POSEditorFeatureHandle', Locked = true;
        ScenarioObsoletedFeatureUpgradeStepLbl: Label 'ScenarioObsoletedFeatureHandle', Locked = true;
        POSStatisticsDashboardFeatureHandleUpgradeStepLbl: Label 'POSStatisticsDashboardFeatureHandle', Locked = true;
        NewSalesReceiptExperienceHandleUpgradeStepLbl: Label 'NewSalesReceiptExperienceHandle', Locked = true;
        NewEFTReceiptExperienceHandleUpgradeStepLbl: Label 'NewEFTReceiptExperienceHandle', Locked = true;
        NewAttractionPrintExperienceHandleUpgradeStepLbl: Label 'NewAttractionPrintExperienceHandle', Locked = true;

    begin
        AddUpgradeTagIfNotExist(CurrCodeunitId(), POSEditorFeatureHandleUpgradeStepLbl);
        AddUpgradeTagIfNotExist(CurrCodeunitId(), ScenarioObsoletedFeatureUpgradeStepLbl);
        AddUpgradeTagIfNotExist(CurrCodeunitId(), POSStatisticsDashboardFeatureHandleUpgradeStepLbl);
        AddUpgradeTagIfNotExist(CurrCodeunitId(), NewSalesReceiptExperienceHandleUpgradeStepLbl);
        AddUpgradeTagIfNotExist(CurrCodeunitId(), NewEFTReceiptExperienceHandleUpgradeStepLbl);
        AddUpgradeTagIfNotExist(CurrCodeunitId(), NewAttractionPrintExperienceHandleUpgradeStepLbl);
    end;

    local procedure AddUpgradeTagIfNotExist(UpgradeCodeunitId: Integer; UpgradeStep: Text)
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(UpgradeCodeunitId, UpgradeStep)) then
            exit;

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(UpgradeCodeunitId, UpgradeStep));
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG New Feature Handler");
    end;
}
