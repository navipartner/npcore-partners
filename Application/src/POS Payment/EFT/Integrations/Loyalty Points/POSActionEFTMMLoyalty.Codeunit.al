codeunit 6184742 "NPR POS Action EFT MM Loyalty" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        InvalidEftFunctionValue: Label 'Invalid EftFunction parameter value.';

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'EFT Pay With Points - Membership Loyalty Workflow';
        FunctionNameLabel: Label 'EFT Loyalty Function';
        FunctionDescLabel: Label 'The default action is the reservation of points. The cancel action is used to cancel the reservation of points.';
        FunctionCaptionsOptionLabel: Label 'Reserve,Cancel';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter('EftFunction', 'reserve,cancel', 'reserve', FunctionNameLabel, FunctionDescLabel, FunctionCaptionsOptionLabel);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'PrepareRequest':
                FrontEnd.WorkflowResponse(PrepareRequest(Context, PaymentLine));
            'InvokePaymentService':
                FrontEnd.WorkflowResponse(MakeRequest(Context));
            'TransactionCompleted':
                Frontend.WorkflowResponse(ProcessResult(Context));
        end;
    end;

    local procedure PrepareRequest(Context: Codeunit "NPR POS JSON Helper"; PaymentLine: Codeunit "NPR POS Payment Line") Request: JsonObject
    var
        EftTransactionRequest: Record "NPR EFT Transaction Request";
        LoyaltyPointsPspClient: Codeunit "NPR MM Loy. Point PSP (Client)";
        EftLoyaltyPointsProtocol: Codeunit "NPR EFT LoyaltyPointsProtocol";
        PaymentLineRec: Record "NPR POS Sale Line";
        "Parameter EftFunction not specified.": Label 'EftFunction is not set.';
        PaymentNotVoidable: Label 'The payment line does not have a valid EFT transaction request that support cancel loyalty reservation.';
        FunctionId: Integer;
        Workflow: Text;
    begin
        if (not Context.GetIntegerParameter('EftFunction', FunctionId)) then
            Error("Parameter EftFunction not specified.");
        if (FunctionId <> 1) then
            Error(InvalidEftFunctionValue);

        PaymentLine.GetCurrentPaymentLine(PaymentLineRec);
        if (not LoyaltyPointsPspClient.CreateEftVoidRequest(PaymentLineRec, EftTransactionRequest)) then
            Error(PaymentNotVoidable);

        EftLoyaltyPointsProtocol.CreateHwcEftDeviceRequest(EftTransactionRequest, Request, Workflow);
    end;

    local procedure MakeRequest(Context: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        EftTransactionRequest: Record "NPR EFT Transaction Request";
        LoyaltyPointsMgrClient: Codeunit "NPR MM Loy. Point Mgr (Client)";
        FunctionId: Integer;
    begin

        if (not Context.GetIntegerParameter('EftFunction', FunctionId)) then
            FunctionId := 0; // PAYMENT (DEFAULT)

        if (FunctionId < 0) or (FunctionId > 1) then
            Error(InvalidEftFunctionValue);

        if (FunctionId = 1) then
            EftTransactionRequest."Processing Type" := EftTransactionRequest."Processing Type"::VOID;

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
'let main=async({workflow:a,popup:n,context:e,captions:r})=>{debugger;e?.request||(e.request=await a.respond("PrepareRequest",e));let i;e.request.Unattended||(i=await n.simplePayment({showStatus:!0,title:e.request.TypeCaption,amount:e.request.AmountCaption,onAbort:async()=>{}}));let s;try{e.soapResponse=await a.respond("InvokePaymentService",e)}finally{e.soapResponse===void 0?s.success=!1:s=await a.respond("TransactionCompleted",e),i?.close();debugger}return{success:s.success,tryEndSale:s.success}};'
        );
    end;

}
