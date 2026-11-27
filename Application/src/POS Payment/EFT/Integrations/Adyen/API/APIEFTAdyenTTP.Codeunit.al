#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248751 "NPR API EFT Adyen TTP" implements "NPR API EFT Provider"
{
    Access = Internal;

    procedure IntegrationType(): Code[20]
    var
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
    begin
        exit(EFTAdyenIntegration.MposTapToPayIntegrationType());
    end;

    procedure Flow(): Enum "NPR API EFT Flow"
    begin
        exit(Enum::"NPR API EFT Flow"::Local);
    end;

#pragma warning disable AA0150
    procedure ValidateSetup(EFTSetup: Record "NPR EFT Setup"; POSUnitNo: Code[10]; var ErrorMessage: Text): Boolean
#pragma warning restore
    begin
        exit(true);
    end;

#pragma warning disable AA0150
    procedure ValidateStart(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var ErrorMessage: Text): Boolean
#pragma warning restore
    begin
        exit(true);
    end;

    procedure StartCloudPayment(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; POSSale: Record "NPR POS Sale")
    begin
        Error('Adyen Tap to Pay uses the local EFT flow and cannot start a cloud payment. This is a programming bug');
    end;

    procedure CancelCloudPayment(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup")
    begin
        Error('Adyen Tap to Pay uses the local EFT flow and cannot cancel a cloud payment. This is a programming bug');
    end;
}
#endif
