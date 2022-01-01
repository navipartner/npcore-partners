report 6060043 "NPR Export Excel Item Worksh."
{
    Caption = 'Export Excel Item Worksheet';
    ProcessingOnly = true;
    UsageCategory = None;
    UseRequestPage = false;

    dataset
    {
        dataitem("Item Worksheet Line"; "NPR Item Worksheet Line")
        {

            trigger OnAfterGetRecord()
            begin
                if RowNo = HeaderRowNo then begin
                    ItemWorksheetTemplate.Get("Worksheet Template Name");
                    ItemWorksheet.Get("Worksheet Template Name", "Worksheet Name");
                end;

                RecNo := RecNo + 1;
                if GuiAllowed then begin
                    Window.Update(1, Round(RecNo / TotalRecNo * 10000, 1));
                end;

                ItemWshtImpExpMgt.RaiseOnBeforeExportWorksheetLine("Item Worksheet Line");

                ItemWorksheetVariantLine.Reset();
                ItemWorksheetVariantLine.SetRange("Worksheet Template Name", "Worksheet Template Name");
                ItemWorksheetVariantLine.SetRange("Worksheet Name", "Worksheet Name");
                ItemWorksheetVariantLine.SetRange("Worksheet Line No.", "Line No.");
                ItemWorksheetVariantLine.SetFilter(Action, '<>%1', ItemWorksheetVariantLine.Action::Undefined);
                if ItemWorksheetVariantLine.FindSet() then begin
                    repeat
                        //Add row based on Worksheet Variant Line
                        ItemWshtImpExpMgt.RaiseOnBeforeExportWorksheetVariantLine(ItemWorksheetVariantLine);
                        RowNo := RowNo + 1;
                        if MappingFound then begin
                            if ItemWorksheetVariantLine."Existing Item No." <> '' then
                                MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Item No."), Format(ItemWorksheetVariantLine."Existing Item No."), false, false, '', TempExcelBuf."Cell Type"::Text)
                            else
                                MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Item No."), Format(ItemWorksheetVariantLine."Item No."), false, false, '', TempExcelBuf."Cell Type"::Text);
                            MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo(Description), Format(ItemWorksheetVariantLine.Description), false, false, '', TempExcelBuf."Cell Type"::Text);
                            MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Item Category Code"), Format("Item Category Code"), false, false, '', TempExcelBuf."Cell Type"::Text);
                            MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Product Group Code"), Format("Product Group Code"), false, false, '', TempExcelBuf."Cell Type"::Text);
                            MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Vendor Item No."), Format("Vendor Item No."), false, false, '', TempExcelBuf."Cell Type"::Text);
                            MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Tariff No."), Format("Tariff No."), false, false, '', TempExcelBuf."Cell Type"::Text);
                            if ItemWorksheetVariantLine."Sales Price" <> 0 then
                                MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Sales Price"), Format(ItemWorksheetVariantLine."Sales Price"), false, false, '', TempExcelBuf."Cell Type"::Number)
                            else
                                MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Sales Price"), Format("Sales Price"), false, false, '', TempExcelBuf."Cell Type"::Number);
                            MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Sales Price Currency Code"), Format("Sales Price Currency Code"), false, false, '', TempExcelBuf."Cell Type"::Text);
                            if ItemWorksheetVariantLine."Direct Unit Cost" <> 0 then
                                MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Direct Unit Cost"), Format(ItemWorksheetVariantLine."Direct Unit Cost"), false, false, '', TempExcelBuf."Cell Type"::Number)
                            else
                                MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Direct Unit Cost"), Format("Direct Unit Cost"), false, false, '', TempExcelBuf."Cell Type"::Number);
                            MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Purchase Price Currency Code"), Format("Purchase Price Currency Code"), false, false, '', TempExcelBuf."Cell Type"::Text);
                            MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Vendor No."), Format("Vendor No."), false, false, '', TempExcelBuf."Cell Type"::Text);
                            MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Variety Group"), Format("Variety Group"), false, false, '', TempExcelBuf."Cell Type"::Text);
                            MapCell(RowNo, DATABASE::"NPR Item Worksh. Variant Line", ItemWorksheetVariantLine.FieldNo("Variety 1 Value"), Format(ItemWorksheetVariantLine."Variety 1 Value"), false, false, '', TempExcelBuf."Cell Type"::Text);
                            MapCell(RowNo, DATABASE::"NPR Item Worksh. Variant Line", ItemWorksheetVariantLine.FieldNo("Variety 2 Value"), Format(ItemWorksheetVariantLine."Variety 2 Value"), false, false, '', TempExcelBuf."Cell Type"::Text);
                            MapCell(RowNo, DATABASE::"NPR Item Worksh. Variant Line", ItemWorksheetVariantLine.FieldNo("Variety 3 Value"), Format(ItemWorksheetVariantLine."Variety 3 Value"), false, false, '', TempExcelBuf."Cell Type"::Text);
                            MapCell(RowNo, DATABASE::"NPR Item Worksh. Variant Line", ItemWorksheetVariantLine.FieldNo("Variety 4 Value"), Format(ItemWorksheetVariantLine."Variety 4 Value"), false, false, '', TempExcelBuf."Cell Type"::Text);
                            if ItemWorksheetVariantLine."Recommended Retail Price" <> 0 then
                                MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Recommended Retail Price"), Format(ItemWorksheetVariantLine."Recommended Retail Price"), false, false, '', TempExcelBuf."Cell Type"::Number)
                            else
                                MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Recommended Retail Price"), Format("Recommended Retail Price"), false, false, '', TempExcelBuf."Cell Type"::Number);
                            if ItemWorksheetVariantLine."Internal Bar Code" <> '' then
                                MapCell(RowNo, DATABASE::"NPR Item Worksh. Variant Line", ItemWorksheetVariantLine.FieldNo("Internal Bar Code"), Format(ItemWorksheetVariantLine."Internal Bar Code"), false, false, '', TempExcelBuf."Cell Type"::Text)
                            else
                                MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Internal Bar Code"), Format("Internal Bar Code"), false, false, '', TempExcelBuf."Cell Type"::Text);
                            if ItemWorksheetVariantLine."Vendors Bar Code" <> '' then
                                MapCell(RowNo, DATABASE::"NPR Item Worksh. Variant Line", ItemWorksheetVariantLine.FieldNo("Vendors Bar Code"), Format(ItemWorksheetVariantLine."Vendors Bar Code"), false, false, '', TempExcelBuf."Cell Type"::Text)
                            else
                                MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Vendors Bar Code"), Format("Vendors Bar Code"), false, false, '', TempExcelBuf."Cell Type"::Text);
                            MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Net Weight"), Format("Net Weight"), false, false, '', TempExcelBuf."Cell Type"::Number);
                            MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Gross Weight"), Format("Gross Weight"), false, false, '', TempExcelBuf."Cell Type"::Number);
                            MapAllColumns(RowNo, DATABASE::"NPR Item Worksheet Line", false, false, '');
                            MapAttributeCells(RowNo, DATABASE::"NPR Item Worksheet Line", false, false, '', TempExcelBuf."Cell Type"::Number);
                        end else begin
                            if ItemWorksheetVariantLine."Existing Item No." <> '' then
                                EnterCell(RowNo, 1, Format(ItemWorksheetVariantLine."Existing Item No."), false, false, '', TempExcelBuf."Cell Type"::Text)
                            else
                                EnterCell(RowNo, 1, Format(ItemWorksheetVariantLine."Item No."), false, false, '', TempExcelBuf."Cell Type"::Text);
                            EnterCell(RowNo, 0, Format(ItemWorksheetVariantLine.Description), false, false, '', TempExcelBuf."Cell Type"::Text);
                            EnterCell(RowNo, 0, Format("Item Category Code"), false, false, '', TempExcelBuf."Cell Type"::Text);
                            EnterCell(RowNo, 0, Format("Product Group Code"), false, false, '', TempExcelBuf."Cell Type"::Text);
                            EnterCell(RowNo, 0, Format("Vendor Item No."), false, false, '', TempExcelBuf."Cell Type"::Text);
                            EnterCell(RowNo, 0, Format("Tariff No."), false, false, '', TempExcelBuf."Cell Type"::Text);
                            if ItemWorksheetVariantLine."Sales Price" <> 0 then
                                EnterCell(RowNo, 0, Format(ItemWorksheetVariantLine."Sales Price"), false, false, '', TempExcelBuf."Cell Type"::Number)
                            else
                                EnterCell(RowNo, 0, Format("Sales Price"), false, false, '', TempExcelBuf."Cell Type"::Number);
                            EnterCell(RowNo, 0, Format("Sales Price Currency Code"), false, false, '', TempExcelBuf."Cell Type"::Text);
                            if ItemWorksheetVariantLine."Direct Unit Cost" <> 0 then
                                EnterCell(RowNo, 0, Format(ItemWorksheetVariantLine."Direct Unit Cost"), false, false, '', TempExcelBuf."Cell Type"::Number)
                            else
                                EnterCell(RowNo, 0, Format("Direct Unit Cost"), false, false, '', TempExcelBuf."Cell Type"::Number);
                            EnterCell(RowNo, 0, Format("Purchase Price Currency Code"), false, false, '', TempExcelBuf."Cell Type"::Text);
                            EnterCell(RowNo, 0, Format("Vendor No."), false, false, '', TempExcelBuf."Cell Type"::Text);
                            EnterCell(RowNo, 0, Format("Variety Group"), false, false, '', TempExcelBuf."Cell Type"::Text);
                            EnterCell(RowNo, 0, ItemWorksheetVariantLine."Variety 1 Value", false, false, '', TempExcelBuf."Cell Type"::Text);
                            EnterCell(RowNo, 0, ItemWorksheetVariantLine."Variety 2 Value", false, false, '', TempExcelBuf."Cell Type"::Text);
                            EnterCell(RowNo, 0, ItemWorksheetVariantLine."Variety 3 Value", false, false, '', TempExcelBuf."Cell Type"::Text);
                            EnterCell(RowNo, 0, ItemWorksheetVariantLine."Variety 4 Value", false, false, '', TempExcelBuf."Cell Type"::Text);
                            if ItemWorksheetVariantLine."Recommended Retail Price" <> 0 then
                                EnterCell(RowNo, 0, Format(ItemWorksheetVariantLine."Recommended Retail Price"), false, false, '', TempExcelBuf."Cell Type"::Number)
                            else
                                EnterCell(RowNo, 0, Format("Recommended Retail Price"), false, false, '', TempExcelBuf."Cell Type"::Number);
                            if ItemWorksheetVariantLine."Vendors Bar Code" <> '' then
                                EnterCell(RowNo, 0, ItemWorksheetVariantLine."Vendors Bar Code", false, false, '', TempExcelBuf."Cell Type"::Text)
                            else
                                EnterCell(RowNo, 0, "Vendors Bar Code", false, false, '', TempExcelBuf."Cell Type"::Text);
                            if ItemWorksheetVariantLine."Internal Bar Code" <> '' then
                                EnterCell(RowNo, 0, ItemWorksheetVariantLine."Internal Bar Code", false, false, '', TempExcelBuf."Cell Type"::Text)
                            else
                                EnterCell(RowNo, 0, "Internal Bar Code", false, false, '', TempExcelBuf."Cell Type"::Text);
                            EnterCell(RowNo, 0, Format("Net Weight"), false, false, '', TempExcelBuf."Cell Type"::Number);
                            EnterCell(RowNo, 0, Format("Gross Weight"), false, false, '', TempExcelBuf."Cell Type"::Number);
                            NPRAttrManagement.GetWorksheetLineAttributeValue(NPRAttrTextArray, DATABASE::"NPR Item Worksheet Line", "Worksheet Template Name", "Worksheet Name", "Line No.");
                            i := 1;
                            if NPRAttrVisibleArray[1] then
                                repeat
                                    EnterCell(RowNo, 0, Format(NPRAttrTextArray[i]), false, false, '', TempExcelBuf."Cell Type"::Text);
                                    i := i + 1;
                                until not NPRAttrVisibleArray[i];
                        end;
                    until ItemWorksheetVariantLine.Next() = 0;
                end else begin
                    //Add row based on Worksheet Line
                    RowNo := RowNo + 1;
                    if MappingFound then begin
                        if ItemWorksheetVariantLine."Existing Item No." <> '' then
                            MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Item No."), Format("Existing Item No."), false, false, '', TempExcelBuf."Cell Type"::Text)
                        else
                            MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Item No."), Format("Item No."), false, false, '', TempExcelBuf."Cell Type"::Text);
                        MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo(Description), Format(Description), false, false, '', TempExcelBuf."Cell Type"::Text);
                        MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Item Category Code"), Format("Item Category Code"), false, false, '', TempExcelBuf."Cell Type"::Text);
                        MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Product Group Code"), Format("Product Group Code"), false, false, '', TempExcelBuf."Cell Type"::Text);
                        MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Vendor Item No."), Format("Vendor Item No."), false, false, '', TempExcelBuf."Cell Type"::Text);
                        MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Tariff No."), Format("Tariff No."), false, false, '', TempExcelBuf."Cell Type"::Text);
                        MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Sales Price"), Format("Sales Price"), false, false, '', TempExcelBuf."Cell Type"::Number);
                        MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Sales Price Currency Code"), Format("Sales Price Currency Code"), false, false, '', TempExcelBuf."Cell Type"::Text);
                        MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Direct Unit Cost"), Format("Direct Unit Cost"), false, false, '', TempExcelBuf."Cell Type"::Number);
                        MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Purchase Price Currency Code"), Format("Purchase Price Currency Code"), false, false, '', TempExcelBuf."Cell Type"::Text);
                        MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Vendor No."), Format("Vendor No."), false, false, '', TempExcelBuf."Cell Type"::Text);
                        MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Variety Group"), Format("Variety Group"), false, false, '', TempExcelBuf."Cell Type"::Text);
                        MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Variety 1"), Format("Variety 1"), false, false, '', TempExcelBuf."Cell Type"::Text);
                        MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Variety 2"), Format("Variety 2"), false, false, '', TempExcelBuf."Cell Type"::Text);
                        MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Variety 3"), Format("Variety 3"), false, false, '', TempExcelBuf."Cell Type"::Text);
                        MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Variety 4"), Format("Variety 4"), false, false, '', TempExcelBuf."Cell Type"::Text);
                        MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Recommended Retail Price"), Format("Direct Unit Cost"), false, false, '', TempExcelBuf."Cell Type"::Number);
                        MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Vendors Bar Code"), Format("Vendors Bar Code"), false, false, '', TempExcelBuf."Cell Type"::Text);
                        MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Internal Bar Code"), Format("Internal Bar Code"), false, false, '', TempExcelBuf."Cell Type"::Text);
                        MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Net Weight"), Format("Net Weight"), false, false, '', TempExcelBuf."Cell Type"::Number);
                        MapCell(RowNo, DATABASE::"NPR Item Worksheet Line", FieldNo("Gross Weight"), Format("Gross Weight"), false, false, '', TempExcelBuf."Cell Type"::Number);
                        MapAllColumns(RowNo, DATABASE::"NPR Item Worksheet Line", false, false, '');
                        MapAttributeCells(RowNo, DATABASE::"NPR Item Worksheet Line", false, false, '', TempExcelBuf."Cell Type"::Number);
                    end else begin
                        if "Existing Item No." <> '' then
                            EnterCell(RowNo, 1, Format("Existing Item No."), false, false, '', TempExcelBuf."Cell Type"::Text)
                        else
                            EnterCell(RowNo, 1, Format("Item No."), false, false, '', TempExcelBuf."Cell Type"::Text);
                        EnterCell(RowNo, 0, Format(Description), false, false, '', TempExcelBuf."Cell Type"::Text);
                        EnterCell(RowNo, 0, Format("Item Category Code"), false, false, '', TempExcelBuf."Cell Type"::Text);
                        EnterCell(RowNo, 0, Format("Product Group Code"), false, false, '', TempExcelBuf."Cell Type"::Text);
                        EnterCell(RowNo, 0, Format("Vendor Item No."), false, false, '', TempExcelBuf."Cell Type"::Text);
                        EnterCell(RowNo, 0, Format("Tariff No."), false, false, '', TempExcelBuf."Cell Type"::Text);
                        EnterCell(RowNo, 0, Format("Sales Price"), false, false, '', TempExcelBuf."Cell Type"::Number);
                        EnterCell(RowNo, 0, Format("Sales Price Currency Code"), false, false, '', TempExcelBuf."Cell Type"::Text);
                        EnterCell(RowNo, 0, Format("Direct Unit Cost"), false, false, '', TempExcelBuf."Cell Type"::Number);
                        EnterCell(RowNo, 0, Format("Purchase Price Currency Code"), false, false, '', TempExcelBuf."Cell Type"::Text);
                        EnterCell(RowNo, 0, Format("Vendor No."), false, false, '', TempExcelBuf."Cell Type"::Text);
                        EnterCell(RowNo, 0, Format("Variety Group"), false, false, '', TempExcelBuf."Cell Type"::Text);
                        EnterCell(RowNo, 0, Format("Variety 1"), false, false, '', TempExcelBuf."Cell Type"::Text);
                        EnterCell(RowNo, 0, Format("Variety 2"), false, false, '', TempExcelBuf."Cell Type"::Text);
                        EnterCell(RowNo, 0, Format("Variety 3"), false, false, '', TempExcelBuf."Cell Type"::Text);
                        EnterCell(RowNo, 0, Format("Variety 4"), false, false, '', TempExcelBuf."Cell Type"::Text);
                        EnterCell(RowNo, 0, Format("Recommended Retail Price"), false, false, '', TempExcelBuf."Cell Type"::Number);
                        EnterCell(RowNo, 0, Format("Vendors Bar Code"), false, false, '', TempExcelBuf."Cell Type"::Text);
                        EnterCell(RowNo, 0, Format("Internal Bar Code"), false, false, '', TempExcelBuf."Cell Type"::Text);
                        EnterCell(RowNo, 0, Format("Net Weight"), false, false, '', TempExcelBuf."Cell Type"::Number);
                        EnterCell(RowNo, 0, Format("Gross Weight"), false, false, '', TempExcelBuf."Cell Type"::Number);
                        NPRAttrManagement.GetWorksheetLineAttributeValue(NPRAttrTextArray, DATABASE::"NPR Item Worksheet Line", "Worksheet Template Name", "Worksheet Name", "Line No.");
                        i := 1;
                        if NPRAttrVisibleArray[1] then
                            repeat
                                EnterCell(RowNo, 0, Format(NPRAttrTextArray[i]), false, false, '', TempExcelBuf."Cell Type"::Text);
                                i := i + 1;
                            until not NPRAttrVisibleArray[i];
                    end;
                end;
            end;

            trigger OnPostDataItem()
            begin

                TempExcelBuf.CreateNewBook(TextItemWorksheetLbl);
                TempExcelBuf.WriteSheet(
                  PadStr(StrSubstNo(Pct1Lbl, "Item Worksheet Line"."Worksheet Name", ItemWorksheet.Description), 30),
                  CompanyName,
                  UserId);

                TempExcelBuf.CloseBook();
                TempExcelBuf.SetFriendlyFilename(StrSubstNo(Pct2Lbl, "Item Worksheet Line"."Worksheet Name", ItemWorksheet.Description));
                TempExcelBuf.OpenExcel();
            end;

            trigger OnPreDataItem()
            begin
                if GetRangeMin("Worksheet Template Name") <> GetRangeMax("Worksheet Template Name") then
                    Error(ExportErr);
                if GetRangeMin("Worksheet Name") <> GetRangeMax("Worksheet Name") then
                    Error(ExportErr);

                TempExcelBuf.DeleteAll();

                if GuiAllowed then begin
                    Window.Open(
                      AnalyzingDataLbl +
                    '  @1@@@@@@@@@@@@@@@@@@@@@@@@@\');
                    Window.Update(1, 0);
                end;
                TotalRecNo := Count;

                RecNo := 0;

                //Add Header Row
                RowNo := 1;
                HeaderRowNo := RowNo;
                ItemWorksheet.Get(GetRangeMin("Worksheet Template Name"), GetRangeMax("Worksheet Name"));
                if ItemWorksheet."Excel Import from Line No." > 1 then begin
                    RowNo := ItemWorksheet."Excel Import from Line No." - 1;
                    HeaderRowNo := RowNo;
                end;
                ItemWorksheetExcelColumn.Reset();
                ItemWorksheetExcelColumn.SetRange("Worksheet Template Name", ItemWorksheet."Item Template Name");
                ItemWorksheetExcelColumn.SetRange("Worksheet Name", ItemWorksheet.Name);
                ItemWorksheetExcelColumn.SetFilter("Process as", '<>%1', ItemWorksheetExcelColumn."Process as"::Skip);
                ItemWorksheetExcelColumn.SetFilter("Excel Column No.", '>0');
                if ItemWorksheetExcelColumn.FindSet() then begin
                    MappingFound := true;
                    repeat
                        EnterCell(HeaderRowNo, ItemWorksheetExcelColumn."Excel Column No.", ItemWorksheetExcelColumn."Excel Header Text", false, true, '', TempExcelBuf."Cell Type"::Text);
                    until ItemWorksheetExcelColumn.Next() = 0;
                end else begin
                    MappingFound := false;
# pragma warning disable AA0139
                    EnterCell(HeaderRowNo, 1, FieldCaption("Item No."), false, true, '', TempExcelBuf."Cell Type"::Text);
                    EnterCell(HeaderRowNo, 0, FieldCaption(Description), false, true, '', TempExcelBuf."Cell Type"::Text);
                    EnterCell(HeaderRowNo, 0, FieldCaption("Item Category Code"), false, true, '', TempExcelBuf."Cell Type"::Text);
                    EnterCell(HeaderRowNo, 0, FieldCaption("Product Group Code"), false, true, '', TempExcelBuf."Cell Type"::Text);
                    EnterCell(HeaderRowNo, 0, FieldCaption("Vendor Item No."), false, true, '', TempExcelBuf."Cell Type"::Text);
                    EnterCell(HeaderRowNo, 0, FieldCaption("Tariff No."), false, true, '', TempExcelBuf."Cell Type"::Text);
                    EnterCell(HeaderRowNo, 0, FieldCaption("Sales Price"), false, true, '', TempExcelBuf."Cell Type"::Text);
                    EnterCell(HeaderRowNo, 0, FieldCaption("Sales Price Currency Code"), false, true, '', TempExcelBuf."Cell Type"::Text);
                    EnterCell(HeaderRowNo, 0, FieldCaption("Direct Unit Cost"), false, true, '', TempExcelBuf."Cell Type"::Text);
                    EnterCell(HeaderRowNo, 0, FieldCaption("Purchase Price Currency Code"), false, true, '', TempExcelBuf."Cell Type"::Text);
                    EnterCell(HeaderRowNo, 0, FieldCaption("Vendor No."), false, true, '', TempExcelBuf."Cell Type"::Text);
                    EnterCell(HeaderRowNo, 0, FieldCaption("Variety Group"), false, true, '', TempExcelBuf."Cell Type"::Text);
                    EnterCell(HeaderRowNo, 0, FieldCaption("Variety 1"), false, true, '', TempExcelBuf."Cell Type"::Text);
                    EnterCell(HeaderRowNo, 0, FieldCaption("Variety 2"), false, true, '', TempExcelBuf."Cell Type"::Text);
                    EnterCell(HeaderRowNo, 0, FieldCaption("Variety 3"), false, true, '', TempExcelBuf."Cell Type"::Text);
                    EnterCell(HeaderRowNo, 0, FieldCaption("Variety 4"), false, true, '', TempExcelBuf."Cell Type"::Text);
                    EnterCell(HeaderRowNo, 0, FieldCaption("Recommended Retail Price"), false, true, '', TempExcelBuf."Cell Type"::Text);
                    EnterCell(HeaderRowNo, 0, FieldCaption("Vendors Bar Code"), false, true, '', TempExcelBuf."Cell Type"::Text);
                    EnterCell(HeaderRowNo, 0, FieldCaption("Internal Bar Code"), false, true, '', TempExcelBuf."Cell Type"::Text);
                    EnterCell(HeaderRowNo, 0, FieldCaption("Net Weight"), false, true, '', TempExcelBuf."Cell Type"::Text);
                    EnterCell(HeaderRowNo, 0, FieldCaption("Gross Weight"), false, true, '', TempExcelBuf."Cell Type"::Text);
# pragma warning restore
                    NPRAttrManagement.GetAttributeVisibility(DATABASE::"NPR Item Worksheet Line", NPRAttrVisibleArray);
                    i := 1;
                    if NPRAttrVisibleArray[1] then
                        repeat
                            NPRAttributeID.Reset();
                            NPRAttributeID.SetRange("Table ID", DATABASE::"NPR Item Worksheet Line");
                            NPRAttributeID.SetRange("Shortcut Attribute ID", i);
                            if NPRAttributeID.FindFirst() then
                                EnterCell(HeaderRowNo, 0, NPRAttributeID."Attribute Code", false, true, '', TempExcelBuf."Cell Type"::Text)
                            else
                                EnterCell(HeaderRowNo, 0, StrSubstNo(AttributeLbl, i), false, true, '', TempExcelBuf."Cell Type"::Text);
                            i := i + 1;
                        until not NPRAttrVisibleArray[i];
                end;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                }
            }
        }

    }


    var
        TempExcelBuf: Record "Excel Buffer" temporary;
        NPRAttributeID: Record "NPR Attribute ID";
        ItemWorksheetExcelColumn: Record "NPR Item Worksh. Excel Column";
        ItemWorksheetTemplate: Record "NPR Item Worksh. Template";
        ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line";
        ItemWorksheet: Record "NPR Item Worksheet";
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        ItemWshtImpExpMgt: Codeunit "NPR Item Wsht. Imp. Exp.";
        MappingFound: Boolean;
        NPRAttrVisibleArray: array[40] of Boolean;
        Window: Dialog;
        HeaderRowNo: Integer;
        i: Integer;
        NextColumNo: Integer;
        RecNo: Integer;
        RowNo: Integer;
        TotalRecNo: Integer;
        AnalyzingDataLbl: Label 'Analyzing Data...\\';
        AttributeLbl: Label 'Attribute %1.', Comment = '%1 = Attribute';
        TextItemWorksheetLbl: Label 'Worksheet';
        ExportErr: Label 'You can only export one item worksheet at a time.';
        Pct1Lbl: Label '%1 %2', locked = true;
        Pct2Lbl: Label '%1-%2', locked = true;
        NPRAttrTextArray: array[40] of Text;

    local procedure EnterCell(RowNo: Integer; ColumnNo: Integer; CellValue: Text[250]; Bold: Boolean; UnderLine: Boolean; NumberFormat: Text[30]; CellType: Option)
    begin
        if ColumnNo = 0 then
            ColumnNo := NextColumNo;
        TempExcelBuf.Init();
        TempExcelBuf.Validate("Row No.", RowNo);
        TempExcelBuf.Validate("Column No.", ColumnNo);
        TempExcelBuf."Cell Value as Text" := CellValue;
        TempExcelBuf.Formula := '';
        TempExcelBuf.Bold := Bold;
        TempExcelBuf.Underline := UnderLine;
        TempExcelBuf.NumberFormat := NumberFormat;
        TempExcelBuf."Cell Type" := CellType;
        TempExcelBuf.Insert();
        NextColumNo := ColumnNo + 1;
    end;

    local procedure MapAllColumns(RowNo: Integer; TableNo: Integer; Bold: Boolean; UnderLine: Boolean; NumberFormat: Text[30])
    var
        RecField: Record "Field";
        RecRef: RecordRef;
        FldRef: FieldRef;
        CellType: Option;
    begin
        ItemWorksheetExcelColumn.Reset();
        ItemWorksheetExcelColumn.SetRange("Process as", ItemWorksheetExcelColumn."Process as"::Item, ItemWorksheetExcelColumn."Process as"::"Item Variant");
        ItemWorksheetExcelColumn.SetRange("Worksheet Template Name", "Item Worksheet Line"."Worksheet Template Name");
        ItemWorksheetExcelColumn.SetRange("Worksheet Name", "Item Worksheet Line"."Worksheet Name");
        ItemWorksheetExcelColumn.SetRange("Map to Table No.", TableNo);
        if ItemWorksheetExcelColumn.FindFirst() then
            repeat
                if not TempExcelBuf.Get(RowNo, ItemWorksheetExcelColumn."Excel Column No.") then begin
                    if RecField.Get(ItemWorksheetExcelColumn."Map to Table No.", ItemWorksheetExcelColumn."Map to Field Number") then begin
                        case RecField.TableNo of
                            DATABASE::"NPR Item Worksheet Line":
                                begin
                                    RecRef.Get("Item Worksheet Line".RecordId);
                                    FldRef := RecRef.Field(RecField."No.");
                                    case UpperCase(Format(FldRef.Type)) of
                                        'INTEGER', 'DECIMAL':
                                            CellType := 0;
                                        'TEXT', 'CODE', 'OPTION', 'DATETIME', 'BOOLEAN', 'DATEFORMULA':
                                            CellType := 1;
                                        'DATE':
                                            CellType := 2;
                                        'TIME':
                                            CellType := 3;
                                    end;
                                    EnterCell(RowNo, ItemWorksheetExcelColumn."Excel Column No.", Format(FldRef.Value), Bold, UnderLine, NumberFormat, CellType);
                                end;
                        end;
                    end;
                end;
            until ItemWorksheetExcelColumn.Next() = 0;
    end;

    local procedure MapCell(RowNo: Integer; TableNo: Integer; Field_No: Integer; CellValue: Text[250]; Bold: Boolean; UnderLine: Boolean; NumberFormat: Text[30]; CellType: Option)
    begin
        ItemWorksheetExcelColumn.Reset();
        ItemWorksheetExcelColumn.SetRange("Process as", ItemWorksheetExcelColumn."Process as"::Item, ItemWorksheetExcelColumn."Process as"::"Item Variant");
        ItemWorksheetExcelColumn.SetRange("Worksheet Template Name", "Item Worksheet Line"."Worksheet Template Name");
        ItemWorksheetExcelColumn.SetRange("Worksheet Name", "Item Worksheet Line"."Worksheet Name");
        ItemWorksheetExcelColumn.SetRange("Map to Table No.", TableNo);
        ItemWorksheetExcelColumn.SetRange("Map to Field Number", Field_No);
        if ItemWorksheetExcelColumn.FindFirst() then
            EnterCell(RowNo, ItemWorksheetExcelColumn."Excel Column No.", CellValue, Bold, UnderLine, NumberFormat, CellType);
    end;

    local procedure MapAttributeCells(RowNo: Integer; TableNo: Integer; Bold: Boolean; UnderLine: Boolean; NumberFormat: Text[30]; CellType: Option)
    var
        Attribute: Record "NPR Attribute";
        AttributeKey: Record "NPR Attribute Key";
        AttributeValueSet: Record "NPR Attribute Value Set";
    begin
        ItemWorksheetExcelColumn.Reset();
        ItemWorksheetExcelColumn.SetRange("Worksheet Template Name", "Item Worksheet Line"."Worksheet Template Name");
        ItemWorksheetExcelColumn.SetRange("Worksheet Name", "Item Worksheet Line"."Worksheet Name");
        ItemWorksheetExcelColumn.SetRange("Process as", ItemWorksheetExcelColumn."Process as"::"Item Attribute");
        ItemWorksheetExcelColumn.SetRange("Map to Table No.", TableNo);
        if ItemWorksheetExcelColumn.FindSet() then
            repeat
                AttributeKey.Reset();
                AttributeKey.SetCurrentKey("Table ID", "MDR Code PK");
                AttributeKey.SetFilter("Table ID", '=%1', TableNo);
                AttributeKey.SetFilter("MDR Code PK", '=%1', "Item Worksheet Line"."Worksheet Template Name");
                AttributeKey.SetFilter("MDR Code 2 PK", '=%1', "Item Worksheet Line"."Worksheet Name");
                AttributeKey.SetFilter("MDR Line PK", '=%1', "Item Worksheet Line"."Line No.");
                if (AttributeKey.FindFirst()) then begin
                    AttributeValueSet.SetFilter("Attribute Set ID", '=%1', AttributeKey."Attribute Set ID");
                    AttributeValueSet.SetFilter("Attribute Code", ItemWorksheetExcelColumn."Map to Attribute Code");
                    if (AttributeValueSet.FindFirst()) then begin
                        if (Attribute.Get(AttributeValueSet."Attribute Code")) then begin
                            EnterCell(RowNo, ItemWorksheetExcelColumn."Excel Column No.", NPRAttrManagement.GetTextValue(Attribute, AttributeValueSet), Bold, UnderLine, NumberFormat, CellType);
                        end;
                    end;
                end;
            until ItemWorksheetExcelColumn.Next() = 0;
    end;
}

