codeunit 6014599 "NPR New Prices Install"
{
    Access = Internal;
    Subtype = Install;


    trigger OnInstallAppPerCompany()
    begin
        RemoveDiscountPriorityRecords();
    end;

    procedure RemoveDiscountPriorityRecords()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
#if BC17
        NewPricesUpgrade: Codeunit "NPR New Prices Upgrade";
#endif
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR New Prices Install")) then
            exit;

        InitDiscountPriority();
#if BC17
        NewPricesUpgrade.FillPriceListNos();
#endif
        EnableFeature();

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

    local procedure EnableFeature()
    var
        NewPriceUpgrade: Codeunit "NPR New Prices Upgrade";
    begin
        NewPriceUpgrade.EnableFeature();
    end;
}

