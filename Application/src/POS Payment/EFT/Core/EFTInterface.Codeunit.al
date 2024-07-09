codeunit 6184479 "NPR EFT Interface"
{
    Access = Internal;

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
    procedure OnPrepareRequestSend(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Request: JsonObject; var RequestMechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendRequestSynchronously(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterFinancialCommit(EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
    end;

    /// <summary>
    /// This event can be used to either queue an integration specific workflow along with parameters in the dictionary OR
    /// to execute a synchronous reconciliation directly in AL code, depending on what each integration needs.
    /// </summary>
    /// <param name="EndOfDayType"></param>
    /// <param name="EftWorkflows"></param>
    [IntegrationEvent(false, false)]
    internal procedure OnEndOfDayCloseEft(EndOfDayType: Option "X-Report","Z-Report",CloseWorkShift; var EftWorkflows: Dictionary of [Text, JsonObject])
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
    internal procedure OnGenericWorkflowResponse(EFTTransactionRequest: Record "NPR EFT Transaction Request"; Request: JsonObject; Response: JsonObject; Result: JsonObject; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCreateVoidEFTRequestOnPaymentLineDelete(var SaleLinePOS: Record "NPR POS Sale Line"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure AllowVoidEFTRequestOnPaymentLineDelete(SaleLinePOS: Record "NPR POS Sale Line"; var IsAllowed: Boolean; var Handled: Boolean)
    begin
    end;


    /// <summary>
    /// This method should be called from an EFT integration implementing this interface to return control back to the EFT module when a transaction is done. 
    /// It will process the resulting EFT data on the record and create associated records such as POS payments and (!) commit everything. 
    /// Meaning, when a specific integration reaches a success/failure/error state for any EFT transaction they should modify their data onto the record, but not commit manually, 
    /// and then call this method.    
    /// </summary>
    /// <param name="EftTransactionRequest"></param>
    procedure EftIntegrationResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTFramework: Codeunit "NPR EFT Framework Mgt.";
    begin
        EFTFramework.EftIntegrationResponseReceived(EftTransactionRequest);
    end;

    #region Obsolete
    [Obsolete('Move to workflow v3 and subscribe to OnPrepareRequestSend and, if synchronous instead of via workflow, OnSendRequestSynchronously instead of this', '2023-06-28')]
    [IntegrationEvent(false, false)]
    internal procedure OnSendEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
    end;

    [Obsolete('Move to workflow v3 and subscribe to OnPrepareRequestSend and/or OnSendRequestSynchronously instead of this', '2023-06-28')]
    [IntegrationEvent(false, false)]
    internal procedure OnGetIntegrationRequestWorkflow(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var IntegrationWorkflow: Text; EftJsonRequest: JsonObject)
    begin
    end;

    [Obsolete('Move to workflow v3 and subscribe to OnPrepareRequestSend and/or OnSendRequestSynchronously instead of this', '2023-06-28')]
    [IntegrationEvent(false, false)]
    internal procedure OnBeforePauseFrontEnd(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Skip: Boolean)
    begin
    end;

    [Obsolete('Move to workflow v3 and subscribe to OnPrepareRequestSend and/or OnSendRequestSynchronously instead of this', '2023-06-28')]
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeResumeFrontEnd(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Skip: Boolean)
    begin
    end;

    [Obsolete('Move to workflow v3 and subscribe to OnPrepareRequestSend and/or OnSendRequestSynchronously instead of this', '2023-06-28')]
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeLookupPrompt(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Skip: Boolean)
    begin
    end;

    [Obsolete('Move to workflow v3 and subscribe to OnPrepareRequestSend and/or OnSendRequestSynchronously instead of this', '2023-06-28')]
    [IntegrationEvent(false, false)]
    internal procedure OnAfterPaymentConfirm(EftTransactionRequest: Record "NPR EFT Transaction Request"; var DoNotResume: Boolean)
    begin
    end;

    [Obsolete('Use OnEndOfDayCloseEft', '2023-06-28')]
    [IntegrationEvent(false, false)]
    internal procedure OnQueueCloseBeforeRegisterBalance(POSSession: Codeunit "NPR POS Session"; var tmpEFTSetup: Record "NPR EFT Setup" temporary)
    begin
    end;
    #endregion
}

