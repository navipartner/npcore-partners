codeunit 6184479 "NPR EFT Interface"
{
    Access = Internal;

    trigger OnRun()
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnDiscoverAuxiliaryOperations(var tmpEFTAuxOperation: Record "NPR EFT Aux Operation" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnConfigureIntegrationUnitSetup(EFTSetup: Record "NPR EFT Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnConfigureIntegrationPaymentSetup(EFTSetup: Record "NPR EFT Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCreateBeginWorkshiftRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCreateEndWorkshiftRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCreateRefundRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCreateVoidRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCreateVerifySetupRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCreateLookupTransactionRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCreateAuxRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCreateGiftCardLoadRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCreateHwcEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; var EftHwcRequest: JsonObject; var Handled: Boolean)
    begin
    end;

    [Obsolete('Use HWC)')]
    [IntegrationEvent(false, false)]
    internal procedure OnSendEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGetIntegrationRequestWorkflow(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var IntegrationWorkflow: Text; EftJsonRequest: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterFinancialCommit(EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterPaymentConfirm(EftTransactionRequest: Record "NPR EFT Transaction Request"; var DoNotResume: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnQueueCloseBeforeRegisterBalance(POSSession: Codeunit "NPR POS Session"; var tmpEFTSetup: Record "NPR EFT Setup" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnDisplayReceipt(EFTTransactionRequest: Record "NPR EFT Transaction Request"; ReceiptNo: Integer; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnPrintReceipt(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforePauseFrontEnd(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Skip: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeResumeFrontEnd(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Skip: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeLookupPrompt(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Skip: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnHwcEftDeviceResponse(HwcName: Text; HwcType: Text; Request: JsonObject; Response: JsonObject; Result: JsonObject; var Handled: Boolean)
    begin
    end;

    procedure OnHwcEftDeviceResponseNotHandled(HwcName: Text; HwcType: Text);
    var
        NotHandled: Label 'Hardware Connector response from %1 %2 is not handled.';
    begin
        Error(NotHandled, HwcName, HwcType);
    end;

    procedure EftIntegrationResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTFramework: Codeunit "NPR EFT Framework Mgt.";
    begin
        EFTFramework.EftIntegrationResponseReceived(EftTransactionRequest);
    end;
}

