codeunit 6060030 "NPR Reverse Sale Public Access"
{
    procedure HandleRequestPOSActionReverseDirectSaleRun(SalesTicketNo: Code[20]; ObfucationMethod: Option "None",MI; CopyHeaderDim: Boolean; ReturnReasonCode: Code[20])
    var
        POSActionRevDirSaleB: Codeunit "NPR POS Action: Rev.Dir.Sale B";
    begin
        POSActionRevDirSaleB.HendleReverse(
            SalesTicketNo, ObfucationMethod, CopyHeaderDim, ReturnReasonCode);
    end;
}