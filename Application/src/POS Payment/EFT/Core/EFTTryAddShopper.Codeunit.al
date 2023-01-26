codeunit 6184508 "NPR EFT Try Add Shopper"
{
    Access = Internal;
    TableNo = "NPR EFT Shopper Recognition";

    trigger OnRun()
    var
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS.Validate("Customer No.", Rec."Entity Key");

        SalePOS.Modify(true);
        POSSale.Refresh(SalePOS);
    end;
}

