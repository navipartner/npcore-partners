codeunit 6151518 "NPR POS Act. Insert Item Event"
{
    [IntegrationEvent(false, false)]
    internal procedure OnAddPostWorkflowsToRun(Context: Codeunit "NPR POS JSON Helper"; SaleLinePOS: Record "NPR POS Sale Line"; var PostWorkflows: JsonObject)
    begin
        // Internally you should not subscribe to this event. It will affect performance of fast insert Item with barcode scan.
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSimpleInsert(Context: Codeunit "NPR POS JSON Helper"; ItemIdentifier: Text; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin; ItemQuantity: Decimal; UnitPrice: Decimal; SkipItemAvailabilityCheck: Boolean; SerialSelectionFromList: Boolean; UsePresetUnitPrice: Boolean; Setup: Codeunit "NPR POS Setup"; FrontEnd: Codeunit "NPR POS Front End Management"; var Response: JsonObject; var Success: Boolean; var SimpleInsertCanBeExecuted: Boolean; Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterCheckPostworkflowSubscriptionExists(Item: Record Item; var PostworkflowSubscriptionExists: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetNextCaptionUpdateTime(Item: Record Item; ItemReference: Record "Item Reference"; var NextUpdateTime: DateTime)
    begin
    end;
}