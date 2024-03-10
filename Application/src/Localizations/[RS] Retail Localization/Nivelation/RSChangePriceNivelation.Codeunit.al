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
        if CheckIfNivelationPosted(SalesPriceListHeader) then
            exit;

        PreviousPriceListHeader.SetRange(Status, "Price Status"::Active);
        PreviousPriceListHeader.SetRange("Ending Date", CalcDate('<-1D>', SalesPriceListHeader."Starting Date"));
        PreviousPriceListHeader.SetRange("NPR Location Code", SalesPriceListHeader."NPR Location Code");
        if not PreviousPriceListHeader.FindFirst() then
            Error(PreviousPriceListNotFoundErr);
        if not (CheckForUnitPriceDifference(SalesPriceListHeader, PreviousPriceListHeader)) then
            Error(UnsuccessfulNivelationPostingMsg);
        NewNivelationHeader.Init();
        NewNivelationHeader.Type := "NPR RS Nivelation Type"::"Price Change";
        NewNivelationHeader."Source Type" := "NPR RS Nivelation Source Type"::"Sales Price List";
        NewNivelationHeader.Validate("Location Code", SalesPriceListHeader."NPR Location Code");
        NewNivelationHeader.Validate("Price List Code", SalesPriceListHeader.Code);
        NewNivelationHeader."Posting Date" := WorkDate();
        NewNivelationHeader."Referring Document Code" := SalesPriceListHeader.Code;
        NewNivelationHeader.Insert(true);
        LineNo := NewNivelationLines.GetInitialLine() + 10000;

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

    local procedure CheckIfNivelationPosted(SalesPriceListHeader: Record "Price List Header"): Boolean
    var
        PostedNivelationHeader: Record "NPR RS Posted Nivelation Hdr";
        NivelationAlreadyPostedForPricelistErr: Label 'Nivelation Document has already been posted for current Price List. Posted Nivelation Document No: %1', Comment = '%1 - Posted Nivelation Header No.';
    begin
        PostedNivelationHeader.SetRange("Referring Document Code", SalesPriceListHeader.Code);
        PostedNivelationHeader.SetRange(Type, "NPR RS Nivelation Type"::"Price Change");
        if not PostedNivelationHeader.FindFirst() then
            exit(false);
        Error(NivelationAlreadyPostedForPricelistErr, PostedNivelationHeader."No.");
    end;

    local procedure AddNivelationLine(PreviousSalesPriceListLine: Record "Price List Line"; SalesPriceListHeader: Record "Price List Header"; SalesPriceListLine: Record "Price List Line"; NivelationHeader: Record "NPR RS Nivelation Header"; var NewNivelationLines: Record "NPR RS Nivelation Lines"; var LineNo: Integer)
    var
        Quantity: Decimal;
    begin
        FindItemLedgerQty(SalesPriceListHeader, SalesPriceListLine, Quantity);
        if Quantity <= 0 then
            exit;
        NewNivelationLines.Init();
        NewNivelationLines."Line No." := LineNo;
        NewNivelationLines."Document No." := NivelationHeader."No.";
        NewNivelationLines.GetDataFromNivelationHeader();
        NewNivelationLines.Validate("Item No.", SalesPriceListLine."Asset No.");
        NewNivelationLines."Old Price" := PreviousSalesPriceListLine."Unit Price";
        NewNivelationLines."New Price" := SalesPriceListLine."Unit Price";
        NewNivelationLines."Posting Date" := WorkDate();
        NewNivelationLines.Validate(Quantity, Quantity);
        NewNivelationLines."VAT Bus. Posting Gr. (Price)" := SalesPriceListHeader."VAT Bus. Posting Gr. (Price)";
        NewNivelationLines.Insert(true);
        LineNo += 10000;
    end;

    local procedure FindItemLedgerQty(SalesPriceListHeader: Record "Price List Header"; SalesPriceListLine: Record "Price List Line"; var Quantity: Decimal)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetCurrentKey("Item No.", "Posting Date");
        ItemLedgerEntry.SetLoadFields("Item No.", "Posting Date", "Location Code", Quantity);
        ItemLedgerEntry.SetRange("Location Code", SalesPriceListHeader."NPR Location Code");
        ItemLedgerEntry.SetRange("Item No.", SalesPriceListLine."Asset No.");
        ItemLedgerEntry.SetFilter("Posting Date", '..%1', CalcDate('<-1D>', SalesPriceListHeader."Starting Date"));
        ItemLedgerEntry.CalcSums(Quantity);
        if ItemLedgerEntry.Quantity <= 0 then begin
            Quantity := 0;
            exit;
        end;
        Quantity := ItemLedgerEntry.Quantity;
    end;
#endif
}