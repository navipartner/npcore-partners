codeunit 6184628 "NPR End Sale Events"
{
    Access = Public;
    [IntegrationEvent(false, false)]
    internal procedure OnAddPreWorkflowsToRun(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup"; var PreWorkflows: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAddPostWorkflowsToRun(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup"; EndSaleSuccess: Boolean; var PostWorkflows: JsonObject)
    begin
    end;
}