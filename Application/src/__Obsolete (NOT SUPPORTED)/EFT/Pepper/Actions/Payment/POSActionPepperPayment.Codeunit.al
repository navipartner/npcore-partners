codeunit 6060014 "NPR POS Action Pepper Payment" implements "NPR IPOS Workflow"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'No longer supported';

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Pepper Payment Workflow Dispatcher';
        HideAmountName: Label 'Hide Amount Dialog';
        HideAmountDesc: Label 'Always hide the amount dialog';
        HideZeroAmountName: Label 'Hide Zero Amount Dialog';
        HideZeroAmountDesc: Label 'Hide the amount dialog when amount is zero';
        PaymentMethodCodeName: Label 'Payment Method Code';
        AdditionalParametersName: Label 'Additional Parameters';
        AdditionalParametersDesc: Label 'Additional configuration for the Pepper terminal to control payment transaction.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddBooleanParameter('HideAmountDialog', false, HideAmountName, HideAmountDesc);
        WorkflowConfig.AddBooleanParameter('HideZeroAmountDialog', false, HideZeroAmountName, HideZeroAmountDesc);
        WorkflowConfig.AddTextParameter('paymentNo', '', PaymentMethodCodeName, PaymentMethodCodeName);
        WorkflowConfig.AddTextParameter('additionalParameters', '', AdditionalParametersName, AdditionalParametersDesc);
    end;


    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'PreparePepperPayment':
                FrontEnd.WorkflowResponse(PreparePepperPayment(PaymentLine, Context));

            'CreateEftRequest':
                FrontEnd.WorkflowResponse(CreateEftRequest(Context, Sale));

            'TryEndSale':
                FrontEnd.WorkflowResponse(AttemptEndSale(Context));
        end;
    end;

    local procedure PreparePepperPayment(PaymentLine: Codeunit "NPR POS Payment Line"; Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        Payments: Codeunit "NPR POS Action: Payment WF2 BL";
        PaymentMethodCode: Code[10];
        WorkflowName: Code[20];
        PosPaymentMethod: Record "NPR POS Payment Method";
        RemainingAmount: Decimal;
        TextAmountLabel: Label 'Enter Amount';
    begin
        PaymentMethodCode := CopyStr(Context.GetStringParameter('paymentNo'), 1, MaxStrLen(PaymentMethodCode));
        Payments.PrepareForPayment(PaymentLine, PaymentMethodCode, WorkflowName, POSPaymentMethod, RemainingAmount);

        Response.ReadFrom('{}');
        Response.Add('paymentNo', POSPaymentMethod."Code");
        Response.Add('paymentDescription', POSPaymentMethod.Description);
        Response.Add('remainingAmount', RemainingAmount);
        Response.Add('amountPrompt', TextAmountLabel);
        exit(Response);
    end;

    local procedure CreateEftRequest(Context: Codeunit "NPR POS JSON Helper"; POSSale: Codeunit "NPR POS Sale") WorkflowRequest: JsonObject
    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        SalePOS: Record "NPR POS Sale";
        EFTSetup: Record "NPR EFT Setup";
        POSPaymentMethod: Record "NPR POS Payment Method";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        IntegrationRequest: JsonObject;
        Mechanism: Enum "NPR EFT Request Mechanism";
        EntryNo: Integer;
        Workflow: Text;
        AdditionalParameters: Text;
        EFTInterface: Codeunit "NPR EFT Interface";
        Pepper: Codeunit "NPR Pepper Library HWC";
        TempEFTIntegrationType: Record "NPR EFT Integration Type" temporary;
    begin
        POSSale.GetCurrentSale(SalePOS);
        POSPaymentMethod.Get(Context.GetString('paymentNo'));
        EFTSetup.FindSetup(SalePOS."Register No.", POSPaymentMethod.Code);

        EFTInterface.OnDiscoverIntegrations(TempEFTIntegrationType);
        TempEFTIntegrationType.SetRange(Code, EFTSetup."EFT Integration Type");
        TempEFTIntegrationType.FindFirst();

        EntryNo := EFTTransactionMgt.PreparePayment(EFTSetup, Context.GetDecimal('suggestedAmount'), '', SalePOS, IntegrationRequest, Mechanism, Workflow);

        AdditionalParameters := Context.GetStringParameter('additionalParameters');
        if (AdditionalParameters <> '') then
            Pepper.AppendAdditionalParameters(EntryNo, AdditionalParameters, IntegrationRequest);

        EFTTransactionRequest.Get(EntryNo);

        WorkflowRequest.Add('tryEndSale', (EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND]));
        WorkflowRequest.Add('workflowName', Workflow);
        WorkflowRequest.Add('legacy', false);
        WorkflowRequest.Add('showSpinner', true);
        WorkflowRequest.Add('showSuccessMessage', true);
        WorkflowRequest.Add('integrationRequest', IntegrationRequest);
        exit(WorkflowRequest);
    end;

    local procedure AttemptEndSale(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        Payments: Codeunit "NPR POS Action: Payment WF2 BL";
    begin
        Response.ReadFrom('{}');
#pragma warning disable AA0139
        Response.Add('success', Payments.AttemptEndCurrentSale(Context.GetString('paymentNo')));
#pragma warning restore AA0139
        exit(Response);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionPepperPayment.js###
'let main=async({workflow:e,popup:a,scope:w,parameters:o,context:A})=>{debugger;const{HideAmountDialog:u,HideZeroAmountDialog:i}=o,{paymentNo:s,remainingAmount:t,paymentDescription:r,amountPrompt:g}=await e.respond("PreparePepperPayment");debugger;let n=t;if(!u&&(!i||t>0)&&(n=await a.numpad({title:r,caption:g,value:t}),n===null))return;debugger;const c=await e.respond("CreateEftRequest",{paymentNo:s,suggestedAmount:n}),{integrationRequest:p,showSuccessMessage:m,showSpinner:d,workflowName:l}=c;debugger;const y=await e.run(l,{context:{request:p,showSpinner:d,showSuccessMessage:m}}),{success:S,tryEndSale:b}=y;debugger;S&&b&&await e.respond("TryEndSale",{paymentNo:s})};'
        );
    end;

}
