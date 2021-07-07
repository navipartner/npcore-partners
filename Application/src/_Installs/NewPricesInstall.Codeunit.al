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
        UpgradeTagLbl: Label 'NPRNewPriceTableInstall-20210618', Locked = true;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagLbl) then
            exit;

        InitDiscountPriority();

        UpdateMagentoSetup();

        EnableFeature('SalesPrices');

        UpgradeTag.SetUpgradeTag(UpgradeTagLbl);

    end;

    local procedure UpdateMagentoSetup()
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if MagentoSetup.Get() then begin
            MagentoSetup."Replicate to Price Source Type" := ConvertPriceType(MagentoSetup."Replicate to Sales Type");
            MagentoSetup.Modify();
        end
    end;

    local procedure ConvertPriceType(ReplicatetoSalesType: Enum "Sales Price Type") PriceSourceType: Enum "Price Source Type"
    begin
        case ReplicatetoSalesType of
            ReplicatetoSalesType::"All Customers":
                exit(PriceSourceType::"All Customers");
            ReplicatetoSalesType::Campaign:
                exit(PriceSourceType::Campaign);
            ReplicatetoSalesType::Customer:
                exit(PriceSourceType::Customer);
            ReplicatetoSalesType::"Customer Price Group":
                exit(PriceSourceType::"Customer Price Group");
            else
        end;
    end;


    local procedure InitDiscountPriority()
    var
        DiscountPriority: Record "NPR Discount Priority";
        POSSalesDiscCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
    begin
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

