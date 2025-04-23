codeunit 6060076 "NPR POS Action: CurSaleStats-B"
{
    Access = Internal;
    procedure RunSalesStatsPage(AlwaysUseUnitCost: Boolean)
    var
        POSSale: Record "NPR POS Sale";
        POSCurrentStatsBuffer: Record "NPR POS Single Stats Buffer";
        SalePOS: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        POSStatisticsMgt: Codeunit "NPR POS Statistics Mgt.";
    begin
        POSSession.GetSale(SalePOS);
        SalePOS.GetCurrentSale(POSSale);

        POSStatisticsMgt.FillCurrentStatsBuffer(POSCurrentStatsBuffer, POSSale, AlwaysUseUnitCost);
        Page.RunModal(Page::"NPR POS Current Sale Stats", POSCurrentStatsBuffer);
    end;
}