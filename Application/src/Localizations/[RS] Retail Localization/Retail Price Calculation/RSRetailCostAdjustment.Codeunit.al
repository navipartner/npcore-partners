codeunit 6184751 "NPR RS Retail Cost Adjustment"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeRunWithCheck', '', false, false)]
    local procedure OnBeforeRunWithCheck(var IsHandled: Boolean; ItemJournalLine: Record "Item Journal Line"; CalledFromAdjustment: Boolean)
    var
        Location: Record Location;
        RetailLocalizationMgt: Codeunit "NPR Retail Localization Mgt.";
        LocationFilters: List of [Code[20]];
        LocationFilter: Code[20];
    begin
        if not RetailLocalizationMgt.IsRetailLocalizationEnabled() then
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

#if not (BC17 or BC18 or BC19 or BC20 OR BC2100 or BC2101 or BC2102 or BC2103 or BC2105)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::ItemCostManagement, OnAfterSetFilters, '', false, false)]
    local procedure ItemCostManagement_OnAfterSetFilters(var ValueEntry: Record "Value Entry"; var Item: Record Item)
    var
        RSRetValueEntryMapp: Record "NPR RS Ret. Value Entry Mapp.";
        RetailLocalizationMgt: Codeunit "NPR Retail Localization Mgt.";
    begin
        if not RetailLocalizationMgt.IsRetailLocalizationEnabled() then
            exit;

        if not RSRetValueEntryMapp.Get(ValueEntry."Entry No.") then
            exit;

        ValueEntry.SetFilter("Entry No.", '<>%1', RSRetValueEntryMapp."Entry No.");
    end;
#endif
}