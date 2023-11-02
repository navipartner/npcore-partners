codeunit 6059954 "NPR POS Action: EFT Nets Baxi" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescriptionLbl: Label 'Action for integrating with EFT NETS BAXI native SDK';
    begin
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddJavascript(GetJavascript());
        WorkflowConfig.AddLabel('PhoneApprovalRequired', 'Phone authorization required. Clicking "No" will cancel the transaction. You can enter a blank code to skip but it will increase your cost if the payment turns out to be fraud');
        WorkflowConfig.AddLabel('PhoneApprovalInput', 'Call acquirer to get a verification code. You can enter a blank code to skip but it will increase your cost if the payment turns out to be fraud');
        WorkflowConfig.AddLabel('statusInitializing', 'Initializing');
        WorkflowConfig.AddLabel('declined', 'Declined');
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        EFTNETSBAXIProtocol: Codeunit "NPR EFT NETS BAXI Protocol";
    begin
        case Step of
            'TransactionCompleted',
            'OperationCompleted':
                FrontEnd.WorkflowResponse(EFTNETSBAXIProtocol.ProcessResponse(Context));
            'PhoneAuthCancelled':
                EFTNETSBAXIProtocol.PhoneAuthCancelled(Context);
        end;
    end;

    local procedure GetJavascript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionEFTNetsBaxi.Codeunit.js###
'let main=async({workflow:i,hwc:t,popup:u,context:e,captions:l})=>{debugger;if(e.request.OfflinePhoneAuth){if(!await u.confirm(l.PhoneApprovalRequired))return await i.respond("PhoneAuthCancelled"),{success:!1,tryEndSale:!1};let n=await u.stringpad(l.PhoneApprovalInput);if(n===null)return await i.respond("PhoneAuthCancelled"),{success:!1,tryEndSale:!1};e.request.TransactionParameters.PhoneAuthCode=n}let a;e.request.Unattended||(a=await u.simplePayment({showStatus:e.request.Type==="Transaction",title:e.request.TypeCaption,amount:e.request.AmountCaption,onAbort:async()=>{await t.invoke("EFTNetsBaxi",{Type:"RequestAbort",EntryNo:e.request.EntryNo},r)}}));let r,s;e.success=!1;try{r=t.registerResponseHandler(async n=>{debugger;try{switch(n.Type){case"Transaction":s=await i.respond("TransactionCompleted",n),s.voidTransaction&&await i.run(s.voidWorkflow,{context:{request:s.voidWorkflowRequest}}),e.success=s.BCSuccess,t.unregisterResponseHandler(r);break;case"DisplayUpdate":a&&a.updateStatus(n.DisplayUpdateResponse.Text);break;case"Open":case"Close":case"GetLastResult":case"Administration":s=await i.respond("OperationCompleted",n),s.voidTransaction&&await i.run(s.voidWorkflow,{context:{request:s.voidWorkflowRequest}}),e.success=s.BCSuccess,t.unregisterResponseHandler(r);break}}catch(o){t.unregisterResponseHandler(r,o)}}),e.request.Type==="Transaction"&&(a&&a.updateStatus(l.statusInitializing),a&&a.enableAbort(!0)),await t.invoke("EFTNetsBaxi",e.request,r),await t.waitForContextCloseAsync(r)}finally{a&&a.close()}return{success:e.success,tryEndSale:e.success}};'
        );
    end;
}
