codeunit 6014470 "NPR UPG Distr. And Exch. Map"
{
    Subtype = Upgrade;


    trigger OnUpgradePerCompany()
    begin
        Upgrade();
    end;

    local procedure Upgrade()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagLbl: Label 'NPRPUGDistrAndExchMap_Upgrade-20210312', Locked = true;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagLbl) then
            exit;

        UpgradePurchaseOrderDistributionData();
        UpgradeTransferLineDistributionData();
        UpgradePurchaseLineExchangeData();

        UpgradeTag.SetUpgradeTag(UpgradeTagLbl);
    end;

    local procedure UpgradePurchaseOrderDistributionData()
    var
        PurchaseLine: Record "Purchase Line";
        DistributionMap: Record "NPR Distribution Map";
    begin
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        PurchaseLine.SetFilter("No.", '<>%1', '');
        PurchaseLine.SetFilter("NPR Retail Replenishment No.", '<>%1', 0);
        if PurchaseLine.FindSet() then
            repeat
                DistributionMap.CreateFromPurchaseLine(PurchaseLine."NPR Retail Replenishment No.", PurchaseLine);
            until PurchaseLine.Next() = 0;
    end;

    local procedure UpgradeTransferLineDistributionData()
    var
        TransferLine: Record "Transfer Line";
        DistributionMap: Record "NPR Distribution Map";
    begin
        TransferLine.SetFilter("Item No.", '<>%1', '');
        TransferLine.SetFilter("NPR Retail Replenishment No.", '<>%1', 0);
        if TransferLine.FindSet() then
            repeat
                DistributionMap.CreateFromTransferLine(TransferLine."NPR Retail Replenishment No.", TransferLine);
            until TransferLine.Next() = 0;
    end;

    local procedure UpgradePurchaseLineExchangeData()
    var
        PurchaseLine: Record "Purchase Line";
        ExchangeLabelMap: Record "NPR Exchange Label Map";
    begin
        PurchaseLine.SetFilter("NPR Exchange Label", '<>%1', '');
        if PurchaseLine.FindSet() then
            repeat
                ExchangeLabelMap.CreateOrUpdateFromPurhaseLine(PurchaseLine, PurchaseLine."NPR Exchange Label");
            until PurchaseLine.Next() = 0;
    end;
}