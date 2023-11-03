codeunit 6151367 "NPR POS Action Doc Exp Events"
{
    [IntegrationEvent(false, false)]
    internal procedure OnAddPreWorkflowsToRun(Context: Codeunit "NPR POS JSON Helper"; SalePOS: Record "NPR POS Sale"; var PreWorkflows: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAddExternalDocNoLabel(var ExternalDocumentNoText: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAddAttentionLabel(var AttentionText: Text)
    begin
    end;
}