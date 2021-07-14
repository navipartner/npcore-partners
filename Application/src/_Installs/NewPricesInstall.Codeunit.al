codeunit 6014599 "NPR New Prices Install"
{
    Subtype = Install;


    trigger OnInstallAppPerCompany()
    begin
        RemoveDiscountPriorityRecords();
    end;

    procedure RemoveDiscountPriorityRecords()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR New Prices Install")) then
            exit;

        InitDiscountPriority();

        EnableFeature('SalesPrices');

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR New Prices Install"));

    end;


    local procedure InitDiscountPriority()
    var
        DiscountPriority: Record "NPR Discount Priority";
        POSSalesDiscCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
    begin
        if not DiscountPriority.IsEmpty() then
            DiscountPriority.DeleteAll();
        POSSalesDiscCalcMgt.InitDiscountPriority(DiscountPriority);
    end;

    local procedure EnableFeature(FeatureName: Text)
    var
        FeatureKey: Record "Feature Key";
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
    begin
        FeatureKey.SetRange(ID, FeatureName);
        FeatureKey.SetRange(Enabled, FeatureKey.Enabled::None);
        if FeatureKey.FindFirst() then begin
            FeatureKey.Validate(Enabled, FeatureKey.Enabled::"All Users");
            FeatureKey.Modify(true);

            if FeatureDataUpdateStatus.Get(FeatureKey.ID, CompanyName()) then
                Codeunit.Run(Codeunit::"Update Feature Data", FeatureDataUpdateStatus);
        end;
    end;
}

