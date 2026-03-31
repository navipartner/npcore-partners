codeunit 6248422 "NPR POSAction TicketAdmitOnEoS" implements "NPR IPOS Workflow"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2026-03-22';
    ObsoleteReason = 'Ticket admission on end of sale now runs inline during end-of-sale processing. The post-workflow roundtrip has been removed for performance.';

    var
        _ActionDescription: Label 'Admit Ticket on End of Sale';

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    begin
        WorkflowConfig.AddActionDescription(_ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
    end;

    internal procedure AddPostEndOfSaleWorkflow(Sale: Codeunit "NPR POS Sale"; var PostWorkflows: JsonObject)
    begin
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionTicketAdmitOnEoS.Codeunit.js### 
'const main=async()=>{};'
        )
    end;

}