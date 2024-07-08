codeunit 6059886 "NPR POS Action: EFT Flexiiterm" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescriptionLbl: Label 'Action for integrating with EFT Flexiiterm';
    begin
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddJavascript(GetJavascript());
        WorkflowConfig.AddLabel('recheckReceipt', 'Terminal transaction has completed but no terminal receipt was received. Attempt re-transfer of terminal receipt?');
        WorkflowConfig.AddLabel('PhoneApprovalRequired', 'Phone authorization required. Clicking "No" will cancel the transaction. You can enter a blank code to skip but it will increase your cost if the payment turns out to be fraud');
        WorkflowConfig.AddLabel('PhoneApprovalInput', 'Call acquirer to get a verification code. You can enter a blank code to skip but it will increase your cost if the payment turns out to be fraud');
        WorkflowConfig.AddLabel('statusInitializing', 'Initializing');
        WorkflowConfig.AddLabel('title', 'Transaction');
        WorkflowConfig.AddLabel('declined', 'Transaction Declined');
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        FlexiitermProtocol: Codeunit "NPR EFT Flexiiterm Prot.";
    begin
        case Step of
            'CardData':
                FrontEnd.WorkflowResponse(FlexiitermProtocol.HandleCardDataResponse(Context, Sale));
            'ReceiptCheck':
                FrontEnd.WorkflowResponse(FlexiitermProtocol.HandleReceiptCheckResponse(Context));
            'ReceiptData':
                FrontEnd.WorkflowResponse(FlexiitermProtocol.HandleReceiptDataResponse(Context));
            'TransactionResult':
                FrontEnd.WorkflowResponse(FlexiitermProtocol.HandleTransactionResultResponse(Context));
            'TransactionCompleted':
                FrontEnd.WorkflowResponse(FlexiitermProtocol.HandleTransactionCompletedResponse(Context));
        end;
    end;

    local procedure GetJavascript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionEFTFlexiiterm.Codeunit.js###
'let main=async({workflow:l,hwc:e,popup:s,context:a,captions:n})=>{debugger;let u=await s.simplePayment({showStatus:!0,title:n.title,amount:a.request.FormattedAmount,onAbort:async()=>{await e.invoke("EFTNetsFlexiiterm",{Type:"RequestAbort",EntryNo:a.request.EntryNo},t)}}),t,r;a.success=!1;try{t=e.registerResponseHandler(async i=>{debugger;try{switch(i.Type){case"CardData":r=await l.respond("CardData",i),await e.invoke("EFTNetsFlexiiterm",r,t);break;case"ReceiptCheck":r=await l.respond("ReceiptCheck",i),await e.invoke("EFTNetsFlexiiterm",r,t);break;case"ReceiptData":r=await l.respond("ReceiptData",i),await e.invoke("EFTNetsFlexiiterm",r,t);break;case"TransactionResult":r=await l.respond("TransactionResult",i),await e.invoke("EFTNetsFlexiiterm",r,t);break;case"TransactionCompleted":let o=await l.respond("TransactionCompleted",i);a.success=o.BCSuccess,e.unregisterResponseHandler(t);break;case"RequestMissingReceiptRecheck":let m=await s.confirm(n.recheckReceipt);await e.invoke("EFTNetsFlexiiterm",{EntryNo:a.request.EntryNo,Type:"RecheckReceiptConfirmResult",RecheckMissingReceipt:m},t);break;case"DisplayUpdate":let y="";i.UIStatus&&(y+=i.UIStatus+" "),u.updateStatus(y);break;case"RequestGenericConfirm":let d=await s.confirm(i.GenericConfirm);await e.invoke("EFTNetsFlexiiterm",{EntryNo:a.request.EntryNo,Type:"GenericConfirmResult",GenericConfirmResult:d},t);break;case"RequestGenericMessage":await s.message(i.GenericMessage);break;case"RequestPhoneApproval":if(!await s.confirm(n.PhoneApprovalRequired)){await e.invoke("EFTNetsFlexiiterm",{EntryNo:a.request.EntryNo,Type:"PhoneApprovalResult",PhoneAuthResult:"Cancel"},t);return}let c=await s.stringpad(n.PhoneApprovalInput);if(c===null){await e.invoke("EFTNetsFlexiiterm",{EntryNo:a.request.EntryNo,Type:"PhoneApprovalResult",PhoneAuthResult:"Cancel"},t);return}if(c===""){await e.invoke("EFTNetsFlexiiterm",{EntryNo:a.request.EntryNo,Type:"PhoneApprovalResult",PhoneAuthResult:"Skip"},t);return}await e.invoke("EFTNetsFlexiiterm",{EntryNo:a.request.EntryNo,Type:"PhoneApprovalResult",PhoneAuthResult:"Input",PhoneApprovalCode:c},t);break}}catch(o){e.unregisterResponseHandler(t,o)}}),u.updateStatus(n.statusInitializing),u.enableAbort(!0),await e.invoke("EFTNetsFlexiiterm",a.request,t),await e.waitForContextCloseAsync(t),a.success||s.error({title:n.title,caption:"<center><font color=red size=72>&#x274C;</font><h3>"+n.declined+"</h3></center>"})}finally{u&&u.close()}return{success:a.success,tryEndSale:a.success}};'
        );
    end;
}
