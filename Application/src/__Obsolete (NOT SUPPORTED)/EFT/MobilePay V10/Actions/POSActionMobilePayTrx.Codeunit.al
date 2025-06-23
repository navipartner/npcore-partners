codeunit 6059881 "NPR POS Action - MobilePay Trx" implements "NPR IPOS Workflow"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'No longer supported';

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'MobilePay V10 EFT Transaction';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'poll':
                PollResponse(Context);
            'startTransaction':
                StartTransaction(Context);
            'requestAbort':
                RequestAbort(Context);
        end;
    end;

    local procedure PollResponse(Context: Codeunit "NPR POS JSON Helper")
    var
        eftTrxRequest: Record "NPR EFT Transaction Request";
        eftSetup: Record "NPR EFT Setup";
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
        mobilePayResultCode: Enum "NPR MobilePayV10 Result Code";
        captured: Boolean;
        captureAttempts: Integer;
        mobilePayIntegration: Codeunit "NPR MobilePayV10 Integration";
    begin
        eftTrxRequest.Get(Context.GetInteger('EntryNo'));
        eftSetup.FindSetup(eftTrxRequest."Register No.", eftTrxRequest."Original POS Payment Type Code");

        mobilePayProtocol.PollTrxStatus(eftTrxRequest, eftSetup);

        Commit();

        if eftTrxRequest."Result Code" = mobilePayResultCode::Reserved.AsInteger() then begin
            //Trx needs to be captured.
            while (not captured) and (captureAttempts < 3) do begin
                captured := mobilePayProtocol.CaptureTrx(eftTrxRequest, eftSetup);
                Commit();
                captureAttempts += 1;
            end;
        end;

        if eftTrxRequest."Result Code" in
            [mobilePayResultCode::Captured.AsInteger(),
            mobilePayResultCode::CancelledByUser.AsInteger(),
             mobilePayResultCode::CancelledByClient.AsInteger(),
             mobilePayResultCode::CancelledByMobilePay.AsInteger(),
             mobilePayResultCode::ExpiredAndCancelled.AsInteger(),
             mobilePayResultCode::RejectedByMobilePayDueToAgeRestrictions.AsInteger()] then begin
            //Trx is done
            Context.SetContext('done', true);
            Context.SetContext('success', eftTrxRequest."Result Code" = mobilePayResultCode::Captured.AsInteger());
            mobilePayIntegration.HandleProtocolResponse(eftTrxRequest);
        end;

        Context.SetContext('lastStatusDescription', Format("NPR MobilePayV10 Result Code".FromInteger(eftTrxRequest."Result Code")));
        Context.SetContext('lastStatusCode', eftTrxRequest."Result Code");
    end;

    local procedure StartTransaction(Context: Codeunit "NPR POS JSON Helper")
    var
        MobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
        EftTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EftTransactionRequest.Get(Context.GetInteger('EntryNo'));
        MobilePayProtocol.SendTrxRequest(EftTransactionRequest);
    end;

    local procedure RequestAbort(Context: Codeunit "NPR POS JSON Helper")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
        eftSetup: Record "NPR EFT Setup";
    begin
        if Context.GetBoolean('abortRequested') then
            exit;

        EFTTransactionRequest.Get(Context.GetInteger('EntryNo'));
        eftSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        mobilePayProtocol.RequestAbort(EFTTransactionRequest, eftSetup);

        Context.SetContext('abortRequested', true);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionMobilePayTrx.js###
'let main=async({workflow:s,context:e,popup:r})=>{e.EntryNo=e.request.EntryNo,e.done=!1,e.abortRequested=!1,e.success=!1,e.lastStatusCode=0,e.lastStatusDescription="";let t=await r.mobilePay({title:e.request.transactionCaption,initialStatus:e.lastStatusDescription,showStatus:!0,amount:e.request.formattedAmount,qr:{value:e.request.qr},onAbort:async()=>{await s.respond("requestAbort")}});t.enableAbort(!0);let u=new Promise((i,l)=>{let a=async()=>{try{if(await s.respond("poll"),e.done){i();return}t.updateStatus(e.lastStatusDescription)}catch(n){try{await s.respond("requestAbort")}catch{}l(n);return}setTimeout(a,1e3)};setTimeout(a,1e3)});try{await s.respond("startTransaction"),e.request.QrOnCustomerDisplay&&await s.run("HTML_DISPLAY_QR",{context:{IsNestedWorkflow:!0,QrShow:!0,QrTitle:"MobilePay",QrMessage:e.request.formattedAmount,QrContent:e.request.qr}}),await u}finally{t&&t.close(),e.request.QrOnCustomerDisplay&&await s.run("HTML_DISPLAY_QR",{context:{IsNestedWorkflow:!0,QrShow:!1,QrTitle:"MobilePay"}})}return{success:e.success,tryEndSale:e.success}};'
        );
    end;

}
