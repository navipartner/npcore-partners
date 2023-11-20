codeunit 6151429 "NPR RS Change Price Nivelation"
{
    Access = Internal;
#if not (BC17 or BC18 or BC19)
    internal procedure CreateAndPostPriceChangeNivelationDocument(SalesPriceListHeader: Record "Price List Header")
    var
        NewNivelationHeader: Record "NPR RS Nivelation Header";
        NewNivelationLines: Record "NPR RS Nivelation Lines";
        PreviousPriceListHeader: Record "Price List Header";
        NivelationPost: Codeunit "NPR RS Nivelation Post";
        LineNo: Integer;
        UnsuccessfulNivelationPostingMsg: Label 'Nivelation Document isn''t posted successfully. There was no Price Change or there are no Items in Inventory.';
        PreviousPriceListNotFoundErr: Label 'Nivelation Document isn''t posted successfully. Previous price list has not been found.';
    begin
        PreviousPriceListHeader.SetRange(Status, "Price Status"::Active);
        PreviousPriceListHeader.SetRange("Ending Date", CalcDate('<-1D>', SalesPriceListHeader."Starting Date"));
        PreviousPriceListHeader.SetRange("NPR Location Code", SalesPriceListHeader."NPR Location Code");
        if not PreviousPriceListHeader.FindFirst() then
            Error(PreviousPriceListNotFoundErr);
        if not (CheckForUnitPriceDifference(SalesPriceListHeader, PreviousPriceListHeader)) then
            Error(UnsuccessfulNivelationPostingMsg);
        NewNivelationHeader.Init();
        NewNivelationHeader.Type := "NPR RS Nivelation Type"::"Price Change";
        NewNivelationHeader.Validate("Location Code", SalesPriceListHeader."NPR Location Code");
        NewNivelationHeader."Price List Code" := SalesPriceListHeader.Code;
        NewNivelationHeader."Posting Date" := WorkDate();
        NewNivelationHeader."Price Valid Date" := SalesPriceListHeader."Starting Date";
        NewNivelationHeader."Referring Document Code" := SalesPriceListHeader.Code;
        NewNivelationHeader.Insert(true);
        LineNo := NewNivelationLines.GetInitialLine(NewNivelationHeader);

        CheckForUnitPriceDifferenceAndAddLines(SalesPriceListHeader, PreviousPriceListHeader, NewNivelationHeader, NewNivelationLines, LineNo);

        NivelationPost.RunNivelationPosting(NewNivelationHeader);
    end;


    local procedure CheckForUnitPriceDifference(SalesPriceListHeader: Record "Price List Header"; PreviousPriceListHeader: Record "Price List Header"): Boolean
    var
        SalesPriceListLine: Record "Price List Line";
        PreviousPriceListLine: Record "Price List Line";
        Quantity: Decimal;
    begin
        SalesPriceListLine.SetCurrentKey(Status, "Price Type", "Amount Type", "Currency Code", "Unit of Measure Code", "Source Type", "Parent Source No.", "Source No.", "Asset Type", "Asset No.", "Work Type Code", "Starting Date", "Ending Date", "Minimum Quantity");
        SalesPriceListLine.SetLoadFields("Price List Code", "Asset No.", "Unit Price");
        PreviousPriceListLine.SetCurrentKey(Status, "Price Type", "Amount Type", "Currency Code", "Unit of Measure Code", "Source Type", "Parent Source No.", "Source No.", "Asset Type", "Asset No.", "Work Type Code", "Starting Date", "Ending Date", "Minimum Quantity");
        PreviousPriceListLine.SetLoadFields("Price List Code", "Asset No.", "Unit Price");
        SalesPriceListLine.SetRange("Price List Code", SalesPriceListHeader.Code);
        if SalesPriceListLine.FindSet() then
            repeat
                PreviousPriceListLine.SetRange("Price List Code", PreviousPriceListHeader.Code);
                PreviousPriceListLine.SetRange("Asset No.", SalesPriceListLine."Asset No.");
                if PreviousPriceListLine.FindFirst() then begin
                    FindItemLedgerQty(SalesPriceListHeader, SalesPriceListLine, Quantity);
                    if (SalesPriceListLine."Unit Price" <> PreviousPriceListLine."Unit Price") and (Quantity <> 0) then
                        exit(true);
                end;
            until SalesPriceListLine.Next() = 0;
        exit(false);
    end;

    local procedure CheckForUnitPriceDifferenceAndAddLines(SalesPriceListHeader: Record "Price List Header"; PreviousPriceListHeader: Record "Price List Header"; NewNivelationHeader2: Record "NPR RS Nivelation Header"; var NewNivelationLines2: Record "NPR RS Nivelation Lines"; var LineNo: Integer)
    var
        SalesPriceListLine: Record "Price List Line";
        PreviousPriceListLine: Record "Price List Line";
    begin
        SalesPriceListLine.SetCurrentKey(Status, "Price Type", "Amount Type", "Currency Code", "Unit of Measure Code", "Source Type", "Parent Source No.", "Source No.", "Asset Type", "Asset No.", "Work Type Code", "Starting Date", "Ending Date", "Minimum Quantity");
        SalesPriceListLine.SetLoadFields("Price List Code", "Asset No.", "Unit Price");
        PreviousPriceListLine.SetCurrentKey(Status, "Price Type", "Amount Type", "Currency Code", "Unit of Measure Code", "Source Type", "Parent Source No.", "Source No.", "Asset Type", "Asset No.", "Work Type Code", "Starting Date", "Ending Date", "Minimum Quantity");
        PreviousPriceListLine.SetLoadFields("Price List Code", "Asset No.", "Unit Price");
        SalesPriceListLine.SetRange("Price List Code", SalesPriceListHeader.Code);
        if SalesPriceListLine.FindSet() then
            repeat
                PreviousPriceListLine.SetRange("Price List Code", PreviousPriceListHeader.Code);
                PreviousPriceListLine.SetRange("Asset No.", SalesPriceListLine."Asset No.");
                if PreviousPriceListLine.FindFirst() then
                    if SalesPriceListLine."Unit Price" <> PreviousPriceListLine."Unit Price" then
                        AddNivelationLine(PreviousPriceListLine, SalesPriceListHeader, SalesPriceListLine, NewNivelationHeader2, NewNivelationLines2, LineNo);
            until SalesPriceListLine.Next() = 0;

        PreviousPriceListHeader.Validate("Ending Date", CalcDate('<-1D>', SalesPriceListHeader."Starting Date"));
        PreviousPriceListHeader.Modify();
    end;

    local procedure AddNivelationLine(PreviousSalesPriceListLine: Record "Price List Line"; SalesPriceListHeader: Record "Price List Header"; SalesPriceListLine: Record "Price List Line"; NivelationHeader: Record "NPR RS Nivelation Header"; var NewNivelationLines: Record "NPR RS Nivelation Lines"; var LineNo: Integer)
    var
        VATSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Quantity: Decimal;
    begin
        FindItemLedgerQty(SalesPriceListHeader, SalesPriceListLine, Quantity);
        if Quantity <= 0 then
            exit;
        NewNivelationLines.Init();
        NewNivelationLines."Line No." := LineNo;
        NewNivelationLines."Document No." := NivelationHeader."No.";
        NewNivelationLines."Location Code" := SalesPriceListHeader."NPR Location Code";
        NewNivelationLines.Validate("Item No.", SalesPriceListLine."Asset No.");
        NewNivelationLines.Quantity := Quantity;
        NewNivelationLines."Old Price" := PreviousSalesPriceListLine."Unit Price";
        NewNivelationLines."New Price" := SalesPriceListLine."Unit Price";
        NewNivelationLines."Posting Date" := WorkDate();
        NewNivelationLines."Old Value" := NewNivelationLines."Old Price" * NewNivelationLines.Quantity;
        NewNivelationLines."VAT Bus. Posting Gr. (Price)" := SalesPriceListHeader."VAT Bus. Posting Gr. (Price)";
        if Item.Get(SalesPriceListLine."Asset No.") then
            if VATSetup.Get(SalesPriceListHeader."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") then
                NewNivelationLines."VAT %" := VATSetup."VAT %";
        NewNivelationLines.Insert(true);
        LineNo += 10000;
    end;

    local procedure FindItemLedgerQty(SalesPriceListHeader: Record "Price List Header"; SalesPriceListLine: Record "Price List Line"; var Quantity: Decimal)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetCurrentKey("Item No.", "Posting Date");
        ItemLedgerEntry.SetLoadFields("Item No.", "Posting Date", Quantity);
        ItemLedgerEntry.SetRange("Item No.", SalesPriceListLine."Asset No.");
        ItemLedgerEntry.SetFilter("Posting Date", '..%1', CalcDate('<-1D>', SalesPriceListHeader."Starting Date"));
        if ItemLedgerEntry.FindSet() then
            ItemLedgerEntry.CalcSums(Quantity);
        if ItemLedgerEntry.Quantity <= 0 then begin
            Quantity := 0;
            exit;
        end;
        Quantity := ItemLedgerEntry.Quantity;
    end;
#endif
}