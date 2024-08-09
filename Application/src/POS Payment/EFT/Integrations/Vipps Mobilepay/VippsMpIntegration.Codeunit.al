codeunit 6184692 "NPR Vipps Mp Integration"
{
    Access = Internal;

    procedure IntegrationType(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::"VIPPS_MOBILEPAY"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    var
        LblDescription: Label 'Vipps Mobilepay integration';
    begin
        tmpEFTIntegrationType.Init();
        tmpEFTIntegrationType.Code := IntegrationType();
        tmpEFTIntegrationType.Description := LblDescription;
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"NPR Vipps Mp Integration";
        tmpEFTIntegrationType."Version 2" := True;
        tmpEFTIntegrationType.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnConfigureIntegrationUnitSetup', '', false, false)]
    local procedure OnConfigureIntegrationUnitSetup(EFTSetup: Record "NPR EFT Setup")
    var
        VippsMpUnitSetup: Record "NPR Vipps Mp Unit Setup";
        VippsMpSetupState: Codeunit "NPR Vipps Mp SetupState";
        LblSpecifyPos: Label 'Please specify a POS Unit first.';
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;
        if (EFTSetup."POS Unit No." = '') then begin
            Message(LblSpecifyPos);
            exit;
        end;
        if (not VippsMpUnitSetup.Get(EFTSetup."POS Unit No.")) then begin
            VippsMpUnitSetup.Init();
            VippsMpUnitSetup."POS Unit No." := EFTSetup."POS Unit No.";
            VippsMpUnitSetup.Insert();
        end;
        VippsMpSetupState.SetCurrentPosUnitNo(EFTSetup."POS Unit No.");
        PAGE.Run(0, VippsMpUnitSetup);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnConfigureIntegrationPaymentSetup', '', false, false)]
    local procedure OnConfigureIntegrationPaymentSetup(EFTSetup: Record "NPR EFT Setup")
    var
        MpVippsPaymentSetup: Record "NPR Vipps Mp Payment Setup";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;
        GetPaymentTypeParameters(EFTSetup, MpVippsPaymentSetup);
        Commit();
        PAGE.RunModal(PAGE::"NPR Vipps Mp Payment Setup", MpVippsPaymentSetup);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
    begin
        if (not EftTransactionRequest.IsType(IntegrationType())) then
            exit;
#pragma warning disable AA0139
        EftTransactionRequest."Reference Number Input" := VippsMpUtil.RemoveCurlyBraces(EftTransactionRequest.Token);
#pragma warning restore AA0139
        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest.Insert(true);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateLookupTransactionRequest', '', false, false)]
    local procedure OnCreateLookupTransactionRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        oldEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if (not EftTransactionRequest.IsType(IntegrationType())) then
            exit;
        oldEFTTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");
        EftTransactionRequest."Reference Number Input" := oldEFTTransactionRequest."Reference Number Input";
        EftTransactionRequest.Insert(true);
        Handled := True;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateRefundRequest', '', false, false)]
    local procedure OnCreateRefundRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        oldEFTTransactionRequest: Record "NPR EFT Transaction Request";
        LblError: Label 'Can only refund payments created with this integration.';
    begin
        if (not EftTransactionRequest.IsType(IntegrationType())) then
            exit;
        if ((not oldEFTTransactionRequest.Get(EftTransactionRequest."Processed Entry No.")) and (oldEFTTransactionRequest."Integration Type" = IntegrationType())) then
            Error(LblError);
        EftTransactionRequest."Reference Number Input" := oldEFTTransactionRequest."Reference Number Input";
        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest.Insert(true);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnPrepareRequestSend', '', false, false)]

    local procedure OnPrepareRequestSend(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Request: JsonObject; var RequestMechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text)
    var
        VippsMpUnitSetup: Record "NPR Vipps Mp Unit Setup";
        VippsMpQrCallback: Record "NPR Vipps Mp QrCallback";
        POSUnit: Record "NPR POS Unit";
        HtmlProfile: Record "NPR POS HTML Disp. Prof.";
    begin
        if (not EftTransactionRequest.IsType(IntegrationType())) then
            exit;
        Workflow := IntegrationType();
        if (EftTransactionRequest."Processing Type" in
            [EftTransactionRequest."Processing Type"::PAYMENT,
            EftTransactionRequest."Processing Type"::REFUND]) then begin
            RequestMechanism := RequestMechanism::POSWorkflow;
            VippsMpUnitSetup.Get(EftTransactionRequest."Register No.");
            VippsMpQrCallback.Get(VippsMpUnitSetup."Merchant Qr Id");
            Request.Add('EFTEntryNo', EftTransactionRequest."Entry No.");
            Request.Add('PaymentSetupCode', EftTransactionRequest."Original POS Payment Type Code");
            Request.Add('ReferenceNumberInput', EftTransactionRequest."Reference Number Input");
            if (EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::PAYMENT) then
                Request.Add('Type', 'PAYMENT');
            if (EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::REFUND) then
                Request.Add('Type', 'REFUND');
            Request.Add('QrContent', VippsMpQrCallback."Qr Content");
            Request.Add('FormattedAmount', Format(EftTransactionRequest."Amount Input", 0, '<Precision,2:2><Standard Format,2>'));
            if (POSUnit.Get(EftTransactionRequest."Register No.") and HtmlProfile.Get(POSUnit."POS HTML Display Profile")) then
                Request.Add('QrOnCustomerDisplay', HtmlProfile."MobilePay QR");
        end;
        if (EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::LOOK_UP) then begin
            RequestMechanism := RequestMechanism::Synchronous;
        end;


    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnSendRequestSynchronously', '', false, false)]

    local procedure OnSendRequestSynchronously(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        OldEFTTransactionRequest: Record "NPR EFT Transaction Request";
        VippsMpLog: Codeunit "NPR Vipps Mp Log";
        VippsMpePaymentAPI: Codeunit "NPR Vipps Mp ePayment API";
        VippsMpResponseHandler: Codeunit "NPR Vipps Mp Response Handler";
        EFTInterface: Codeunit "NPR EFT Interface";
        LookupContent: JsonObject;
        ErrLbl: Label 'Error on Lookup: %1';
        ErrProcTypeLbl: Label 'Only supports lookup as synchronised requests.';
    begin
        if (not EftTransactionRequest.IsType(IntegrationType())) then
            exit;
        if (EftTransactionRequest."Processing Type" <> EftTransactionRequest."Processing Type"::LOOK_UP) then
            Error(ErrProcTypeLbl);
        if (VippsMpePaymentAPI.GetPayment(EftTransactionRequest, LookupContent)) then begin
            VippsMpLog.Log(Enum::"NPR Vipps Mp Log Lvl"::All, EftTransactionRequest, 'Lookup', LookupContent);
            VippsMpResponseHandler.HandleLookupResponse(EftTransactionRequest, LookupContent);
        end else begin
            Message(StrSubstNo(ErrLbl, GetLastErrorText()));
            EftTransactionRequest."Result Description" := 'LOOKUP FAILED';
            OldEFTTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");
#pragma warning disable AA0139
            EftTransactionRequest."Client Error" := CopyStr(GetLastErrorText(), 1, 250);
#pragma warning restore AA0139
            OldEFTTransactionRequest."POS Description" := 'Vipps Mobilepay: Not Found';
            OldEFTTransactionRequest.Recoverable := false;
            OldEFTTransactionRequest.Modify();
            EFTInterface.EftIntegrationResponse(OldEFTTransactionRequest);
            EFTInterface.EftIntegrationResponse(EftTransactionRequest);
            VippsMpLog.Log(Enum::"NPR Vipps Mp Log Lvl"::Error, EftTransactionRequest, 'Lookup Failed', LookupContent);
        end;
        Handled := true
    end;

    local procedure GetPaymentTypeParameters(EFTSetup: Record "NPR EFT Setup"; var EFTPaymentConfig: Record "NPR Vipps Mp Payment Setup")
    begin
        GetPaymentTypeParameters(EFTSetup."Payment Type POS", EFTPaymentConfig);
    end;

    internal procedure GetPaymentTypeParameters(VippsPaymentSetupCode: Code[10]; var EFTPaymentConfig: Record "NPR Vipps Mp Payment Setup")
    begin
        if not EFTPaymentConfig.Get(VippsPaymentSetupCode) then begin
            EFTPaymentConfig.Init();
            EFTPaymentConfig."Payment Type POS" := VippsPaymentSetupCode;
            EFTPaymentConfig."Log Level" := Enum::"NPR Vipps Mp Log Lvl"::Error;
            EFTPaymentConfig.Insert();
        end;
    end;
}