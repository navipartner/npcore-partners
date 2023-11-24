codeunit 6184637 "NPR POS Action EFT Adyen Local" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Adyen Local EFT Transaction';
        InitialStatusLbl: Label 'Initializing';
        ActiveStatusLbl: Label 'Waiting For Response';
        ApproveSignatureLbl: Label 'Approve signature on receipt?';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('initialStatus', InitialStatusLbl);
        WorkflowConfig.AddLabel('activeStatus', ActiveStatusLbl);
        WorkflowCOnfig.AddLabel('approveSignature', ApproveSignatureLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
    end;


    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionEFTAdyenLocal.js###
'let main=async({workflow:a,context:e,popup:u,captions:o})=>{e.EntryNo=e.request.EntryNo;let r=await u.simplePayment({title:e.request.TypeCaption,initialStatus:o.initialStatus,showStatus:!0,amount:e.request.formattedAmount,onAbort:async()=>{await a.respond("requestAbort")}}),y=new Promise((s,c)=>{let l=async()=>{try{let t=await a.respond("poll");if(t.newEntryNo){e.EntryNo=t.newEntryNo;return}if(t.signatureRequired){let i=!1;if(t.signatureType==="Receipt"&&(i=confirm("Approve receipt?")),t.signatureType==="Bitmap"){let n=JSON.parse(t.signatureBitmap),p=u.signatureValidation();p.updateSignature(n.SignaturePoint),i=await p.completeAsync()}if(!i){let n=await a.respond("signatureDecline");e.EntryNo=n.newEntryNo;return}}if(t.done){debugger;e.success=t.success,s();return}}catch(t){try{await a.respond("requestAbort")}catch{}c(t);return}setTimeout(l,1e3)};setTimeout(l,1e3)});try{let s=await a.respond("startTransaction");s.newEntryNo&&(e.EntryNo=s.newEntryNo),r.updateStatus(o.activeStatus),r.enableAbort(!0),await y}finally{r&&r.close()}return{success:e.success,tryEndSale:e.success}};'
        );
    end;
}
