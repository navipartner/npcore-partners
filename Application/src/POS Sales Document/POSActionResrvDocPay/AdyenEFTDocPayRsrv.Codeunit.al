codeunit 6184944 "NPR Adyen EFT Doc Pay Rsrv" implements "NPR EFT Doc Pay Reservation"
{
    Access = Internal;

    internal procedure Reserve(SaleLinePOS: Record "NPR POS Sale Line"; SalesHeader: Record "Sales Header"; var MagentoPaymentLine: Record "NPR Magento Payment Line") Reserved: Boolean
    var
        MagentoPmtAdyenMgt: Codeunit "NPR Magento Pmt. Adyen Mgt.";
    begin
        Reserved := MagentoPmtAdyenMgt.CreateMagentoPaymentLineForPOSEFTDocumentRservation(SaleLinePOS, SalesHeader, MagentoPaymentLine);
    end;

    internal procedure GetReservationAmount(SalesHeader: Record "Sales Header") ReservationAmount: Decimal;
    var
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
    begin
        ReservationAmount := MagentoPmtMgt.GetAmountToPay(SalesHeader."Amount Including VAT", Database::"Sales Header", SalesHeader."No.", SalesHeader."Document Type");
    end;

    internal procedure ValidatePOSPaymentMethod(PaymentMethodCode: Code[10]; POSUnitNo: Code[10])
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        ManualCaptureErrorLbl: Label 'Manual capture is not enabled for POS Payment Method %1 POS Unit No. %2.', Comment = '%1 - pos payment method, %2 - pos unit no.';
    begin
        EFTSetup.FindSetup(POSUnitNo, PaymentMethodCode);
        if EFTAdyenIntegration.GetManualCapture(EFTSetup) then
            exit;

        Error(ManualCaptureErrorLbl, PaymentMethodCode, POSUnitNo);
    end;
}