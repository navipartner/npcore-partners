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
}