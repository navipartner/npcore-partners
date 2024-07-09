codeunit 6059935 "NPR POSAction VoucherPayment" implements "NPR POS IPaymentWFHandler", "NPR IPOS Workflow"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Use action NPR POS Action Scan Voucher2';

    Access = Internal;
    procedure GetPaymentHandler(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::VOUCHER_PAYMENT));
    end;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Voucher Payment Workflow';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionVoucherPayment.Codeunit.js###
'let main=async()=>({legacy:!0});'
        );
    end;

}
