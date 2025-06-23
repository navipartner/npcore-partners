codeunit 6184515 "NPR EFT Flexiiterm Integ."
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'No longer supported';

    var
        IntegrationType: Label 'FLEXIITERM', Locked = true;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    var
        Description: Label 'NETS PSAM integration via Flexiiterm';
    begin
        tmpEFTIntegrationType.Init();
        tmpEFTIntegrationType.Code := IntegrationType;
        tmpEFTIntegrationType.Description := Description;
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"NPR EFT Flexiiterm Integ.";
        tmpEFTIntegrationType."Version 2" := true;
        tmpEFTIntegrationType.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnConfigureIntegrationUnitSetup', '', false, false)]
    local procedure OnConfigureIntegrationUnitSetup(EFTSetup: Record "NPR EFT Setup")
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType then
            exit;

        GetFolderPath(EFTSetup);
        GetSurchargeStatus(EFTSetup);
        GetSurchargeDialogStatus(EFTSetup);

        EFTSetup.ShowEftPOSUnitParameters();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnConfigureIntegrationPaymentSetup', '', false, false)]
    local procedure OnConfigureIntegrationPaymentSetup(EFTSetup: Record "NPR EFT Setup")
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType then
            exit;

        GetCVM(EFTSetup);
        GetTransactionType(EFTSetup);

        EFTSetup.ShowEftPaymentParameters();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType) then
            exit;
        Handled := true;

        EftTransactionRequest.TestField("Amount Input");
        if EftTransactionRequest."Cashback Amount" = EftTransactionRequest."Amount Input" then
            EftTransactionRequest.FieldError("Cashback Amount"); //100% cashback crashes terminal SDK from NETS...
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateRefundRequest', '', false, false)]
    local procedure OnCreateRefundRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType) then
            exit;
        Handled := true;

        EftTransactionRequest.TestField("Amount Input");
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateGiftCardLoadRequest', '', false, false)]
    local procedure OnCreateGiftcardLoadRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType) then
            exit;
        Handled := true;

        EftTransactionRequest.TestField("Amount Input");
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnPrepareRequestSend', '', false, false)]
    local procedure OnPrepareRequestSend(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Request: JsonObject; var RequestMechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text)
    var
        EFTFlexiitermProtocol: Codeunit "NPR EFT Flexiiterm Prot.";
    begin
        if not EftTransactionRequest.IsType(IntegrationType) then
            exit;

        RequestMechanism := RequestMechanism::POSWorkflow;
        Workflow := Format(Enum::"NPR POS Workflow"::EFT_FLEXIITERM);
        EFTFlexiitermProtocol.ConstructTransaction(EftTransactionRequest, Request);
    end;

#if not BC17
//Message breaks before BC17.6
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnAfterFinancialCommit', '', false, false)]
    local procedure OnAfterGiftCardLoadFinancialCommit(EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        if not EftTransactionRequest.IsType(IntegrationType) then
            exit;
        if EftTransactionRequest."Processing Type" <> EftTransactionRequest."Processing Type"::GIFTCARD_LOAD then
            exit;
        if not EftTransactionRequest.Successful then
            exit;

        WarnIfVoucherPaymentTypeMismatch(EftTransactionRequest);
    end;
#endif            

    procedure GetPOSDescription(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    var
        TextDescription: Label '%1:%2';
        TextUnknown: Label 'Card: %1';
    begin
        if (EFTTransactionRequest."Card Name" <> '') then begin
            if (StrLen(EFTTransactionRequest."Card Number") > 8) then
                exit(StrSubstNo(TextDescription, CopyStr(EFTTransactionRequest."Card Name", 1, 8), CopyStr(EFTTransactionRequest."Card Number", StrLen(EFTTransactionRequest."Card Number") - 7)))
            else
                exit(StrSubstNo(EFTTransactionRequest."Card Name"));
        end else begin
            exit(StrSubstNo(TextUnknown, EFTTransactionRequest."Card Number"));
        end;
    end;

    procedure WarnIfVoucherPaymentTypeMismatch(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        WarningCardTypeLbl: Label 'Warning:\The %1 %2 used for %3 is not set as type %4. This is either caused by a wrong card swipe on terminal or incorrect setup.';
    begin
        POSPaymentMethod.Get(EFTTransactionRequest."POS Payment Type Code");
        if POSPaymentMethod."Processing Type" <> POSPaymentMethod."Processing Type"::VOUCHER then
            Message(WarningCardTypeLbl, POSPaymentMethod.TableCaption, POSPaymentMethod.Code, EFTTransactionRequest."Processing Type", POSPaymentMethod."Processing Type"::VOUCHER);
    end;

    procedure GetFolderPath(EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTTypePOSUnitGenParam: Record "NPR EFTType POSUnit Gen.Param.";
    begin
        exit(EFTTypePOSUnitGenParam.GetTextParameterValue(IntegrationType, EFTSetup."POS Unit No.", 'Folder Path', 'C:\Dankort\', true));
    end;

    procedure GetSurchargeStatus(EFTSetup: Record "NPR EFT Setup"): Boolean
    var
        EFTTypePOSUnitGenParam: Record "NPR EFTType POSUnit Gen.Param.";
    begin
        exit(EFTTypePOSUnitGenParam.GetBooleanParameterValue(IntegrationType, EFTSetup."POS Unit No.", 'Surcharge', false, true));
    end;

    procedure GetSurchargeDialogStatus(EFTSetup: Record "NPR EFT Setup"): Boolean
    var
        EFTTypePOSUnitGenParam: Record "NPR EFTType POSUnit Gen.Param.";
    begin
        exit(EFTTypePOSUnitGenParam.GetBooleanParameterValue(IntegrationType, EFTSetup."POS Unit No.", 'Surcharge Confirm Dialog', false, true));
    end;

    procedure GetCVM(EFTSetup: Record "NPR EFT Setup"): Integer
    var
        EFTTypePaymentGenParam: Record "NPR EFT Type Pay. Gen. Param.";
    begin
        exit(EFTTypePaymentGenParam.GetOptionParameterValue(IntegrationType, EFTSetup."Payment Type POS", 'CVM', 0, 'CVM not Forced,Forced Signature,Forced Pin', true));
    end;

    procedure GetTransactionType(EFTSetup: Record "NPR EFT Setup"): Integer
    var
        EFTTypePaymentGenParam: Record "NPR EFT Type Pay. Gen. Param.";
    begin
        exit(EFTTypePaymentGenParam.GetOptionParameterValue(IntegrationType, EFTSetup."Payment Type POS", 'Transaction Type', 0, 'Not Forced,Forced Online,Forced Offline', true));
    end;
}
