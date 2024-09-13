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

        ValueEntryNoFilter := FormatFilterDiffFromValueEntryMapping(Item, ValueEntry.GetFilter("Entry No."));

        if ValueEntryNoFilter <> '' then
            ValueEntry.SetFilter("Entry No.", StrSubstNo('%1', ValueEntryNoFilter));
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

    local procedure FormatFilterDiffFromValueEntryMapping(Item: Record Item; BaseFilter: Text) ValueEntryNoFilter: Text
    var
        RSRetValueEntryMapp: Record "NPR RS Ret. Value Entry Mapp.";
        TextBuilder: TextBuilder;
        FilterDiffFormLbl: Label '<>%1', Locked = true, Comment = '%1 = Entry No.';
        AddFilterDiffFormLbl: Label '&<>%1', Locked = true, Comment = '%1 = Entry No.';
    begin
        if BaseFilter <> '' then
            TextBuilder.Append(BaseFilter.Replace(',', '|'));

        RSRetValueEntryMapp.SetFilter("Location Code", Item.GetFilter("Location Filter"));
        RSRetValueEntryMapp.SetRange("Item No.", Item."No.");
        if RSRetValueEntryMapp.IsEmpty() then begin
            ValueEntryNoFilter := TextBuilder.ToText();
            exit;
        end;

        RSRetValueEntryMapp.SetLoadFields("Entry No.");
        if RSRetValueEntryMapp.FindSet() then
            repeat
                if TextBuilder.Length = 0 then
                    TextBuilder.Append(StrSubstNo(FilterDiffFormLbl, RSRetValueEntryMapp."Entry No."))
                else
                    TextBuilder.Append(StrSubstNo(AddFilterDiffFormLbl, RSRetValueEntryMapp."Entry No."))
            until RSRetValueEntryMapp.Next() = 0;

        ValueEntryNoFilter := TextBuilder.ToText();
    end;

#endif
    #endregion RS Retail Cost Adjustment Helper Procedures
}