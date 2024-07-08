codeunit 6060030 "NPR Reverse Sale Public Access"
{
    [Obsolete('New overload created with additional parameter', 'NPR23.0')]
    procedure HandleRequestPOSActionReverseDirectSaleRun(SalesTicketNo: Code[20]; ObfucationMethod: Option "None",MI; CopyHeaderDim: Boolean; ReturnReasonCode: Code[20])
    var
        POSActionRevDirSaleB: Codeunit "NPR POS Action: Rev.Dir.Sale B";
    begin
        POSActionRevDirSaleB.HendleReverse(
            SalesTicketNo, ObfucationMethod, CopyHeaderDim, ReturnReasonCode, false, true);
    end;

    [Obsolete('New overload created with new additional parameter', 'NPR23.0')]
    procedure HandleRequestPOSActionReverseDirectSaleRun(SalesTicketNo: Code[20]; ObfucationMethod: Option "None",MI; CopyHeaderDim: Boolean; ReturnReasonCode: Code[20]; IncludePaymentLines: Boolean)
    var
        POSActionRevDirSaleB: Codeunit "NPR POS Action: Rev.Dir.Sale B";
    begin
        POSActionRevDirSaleB.HendleReverse(
            SalesTicketNo, ObfucationMethod, CopyHeaderDim, ReturnReasonCode, IncludePaymentLines, true);
    end;

    procedure HandleRequestPOSActionReverseDirectSaleRun(SalesTicketNo: Code[20]; ObfucationMethod: Option "None",MI; CopyHeaderDim: Boolean; ReturnReasonCode: Code[20]; IncludePaymentLines: Boolean; CopyLineDim: Boolean)
    var
        POSActionRevDirSaleB: Codeunit "NPR POS Action: Rev.Dir.Sale B";
    begin
        POSActionRevDirSaleB.HendleReverse(
            SalesTicketNo, ObfucationMethod, CopyHeaderDim, ReturnReasonCode, IncludePaymentLines, CopyLineDim);
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
