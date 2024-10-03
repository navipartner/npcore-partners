codeunit 6185000 "NPR EFT Adyen Mpos Lan Integ."
{
    Access = Internal;

    procedure IntegrationType(): Code[20]
    begin
        exit('ADYEN_MPOS_LAN');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    begin
        tmpEFTIntegrationType.Init();
        tmpEFTIntegrationType.Code := IntegrationType();
        tmpEFTIntegrationType.Description := 'Adyen Mpos LAN.';
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"NPR EFT Adyen Mpos Lan Integ.";
        tmpEFTIntegrationType."Version 2" := true;
        tmpEFTIntegrationType.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnConfigureIntegrationUnitSetup', '', false, false)]
    local procedure OnConfigureIntegrationUnitSetup(EFTSetup: Record "NPR EFT Setup")
    var
        EFTAdyenUnitSetup: Record "NPR EFT Adyen Unit Setup";
        EFTAdyenUnitSetupPage: Page "NPR EFT Adyen Unit Setup";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;

        if (not EFTAdyenUnitSetup.Get(EFTSetup."POS Unit No.")) then begin
            EFTAdyenUnitSetup.Init();
            EFTAdyenUnitSetup."POS Unit No." := EFTSetup."POS Unit No.";
            EFTAdyenUnitSetup.Insert();
        end;
        Commit();
        EFTAdyenUnitSetupPage.SetLan();
        EFTAdyenUnitSetupPage.SetRecord(EFTAdyenUnitSetup);
        EFTAdyenUnitSetupPage.RunModal();
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
        EFTAdyenPaymTypeSetup.SetMposLan();
        EFTAdyenPaymTypeSetup.SetRecord(EFTAdyenPaymentTypeSetup);
        EFTAdyenPaymTypeSetup.RunModal();
    end;
}