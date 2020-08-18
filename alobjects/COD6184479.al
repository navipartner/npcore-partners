codeunit 6184479 "EFT Interface"
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object
    // NPR5.48/MMV /20190123 CASE 341237 Added new events for skipping pause/unpause of front end.
    // NPR5.51/MMV /20190626 CASE 359385 Added gift card event
    // NPR5.55/MMV /20200420 CASE 386254 Added event for retrieving integration workflow


    trigger OnRun()
    begin
    end;

    local procedure "// Discovery"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "EFT Integration Type" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnDiscoverAuxiliaryOperations(var tmpEFTAuxOperation: Record "EFT Aux Operation" temporary)
    begin
    end;

    local procedure "// Configuration"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnConfigureIntegrationUnitSetup(EFTSetup: Record "EFT Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnConfigureIntegrationPaymentSetup(EFTSetup: Record "EFT Setup")
    begin
    end;

    local procedure "// Requests"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCreateBeginWorkshiftRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCreateEndWorkshiftRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCreateRefundRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCreateVoidRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCreateVerifySetupRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCreateLookupTransactionRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCreateAuxRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCreateGiftCardLoadRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendEftDeviceRequest(EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetIntegrationRequestWorkflow(EFTTransactionRequest: Record "EFT Transaction Request";var IntegrationWorkflow: Text)
    begin
    end;

    local procedure "// Aux"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterFinancialCommit(EftTransactionRequest: Record "EFT Transaction Request")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterPaymentConfirm(EftTransactionRequest: Record "EFT Transaction Request";var DoNotResume: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnQueueCloseBeforeRegisterBalance(POSSession: Codeunit "POS Session";var tmpEFTSetup: Record "EFT Setup" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnDisplayReceipt(EFTTransactionRequest: Record "EFT Transaction Request";ReceiptNo: Integer;var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnPrintReceipt(EFTTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforePauseFrontEnd(EFTTransactionRequest: Record "EFT Transaction Request";var Skip: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeResumeFrontEnd(EFTTransactionRequest: Record "EFT Transaction Request";var Skip: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeLookupPrompt(EFTTransactionRequest: Record "EFT Transaction Request";var Skip: Boolean)
    begin
    end;

    local procedure "// Response"()
    begin
    end;

    procedure EftIntegrationResponse(var EftTransactionRequest: Record "EFT Transaction Request")
    var
        EFTFramework: Codeunit "EFT Framework Mgt.";
    begin
        EFTFramework.EftIntegrationResponseReceived(EftTransactionRequest);
    end;
}

