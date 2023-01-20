codeunit 6060091 "NPR POS Action: POS Info-B"
{
    Access = Internal;

    procedure OpenPOSInfoPage(PosInfo: Record "NPR POS Info"; POSSession: Codeunit "NPR POS Session"; UserInputString: Text; ApplicationScope: Option " ","Current Line","All Lines","New Lines","Ask"; ClearPOSInfo: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        CurrentView: Codeunit "NPR POS View";
        POSInfoManagement: Codeunit "NPR POS Info Management";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        POSSession.GetCurrentView(CurrentView);
        if (CurrentView.GetType() = CurrentView.GetType() ::Sale) then begin
            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        end;

        if (CurrentView.GetType() = CurrentView.GetType() ::Payment) then begin
            POSSession.GetPaymentLine(POSPaymentLine);
            POSPaymentLine.GetCurrentPaymentLine(SaleLinePOS);
        end;

        if (SaleLinePOS."Sales Ticket No." = '') then begin
            // No lines in current view
            SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
            SaleLinePOS."Register No." := SalePOS."Register No.";
            SaleLinePOS.Date := SalePOS.Date;
            SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
        end;

        POSInfoManagement.ProcessPOSInfoMenuFunction(
            SaleLinePOS, PosInfo.Code, ApplicationScope, ClearPOSInfo, UserInputString);
    end;
}
