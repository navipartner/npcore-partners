codeunit 6151042 "NPR Payment Processing Events"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure OnAddPreWorkflowsToRun(Context: Codeunit "NPR POS JSON Helper"; SalePOS: Record "NPR POS Sale"; var PreWorkflows: JsonObject)
    begin
    end;
}