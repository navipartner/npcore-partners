codeunit 6060076 "NPR POS Action: CurSaleStats-B"
{
    Access = Internal;
    procedure RunSalesStatsPage(AlwaysUseUnitCost: Boolean)
    var
        POSSale: Record "NPR POS Sale";
        TempPOSCurrentStatsBuffer: Record "NPR POS Single Stats Buffer" temporary;
        SalePOS: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        POSStatisticsMgt: Codeunit "NPR POS Statistics Mgt.";
    begin
        POSSession.GetSale(SalePOS);
        SalePOS.GetCurrentSale(POSSale);

        POSStatisticsMgt.FillCurrentStatsBuffer(TempPOSCurrentStatsBuffer, POSSale, AlwaysUseUnitCost);
        Page.RunModal(Page::"NPR POS Current Sale Stats", TempPOSCurrentStatsBuffer);
    end;
}