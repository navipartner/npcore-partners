codeunit 6184955 "NPR EFT Pay Reserv Setup Utils"
{
    Access = Internal;
    internal procedure CheckPaymentServationSetup(AdyenSetup: Record "NPR Adyen Setup")
    begin
        AdyenSetup.TestField("EFT Res. Account No.");
        AdyenSetup.TestField("EFT Res. Payment Gateway Code");
    end;
}