report 6060042 "NPR Import Excel Item Worksh."
{
    Caption = 'Import Excel Item Worksheet';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    dataset
    {
        dataitem("Item Worksheet"; "NPR Item Worksheet")
        {
            DataItemTableView = SORTING("Item Template Name", Name) ORDER(Ascending);

            trigger OnPostDataItem()
            begin
                ItemWorksheetLine.Reset();
                ItemWorksheetLine.SetRange("Worksheet Template Name", "Item Worksheet"."Item Template Name");
                ItemWorksheetLine.SetRange("Worksheet Name", "Item Worksheet".Name);
                if ItemWorksheetLine.FindLast() then
                    LastItemWorksheetLine := ItemWorksheetLine
                else
                    LastItemWorksheetLine.Init();
                LineNo := 0;
                case ImportOption of
                    ImportOption::"Replace lines":
                        begin
                            ItemWorksheetLine.Reset();
                            ItemWorksheetLine.SetRange("Worksheet Template Name", "Item Worksheet"."Item Template Name");
                            ItemWorksheetLine.SetRange("Worksheet Name", "Item Worksheet".Name);
                            ItemWorksheetLine.DeleteAll(true);
                        end;
                    ImportOption::"Add lines":
                        begin
                            ItemWorksheetLine.Reset();
                            ItemWorksheetLine.SetRange("Worksheet Template Name", "Item Worksheet"."Item Template Name");
                            ItemWorksheetLine.SetRange("Worksheet Name", "Item Worksheet".Name);
                            if ItemWorksheetLine.FindLast() then
                                LineNo := ItemWorksheetLine."Line No.";
                        end;
                end;

                FirstLine := LineNo + 10000;

                AnalyzeData();
                if CombineVarieties then
                    ItemWorksheetMgt.CombineLines("Item Worksheet");
            end;

            trigger OnPreDataItem()
            begin
                if Count > 1 then
                    Error(ImportErr);
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
                field("Import Option"; ImportOption)
                {
                    Caption = 'Option';
                    OptionCaption = 'Replace lines,Add lines';

                    ToolTip = 'Specifies the value of the Option field';
                    ApplicationArea = NPRRetail;
                }
                field("Set Items To Skip"; SetItemsToSkip)
                {
                    Caption = 'Set all items to SKIP';

                    ToolTip = 'Specifies the value of the Set all items to SKIP field';
                    ApplicationArea = NPRRetail;
                }
                field("Action If Variant Unknown"; ActionIfVariantUnknown)
                {
                    Caption = 'If the Variant does not exist, but the Variety does';
                    OptionCaption = 'Set Variety Worksheet Line to <Skip>,Set Variety Worksheet Line to <Create>';

                    ToolTip = 'Specifies the value of the If the Variant does not exist, but the Variety does field';
                    ApplicationArea = NPRRetail;
                }
                field("Action If Variety Unknown"; ActionIfVarietyUnknown)
                {
                    Caption = 'If the Variant and Variety do not exist';
                    OptionCaption = 'Set Variety Worksheet Line to <Skip>,Set Variety Worksheet Line to <Create>';

                    ToolTip = 'Specifies the value of the If the Variant and Variety do not exist field';
                    ApplicationArea = NPRRetail;
                }
                field("Combine Varieties"; CombineVarieties)
                {
                    Caption = 'Combine Varieties';
                    ToolTip = 'Automatically try to combine all imported lines to item/variety combinations after import.';
                    ApplicationArea = NPRRetail;

                }
            }
        }

        trigger OnOpenPage()
        begin
            CombineVarieties := true;
            ImportOption := ImportOption::"Add lines";
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        var
            UploadResult: Boolean;
            InStream: InStream;
            ImportFileLbl: Label 'Import Excel File';
            ExcelFileExtensionTok: Label 'Excel File (.xlsx)|*.xlsx', Locked = true;
        begin
            if CloseAction = ACTION::OK then begin
                UploadResult := UploadIntoStream(ImportFileLbl, '', ExcelFileExtensionTok, ServerFileName, InStream);
                if not UploadResult then
                    exit(false);
                if ServerFileName = '' then
                    exit(false);

                SheetName := ExcelBuf.SelectSheetsName(ServerFileName);
                if SheetName = '' then
                    exit(false);
            end;
        end;
    }

    trigger OnPostReport()
    begin
        ExcelBuf.DeleteAll();
    end;

    trigger OnPreReport()
    begin
        GLSetup.Get();
        ExcelBuf.LockTable();
        ExcelBuf.OpenBook(ServerFileName, SheetName);
        ExcelBuf.ReadSheet();
    end;

    var
        ExcelBuf: Record "Excel Buffer";
        ExcelBuf2: Record "Excel Buffer";
        RecField: Record "Field";
        GLSetup: Record "General Ledger Setup";
        ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line";
        ItemWorksheetLine: Record "NPR Item Worksheet Line";
        LastItemWorksheetLine: Record "NPR Item Worksheet Line";
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        ItemWorksheetMgt: Codeunit "NPR Item Worksheet Mgt.";
        ItemWshtImpExpMgt: Codeunit "NPR Item Wsht. Imp. Exp.";
        CombineVarieties: Boolean;
        SetItemsToSkip: Boolean;
        Window: Dialog;
        FirstLine: Integer;
        LastRow: Integer;
        LineNo: Integer;
        RecNo: Integer;
        TotalRecNo: Integer;
        AnalyzingDataLbl: Label 'Analyzing Data...\\';
        ImportErr: Label 'Please start this import from the Item Worksheet Page.';
        SkipWarningMsg: Label 'Warning: %1 of the imported Variety lines are set to Skip. Please change the Action on the Variety line to process the changes.';
        ImportOption: Option "Replace lines","Add lines";
        ActionIfVariantUnknown: Option Skip,Create;
        ActionIfVarietyUnknown: Option Skip,Create;
        ExcludeColumnsFilter: Text;
        ServerFileName: Text;
        SheetName: Text[250];

    local procedure AnalyzeData()
    var
        BudgetBuf: Record "Budget Buffer";
        TempExcelBuf: Record "Excel Buffer" temporary;
        ItemWorksheetExcelColumn: Record "NPR Item Worksh. Excel Column";
        MappingFound: Boolean;
        TempDate: Date;
        TempDec: Decimal;
        AttributeNo: Integer;
        FieldLength: Integer;
        MappedColumnNo: Integer;
    begin
        Window.Open(
         AnalyzingDataLbl +
          '@1@@@@@@@@@@@@@@@@@@@@@@@@@\');
        Window.Update(1, 0);
        ExcelBuf.SetRange("Row No.", 2, 999999);
        TotalRecNo := ExcelBuf.Count();
        RecNo := 0;
        BudgetBuf.DeleteAll();

        ExcelBuf.SetRange("Column No.");
        if ExcelBuf.FindFirst() then begin
            repeat
                RecNo := RecNo + 1;
                if ExcelBuf."Row No." <> LastRow then begin
                    Window.Update(1, Round(RecNo / TotalRecNo * 10000, 1));
                    LineNo := LineNo + 10000;
                    ExcludeColumnsFilter := '';
                    ItemWorksheetLine.Init();
                    ItemWorksheetLine.Validate("Worksheet Template Name", "Item Worksheet"."Item Template Name");
                    ItemWorksheetLine.Validate("Worksheet Name", "Item Worksheet".Name);
                    ItemWorksheetLine.Validate("Line No.", LineNo);
                    ItemWorksheetLine.SetUpNewLine(LastItemWorksheetLine);
                    ItemWorksheetLine.Insert(true);
                    OnAfterCreateWorksheetLineFromExcel(ItemWorksheetLine, ExcelBuf);
                    if SetItemsToSkip then
                        ItemWorksheetLine.Action := ItemWorksheetLine.Action::Skip
                    else
                        ItemWorksheetLine.Action := ItemWorksheetLine.Action::CreateNew;
                    ItemWorksheetExcelColumn.Reset();
                    ItemWorksheetExcelColumn.SetRange("Worksheet Template Name", "Item Worksheet"."Item Template Name");
                    ItemWorksheetExcelColumn.SetRange("Worksheet Name", "Item Worksheet".Name);
                    ItemWorksheetExcelColumn.SetFilter("Process as", '<>%1', ItemWorksheetExcelColumn."Process as"::Skip);
                    MappingFound := ItemWorksheetExcelColumn.FindFirst();
                    if MappingFound then begin
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Item No."), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetLine.Validate("Item No.", CopyStr(AppendPrefix(ExcelBuf2."Cell Value as Text", ItemWorksheetLine), 1, FieldLength));
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Vendor No."), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetLine.Validate("Vendor No.", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Vendor Item No."), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetLine.Validate("Vendor Item No.", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo(Description), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetLine.Validate(Description, CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Direct Unit Cost"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                if Evaluate(TempDec, ExcelBuf2."Cell Value as Text") then
                                    ItemWorksheetLine.Validate("Direct Unit Cost", TempDec);
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Sales Price"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                if Evaluate(TempDec, ExcelBuf2."Cell Value as Text") then
                                    ItemWorksheetLine.Validate("Sales Price", TempDec);
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Sales Price Currency Code"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                if ExcelBuf2."Cell Value as Text" <> GLSetup."LCY Code" then
                                    ItemWorksheetLine.Validate("Sales Price Currency Code", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Purchase Price Currency Code"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                if ExcelBuf2."Cell Value as Text" <> GLSetup."LCY Code" then
                                    ItemWorksheetLine.Validate("Purchase Price Currency Code", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Sales Price Start Date"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                if Evaluate(TempDate, ExcelBuf2."Cell Value as Text") then
                                    ItemWorksheetLine.Validate("Sales Price Start Date", TempDate);
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Purchase Price Start Date"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                if Evaluate(TempDate, ExcelBuf2."Cell Value as Text") then
                                    ItemWorksheetLine.Validate("Purchase Price Start Date", TempDate);
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Tariff No."), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetLine.Validate("Tariff No.", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Variety Group"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetLine.Validate("Variety Group", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Item Category Code"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
# pragma warning disable AA0139
                                ItemWorksheetLine."Item Category Code" := CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength);
# pragma warning restore
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Product Group Code"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
# pragma warning disable AA0139
                                ItemWorksheetLine."Product Group Code" := CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength);
# pragma warning restore
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Recommended Retail Price"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                if Evaluate(TempDec, ExcelBuf2."Cell Value as Text") then
                                    ItemWorksheetLine.Validate("Recommended Retail Price", TempDec);
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Vendors Bar Code"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetLine.Validate("Vendors Bar Code", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Internal Bar Code"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetLine.Validate("Internal Bar Code", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Net Weight"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                if Evaluate(TempDec, ExcelBuf2."Cell Value as Text") then
                                    ItemWorksheetLine.Validate("Net Weight", TempDec);
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Gross Weight"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                if Evaluate(TempDec, ExcelBuf2."Cell Value as Text") then
                                    ItemWorksheetLine.Validate("Gross Weight", TempDec);
                        ItemWorksheetLine.Modify();
                        ProcessColumnMapping(DATABASE::"NPR Item Worksheet Line", '', ExcludeColumnsFilter);
                        ItemWorksheetLine.Get(ItemWorksheetLine."Worksheet Template Name", ItemWorksheetLine."Worksheet Name", ItemWorksheetLine."Line No.");
                        GetAttributeMapping();
                    end else begin
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 1) then
                            ItemWorksheetLine.Validate("Item No.", ExcelBuf2."Cell Value as Text");
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 5) then
                            ItemWorksheetLine.Validate("Vendor Item No.", ExcelBuf2."Cell Value as Text");
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 11) then
                            ItemWorksheetLine.Validate("Vendor No.", ExcelBuf2."Cell Value as Text");
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 2) then
                            ItemWorksheetLine.Validate(Description, ExcelBuf2."Cell Value as Text");
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 9) then
                            if Evaluate(TempDec, ExcelBuf2."Cell Value as Text") then
                                ItemWorksheetLine.Validate("Direct Unit Cost", TempDec);
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 7) then
                            if Evaluate(TempDec, ExcelBuf2."Cell Value as Text") then
                                ItemWorksheetLine.Validate("Sales Price", TempDec);
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 8) then
                            if ExcelBuf2."Cell Value as Text" <> GLSetup."LCY Code" then
                                ItemWorksheetLine.Validate("Sales Price Currency Code", ExcelBuf2."Cell Value as Text");
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 10) then
                            if ExcelBuf2."Cell Value as Text" <> GLSetup."LCY Code" then
                                ItemWorksheetLine.Validate("Purchase Price Currency Code", CopyStr(ExcelBuf2."Cell Value as Text", 1, 3));
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 6) then
                            ItemWorksheetLine.Validate("Tariff No.", ExcelBuf2."Cell Value as Text");
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 13) then
                            ItemWorksheetLine.Validate("Variety Group", ExcelBuf2."Cell Value as Text");
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 3) then
                            ItemWorksheetLine."Item Category Code" := CopyStr(ExcelBuf2."Cell Value as Text", 1, MaxStrLen(ItemWorksheetLine."Item Category Code"));
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 4) then
                            ItemWorksheetLine."Product Group Code" := CopyStr(ExcelBuf2."Cell Value as Text", 1, MaxStrLen(ItemWorksheetLine."Product Group Code"));
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 18) then
                            if Evaluate(TempDec, ExcelBuf2."Cell Value as Text") then
                                ItemWorksheetLine.Validate("Recommended Retail Price", TempDec);
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 19) then
                            ItemWorksheetLine.Validate("Vendors Bar Code", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 20) then
                            ItemWorksheetLine.Validate("Internal Bar Code", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 21) then
                            if Evaluate(TempDec, ExcelBuf2."Cell Value as Text") then
                                ItemWorksheetLine.Validate("Net Weight", TempDec);
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 22) then
                            if Evaluate(TempDec, ExcelBuf2."Cell Value as Text") then
                                ItemWorksheetLine.Validate("Gross Weight", TempDec);
                        AttributeNo := 1;
                        repeat
                            if ExcelBuf2.Get(ExcelBuf."Row No.", AttributeNo + 22) then begin
                                NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", AttributeNo,
                                   ItemWorksheetLine."Worksheet Template Name", ItemWorksheetLine."Worksheet Name", ItemWorksheetLine."Line No.", ExcelBuf2."Cell Value as Text");
                            end;
                            AttributeNo := AttributeNo + 1;
                        until AttributeNo = 19;
                    end;

                    ItemWshtImpExpMgt.SetImportActionWorksheetLine(ItemWorksheetLine);
                    if SetItemsToSkip then
                        ItemWorksheetLine.Validate(Action, ItemWorksheetLine.Action::Skip);
                    ItemWorksheetLine.Modify(true);
                    ItemWshtImpExpMgt.RaiseOnAfterImportWorksheetLine(ItemWorksheetLine);

                    ItemWorksheetVariantLine.Init();
                    ItemWorksheetVariantLine.Validate("Worksheet Template Name", ItemWorksheetLine."Worksheet Template Name");
                    ItemWorksheetVariantLine.Validate("Worksheet Name", ItemWorksheetLine."Worksheet Name");
                    ItemWorksheetVariantLine.Validate("Worksheet Line No.", ItemWorksheetLine."Line No.");
                    ItemWorksheetVariantLine.Validate("Line No.", 10000);
                    ItemWorksheetVariantLine.Insert(true);
                    if SetItemsToSkip then
                        ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action::Skip
                    else
                        ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action::CreateNew;
                    ItemWorksheetVariantLine.Validate("Item No.", ItemWorksheetLine."Item No.");
                    ItemWorksheetVariantLine.Validate("Sales Price", ItemWorksheetLine."Sales Price");
                    ItemWorksheetVariantLine.Validate("Direct Unit Cost", ItemWorksheetLine."Direct Unit Cost");
                    if MappingFound then begin
                        if GetColumnMapping(DATABASE::"NPR Item Worksh. Variant Line", ItemWorksheetVariantLine.FieldNo("Variety 1 Value"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
# pragma warning disable AA0139
                                ItemWorksheetVariantLine."Variety 1 Value" := CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength);
# pragma warning restore
                        if GetColumnMapping(DATABASE::"NPR Item Worksh. Variant Line", ItemWorksheetVariantLine.FieldNo("Variety 2 Value"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
# pragma warning disable AA0139
                                ItemWorksheetVariantLine."Variety 2 Value" := CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength);
# pragma warning restore
                        if GetColumnMapping(DATABASE::"NPR Item Worksh. Variant Line", ItemWorksheetVariantLine.FieldNo("Variety 3 Value"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
# pragma warning disable AA0139
                                ItemWorksheetVariantLine."Variety 3 Value" := CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength);
# pragma warning restore
                        if GetColumnMapping(DATABASE::"NPR Item Worksh. Variant Line", ItemWorksheetVariantLine.FieldNo("Variety 4 Value"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
# pragma warning disable AA0139
                                ItemWorksheetVariantLine."Variety 4 Value" := CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength);
# pragma warning restore
                        if GetColumnMapping(DATABASE::"NPR Item Worksh. Variant Line", ItemWorksheetVariantLine.FieldNo("Vendors Bar Code"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetVariantLine.Validate("Vendors Bar Code", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        if GetColumnMapping(DATABASE::"NPR Item Worksh. Variant Line", ItemWorksheetVariantLine.FieldNo("Internal Bar Code"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetVariantLine.Validate("Internal Bar Code", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                    end else begin
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 14) then
                            ItemWorksheetVariantLine."Variety 1 Value" := CopyStr(ExcelBuf2."Cell Value as Text", 1, MaxStrLen(ItemWorksheetVariantLine."Variety 1 Value"));
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 15) then
                            ItemWorksheetVariantLine."Variety 2 Value" := CopyStr(ExcelBuf2."Cell Value as Text", 1, MaxStrLen(ItemWorksheetVariantLine."Variety 2 Value"));
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 16) then
                            ItemWorksheetVariantLine."Variety 3 Value" := CopyStr(ExcelBuf2."Cell Value as Text", 1, MaxStrLen(ItemWorksheetVariantLine."Variety 3 Value"));
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 17) then
                            ItemWorksheetVariantLine."Variety 4 Value" := CopyStr(ExcelBuf2."Cell Value as Text", 1, MaxStrLen(ItemWorksheetVariantLine."Variety 4 Value"));
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 19) then
                            ItemWorksheetVariantLine.Validate("Vendors Bar Code", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 20) then
                            ItemWorksheetVariantLine.Validate("Internal Bar Code", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                    end;
                    ItemWorksheetVariantLine.Validate("Existing Item No.", ItemWorksheetLine."Existing Item No.");
                    ItemWorksheetVariantLine.Validate("Variety 1 Value");
                    ItemWorksheetVariantLine.Validate("Variety 2 Value");
                    ItemWorksheetVariantLine.Validate("Variety 3 Value");
                    ItemWorksheetVariantLine.Validate("Variety 4 Value");

                    ItemWshtImpExpMgt.SetImportActionWorksheetVariantLine(ItemWorksheetLine, ActionIfVariantUnknown, ActionIfVarietyUnknown, ItemWorksheetVariantLine);
                    if SetItemsToSkip then
                        ItemWorksheetVariantLine.Validate(Action, ItemWorksheetVariantLine.Action::Skip);
                    ItemWorksheetVariantLine.Modify(true);
                    ItemWshtImpExpMgt.RaiseOnAfterImportWorksheetVariantLine(ItemWorksheetVariantLine);
                end;
                LastRow := ExcelBuf."Row No.";
            until ExcelBuf.Next() = 0;
        end;

        Window.Close();
        TempExcelBuf.Reset();

        ItemWorksheetVariantLine.Reset();
        ItemWorksheetVariantLine.SetRange("Worksheet Template Name", "Item Worksheet"."Item Template Name");
        ItemWorksheetVariantLine.SetRange("Worksheet Name", "Item Worksheet".Name);
        ItemWorksheetVariantLine.SetRange("Worksheet Line No.", FirstLine, LineNo);
        ItemWorksheetVariantLine.SetRange(Action, ItemWorksheetVariantLine.Action::Skip);
        if (ItemWorksheetVariantLine.Count() > 0) then begin
            Message(SkipWarningMsg, ItemWorksheetVariantLine.Count());
        end;
    end;

    local procedure ProcessColumnMapping(ParTableNo: Integer; ParFieldNoFilter: Text; ParColumnsFilter: Text): Boolean
    var
        ItemWorksheetExcelColumn: Record "NPR Item Worksh. Excel Column";
        RecRef: RecordRef;
        FldRef: FieldRef;
        I: Integer;
        TxtOption: Text;
    begin
        ItemWorksheetExcelColumn.Reset();
        ItemWorksheetExcelColumn.SetCurrentKey("Worksheet Template Name", "Worksheet Name", "Map to Table No.", "Map to Field Number");
        ItemWorksheetExcelColumn.SetRange("Worksheet Template Name", "Item Worksheet"."Item Template Name");
        ItemWorksheetExcelColumn.SetRange("Worksheet Name", "Item Worksheet".Name);
        if ParColumnsFilter <> '' then
            ItemWorksheetExcelColumn.SetFilter("Excel Column No.", ParColumnsFilter);
        if ParTableNo <> 0 then
            ItemWorksheetExcelColumn.SetRange("Map to Table No.", ParTableNo);
        if ParFieldNoFilter <> '' then
            ItemWorksheetExcelColumn.SetFilter("Map to Field Number", ParFieldNoFilter);
        if ItemWorksheetExcelColumn.FindSet() then
            repeat
                if ExcelBuf2.Get(ExcelBuf."Row No.", ItemWorksheetExcelColumn."Excel Column No.") then
                    if RecField.Get(ItemWorksheetExcelColumn."Map to Table No.", ItemWorksheetExcelColumn."Map to Field Number") then begin
                        case RecField.TableNo of
                            DATABASE::"NPR Item Worksheet Line":
                                begin
                                    RecRef.Get(ItemWorksheetLine.RecordId);
                                    FldRef := RecRef.Field(RecField."No.");
                                    if UpperCase(Format(FldRef.Type)) = 'OPTION' then begin
                                        TxtOption := '';
                                        if StrPos(UpperCase(FldRef.OptionCaption), UpperCase(ExcelBuf2."Cell Value as Text")) > 0 then
                                            TxtOption := UpperCase(FldRef.OptionCaption)
                                        else
                                            if StrPos(UpperCase(FldRef.OptionMembers), UpperCase(ExcelBuf2."Cell Value as Text")) > 0 then
                                                TxtOption := UpperCase(FldRef.OptionMembers);
                                        if TxtOption <> '' then begin
                                            //Option as Text
                                            if TxtOption[1] = ',' then
                                                I := 2
                                            else
                                                I := 1;
                                            while StrPos(SelectStr(I, TxtOption), UpperCase(ExcelBuf2."Cell Value as Text")) = 0 do
                                                I += 1;
                                            I := I - 1;
                                        end else begin
                                            //Option as Integer
                                            if not Evaluate(I, ExcelBuf2."Cell Value as Text") then
                                                I := 0;
                                        end;
                                        FldRef.Value(I);
                                    end else
                                        ValidateFieldRef(ExcelBuf2."Cell Value as Text", false, FldRef);
                                    RecRef.Modify();
                                end;
                        end;
                    end;
            until ItemWorksheetExcelColumn.Next() = 0;
    end;

    local procedure GetColumnMapping(ParTableNo: Integer; ParFieldNo: Integer; var VarMappedColumnNo: Integer; var VarLength: Integer): Boolean
    var
        ItemWorksheetExcelColumn: Record "NPR Item Worksh. Excel Column";
    begin
        ItemWorksheetExcelColumn.Reset();
        ItemWorksheetExcelColumn.SetCurrentKey("Worksheet Template Name", "Worksheet Name", "Map to Table No.", "Map to Field Number");
        ItemWorksheetExcelColumn.SetRange("Worksheet Template Name", "Item Worksheet"."Item Template Name");
        ItemWorksheetExcelColumn.SetRange("Worksheet Name", "Item Worksheet".Name);
        ItemWorksheetExcelColumn.SetRange("Map to Table No.", ParTableNo);
        ItemWorksheetExcelColumn.SetRange("Map to Field Number", ParFieldNo);
        if ItemWorksheetExcelColumn.FindFirst() then begin
            VarMappedColumnNo := ItemWorksheetExcelColumn."Excel Column No.";
            RecField.Get(ParTableNo, ParFieldNo);
            VarLength := RecField.Len;
            if ExcludeColumnsFilter = '' then
                ExcludeColumnsFilter := '<>' + Format(VarMappedColumnNo)
            else
                ExcludeColumnsFilter := ExcludeColumnsFilter + '&<>' + Format(VarMappedColumnNo);
            exit(true);
        end else
            exit(false);
    end;

    local procedure GetAttributeMapping(): Boolean
    var
        AttributeID: Record "NPR Attribute ID";
        ItemWorksheetExcelColumn: Record "NPR Item Worksh. Excel Column";
    begin
        ItemWorksheetExcelColumn.Reset();
        ItemWorksheetExcelColumn.SetRange("Worksheet Template Name", "Item Worksheet"."Item Template Name");
        ItemWorksheetExcelColumn.SetRange("Worksheet Name", "Item Worksheet".Name);
        ItemWorksheetExcelColumn.SetRange("Process as", ItemWorksheetExcelColumn."Process as"::"Item Attribute");
        if ItemWorksheetExcelColumn.FindSet() then
            repeat
                if ExcelBuf2.Get(ExcelBuf."Row No.", ItemWorksheetExcelColumn."Excel Column No.") then begin
                    AttributeID.Reset();
                    AttributeID.SetRange("Table ID", ItemWorksheetExcelColumn."Map to Table No.");
                    AttributeID.SetRange("Attribute Code", ItemWorksheetExcelColumn."Map to Attribute Code");
                    if AttributeID.FindFirst() then begin
                        NPRAttrManagement.SetWorksheetLineAttributeValue(ItemWorksheetExcelColumn."Map to Table No.", AttributeID."Shortcut Attribute ID",
                             ItemWorksheetLine."Worksheet Template Name", ItemWorksheetLine."Worksheet Name", ItemWorksheetLine."Line No.", ExcelBuf2."Cell Value as Text");
                    end;
                end;
            until ItemWorksheetExcelColumn.Next() = 0;
    end;

    local procedure ValidateFieldRef(TextValue: Text; ValidateField: Boolean; var FldRef: FieldRef): Boolean
    var
        TmpDateFormula: DateFormula;
        TmpBool: Boolean;
        TmpDate: Date;
        TmpDateTime: DateTime;
        TmpDecimal: Decimal;
        TmpInteger: Integer;
        TmpTime: Time;
    begin
        case UpperCase(Format(FldRef.Type)) of
            'TEXT', 'CODE':
                if ValidateField then
                    FldRef.Validate(TextValue)
                else
                    FldRef.Value(TextValue);
            'INTEGER', 'OPTION':
                if Evaluate(TmpInteger, TextValue) then begin
                    if ValidateField then
                        FldRef.Validate(TmpInteger)
                    else
                        FldRef.Value(TmpInteger);
                end else
                    exit(false);
            'DECIMAL':
                if Evaluate(TmpDecimal, TextValue) then begin
                    if ValidateField then
                        FldRef.Validate(TmpDecimal)
                    else
                        FldRef.Value(TmpDecimal);
                end else
                    exit(false);
            'DATE':
                if Evaluate(TmpDate, TextValue) then begin
                    if ValidateField then
                        FldRef.Validate(TmpDate)
                    else
                        FldRef.Value(TmpDate);
                end else
                    exit(false);
            'TIME':
                if Evaluate(TmpTime, TextValue) then begin
                    if ValidateField then
                        FldRef.Validate(TmpTime)
                    else
                        FldRef.Value(TmpTime);
                end else
                    exit(false);
            'DATETIME':
                if Evaluate(TmpDateTime, TextValue) then begin
                    if ValidateField then
                        FldRef.Validate(TmpDateTime)
                    else
                        FldRef.Value(TmpDateTime);
                end else
                    exit(false);
            'BOOLEAN':
                if Evaluate(TmpBool, TextValue) then begin
                    if ValidateField then
                        FldRef.Validate(TmpBool)
                    else
                        FldRef.Value(TmpBool);
                end else
                    exit(false);
            'DATEFORMULA':
                if Evaluate(TmpDateFormula, TextValue) then begin
                    if ValidateField then
                        FldRef.Validate(TmpDateFormula)
                    else
                        FldRef.Value(TmpDateFormula);
                end else
                    exit(false);
        end;
        exit(true);
    end;

    local procedure AppendPrefix(ItemNoIn: Text; ItemWorksheetLineIn: Record "NPR Item Worksheet Line"): Text
    var
        ItemWorksheetTemplate2: Record "NPR Item Worksh. Template";
        ItemWorksheet2: Record "NPR Item Worksheet";
        PrefixCode: Text;
    begin
        PrefixCode := '';
        if not ItemWorksheetTemplate2.Get(ItemWorksheetLineIn."Worksheet Template Name") then
            exit(ItemNoIn);
        if not (ItemWorksheetTemplate2."Item No. Creation by" = ItemWorksheetTemplate2."Item No. Creation by"::Manually) then
            exit(ItemNoIn);
        case ItemWorksheetTemplate2."Item No. Prefix" of
            ItemWorksheetTemplate2."Item No. Prefix"::None:
                exit(ItemNoIn);
            ItemWorksheetTemplate2."Item No. Prefix"::"From Template":
                PrefixCode := ItemWorksheetTemplate2."Prefix Code";
            ItemWorksheetTemplate2."Item No. Prefix"::"Vendor No.":
                PrefixCode := ItemWorksheetLineIn."Vendor No.";
            ItemWorksheetTemplate2."Item No. Prefix"::"From Worksheet":
                if ItemWorksheet2.Get(ItemWorksheetLineIn."Worksheet Template Name", ItemWorksheetLineIn."Worksheet Name") then
                    PrefixCode := ItemWorksheet2."Prefix Code";
        end;
        if PrefixCode = '' then
            exit(ItemNoIn);
        exit(PrefixCode + '-' + ItemNoIn);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateWorksheetLineFromExcel(var ItemWorksheetLine: Record "NPR Item Worksheet Line"; var ExcelBuffer: Record "Excel Buffer")
    begin
    end;
}

