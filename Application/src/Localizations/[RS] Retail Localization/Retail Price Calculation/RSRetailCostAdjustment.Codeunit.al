codeunit 6184751 "NPR RS Retail Cost Adjustment"
{
    Access = Internal;

    #region Cost Adjustment Subscribers
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeRunWithCheck', '', false, false)]
    local procedure OnBeforeRunWithCheck(var IsHandled: Boolean; ItemJournalLine: Record "Item Journal Line"; CalledFromAdjustment: Boolean)
    var
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        if not CalledFromAdjustment then
            exit;

        if RSRLocalizationMgt.IsRetailLocation(ItemJournalLine."Location Code") then begin
            IsHandled := true;
            exit;
        end;

        if ItemJournalLine."Entry Type" = "Item Ledger Entry Type"::Transfer then
            if RSRLocalizationMgt.IsRetailLocation(ItemJournalLine."New Location Code") then
                IsHandled := true;
    end;

#if not (BC17 or BC18 or BC19 or BC20 or BC2100 or BC2101 or BC2102 or BC2103 or BC2105)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::ItemCostManagement, 'OnAfterSetFilters', '', false, false)]
    local procedure ItemCostManagement_OnAfterSetFilters(var ValueEntry: Record "Value Entry"; var Item: Record Item)
    var
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        RSRLocalizationMgt.SetSynthesisedEntryTypeFilter(ValueEntry, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Batch", 'OnPostLinesOnAfterPostLine', '', false, false)]
    local procedure OnPostLinesOnAfterPostLine(var ItemJournalLine: Record "Item Journal Line")
    var
        ValueEntry: Record "Value Entry";
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        if not RSRLocalizationMgt.IsRetailLocation(ItemJournalLine."Location Code") then
            exit;

        ValueEntry.SetRange("Document No.", ItemJournalLine."Document No.");
        RSRLocalizationMgt.SetSynthesisedEntryTypeFilter(ValueEntry, false);
        if not ValueEntry.FindLast() then
            exit;

        RSRLocalizationMgt.InsertCOGSCorrectionValueEntryMappingEntry(ValueEntry);
    end;
#endif
    #endregion Cost Adjustment Subscribers
}
