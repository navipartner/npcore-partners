codeunit 6151064 "NPR POSAct PaymentWithCheck B"
{
    Access = Internal;
    internal procedure CapturePayment(AmountToCaptureLCY: Decimal;
                                      DefaultAmountToCaptureLCY: Decimal;
                                      POSPaymentLine: Codeunit "NPR POS Payment Line";
                                      var POSLine: Record "NPR POS Sale Line";
                                      POSPaymentMethod: Record "NPR POS Payment Method") IsCaptured: Boolean
    var
        AmountToCapture: Decimal;
    begin
        AmountToCapture := AmountToCaptureLCY;

        IsCaptured := AmountToCaptureLCY = 0;
        if IsCaptured then
            exit;

        POSPaymentLine.ValidateAmountBeforePayment(POSPaymentMethod,
                                                   AmountToCaptureLCY,
                                                   DefaultAmountToCaptureLCY);

        if (POSPaymentMethod."Fixed Rate" <> 0) then begin

            POSLine."Amount Including VAT" := 0;
            POSPaymentLine.InsertPaymentLine(POSLine,
                                             AmountToCapture);

        end else begin

            POSLine."Amount Including VAT" := AmountToCaptureLCY;
            POSPaymentLine.InsertPaymentLine(POSLine,
                                             0);
        end;

        IsCaptured := true;
    end;
}