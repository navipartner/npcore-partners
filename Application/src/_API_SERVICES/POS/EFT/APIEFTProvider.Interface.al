#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
interface "NPR API EFT Provider"
{
    Access = Internal;

    procedure IntegrationType(): Code[20];
    procedure Flow(): Enum "NPR API EFT Flow";
    procedure ValidateSetup(EFTSetup: Record "NPR EFT Setup"; POSUnitNo: Code[10]; var ErrorMessage: Text): Boolean;
    procedure ValidateStart(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var ErrorMessage: Text): Boolean;
    procedure StartCloudPayment(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; POSSale: Record "NPR POS Sale");
    procedure CancelCloudPayment(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup");
}
#endif
