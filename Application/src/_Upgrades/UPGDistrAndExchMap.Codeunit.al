codeunit 6014470 "NPR UPG Distr. And Exch. Map"
{
    Subtype = Upgrade;


    trigger OnUpgradePerCompany()
    begin
        Upgrade();
    end;

    local procedure Upgrade()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagMgt: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Distr. And Exch. Map', 'Upgrade');

        if UpgradeTag.HasUpgradeTag(UpgTagMgt.GetUpgradeTag(Codeunit::"NPR UPG Distr. And Exch. Map")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradePurchaseOrderDistributionData();
        UpgradeTransferLineDistributionData();
        UpgradePurchaseLineExchangeData();

        UpgradeTag.SetUpgradeTag(UpgTagMgt.GetUpgradeTag(Codeunit::"NPR UPG Distr. And Exch. Map"));

        LogMessageStopwatch.LogFinish();
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