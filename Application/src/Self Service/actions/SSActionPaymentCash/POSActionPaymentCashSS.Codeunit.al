codeunit 6151333 "NPR POS Action: SS Paym. Cash" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Unattended cash payment';
        PaymentTypeCaptionLbl: Label 'Payment Type';
        PaymentTypeDescriptionLbl: Label 'Set Cash Payment Type';
    begin
        WorkflowConfig.SetWorkflowTypeUnattended();
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('PaymentType', '', PaymentTypeCaptionLbl, PaymentTypeDescriptionLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        case Step of
            'TryEndSale':
                FrontEnd.WorkflowResponse(TryEndSale(POSSession, context));
        end;
    end;

    local procedure TryEndSale(POSSession: Codeunit "NPR POS Session"; Context: codeunit "NPR POS JSON Helper"): JsonObject
    var
        POSActionSSPaymCash: Codeunit "NPR POS Action SS Paym. Cash";
        POSPaymentMethod: Record "NPR POS Payment Method";
        PaymentErr: Label 'Only cash';
    begin
        POSActionSSPaymCash.EnsureSaleIsNotEmpty(POSSession);

        POSPaymentMethod.Get(Context.GetStringParameter('PaymentType'));
        IF POSPaymentMethod."Processing Type" <> POSPaymentMethod."Processing Type"::CASH THEN
            Error(PaymentErr);
        POSActionSSPaymCash.EndSale(POSSession, POSPaymentMethod);
    END;

    local procedure GetActionScript(): Text
    begin
        exit(
       //###NPR_INJECT_FROM_FILE:POSActionPaymentCashSS.js###
       'let main=async({})=>{await workflow.respond("TryEndSale")};'
        );
    end;


    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        POSPaymentMethod: Record "NPR POS Payment Method";

    begin
        if POSParameterValue."Action Code" <> 'SS_PAYMENT_CASH' then
            exit;

        case POSParameterValue.Name of
            'PaymentType':
                begin
                    POSPaymentMethod.SetRange("Processing Type", POSPaymentMethod."Processing Type"::CASH);
                    if Page.RunModal(0, POSPaymentMethod) = Action::LookupOK then
                        POSParameterValue.Value := POSPaymentMethod.Code;
                end;
        end;
    end;
}

