report 6060044 "NPR Map Excel Item Worksh."
{
    // NPR5.22\BR\20160321  CASE 182391 Object Created
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to object

    UsageCategory = None;
    Caption = 'Map Excel Item Worksheet';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Item Worksheet"; "NPR Item Worksheet")
        {
            DataItemTableView = SORTING("Item Template Name", Name) ORDER(Ascending);

            trigger OnAfterGetRecord()
            begin
                "Excel Import from Line No." := HeaderRow + 1;
                Modify;
            end;

            trigger OnPostDataItem()
            begin
                AnalyzeData;
            end;

            trigger OnPreDataItem()
            begin
                if Count > 1 then
                    Error(Text100);
                if HeaderRow = 0 then
                    Error(Text101);
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
                field("Header Row"; HeaderRow)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the HeaderRow field';
                }
                field("Try to match fields automatically"; BoolTryMatch)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the BoolTryMatch field';
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        var
            LocItemWorksheet: Record "NPR Item Worksheet";
        begin
            BoolTryMatch := true;
            LocItemWorksheet.CopyFilters("Item Worksheet");
            if LocItemWorksheet.FindFirst then
                if LocItemWorksheet."Excel Import from Line No." > 1 then
                    HeaderRow := LocItemWorksheet."Excel Import from Line No." - 1;
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        var
            FileMgt: Codeunit "File Management";
        begin
            if CloseAction = ACTION::OK then begin
                ServerFileName := FileMgt.UploadFile(Text006, ExcelFileExtensionTok);
                if ServerFileName = '' then
                    exit(false);

                SheetName := ExcelBuf.SelectSheetsName(ServerFileName);
                if SheetName = '' then
                    exit(false);
            end;
        end;
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        ExcelBuf.DeleteAll;
    end;

    trigger OnPreReport()
    begin
        ExcelBuf.LockTable;
        ExcelBuf.OpenBook(ServerFileName, SheetName);
        ExcelBuf.ReadSheet;
    end;

    var
        ExcelBuf: Record "Excel Buffer";
        ExcelBuf2: Record "Excel Buffer";
        ServerFileName: Text;
        SheetName: Text[250];
        Text005: Label 'Imported from Excel ';
        Text006: Label 'Import Excel File';
        Text007: Label 'Analyzing Data...\\';
        ExcelFileExtensionTok: Label '.xlsx', Locked = true;
        Text100: Label 'Please start this import from the Item Worksheet Page.';
        ActionIfVariantUnknown: Option Skip,Create;
        ActionIfVarietyUnknown: Option Skip,Create;
        FirstLine: Integer;
        Text101: Label 'Please indicate the Header Row';
        HeaderRow: Integer;
        BoolTryMatch: Boolean;

    local procedure AnalyzeData()
    var
        ItemWorksheetExcelColumn: Record "NPR Item Worksh. Excel Column";
        RecField: Record "Field";
    begin
        ExcelBuf.Reset;
        ExcelBuf.SetRange("Column No.");
        ExcelBuf.SetRange("Row No.", HeaderRow);

        if ExcelBuf.FindFirst then begin
            repeat
                if not ItemWorksheetExcelColumn.Get("Item Worksheet"."Item Template Name", "Item Worksheet".Name, ExcelBuf."Column No.") then begin
                    ItemWorksheetExcelColumn.Init;
                    ItemWorksheetExcelColumn.Validate("Worksheet Template Name", "Item Worksheet"."Item Template Name");
                    ItemWorksheetExcelColumn.Validate("Worksheet Name", "Item Worksheet".Name);
                    ItemWorksheetExcelColumn.Validate("Excel Column No.", ExcelBuf."Column No.");
                    ItemWorksheetExcelColumn.Insert(true);
                end;
                ItemWorksheetExcelColumn.Validate("Excel Header Text", ExcelBuf."Cell Value as Text");
                if ExcelBuf2.Get(ExcelBuf."Row No." + 1, ExcelBuf."Column No.") then
                    ItemWorksheetExcelColumn.Validate("Sample Data Row 1", ExcelBuf2."Cell Value as Text");
                if ExcelBuf2.Get(ExcelBuf."Row No." + 2, ExcelBuf."Column No.") then
                    ItemWorksheetExcelColumn.Validate("Sample Data Row 2", ExcelBuf2."Cell Value as Text");
                if ExcelBuf2.Get(ExcelBuf."Row No." + 3, ExcelBuf."Column No.") then
                    ItemWorksheetExcelColumn.Validate("Sample Data Row 3", ExcelBuf2."Cell Value as Text");
                if BoolTryMatch and (ItemWorksheetExcelColumn."Map to Field Number" = 0) then begin
                    RecField.Reset;
                    RecField.SetRange(TableNo, DATABASE::"NPR Item Worksheet Line");
                    RecField.SetFilter(FieldName, '%1', ItemWorksheetExcelColumn."Excel Header Text");
                    if RecField.FindFirst then begin
                        ItemWorksheetExcelColumn.Validate(ItemWorksheetExcelColumn."Process as", ItemWorksheetExcelColumn."Process as"::Item);
                        ItemWorksheetExcelColumn.Validate(ItemWorksheetExcelColumn."Map to Field Number", RecField."No.");
                    end;
                    if ItemWorksheetExcelColumn."Map to Field Number" = 0 then begin
                        RecField.SetRange(FieldName);
                        RecField.SetFilter("Field Caption", '%1', ItemWorksheetExcelColumn."Excel Header Text");
                        if RecField.FindFirst then begin
                            ItemWorksheetExcelColumn.Validate(ItemWorksheetExcelColumn."Process as", ItemWorksheetExcelColumn."Process as"::Item);
                            ItemWorksheetExcelColumn.Validate(ItemWorksheetExcelColumn."Map to Field Number", RecField."No.");
                        end;
                    end;
                    if ItemWorksheetExcelColumn."Map to Field Number" = 0 then begin
                        RecField.SetRange(TableNo, DATABASE::"NPR Item Worksh. Variant Line");
                        RecField.SetFilter(FieldName, '%1', ItemWorksheetExcelColumn."Excel Header Text");
                        RecField.SetRange("Field Caption");
                        if RecField.FindFirst then begin
                            ItemWorksheetExcelColumn.Validate(ItemWorksheetExcelColumn."Process as", ItemWorksheetExcelColumn."Process as"::"Item Variant");
                            ItemWorksheetExcelColumn.Validate(ItemWorksheetExcelColumn."Map to Field Number", RecField."No.");
                        end;
                    end;
                    if ItemWorksheetExcelColumn."Map to Field Number" = 0 then begin
                        RecField.SetRange(FieldName);
                        RecField.SetFilter("Field Caption", '%1', ItemWorksheetExcelColumn."Excel Header Text");
                        if RecField.FindFirst then begin
                            ItemWorksheetExcelColumn.Validate(ItemWorksheetExcelColumn."Process as", ItemWorksheetExcelColumn."Process as"::"Item Variant");
                            ItemWorksheetExcelColumn.Validate(ItemWorksheetExcelColumn."Map to Field Number", RecField."No.");
                        end;
                    end;
                end;
                ItemWorksheetExcelColumn.Modify(true);
            until ExcelBuf.Next = 0;
        end;
    end;

    local procedure FormatData(TextToFormat: Text[250]): Text[250]
    var
        FormatInteger: Integer;
        FormatDecimal: Decimal;
        FormatDate: Date;
    begin
        case true of
            Evaluate(FormatInteger, TextToFormat):
                exit(Format(FormatInteger));
            Evaluate(FormatDecimal, TextToFormat):
                exit(Format(FormatDecimal));
            Evaluate(FormatDate, TextToFormat):
                exit(Format(FormatDate));
            else
                exit(TextToFormat);
        end;
    end;
}

