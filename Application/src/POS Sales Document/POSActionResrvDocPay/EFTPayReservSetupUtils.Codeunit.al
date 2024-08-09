codeunit 6184955 "NPR EFT Pay Reserv Setup Utils"
{
    Access = Internal;
    internal procedure CheckPaymentServationSetup(POSEFTPayReservSetup: Record "NPR POS EFT Pay Reserv Setup")
    begin
        POSEFTPayReservSetup.TestField("Account No.");
        POSEFTPayReservSetup.TestField("Payment Gateway Code");
    end;
}