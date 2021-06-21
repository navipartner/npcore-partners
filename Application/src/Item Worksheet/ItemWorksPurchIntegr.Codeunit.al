codeunit 6060057 "NPR Item Works. Purch. Integr."
{
    var
        RegisteredButNotFoundErr: Label 'And Item Worksheet Line was registered but not found in Registered Item Lines.';
        OneLineFoundQst: Label 'One Item Worksheet Line found. Would you like to created the item with description %1?', Comment = '%1 = Description';

    procedure CreateItemFromWorksheet(VendorNo: Code[20]; VendorItemNo: Text[50]; var ItemNo: Code[20]): Boolean
    var
        ItemWorksheet: Record "NPR Item Worksheet";
    begin
        //Search Vendor specific Worksheets
        ItemWorksheet.SetRange("Vendor No.", VendorNo);
        if not SelectItemWorksheet(ItemWorksheet, VendorItemNo) then begin
            //Search Worksheets without vendor
            ItemWorksheet.SetFilter("Vendor No.", '=%1', '');
            if not SelectItemWorksheet(ItemWorksheet, VendorItemNo) then
                exit(false);
        end;

        exit(SelectItemtoCreate(ItemWorksheet, VendorNo, VendorItemNo, ItemNo));
    end;

    local procedure SelectItemtoCreate(ItemWorksheet: Record "NPR Item Worksheet"; VendorNo: Code[20]; VendorItemNo: Text[50]; var ItemNo: Code[20]): Boolean
    var
        TempItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line" temporary;
        TempItemWorksheetLine: Record "NPR Item Worksheet Line" temporary;
        ItemWorksheetPage: Page "NPR Item Worksheet Page";
        LineNoFilter: Text;
    begin
        MatchToItemWorksheetLine(ItemWorksheet, VendorItemNo, TempItemWorksheetLine, TempItemWorksheetVariantLine);
        if (TempItemWorksheetLine.Count() = 1) and (TempItemWorksheetLine.Action = TempItemWorksheetLine.Action::CreateNew) then begin
            //only one possible line
            TempItemWorksheetLine."Vendor No." := VendorNo;
            if GuiAllowed then begin
                if Confirm(StrSubstNo(OneLineFoundQst, TempItemWorksheetLine.Description)) then begin
                    if CreateItem(TempItemWorksheetLine, ItemNo) then
                        exit(true);
                end;
            end else
                if CreateItem(TempItemWorksheetLine, ItemNo) then
                    exit(true);
        end;
        if not GuiAllowed then
            exit(true);

        //more than one possible line: open the item worksheet filtered to these lines
        TempItemWorksheetLine.SetFilter("Worksheet Template Name", TempItemWorksheetLine."Worksheet Template Name");
        TempItemWorksheetLine.SetFilter("Worksheet Name", TempItemWorksheetLine."Worksheet Name");
        if TempItemWorksheetLine.FindSet() then
            repeat
                if LineNoFilter <> '' then
                    LineNoFilter := LineNoFilter + '|';
                LineNoFilter := LineNoFilter + Format(TempItemWorksheetLine."Line No.");
            until (TempItemWorksheetLine.Next() = 0) or (StrLen(LineNoFilter) >= 200);
        if LineNoFilter = '' then
            exit(false);

        TempItemWorksheetLine.SetFilter("Worksheet Template Name", TempItemWorksheetLine."Worksheet Template Name");
        TempItemWorksheetLine.SetFilter("Worksheet Name", TempItemWorksheetLine."Worksheet Name");
        TempItemWorksheetLine.SetFilter("Line No.", LineNoFilter);
        ItemWorksheetPage.OpenFilteredView(TempItemWorksheetLine);
        ItemWorksheetPage.Run();
        exit(false);
    end;

    local procedure CreateItem(TempItemWorksheetLine: Record "NPR Item Worksheet Line" temporary; var ItemNo: Code[20]): Boolean
    var
        ItemWorksheetLine: Record "NPR Item Worksheet Line";
        RegisteredItemWorksheetLine: Record "NPR Regist. Item Worksh Line";
        RegisteredItemWorksheet: Record "NPR Registered Item Works.";
        Description: Text;
    begin
        ItemWorksheetLine.Get(TempItemWorksheetLine."Worksheet Template Name", TempItemWorksheetLine."Worksheet Name", TempItemWorksheetLine."Line No.");
        ItemWorksheetLine.SetRange("Worksheet Template Name", ItemWorksheetLine."Worksheet Template Name");
        ItemWorksheetLine.SetRange("Worksheet Name", ItemWorksheetLine."Worksheet Name");
        ItemWorksheetLine.SetRange("Line No.", ItemWorksheetLine."Line No.");
        ItemWorksheetLine.FindFirst();
        ItemWorksheetLine."Vendor No." := TempItemWorksheetLine."Vendor No.";
        ItemWorksheetLine.Modify();
        Commit();
        ItemNo := TempItemWorksheetLine."Item No.";
        Description := ItemWorksheetLine.Description;
        if not CODEUNIT.Run(CODEUNIT::"NPR Item Wsht.-Regist. Batch", ItemWorksheetLine) then
            exit(false);
        if ItemWorksheetLine.Get(TempItemWorksheetLine."Worksheet Template Name", TempItemWorksheetLine."Worksheet Name", TempItemWorksheetLine."Line No.") then
            if ItemWorksheetLine.Status = ItemWorksheetLine.Status::Error then
                exit(false);
        if (ItemNo = '') then begin
            RegisteredItemWorksheet.Reset();
            RegisteredItemWorksheet.FindLast();
            RegisteredItemWorksheetLine.SetFilter(Description, Description);
            if not RegisteredItemWorksheetLine.FindFirst() then
                Error(RegisteredButNotFoundErr);
            ItemNo := RegisteredItemWorksheetLine."Item No.";
        end;
        Commit();
        exit(true);
    end;

    local procedure SelectItemWorksheet(var ItemWorksheet: Record "NPR Item Worksheet"; VendorItemNo: Text[50]): Boolean
    var
        TempItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line" temporary;
        TempItemWorksheetWithPossibleMatch: Record "NPR Item Worksheet" temporary;
        TempItemWorksheetLine: Record "NPR Item Worksheet Line" temporary;
        ItemWorksheets: Page "NPR Item Worksheets";
    begin
        case ItemWorksheet.Count() of
            0:
                exit(false);
            1:
                begin
                    ItemWorksheet.FindFirst();
                    exit(true);
                end;
            else begin
                    //More than one item worksheet in the selection
                    if ItemWorksheet.FindSet() then
                        repeat
                            MatchToItemWorksheetLine(ItemWorksheet, VendorItemNo, TempItemWorksheetLine, TempItemWorksheetVariantLine);
                            if (TempItemWorksheetVariantLine.Count() > 0) or (TempItemWorksheetLine.Count() > 0) then begin
                                TempItemWorksheetWithPossibleMatch := ItemWorksheet;
                                TempItemWorksheetWithPossibleMatch.Insert();
                            end;
                        until ItemWorksheet.Next() = 0;
                    case TempItemWorksheetWithPossibleMatch.Count() of
                        0:
                            exit(false);
                        1:
                            begin
                                ItemWorksheet.Get(TempItemWorksheetWithPossibleMatch."Item Template Name", TempItemWorksheetWithPossibleMatch.Name);
                            end;
                        else begin
                                //More than one of these item worksheets contains a matching line
                                if not GuiAllowed then
                                    exit(false);
                                if TempItemWorksheetWithPossibleMatch.FindSet() then
                                    repeat
                                        TempItemWorksheetWithPossibleMatch.Mark(true);
                                    until TempItemWorksheetWithPossibleMatch.Next() = 0;
                                TempItemWorksheetWithPossibleMatch.MarkedOnly(true);
                                ItemWorksheets.SetTableView(TempItemWorksheetWithPossibleMatch);
                                if ItemWorksheets.RunModal() <> ACTION::LookupOK then begin
                                    ItemWorksheets.GetRecord(ItemWorksheet);
                                    exit(true);
                                end else
                                    exit(false);
                            end;
                    end;
                end;
        end;
    end;

    local procedure MatchToItemWorksheetLine(ItemWorksheet: Record "NPR Item Worksheet"; VendorItemNo: Text[50]; var TempItemWorksheetLine: Record "NPR Item Worksheet Line" temporary; var TempItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line" temporary): Boolean
    var
        ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line";
        ItemWorksheetLine: Record "NPR Item Worksheet Line";
    begin
        ItemWorksheetLine.SetRange("Worksheet Template Name", ItemWorksheet."Item Template Name");
        ItemWorksheetLine.SetRange("Worksheet Name", ItemWorksheet.Name);
        //Matching criterea Item Worksheet Line
        //Vendor Item No.
        ItemWorksheetLine.SetFilter("Vendor Item No.", VendorItemNo);
        AddItemWorksheetLinesToTemp(ItemWorksheetLine, TempItemWorksheetLine);
        ItemWorksheetLine.SetFilter("Vendor Item No.", '');

        //Internal Bar Code
        ItemWorksheetLine.SetFilter("Internal Bar Code", VendorItemNo);
        AddItemWorksheetLinesToTemp(ItemWorksheetLine, TempItemWorksheetLine);
        ItemWorksheetLine.SetFilter("Internal Bar Code", '');

        //Vendors Bar Code
        ItemWorksheetLine.SetFilter("Vendors Bar Code", VendorItemNo);
        AddItemWorksheetLinesToTemp(ItemWorksheetLine, TempItemWorksheetLine);
        ItemWorksheetLine.SetFilter("Vendors Bar Code", '');

        //GTIN
        if StrLen(VendorItemNo) <= MaxStrLen(ItemWorksheetLine.GTIN) then begin
            ItemWorksheetLine.SetFilter(GTIN, VendorItemNo);
            AddItemWorksheetLinesToTemp(ItemWorksheetLine, TempItemWorksheetLine);
            ItemWorksheetLine.SetFilter(GTIN, '');
        end;

        ItemWorksheetVariantLine.SetRange("Worksheet Template Name", ItemWorksheet."Item Template Name");
        ItemWorksheetVariantLine.SetRange("Worksheet Name", ItemWorksheet.Name);

        //Matching criterea Item Variant Line
        //Internal Bar Code
        ItemWorksheetVariantLine.SetFilter("Internal Bar Code", VendorItemNo);
        AddItemWorksheetVariantLinesToTemp(TempItemWorksheetLine, ItemWorksheetVariantLine, TempItemWorksheetVariantLine);
        ItemWorksheetVariantLine.SetFilter("Internal Bar Code", '');

        //Vendors Bar Code
        ItemWorksheetVariantLine.SetFilter("Vendors Bar Code", VendorItemNo);
        AddItemWorksheetVariantLinesToTemp(TempItemWorksheetLine, ItemWorksheetVariantLine, TempItemWorksheetVariantLine);
        ItemWorksheetVariantLine.SetFilter("Vendors Bar Code", '');
    end;

    local procedure AddItemWorksheetLinesToTemp(var ItemWorksheetLine: Record "NPR Item Worksheet Line"; var TempItemWorksheetLine: Record "NPR Item Worksheet Line" temporary)
    begin
        if ItemWorksheetLine.FindSet() then
            repeat
                if not TempItemWorksheetLine.Get(ItemWorksheetLine."Worksheet Template Name", ItemWorksheetLine."Worksheet Name", ItemWorksheetLine."Line No.") then begin
                    TempItemWorksheetLine := ItemWorksheetLine;
                    TempItemWorksheetLine.Insert();
                end;
            until ItemWorksheetLine.Next() = 0;
    end;

    local procedure AddItemWorksheetVariantLinesToTemp(var TempItemWorksheetLine: Record "NPR Item Worksheet Line" temporary; var ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line"; var TempItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line" temporary)
    var
        ItemWorksheetLine: Record "NPR Item Worksheet Line";
    begin
        if ItemWorksheetVariantLine.FindSet() then
            repeat
                if not TempItemWorksheetVariantLine.Get(ItemWorksheetVariantLine."Worksheet Template Name", ItemWorksheetVariantLine."Worksheet Name", ItemWorksheetVariantLine."Worksheet Line No.", ItemWorksheetVariantLine."Line No.") then begin
                    TempItemWorksheetVariantLine := ItemWorksheetVariantLine;
                    TempItemWorksheetVariantLine.Insert();
                    //also insert ItemWorksheetLine
                    if not TempItemWorksheetLine.Get(ItemWorksheetVariantLine."Worksheet Template Name", ItemWorksheetVariantLine."Worksheet Name", ItemWorksheetVariantLine."Worksheet Line No.") then begin
                        ItemWorksheetLine."Worksheet Template Name" := ItemWorksheetVariantLine."Worksheet Template Name";
                        ItemWorksheetLine."Worksheet Name" := ItemWorksheetVariantLine."Worksheet Name";
                        ItemWorksheetLine."Line No." := ItemWorksheetVariantLine."Worksheet Line No.";
                        ItemWorksheetLine.Find();
                        TempItemWorksheetLine := ItemWorksheetLine;
                        TempItemWorksheetLine.Insert();
                    end;
                end;
            until ItemWorksheetLine.Next() = 0;
    end;
}

