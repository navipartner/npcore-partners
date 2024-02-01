codeunit 6184742 "NPR POS Action EFT MM Loyalty" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'EFT Pay With Points - Membership Loyalty Workflow';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'InvokePaymentService':
                FrontEnd.WorkflowResponse(MakeRequest(Context));
            'TransactionCompleted':
                Frontend.WorkflowResponse(ProcessResult(Context));
        end;
    end;

    local procedure MakeRequest(Context: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        EftTransactionRequest: Record "NPR EFT Transaction Request";
        LoyaltyPointsMgrClient: Codeunit "NPR MM Loy. Point Mgr (Client)";
    begin
        Context.SetScope('request');
        EftTransactionRequest.Get(Context.GetInteger('EntryNo'));
        LoyaltyPointsMgrClient.MakeServiceRequest(EftTransactionRequest);
    end;

    local procedure ProcessResult(Context: Codeunit "NPR POS JSON Helper") Result: JsonObject
    var
        EftTransactionRequest: Record "NPR EFT Transaction Request";
        EftLoyaltyPointsProtocol: Codeunit "NPR EFT LoyaltyPointsProtocol";
        SoapResponse: JsonObject;
        HwcRequest: JsonObject;
        EftInterface: Codeunit "NPR EFT Interface";
    begin
        SoapResponse := Context.GetJsonObject('soapResponse');
        HwcRequest := Context.GetJsonObject('request');
        Context.SetScope('request');

        EftTransactionRequest.Get(Context.GetInteger('EntryNo'));
        EftLoyaltyPointsProtocol.HandleDeviceResponse(EftTransactionRequest, SoapResponse, Result);
        EftTransactionRequest.Find('=');

        EftInterface.EftIntegrationResponse(EftTransactionRequest);
    end;


    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionEftMMLoyalty.js###
'let main=async({workflow:n,popup:t,context:e,captions:i})=>{debugger;let a;e.request.Unattended||(a=await t.simplePayment({showStatus:!0,title:e.request.TypeCaption,amount:e.request.AmountCaption,onAbort:async()=>{}}));let s;try{e.soapResponse=await n.respond("InvokePaymentService",e)}finally{e.soapResponse===void 0?s.success=!1:s=await n.respond("TransactionCompleted",e),a&&a.close();debugger}return{success:s.success,tryEndSale:s.success}};'
        );
    end;

}
