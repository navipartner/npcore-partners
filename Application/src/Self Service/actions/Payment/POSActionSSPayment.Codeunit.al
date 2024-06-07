codeunit 6151291 "NPR POS Action: SS Payment" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        ActionDescription: Label 'Unattended payment';
        PaymentTypeName: Label 'Payment Type';
        PaymentTypeDescription: Label 'POS Payment Method to pay with';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.SetWorkflowTypeUnattended();
        WorkflowConfig.AddTextParameter('PaymentType', '', PaymentTypeName, PaymentTypeDescription);
        WorkflowConfig.SetDataSourceBinding(POSDataMgt.POSDataSource_BuiltInSaleLine());
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'preparePaymentWorkflow':
                Frontend.WorkflowResponse(PreparePayment(PaymentLine, Context));
            'tryEndSale':
                Frontend.WorkflowResponse(AttemptEndSale(Context));
        end;
    end;

    local procedure PreparePayment(PaymentLine: Codeunit "NPR POS Payment Line"; Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        Payments: Codeunit "NPR POS Action: SS Payment BL";
        PaymentMethodCode: Code[10];
        WorkflowName: Code[20];
        PosPaymentMethod: Record "NPR POS Payment Method";
        Amount: Decimal;
        POSSession: Codeunit "NPR POS Session";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        ErrBlankPayment: Label 'Cannot pay in an empty sale';
    begin
#pragma warning disable AA0139
        PaymentMethodCode := Context.GetStringParameter('PaymentType');
#pragma warning restore AA0139        

        Payments.PrepareForPayment(PaymentLine, PaymentMethodCode, WorkflowName, POSPaymentMethod, Amount);

        if Amount = 0 then begin
            POSSession.GetSaleLine(POSSaleLine);
            if POSSaleLine.IsEmpty() then begin
                Error(ErrBlankPayment);
            end;
        end;

        Response.Add('dispatchToWorkflow', WorkflowName);
        Response.Add('paymentType', POSPaymentMethod."Code");
        Response.Add('amount', Amount);
        exit(Response);
    end;

    local procedure AttemptEndSale(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        Payments: Codeunit "NPR POS Action: SS Payment BL";
        PaymentMethodCode: Code[10];
        Success: Boolean;
    begin
#pragma warning disable AA0139
        PaymentMethodCode := Context.GetStringParameter('PaymentType');
#pragma warning restore AA0139

        Success := Payments.AttemptEndCurrentSale(PaymentMethodCode);

        Response.ReadFrom('{}');
        Response.Add('success', Success);
        exit(Response);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSSPayment.js###
'let main=async({workflow:t,runtime:a})=>{a.suspendTimeout();const{dispatchToWorkflow:s,paymentType:r,amount:n}=await t.respond("preparePaymentWorkflow");if(n===0)return await t.respond("tryEndSale");const e=await t.run(s,{context:{paymentType:r,amount:n}});return e&&e.endSaleExecuted?{success:e.endSaleSuccess}:e&&e.tryEndSale?await t.respond("tryEndSale"):{success:!1}};'
        );
    end;
}

