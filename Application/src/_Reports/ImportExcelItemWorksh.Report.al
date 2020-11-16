report 6060042 "NPR Import Excel Item Worksh."
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created
    // NPR4.19\BR\20160216  CASE 182391 Added extra import fields and changed order of columns
    // NPR5.22\BR\20160316  CASE 182391 Added option to Skip varieties that do not exist on current item
    // NPR5.22\BR\20160316  CASE 182391 Added Support for mapping Excel file
    // NPR5.22\BR\20160316  CASE 182391 Added Recommended Retail Price
    // NPR5.22\BR\20160324  CASE 182391 Added Support for Attributes
    // NPR5.22\BR\20160418  CASE 182391 Fix not importing anything if column A is empty.
    // NPR5.23\BR\20160524  CASE 242329 Added Support for Vendor Barcode and Internal BarCode
    // NPR5.23\BR\20160525  CASE 242498 Added field Net Weight and Gross Weight
    // NPR5.23\BR\20160525  CASE 242498 Call Event Publisher OnAfterImportWorksheet(Variant)Line
    // NPR5.23\BR\20160525  CASE 242498 Changed Combinelines setup to Item Worksheet Template
    // NPR5.23\BR\20160530  CASE 242498 Fix divide by zero for reading sheets with nothing in column 1
    // NPR5.25\BR \20160704 CASE 246088 Added many extra fileds from the Item Table, bugfixed variety 3 mapping
    // NPR5.26\BR \20160830 CASE 250586 Fix for importing <blank> option values and  datetimes
    // NPR5.28\BR\20161123  CASE 259200 Restruture Events to avoid memory leak + fix progress bar
    // 278205\OSFI\20170602 CASE 278205 Check if Item Categories are missing.
    // NPR5.33/ANEN/20170427 CASE 273989 Extending to 40 attributes
    // NPR5.35/BR  /20170815 CASE 268786 Added option to skip items.
    // NPR5.36/BR  /20170920 CASE 268786 Set Default to Add instead of Replace
    // NPR5.36/BR  /20170920 CASE 268786 Added Prefix option when set to "Manual" item no.s' in combination with "Prefix"
    // NPR5.38/BR  /20171124 CASE 278205 Remove Check If Item Categories are missing, removed function CheckItemCategories
    // NPR5.38/BR  /20171124 CASE 297587 Added fields Sales Price Start Date and Purchase Price Start Date
    // NPR5.49/BHR /20190213 CASE 343119 Correct report as per OMA standards
    // NPR5.55/ALST/20200521 CASE 402502 added event publisher after item worksheer line is created from excel

    Caption = 'Import Excel Item Worksheet';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Item Worksheet"; "NPR Item Worksheet")
        {
            DataItemTableView = SORTING("Item Template Name", Name) ORDER(Ascending);

            trigger OnPostDataItem()
            begin
                //-NPR5.38 [278205]
                ///CheckItemCategories; //NPR5.34
                //+NPR5.38 [278205]

                //-NPR4.19
                ItemWorksheetLine.Reset;
                ItemWorksheetLine.SetRange("Worksheet Template Name", "Item Worksheet"."Item Template Name");
                ItemWorksheetLine.SetRange("Worksheet Name", "Item Worksheet".Name);
                if ItemWorksheetLine.FindLast then
                    LastItemWorksheetLine := ItemWorksheetLine
                else
                    LastItemWorksheetLine.Init;
                //+NPR4.19
                LineNo := 0;
                case ImportOption of
                    ImportOption::"Replace lines":
                        begin
                            ItemWorksheetLine.Reset;
                            ItemWorksheetLine.SetRange("Worksheet Template Name", "Item Worksheet"."Item Template Name");
                            ItemWorksheetLine.SetRange("Worksheet Name", "Item Worksheet".Name);
                            ItemWorksheetLine.DeleteAll(true);
                        end;
                    ImportOption::"Add lines":
                        begin
                            ItemWorksheetLine.Reset;
                            ItemWorksheetLine.SetRange("Worksheet Template Name", "Item Worksheet"."Item Template Name");
                            ItemWorksheetLine.SetRange("Worksheet Name", "Item Worksheet".Name);
                            if ItemWorksheetLine.FindLast then
                                LineNo := ItemWorksheetLine."Line No.";
                        end;
                end;

                //-NPR5.22
                FirstLine := LineNo + 10000;
                //+NPR5.22

                AnalyzeData;
                if CombineVarieties then
                    //-NPR5.23 [242498]
                    ItemWorksheetMgt.CombineLines("Item Worksheet");
                //+NPR5.23 [242498]
            end;

            trigger OnPreDataItem()
            begin
                if Count > 1 then
                    Error(Text100);
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
                field(ImportOption; ImportOption)
                {
                    Caption = 'Option';
                    OptionCaption = 'Replace lines,Add lines';
                    ApplicationArea = All;
                }
                field(SetItemsToSkip; SetItemsToSkip)
                {
                    Caption = 'Set all items to SKIP';
                    ApplicationArea = All;
                }
                field(ActionIfVariantUnknown; ActionIfVariantUnknown)
                {
                    Caption = 'If the Variant does not exist, but the Variety does';
                    OptionCaption = 'Set Variety Worksheet Line to <Skip>,Set Variety Worksheet Line to <Create>';
                    ApplicationArea = All;
                }
                field(ActionIfVarietyUnknown; ActionIfVarietyUnknown)
                {
                    Caption = 'If the Variant and Variety do not exist';
                    OptionCaption = 'Set Variety Worksheet Line to <Skip>,Set Variety Worksheet Line to <Create>';
                    ApplicationArea = All;
                }
                field(CombineVarieties; CombineVarieties)
                {
                    Caption = 'Combine Varieties';
                    ToolTip = 'Automatically try to combine all imported lines to item/variety combinations after import.';
                    ApplicationArea = All;
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            CombineVarieties := true;
            //-NPR5.36 [268786]
            ImportOption := ImportOption::"Add lines";
            //-NPR5.36 [268786]
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
        GLSetup.Get;
        ExcelBuf.LockTable;
        ExcelBuf.OpenBook(ServerFileName, SheetName);
        ExcelBuf.ReadSheet;
    end;

    var
        ExcelBuf: Record "Excel Buffer";
        ExcelBuf2: Record "Excel Buffer";
        RecField: Record "Field";
        ServerFileName: Text;
        SheetName: Text[250];
        TotalRecNo: Integer;
        RecNo: Integer;
        Window: Dialog;
        ImportOption: Option "Replace lines","Add lines";
        ItemWorksheetLine: Record "NPR Item Worksheet Line";
        LastItemWorksheetLine: Record "NPR Item Worksheet Line";
        ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line";
        Text005: Label 'Imported from Excel ';
        Text006: Label 'Import Excel File';
        Text007: Label 'Analyzing Data...\\';
        Text026: Label 'Dates have not been recognized in the Excel worksheet.';
        Text027: Label 'Replace Lines,Add Lines';
        ExcelFileExtensionTok: Label '.xlsx', Locked = true;
        LineNo: Integer;
        GLSetup: Record "General Ledger Setup";
        Text100: Label 'Please start this import from the Item Worksheet Page.';
        CombineVarieties: Boolean;
        ItemWorksheetMgt: Codeunit "NPR Item Worksheet Mgt.";
        ItemWshtImpExpMgt: Codeunit "NPR Item Wsht. Imp. Exp.";
        ActionIfVariantUnknown: Option Skip,Create;
        ActionIfVarietyUnknown: Option Skip,Create;
        FirstLine: Integer;
        TextSkipWarning: Label 'Warning: %1 of the imported Variety lines are set to Skip. Please change the Action on the Variety line to process the changes.';
        FilterText: Text;
        NPRAttributeID: Record "NPR Attribute ID";
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        NPRAttrVisibleArray: array[40] of Boolean;
        NPRAttrTextArray: array[40] of Text;
        LastRow: Integer;
        ExcludeColumnsFilter: Text;
        ItemCategoryErrorTxt: Label 'The following Item Categories are missing : \';
        SetItemsToSkip: Boolean;

    local procedure AnalyzeData()
    var
        TempExcelBuf: Record "Excel Buffer" temporary;
        BudgetBuf: Record "Budget Buffer";
        TempBudgetBuf: Record "Budget Buffer" temporary;
        VarietyValue: Record "NPR Variety Value";
        ItemWorksheetExcelColumn: Record "NPR Item Worksh. Excel Column";
        HeaderRowNo: Integer;
        CountDim: Integer;
        TestDateTime: DateTime;
        OldRowNo: Integer;
        DimRowNo: Integer;
        DimCode3: Code[20];
        TempDec: Decimal;
        MappingFound: Boolean;
        MappedColumnNo: Integer;
        FieldLength: Integer;
        I: Integer;
        AttributeNo: Integer;
        TempDate: Date;
    begin
        Window.Open(
         Text007 +
          '@1@@@@@@@@@@@@@@@@@@@@@@@@@\');
        Window.Update(1, 0);

        //-NPR5.23 [242498]
        //ExcelBuf.SETRANGE("Column No.",1);
        //+NPR5.23 [242498]
        ExcelBuf.SetRange("Row No.", 2, 999999);
        TotalRecNo := ExcelBuf.Count;
        RecNo := 0;
        BudgetBuf.DeleteAll;

        //-NPR5.22
        ExcelBuf.SetRange("Column No.");
        //+NPR5.22

        if ExcelBuf.FindFirst then begin
            repeat
                //-NPR5.22
                //-NPR5.28 [259200]
                RecNo := RecNo + 1;
                //+NPR5.28 [259200]
                if ExcelBuf."Row No." <> LastRow then begin
                    //+NPR5.22
                    //-NPR5.28 [259200]
                    //RecNo := RecNo + 1;
                    //+NPR5.28 [259200]
                    Window.Update(1, Round(RecNo / TotalRecNo * 10000, 1));
                    LineNo := LineNo + 10000;
                    //-246088 [246088]
                    ExcludeColumnsFilter := '';
                    //-246088 [246088]
                    ItemWorksheetLine.Init;
                    ItemWorksheetLine.Validate("Worksheet Template Name", "Item Worksheet"."Item Template Name");
                    ItemWorksheetLine.Validate("Worksheet Name", "Item Worksheet".Name);
                    ItemWorksheetLine.Validate("Line No.", LineNo);
                    ItemWorksheetLine.SetUpNewLine(LastItemWorksheetLine);
                    ItemWorksheetLine.Insert(true);
                    //-NPR5.55 [402502]
                    OnAfterCreateWorksheetLineFromExcel(ItemWorksheetLine, ExcelBuf);
                    //+NPR5.55 [402502]
                    //-NPR5.35 [268786]
                    if SetItemsToSkip then
                        ItemWorksheetLine.Action := ItemWorksheetLine.Action::Skip
                    else
                        //+NPR5.35 [268786]
                        ItemWorksheetLine.Action := ItemWorksheetLine.Action::CreateNew;
                    //-NPR5.22
                    ItemWorksheetExcelColumn.Reset;
                    ItemWorksheetExcelColumn.SetRange("Worksheet Template Name", "Item Worksheet"."Item Template Name");
                    ItemWorksheetExcelColumn.SetRange("Worksheet Name", "Item Worksheet".Name);
                    ItemWorksheetExcelColumn.SetFilter("Process as", '<>%1', ItemWorksheetExcelColumn."Process as"::Skip);
                    MappingFound := ItemWorksheetExcelColumn.FindFirst;
                    if MappingFound then begin
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Item No."), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                //-NPR5.36 [268786]
                                //ItemWorksheetLine.VALIDATE("Item No.",COPYSTR(ExcelBuf2."Cell Value as Text",1,FieldLength));
                                ItemWorksheetLine.Validate("Item No.", CopyStr(AppendPrefix(ExcelBuf2."Cell Value as Text", ItemWorksheetLine), 1, FieldLength));
                        //-NPR5.36 [268786]
                        //-NPR5.25 [246088]
                        //IF GetColumnMapping(DATABASE::"Item Worksheet Line",ItemWorksheetLine.FIELDNO("Vendor Item No."),MappedColumnNo,FieldLength) THEN
                        //  IF ExcelBuf2.GET(ExcelBuf."Row No.",MappedColumnNo) THEN
                        //    ItemWorksheetLine.VALIDATE("Vendor Item No.",COPYSTR(ExcelBuf2."Cell Value as Text",1,FieldLength));
                        //+NPR5.25[246088]
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Item Group"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetLine.Validate("Item Group", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Vendor No."), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetLine.Validate("Vendor No.", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        //-NPR5.25 [246088]
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Vendor Item No."), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetLine.Validate("Vendor Item No.", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        //+NPR5.25[246088]
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
                        //-NPR5.38 [297587]
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Sales Price Start Date"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                if Evaluate(TempDate, ExcelBuf2."Cell Value as Text") then
                                    ItemWorksheetLine.Validate("Sales Price Start Date", TempDate);
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Purchase Price Start Date"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                if Evaluate(TempDate, ExcelBuf2."Cell Value as Text") then
                                    ItemWorksheetLine.Validate("Purchase Price Start Date", TempDate);
                        //+NPR5.38 [297587]
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Tariff No."), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetLine.Validate("Tariff No.", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Variety Group"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetLine.Validate("Variety Group", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Item Category Code"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetLine."Item Category Code" := CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength);
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Product Group Code"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetLine."Product Group Code" := CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength);
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Recommended Retail Price"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                if Evaluate(TempDec, ExcelBuf2."Cell Value as Text") then
                                    ItemWorksheetLine.Validate("Recommended Retail Price", TempDec);
                        //-NPR5.23 [242329]
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Vendors Bar Code"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetLine.Validate("Vendors Bar Code", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Internal Bar Code"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetLine.Validate("Internal Bar Code", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        //+NPR5.23 [242329]
                        //-NPR5.23 [242498]
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Net Weight"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                if Evaluate(TempDec, ExcelBuf2."Cell Value as Text") then
                                    ItemWorksheetLine.Validate("Net Weight", TempDec);
                        if GetColumnMapping(DATABASE::"NPR Item Worksheet Line", ItemWorksheetLine.FieldNo("Gross Weight"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                if Evaluate(TempDec, ExcelBuf2."Cell Value as Text") then
                                    ItemWorksheetLine.Validate("Gross Weight", TempDec);
                        //+NPR5.23 [242498]
                        //-NPR5.25 [246088]
                        ItemWorksheetLine.Modify;
                        ProcessColumnMapping(DATABASE::"NPR Item Worksheet Line", '', ExcludeColumnsFilter);
                        ItemWorksheetLine.Get(ItemWorksheetLine."Worksheet Template Name", ItemWorksheetLine."Worksheet Name", ItemWorksheetLine."Line No.");
                        //+NPR5.25 [246088]
                        GetAttributeMapping(DATABASE::"NPR Item Worksheet Line");
                    end else begin
                        //+NPR5.22
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 1) then
                            ItemWorksheetLine.Validate("Item No.", ExcelBuf2."Cell Value as Text");
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 5) then
                            ItemWorksheetLine.Validate("Vendor Item No.", ExcelBuf2."Cell Value as Text");
                        //-NPR4.19
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 12) then
                            ItemWorksheetLine.Validate("Item Group", ExcelBuf2."Cell Value as Text");
                        //IF ExcelBuf2.GET(ExcelBuf."Row No.",16) THEN
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 11) then
                            //+NPR4.19
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
                        //-NPR4.19
                        //IF ExcelBuf2.GET(ExcelBuf."Row No.",15) THEN
                        //   ItemWorksheetLine.VALIDATE("Item Group",ExcelBuf2."Cell Value as Text");
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 6) then
                            ItemWorksheetLine.Validate("Tariff No.", ExcelBuf2."Cell Value as Text");
                        //IF ExcelBuf2.GET(ExcelBuf."Row No.",14) THEN
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 13) then
                            //+NPR4.19
                            ItemWorksheetLine.Validate("Variety Group", ExcelBuf2."Cell Value as Text");
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 3) then
                            ItemWorksheetLine."Item Category Code" := CopyStr(ExcelBuf2."Cell Value as Text", 1, MaxStrLen(ItemWorksheetLine."Item Category Code"));
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 4) then
                            ItemWorksheetLine."Product Group Code" := CopyStr(ExcelBuf2."Cell Value as Text", 1, MaxStrLen(ItemWorksheetLine."Product Group Code"));
                        //-NPR5.22
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 18) then
                            if Evaluate(TempDec, ExcelBuf2."Cell Value as Text") then
                                ItemWorksheetLine.Validate("Recommended Retail Price", TempDec);

                        //-NPR5.23 [242329]
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 19) then
                            ItemWorksheetLine.Validate("Vendors Bar Code", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 20) then
                            ItemWorksheetLine.Validate("Internal Bar Code", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        //+NPR5.23 [242329]
                        //-NPR5.23 [242498]
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 21) then
                            if Evaluate(TempDec, ExcelBuf2."Cell Value as Text") then
                                ItemWorksheetLine.Validate("Net Weight", TempDec);
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 22) then
                            if Evaluate(TempDec, ExcelBuf2."Cell Value as Text") then
                                ItemWorksheetLine.Validate("Gross Weight", TempDec);
                        //+NPR5.23 [242498]
                        AttributeNo := 1;
                        repeat
                            //-NPR5.23 [242498]
                            //IF ExcelBuf2.GET(ExcelBuf."Row No.",AttributeNo + 18) THEN BEGIN
                            if ExcelBuf2.Get(ExcelBuf."Row No.", AttributeNo + 22) then begin
                                //+NPR5.23 [242498]
                                NPRAttrManagement.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", AttributeNo,
                                   ItemWorksheetLine."Worksheet Template Name", ItemWorksheetLine."Worksheet Name", ItemWorksheetLine."Line No.", ExcelBuf2."Cell Value as Text");
                            end;
                            AttributeNo := AttributeNo + 1;
                        until AttributeNo = 19;
                    end;

                    ItemWshtImpExpMgt.SetImportActionWorksheetLine(ItemWorksheetLine);
                    //IF ItemWorksheetLine."Existing Item No." <> '' THEN
                    //  ItemWorksheetLine.Action := ItemWorksheetLine.Action :: UpdateAndCreateVariants
                    //ELSE
                    //  ItemWorksheetLine.Action := ItemWorksheetLine.Action :: CreateNew;
                    //+NPR5.22
                    //-NPR5.35 [268786]
                    if SetItemsToSkip then
                        ItemWorksheetLine.Validate(Action, ItemWorksheetLine.Action::Skip);
                    //+NPR5.35 [268786]
                    ItemWorksheetLine.Modify(true);
                    //-NPR5.23 [242498]
                    //-NPR5.28 [259200]
                    //ItemWshtImpExpMgt.OnAfterImportWorksheetLine(ItemWorksheetLine);
                    ItemWshtImpExpMgt.RaiseOnAfterImportWorksheetLine(ItemWorksheetLine);
                    //+NPR5.28 [259200]
                    //+NPR5.23 [242498]

                    ItemWorksheetVariantLine.Init;
                    ItemWorksheetVariantLine.Validate("Worksheet Template Name", ItemWorksheetLine."Worksheet Template Name");
                    ItemWorksheetVariantLine.Validate("Worksheet Name", ItemWorksheetLine."Worksheet Name");
                    ItemWorksheetVariantLine.Validate("Worksheet Line No.", ItemWorksheetLine."Line No.");
                    ItemWorksheetVariantLine.Validate("Line No.", 10000);
                    ItemWorksheetVariantLine.Insert(true);
                    //-NPR5.35 [268786]
                    if SetItemsToSkip then
                        ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action::Skip
                    else
                        //+NPR5.35 [268786]
                        ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action::CreateNew;
                    ItemWorksheetVariantLine.Validate("Item No.", ItemWorksheetLine."Item No.");
                    ItemWorksheetVariantLine.Validate("Sales Price", ItemWorksheetLine."Sales Price");
                    ItemWorksheetVariantLine.Validate("Direct Unit Cost", ItemWorksheetLine."Direct Unit Cost");
                    //-NPR5.22
                    if MappingFound then begin
                        if GetColumnMapping(DATABASE::"NPR Item Worksh. Variant Line", ItemWorksheetVariantLine.FieldNo("Variety 1 Value"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetVariantLine."Variety 1 Value" := CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength);
                        if GetColumnMapping(DATABASE::"NPR Item Worksh. Variant Line", ItemWorksheetVariantLine.FieldNo("Variety 2 Value"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetVariantLine."Variety 2 Value" := CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength);
                        if GetColumnMapping(DATABASE::"NPR Item Worksh. Variant Line", ItemWorksheetVariantLine.FieldNo("Variety 3 Value"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetVariantLine."Variety 3 Value" := CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength);
                        if GetColumnMapping(DATABASE::"NPR Item Worksh. Variant Line", ItemWorksheetVariantLine.FieldNo("Variety 4 Value"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                //-NPR5.25
                                //ItemWorksheetVariantLine."Variety 3 Value" := COPYSTR(ExcelBuf2."Cell Value as Text",1,FieldLength);
                                ItemWorksheetVariantLine."Variety 4 Value" := CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength);
                        //+NPR5.25
                        //-NPR5.23 [242329]
                        if GetColumnMapping(DATABASE::"NPR Item Worksh. Variant Line", ItemWorksheetVariantLine.FieldNo("Vendors Bar Code"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetVariantLine.Validate("Vendors Bar Code", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        if GetColumnMapping(DATABASE::"NPR Item Worksh. Variant Line", ItemWorksheetVariantLine.FieldNo("Internal Bar Code"), MappedColumnNo, FieldLength) then
                            if ExcelBuf2.Get(ExcelBuf."Row No.", MappedColumnNo) then
                                ItemWorksheetVariantLine.Validate("Internal Bar Code", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        //+NPR5.23 [242329]
                    end else begin
                        //+NPR5.22

                        //-NPR4.19
                        //IF ExcelBuf2.GET(ExcelBuf."Row No.",13) THEN
                        //  ItemWorksheetVariantLine."Variety 1 Value" := ExcelBuf2."Cell Value as Text";
                        //IF ExcelBuf2.GET(ExcelBuf."Row No.",12) THEN
                        //  ItemWorksheetVariantLine."Variety 2 Value" := ExcelBuf2."Cell Value as Text";
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 14) then
                            //-NPR5.49 [343119]
                            //ItemWorksheetVariantLine."Variety 1 Value" := ExcelBuf2."Cell Value as Text";
                            ItemWorksheetVariantLine."Variety 1 Value" := CopyStr(ExcelBuf2."Cell Value as Text", 1, MaxStrLen(ItemWorksheetVariantLine."Variety 1 Value"));
                        //+NPR5.49 [343119]
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 15) then
                            //-NPR5.49 [343119]
                            //ItemWorksheetVariantLine."Variety 2 Value" := ExcelBuf2."Cell Value as Text";
                            ItemWorksheetVariantLine."Variety 2 Value" := CopyStr(ExcelBuf2."Cell Value as Text", 1, MaxStrLen(ItemWorksheetVariantLine."Variety 2 Value"));
                        //+NPR5.49 [343119]
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 16) then
                            //-NPR5.49 [343119]
                            //ItemWorksheetVariantLine."Variety 3 Value" := ExcelBuf2."Cell Value as Text";
                            ItemWorksheetVariantLine."Variety 3 Value" := CopyStr(ExcelBuf2."Cell Value as Text", 1, MaxStrLen(ItemWorksheetVariantLine."Variety 3 Value"));
                        //+NPR5.49 [343119]
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 17) then
                            //-NPR5.49 [343119]
                            //ItemWorksheetVariantLine."Variety 4 Value" := ExcelBuf2."Cell Value as Text";
                            ItemWorksheetVariantLine."Variety 4 Value" := CopyStr(ExcelBuf2."Cell Value as Text", 1, MaxStrLen(ItemWorksheetVariantLine."Variety 4 Value"));
                        //+NPR5.49 [343119]
                        //-NPR5.23 [242329]
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 19) then
                            ItemWorksheetVariantLine.Validate("Vendors Bar Code", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        if ExcelBuf2.Get(ExcelBuf."Row No.", 20) then
                            ItemWorksheetVariantLine.Validate("Internal Bar Code", CopyStr(ExcelBuf2."Cell Value as Text", 1, FieldLength));
                        //+NPR5.23 [242329]
                        //-NPR5.22
                    end;
                    //+NPR5.22

                    //+NPR4.19
                    ItemWorksheetVariantLine.Validate("Existing Item No.", ItemWorksheetLine."Existing Item No.");
                    ItemWorksheetVariantLine.Validate("Variety 1 Value");
                    ItemWorksheetVariantLine.Validate("Variety 2 Value");
                    //-NPR5.22
                    ItemWorksheetVariantLine.Validate("Variety 3 Value");
                    ItemWorksheetVariantLine.Validate("Variety 4 Value");

                    ItemWshtImpExpMgt.SetImportActionWorksheetVariantLine(ItemWorksheetLine, ActionIfVariantUnknown, ActionIfVarietyUnknown, ItemWorksheetVariantLine);
                    //+NPR5.22
                    //-NPR5.35 [268786]
                    if SetItemsToSkip then
                        ItemWorksheetVariantLine.Validate(Action, ItemWorksheetVariantLine.Action::Skip);
                    //+NPR5.35 [268786]
                    ItemWorksheetVariantLine.Modify(true);
                    //-NPR5.23 [242498]
                    //-NPR5.28 [259200]
                    //ItemWshtImpExpMgt.OnAfterImportWorksheetVariantLine(ItemWorksheetVariantLine);
                    ItemWshtImpExpMgt.RaiseOnAfterImportWorksheetVariantLine(ItemWorksheetVariantLine);
                    //+NPR5.28 [259200]
                    //+NPR5.23 [242498]
                    //-NPR5.22
                end;
                LastRow := ExcelBuf."Row No.";
            //+NPR5.22
            until ExcelBuf.Next = 0;
        end;

        Window.Close;
        TempExcelBuf.Reset;

        //-NPR5.22
        ItemWorksheetVariantLine.Reset;
        ItemWorksheetVariantLine.SetRange("Worksheet Template Name", "Item Worksheet"."Item Template Name");
        ItemWorksheetVariantLine.SetRange("Worksheet Name", "Item Worksheet".Name);
        ItemWorksheetVariantLine.SetRange("Worksheet Line No.", FirstLine, LineNo);
        ItemWorksheetVariantLine.SetRange(Action, ItemWorksheetVariantLine.Action::Skip);
        if (ItemWorksheetVariantLine.Count > 0) then begin
            Message(TextSkipWarning, ItemWorksheetVariantLine.Count);
        end;
        //+NPR5.22
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

    local procedure ProcessColumnMapping(ParTableNo: Integer; ParFieldNoFilter: Text; ParColumnsFilter: Text): Boolean
    var
        ItemWorksheetExcelColumn: Record "NPR Item Worksh. Excel Column";
        RecRef: RecordRef;
        FldRef: FieldRef;
        I: Integer;
        TxtOption: Text;
        Df: DateFormula;
    begin
        //-NPR5.25 [246088]
        ItemWorksheetExcelColumn.Reset;
        ItemWorksheetExcelColumn.SetCurrentKey("Worksheet Template Name", "Worksheet Name", "Map to Table No.", "Map to Field Number");
        ItemWorksheetExcelColumn.SetRange("Worksheet Template Name", "Item Worksheet"."Item Template Name");
        ItemWorksheetExcelColumn.SetRange("Worksheet Name", "Item Worksheet".Name);
        if ParColumnsFilter <> '' then
            ItemWorksheetExcelColumn.SetFilter("Excel Column No.", ParColumnsFilter);
        if ParTableNo <> 0 then
            ItemWorksheetExcelColumn.SetRange("Map to Table No.", ParTableNo);
        if ParFieldNoFilter <> '' then
            ItemWorksheetExcelColumn.SetFilter("Map to Field Number", ParFieldNoFilter);
        if ItemWorksheetExcelColumn.FindFirst then
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
                                            //-NPR5.26 [250586]
                                            //EVALUATE(I,ExcelBuf2."Cell Value as Text");
                                            if not Evaluate(I, ExcelBuf2."Cell Value as Text") then
                                                I := 0;
                                            //+NPR5.26 [250586]
                                        end;
                                        FldRef.Value(I);
                                    end else
                                        //-NPR5.26 [250586]
                                        //IF UPPERCASE(FORMAT(FldRef.TYPE)) = 'DATEFORMULA' THEN BEGIN
                                        //  IF EVALUATE(Df,ExcelBuf2."Cell Value as Text") THEN
                                        //    FldRef.VALUE := Df;
                                        //END ELSE BEGIN
                                        //  FldRef.VALUE(COPYSTR(ExcelBuf2."Cell Value as Text",1,RecField.Len));
                                        //END;
                                        ValidateFieldRef(ExcelBuf2."Cell Value as Text", false, FldRef);
                                    //-NPR5.26 [250586]
                                    RecRef.Modify;
                                end;
                        end;
                    end;
            until ItemWorksheetExcelColumn.Next = 0;
        //+NPR5.25 [246088]
    end;

    local procedure GetColumnMapping(ParTableNo: Integer; ParFieldNo: Integer; var VarMappedColumnNo: Integer; var VarLength: Integer): Boolean
    var
        ItemWorksheetExcelColumn: Record "NPR Item Worksh. Excel Column";
    begin
        ItemWorksheetExcelColumn.Reset;
        ItemWorksheetExcelColumn.SetCurrentKey("Worksheet Template Name", "Worksheet Name", "Map to Table No.", "Map to Field Number");
        ItemWorksheetExcelColumn.SetRange("Worksheet Template Name", "Item Worksheet"."Item Template Name");
        ItemWorksheetExcelColumn.SetRange("Worksheet Name", "Item Worksheet".Name);
        ItemWorksheetExcelColumn.SetRange("Map to Table No.", ParTableNo);
        ItemWorksheetExcelColumn.SetRange("Map to Field Number", ParFieldNo);
        if ItemWorksheetExcelColumn.FindFirst then begin
            VarMappedColumnNo := ItemWorksheetExcelColumn."Excel Column No.";
            RecField.Get(ParTableNo, ParFieldNo);
            VarLength := RecField.Len;
            //-246088 [246088]
            if ExcludeColumnsFilter = '' then
                ExcludeColumnsFilter := '<>' + Format(VarMappedColumnNo)
            else
                ExcludeColumnsFilter := ExcludeColumnsFilter + '&<>' + Format(VarMappedColumnNo);
            //-246088 [246088]
            exit(true);
        end else
            exit(false);
    end;

    local procedure GetAttributeMapping(ParTableNo: Integer): Boolean
    var
        ItemWorksheetExcelColumn: Record "NPR Item Worksh. Excel Column";
        AttributeKey: Record "NPR Attribute Key";
        AttributeValueSet: Record "NPR Attribute Value Set";
        Attribute: Record "NPR Attribute";
        AttributeID: Record "NPR Attribute ID";
    begin
        //-NPR5.22
        ItemWorksheetExcelColumn.Reset;
        ItemWorksheetExcelColumn.SetRange("Worksheet Template Name", "Item Worksheet"."Item Template Name");
        ItemWorksheetExcelColumn.SetRange("Worksheet Name", "Item Worksheet".Name);
        ItemWorksheetExcelColumn.SetRange("Process as", ItemWorksheetExcelColumn."Process as"::"Item Attribute");
        if ItemWorksheetExcelColumn.FindSet then
            repeat
                if ExcelBuf2.Get(ExcelBuf."Row No.", ItemWorksheetExcelColumn."Excel Column No.") then begin
                    AttributeID.Reset;
                    AttributeID.SetRange("Table ID", ItemWorksheetExcelColumn."Map to Table No.");
                    AttributeID.SetRange("Attribute Code", ItemWorksheetExcelColumn."Map to Attribute Code");
                    if AttributeID.FindFirst then begin
                        NPRAttrManagement.SetWorksheetLineAttributeValue(ItemWorksheetExcelColumn."Map to Table No.", AttributeID."Shortcut Attribute ID",
                             ItemWorksheetLine."Worksheet Template Name", ItemWorksheetLine."Worksheet Name", ItemWorksheetLine."Line No.", ExcelBuf2."Cell Value as Text");
                    end;
                end;
            until ItemWorksheetExcelColumn.Next = 0;
        //+NPR5.22
    end;

    local procedure ValidateFieldRef(TextValue: Text; ValidateField: Boolean; var FldRef: FieldRef): Boolean
    var
        TmpInteger: Integer;
        TmpDecimal: Decimal;
        TmpDate: Date;
        TmpTime: Time;
        TmpDateTime: DateTime;
        TmpDateFormula: DateFormula;
        TmpBool: Boolean;
    begin
        //-NPR5.25 [246088]
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
                //-NPR5.26 [250586]
                //IF EVALUATE(TmpTime,TextValue) THEN BEGIN
                //   IF ValidateField THEN
                //    FldRef.VALIDATE(TmpTime)
                //  ELSE
                //    FldRef.VALUE(TmpTime)
                if Evaluate(TmpDateTime, TextValue) then begin
                    if ValidateField then
                        FldRef.Validate(TmpDateTime)
                    else
                        FldRef.Value(TmpDateTime);
                    //-NPR5.26 [250586]
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
        //+NPR5.25 [246088]
    end;

    local procedure AppendPrefix(ItemNoIn: Text; ItemWorksheetLineIn: Record "NPR Item Worksheet Line"): Text
    var
        ItemWorksheetTemplate2: Record "NPR Item Worksh. Template";
        ItemWorksheet2: Record "NPR Item Worksheet";
        PrefixCode: Code[10];
    begin
        //-NPR5.36 [268786]
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
        //+NPR5.36 [268786]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateWorksheetLineFromExcel(var ItemWorksheetLine: Record "NPR Item Worksheet Line"; var ExcelBuffer: Record "Excel Buffer")
    begin
    end;
}

