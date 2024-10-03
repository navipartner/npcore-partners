codeunit 6184640 "NPR EFT Adyen Local Integrat."
{
    Access = Internal;

    var
        Description: Label 'Adyen Cloud Terminal API';
        ABORT_TRX: Label 'Abort Transaction';
        ACQUIRE_CARD: Label 'Acquire Card';
        ABORT_ACQUIRED: Label 'Abort Acquired Card';
        DETECT_SHOPPER: Label 'Detect Shopper from Card';
        CLEAR_SHOPPER: Label 'Clear Shopper from Card';
        DISABLE_CONTRACT: Label 'Disable Shopper Recurring Contract';

    procedure IntegrationType(): Code[20]
    begin
        exit('ADYEN_LOCAL');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    begin
        tmpEFTIntegrationType.Init();
        tmpEFTIntegrationType.Code := IntegrationType();
        tmpEFTIntegrationType.Description := Description;
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"NPR EFT Adyen Local Integrat.";
        tmpEFTIntegrationType."Version 2" := true;
        tmpEFTIntegrationType.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverAuxiliaryOperations', '', false, false)]
    local procedure OnDiscoverAuxiliaryOperations(var tmpEFTAuxOperation: Record "NPR EFT Aux Operation" temporary)
    begin
        //Any non standard EFT operations are registered here:

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 1;
        tmpEFTAuxOperation.Description := ABORT_TRX;
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 2;
        tmpEFTAuxOperation.Description := ACQUIRE_CARD;
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 3;
        tmpEFTAuxOperation.Description := ABORT_ACQUIRED;
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 4;
        tmpEFTAuxOperation.Description := DETECT_SHOPPER;
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 5;
        tmpEFTAuxOperation.Description := CLEAR_SHOPPER;
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 6;
        tmpEFTAuxOperation.Description := DISABLE_CONTRACT;
        tmpEFTAuxOperation.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnConfigureIntegrationUnitSetup', '', false, false)]
    local procedure OnConfigureIntegrationUnitSetup(EFTSetup: Record "NPR EFT Setup")
    var
        EFTAdyenLocalUnitSetup: Record "NPR EFT Adyen Local Unit Setup";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;

        GetPOSUnitParameters(EFTSetup, EFTAdyenLocalUnitSetup);
        Commit();
        PAGE.RunModal(PAGE::"NPR EFT Adyen Local Unit Setup", EFTAdyenLocalUnitSetup);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnConfigureIntegrationPaymentSetup', '', false, false)]
    local procedure OnConfigureIntegrationPaymentSetup(EFTSetup: Record "NPR EFT Setup")
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        EFTAdyenPaymTypeSetup: Page "NPR EFT Adyen Paym. Type Setup";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;

        EFTAdyenIntegration.GetPaymentTypeParameters(EFTSetup, EFTAdyenPaymentTypeSetup);
        Commit();
        EFTAdyenPaymTypeSetup.SetLocal();
        EFTAdyenPaymTypeSetup.SetRecord(EFTAdyenPaymentTypeSetup);
        EFTAdyenPaymTypeSetup.RunModal();
    end;


    procedure GetPOSUnitParameters(EFTSetup: Record "NPR EFT Setup"; var EFTAdyenLocalUnitSetup: Record "NPR EFT Adyen Local Unit Setup")
    begin
        EFTSetup.TestField("Payment Type POS");

        if not EFTAdyenLocalUnitSetup.Get(EFTSetup."POS Unit No.") then begin
            EFTAdyenLocalUnitSetup.Init();
            EFTAdyenLocalUnitSetup."POS Unit No." := EFTSetup."POS Unit No.";
            EFTAdyenLocalUnitSetup.Insert();
        end;
    end;
}
