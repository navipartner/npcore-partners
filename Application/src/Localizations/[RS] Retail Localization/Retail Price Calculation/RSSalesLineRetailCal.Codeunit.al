codeunit 6184754 "NPR RS Sales Line Retail Cal."
{
    Access = Internal;

    var
        PriceListHeader: Record "Price List Header";
        PriceListLine: Record "Price List Line";

    internal procedure GetPriceFromSalesPriceList(var SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
        Location: Record Location;
    begin
        if not Location.Get(SalesLine."Location Code") then
            exit;
        if not Location."NPR Retail Location" then
            exit;

        SalesHeader.Get("Sales Document Type"::Order, SalesLine."Document No.");
        FilterPriceListHeader(SalesHeader, SalesLine);

        FilterPriceListLine(SalesLine);

        case true of
            PriceListHeader."Price Includes VAT" and SalesHeader."Prices Including VAT":
                SalesLine.Validate("Unit Price", PriceListLine."Unit Price");

            PriceListHeader."Price Includes VAT" and not SalesHeader."Prices Including VAT":
                SalesLine.Validate("Unit Price", PriceListLine."Unit Price" - (PriceListLine."Unit Price" * CalculateLineVATBreakDown(SalesLine)));

            not PriceListHeader."Price Includes VAT" and SalesHeader."Prices Including VAT":
                SalesLine.Validate("Unit Price", PriceListLine."Unit Price" + (PriceListLine."Unit Price" * CalculateLineVATBreakDown(SalesLine)));

            not PriceListHeader."Price Includes VAT" and not SalesHeader."Prices Including VAT":
                SalesLine.Validate("Unit Price", PriceListLine."Unit Price");
        end;

        if SalesLine.Quantity = 0 then
            exit;
        SalesLine.Validate("Line Amount");
    end;

    local procedure CalculateLineVATBreakDown(SalesLine: Record "Sales Line"): Decimal
    begin
        exit((100 * SalesLine."VAT %") / (100 + SalesLine."VAT %") / 100);
    end;

    local procedure FilterPriceListHeader(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    var
        EndingDateFilter: Label '>=%1|''''', Comment = '%1 = Ending Date', Locked = true;
        PriceListNotFoundErr: Label 'Price for the Location %2 has not been found.', Comment = '%1 - Location Code';
        StartingDateFilter: Label '<=%1', Comment = '%1 = Starting Date', Locked = true;
#if not (BC17 or BC18 or BC19)
        PriceListFilter: Text;
#endif
    begin
#if not (BC17 or BC18 or BC19)
        PriceListHeader.SetLoadFields("Price Type", Status, "Starting Date", "Ending Date", "NPR Location Code", "Assign-to No.");
        PriceListFilter := SalesHeader."Sell-to Customer No.";
        if (SalesHeader."Customer Disc. Group" <> '') and (PriceListFilter <> '') then
            PriceListFilter += '|' + SalesHeader."Customer Disc. Group"
        else
            PriceListFilter += SalesHeader."Customer Disc. Group";
        if (SalesHeader."Customer Price Group" <> '') and (PriceListFilter <> '') then
            PriceListFilter += '|' + SalesHeader."Customer Price Group"
        else
            PriceListFilter += SalesHeader."Customer Price Group";
        if (SalesHeader."Campaign No." <> '') and (PriceListFilter <> '') then
            PriceListFilter += '|' + SalesHeader."Campaign No."
        else
            PriceListFilter += SalesHeader."Campaign No.";

        PriceListHeader.SetFilter("Assign-to No.", PriceListFilter);
#else
        PriceListHeader.SetLoadFields("Price Type", Status, "Starting Date", "Ending Date", "NPR Location Code");
#endif
        PriceListHeader.SetRange("Price Type", "Price Type"::Sale);
        PriceListHeader.SetRange(Status, "Price Status"::Active);
        PriceListHeader.SetFilter("Starting Date", StrSubstNo(StartingDateFilter, SalesHeader."Posting Date"));
        PriceListHeader.SetFilter("Ending Date", StrSubstNo(EndingDateFilter, SalesHeader."Posting Date"));
        PriceListHeader.SetRange("NPR Location Code", SalesLine."Location Code");
#if not (BC17 or BC18 or BC19)
        if not PriceListHeader.FindFirst() then
            PriceListHeader.SetRange("Assign-to No.", '');
#endif
        if not PriceListHeader.FindFirst() then
            Error(PriceListNotFoundErr, SalesLine."Location Code");
    end;

    local procedure FilterPriceListLine(SalesLine: Record "Sales Line")
    var
        PriceNotFoundErr: Label 'Price for the Item %1 has not been found in Price List: %2 for Location %3', Comment = '%1 - Item No, %2 - Price List Code, %3 - Location Code';
    begin
        PriceListLine.SetLoadFields("Price List Code", "Asset No.", "Unit Price");
        PriceListLine.SetRange("Price List Code", PriceListHeader.Code);
        PriceListLine.SetRange("Asset No.", SalesLine."No.");
        if not PriceListLine.FindFirst() then
            Error(PriceNotFoundErr, SalesLine."No.", PriceListHeader.Code, SalesLine."Location Code");
    end;
}