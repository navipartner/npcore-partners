codeunit 6184515 "EFT Flexiiterm Integration"
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object
    // NPR5.48/MMV /20190125 CASE 341237 Renamed desc
    // NPR5.49/MMV /20190312 CASE 345188 Renamed object


    trigger OnRun()
    begin
    end;

    var
        Description: Label 'NETS PSAM integration via Flexiiterm';
        NO_SESSION_ERROR: Label 'POS Session is missing. EFT Request cancelled.';
        ZERO_AMOUNT_ERROR: Label 'Cannot start EFT Request for zero amount';

    procedure IntegrationType(): Text
    begin
        exit('FLEXIITERM');
    end;

    local procedure "// EFT Interface implementation"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "EFT Integration Type" temporary)
    begin
        tmpEFTIntegrationType.Init;
        tmpEFTIntegrationType.Code := IntegrationType();
        tmpEFTIntegrationType.Description := Description;
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"EFT Flexiiterm Integration";
        tmpEFTIntegrationType.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnConfigureIntegrationUnitSetup', '', false, false)]
    local procedure OnConfigureIntegrationUnitSetup(EFTSetup: Record "EFT Setup")
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
          exit;

        GetFolderPath(EFTSetup);
        GetSurchargeStatus(EFTSetup);
        GetSurchargeDialogStatus(EFTSetup);

        EFTSetup.ShowEftPOSUnitParameters();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnConfigureIntegrationPaymentSetup', '', false, false)]
    local procedure OnConfigureIntegrationPaymentSetup(EFTSetup: Record "EFT Setup")
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
          exit;

        GetCVM(EFTSetup);
        GetTransactionType(EFTSetup);

        EFTSetup.ShowEftPaymentParameters();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;
        Handled := true;

        if EftTransactionRequest."Amount Input" = 0 then
          Error(ZERO_AMOUNT_ERROR);
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateRefundRequest', '', false, false)]
    local procedure OnCreateRefundRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;
        Handled := true;

        if EftTransactionRequest."Amount Input" = 0 then
          Error(ZERO_AMOUNT_ERROR);
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnSendEftDeviceRequest', '', false, false)]
    local procedure OnSendEftDeviceRequest(EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    var
        EFTFlexiitermProtocol: Codeunit "EFT Flexiiterm Protocol";
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;
        Handled := true;

        EFTFlexiitermProtocol.SendRequest(EftTransactionRequest);
    end;

    local procedure "// Protocol Response"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184516, 'OnAfterProtocolResponse', '', false, false)]
    local procedure OnAfterProtocolResponse(var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        EFTInterface: Codeunit "EFT Interface";
    begin
        EFTInterface.EftIntegrationResponse(EFTTransactionRequest);
    end;

    local procedure "// Aux"()
    begin
    end;

    procedure GetPOSDescription(EFTTransactionRequest: Record "EFT Transaction Request"): Text
    var
        PepperCardType: Record "Pepper Card Type";
        TextDescription: Label '%1:%2';
        TextUnknown: Label 'Card: %1';
    begin
        with EFTTransactionRequest do begin
          if ("Card Name" <> '') then begin
            if (StrLen("Card Number") > 8) then
              exit(StrSubstNo (TextDescription, CopyStr ("Card Name",1,8), CopyStr("Card Number", StrLen("Card Number")-7)))
            else
              exit (StrSubstNo("Card Name"));
          end else begin
            exit(StrSubstNo(TextUnknown, "Card Number"));
          end;
        end;
    end;

    procedure GetFolderPath(EFTSetup: Record "EFT Setup"): Text
    var
        EFTTypePOSUnitGenParam: Record "EFT Type POS Unit Gen. Param.";
    begin
        exit(EFTTypePOSUnitGenParam.GetTextParameterValue(IntegrationType(), EFTSetup."POS Unit No.", 'Folder Path', 'C:\Dankort\', true));
    end;

    procedure GetSurchargeStatus(EFTSetup: Record "EFT Setup"): Boolean
    var
        EFTTypePOSUnitGenParam: Record "EFT Type POS Unit Gen. Param.";
    begin
        exit(EFTTypePOSUnitGenParam.GetBooleanParameterValue(IntegrationType(), EFTSetup."POS Unit No.", 'Surcharge', false, true));
    end;

    procedure GetSurchargeDialogStatus(EFTSetup: Record "EFT Setup"): Boolean
    var
        EFTTypePOSUnitGenParam: Record "EFT Type POS Unit Gen. Param.";
    begin
        exit(EFTTypePOSUnitGenParam.GetBooleanParameterValue(IntegrationType(), EFTSetup."POS Unit No.", 'Surcharge Confirm Dialog', false, true));
    end;

    procedure GetCVM(EFTSetup: Record "EFT Setup"): Integer
    var
        EFTTypePaymentGenParam: Record "EFT Type Payment Gen. Param.";
    begin
        exit(EFTTypePaymentGenParam.GetOptionParameterValue(IntegrationType(), EFTSetup."Payment Type POS", 'CVM', 0, 'CVM not Forced,Forced Signature,Forced Pin', true));
    end;

    procedure GetTransactionType(EFTSetup: Record "EFT Setup"): Integer
    var
        EFTTypePaymentGenParam: Record "EFT Type Payment Gen. Param.";
    begin
        exit(EFTTypePaymentGenParam.GetOptionParameterValue(IntegrationType(), EFTSetup."Payment Type POS", 'Transaction Type', 0, 'Not Forced,Forced Online,Forced Offline', true));
    end;
}

