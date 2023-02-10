codeunit 6060030 "NPR Reverse Sale Public Access"
{
    [Obsolete('New overload created with additional parameter')]
    procedure HandleRequestPOSActionReverseDirectSaleRun(SalesTicketNo: Code[20]; ObfucationMethod: Option "None",MI; CopyHeaderDim: Boolean; ReturnReasonCode: Code[20])
    var
        POSActionRevDirSaleB: Codeunit "NPR POS Action: Rev.Dir.Sale B";
    begin
        POSActionRevDirSaleB.HendleReverse(
            SalesTicketNo, ObfucationMethod, CopyHeaderDim, ReturnReasonCode, false);
    end;

    procedure HandleRequestPOSActionReverseDirectSaleRun(SalesTicketNo: Code[20]; ObfucationMethod: Option "None",MI; CopyHeaderDim: Boolean; ReturnReasonCode: Code[20]; IncludePaymentLines: Boolean)
    var
        POSActionRevDirSaleB: Codeunit "NPR POS Action: Rev.Dir.Sale B";
    begin
        POSActionRevDirSaleB.HendleReverse(
            SalesTicketNo, ObfucationMethod, CopyHeaderDim, ReturnReasonCode, IncludePaymentLines);
    end;

    internal procedure CallOnReverseSalesTicketOnBeforeModifySalesLinePOS(var SaleLinePOS: Record "NPR POS Sale Line"; var SalePOS: Record "NPR POS Sale")
    begin
        OnReverseSalesTicketOnBeforeModifySalesLinePOS(SaleLinePOS, SalePOS);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReverseSalesTicketOnBeforeModifySalesLinePOS(var SaleLinePOS: Record "NPR POS Sale Line"; var SalePOS: Record "NPR POS Sale")
    begin
    end;
}