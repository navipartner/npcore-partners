codeunit 6184515 "NPR EFT Flexiiterm Integ."
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object
    // NPR5.48/MMV /20190125 CASE 341237 Renamed desc
    // NPR5.49/MMV /20190312 CASE 345188 Renamed object
    // NPR5.51/MMV /20190626 CASE 359385 Added gift card load support.
    // NPR5.54/MMV /20200131 CASE 387965 Reintroduced gift card balance check integration.


    trigger OnRun()
    begin
    end;

    var
        Description: Label 'NETS PSAM integration via Flexiiterm';
        ZERO_AMOUNT_ERROR: Label 'Cannot start EFT Request for zero amount';

    procedure IntegrationType(): Code[20]
    begin
        exit('FLEXIITERM');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    begin
        tmpEFTIntegrationType.Init();
        tmpEFTIntegrationType.Code := IntegrationType();
        tmpEFTIntegrationType.Description := Description;
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"NPR EFT Flexiiterm Integ.";
        tmpEFTIntegrationType.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnConfigureIntegrationUnitSetup', '', false, false)]
    local procedure OnConfigureIntegrationUnitSetup(EFTSetup: Record "NPR EFT Setup")
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;

        GetFolderPath(EFTSetup);
        GetSurchargeStatus(EFTSetup);
        GetSurchargeDialogStatus(EFTSetup);

        EFTSetup.ShowEftPOSUnitParameters();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnConfigureIntegrationPaymentSetup', '', false, false)]
    local procedure OnConfigureIntegrationPaymentSetup(EFTSetup: Record "NPR EFT Setup")
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;

        GetCVM(EFTSetup);
        GetTransactionType(EFTSetup);

        EFTSetup.ShowEftPaymentParameters();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        if EftTransactionRequest."Amount Input" = 0 then
            Error(ZERO_AMOUNT_ERROR);
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateRefundRequest', '', false, false)]
    local procedure OnCreateRefundRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        if EftTransactionRequest."Amount Input" = 0 then
            Error(ZERO_AMOUNT_ERROR);
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateGiftCardLoadRequest', '', false, false)]
    local procedure OnCreateGiftcardLoadRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        //-NPR5.51 [359385]
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        EftTransactionRequest.TestField("Amount Input");
        EftTransactionRequest.Insert(true);
        //+NPR5.51 [359385]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnSendEftDeviceRequest', '', false, false)]
    local procedure OnSendEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        EFTFlexiitermProtocol: Codeunit "NPR EFT Flexiiterm Prot.";
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        EFTFlexiitermProtocol.SendRequest(EftTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184516, 'OnAfterProtocolResponse', '', false, false)]
    local procedure OnAfterProtocolResponse(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTInterface: Codeunit "NPR EFT Interface";
    begin
        EFTInterface.EftIntegrationResponse(EFTTransactionRequest);
    end;

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

    procedure GetFolderPath(EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTTypePOSUnitGenParam: Record "NPR EFTType POSUnit Gen.Param.";
    begin
        exit(EFTTypePOSUnitGenParam.GetTextParameterValue(IntegrationType(), EFTSetup."POS Unit No.", 'Folder Path', 'C:\Dankort\', true));
    end;

    procedure GetSurchargeStatus(EFTSetup: Record "NPR EFT Setup"): Boolean
    var
        EFTTypePOSUnitGenParam: Record "NPR EFTType POSUnit Gen.Param.";
    begin
        exit(EFTTypePOSUnitGenParam.GetBooleanParameterValue(IntegrationType(), EFTSetup."POS Unit No.", 'Surcharge', false, true));
    end;

    procedure GetSurchargeDialogStatus(EFTSetup: Record "NPR EFT Setup"): Boolean
    var
        EFTTypePOSUnitGenParam: Record "NPR EFTType POSUnit Gen.Param.";
    begin
        exit(EFTTypePOSUnitGenParam.GetBooleanParameterValue(IntegrationType(), EFTSetup."POS Unit No.", 'Surcharge Confirm Dialog', false, true));
    end;

    procedure GetCVM(EFTSetup: Record "NPR EFT Setup"): Integer
    var
        EFTTypePaymentGenParam: Record "NPR EFT Type Pay. Gen. Param.";
    begin
        exit(EFTTypePaymentGenParam.GetOptionParameterValue(IntegrationType(), EFTSetup."Payment Type POS", 'CVM', 0, 'CVM not Forced,Forced Signature,Forced Pin', true));
    end;

    procedure GetTransactionType(EFTSetup: Record "NPR EFT Setup"): Integer
    var
        EFTTypePaymentGenParam: Record "NPR EFT Type Pay. Gen. Param.";
    begin
        exit(EFTTypePaymentGenParam.GetOptionParameterValue(IntegrationType(), EFTSetup."Payment Type POS", 'Transaction Type', 0, 'Not Forced,Forced Online,Forced Offline', true));
    end;
}

