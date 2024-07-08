codeunit 6060091 "NPR POS Action: POS Info-B"
{
    Access = Internal;

    procedure OpenPOSInfoPage(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; PosInfo: Record "NPR POS Info"; UserInputString: Text; ApplicationScope: Option " ","Current Line","All Lines","New Lines","Ask"; ClearPOSInfo: Boolean) RequestFrontEndRefresh: Boolean
    var
        POSInfoManagement: Codeunit "NPR POS Info Management";
    begin
        if (SaleLinePOS."Sales Ticket No." = '') then begin
            // No lines in current view
            SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
            SaleLinePOS."Register No." := SalePOS."Register No.";
            SaleLinePOS.Date := SalePOS.Date;
        end;

        RequestFrontEndRefresh :=
            POSInfoManagement.ProcessPOSInfoMenuFunction(SaleLinePOS, PosInfo.Code, ApplicationScope, ClearPOSInfo, UserInputString);
    end;
}
