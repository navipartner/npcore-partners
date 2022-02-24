codeunit 6059796 "NPR POS Action: Payment WF2" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Payment Workflow Dispatcher';
        HideAmountName: Label 'Hide Amount Dialog';
        HideAmountDesc: Label 'Always hide the amount dialog';
        HideZeroAmountName: Label 'Hide Zero Amount Dialog';
        HideZeroAmountDesc: Label 'Hide the amount dialog when amount is zero';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddBooleanParameter('HideAmountDialog', false, HideAmountName, HideAmountDesc);
        WorkflowConfig.AddBooleanParameter('HideZeroAmountDialog', false, HideZeroAmountName, HideZeroAmountDesc);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'preparePaymentWorkflow':
                Frontend.WorkflowResponse(PreparePayment(PaymentLine, Context));
            'tryEndSale':
                Frontend.WorkflowResponse(AttemptEndSale(Context));
            'doLegacyPaymentWorkflow':
                Frontend.WorkflowResponse(DoLegacyPayment(Context, FrontEnd));
        end;
    end;

    local procedure PreparePayment(PaymentLine: Codeunit "NPR POS Payment Line"; Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        Payments: Codeunit "NPR POS Action: Payment WF2 BL";
        PaymentMethodCode: Code[10];
        WorkflowName: Code[20];
        PosPaymentMethod: Record "NPR POS Payment Method";
        RemainingAmount: Decimal;
        TextAmountLabel: Label 'Enter Amount';
    begin
        PaymentMethodCode := Context.GetStringParameter('paymentNo');

        Payments.PrepareForPayment(PaymentLine, PaymentMethodCode, WorkflowName, POSPaymentMethod, RemainingAmount);

        Response.ReadFrom('{}');
        Response.Add('dispatchToWorkflow', WorkflowName);
        Response.Add('paymentType', POSPaymentMethod."Code");
        Response.Add('paymentDescription', POSPaymentMethod.Description);
        Response.Add('remainingAmount', RemainingAmount);
        Response.Add('amountPrompt', TextAmountLabel);
        exit(Response);
    end;

    local procedure AttemptEndSale(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        Payments: Codeunit "NPR POS Action: Payment WF2 BL";
        PaymentMethodCode: Code[10];
        Success: Boolean;
    begin
        PaymentMethodCode := Context.GetStringParameter('paymentNo');

        Success := Payments.AttemptEndCurrentSale(PaymentMethodCode);

        Response.ReadFrom('{}');
        Response.Add('success', Success);
        exit(Response);
    end;

    local procedure DoLegacyPayment(Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management") Response: JsonObject
    var
        POSAction: Record "NPR POS Action";
    begin
        POSAction.Get('PAYMENT');

        POSAction.SetWorkflowInvocationParameterUnsafe('paymentNo', Context.GetStringParameter('paymentNo'));
        FrontEnd.InvokeWorkflow(POSAction);

        Response.ReadFrom('{}');
        exit(Response);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionPaymentWF2.Codeunit.js###
'let main=async({workflow:e,popup:i,scope:l,parameters:o})=>{const{HideAmountDialog:p,HideZeroAmountDialog:m}=o,{dispatchToWorkflow:s,paymentType:r,remainingAmount:t,paymentDescription:u,amountPrompt:d}=await e.respond("preparePaymentWorkflow");let n=t;if(!p&&(!m||t>0)&&(n=await i.numpad({title:u,caption:d,value:t}),n===null))return;let a=await e.run(s,{context:{paymentType:r,suggestedAmount:n}});a.version==1&&await e.respond("doLegacyPaymentWorkflow"),a.version>=2&&a.endSale&&await e.respond("tryEndSale")};'
        );
    end;
}
