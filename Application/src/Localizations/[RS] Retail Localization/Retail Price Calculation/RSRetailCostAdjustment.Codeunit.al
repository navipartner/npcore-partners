codeunit 6184751 "NPR RS Retail Cost Adjustment"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeRunWithCheck', '', false, false)]
    local procedure OnBeforeRunWithCheck(var IsHandled: Boolean; ItemJournalLine: Record "Item Journal Line"; CalledFromAdjustment: Boolean)
    var
        Location: Record Location;
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        LocationFilters: List of [Code[20]];
        LocationFilter: Code[20];
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
    [EventSubscriber(ObjectType::Codeunit, Codeunit::ItemCostManagement, OnAfterSetFilters, '', false, false)]
    local procedure ItemCostManagement_OnAfterSetFilters(var ValueEntry: Record "Value Entry"; var Item: Record Item)
    var
        RSRetValueEntryMapp: Record "NPR RS Ret. Value Entry Mapp.";
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        ValueEntryFilter: Text;
        TextBuilder: TextBuilder;
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        if not RSRetValueEntryMapp.FindSet() then
            exit;

        SetInitalFilterToTBuilder(TextBuilder, ValueEntry);

        repeat
            AppendEntryNoFilterToTBuilder(TextBuilder, RSRetValueEntryMapp."Entry No.");
        until RSRetValueEntryMapp.Next() = 0;

        FormatRetailValueEntryFilter(ValueEntryFilter, TextBuilder);

        ValueEntry.SetFilter("Entry No.", StrSubstNo('<>%1', ValueEntryFilter));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Batch", 'OnPostLinesOnAfterPostLine', '', false, false)]
    local procedure OnPostLinesOnAfterPostLine(var ItemJournalLine: Record "Item Journal Line")
    var
        ValueEntry: Record "Value Entry";
        Location: Record Location;
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

    #region RS Retail Cost Adjustment Helper Procedures

    local procedure SetInitalFilterToTBuilder(var TextBuilder: TextBuilder; ValueEntry: Record "Value Entry")
    var
        ValueEntryFilter: Text;
    begin
        ValueEntryFilter := ValueEntry.GetFilter("Entry No.");
        ValueEntryFilter := ValueEntryFilter.Replace(',', '|');
        if ValueEntryFilter <> '' then
            TextBuilder.Append(ValueEntryFilter);
    end;

    local procedure AppendEntryNoFilterToTBuilder(var TextBuilder: TextBuilder; EntryNo: Integer)
    begin
        case (TextBuilder.Length <> 0) of
            true:
                TextBuilder.Append('|' + Format(EntryNo));
            false:
                TextBuilder.Append(Format(EntryNo));
        end;
    end;

    local procedure FormatRetailValueEntryFilter(var ValueEntryFilter: Text; TextBuilder: TextBuilder)
    begin
        ValueEntryFilter := TextBuilder.ToText();
        if ValueEntryFilter.EndsWith('|') then
            ValueEntryFilter := ValueEntryFilter.Remove(StrLen(ValueEntryFilter) - 1, 1);
    end;
    #endregion RS Retail Cost Adjustment Helper Procedures
#endif
}