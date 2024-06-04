codeunit 6184915 "NPR Merge Similar Lines Public"
{
    Access = Public;

    procedure ColapseSaleLines(var POSSession: Codeunit "NPR POS Session"; SalePOS: Record "NPR POS Sale")
    var
        NPRPOSActionMergSmlLinesB: Codeunit "NPR POSAction: Merg.Sml.LinesB";
    begin
        NPRPOSActionMergSmlLinesB.ColapseSaleLines(POSSession, SalePOS);
    end;
}