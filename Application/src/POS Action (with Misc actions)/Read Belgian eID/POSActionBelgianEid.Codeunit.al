codeunit 6151589 "NPR POS Action: BelgianEid" implements "NPR IPOS Workflow"
{
    Access = Internal;

    local procedure HwcIntegrationName(): Text
    begin
        exit('BelgianEid');
    end;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Read Belgian eID card.';
        WorkflowTitle: Label 'Belgian eID';
        Executing: Label 'Preparing...';
        Finalizing: Label 'Finalizing...';
        Aborting: Label 'Aborting...';
        ConfirmAbort: Label 'Are you sure you want to abort this operation?';
        StatusProcessing: Label 'Processing the data...';
        RspTypeUnknown: Label 'Unknown error occurred';
        RspTypeUpdate: Label 'Reading the eID card...';
        RspTypeTokenWait: Label 'Please insert the eID card';
        RspTypeError: Label 'An error occurred';
        RspTypeCancel: Label 'The operation was canceled';
        RspTypeSuccess: Label 'The operation succeeded';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('workflowTitle', WorkflowTitle);
        WorkflowConfig.AddLabel('statusExecuting', Executing);
        WorkflowConfig.AddLabel('statusFinalizing', Finalizing);
        WorkflowConfig.AddLabel('statusAborting', Aborting);
        WorkflowConfig.AddLabel('statusProcessing', StatusProcessing);
        WorkflowConfig.AddLabel('confirmAbort', ConfirmAbort);
        WorkflowConfig.AddLabel('rspTypeUnknown', RspTypeUnknown);
        WorkflowConfig.AddLabel('rspTypeUpdate', RspTypeUpdate);
        WorkflowConfig.AddLabel('rspTypeTokenWait', RspTypeTokenWait);
        WorkflowConfig.AddLabel('rspTypeError', RspTypeError);
        WorkflowConfig.AddLabel('rspTypeCancel', RspTypeCancel);
        WorkflowConfig.AddLabel('rspTypeSuccess', RspTypeSuccess);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        CASE Step OF
            'SetValuesToContext':
                SetValuesToContext(Context, Sale, Setup);
            'Process':
                Frontend.WorkflowResponse(ProcessCardData(Context, Sale, Setup));
        end;
    end;

    local procedure SetValuesToContext(Context: Codeunit "NPR POS JSON Helper"; Sale: codeunit "NPR POS Sale"; Setup: Codeunit "NPR POS Setup")
    var
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        SalePOS: Record "NPR POS Sale";
        Salesperson: Record "Salesperson/Purchaser";
        HwcRequest: JsonObject;
    begin
        Setup.GetPOSStore(POSStore);
        Setup.GetPOSUnit(POSUnit);
        Setup.GetSalespersonRecord(Salesperson);
        Sale.GetCurrentSale(SalePOS);

        HwcRequest.Add('HwcName', HwcIntegrationName());
        HwcRequest.Add('CardAction', 'Read');

        HwcRequest.Add('PosStoreCode', POSStore.Code);
        HwcRequest.Add('PosUnitNo', POSUnit."No.");
        HwcRequest.Add('SalePosRegisterNo', SalePOS."Register No.");
        HwcRequest.Add('SalePosSalesTicketNo', SalePOS."Sales Ticket No.");
        HwcRequest.Add('SalespersonCode', Salesperson.Code);

        HwcRequest.Add('CancelTimeout', 3 * 60); // 3mins

        Context.SetContext('hwcRequest', HwcRequest);
        Context.SetContext('showSpinner', true);
    end;

    local procedure ProcessCardData(Context: Codeunit "NPR POS JSON Helper"; Sale: codeunit "NPR POS Sale"; Setup: Codeunit "NPR POS Setup") Result: JsonObject
    var
        HwcResponse: JsonObject;
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        SalePOS: Record "NPR POS Sale";
        Salesperson: Record "Salesperson/Purchaser";
        ProcessBeId: Codeunit "NPR POS Action:ProcessBeIdData";
    begin
        // BC Data
        Setup.GetPOSStore(POSStore);
        Setup.GetPOSUnit(POSUnit);
        Setup.GetSalespersonRecord(Salesperson);
        Sale.GetCurrentSale(SalePOS);

        // HWC data
        HwcResponse := Context.GetJsonObject('hwcResponse');

        Result := ProcessBeId.ProcessCardData(POSStore, POSUnit, SalePOS, Salesperson, HwcResponse);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionBelgianEid.js###
'let main=async({workflow:o,hwc:r,popup:i,context:n,captions:a})=>{let e,s,l={Success:!1};await o.respond("SetValuesToContext"),n.showSpinner&&(e=await i.simpleSpinner({caption:a.workflowTitle,onAbort:async()=>{await i.confirm(a.confirmAbort)&&(e.updateStatus(a.statusAborting),await r.invoke(n.hwcRequest.HwcName,{CardAction:"RequestCancel"},s))},abortValue:{completed:"Aborted"}}));try{return s=r.registerResponseHandler(async t=>{switch(t.RspType){case"Success":try{console.log("[BelgianEid HWC] ",t),e&&e.updateStatus(a.statusProcessing),l=await o.respond("Process",{hwcResponse:t}),r.unregisterResponseHandler(s),l.Success?l.ShowSuccessMessage&&i.message({caption:l.Message,title:a.workflowTitle}):i.error({caption:l.Message,title:a.workflowTitle})}catch(u){r.unregisterResponseHandler(s,u)}break;case"TokenWait":e&&e.updateStatus(a.rspTypeTokenWait),console.log("[BelgianEid HWC] TokenWait ",t);break;case"Update":e&&e.updateStatus(a.rspTypeUpdate),console.log("[BelgianEid HWC] TokenWait ",t);break;case"Error":e&&e.updateStatus(a.rspTypeError),console.log("[BelgianEid HWC] Error ",t),r.unregisterResponseHandler(s),i.error({caption:t.Message,title:a.workflowTitle});break;case"Unknown":e&&e.updateStatus(a.rspTypeUnknown),console.log("[BelgianEid HWC] Unknown ",t),r.unregisterResponseHandler(s),i.error({caption:t.Message,title:a.workflowTitle});break;case"Cancel":e&&e.updateStatus(a.rspTypeCancel),console.log("[BelgianEid HWC] Cancel ",t),r.unregisterResponseHandler(s);break}}),e&&e.updateStatus(a.statusExecuting),e&&e.enableAbort(!0),await r.invoke(n.hwcRequest.HwcName,n.hwcRequest,s),await r.waitForContextCloseAsync(s),{success:l.Success}}finally{e&&e.close(),e=null}};'
        );
    end;
}

