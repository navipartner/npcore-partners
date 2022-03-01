codeunit 6014470 "NPR UPG Distr. And Exch. Map"
{
    Access = Internal;
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

        UpgradeTransferLineDistributionData();

        UpgradeTag.SetUpgradeTag(UpgTagMgt.GetUpgradeTag(Codeunit::"NPR UPG Distr. And Exch. Map"));

        LogMessageStopwatch.LogFinish();
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
}
