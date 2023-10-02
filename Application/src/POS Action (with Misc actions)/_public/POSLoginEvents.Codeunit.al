codeunit 6151544 "NPR POS Login Events"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure OnAddPreWorkflowsToRun(Context: Codeunit "NPR POS JSON Helper"; SalePOS: Record "NPR POS Sale"; var PreWorkflows: JsonObject)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnAfterLogin(var POSSession: Codeunit "NPR POS Session")
    begin
    end;
}