codeunit 6184607 "NPR EFT Adyen Cloud Integrat."
{
    Access = Internal;

    var
        Description: Label 'Adyen Cloud Terminal API', MaxLength = 50;
        ABORT_TRX: Label 'Abort Transaction', MaxLength = 50;
        ACQUIRE_CARD: Label 'Acquire Card', MaxLength = 50;
        ABORT_ACQUIRED: Label 'Abort Acquired Card', MaxLength = 50;
        DETECT_SHOPPER: Label 'Detect Shopper from Card', MaxLength = 50;
        CLEAR_SHOPPER: Label 'Clear Shopper from Card', MaxLength = 50;
        DISABLE_CONTRACT: Label 'Disable Shopper Recurring Contract', MaxLength = 50;
        SUBSCRIPTION_CONFIRM: Label 'Subscription Confirmation', MaxLength = 50;

    procedure IntegrationType(): Code[20]
    begin
        exit('ADYEN_CLOUD');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    begin
        tmpEFTIntegrationType.Init();
        tmpEFTIntegrationType.Code := IntegrationType();
        tmpEFTIntegrationType.Description := CopyStr(Description, 1, MaxStrLen(tmpEFTIntegrationType.Description));
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"NPR EFT Adyen Cloud Integrat.";
        tmpEFTIntegrationType."Version 2" := true;
        tmpEFTIntegrationType.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverAuxiliaryOperations', '', false, false)]
    local procedure OnDiscoverAuxiliaryOperations(var tmpEFTAuxOperation: Record "NPR EFT Aux Operation" temporary)
    begin
        //Any non standard EFT operations are registered here:

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := Enum::"NPR EFT Adyen Aux Operation"::ABORT_TRX.AsInteger();
        tmpEFTAuxOperation.Description := CopyStr(ABORT_TRX, 1, MaxStrLen(tmpEFTAuxOperation.Description));
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := Enum::"NPR EFT Adyen Aux Operation"::ACQUIRE_CARD.AsInteger();
        tmpEFTAuxOperation.Description := CopyStr(ACQUIRE_CARD, 1, MaxStrLen(tmpEFTAuxOperation.Description));
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := Enum::"NPR EFT Adyen Aux Operation"::ABORT_ACQUIRED.AsInteger();
        tmpEFTAuxOperation.Description := CopyStr(ABORT_ACQUIRED, 1, MaxStrLen(tmpEFTAuxOperation.Description));
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := Enum::"NPR EFT Adyen Aux Operation"::DETECT_SHOPPER.AsInteger();
        tmpEFTAuxOperation.Description := CopyStr(DETECT_SHOPPER, 1, MaxStrLen(tmpEFTAuxOperation.Description));
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := Enum::"NPR EFT Adyen Aux Operation"::CLEAR_SHOPPER.AsInteger();
        tmpEFTAuxOperation.Description := CopyStr(CLEAR_SHOPPER, 1, MaxStrLen(tmpEFTAuxOperation.Description));
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := Enum::"NPR EFT Adyen Aux Operation"::DISABLE_CONTRACT.AsInteger();
        tmpEFTAuxOperation.Description := CopyStr(DISABLE_CONTRACT, 1, MaxStrLen(tmpEFTAuxOperation.Description));
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := Enum::"NPR EFT Adyen Aux Operation"::SUBSCRIPTION_CONFIRM.AsInteger();
        tmpEFTAuxOperation.Description := CopyStr(SUBSCRIPTION_CONFIRM, 1, MaxStrLen(tmpEFTAuxOperation.Description));
        tmpEFTAuxOperation.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnConfigureIntegrationUnitSetup', '', false, false)]
    local procedure OnConfigureIntegrationUnitSetup(EFTSetup: Record "NPR EFT Setup")
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;

        GetPOIID(EFTSetup);

        EFTSetup.ShowEftPOSUnitParameters();
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

        EFTAdyenintegration.GetPaymentTypeParameters(EFTSetup, EFTAdyenPaymentTypeSetup);
        Commit();
        EFTAdyenPaymTypeSetup.SetCloud();
        EFTAdyenPaymTypeSetup.SetRecord(EFTAdyenPaymentTypeSetup);
        EFTAdyenPaymTypeSetup.RunModal();
    end;

    procedure GetPOIID(EFTSetupIn: Record "NPR EFT Setup"): Text[200]
    var
        EFTTypePOSUnitGenParam: Record "NPR EFTType POSUnit Gen.Param.";
    begin
#pragma warning disable AA0139
        exit(EFTTypePOSUnitGenParam.GetTextParameterValue(IntegrationType(), EFTSetupIn."POS Unit No.", 'POI ID', '', true));
#pragma warning restore AA0139
    end;

    procedure GetAPIKey(EFTSetupIn: Record "NPR EFT Setup"): Text
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
    begin
        EFTAdyenintegration.GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup.GetApiKey());
    end;

    procedure GetEnvironment(EFTSetupIn: Record "NPR EFT Setup"): Integer
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
    begin
        EFTAdyenintegration.GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup.Environment);
    end;
}
