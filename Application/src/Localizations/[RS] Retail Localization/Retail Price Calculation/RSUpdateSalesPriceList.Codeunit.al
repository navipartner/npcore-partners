codeunit 6151484 "NPR RS Update Sales Price List"
{
    Access = Internal;

    internal procedure UpdatePriceListStatus(var PriceListHeader: Record "Price List Header"): Boolean
    var
        PrevPriceListHeaders: Record "Price List Header";
    begin
        if PriceListHeader."Starting Date" = 0D then
            exit(false);

        SetPriceListHeaderStatus(PriceListHeader, PrevPriceListHeaders);

        SetPriceListLineStatus(PriceListHeader, PrevPriceListHeaders);

        exit(true);
    end;

    local procedure SetPriceListHeaderStatus(var PriceListHeader: Record "Price List Header"; var PrevPriceListHeaders: Record "Price List Header")
    var
        PrevPriceListLines: Record "Price List Line";
    begin
        PrevPriceListHeaders.SetFilter("Starting Date", '<%1', PriceListHeader."Starting Date");
        PrevPriceListHeaders.SetRange(Status, "Price Status"::Active);
        PrevPriceListHeaders.SetRange("NPR Location Code", PriceListHeader."NPR Location Code");
        PrevPriceListHeaders.SetRange("Source Type", PriceListHeader."Source Type");
#if not (BC17 or BC18 or BC19)
        PrevPriceListHeaders.SetRange("Assign-to No.", PriceListHeader."Assign-to No.");
#endif
        PrevPriceListHeaders.SetCurrentKey("Starting Date");
        if PrevPriceListHeaders.FindLast() then begin
            PrevPriceListHeaders."Ending Date" := CalcDate('<-1D>', PriceListHeader."Starting Date");
            PrevPriceListHeaders.Modify();
            PrevPriceListLines.SetRange("Price List Code", PrevPriceListHeaders.Code);
            if PrevPriceListLines.FindSet() then
                repeat
                    PrevPriceListLines."Ending Date" := CalcDate('<-1D>', PriceListHeader."Starting Date");
                    PrevPriceListLines.Modify();
                until PrevPriceListLines.Next() = 0;
        end;
        PriceListHeader.Status := "Price Status"::Active;
        PriceListHeader.Modify();
    end;

    local procedure SetPriceListLineStatus(PriceListHeader: Record "Price List Header"; var PrevPriceListHeaders: Record "Price List Header")
    var
        PriceListLine: Record "Price List Line";
    begin
        PriceListLine.SetRange("Price List Code", PriceListHeader.Code);
        if PriceListLine.FindSet() then
            repeat
                PriceListLine.Status := "Price Status"::Active;
                PriceListLine.Modify();
            until PriceListLine.Next() = 0;

        PrevPriceListHeaders.Reset();
        PriceListLine.Reset();
        PrevPriceListHeaders.SetFilter("Starting Date", '>%1', PriceListHeader."Starting Date");
        PrevPriceListHeaders.SetRange(Status, "Price Status"::Active);
        PrevPriceListHeaders.SetRange("NPR Location Code", PriceListHeader."NPR Location Code");
        PrevPriceListHeaders.SetCurrentKey("Starting Date");
        if PrevPriceListHeaders.FindFirst() then begin
            PriceListHeader."Ending Date" := CalcDate('<-1D>', PrevPriceListHeaders."Starting Date");
            PrevPriceListHeaders.Modify();
            PriceListLine.SetRange("Price List Code", PrevPriceListHeaders.Code);
            if PriceListLine.FindSet() then
                repeat
                    PriceListLine."Ending Date" := CalcDate('<-1D>', PriceListHeader."Starting Date");
                    PriceListLine.Modify();
                until PriceListLine.Next() = 0;
        end;
    end;
}