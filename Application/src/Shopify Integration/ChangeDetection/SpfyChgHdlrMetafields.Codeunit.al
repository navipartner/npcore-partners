codeunit 6151228 "NPR Spfy Chg Hdlr Metafields" implements "NPR Spfy Change Handler"
{
    Access = Internal;

    var
        SpfyChangeTrackerMgt: Codeunit "NPR Spfy Change Tracker Mgt.";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";

    procedure ProcessChange(var DetectedChange: Codeunit "NPR Spfy Detected Change"): Boolean
    var
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
    begin
        if DetectedChange.ChangeType() = "NPR Spfy Change Type"::Delete then
            exit(false);
        if not SpfyEntityMetafield.GetBySystemId(DetectedChange.SystemId()) then
            exit(false);

        if not SpfyChangeTrackerMgt.MetafieldOwnerOnRowVersionPoll(SpfyEntityMetafield."Table No.") then
            exit(false);
        exit(ProcessMetafield(SpfyEntityMetafield));
    end;

    local procedure ProcessMetafield(var SpfyEntityMetafield: Record "NPR Spfy Entity Metafield") TaskCreated: Boolean
    var
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        Baseline: JsonObject;
        CurrentMetafieldHash: Text;
        ProcessedEligibly: Boolean;
    begin
        CurrentMetafieldHash := SpfySyncStateMgt.EntityMetafieldPayloadHash(SpfyEntityMetafield);
        SpfySyncStateMgt.GetBaseline(Database::"NPR Spfy Entity Metafield", SpfyEntityMetafield.SystemId, '', Baseline);
        if SpfySyncStateMgt.Facet(Baseline, SpfySyncStateMgt.GetEntityMetafieldHashKey()) = CurrentMetafieldHash then
            exit;

        // Advance the baseline on ProcessedEligibly, NOT on TaskCreated: an ineligible owner must not advance (silent miss), a deduped-but-eligible one must.
        TaskCreated := SpfyMetafieldMgt.ProcessMetafield(SpfyEntityMetafield, ProcessedEligibly);
        if ProcessedEligibly then begin
            SpfySyncStateMgt.SetFacet(Baseline, SpfySyncStateMgt.GetEntityMetafieldHashKey(), CurrentMetafieldHash);
            SpfySyncStateMgt.SaveBaseline(Database::"NPR Spfy Entity Metafield", SpfyEntityMetafield.SystemId, '', Baseline);
        end;
    end;
}
