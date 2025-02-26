codeunit 6248277 "NPR EFT Adyen HWC Integrat."
{
    Access = Internal;

    var
        Description: Label 'Adyen HWC Terminal API', MaxLength = 50;
        ABORT_TRX: Label 'Abort Transaction', MaxLength = 50;
        ACQUIRE_CARD: Label 'Acquire Card', MaxLength = 50;
        ABORT_ACQUIRED: Label 'Abort Acquired Card', MaxLength = 50;
        DETECT_SHOPPER: Label 'Detect Shopper from Card', MaxLength = 50;
        CLEAR_SHOPPER: Label 'Clear Shopper from Card', MaxLength = 50;
        DISABLE_CONTRACT: Label 'Disable Shopper Recurring Contract', MaxLength = 50;
        SUBSCRIPTION_CONFIRM: Label 'Subscription Confirmation', MaxLength = 50;

    procedure IntegrationType(): Code[20]
    begin
        exit('ADYEN_HWC');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    begin
        tmpEFTIntegrationType.Init();
        tmpEFTIntegrationType.Code := IntegrationType();
        tmpEFTIntegrationType.Description := CopyStr(Description, 1, MaxStrLen(tmpEFTIntegrationType.Description));
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"NPR EFT Adyen HWC Integrat.";
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
        tmpEFTAuxOperation.Description := CopyStr(ABORT_TRX, 1, MaxStrLen(tmpEFTAuxOperation.Description));
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 2;
        tmpEFTAuxOperation.Description := CopyStr(ACQUIRE_CARD, 1, MaxStrLen(tmpEFTAuxOperation.Description));
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 3;
        tmpEFTAuxOperation.Description := CopyStr(ABORT_ACQUIRED, 1, MaxStrLen(tmpEFTAuxOperation.Description));
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 4;
        tmpEFTAuxOperation.Description := CopyStr(DETECT_SHOPPER, 1, MaxStrLen(tmpEFTAuxOperation.Description));
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 5;
        tmpEFTAuxOperation.Description := CopyStr(CLEAR_SHOPPER, 1, MaxStrLen(tmpEFTAuxOperation.Description));
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 6;
        tmpEFTAuxOperation.Description := CopyStr(DISABLE_CONTRACT, 1, MaxStrLen(tmpEFTAuxOperation.Description));
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 8;
        tmpEFTAuxOperation.Description := SUBSCRIPTION_CONFIRM;
        tmpEFTAuxOperation.Insert();
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

        EFTAdyenintegration.GetPaymentTypeParameters(EFTSetup, EFTAdyenPaymentTypeSetup);
        Commit();
        EFTAdyenPaymTypeSetup.SetLocal();
        EFTAdyenPaymTypeSetup.SetRecord(EFTAdyenPaymentTypeSetup);
        EFTAdyenPaymTypeSetup.RunModal();
    end;

    procedure BuildTransactionRequest(EntryNo: Integer): JsonObject
    var
        EftTransactionRequest: Record "NPR EFT Transaction Request";
        EftSetup: Record "NPR EFT Setup";
        requestJson: Text;
        EFTAdyenTrxRequest: Codeunit "NPR EFT Adyen Trx Request";
        EFTAdyenVoidReq: Codeunit "NPR EFT Adyen Void Req";
        EFTAdyenLookupReq: Codeunit "NPR EFT Adyen Lookup Req";
        EFTAdyenDiagnoseReq: Codeunit "NPR EFT Adyen Diagnose Req";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EftTransactionRequest.Get(EntryNo);
        EftSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::PAYMENT,
            EftTransactionRequest."Processing Type"::REFUND:
                begin
                    requestJson := EFTAdyenTrxRequest.GetRequestJson(EFTTransactionRequest, EFTSetup);
                end;
            EftTransactionRequest."Processing Type"::VOID:
                begin
                    requestJson := EFTAdyenVoidReq.GetRequestJson(EFTTransactionRequest, EFTSetup);
                end;
            EftTransactionRequest."Processing Type"::LOOK_UP:
                begin
                    OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
                    requestJson := EFTAdyenLookupReq.GetRequestJson(EFTTransactionRequest, OriginalEFTTransactionRequest, EFTSetup);
                end;
            EftTransactionRequest."Processing Type"::SETUP:
                begin
                    requestJson := EFTAdyenDiagnoseReq.GetRequestJson(EFTTransactionRequest, EFTSetup);
                end;
            else
                Error('Unsupported operation. This is programming bug, not a user error.');
        end;

        exit(BuildHwcRequest(EntryNo, EftSetup, requestJson))
    end;

    procedure BuildHwcRequest(EntryNo: Integer; EFTSetup: Record "NPR EFT Setup"; RequestJson: Text): JsonObject
    var
        hwcRequest: JsonObject;
        AdyenIntegration: Codeunit "NPR EFT Adyen Integration";
    begin
        hwcRequest.Add('entryNo', EntryNo);
        hwcRequest.Add('terminalRequest', RequestJson);
        hwcRequest.Add('localKeyIdentifier', AdyenIntegration.GetLocalKeyIdentifier(EFTSetup));
        hwcRequest.Add('localKeyPassphrase', AdyenIntegration.GetLocalKeyPassphrase(EFTSetup));
        hwcRequest.Add('localKeyVersion', AdyenIntegration.GetLocalKeyVersion(EFTSetup));
        hwcRequest.Add('terminalEndpoint', AdyenIntegration.GetTerminalEndpoint(EFTSetup));
        exit(hwcRequest);
    end;
}
