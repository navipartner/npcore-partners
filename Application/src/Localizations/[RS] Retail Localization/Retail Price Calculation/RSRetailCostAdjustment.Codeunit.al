codeunit 6184751 "NPR RS Retail Cost Adjustment"
{
    Access = Internal;

    #region Cost Adjustment Subscribers
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeRunWithCheck', '', false, false)]
    local procedure OnBeforeRunWithCheck(var IsHandled: Boolean; ItemJournalLine: Record "Item Journal Line"; CalledFromAdjustment: Boolean)
    var
        Location: Record Location;
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        LocationFilter: Code[20];
        LocationFilters: List of [Code[20]];
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        if not CalledFromAdjustment then
            exit;

        if ItemJournalLine."Entry Type" in ["Item Ledger Entry Type"::Transfer] then begin
            IsHandled := true;
            exit;
        end;

        Location.SetRange("NPR Retail Location", true);
        if not Location.FindSet() then
            exit;
        repeat
            LocationFilters.Add(Location.Code);
        until Location.Next() = 0;

        foreach LocationFilter in LocationFilters do
            if ItemJournalLine."Location Code" = LocationFilter then
                IsHandled := true;
    end;

#if not (BC17 or BC18 or BC19 or BC20 or BC2100 or BC2101 or BC2102 or BC2103 or BC2105)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::ItemCostManagement, 'OnAfterSetFilters', '', false, false)]
    local procedure ItemCostManagement_OnAfterSetFilters(var ValueEntry: Record "Value Entry"; var Item: Record Item)
    var
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        ValueEntryNoFilter: Text;
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        ValueEntryNoFilter := GetFilterFromValueEntryMapping(ValueEntry.GetFilter("Entry No."), false);

        if ValueEntryNoFilter <> '' then
            ValueEntry.SetFilter("Entry No.", StrSubstNo('<>%1', ValueEntryNoFilter));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Batch", 'OnPostLinesOnAfterPostLine', '', false, false)]
    local procedure OnPostLinesOnAfterPostLine(var ItemJournalLine: Record "Item Journal Line")
    var
        Location: Record Location;
        ValueEntry: Record "Value Entry";
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        Location.Get(ItemJournalLine."Location Code");
        if not (Location."NPR Retail Location") then
            exit;

        ValueEntry.SetRange("Document No.", ItemJournalLine."Document No.");
        if not ValueEntry.FindLast() then
            exit;

        RSRLocalizationMgt.InsertCOGSCorrectionValueEntryMappingEntry(ValueEntry);
    end;
#endif
    #endregion Cost Adjustment Subscribers

    #region RS Retail Cost Adjustment Helper Procedures

#if not (BC17 or BC18 or BC19 or BC20 or BC2100 or BC2101 or BC2102 or BC2103 or BC2105)

    internal procedure GetFilterFromValueEntryMapping(BaseValueEntryFilter: Text; IsCOGS: Boolean) ValueEntryFilter: Text
    var
        RSRetValueEntryMapp: Record "NPR RS Ret. Value Entry Mapp.";
        TextBuilder: TextBuilder;
    begin
        if BaseValueEntryFilter.Contains('|') then
            ValueEntryFilter := BaseValueEntryFilter.Replace(',', '|');

        if ValueEntryFilter <> '' then
            TextBuilder.Append(ValueEntryFilter);

        if IsCOGS then
            RSRetValueEntryMapp.SetRange("COGS Correction", true);

        if RSRetValueEntryMapp.IsEmpty() then begin
            ValueEntryFilter := TextBuilder.ToText();
            RemoveTrailingFilterFromVEFilter(ValueEntryFilter);
            exit;
        end;

        RSRetValueEntryMapp.SetLoadFields("Entry No.");
        if RSRetValueEntryMapp.FindSet() then
            repeat
                AppendEntryNoFilterToVEFilter(TextBuilder, RSRetValueEntryMapp."Entry No.", not IsCOGS);
            until RSRetValueEntryMapp.Next() = 0;

        ValueEntryFilter := TextBuilder.ToText();
        RemoveTrailingFilterFromVEFilter(ValueEntryFilter);
    end;

    local procedure AppendEntryNoFilterToVEFilter(var TextBuilder: TextBuilder; EntryNo: Integer; Diff: Boolean)
    begin
        case (TextBuilder.Length > 0) of
            true:
                if Diff then
                    TextBuilder.Append('&<>' + Format(EntryNo))
                else
                    TextBuilder.Append('|' + Format(EntryNo));
            false:
                TextBuilder.Append(Format(EntryNo));
        end;
    end;

    local procedure RemoveTrailingFilterFromVEFilter(var ValueEntryFilter: Text)
    begin
        if ValueEntryFilter.EndsWith('&<>') then
            ValueEntryFilter := ValueEntryFilter.Remove(StrLen(ValueEntryFilter) - 1, 1);
    end;
#endif
    #endregion RS Retail Cost Adjustment Helper Procedures
}