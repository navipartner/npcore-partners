codeunit 6059959 "NPR POS Action: Check Avail. B"
{
    Access = Internal;
    procedure CheckAvail(POSSale: Codeunit "NPR POS Sale")
    var
        SalePOS: Record "NPR POS Sale";
        PosItemCheckAvail: Codeunit "NPR POS Item-Check Avail.";
        AllInStockMsg: Label 'All items are in stock.';
    begin
        POSSale.GetCurrentSale(SalePOS);
        Clear(PosItemCheckAvail);
        if BindSubscription(PosItemCheckAvail) then;
        PosItemCheckAvail.SetIgnoreProfile(true);
        PosItemCheckAvail.CheckAvailability_PosSale(SalePOS, false);
        if not PosItemCheckAvail.GetAvailabilityIssuesFound() then
            Message(AllInStockMsg);
        UnbindSubscription(PosItemCheckAvail);
    end;
}