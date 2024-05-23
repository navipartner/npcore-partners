codeunit 6151518 "NPR POS Act. Insert Item Event"
{
    [IntegrationEvent(false, false)]
    internal procedure OnAddPostWorkflowsToRun(Context: Codeunit "NPR POS JSON Helper"; SaleLinePOS: Record "NPR POS Sale Line"; var PostWorkflows: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSimpleInsert(Context: Codeunit "NPR POS JSON Helper"; ItemIdentifier: Text; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin; ItemQuantity: Decimal; UnitPrice: Decimal; SkipItemAvailabilityCheck: Boolean; SerialSelectionFromList: Boolean; UsePresetUnitPrice: Boolean; Setup: Codeunit "NPR POS Setup"; FrontEnd: Codeunit "NPR POS Front End Management"; var Response: JsonObject; var Success: Boolean; var SimpleInsertCanBeExecuted: Boolean; Item: Record Item)
    begin
    end;
}