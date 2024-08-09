interface "NPR EFT Doc Pay Reservation"
{

    procedure Reserve(SaleLinePOS: Record "NPR POS Sale Line"; SalesHeader: Record "Sales Header"; var MagentoPaymentLine: Record "NPR Magento Payment Line") Reserved: Boolean;

    procedure GetReservationAmount(SalesHeader: Record "Sales Header") ReservationAmount: Decimal;

    procedure ValidatePOSPaymentMethod(PaymentMethodCode: Code[10]; POSUnitNo: Code[10])
}