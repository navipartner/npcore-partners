codeunit 6059954 "NPR POS Action: EFT Nets Baxi" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescriptionLbl: Label 'Action for integrating with EFT NETS BAXI native SDK';
        ApproveSignatureLbl: Label 'Approve signature on receipt?';
        DeclinedLbl: Label 'Declined';
        InitializingLbl: Label 'Initializing';
        PhoneApprovalInputLbl: Label 'Call acquirer to get a verification code. You can enter a blank code to skip but it will increase your cost if the payment turns out to be fraud';
        PhoneApprovalRequiredLbl: Label 'Phone authorization required. Clicking "No" will cancel the transaction. You can enter a blank code to skip but it will increase your cost if the payment turns out to be fraud';
    begin
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddJavascript(GetJavascript());
        WorkflowConfig.AddLabel('PhoneApprovalRequired', PhoneApprovalRequiredLbl);
        WorkflowConfig.AddLabel('PhoneApprovalInput', PhoneApprovalInputLbl);
        WorkflowConfig.AddLabel('statusInitializing', InitializingLbl);
        WorkflowConfig.AddLabel('declined', DeclinedLbl);
        WorkflowCOnfig.AddLabel('approveSignature', ApproveSignatureLbl);
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
            'signatureDeclined':
                FrontEnd.WorkflowResponse(EFTNETSBAXIProtocol.SignatureDeclined(Context));
        end;
    end;

    local procedure GetJavascript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionEFTNetsBaxi.Codeunit.js###
'let main=async({workflow:t,hwc:r,popup:u,context:e,captions:o})=>{debugger;if(e.request.OfflinePhoneAuth){if(!await u.confirm(o.PhoneApprovalRequired))return await t.respond("PhoneAuthCancelled"),{success:!1,tryEndSale:!1};let i=await u.stringpad(o.PhoneApprovalInput);if(i===null)return await t.respond("PhoneAuthCancelled"),{success:!1,tryEndSale:!1};e.request.TransactionParameters.PhoneAuthCode=i}let s;e.request.Unattended||(s=await u.simplePayment({showStatus:e.request.Type==="Transaction",title:e.request.TypeCaption,amount:e.request.AmountCaption,onAbort:async()=>{await r.invoke("EFTNetsBaxi",{Type:"RequestAbort",EntryNo:e.request.EntryNo},n)}}));let n,a;e.success=!1;try{n=r.registerResponseHandler(async i=>{debugger;try{switch(i.Type){case"Transaction":a=await t.respond("TransactionCompleted",i),a.confirmSignature&&(e.request.Unattended||!await u.confirm(o.approveSignature))&&(voidResponse=await t.respond("signatureDeclined"),await t.run(voidResponse.voidWorkflow,{context:{request:voidResponse.voidWorkflowRequest}})),e.success=a.BCSuccess,r.unregisterResponseHandler(n);break;case"DisplayUpdate":s&&s.updateStatus(i.DisplayUpdateResponse.Text);break;case"Open":case"Close":case"GetLastResult":case"Administration":a=await t.respond("OperationCompleted",i),a.voidTransaction&&await t.run(a.voidWorkflow,{context:{request:a.voidWorkflowRequest}}),e.success=a.BCSuccess,r.unregisterResponseHandler(n);break}}catch(d){r.unregisterResponseHandler(n,d)}}),e.request.Type==="Transaction"&&(s&&s.updateStatus(o.statusInitializing),s&&s.enableAbort(!0)),await r.invoke("EFTNetsBaxi",e.request,n),await r.waitForContextCloseAsync(n)}finally{s&&s.close()}return{success:e.success,tryEndSale:e.success}};'
        );
    end;
}
