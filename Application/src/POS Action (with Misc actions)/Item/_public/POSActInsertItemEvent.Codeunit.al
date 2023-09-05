codeunit 6151518 "NPR POS Act. Insert Item Event"
{
    [IntegrationEvent(false, false)]
    internal procedure OnAddPostWorkflowsToRun(Context: Codeunit "NPR POS JSON Helper"; SaleLinePOS: Record "NPR POS Sale Line"; var PostWorkflows: JsonObject)
    begin
    end;
}