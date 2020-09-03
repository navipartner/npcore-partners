codeunit 6060046 "NPR Item Wsht.Register Line"
{
    // NPR4.18/BR/20160209  CASE 182391 Object Created
    // NPR4.19/BR/20160216  CASE 182391 Added Support for Tariff No., minor fixes, only update Variety values for new variants
    // NPR5.22/BR/20160419  CASE 239640 Fix error when updating item
    // NPR5.22/BR/20160420  CASE 239422 Fix creating "Empty" Variants"
    // NPR5.22/BR/20160420  CASE 182391 Fix creating Variants with blank code
    // NPR5.23/BR/20160502  CASE 240330 Added support for prefixes
    // NPR5.23/BR/20160525  CASE 242498 Added field Net Weight and Gross Weight
    // NPR5.23/BR/20160525  CASE 242498 Added Event Publishers OnBeforeRegister(Variant)Line OnAfterRegister(Variant)Line
    // NPR5.23/BR/20160525  CASE 242498 Added options for Purchase and Sales price handling
    // NPR5.23/BR/20160531  CASE 242498 Only overwrite Unit Price on item card if in LCY
    // NPR5.25/BR /20160704 CASE 246088 Added many extra fields from the Item Table
    // NPR5.25/BR /20160707 CASE 246088 Changed Validation structure
    // NPR5.26/BR /20160831 CASE 250745 Fix mapping of "standard" fields
    // NPR5.29/TJ /20170119 CASE 263917 Changed how to call function GetFromVariety in function CreateVariant
    // NPR5.33/BR /20170607 CASE 279610 Deleted fields: Properties, Item Sales Prize, Program No., Assortment, Auto, Out of Stock Print, Print Quantity, Labels per item, ISBN, Label Date, Open quarry unit cost, Hand Out Item No., Model, Basis Number, It
    // NPR5.33/BR /20170629 CASE 280329 Changed to comply with Guidelines
    // NPR5.35/BR /20170815 CASE 268786 Fixed issue with Variants
    // NPR5.35/BR /20170821 CASE 268786 Added support for "Leave Skipped line on Register"
    // NPR5.38/BR /20171124 CASE 297587 Added support for fields Sales Price Start Date and Purchase Price Start Date
    // NPR5.38/BR /20171222 CASE 300754 Only update Unit Price if Sales price date is Before on on Workdate
    // NPR5.38/BR /20180112 CASE 268786 Only Create Item Worksheet Variety Value lines with "Create New" Item Worksheet Variant Lines
    // NPR5.41/TS  /20180425 CASE 303403 Modifications on Item are overwritten as modify is after ValidateFields.
    // NPR5.43/MHA /20180621 CASE 319925 "Direct Unit Cost" is used for initiating "Unit Cost" in CreateItem() and UpdateItem()
    // NPR5.43/JDH /20180628 CASE 317108 Variant Code generation enabled for subscriber
    // NPR5.48/TJ  /20190102 CASE 340615 Commented out usage of field Item."Product Group Code"
    // NPR5.50/THRO/20190528 CASE 353052 Changes to Sales Price update
    // NPR5.55/TJ  /20200304 CASE 388960 Renamed RegisterAndDeleteLines to CreateRegisteredWorksheetLines
    //                                   Delete part is moved to batch codeunit

    Permissions = TableData "NPR Registered Item Works." = imd,
                  TableData "NPR Regist. Item Worksh Line" = imd,
                  TableData "NPR Reg. Item Wsht Var. Line" = imd;
    TableNo = "NPR Item Worksheet Line";

    trigger OnRun()
    begin
        GLSetup.Get;
        RunWithCheck(Rec);
    end;

    var
        ItemWkshLine: Record "NPR Item Worksheet Line";
        ItemWkshVariantLine: Record "NPR Item Worksh. Variant Line";
        ItemWorksheetVarietyValue: Record "NPR Item Worksh. Variety Value";
        GLSetup: Record "General Ledger Setup";
        ItemWkshCheckLine: Codeunit "NPR Item Wsht.-Check Line";
        RegisteredWorksheet: Record "NPR Registered Item Works.";
        RegisteredWorksheetLine: Record "NPR Regist. Item Worksh Line";
        RegisteredWorksheetVariantLine: Record "NPR Reg. Item Wsht Var. Line";
        RegisteredWorksheetVarietyValue: Record "NPR Reg. Item Wsht Var. Value";
        ItemWorksheetTemplate: Record "NPR Item Worksh. Template";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        VarietyCloneData: Codeunit "NPR Variety Clone Data";
        NewItemNo: Code[20];
        Txt100: Label 'Variant already exists.';
        ItemWorksheetItemManagement: Codeunit "NPR Item Worksheet Item Mgt.";
        RecRefTextMaster: Text[250];
        TxtNotImplemented: Label 'Not implemented yet. Please set Sales Price handling to Item of Item+Variant in the Item Worksheet Template';
        CalledFromTest: Boolean;

    procedure RunWithCheck(var ItemWkshLine2: Record "NPR Item Worksheet Line")
    begin
        ItemWkshLine.Copy(ItemWkshLine2);
        Code;
        ItemWkshLine2 := ItemWkshLine;
    end;

    local procedure "Code"()
    begin
        with ItemWkshLine do begin
            if EmptyLine then
                exit;

            if Status = Status::Validated then begin

                ItemWorksheetTemplate.Get("Worksheet Template Name");
                //-NPR5.25 [246088]
                //ItemWkshCheckLine.RunCheck(ItemWkshLine,TRUE);
                //IF NOT CalledFromTest THEN
                //  ItemWkshCheckLine.RunCheck(ItemWkshLine,TRUE);
                //+NPR5.25 [246088]

                //-NPR5.23 [242498]
                if Action <> Action::Skip then
                    OnBeforeRegisterLine(ItemWkshLine);
                //+NPR5.23 [242498]

                case Action of
                    Action::Skip:
                        begin
                            if "Item No." = '' then
                                "Item No." := "Existing Item No.";
                            //-NPR4.19
                            //UpdateAndCopyVarieties(ItemWkshLine,1,"Variety 1","Variety 1 Table (Base)","Variety 1 Table (New)","Create Copy of Variety 1 Table");
                            //UpdateAndCopyVarieties(ItemWkshLine,2,"Variety 2","Variety 2 Table (Base)","Variety 2 Table (New)","Create Copy of Variety 2 Table");
                            //UpdateAndCopyVarieties(ItemWkshLine,3,"Variety 3","Variety 3 Table (Base)","Variety 3 Table (New)","Create Copy of Variety 3 Table");
                            //UpdateAndCopyVarieties(ItemWkshLine,4,"Variety 4","Variety 4 Table (Base)","Variety 4 Table (New)","Create Copy of Variety 4 Table");
                            //+NPR4.19
                        end;
                    Action::CreateNew:
                        begin
                            Item.Init;
                            if "Item No." <> '' then begin
                                Item.Init;
                                Item."No." := "Item No.";
                                Item."No. Series" := "No. Series";
                                Item.Validate("No.");
                                //-NPR5.23 [242498]
                                "Item No." := Item."No.";
                                Item."No. Series" := "No. Series";
                                //+NPR5.23 [242498]
                                Item.Insert(true);
                            end else begin
                                Item.Init;
                                //-NPR5.23
                                NewItemNo := GetNewItemNo;
                                if NewItemNo = '' then
                                    //+NPR5.23
                                    NoSeriesMgt.InitSeries("No. Series", '', 0D, NewItemNo, "No. Series");
                                Item."No." := NewItemNo;
                                Item.Validate("No.", NewItemNo);
                                Item."No. Series" := "No. Series";
                                Item.Insert(true);
                                "Item No." := NewItemNo;
                            end;
                            CreateItem;
                        end;
                    Action::UpdateOnly:
                        begin
                            "Item No." := "Existing Item No.";
                            UpdateItem;
                        end;
                    Action::UpdateAndCreateVariants:
                        begin
                            "Item No." := "Existing Item No.";
                            UpdateItem;
                        end;
                end;

                ItemWkshVariantLine.Reset;
                ItemWkshVariantLine.SetRange("Worksheet Template Name", "Worksheet Template Name");
                ItemWkshVariantLine.SetRange("Worksheet Name", "Worksheet Name");
                ItemWkshVariantLine.SetRange("Worksheet Line No.", "Line No.");
                ItemWkshVariantLine.SetFilter("Heading Text", '%1', ''); //Skip Headers
                if ItemWkshVariantLine.FindSet then
                    repeat
                        //-NPR5.23 [242498]
                        if ItemWkshVariantLine.Action <> ItemWkshVariantLine.Action::Skip then
                            OnBeforeRegisterVariantLine(ItemWkshVariantLine);
                        //+NPR5.23 [242498]
                        case ItemWkshVariantLine.Action of
                            ItemWkshVariantLine.Action::CreateNew:
                                begin
                                    //-NPR5.22
                                    if (ItemWkshVariantLine."Variety 1 Value" <> '') or
                                       (ItemWkshVariantLine."Variety 1 Value" <> '') or
                                       (ItemWkshVariantLine."Variety 1 Value" <> '') or
                                       (ItemWkshVariantLine."Variety 1 Value" <> '') then begin
                                        //+NPR5.22
                                        //-NPRx.x
                                        UpdateAndCopyVariety("Variety 1", "Variety 1 Table (Base)", "Variety 1 Table (New)", ItemWkshVariantLine."Variety 1 Value");
                                        UpdateAndCopyVariety("Variety 2", "Variety 2 Table (Base)", "Variety 2 Table (New)", ItemWkshVariantLine."Variety 2 Value");
                                        UpdateAndCopyVariety("Variety 3", "Variety 3 Table (Base)", "Variety 3 Table (New)", ItemWkshVariantLine."Variety 3 Value");
                                        UpdateAndCopyVariety("Variety 4", "Variety 4 Table (Base)", "Variety 4 Table (New)", ItemWkshVariantLine."Variety 4 Value");
                                        //+NPRx.x
                                        if ItemWkshVariantLine."Item No." = '' then
                                            ItemWkshVariantLine."Item No." := "Item No.";
                                        CreateVariant(ItemWkshVariantLine);
                                        ItemWkshVariantLine.UpdateBarcode;
                                        ProcessVariantLineSalesPrice;
                                        ProcessVariantLinePurchasePrice;
                                        //-NPR5.22
                                    end;
                                    //+NPR5.22
                                end;
                            ItemWkshVariantLine.Action::Update:
                                begin
                                    ItemVariant.Get(ItemWkshVariantLine."Existing Item No.", ItemWkshVariantLine."Existing Variant Code");
                                    ItemWkshVariantLine."Item No." := ItemWkshVariantLine."Existing Item No.";
                                    ItemWkshVariantLine."Variant Code" := ItemWkshVariantLine."Existing Variant Code";
                                    if ItemWkshVariantLine.Description <> '' then
                                        ItemVariant.Description := ItemWkshVariantLine.Description;
                                    ItemVariant."NPR Blocked" := ItemWkshVariantLine.Blocked;
                                    ItemVariant.Modify(true);
                                    ItemWkshVariantLine.UpdateBarcode;
                                    ProcessVariantLineSalesPrice;
                                    ProcessVariantLinePurchasePrice;
                                end;
                        end;
                        ItemWkshVariantLine.Modify(true);
                        //-NPR5.23 [242498]
                        if ItemWkshVariantLine.Action <> ItemWkshVariantLine.Action::Skip then
                            OnAfterRegisterVariantLine(ItemWkshVariantLine);
                    //+NPR5.23 [242498]
                    until ItemWkshVariantLine.Next = 0;
                Validate(Status, Status::Processed);
                //-NPR5.25 [246088]
                if not CalledFromTest then
                    //+NPR5.25 [246088]
                    Modify(true);
                //-NPR5.23 [242498]
                if Action <> Action::Skip then
                    OnAfterRegisterLine(ItemWkshLine);
                //+NPR5.23 [242498]
            end;
            //-NPR5.25 [246088]
            if not CalledFromTest then
                //+NPR5.25 [246088]
                //-NPR5.55 [388960]
                //RegisterAndDeleteLines;
                CreateRegisteredWorksheetLines();
            //+NPR5.55 [388960]
        end;
    end;

    local procedure CreateItem()
    begin
        GetItem(ItemWkshLine."Item No.");
        with Item do begin
            Validate("Vendor Item No.", ItemWkshLine."Vendor Item No.");
            //-NPR5.26 [250745]
            if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Item Group")) then
                //+NPR5.26 [250745]
                Validate("NPR Item Group", ItemWkshLine."Item Group");
            //"Bar Code" := ItemWkshLine."Bar Code";
            //-NPR5.26 [250745]
            if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Vendor No.")) then
                //+NPR5.26 [250745]
                Validate("Vendor No.", ItemWkshLine."Vendor No.");
            Validate(Description, ItemWkshLine.Description);
            if ItemWkshLine."Direct Unit Cost" <> 0 then
                if (ItemWkshLine."Purchase Price Currency Code" = '') then
                    Validate("Last Direct Cost", ItemWkshLine."Direct Unit Cost");
            Validate("Costing Method", ItemWkshLine."Costing Method");
            if ItemWkshLine."Costing Method" = ItemWkshLine."Costing Method"::Standard then
                if (ItemWkshLine."Purchase Price Currency Code" = '') then
                    Validate("Standard Cost", ItemWkshLine."Direct Unit Cost");
            //-NPR5.43 [319925]
            if "Unit Cost" = 0 then
                "Unit Cost" := ItemWkshLine."Direct Unit Cost";
            //+NPR5.43 [319925]
            if (ItemWkshLine."Sales Price Currency Code" = '') then
                //-NPR5.38 [300754]
                if ItemWkshLine."Sales Price Start Date" <= WorkDate then
                    //+NPR5.38 [300754]
                    Validate("Unit Price", ItemWkshLine."Sales Price");
            //-NPR5.26 [250745]
            if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Base Unit of Measure")) then
                //+NPR5.26 [250745]
                Validate("Base Unit of Measure", ItemWkshLine."Base Unit of Measure");
            //-NPR5.26 [250745]
            if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Inventory Posting Group")) then
                //+NPR5.26 [250745]
                Validate("Inventory Posting Group", ItemWkshLine."Inventory Posting Group");
            //"Vendors Bar Code" := ItemWkshLine."Vendors Bar Code";
            //-NPR5.26 [250745]
            if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Gen. Prod. Posting Group")) then
                //+NPR5.26 [250745]
                Validate("Gen. Prod. Posting Group", ItemWkshLine."Gen. Prod. Posting Group");
            //-NPR5.26 [250745]
            if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Tax Group Code")) then
                //+NPR5.26 [250745]
                Validate("Tax Group Code", ItemWkshLine."Tax Group Code");
            //-NPR5.26
            if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("VAT Prod. Posting Group")) then
                //+NPR5.26
                Validate("VAT Prod. Posting Group", ItemWkshLine."VAT Prod. Posting Group");
            //-NPR5.26
            if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Global Dimension 1 Code")) then
                //+NPR5.26
                Validate("Global Dimension 1 Code", ItemWkshLine."Global Dimension 1 Code");
            //-NPR5.26
            if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Global Dimension 2 Code")) then
                Validate("Global Dimension 2 Code", ItemWkshLine."Global Dimension 2 Code");
            //+NPR5.26
            //-NPR4.19
            ItemWkshLine."Variety 1 Table (New)" := FindNewVarietyNames(ItemWkshLine, 1, ItemWkshLine."Variety 1", ItemWkshLine."Variety 1 Table (Base)", ItemWkshLine."Variety 1 Table (New)", ItemWkshLine."Create Copy of Variety 1 Table");
            ItemWkshLine."Variety 2 Table (New)" := FindNewVarietyNames(ItemWkshLine, 2, ItemWkshLine."Variety 2", ItemWkshLine."Variety 2 Table (Base)", ItemWkshLine."Variety 2 Table (New)", ItemWkshLine."Create Copy of Variety 2 Table");
            ItemWkshLine."Variety 3 Table (New)" := FindNewVarietyNames(ItemWkshLine, 3, ItemWkshLine."Variety 3", ItemWkshLine."Variety 3 Table (Base)", ItemWkshLine."Variety 3 Table (New)", ItemWkshLine."Create Copy of Variety 3 Table");
            ItemWkshLine."Variety 4 Table (New)" := FindNewVarietyNames(ItemWkshLine, 4, ItemWkshLine."Variety 4", ItemWkshLine."Variety 4 Table (Base)", ItemWkshLine."Variety 4 Table (New)", ItemWkshLine."Create Copy of Variety 4 Table");
            //+NPR4.19
            "NPR Variety 1" := ItemWkshLine."Variety 1";
            "NPR Variety 1 Table" := ItemWkshLine."Variety 1 Table (New)";
            "NPR Variety 2" := ItemWkshLine."Variety 2";
            "NPR Variety 2 Table" := ItemWkshLine."Variety 2 Table (New)";
            "NPR Variety 3" := ItemWkshLine."Variety 3";
            "NPR Variety 3 Table" := ItemWkshLine."Variety 3 Table (New)";
            "NPR Variety 4" := ItemWkshLine."Variety 4";
            "NPR Variety 4 Table" := ItemWkshLine."Variety 4 Table (New)";
            "NPR Cross Variety No." := ItemWkshLine."Cross Variety No.";
            "NPR Variety Group" := ItemWkshLine."Variety Group";
            //-NPR5.26
            if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Sales Unit of Measure")) then
                //+NPR5.26
                Validate("Sales Unit of Measure", ItemWkshLine."Sales Unit of Measure");
            //-NPR5.26
            if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Sales Unit of Measure")) then
                //+NPR5.26
                Validate("Purch. Unit of Measure", ItemWkshLine."Sales Unit of Measure");
            //-NPR5.26
            if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Manufacturer Code")) then
                //+NPR5.26
                Validate("Manufacturer Code", ItemWkshLine."Manufacturer Code");
            //-NPR5.26
            if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Item Category Code")) then
                //+NPR5.26
                Validate("Item Category Code", ItemWkshLine."Item Category Code");
            //-NPR5.48 [340615]
            /*
            //-NPR5.26
            IF NOT MapStandardItemWorksheetLineField(Item,ItemWkshLine.FIELDNO("Product Group Code")) THEN
            //+NPR5.26
            VALIDATE("Product Group Code",ItemWkshLine."Product Group Code");
            */
            //+NPR5.48 [340615]
            //-NPR5.23 [242498]
            Validate("Net Weight", ItemWkshLine."Net Weight");
            Validate("Gross Weight", ItemWkshLine."Gross Weight");
            //+NPR5.23 [242498]
            //-NPR4.19
            //-NPR5.26
            if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Tariff No.")) then
                //+NPR5.26
                Validate("Tariff No.", ItemWkshLine."Tariff No.");
            //+NPR4.19
            //-NPR5.25 [246088]
            ValidateFields(Item, ItemWkshLine, true, false);
            //+NPR5.25 [246088]


            Modify(true);
        end;

        ItemWkshLine.UpdateBarcode;
        ProcessLineSalesPrices;
        ProcessLinePurchasePrices;
        //-NPR4.19
        //UpdateAndCopyVarieties(ItemWkshLine,1,ItemWkshLine."Variety 1",ItemWkshLine."Variety 1 Table (Base)",ItemWkshLine."Variety 1 Table (New)",ItemWkshLine."Create Copy of Variety 1 Table");
        //UpdateAndCopyVarieties(ItemWkshLine,2,ItemWkshLine."Variety 2",ItemWkshLine."Variety 2 Table (Base)",ItemWkshLine."Variety 2 Table (New)",ItemWkshLine."Create Copy of Variety 2 Table");
        //UpdateAndCopyVarieties(ItemWkshLine,3,ItemWkshLine."Variety 3",ItemWkshLine."Variety 3 Table (Base)",ItemWkshLine."Variety 3 Table (New)",ItemWkshLine."Create Copy of Variety 3 Table");
        //UpdateAndCopyVarieties(ItemWkshLine,4,ItemWkshLine."Variety 4",ItemWkshLine."Variety 4 Table (Base)",ItemWkshLine."Variety 4 Table (New)",ItemWkshLine."Create Copy of Variety 4 Table");
        UpdateAndCopyVarieties(ItemWkshLine, 1, ItemWkshLine."Variety 1", ItemWkshLine."Variety 1 Table (Base)", ItemWkshLine."Variety 1 Table (New)", ItemWkshLine."Create Copy of Variety 1 Table", true);
        UpdateAndCopyVarieties(ItemWkshLine, 2, ItemWkshLine."Variety 2", ItemWkshLine."Variety 2 Table (Base)", ItemWkshLine."Variety 2 Table (New)", ItemWkshLine."Create Copy of Variety 2 Table", true);
        UpdateAndCopyVarieties(ItemWkshLine, 3, ItemWkshLine."Variety 3", ItemWkshLine."Variety 3 Table (Base)", ItemWkshLine."Variety 3 Table (New)", ItemWkshLine."Create Copy of Variety 3 Table", true);
        UpdateAndCopyVarieties(ItemWkshLine, 4, ItemWkshLine."Variety 4", ItemWkshLine."Variety 4 Table (Base)", ItemWkshLine."Variety 4 Table (New)", ItemWkshLine."Create Copy of Variety 4 Table", true);
        UpdateItemAttributes;
        //+NPR4.19

    end;

    local procedure UpdateItem()
    begin
        GetItem(ItemWkshLine."Item No.");
        with Item do begin
            //-NPR5.22
            //IF  ("Vendor Item No." <> ItemWkshLine."Vendor Item No.") AND ("Vendor Item No." <> '') THEN
            //  VALIDATE("Vendor Item No.",ItemWkshLine."Vendor Item No.");
            //IF ("Vendor No."  <> ItemWkshLine."Vendor No.") AND ("Vendor No."  <> '') THEN
            //  VALIDATE("Vendor No.",ItemWkshLine."Vendor No.");
            //IF (Description <> ItemWkshLine.Description) AND (Description <> '') THEN
            //  VALIDATE(Description,ItemWkshLine.Description);
            //-NPR4.19
            //IF ("Tariff No." <> ItemWkshLine."Tariff No.") AND ("Tariff No." <> '') THEN
            //  VALIDATE("Tariff No.",ItemWkshLine."Tariff No.");
            //+NPR4.19
            if ("Vendor Item No." <> ItemWkshLine."Vendor Item No.") and (ItemWkshLine."Vendor Item No." <> '') then
                Validate("Vendor Item No.", ItemWkshLine."Vendor Item No.");
            if ("Vendor No." <> ItemWkshLine."Vendor No.") and (ItemWkshLine."Vendor No." <> '') then
                Validate("Vendor No.", ItemWkshLine."Vendor No.");
            if (Description <> ItemWkshLine.Description) and (ItemWkshLine.Description <> '') then
                Validate(Description, ItemWkshLine.Description);
            if ("Tariff No." <> ItemWkshLine."Tariff No.") and (ItemWkshLine."Tariff No." <> '') then
                Validate("Tariff No.", ItemWkshLine."Tariff No.");
            //+NPR5.22
            //-NPR5.23 [242498]
            if ("Net Weight" <> ItemWkshLine."Net Weight") and (ItemWkshLine."Net Weight" <> 0) then
                Validate("Net Weight", ItemWkshLine."Net Weight");
            if ("Gross Weight" <> ItemWkshLine."Gross Weight") and (ItemWkshLine."Gross Weight" <> 0) then
                Validate("Gross Weight", ItemWkshLine."Gross Weight");
            //+NPR5.23 [242498]
            //-NPR5.43 [319925]
            if "Unit Cost" = 0 then
                "Unit Cost" := ItemWkshLine."Direct Unit Cost";
            //+NPR5.43 [319925]
            //-NPR5.41 [303403]
            Modify(true);
            //+NPR5.41 [303403]
            //-NPR5.25 [246088]
            ValidateFields(Item, ItemWkshLine, true, false);
            //+NPR5.25 [246088]
            //-NPR5.41 [303403]
            //MODIFY(TRUE);
            //+NPR5.41 [303403]
        end;
        ItemWkshLine.UpdateBarcode;
        ProcessLineSalesPrices;
        ProcessLinePurchasePrices;
        //-NPR4.19
        //UpdateAndCopyVarieties(ItemWkshLine,1,ItemWkshLine."Variety 1",ItemWkshLine."Variety 1 Table (Base)",ItemWkshLine."Variety 1 Table (New)",ItemWkshLine."Create Copy of Variety 1 Table");
        //UpdateAndCopyVarieties(ItemWkshLine,2,ItemWkshLine."Variety 2",ItemWkshLine."Variety 2 Table (Base)",ItemWkshLine."Variety 2 Table (New)",ItemWkshLine."Create Copy of Variety 2 Table");
        //UpdateAndCopyVarieties(ItemWkshLine,3,ItemWkshLine."Variety 3",ItemWkshLine."Variety 3 Table (Base)",ItemWkshLine."Variety 3 Table (New)",ItemWkshLine."Create Copy of Variety 3 Table");
        //UpdateAndCopyVarieties(ItemWkshLine,4,ItemWkshLine."Variety 4",ItemWkshLine."Variety 4 Table (Base)",ItemWkshLine."Variety 4 Table (New)",ItemWkshLine."Create Copy of Variety 4 Table");
        UpdateAndCopyVarieties(ItemWkshLine, 1, ItemWkshLine."Variety 1", ItemWkshLine."Variety 1 Table (Base)", ItemWkshLine."Variety 1 Table (New)", ItemWkshLine."Create Copy of Variety 1 Table", false);
        UpdateAndCopyVarieties(ItemWkshLine, 2, ItemWkshLine."Variety 2", ItemWkshLine."Variety 2 Table (Base)", ItemWkshLine."Variety 2 Table (New)", ItemWkshLine."Create Copy of Variety 2 Table", false);
        UpdateAndCopyVarieties(ItemWkshLine, 3, ItemWkshLine."Variety 3", ItemWkshLine."Variety 3 Table (Base)", ItemWkshLine."Variety 3 Table (New)", ItemWkshLine."Create Copy of Variety 3 Table", false);
        UpdateAndCopyVarieties(ItemWkshLine, 4, ItemWkshLine."Variety 4", ItemWkshLine."Variety 4 Table (Base)", ItemWkshLine."Variety 4 Table (New)", ItemWkshLine."Create Copy of Variety 4 Table", false);
        UpdateItemAttributes;
        //+NPR4.19
    end;

    local procedure UpdateAndCopyVarieties(var ItemworkshLine: Record "NPR Item Worksheet Line"; VarietyNo: Integer; Variety: Code[20]; VarietyTableFrom: Code[20]; VarietyTableTo: Code[20]; CreateCopy: Boolean; CopyValues: Boolean)
    var
        VarietyTableOld: Record "NPR Variety Table";
        PrefixCode: Code[20];
        SuffixCode: Code[20];
        NewTableCode: Code[20];
        VarietyGroup: Record "NPR Variety Group";
        VarietyValue: Record "NPR Variety Value";
        NewVarietyTable: Record "NPR Variety Table";
        ItemWorksheetVariantLineToCreate: Record "NPR Item Worksh. Variant Line";
        IsUpdated: Boolean;
    begin
        if CreateCopy then begin
            VarietyTableOld.Get(Variety, VarietyTableFrom);
            if (VarietyTableTo = '') or (VarietyTableFrom = VarietyTableTo) then begin
                if ItemworkshLine."Variety Group" <> '' then begin
                    VarietyGroup.Get(ItemworkshLine."Variety Group");
                end else begin
                    VarietyGroup.Init;
                end;
                SuffixCode := ItemworkshLine."Item No.";
                case VarietyNo of
                    1:
                        if (VarietyGroup."Copy Naming Variety 1" = VarietyGroup."Copy Naming Variety 1"::TableCodeAndNoSeries) and
                          (VarietyGroup."No. Series" <> '') then
                            NoSeriesMgt.InitSeries(VarietyGroup."No. Series", '', WorkDate, SuffixCode, VarietyGroup."No. Series");
                    2:
                        if (VarietyGroup."Copy Naming Variety 2" = VarietyGroup."Copy Naming Variety 2"::TableCodeAndNoSeries) and
                          (VarietyGroup."No. Series" <> '') then
                            NoSeriesMgt.InitSeries(VarietyGroup."No. Series", '', WorkDate, SuffixCode, VarietyGroup."No. Series");
                    3:
                        if (VarietyGroup."Copy Naming Variety 3" = VarietyGroup."Copy Naming Variety 3"::TableCodeAndNoSeries) and
                          (VarietyGroup."No. Series" <> '') then
                            NoSeriesMgt.InitSeries(VarietyGroup."No. Series", '', WorkDate, SuffixCode, VarietyGroup."No. Series");
                    4:
                        if (VarietyGroup."Copy Naming Variety 4" = VarietyGroup."Copy Naming Variety 4"::TableCodeAndNoSeries) and
                          (VarietyGroup."No. Series" <> '') then
                            NoSeriesMgt.InitSeries(VarietyGroup."No. Series", '', WorkDate, SuffixCode, VarietyGroup."No. Series");
                end;
                if StrPos(VarietyTableFrom, '-') > 0 then
                    PrefixCode := CopyStr(VarietyTableFrom, 1, StrPos(VarietyTableFrom, '-') - 1)
                else
                    PrefixCode := VarietyTableFrom;
                NewTableCode := CopyStr(PrefixCode + '-' + SuffixCode, 1, MaxStrLen(NewTableCode));
                //-NPR4.19
                case VarietyNo of
                    1:
                        ItemworkshLine."Variety 1 Table (New)" := NewTableCode;
                    2:
                        ItemworkshLine."Variety 2 Table (New)" := NewTableCode;
                    3:
                        ItemworkshLine."Variety 3 Table (New)" := NewTableCode;
                    4:
                        ItemworkshLine."Variety 4 Table (New)" := NewTableCode;
                end;
                //+NPR4.19
            end else begin
                NewTableCode := VarietyTableTo;
            end;
            //-NPR4.19
            //VarietyTable.INIT;
            //VarietyTable :=  VarietyTableOld;
            //VarietyTable.Code := NewTableCode;
            //VarietyTable."Is Copy" := TRUE;
            //VarietyTable."Lock Table" := FALSE;
            //VarietyTable.INSERT(TRUE);
            //+NPR4.19
            //Copy Existing Values
            //-NPR4.19
            if CopyValues then
                if not NewVarietyTable.Get(Variety, NewTableCode) then
                    //+NPR4.19
                    VarietyGroup.CopyTable2NewTable(Variety, VarietyTableFrom, NewTableCode);

        end else begin
            NewTableCode := VarietyTableTo;
        end;

        //Copy Worksheet Values
        //-NPR4.19
        if CopyValues then begin
            //+NPR4.19
            ItemWorksheetVarietyValue.Reset;
            ItemWorksheetVarietyValue.SetRange("Worksheet Template Name", ItemWkshLine."Worksheet Template Name");
            //-NPR5.38 [268786]
            //ItemWorksheetVarietyValue.SETRANGE("Worksheet Template Name",ItemWkshLine."Worksheet Template Name");
            ItemWorksheetVarietyValue.SetRange("Worksheet Name", ItemWkshLine."Worksheet Name");
            //+NPR5.38 [268786]
            ItemWorksheetVarietyValue.SetRange("Worksheet Line No.", ItemWkshLine."Line No.");
            ItemWorksheetVarietyValue.SetRange(Type, Variety);
            if ItemWorksheetVarietyValue.FindSet then
                repeat
                    //-NPR5.38 [268786]
                    //UpdateVarietyValue(Variety,NewTableCode,ItemWorksheetVarietyValue.Value,ItemWorksheetVarietyValue."Sort Order",ItemWorksheetVarietyValue.Description);
                    IsUpdated := false;
                    ItemWorksheetVariantLineToCreate.SetRange("Worksheet Template Name", ItemWkshLine."Worksheet Template Name");
                    ItemWorksheetVariantLineToCreate.SetRange("Worksheet Name", ItemWkshLine."Worksheet Name");
                    ItemWorksheetVariantLineToCreate.SetRange("Worksheet Line No.", ItemWkshLine."Line No.");
                    ItemWorksheetVariantLineToCreate.SetRange(Action, ItemWorksheetVariantLineToCreate.Action::CreateNew);
                    if ItemWorksheetVariantLineToCreate.FindSet then
                        repeat
                            if ((ItemWorksheetVariantLineToCreate."Variety 1" = ItemWorksheetVarietyValue.Type) and
                                (ItemWorksheetVariantLineToCreate."Variety 1 Value" = ItemWorksheetVarietyValue.Value)) or
                               ((ItemWorksheetVariantLineToCreate."Variety 2" = ItemWorksheetVarietyValue.Type) and
                                (ItemWorksheetVariantLineToCreate."Variety 2 Value" = ItemWorksheetVarietyValue.Value)) or
                                ((ItemWorksheetVariantLineToCreate."Variety 3" = ItemWorksheetVarietyValue.Type) and
                                (ItemWorksheetVariantLineToCreate."Variety 3 Value" = ItemWorksheetVarietyValue.Value)) or
                               ((ItemWorksheetVariantLineToCreate."Variety 4" = ItemWorksheetVarietyValue.Type) and
                                (ItemWorksheetVariantLineToCreate."Variety 4 Value" = ItemWorksheetVarietyValue.Value)) then
                                IsUpdated := true;
                        until (ItemWorksheetVariantLineToCreate.Next = 0) or IsUpdated;
                    if IsUpdated then
                        UpdateVarietyValue(Variety, NewTableCode, ItemWorksheetVarietyValue.Value, ItemWorksheetVarietyValue."Sort Order", ItemWorksheetVarietyValue.Description);
                //+NPR5.38 [268786]
                until ItemWorksheetVarietyValue.Next = 0;
            //-NPR4.19
        end;
        //+NPR4.19
    end;

    local procedure FindNewVarietyNames(ItemWkshLine: Record "NPR Item Worksheet Line"; VarietyNo: Integer; Variety: Code[20]; VarietyTableFrom: Code[20]; VarietyTableTo: Code[20]; CreateCopy: Boolean): Code[50]
    var
        VarietyTableOld: Record "NPR Variety Table";
        PrefixCode: Code[20];
        SuffixCode: Code[20];
        NewTableCode: Code[20];
        VarietyGroup: Record "NPR Variety Group";
    begin
        //-NPR4.19
        //-NPR5.35 [268786]
        if VarietyTableFrom = '' then
            VarietyTableFrom := VarietyTableTo;
        //+NPR5.35 [268786]
        if CreateCopy then begin
            VarietyTableOld.Get(Variety, VarietyTableFrom);
            if (VarietyTableTo = '') or (VarietyTableFrom = VarietyTableTo) then begin
                if ItemWkshLine."Variety Group" <> '' then begin
                    VarietyGroup.Get(ItemWkshLine."Variety Group");
                end else begin
                    VarietyGroup.Init;
                end;
                SuffixCode := ItemWkshLine."Item No.";
                case VarietyNo of
                    1:
                        if (VarietyGroup."Copy Naming Variety 1" = VarietyGroup."Copy Naming Variety 1"::TableCodeAndNoSeries) and
                          (VarietyGroup."No. Series" <> '') then
                            NoSeriesMgt.InitSeries(VarietyGroup."No. Series", '', WorkDate, SuffixCode, VarietyGroup."No. Series");
                    2:
                        if (VarietyGroup."Copy Naming Variety 2" = VarietyGroup."Copy Naming Variety 2"::TableCodeAndNoSeries) and
                          (VarietyGroup."No. Series" <> '') then
                            NoSeriesMgt.InitSeries(VarietyGroup."No. Series", '', WorkDate, SuffixCode, VarietyGroup."No. Series");
                    3:
                        if (VarietyGroup."Copy Naming Variety 3" = VarietyGroup."Copy Naming Variety 3"::TableCodeAndNoSeries) and
                          (VarietyGroup."No. Series" <> '') then
                            NoSeriesMgt.InitSeries(VarietyGroup."No. Series", '', WorkDate, SuffixCode, VarietyGroup."No. Series");
                    4:
                        if (VarietyGroup."Copy Naming Variety 4" = VarietyGroup."Copy Naming Variety 4"::TableCodeAndNoSeries) and
                          (VarietyGroup."No. Series" <> '') then
                            NoSeriesMgt.InitSeries(VarietyGroup."No. Series", '', WorkDate, SuffixCode, VarietyGroup."No. Series");
                end;
                if StrPos(VarietyTableFrom, '-') > 0 then
                    PrefixCode := CopyStr(VarietyTableFrom, 1, StrPos(VarietyTableFrom, '-') - 1)
                else
                    PrefixCode := VarietyTableFrom;
                NewTableCode := CopyStr(PrefixCode + '-' + SuffixCode, 1, MaxStrLen(NewTableCode));
            end else begin
                NewTableCode := VarietyTableTo;
            end;
            exit(NewTableCode);
        end else
            exit(VarietyTableFrom);
        //-NPR4.19
    end;

    local procedure UpdateAndCopyVariety(Variety: Code[20]; VarietyTableFrom: Code[20]; VarietyTableTo: Code[20]; VarietyValue: Code[20])
    var
        ExistingVarityValue: Record "NPR Variety Value";
        VarietyTable: Record "NPR Variety Table";
        NewVarietyValue: Record "NPR Variety Value";
    begin
        //-NPR4.19
        if Variety <> '' then begin
            if VarietyValue <> '' then begin
                if not ExistingVarityValue.Get(Variety, VarietyTableFrom, VarietyValue) then
                    ExistingVarityValue.Init;
                if not NewVarietyValue.Get(Variety, VarietyTableTo, VarietyValue) then begin
                    //DoubleCheck the table is not Locked
                    //-NPR4.19
                    //VarietyTable.GET(Variety,VarietyTableTo);
                    //VarietyTable.TESTFIELD("Lock Table",FALSE);
                    //+NPR4.19
                    NewVarietyValue.Init;
                    NewVarietyValue.Validate(Type, Variety);
                    NewVarietyValue.Validate(Table, VarietyTableTo);
                    NewVarietyValue.Validate(Value, VarietyValue);
                    if ExistingVarityValue.Description <> '' then
                        NewVarietyValue.Validate(Description, ExistingVarityValue.Description);
                    if ExistingVarityValue."Sort Order" <> 0 then
                        NewVarietyValue.Validate("Sort Order", ExistingVarityValue."Sort Order");
                    NewVarietyValue.Insert(true);
                end;
            end;
        end;
        //+NPR4.19
    end;

    local procedure UpdateVarietyValue(ParType: Code[20]; ParTable: Code[20]; ParValue: Code[20]; ParSortOrder: Integer; ParDescription: Text[30])
    var
        VarietyValue: Record "NPR Variety Value";
        VarietyTable: Record "NPR Variety Table";
    begin
        // IF Type <> '' THEN  BEGIN
        //  IF Value <> '' THEN BEGIN
        //    IF NOT VarietyValue.GET(Type,Table,Value) THEN BEGIN
        //      //DoubleCheck the table is not Locked
        //      //-NPR4.19
        //      VarietyTable.GET(Type,Table);
        //      VarietyTable.TESTFIELD("Lock Table",FALSE);
        //      //+NPR4.19
        //      VarietyValue.INIT;
        //      VarietyValue.VALIDATE(Type,Type);
        //      VarietyValue.VALIDATE(Table,ParTable);
        //      VarietyValue.VALIDATE(Value,Value);
        //      VarietyValue.VALIDATE(Description,Description);
        //      VarietyValue.VALIDATE("Sort Order",SortOrder);
        //      VarietyValue.INSERT(TRUE);
        //    END;
        //  END;
        // END;

        if ParType <> '' then begin
            if ParValue <> '' then begin
                Clear(VarietyValue);
                if not VarietyValue.Get(ParType, ParTable, ParValue) then begin
                    //DoubleCheck the table is not Locked
                    //-NPR4.19
                    //CLEAR(VarietyTable);
                    //VarietyTable.GET(ParType,ParTable);
                    //VarietyTable.TESTFIELD("Lock Table",FALSE);
                    //+NPR4.19
                    VarietyValue.Init;
                    VarietyValue.Type := ParType;
                    VarietyValue.Table := ParTable;
                    VarietyValue.Value := ParValue;
                    VarietyValue.Description := ParDescription;
                    VarietyValue."Sort Order" := ParSortOrder;
                    VarietyValue.Insert;
                end;
            end;
        end;
    end;

    local procedure CreateVariant(var ItemWkshVariantLine: Record "NPR Item Worksh. Variant Line")
    begin
        //-NPR5.29 [263917]
        //IF ItemVariant.GetFromVariety(ItemWkshVariantLine."Item No.", ItemWkshVariantLine."Variety 1 Value",
        if VarietyCloneData.GetFromVariety(ItemVariant, ItemWkshVariantLine."Item No.", ItemWkshVariantLine."Variety 1 Value",
        //+NPR5.29 [263917]
                                     ItemWkshVariantLine."Variety 2 Value", ItemWkshVariantLine."Variety 3 Value",
                                     ItemWkshVariantLine."Variety 4 Value") then
            Error(Txt100);

        ItemWkshVariantLine.CalcFields("Variety 1 Table", "Variety 2 Table", "Variety 3 Table", "Variety 4 Table",
                                       "Variety 1", "Variety 2", "Variety 3", "Variety 4");
        ItemVariant.Init;
        ItemVariant."Item No." := ItemWkshVariantLine."Item No.";
        if ItemWkshVariantLine."Variant Code" = '' then begin
            //-NPR5.43 [317108]
            //ItemVariant.Code := VarietyCloneData.GetNextVariantCode;
            ItemVariant.Code := VarietyCloneData.GetNextVariantCode(ItemWkshVariantLine."Item No.",
                                                                    ItemWkshVariantLine."Variety 1 Value", ItemWkshVariantLine."Variety 2 Value",
                                                                    ItemWkshVariantLine."Variety 3 Value", ItemWkshVariantLine."Variety 4 Value");
            //+NPR5.43 [317108]
            ItemWkshVariantLine."Variant Code" := ItemVariant.Code;
            //-NPR5.22
            //END
        end else begin
            ItemVariant.Code := ItemWkshVariantLine."Variant Code";
        end;
        //+NPR5.22
        ItemVariant."NPR Variety 1" := ItemWkshVariantLine."Variety 1";
        ItemVariant."NPR Variety 1 Table" := ItemWkshVariantLine."Variety 1 Table";
        ItemVariant."NPR Variety 1 Value" := ItemWkshVariantLine."Variety 1 Value";
        ItemVariant."NPR Variety 2" := ItemWkshVariantLine."Variety 2";
        ItemVariant."NPR Variety 2 Table" := ItemWkshVariantLine."Variety 2 Table";
        ItemVariant."NPR Variety 2 Value" := ItemWkshVariantLine."Variety 2 Value";
        ItemVariant."NPR Variety 3" := ItemWkshVariantLine."Variety 3";
        ItemVariant."NPR Variety 3 Table" := ItemWkshVariantLine."Variety 3 Table";
        ItemVariant."NPR Variety 3 Value" := ItemWkshVariantLine."Variety 3 Value";
        ItemVariant."NPR Variety 4" := ItemWkshVariantLine."Variety 4";
        ItemVariant."NPR Variety 4 Table" := ItemWkshVariantLine."Variety 4 Table";
        ItemVariant."NPR Variety 4 Value" := ItemWkshVariantLine."Variety 4 Value";
        ItemVariant."NPR Blocked" := ItemWkshVariantLine.Blocked;

        if ItemWkshVariantLine.Description <> '' then begin
            ItemVariant.Description := ItemWkshVariantLine.Description;
        end else begin
            GetItem(ItemVariant."Item No.");
            VarietyCloneData.FillDescription(ItemVariant, Item);
        end;

        ItemVariant.Insert(true);
    end;

    local procedure UpdateVariant()
    begin
    end;

    local procedure UpdateItemAttributes()
    var
        AttributeKey: Record "NPR Attribute Key";
        AttributeValueSet: Record "NPR Attribute Value Set";
        AttributeID: Record "NPR Attribute ID";
        AttributeManagement: Codeunit "NPR Attribute Management";
        WorksheetReference: Integer;
        TxtAttributeNotSetUp: Label 'Attribute %1 is not set up on the Item table, so it cannot be used with item %2.';
    begin
        //-NPR4.19
        AttributeKey.SetCurrentKey("Table ID", "MDR Code PK");
        AttributeKey.SetFilter("Table ID", '=%1', DATABASE::"NPR Item Worksheet Line");
        AttributeKey.SetFilter("MDR Code PK", '=%1', ItemWkshLine."Worksheet Template Name");
        AttributeKey.SetFilter("MDR Code 2 PK", '=%1', ItemWkshLine."Worksheet Name");
        AttributeKey.SetFilter("MDR Line PK", '=%1', ItemWkshLine."Line No.");
        AttributeKey.SetFilter("MDR Line 2 PK", '=%1', 0);

        // Fill array
        if AttributeKey.FindFirst then begin
            AttributeValueSet.Reset;
            AttributeValueSet.SetRange("Attribute Set ID", AttributeKey."Attribute Set ID");
            if AttributeValueSet.FindSet then
                repeat
                    if not AttributeID.Get(DATABASE::Item, AttributeValueSet."Attribute Code") then
                        Error(StrSubstNo(TxtAttributeNotSetUp, AttributeValueSet."Attribute Code", ItemWkshLine."Item No."));
                    AttributeManagement.SetMasterDataAttributeValue(DATABASE::Item, AttributeID."Shortcut Attribute ID", ItemWkshLine."Item No.", AttributeValueSet."Text Value");
                until AttributeValueSet.Next = 0;
        end;
        //+NPR4.19
    end;

    local procedure CreateRegisteredWorksheetLines()
    begin
        if ItemWorksheetTemplate."Register Lines" then begin
            CopyToRegisteredWorksheetLine;

            ItemWkshVariantLine.Reset;
            ItemWkshVariantLine.SetRange("Worksheet Template Name", ItemWkshLine."Worksheet Template Name");
            ItemWkshVariantLine.SetRange("Worksheet Name", ItemWkshLine."Worksheet Name");
            ItemWkshVariantLine.SetRange("Worksheet Line No.", ItemWkshLine."Line No.");
            if ItemWkshVariantLine.FindSet then
                repeat
                    CopyToRegisteredWorksheetVariantLine;
                until ItemWkshVariantLine.Next = 0;

            ItemWorksheetVarietyValue.Reset;
            ItemWorksheetVarietyValue.SetRange("Worksheet Template Name", ItemWkshLine."Worksheet Template Name");
            ItemWorksheetVarietyValue.SetRange("Worksheet Name", ItemWkshLine."Worksheet Name");
            ItemWorksheetVarietyValue.SetRange("Worksheet Line No.", ItemWkshLine."Line No.");
            if ItemWorksheetVarietyValue.FindSet then
                repeat
                    CopyToRegisteredWorksheetVarietyValueLine;
                until ItemWorksheetVarietyValue.Next = 0;
        end;
        //-NPR5.55 [388960]
        /*
        IF ItemWorksheetTemplate."Delete Processed Lines" THEN
          IF ItemWkshLine.Status = ItemWkshLine.Status :: Processed THEN
            //-NPR5.35 [268786]
            IF NOT (ItemWorksheetTemplate."Leave Skipped Line on Register" AND (ItemWkshLine.Action = ItemWkshLine.Action::Skip)) THEN
              ItemWkshLine.DELETE(TRUE);
            //+NPR5.35 [268786]
        */
        //+NPR5.55 [388960]

    end;

    local procedure CopyToRegisteredWorksheetLine()
    begin
        with RegisteredWorksheetLine do begin
            "Registered Worksheet No." := LastRegisteredWorksheetNo;
            "Line No." := ItemWkshLine."Line No.";
            Action := ItemWkshLine.Action;
            "Existing Item No." := ItemWkshLine."Existing Item No.";
            "Item No." := ItemWkshLine."Item No.";
            "Vendor Item No." := ItemWkshLine."Vendor Item No.";
            "Internal Bar Code" := ItemWkshLine."Internal Bar Code";
            "Vendor No." := ItemWkshLine."Vendor No.";
            Description := ItemWkshLine.Description;
            "Direct Unit Cost" := ItemWkshLine."Direct Unit Cost";
            "Unit Price (LCY)" := ItemWkshLine."Sales Price";
            "Use Variant" := ItemWkshLine."Use Variant";
            "Base Unit of Measure" := ItemWkshLine."Base Unit of Measure";
            "Inventory Posting Group" := ItemWkshLine."Inventory Posting Group";
            "Costing Method" := ItemWkshLine."Costing Method";
            "Vendors Bar Code" := ItemWkshLine."Vendors Bar Code";
            "VAT Bus. Posting Group" := ItemWkshLine."VAT Bus. Posting Group";
            "VAT Bus. Posting Gr. (Price)" := ItemWkshLine."VAT Bus. Posting Gr. (Price)";
            "Gen. Prod. Posting Group" := ItemWkshLine."Gen. Prod. Posting Group";
            "No. Series" := ItemWkshLine."No. Series";
            "Tax Group Code" := ItemWkshLine."Tax Group Code";
            "VAT Prod. Posting Group" := ItemWkshLine."VAT Prod. Posting Group";
            "Global Dimension 1 Code" := ItemWkshLine."Global Dimension 2 Code";
            Status := ItemWkshLine.Status;
            "Status Comment" := ItemWkshLine."Status Comment";
            "Variety 1" := ItemWkshLine."Variety 1";
            "Variety 1 Table (Base)" := ItemWkshLine."Variety 1 Table (Base)";
            "Create Copy of Variety 1 Table" := ItemWkshLine."Create Copy of Variety 1 Table";
            "Variety 1 Table (New)" := ItemWkshLine."Variety 1 Table (New)";
            "Variety 1 Lock Table" := ItemWkshLine."Variety 1 Lock Table";
            "Variety 2" := ItemWkshLine."Variety 1";
            "Variety 2 Table (Base)" := ItemWkshLine."Variety 2 Table (Base)";
            "Create Copy of Variety 2 Table" := ItemWkshLine."Create Copy of Variety 2 Table";
            "Variety 2 Table (New)" := ItemWkshLine."Variety 2 Table (New)";
            "Variety 2 Lock Table" := ItemWkshLine."Variety 2 Lock Table";
            "Variety 3" := ItemWkshLine."Variety 1";
            "Variety 3 Table (Base)" := ItemWkshLine."Variety 3 Table (Base)";
            "Create Copy of Variety 3 Table" := ItemWkshLine."Create Copy of Variety 3 Table";
            "Variety 3 Table (New)" := ItemWkshLine."Variety 3 Table (New)";
            "Variety 3 Lock Table" := ItemWkshLine."Variety 3 Lock Table";
            "Variety 4 Table (Base)" := ItemWkshLine."Variety 4 Table (Base)";
            "Create Copy of Variety 4 Table" := ItemWkshLine."Create Copy of Variety 4 Table";
            "Variety 4 Table (New)" := ItemWkshLine."Variety 4 Table (New)";
            "Variety 4 Lock Table" := ItemWkshLine."Variety 4 Lock Table";
            "Cross Variety No." := ItemWkshLine."Cross Variety No.";
            "Variety Group" := ItemWkshLine."Variety Group";
            "Sales Unit of Measure" := ItemWkshLine."Sales Unit of Measure";
            "Purch. Unit of Measure" := ItemWkshLine."Purch. Unit of Measure";
            "Manufacturer Code" := ItemWkshLine."Manufacturer Code";
            "Item Category Code" := ItemWkshLine."Item Category Code";
            "Product Group Code" := ItemWkshLine."Product Group Code";
            "Item Group" := ItemWkshLine."Item Group";
            "Variant Code" := ItemWkshLine."Variant Code";
            "Sales Price Currency Code" := ItemWkshLine."Sales Price Currency Code";
            "Purchase Price Currency Code" := ItemWkshLine."Purchase Price Currency Code";
            //-NPR5.38 [297587]
            "Sales Price Start Date" := ItemWkshLine."Sales Price Start Date";
            "Purchase Price Start Date" := ItemWkshLine."Purchase Price Start Date";
            //+NPR5.38 [297587]
            //-NPR4.19
            "Tariff No." := ItemWkshLine."Tariff No.";
            //+NPR4.19
            //-NPR5.25 [246088]
            "No. 2" := ItemWkshLine."No. 2";
            Type := ItemWkshLine.Type;
            "Shelf No." := ItemWkshLine."Shelf No.";
            "Item Disc. Group" := ItemWkshLine."Item Disc. Group";
            "Allow Invoice Disc." := ItemWkshLine."Allow Invoice Disc.";
            "Statistics Group" := ItemWkshLine."Statistics Group";
            "Commission Group" := ItemWkshLine."Commission Group";
            "Price/Profit Calculation" := ItemWkshLine."Price/Profit Calculation";
            "Profit %" := ItemWkshLine."Profit %";
            "Lead Time Calculation" := ItemWkshLine."Lead Time Calculation";
            "Reorder Point" := ItemWkshLine."Reorder Point";
            "Maximum Inventory" := ItemWkshLine."Maximum Inventory";
            "Reorder Quantity" := ItemWkshLine."Reorder Quantity";
            "Unit List Price" := ItemWkshLine."Unit List Price";
            "Duty Due %" := ItemWkshLine."Duty Due %";
            "Duty Code" := ItemWkshLine."Duty Code";
            "Units per Parcel" := ItemWkshLine."Units per Parcel";
            "Unit Volume" := ItemWkshLine."Unit Volume";
            Durability := ItemWkshLine.Durability;
            "Freight Type" := ItemWkshLine."Freight Type";
            "Duty Unit Conversion" := ItemWkshLine."Duty Unit Conversion";
            "Country/Region Purchased Code" := ItemWkshLine."Country/Region Purchased Code";
            "Budget Quantity" := ItemWkshLine."Budget Quantity";
            "Budgeted Amount" := ItemWkshLine."Budgeted Amount";
            "Budget Profit" := ItemWkshLine."Budget Profit";
            Blocked := ItemWkshLine.Blocked;
            "Price Includes VAT" := ItemWkshLine."Price Includes VAT";
            "Country/Region of Origin Code" := ItemWkshLine."Country/Region of Origin Code";
            "Automatic Ext. Texts" := ItemWkshLine."Automatic Ext. Texts";
            Reserve := ItemWkshLine.Reserve;
            "Stockout Warning" := ItemWkshLine."Stockout Warning";
            "Prevent Negative Inventory" := ItemWkshLine."Prevent Negative Inventory";
            "Assembly Policy" := ItemWkshLine."Assembly Policy";
            GTIN := ItemWkshLine.GTIN;
            "Lot Size" := ItemWkshLine."Lot Size";
            "Serial Nos." := ItemWkshLine."Serial Nos.";
            "Scrap %" := ItemWkshLine."Scrap %";
            "Inventory Value Zero" := ItemWkshLine."Inventory Value Zero";
            "Discrete Order Quantity" := ItemWkshLine."Discrete Order Quantity";
            "Minimum Order Quantity" := ItemWkshLine."Minimum Order Quantity";
            "Maximum Order Quantity" := ItemWkshLine."Maximum Order Quantity";
            "Safety Stock Quantity" := ItemWkshLine."Safety Stock Quantity";
            "Order Multiple" := ItemWkshLine."Order Multiple";
            "Safety Lead Time" := ItemWkshLine."Safety Lead Time";
            "Flushing Method" := ItemWkshLine."Flushing Method";
            "Replenishment System" := ItemWkshLine."Replenishment System";
            "Reordering Policy" := ItemWkshLine."Reordering Policy";
            "Include Inventory" := ItemWkshLine."Include Inventory";
            "Manufacturing Policy" := ItemWkshLine."Manufacturing Policy";
            "Rescheduling Period" := ItemWkshLine."Rescheduling Period";
            "Lot Accumulation Period" := ItemWkshLine."Lot Accumulation Period";
            "Dampener Period" := ItemWkshLine."Dampener Period";
            "Dampener Quantity" := ItemWkshLine."Dampener Quantity";
            "Overflow Level" := ItemWkshLine."Overflow Level";
            "Service Item Group" := ItemWkshLine."Service Item Group";
            "Item Tracking Code" := ItemWkshLine."Item Tracking Code";
            "Lot Nos." := ItemWkshLine."Lot Nos.";
            "Expiration Calculation" := ItemWkshLine."Expiration Calculation";
            "Special Equipment Code" := ItemWkshLine."Special Equipment Code";
            "Put-away Template Code" := ItemWkshLine."Put-away Template Code";
            "Put-away Unit of Measure Code" := ItemWkshLine."Put-away Unit of Measure Code";
            "Phys Invt Counting Period Code" := ItemWkshLine."Phys Invt Counting Period Code";
            "Use Cross-Docking" := ItemWkshLine."Use Cross-Docking";
            "Custom Text 1" := ItemWkshLine."Custom Text 1";
            "Custom Text 2" := ItemWkshLine."Custom Text 2";
            "Custom Text 3" := ItemWkshLine."Custom Text 3";
            "Custom Text 4" := ItemWkshLine."Custom Text 4";
            "Custom Text 5" := ItemWkshLine."Custom Text 5";
            "Custom Price 1" := ItemWkshLine."Custom Price 1";
            "Custom Price 2" := ItemWkshLine."Custom Price 2";
            "Custom Price 3" := ItemWkshLine."Custom Price 3";
            "Custom Price 4" := ItemWkshLine."Custom Price 4";
            "Custom Price 5" := ItemWkshLine."Custom Price 5";
            "Group sale" := ItemWkshLine."Group sale";
            //-NPR5.33 [279610]
            //Properties := ItemWkshLine.Properties;
            //"Item Sales Prize" := ItemWkshLine."Item Sales Prize";
            //"Program No." := ItemWkshLine."Program No.";
            //+NPR5.33 [279610]
            Season := ItemWkshLine.Season;
            //-NPR5.33 [279610]
            //Assortment := ItemWkshLine.Assortment;
            //+NPR5.33 [279610]
            "Label Barcode" := ItemWkshLine."Label Barcode";
            //-NPR5.33 [279610]
            //Auto := ItemWkshLine.Auto;
            //"Out of stock" := ItemWkshLine."Out of stock";
            //"Print quantity" := ItemWkshLine."Print quantity";
            //"Labels per item" := ItemWkshLine."Labels per item";
            //+NPR5.33 [279610]
            "Explode BOM auto" := ItemWkshLine."Explode BOM auto";
            "Guarantee voucher" := ItemWkshLine."Guarantee voucher";
            //-NPR5.33 [279610]
            //ISBN := ItemWkshLine.ISBN;
            //+NPR5.33 [279610]
            "Cannot edit unit price" := ItemWkshLine."Cannot edit unit price";
            //-NPR5.33 [279610]
            //"Label Date" := ItemWkshLine."Label Date";
            //"Open quarry unit cost" := ItemWkshLine."Open quarry unit cost";
            //+NPR5.33 [279610]
            "Second-hand number" := ItemWkshLine."Second-hand number";
            Condition := ItemWkshLine.Condition;
            "Second-hand" := ItemWkshLine."Second-hand";
            "Guarantee Index" := ItemWkshLine."Guarantee Index";
            //"Hand Out Item No." := ItemWkshLine."Hand Out Item No.";
            "Insurrance category" := ItemWkshLine."Insurrance category";
            "Item Brand" := ItemWkshLine."Item Brand";
            //Model := ItemWkshLine.Model;
            "Type Retail" := ItemWkshLine."Type Retail";
            "No Print on Reciept" := ItemWkshLine."No Print on Reciept";
            "Print Tags" := ItemWkshLine."Print Tags";
            //"Basis Number" := ItemWkshLine."Basis Number";
            "Change quantity by Photoorder" := ItemWkshLine."Change quantity by Photoorder";
            //"Picture Extention" := ItemWkshLine."Picture Extention";
            //"Item Type" := ItemWkshLine."Item Type";
            //"Item - Weight item ref." := ItemWkshLine."Item - Weight item ref.";
            "Std. Sales Qty." := ItemWkshLine."Std. Sales Qty.";
            "Blocked on Pos" := ItemWkshLine."Blocked on Pos";
            "Ticket Type" := ItemWkshLine."Ticket Type";
            "Magento Status" := ItemWkshLine."Magento Status";
            Backorder := ItemWkshLine.Backorder;
            "Product New From" := ItemWkshLine."Product New From";
            "Product New To" := ItemWkshLine."Product New To";
            "Attribute Set ID" := ItemWkshLine."Attribute Set ID";
            "Special Price" := ItemWkshLine."Special Price";
            "Special Price From" := ItemWkshLine."Special Price From";
            "Special Price To" := ItemWkshLine."Special Price To";
            "Magento Brand" := ItemWkshLine."Magento Brand";
            "Display Only" := ItemWkshLine."Display Only";
            "Magento Item" := ItemWkshLine."Magento Item";
            "Magento Name" := ItemWkshLine."Magento Name";
            "Seo Link" := ItemWkshLine."Seo Link";
            "Meta Title" := ItemWkshLine."Meta Title";
            "Meta Description" := ItemWkshLine."Meta Description";
            "Featured From" := ItemWkshLine."Featured From";
            "Featured To" := ItemWkshLine."Featured To";
            "Routing No." := ItemWkshLine."Routing No.";
            "Production BOM No." := ItemWkshLine."Production BOM No.";
            "Overhead Rate" := ItemWkshLine."Overhead Rate";
            "Order Tracking Policy" := ItemWkshLine."Order Tracking Policy";
            Critical := ItemWkshLine.Critical;
            "Common Item No." := ItemWkshLine."Common Item No.";
            //+NPR5.25 [246088]
            Insert;
        end;
    end;

    local procedure CopyToRegisteredWorksheetVariantLine()
    begin
        with RegisteredWorksheetVariantLine do begin
            "Registered Worksheet No." := LastRegisteredWorksheetNo;
            "Registered Worksheet Line No." := ItemWkshLine."Line No.";
            "Line No." := ItemWkshVariantLine."Line No.";
            Level := ItemWkshVariantLine.Level;
            Action := ItemWkshVariantLine.Action;
            "Item No." := ItemWkshVariantLine."Item No.";
            "Existing Item No." := ItemWkshVariantLine."Existing Item No.";
            "Existing Variant Code" := ItemWkshVariantLine."Existing Variant Code";
            "Variant Code" := ItemWkshVariantLine."Variant Code";
            "Internal Bar Code" := ItemWkshVariantLine."Internal Bar Code";
            "Sales Price" := ItemWkshVariantLine."Sales Price";
            "Direct Unit Cost" := ItemWkshVariantLine."Direct Unit Cost";
            "Vendors Bar Code" := ItemWkshVariantLine."Vendors Bar Code";
            "Heading Text" := ItemWkshVariantLine."Heading Text";
            "Variety 1 Value" := ItemWkshVariantLine."Variety 1 Value";
            "Variety 2 Value" := ItemWkshVariantLine."Variety 2 Value";
            "Variety 3 Value" := ItemWkshVariantLine."Variety 3 Value";
            "Variety 4 Value" := ItemWkshVariantLine."Variety 4 Value";
            Description := ItemWkshVariantLine.Description;
            Blocked := ItemWkshVariantLine.Blocked;
            Insert;
        end;
    end;

    local procedure CopyToRegisteredWorksheetVarietyValueLine()
    begin
        with RegisteredWorksheetVarietyValue do begin
            "Registered Worksheet No." := LastRegisteredWorksheetNo;
            "Registered Worksheet Line No." := ItemWorksheetVarietyValue."Worksheet Line No.";
            Type := ItemWorksheetVarietyValue.Type;
            Table := ItemWorksheetVarietyValue.Table;
            Value := ItemWorksheetVarietyValue.Value;
            "Sort Order" := ItemWorksheetVarietyValue."Sort Order";
            Description := ItemWorksheetVarietyValue.Description;
            Insert;
        end;
    end;

    local procedure LastRegisteredWorksheetNo(): Integer
    var
        RegisteredItemWorksheet: Record "NPR Registered Item Works.";
    begin
        RegisteredItemWorksheet.FindLast;
        exit(RegisteredItemWorksheet."No.");
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        if Item."No." <> ItemNo then
            Item.Get(ItemNo);
    end;

    local procedure ProcessLineSalesPrices()
    var
        SalesPrice: Record "Sales Price";
        ItemWorksheeVarieties: Record "NPR Item Worksh. Variety Value";
        SalesPriceStartDate: Date;
        SalesPriceEndDate: Date;
        SalesUnitOfMeasure: Code[10];
    begin
        //-NPR5.50 [353052]
        if ItemWkshLine."Sales Price" = 0 then
            exit;
        GetItem(ItemWkshLine."Item No.");
        if ItemWkshLine."Sales Price" <> Item."Unit Price" then begin
            if ItemWkshLine."Sales Price Currency Code" = '' then begin
                if ItemWkshLine."Sales Price Start Date" <= WorkDate then begin
                    Item.Validate("Unit Price", ItemWkshLine."Sales Price");
                    Item.Modify(true);
                end;
            end;
        end;

        if ItemWorksheetTemplate."Sales Price Handling" = ItemWorksheetTemplate."Sales Price Handling"::Item then
            exit;

        if ItemWkshLine."Sales Unit of Measure" <> '' then
            SalesUnitOfMeasure := ItemWkshLine."Sales Unit of Measure"
        else
            SalesUnitOfMeasure := Item."Sales Unit of Measure";

        SalesPrice.Reset;
        SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::"All Customers");
        SalesPrice.SetRange("Item No.", ItemWkshLine."Item No.");
        SalesPrice.SetRange("Variant Code", '');
        SalesPrice.SetRange("Currency Code", ItemWkshLine."Sales Price Currency Code");
        if SalesUnitOfMeasure = Item."Sales Unit of Measure" then
            SalesPrice.SetFilter("Unit of Measure Code", '%1|%2', '', SalesUnitOfMeasure)
        else
            SalesPrice.SetRange("Unit of Measure Code", SalesUnitOfMeasure);
        SalesPrice.SetRange("Minimum Quantity", 0, 1);
        case ItemWorksheetTemplate."Sales Price Handling" of
            ItemWorksheetTemplate."Sales Price Handling"::"Item+Variant":
                begin
                    SalesPriceStartDate := 0D;
                    SalesPriceEndDate := 0D;
                end;
            ItemWorksheetTemplate."Sales Price Handling"::"Item+Date",
            ItemWorksheetTemplate."Sales Price Handling"::"Item+Variant+Date":
                begin
                    SalesPriceStartDate := WorkDate;
                    if ItemWkshLine."Sales Price Start Date" <> 0D then
                        SalesPriceStartDate := ItemWkshLine."Sales Price Start Date";
                    SalesPrice.SetFilter("Starting Date", '>%1', SalesPriceStartDate);
                    if SalesPrice.FindFirst then
                        SalesPriceEndDate := SalesPrice."Starting Date" - 1
                    else
                        SalesPriceEndDate := 0D;
                end;
        end;
        SalesPrice.SetRange("Starting Date", SalesPriceStartDate);
        if SalesPrice.FindFirst then begin
            if SalesPrice."Ending Date" <> SalesPriceEndDate then begin
                SalesPrice.Validate("Ending Date", SalesPriceEndDate);
            end;
            if SalesPrice."Unit Price" <> ItemWkshLine."Sales Price" then begin
                SalesPrice.Validate("Unit Price", ItemWkshLine."Sales Price");
            end;
            if not SalesPrice."NPR Is Master" then begin
                SalesPrice.Validate("NPR Master Record Reference", Format(SalesPrice.RecordId));
                SalesPrice.Validate("NPR Is Master", true);
            end;
            SalesPrice.Modify(true);
        end else begin
            SalesPrice.Init;
            SalesPrice.Validate("Item No.", ItemWkshLine."Item No.");
            SalesPrice.Validate("Sales Type", SalesPrice."Sales Type"::"All Customers");
            SalesPrice."Sales Code" := '';
            SalesPrice.Validate("Starting Date", SalesPriceStartDate);
            SalesPrice.Validate("Currency Code", ItemWkshLine."Sales Price Currency Code");
            SalesPrice.Validate("Variant Code", '');
            SalesPrice.Validate("Unit of Measure Code", SalesUnitOfMeasure);
            SalesPrice.Validate("Minimum Quantity", 0);
            SalesPrice.Validate("Unit Price", ItemWkshLine."Sales Price");
            SalesPrice.Validate("Ending Date", SalesPriceEndDate);
            SalesPrice.Validate("NPR Master Record Reference", Format(SalesPrice.RecordId));
            SalesPrice.Validate("NPR Is Master", true);
            SalesPrice.Insert(true);
        end;
        case ItemWorksheetTemplate."Sales Price Handling" of
            ItemWorksheetTemplate."Sales Price Handling"::"Item+Variant":
                begin
                    CloseRelatedSalesPrices(SalesPrice, WorkDate - 1);
                end;
            ItemWorksheetTemplate."Sales Price Handling"::"Item+Date",
            ItemWorksheetTemplate."Sales Price Handling"::"Item+Variant+Date":
                begin
                    CloseRelatedSalesPrices(SalesPrice, SalesPriceStartDate - 1);
                end;
        end;
        //+NPR5.50 [353052]

        //-NPR5.50 [353052]
        // IF ItemWkshLine."Sales Price" = 0 THEN
        //  EXIT;
        // //-NPR4.19
        // //Item.GET(ItemWkshLine."Item No.");
        // GetItem(ItemWkshLine."Item No.");
        // //+NPR4.19
        // IF ItemWkshLine."Sales Price" <> Item."Unit Price" THEN BEGIN
        //  //-NPR5.23 [242498]
        //  IF ItemWkshLine."Sales Price Currency Code" = '' THEN BEGIN
        //  //+NPR5.23 [242498]
        //    //-NPR5.38 [300754]
        //    IF ItemWkshLine."Sales Price Start Date" <= WORKDATE THEN BEGIN
        //    //+NPR5.38 [300754]
        //      Item.VALIDATE("Unit Price",ItemWkshLine."Sales Price");
        //      Item.MODIFY(TRUE);
        //      //-NPR5.23 [242498]
        //    //-NPR5.38 [300754]
        //    END;
        //    //+NPR5.38 [300754]
        //  END;
        //  //+NPR5.23 [242498]
        // END;
        //
        // //-NPR5.23 [242498]
        // //IF ItemWorksheetTemplate."Sales Price Handling" = ItemWorksheetTemplate."Sales Price Handling" :: "Item+Variant" THEN  BEGIN
        // IF ItemWorksheetTemplate."Sales Price Handling" = ItemWorksheetTemplate."Sales Price Handling" :: Item THEN
        //  EXIT;
        // //+NPR5.23 [242498]
        // SalesPrice.RESET;
        // SalesPrice.SETRANGE("Sales Type",SalesPrice."Sales Type"::"All Customers");
        // SalesPrice.SETRANGE("Item No.",ItemWkshLine."Item No.");
        // SalesPrice.SETRANGE("Variant Code",'');
        // SalesPrice.SETRANGE("Is Master",TRUE);
        // SalesPrice.SETRANGE("Currency Code",ItemWkshLine."Sales Price Currency Code");
        // //-NPR5.23 [242498]
        // //-NPR5.38 [297587]
        // IF ItemWkshLine."Sales Price Start Date" <> 0D THEN
        //  SalesPrice.SETRANGE("Starting Date",ItemWkshLine."Sales Price Start Date")
        // ELSE
        // //+NPR5.38 [297587]
        //  SalesPrice.SETRANGE("Starting Date",0D,WORKDATE);
        // IF SalesPrice.FINDLAST THEN BEGIN
        // //IF SalesPrice.FINDFIRST THEN BEGIN
        // //+NPR5.23 [242498]
        //  //Found Master
        //  IF SalesPrice."Unit Price"  <> ItemWkshLine."Sales Price" THEN BEGIN
        //    //-NPR5.23 [242498]
        //    //-NPR5.38 [297587]
        //    //IF (ItemWorksheetTemplate."Sales Price Handling" = ItemWorksheetTemplate."Sales Price Handling"::"Item+Variant") OR (SalesPrice."Starting Date" = WORKDATE) THEN BEGIN
        //    IF (ItemWorksheetTemplate."Sales Price Handling" = ItemWorksheetTemplate."Sales Price Handling"::"Item+Variant") OR (SalesPrice."Starting Date" = WORKDATE) OR
        //      (ItemWkshLine."Sales Price Start Date" <> 0D)  THEN BEGIN
        //    //+NPR5.38 [297587]
        //    //+NPR5.23 [242498]
        //      SalesPrice.VALIDATE("Unit Price",ItemWkshLine."Sales Price");
        //      SalesPrice.MODIFY(TRUE);
        //    //-NPR5.23 [242498]
        //    END ELSE BEGIN
        //      SalesPrice.VALIDATE("Ending Date",WORKDATE-1);
        //      SalesPrice.MODIFY(TRUE);
        //      SalesPrice.VALIDATE("Ending Date",0D);
        //      SalesPrice.VALIDATE("Unit Price",ItemWkshLine."Sales Price");
        //      SalesPrice.VALIDATE("Starting Date",WORKDATE);
        //      SalesPrice.INSERT(TRUE);
        //    END;
        //    //+NPR5.23 [242498]
        //  END;
        //  RecRefTextMaster :=  SalesPrice."Master Record Reference";
        // END ELSE BEGIN
        //  SalesPrice.SETRANGE("Is Master",FALSE);
        //  //-NPR5.23 [242498]
        //  //IF SalesPrice.FINDFIRST THEN BEGIN
        //  IF SalesPrice.FINDLAST THEN BEGIN
        //  //+NPR5.23 [242498]
        //    //Found Non-Master to make Master
        //    IF SalesPrice."Unit Price"  <> ItemWkshLine."Sales Price" THEN
        //      //-NPR5.38 [297587]
        //      //IF (ItemWorksheetTemplate."Sales Price Handling" = ItemWorksheetTemplate."Sales Price Handling"::"Item+Variant") OR (SalesPrice."Starting Date" = WORKDATE) THEN BEGIN
        //      IF (ItemWorksheetTemplate."Sales Price Handling" = ItemWorksheetTemplate."Sales Price Handling"::"Item+Variant") OR (SalesPrice."Starting Date" = WORKDATE) OR
        //        (ItemWkshLine."Sales Price Start Date" <> 0D)  THEN BEGIN
        //      //+NPR5.38 [297587]
        //        SalesPrice.VALIDATE("Unit Price",ItemWkshLine."Sales Price");
        //      //-NPR5.23 [242498]
        //      END ELSE BEGIN
        //        SalesPrice.VALIDATE("Ending Date",WORKDATE-1);
        //        SalesPrice.MODIFY(TRUE);
        //        SalesPrice.VALIDATE("Ending Date",0D);
        //        SalesPrice.VALIDATE("Unit Price",ItemWkshLine."Sales Price");
        //        SalesPrice.VALIDATE("Starting Date",WORKDATE);
        //        SalesPrice.INSERT(TRUE);
        //      END;
        //      //+NPR5.23 [242498]
        //    RecRef.GETTABLE(SalesPrice);
        //    SalesPrice.VALIDATE("Master Record Reference",FORMAT(RecRef.RECORDID));
        //    SalesPrice.VALIDATE("Is Master",TRUE);
        //    SalesPrice.MODIFY(TRUE);
        //  END ELSE BEGIN
        //    //Create a new Master
        //    SalesPrice.INIT;
        //    SalesPrice.VALIDATE("Sales Type",SalesPrice."Sales Type"::"All Customers");
        //    SalesPrice.VALIDATE("Item No.",ItemWkshLine."Item No.");
        //    SalesPrice.VALIDATE("Unit of Measure Code",Item."Sales Unit of Measure");
        //    SalesPrice.VALIDATE("Unit Price",ItemWkshLine."Sales Price");
        //    SalesPrice.VALIDATE("Currency Code",ItemWkshLine."Sales Price Currency Code");
        //    //-NPR5.23 [242498]
        //    IF (ItemWorksheetTemplate."Sales Price Handling" <> ItemWorksheetTemplate."Sales Price Handling"::"Item+Variant")  THEN
        //      SalesPrice.VALIDATE("Starting Date",WORKDATE);
        //    //+NPR5.23 [242498]
        //    //-NPR5.38 [297587]
        //    IF ItemWkshLine."Sales Price Start Date" <> 0D THEN
        //      SalesPrice.VALIDATE("Starting Date",ItemWkshLine."Sales Price Start Date");
        //    //+NPR5.38 [297587]
        //    SalesPrice.INSERT(TRUE);
        //    RecRef.GETTABLE(SalesPrice);
        //    SalesPrice.VALIDATE("Master Record Reference",FORMAT(RecRef.RECORDID));
        //    SalesPrice.VALIDATE("Is Master",TRUE);
        //    SalesPrice.MODIFY(TRUE);
        //  END;
        // END;
        // RecRefTextMaster :=  SalesPrice."Master Record Reference";
        //
        // //-NPR5.23 [242498]
        // // END;
        // // IF ItemWorksheetTemplate."Sales Price Handling" = ItemWorksheetTemplate."Sales Price Handling" :: "Item+Date" THEN BEGIN
        // //  //TO BE IMPLEMENTED
        // //  ERROR(TxtNotImplemented);
        // // END;
        // //+NPR5.23 [242498]
        //+NPR5.50 [353052]
    end;

    local procedure ProcessVariantLineSalesPrice()
    var
        SalesPrice: Record "Sales Price";
        SalesPriceMaster: Record "Sales Price";
        ItemWorksheeVarieties: Record "NPR Item Worksh. Variety Value";
        VariantSalesPrice: Decimal;
        SalesPriceStartDate: Date;
        SalesPriceEndDate: Date;
        OnlyCloseExistingPrices: Boolean;
        SalesUnitOfMeasure: Code[10];
    begin
        //-NPR5.50 [353052]
        if (ItemWorksheetTemplate."Sales Price Handling" = ItemWorksheetTemplate."Sales Price Handling"::Item) or
           (ItemWorksheetTemplate."Sales Price Handling" = ItemWorksheetTemplate."Sales Price Handling"::"Item+Date") then
            exit;

        VariantSalesPrice := ItemWkshVariantLine."Sales Price";
        if VariantSalesPrice = 0 then begin
            VariantSalesPrice := ItemWkshLine."Sales Price";
            OnlyCloseExistingPrices := true;
        end;

        if ItemWkshLine."Sales Unit of Measure" <> '' then
            SalesUnitOfMeasure := ItemWkshLine."Sales Unit of Measure"
        else
            SalesUnitOfMeasure := Item."Sales Unit of Measure";

        SalesPrice.Reset;
        SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::"All Customers");
        SalesPrice.SetRange("Item No.", ItemWkshVariantLine."Item No.");
        SalesPrice.SetRange("Variant Code", ItemWkshVariantLine."Variant Code");
        SalesPrice.SetRange("Currency Code", ItemWkshLine."Sales Price Currency Code");
        if SalesUnitOfMeasure = Item."Sales Unit of Measure" then
            SalesPrice.SetFilter("Unit of Measure Code", '%1|%2', '', SalesUnitOfMeasure)
        else
            SalesPrice.SetRange("Unit of Measure Code", SalesUnitOfMeasure);
        SalesPrice.SetRange("Minimum Quantity", 0, 1);
        if OnlyCloseExistingPrices then
            if SalesPrice.IsEmpty then
                exit;
        case ItemWorksheetTemplate."Sales Price Handling" of
            ItemWorksheetTemplate."Sales Price Handling"::"Item+Variant":
                begin
                    SalesPriceStartDate := 0D;
                    SalesPriceEndDate := 0D;
                end;
            ItemWorksheetTemplate."Sales Price Handling"::"Item+Variant+Date":
                begin
                    SalesPriceStartDate := WorkDate;
                    if ItemWkshLine."Sales Price Start Date" <> 0D then
                        SalesPriceStartDate := ItemWkshLine."Sales Price Start Date";
                    SalesPrice.SetFilter("Starting Date", '>%1', SalesPriceStartDate);
                    if SalesPrice.FindFirst then
                        SalesPriceEndDate := SalesPrice."Starting Date" - 1
                    else
                        SalesPriceEndDate := 0D;
                end;
        end;
        SalesPrice.SetRange("Starting Date", SalesPriceStartDate);
        if SalesPrice.FindFirst then begin
            if not OnlyCloseExistingPrices then begin
                if SalesPrice."Ending Date" <> SalesPriceEndDate then begin
                    SalesPrice.Validate("Ending Date", SalesPriceEndDate);
                end;
                if SalesPrice."Unit Price" <> VariantSalesPrice then begin
                    SalesPrice.Validate("Unit Price", VariantSalesPrice);
                end;
                SalesPrice.Modify(true);
            end;
        end else begin
            SalesPriceMaster.Reset;
            SalesPriceMaster.SetRange("Sales Type", SalesPriceMaster."Sales Type"::"All Customers");
            SalesPriceMaster.SetRange("Item No.", ItemWkshLine."Item No.");
            SalesPriceMaster.SetRange("Starting Date", SalesPriceStartDate);
            SalesPriceMaster.SetRange("Currency Code", ItemWkshLine."Sales Price Currency Code");
            SalesPriceMaster.SetRange("Variant Code", '');
            if SalesUnitOfMeasure = Item."Sales Unit of Measure" then
                SalesPriceMaster.SetFilter("Unit of Measure Code", '%1|%2', '', SalesUnitOfMeasure)
            else
                SalesPriceMaster.SetRange("Unit of Measure Code", SalesUnitOfMeasure);
            SalesPriceMaster.SetRange("Minimum Quantity", 0, 1);
            SalesPriceMaster.SetRange("NPR Is Master", true);
            if SalesPriceMaster.FindFirst then begin
                SalesPrice := SalesPriceMaster;
                SalesPrice."Variant Code" := ItemWkshVariantLine."Variant Code";
                if (SalesPriceMaster."Unit Price" <> VariantSalesPrice) and (not OnlyCloseExistingPrices) then begin
                    SalesPrice.Validate("Variant Code");
                    SalesPrice.Validate("Unit Price", VariantSalesPrice);
                    SalesPrice.Validate("NPR Is Master", false);
                    SalesPrice.Validate("Ending Date", SalesPriceEndDate);
                    SalesPrice.Insert(true);
                end;
            end else begin
                SalesPrice.Init;
                SalesPrice.Validate("Item No.", ItemWkshLine."Item No.");
                SalesPrice.Validate("Sales Type", SalesPrice."Sales Type"::"All Customers");
                SalesPrice."Sales Code" := '';
                SalesPrice.Validate("Starting Date", SalesPriceStartDate);
                SalesPrice.Validate("Currency Code", ItemWkshLine."Sales Price Currency Code");
                SalesPrice.Validate("Variant Code", ItemWkshVariantLine."Variant Code");
                SalesPrice.Validate("Unit of Measure Code", SalesUnitOfMeasure);
                SalesPrice.Validate("Minimum Quantity", 0);
                SalesPrice.Validate("Unit Price", VariantSalesPrice);
                SalesPrice.Validate("Ending Date", SalesPriceEndDate);
                if not OnlyCloseExistingPrices then
                    SalesPrice.Insert(true);
            end;
        end;
        case ItemWorksheetTemplate."Sales Price Handling" of
            ItemWorksheetTemplate."Sales Price Handling"::"Item+Variant":
                begin
                    CloseRelatedSalesPrices(SalesPrice, WorkDate - 1);
                end;
            ItemWorksheetTemplate."Sales Price Handling"::"Item+Variant+Date":
                begin
                    CloseRelatedSalesPrices(SalesPrice, SalesPriceStartDate - 1);
                end;
        end;
        //+NPR5.50 [353052]

        //-NPR5.50 [353052]
        // IF  ItemWkshVariantLine."Sales Price" = 0 THEN
        //  EXIT;
        //
        // //-NPR5.23 [242498]
        // //IF ItemWorksheetTemplate."Sales Price Handling" = ItemWorksheetTemplate."Sales Price Handling" :: "Item+Variant" THEN  BEGIN
        // IF ItemWorksheetTemplate."Sales Price Handling" IN [ItemWorksheetTemplate."Sales Price Handling" :: "Item+Variant",ItemWorksheetTemplate."Sales Price Handling" :: "Item+Variant+Date" ] THEN  BEGIN
        // //+NPR5.23 [242498]
        //  SalesPrice.RESET;
        //  SalesPrice.SETRANGE("Sales Type",SalesPrice."Sales Type"::"All Customers");
        //  SalesPrice.SETRANGE("Item No.",ItemWkshVariantLine."Item No.");
        //  SalesPrice.SETRANGE("Variant Code",ItemWkshVariantLine."Variant Code");
        //  SalesPrice.SETRANGE("Currency Code",ItemWkshLine."Sales Price Currency Code");
        //  //-NPR5.23 [242498]
        //  //-NPR5.38 [297587]
        //  IF ItemWkshLine."Sales Price Start Date" <> 0D THEN
        //    SalesPrice.SETRANGE("Starting Date",ItemWkshLine."Sales Price Start Date")
        //  ELSE
        //  //+NPR5.38 [297587
        //    SalesPrice.SETRANGE("Starting Date",0D,WORKDATE);
        //  IF SalesPrice.FINDLAST THEN BEGIN
        //  //IF SalesPrice.FINDFIRST THEN BEGIN
        //    //existing variant price found
        //    IF ItemWkshVariantLine."Sales Price" <> SalesPrice."Unit Price" THEN BEGIN
        //        //-NPR5.23 [242498]
        //        //-NPR5.38 [297587]
        //        //IF (ItemWorksheetTemplate."Sales Price Handling" = ItemWorksheetTemplate."Sales Price Handling"::"Item+Variant") OR (SalesPrice."Starting Date" = WORKDATE) THEN BEGIN
        //        IF (ItemWorksheetTemplate."Sales Price Handling" = ItemWorksheetTemplate."Sales Price Handling"::"Item+Variant") OR (SalesPrice."Starting Date" = WORKDATE) OR
        //          (ItemWkshLine."Sales Price Start Date" <> 0D)  THEN BEGIN
        //        //+NPR5.38 [297587]
        //          //+NPR5.23 [242498]
        //          SalesPrice.VALIDATE("Unit Price",ItemWkshVariantLine."Sales Price");
        //          SalesPrice.MODIFY(TRUE);
        //        //-NPR5.23 [242498]
        //        END ELSE BEGIN
        //          SalesPrice.VALIDATE("Ending Date",WORKDATE-1);
        //          SalesPrice.MODIFY(TRUE);
        //          SalesPrice.VALIDATE("Ending Date",0D);
        //          SalesPrice.VALIDATE("Unit Price",ItemWkshVariantLine."Sales Price");
        //          SalesPrice.VALIDATE("Starting Date",WORKDATE);
        //          SalesPrice.INSERT(TRUE);
        //        END;
        //        //+NPR5.23 [242498]
        //    END;
        //  END ELSE BEGIN
        //    SalesPriceMaster.RESET;
        //    SalesPriceMaster.SETRANGE("Sales Type",SalesPrice."Sales Type"::"All Customers");
        //    SalesPriceMaster.SETRANGE("Item No.",ItemWkshVariantLine."Item No.");
        //    SalesPriceMaster.SETRANGE("Is Master",TRUE);
        //    //-NPR5.23 [242498]
        //    SalesPrice.SETRANGE("Starting Date",0D,WORKDATE);
        //    IF SalesPriceMaster.FINDLAST THEN BEGIN
        //    //IF SalesPriceMaster.FINDFIRST THEN BEGIN
        //    //+NPR5.23 [242498]
        //      //Found Master
        //      IF SalesPriceMaster."Unit Price"  <> ItemWkshVariantLine."Sales Price" THEN BEGIN
        //        SalesPrice.INIT;
        //        SalesPrice := SalesPriceMaster;
        //        SalesPrice.VALIDATE("Variant Code",ItemWkshVariantLine."Variant Code");
        //        SalesPrice.VALIDATE("Currency Code",ItemWkshLine."Sales Price Currency Code");
        //        //-NPR5.23 [242498]
        //        IF (ItemWorksheetTemplate."Sales Price Handling" <> ItemWorksheetTemplate."Sales Price Handling"::"Item+Variant")  THEN
        //          SalesPrice.VALIDATE("Starting Date",WORKDATE);
        //        //+NPR5.23 [242498]
        //        //-NPR5.38 [297587]
        //        IF ItemWkshLine."Sales Price Start Date" <> 0D THEN
        //          SalesPrice.VALIDATE("Starting Date",ItemWkshLine."Sales Price Start Date");
        //        //+NPR5.38 [297587]
        //        SalesPrice.INSERT(TRUE);
        //        SalesPrice."Is Master" := FALSE;
        //        SalesPrice.VALIDATE("Unit Price",ItemWkshVariantLine."Sales Price");
        //        SalesPrice.MODIFY(TRUE);
        //      END;
        //    END ELSE BEGIN
        //      //No Price found
        //      SalesPrice.INIT;
        //      SalesPrice.VALIDATE("Sales Type",SalesPrice."Sales Type"::"All Customers");
        //      SalesPrice.VALIDATE("Item No.",ItemWkshLine."Item No.");
        //      SalesPrice.VALIDATE("Variant Code",ItemWkshVariantLine."Variant Code");
        //      SalesPrice.VALIDATE("Unit of Measure Code",Item."Sales Unit of Measure");
        //      SalesPrice.VALIDATE("Unit Price",ItemWkshVariantLine."Sales Price");
        //      SalesPrice.VALIDATE("Currency Code",ItemWkshLine."Sales Price Currency Code");
        //      //-NPR5.23 [242498]
        //      IF (ItemWorksheetTemplate."Sales Price Handling" <> ItemWorksheetTemplate."Sales Price Handling"::"Item+Variant")  THEN
        //        SalesPrice.VALIDATE("Starting Date",WORKDATE);
        //      //+NPR5.23 [242498]
        //      //-NPR5.38 [297587]
        //      IF ItemWkshLine."Sales Price Start Date" <> 0D THEN
        //        SalesPrice.VALIDATE("Starting Date",ItemWkshLine."Sales Price Start Date");
        //      //+NPR5.38 [297587]
        //      SalesPrice.INSERT(TRUE);
        //    END;
        //  END;
        // END;
        // IF ItemWorksheetTemplate."Sales Price Handling" = ItemWorksheetTemplate."Sales Price Handling" :: "Item+Date" THEN BEGIN
        //  //TO BE IMPLEMENTED
        //  ERROR(TxtNotImplemented);
        // END;
        //+NPR5.50 [353052]
    end;

    local procedure CloseRelatedSalesPrices(SalesPrice: Record "Sales Price"; EndingDate: Date)
    var
        SalesPrice2: Record "Sales Price";
    begin
        //-NPR5.50 [353052]
        GetItem(SalesPrice."Item No.");
        SalesPrice2.Reset;
        SalesPrice2.SetRange("Sales Type", SalesPrice2."Sales Type"::"All Customers");
        SalesPrice2.SetRange("Item No.", SalesPrice."Item No.");
        SalesPrice2.SetRange("Variant Code", SalesPrice."Variant Code");
        SalesPrice2.SetRange("Currency Code", SalesPrice."Currency Code");
        if SalesPrice."Unit of Measure Code" = Item."Sales Unit of Measure" then
            SalesPrice2.SetFilter("Unit of Measure Code", '%1|%2', '', SalesPrice."Unit of Measure Code")
        else
            SalesPrice2.SetRange("Unit of Measure Code", SalesPrice."Unit of Measure Code");
        SalesPrice2.SetRange("Starting Date", 0D, EndingDate);
        SalesPrice2.SetRange("Minimum Quantity", 0, 1);
        if SalesPrice2.FindSet then
            repeat
                if (SalesPrice2."Ending Date" = 0D) or (SalesPrice2."Ending Date" > EndingDate) then
                    if (SalesPrice2."Item No." <> SalesPrice."Item No.") or
                        (SalesPrice2."Sales Type" <> SalesPrice."Sales Type") or
                        (SalesPrice2."Sales Code" <> SalesPrice."Sales Code") or
                        (SalesPrice2."Starting Date" <> SalesPrice."Starting Date") or
                        (SalesPrice2."Currency Code" <> SalesPrice."Currency Code") or
                        (SalesPrice2."Variant Code" <> SalesPrice."Variant Code") or
                        (SalesPrice2."Unit of Measure Code" <> SalesPrice."Unit of Measure Code") or
                        (SalesPrice2."Minimum Quantity" <> SalesPrice."Minimum Quantity") then begin
                        SalesPrice2."Ending Date" := EndingDate;
                        SalesPrice2.Modify(true);
                    end;
            until SalesPrice2.Next = 0;
        //+NPR5.50 [353052]
    end;

    procedure ProcessLinePurchasePrices()
    var
        PurchasePrice: Record "Purchase Price";
    begin
        if ItemWkshLine."Direct Unit Cost" = 0 then
            exit;
        //-NPR4.19
        //Item.GET(ItemWkshLine."Item No.");
        GetItem(ItemWkshLine."Item No.");
        //+NPR4.19
        if ItemWorksheetTemplate."Purchase Price Handling" = ItemWorksheetTemplate."Purchase Price Handling"::Item then begin
            if ItemWkshLine."Direct Unit Cost" <> Item."Last Direct Cost" then begin
                Item.Validate("Last Direct Cost", ItemWkshLine."Direct Unit Cost");
                Item.Modify(true);
            end;
            //-NPR5.23 [242498]
            exit;
            //+NPR5.23 [242498]
        end;
        //-NPR5.23 [242498]
        //IF ItemWorksheetTemplate."Purchase Price Handling" = ItemWorksheetTemplate."Purchase Price Handling" :: "Item+Variant" THEN  BEGIN
        //+NPR5.23 [242498]
        PurchasePrice.Reset;
        PurchasePrice.SetRange("Vendor No.", ItemWkshLine."Vendor No.");
        PurchasePrice.SetRange("Item No.", ItemWkshLine."Item No.");
        PurchasePrice.SetRange("Variant Code", '');
        PurchasePrice.SetRange("Currency Code", ItemWkshLine."Purchase Price Currency Code");
        //-NPR5.23 [242498]
        //-NPR5.38 [297587]
        if ItemWkshLine."Purchase Price Start Date" <> 0D then
            PurchasePrice.SetRange("Starting Date", ItemWkshLine."Purchase Price Start Date")
        else
            //+NPR5.38 [297587]
            PurchasePrice.SetRange("Starting Date", 0D, WorkDate);
        if PurchasePrice.FindLast then begin
            //IF PurchasePrice.FINDFIRST THEN BEGIN
            //+NPR5.23 [242498]
            //Found Purchase Price
            if PurchasePrice."Direct Unit Cost" <> ItemWkshLine."Direct Unit Cost" then begin
                //-NPR5.23 [242498]
                //-NPR5.38 [297587]
                //IF (ItemWorksheetTemplate."Purchase Price Handling" = ItemWorksheetTemplate."Purchase Price Handling"::"Item+Variant") OR (PurchasePrice."Starting Date" = WORKDATE) THEN BEGIN
                if (ItemWorksheetTemplate."Purchase Price Handling" = ItemWorksheetTemplate."Purchase Price Handling"::"Item+Variant") or (PurchasePrice."Starting Date" = WorkDate) or
                  (ItemWkshLine."Purchase Price Start Date" <> 0D) then begin
                    //+NPR5.38 [297587]
                    //+NPR5.23 [242498]
                    PurchasePrice.Validate("Direct Unit Cost", ItemWkshLine."Direct Unit Cost");
                    PurchasePrice.Modify(true);
                    //-NPR5.23 [242498]
                end else begin
                    PurchasePrice.Validate("Ending Date", WorkDate - 1);
                    PurchasePrice.Modify(true);
                    PurchasePrice.Validate("Ending Date", 0D);
                    PurchasePrice.Validate("Direct Unit Cost", ItemWkshLine."Direct Unit Cost");
                    //-NPR5.38 [297587]
                    if ItemWkshLine."Purchase Price Start Date" <> 0D then
                        PurchasePrice.Validate("Starting Date", ItemWkshLine."Purchase Price Start Date")
                    else
                        //+NPR5.38 [297587]
                        PurchasePrice.Validate("Starting Date", WorkDate);
                    PurchasePrice.Insert(true);
                end;
                //+NPR5.23 [242498]
            end;
        end else begin
            //Create a new Purchase Price
            PurchasePrice.Init;
            PurchasePrice.Validate("Vendor No.", ItemWkshLine."Vendor No.");
            PurchasePrice.Validate("Item No.", ItemWkshLine."Item No.");
            PurchasePrice.Validate("Unit of Measure Code", Item."Purch. Unit of Measure");
            PurchasePrice.Validate("Direct Unit Cost", ItemWkshLine."Direct Unit Cost");
            PurchasePrice.Validate("Currency Code", ItemWkshLine."Purchase Price Currency Code");
            //-NPR5.23 [242498]
            if (ItemWorksheetTemplate."Purchase Price Handling" <> ItemWorksheetTemplate."Purchase Price Handling"::"Item+Variant") then
                PurchasePrice.Validate("Starting Date", WorkDate);
            //+NPR5.23 [242498]
            //-NPR5.38 [297587]
            if ItemWkshLine."Purchase Price Start Date" <> 0D then
                PurchasePrice.Validate("Starting Date", ItemWkshLine."Purchase Price Start Date");
            //+NPR5.38 [297587]
            PurchasePrice.Insert(true);
        end;

        //-NPR5.23 [242498]
        // END;
        // IF ItemWorksheetTemplate."Purchase Price Handling" = ItemWorksheetTemplate."Purchase Price Handling" :: "Item+Date" THEN BEGIN
        //  //TO BE IMPLEMENTED
        //  ERROR(TxtNotImplemented);
        // END;
        //+NPR5.23 [242498]
    end;

    local procedure ProcessVariantLinePurchasePrice()
    var
        PurchasePriceItem: Record "Purchase Price";
        PurchasePrice: Record "Purchase Price";
        RecRef: RecordRef;
    begin
        if ItemWkshVariantLine."Direct Unit Cost" = 0 then
            exit;
        //-NPR5.23 [242498]
        //IF ItemWorksheetTemplate."Purchase Price Handling" = ItemWorksheetTemplate."Purchase Price Handling" :: "Item+Variant" THEN  BEGIN
        if ItemWorksheetTemplate."Purchase Price Handling" = ItemWorksheetTemplate."Purchase Price Handling"::"Item+Date" then
            exit;
        //+NPR5.23 [242498]
        PurchasePrice.Reset;
        PurchasePrice.SetRange("Vendor No.", ItemWkshLine."Vendor No.");
        PurchasePrice.SetRange("Item No.", ItemWkshVariantLine."Item No.");
        PurchasePrice.SetRange("Variant Code", ItemWkshVariantLine."Variant Code");
        PurchasePrice.SetRange("Currency Code", ItemWkshLine."Purchase Price Currency Code");
        //-NPR5.23 [242498]
        //-NPR5.38 [297587]
        if ItemWkshLine."Purchase Price Start Date" <> 0D then
            PurchasePrice.SetRange("Starting Date", ItemWkshLine."Purchase Price Start Date")
        else
            //+NPR5.38 [297587]
            PurchasePrice.SetRange("Starting Date", 0D, WorkDate);
        if PurchasePrice.FindLast then begin
            //IF PurchasePrice.FINDFIRST THEN BEGIN
            //+NPR5.23 [242498]
            //existing variant price found
            if ItemWkshVariantLine."Direct Unit Cost" <> PurchasePrice."Direct Unit Cost" then begin
                //-NPR5.23 [242498]
                //-NPR5.38 [297587]
                //IF (ItemWorksheetTemplate."Purchase Price Handling" = ItemWorksheetTemplate."Purchase Price Handling"::"Item+Variant") OR (PurchasePrice."Starting Date" = WORKDATE) THEN BEGIN
                if (ItemWorksheetTemplate."Purchase Price Handling" = ItemWorksheetTemplate."Purchase Price Handling"::"Item+Variant") or (PurchasePrice."Starting Date" = WorkDate) or
                  (ItemWkshLine."Purchase Price Start Date" <> 0D) then begin
                    //+NPR5.38 [297587]
                    //+NPR5.23 [242498]
                    PurchasePrice.Validate("Direct Unit Cost", ItemWkshVariantLine."Direct Unit Cost");
                    PurchasePrice.Modify(true);
                    //-NPR5.23 [242498]
                end else begin
                    PurchasePrice.Validate("Ending Date", WorkDate - 1);
                    PurchasePrice.Modify(true);
                    PurchasePrice.Validate("Ending Date", 0D);
                    PurchasePrice.Validate("Direct Unit Cost", ItemWkshVariantLine."Direct Unit Cost");
                    PurchasePrice.Validate("Starting Date", WorkDate);
                    PurchasePrice.Insert(true);
                end;
                //+NPR5.23 [242498]
            end;
        end else begin
            PurchasePriceItem.Reset;
            PurchasePriceItem.SetRange("Vendor No.", ItemWkshLine."Vendor No.");
            PurchasePriceItem.SetRange("Item No.", ItemWkshVariantLine."Item No.");
            PurchasePriceItem.SetRange("Currency Code", ItemWkshLine."Purchase Price Currency Code");
            //-NPR5.23 [242498]
            //-NPR5.38 [297587]
            if ItemWkshLine."Purchase Price Start Date" <> 0D then
                PurchasePrice.SetRange("Starting Date", ItemWkshLine."Purchase Price Start Date")
            else
                //+NPR5.38 [297587]
                PurchasePrice.SetRange("Starting Date", 0D, WorkDate);
            if PurchasePrice.FindLast then begin
                //IF PurchasePrice.FINDFIRST THEN BEGIN
                //+NPR5.23 [242498]
                //existing item price
                if PurchasePriceItem."Direct Unit Cost" <> ItemWkshVariantLine."Direct Unit Cost" then begin
                    PurchasePrice.Init;
                    PurchasePrice := PurchasePriceItem;
                    PurchasePrice.Validate("Variant Code", ItemWkshVariantLine."Variant Code");
                    PurchasePrice.Validate("Direct Unit Cost", ItemWkshVariantLine."Direct Unit Cost");
                    PurchasePrice.Validate("Currency Code", ItemWkshLine."Purchase Price Currency Code");
                    //-NPR5.23 [242498]
                    if (ItemWorksheetTemplate."Purchase Price Handling" <> ItemWorksheetTemplate."Purchase Price Handling"::"Item+Variant") then
                        PurchasePrice.Validate("Starting Date", WorkDate);
                    //+NPR5.23 [242498]
                    PurchasePrice.Insert(true);
                end;
            end else begin
                //No Price found
                PurchasePrice.Init;
                PurchasePrice.Validate("Vendor No.", ItemWkshLine."Vendor No.");
                PurchasePrice.Validate("Item No.", ItemWkshLine."Item No.");
                PurchasePrice.Validate("Variant Code", ItemWkshVariantLine."Variant Code");
                PurchasePrice.Validate("Unit of Measure Code", Item."Purch. Unit of Measure");
                PurchasePrice.Validate("Direct Unit Cost", ItemWkshVariantLine."Direct Unit Cost");
                PurchasePrice.Validate("Currency Code", ItemWkshLine."Purchase Price Currency Code");
                //-NPR5.23 [242498]
                if (ItemWorksheetTemplate."Purchase Price Handling" <> ItemWorksheetTemplate."Purchase Price Handling"::"Item+Variant") then
                    PurchasePrice.Validate("Starting Date", WorkDate);
                //+NPR5.23 [242498]
                //-NPR5.38 [297587]
                if ItemWkshLine."Purchase Price Start Date" <> 0D then
                    PurchasePrice.Validate("Starting Date", ItemWkshLine."Purchase Price Start Date");
                //+NPR5.38 [297587]
                PurchasePrice.Insert(true);
            end;
        end;

        //-NPR5.23 [242498]
        // END;
        // IF ItemWorksheetTemplate."Purchase Price Handling" = ItemWorksheetTemplate."Purchase Price Handling" :: "Item+Date" THEN BEGIN
        //  //TO BE IMPLEMENTED
        //  ERROR(TxtNotImplemented);
        // END;
        //+NPR5.23 [242498]
    end;

    [BusinessEvent(false)]
    local procedure OnBeforeRegisterLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
    end;

    [BusinessEvent(false)]
    local procedure OnBeforeRegisterVariantLine(var ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line")
    begin
    end;

    [BusinessEvent(false)]
    local procedure OnAfterRegisterLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
    end;

    [BusinessEvent(false)]
    local procedure OnAfterRegisterVariantLine(var ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line")
    begin
    end;

    procedure SetCalledFromTest(ParCalledFromTest: Boolean)
    begin
        //-NPR5.25 [246088]
        CalledFromTest := ParCalledFromTest;
        //+NPR5.25 [246088]
    end;

    procedure InsertChangeRecords(VarItemWkshLine: Record "NPR Item Worksheet Line")
    var
        ExistingItem: Record Item;
    begin
        //-NPR5.25 [246088]
        if VarItemWkshLine."Existing Item No." = '' then
            exit;
        if not ExistingItem.Get(VarItemWkshLine."Existing Item No.") then
            exit;
        ValidateFields(ExistingItem, VarItemWkshLine, false, true);
        //+NPR5.25 [246088]
    end;

    local procedure ValidateFields(var VarItem: Record Item; var VarItemWkshLine: Record "NPR Item Worksheet Line"; DoValidateFields: Boolean; DoInsertChangeRecords: Boolean)
    var
        ItemRecRef: RecordRef;
        ItemWorksheetRecRef: RecordRef;
        ItemWorksheetFieldSetup: Record "NPR Item Worksh. Field Setup";
        ItemFldRef: FieldRef;
        ItemWorksheetFldRef: FieldRef;
        SourceFieldRec: Record "Field";
        TargetFieldRec: Record "Field";
        TxtFieldCouldNotValidate: Label 'Target field %1 in table %2 could not be validated with value %3.';
        ItemWorksheetFieldChange: Record "NPR Item Worksh. Field Change";
    begin
        //-NPR5.25 [246088]
        VarItem.Get(VarItem."No.");
        ItemRecRef.Get(VarItem.RecordId);
        ItemWorksheetRecRef.Get(VarItemWkshLine.RecordId);

        ItemWorksheetFieldChange.Reset;
        ItemWorksheetFieldChange.SetRange("Worksheet Template Name", VarItemWkshLine."Worksheet Template Name");
        ItemWorksheetFieldChange.SetRange("Worksheet Name", VarItemWkshLine."Worksheet Name");
        ItemWorksheetFieldChange.SetRange("Worksheet Line No.", VarItemWkshLine."Line No.");
        ItemWorksheetFieldChange.DeleteAll;

        ItemWorksheetFieldSetup.Reset;
        ItemWorksheetFieldSetup.SetFilter("Worksheet Template Name", '%1|%2', VarItemWkshLine."Worksheet Template Name", '');
        ItemWorksheetFieldSetup.SetFilter("Worksheet Name", '%1|%2', VarItemWkshLine."Worksheet Name", '');
        ItemWorksheetFieldSetup.SetRange("Table No.", DATABASE::"NPR Item Worksheet Line");
        if ItemWorksheetFieldSetup.FindSet then
            repeat
                //Find the setup on Template, Worksheet or General
                ItemWorksheetFieldSetup.SetRange("Field Number", ItemWorksheetFieldSetup."Field Number");
                ItemWorksheetFieldSetup.FindLast;
                ItemWorksheetFieldSetup.SetRange("Field Number");
                case VarItemWkshLine.Action of
                    VarItemWkshLine.Action::CreateNew:
                        begin
                            if not DoValidateFields then
                                exit;
                            case ItemWorksheetFieldSetup."Process Create" of
                                ItemWorksheetFieldSetup."Process Create"::Ignore:
                                    ;
                                ItemWorksheetFieldSetup."Process Create"::Process:
                                    begin
                                        if SourceFieldRec.Get(ItemWorksheetFieldSetup."Table No.", ItemWorksheetFieldSetup."Field Number") then begin
                                            ItemWorksheetFldRef := ItemWorksheetRecRef.Field(SourceFieldRec."No.");
                                            TargetFieldRec.Init;
                                            if not TargetFieldRec.Get(ItemWorksheetFieldSetup."Target Table No. Create", ItemWorksheetFieldSetup."Target Field Number Create") then
                                                if not TargetFieldRec.Get(DATABASE::Item, ItemWorksheetFieldSetup."Field Number") then
                                                    TargetFieldRec.Init;
                                            if TargetFieldRec."No." <> 0 then begin
                                                ItemFldRef := ItemRecRef.Field(TargetFieldRec."No.");
                                                if not MapField(ItemWorksheetFieldSetup, ItemWorksheetFldRef, ItemFldRef) then
                                                    if not ValidateFieldRef(ItemWorksheetFldRef, ItemFldRef) then
                                                        Error(TxtFieldCouldNotValidate, TargetFieldRec."Field Caption", TargetFieldRec.TableName, Format(ItemWorksheetFldRef.Value));
                                            end;
                                        end;
                                    end;
                                ItemWorksheetFieldSetup."Process Create"::"Use Default on Blank":
                                    begin
                                        if SourceFieldRec.Get(ItemWorksheetFieldSetup."Table No.", ItemWorksheetFieldSetup."Field Number") then begin
                                            ItemWorksheetFldRef := ItemWorksheetRecRef.Field(SourceFieldRec."No.");
                                            TargetFieldRec.Init;
                                            if not TargetFieldRec.Get(ItemWorksheetFieldSetup."Target Table No. Create", ItemWorksheetFieldSetup."Target Field Number Create") then
                                                if not TargetFieldRec.Get(DATABASE::Item, ItemWorksheetFieldSetup."Field Number") then
                                                    TargetFieldRec.Init;
                                            if TargetFieldRec."No." <> 0 then begin
                                                ItemFldRef := ItemRecRef.Field(TargetFieldRec."No.");
                                                if IsBlankFieldRef(ItemWorksheetFldRef, ItemFldRef) then begin
                                                    if not ValidateFieldText(ItemWorksheetFieldSetup."Default Value for Create", ItemFldRef) then
                                                        Error(TxtFieldCouldNotValidate, TargetFieldRec."Field Caption", TargetFieldRec.TableName, ItemWorksheetFieldSetup."Default Value for Create");
                                                end else begin
                                                    if not MapField(ItemWorksheetFieldSetup, ItemWorksheetFldRef, ItemFldRef) then
                                                        if not ValidateFieldRef(ItemWorksheetFldRef, ItemFldRef) then
                                                            Error(TxtFieldCouldNotValidate, TargetFieldRec."Field Caption", TargetFieldRec.TableName, Format(ItemWorksheetFldRef.Value));
                                                end;
                                            end;
                                        end;
                                    end;
                                ItemWorksheetFieldSetup."Process Create"::"Always use Default":
                                    begin
                                        TargetFieldRec.Init;
                                        if not TargetFieldRec.Get(ItemWorksheetFieldSetup."Target Table No. Create", ItemWorksheetFieldSetup."Target Field Number Create") then
                                            if not TargetFieldRec.Get(DATABASE::Item, ItemWorksheetFieldSetup."Field Number") then
                                                TargetFieldRec.Init;
                                        if TargetFieldRec."No." <> 0 then begin
                                            ItemFldRef := ItemRecRef.Field(TargetFieldRec."No.");
                                            if not ValidateFieldText(ItemWorksheetFieldSetup."Default Value for Create", ItemFldRef) then
                                                Error(TxtFieldCouldNotValidate, TargetFieldRec."Field Caption", TargetFieldRec.TableName, ItemWorksheetFieldSetup."Default Value for Create");
                                        end;
                                    end;

                            end;
                        end;
                    VarItemWkshLine.Action::UpdateOnly, VarItemWkshLine.Action::UpdateAndCreateVariants:
                        begin
                            if ItemWorksheetFieldSetup."Process Update" = ItemWorksheetFieldSetup."Process Update"::Ignore then
                                ;

                            if SourceFieldRec.Get(ItemWorksheetFieldSetup."Table No.", ItemWorksheetFieldSetup."Field Number") then begin
                                ItemWorksheetFldRef := ItemWorksheetRecRef.Field(SourceFieldRec."No.");
                                TargetFieldRec.Init;
                                if not TargetFieldRec.Get(ItemWorksheetFieldSetup."Target Table No. Create", ItemWorksheetFieldSetup."Target Field Number Update") then
                                    if not TargetFieldRec.Get(DATABASE::Item, ItemWorksheetFieldSetup."Target Field Number Update") then
                                        TargetFieldRec.Init;
                                if TargetFieldRec."No." <> 0 then begin
                                    ItemFldRef := ItemRecRef.Field(TargetFieldRec."No.");
                                    if not IsBlankFieldRef(ItemWorksheetFldRef, ItemFldRef) then begin
                                        if Format(ItemFldRef.Value) <> Format(ItemWorksheetFldRef.Value) then begin
                                            //Difference between new value and old value
                                            if DoInsertChangeRecords then
                                                InsertChangeRecord(VarItemWkshLine, ItemWorksheetFieldSetup, ItemWorksheetFldRef, ItemFldRef);
                                            if DoValidateFields then
                                                if ItemWorksheetFieldSetup."Process Update" in [ItemWorksheetFieldSetup."Process Update"::"Warn and Process", ItemWorksheetFieldSetup."Process Update"::Process] then
                                                    if not MapField(ItemWorksheetFieldSetup, ItemWorksheetFldRef, ItemFldRef) then
                                                        if not ValidateFieldRef(ItemWorksheetFldRef, ItemFldRef) then
                                                            Error(TxtFieldCouldNotValidate, TargetFieldRec."Field Caption", TargetFieldRec.TableName, Format(ItemWorksheetFldRef.Value));
                                        end;
                                    end;
                                end;
                            end;
                        end;
                end;
            until ItemWorksheetFieldSetup.Next = 0;
        if DoValidateFields then
            ItemRecRef.Modify(true);
        VarItem.Get(VarItem."No.");
        //+NPR5.25 [246088]
    end;

    local procedure MapStandardItemWorksheetLineField(var VarItem: Record Item; SourceFieldNo: Integer): Boolean
    var
        ItemWorksheetFieldSetup: Record "NPR Item Worksh. Field Setup";
        ItemRecRef: RecordRef;
        ItemWorksheetRecRef: RecordRef;
        ItemWorksheetFldRef: FieldRef;
        ItemFldRef: FieldRef;
    begin
        //-NPR5.26 [250745]
        ItemWorksheetFieldSetup.Reset;
        ItemWorksheetFieldSetup.SetFilter("Worksheet Template Name", '%1|%2', ItemWkshLine."Worksheet Template Name", '');
        ItemWorksheetFieldSetup.SetFilter("Worksheet Name", '%1|%2', ItemWkshLine."Worksheet Name", '');
        ItemWorksheetFieldSetup.SetRange("Table No.", DATABASE::"NPR Item Worksheet Line");
        ItemWorksheetFieldSetup.SetRange("Field Number", SourceFieldNo);
        if not ItemWorksheetFieldSetup.FindLast then
            exit(false);
        ItemRecRef.Get(VarItem.RecordId);
        ItemWorksheetRecRef.Get(ItemWkshLine.RecordId);
        ItemWorksheetFldRef := ItemWorksheetRecRef.Field(SourceFieldNo);
        ItemFldRef := ItemRecRef.Field(ItemWorksheetFieldSetup."Target Field Number Create");
        if MapField(ItemWorksheetFieldSetup, ItemWorksheetFldRef, ItemFldRef) then begin
            ItemRecRef.Modify;
            exit(true);
        end else
            exit(false);
        //+NPR5.26 [250745]
    end;

    local procedure MapField(ItemWorksheetFieldSetup: Record "NPR Item Worksh. Field Setup"; SourceFldRef: FieldRef; var TargetFldRef: FieldRef): Boolean
    var
        ItemWorksheetFieldMapping: Record "NPR Item Worksh. Field Mapping";
        RecRef: RecordRef;
    begin
        //-NPR5.25 [246088]
        with ItemWorksheetFieldMapping do begin
            Reset;
            SetRange("Worksheet Template Name", ItemWorksheetFieldSetup."Worksheet Template Name");
            SetRange("Worksheet Name", ItemWorksheetFieldSetup."Worksheet Name");
            SetRange("Table No.", ItemWorksheetFieldSetup."Table No.");
            SetRange("Field Number", ItemWorksheetFieldSetup."Field Number");
            if FindSet then
                repeat
                    RecRef := SourceFldRef.Record;
                    RecRef.SetRecFilter;
                    //Exact
                    case Matching of
                        Matching::Exact:
                            begin
                                if "Case Sensitive" then begin
                                    SetFilter("Source Value", Format(SourceFldRef.Value));
                                    if FindFirst then
                                        if ValidateFieldText("Target Value", TargetFldRef) then
                                            exit(true);
                                end else begin
                                    SourceFldRef.SetFilter('@' + Format("Source Value"));
                                    if RecRef.FindFirst then
                                        if ValidateFieldText("Target Value", TargetFldRef) then
                                            exit(true);
                                end;
                            end;
                        Matching::"Starts With":
                            begin
                                if "Case Sensitive" then begin
                                    SourceFldRef.SetFilter(Format("Source Value") + '*');
                                    if RecRef.FindFirst then
                                        if ValidateFieldText("Target Value", TargetFldRef) then
                                            exit(true);
                                end else begin
                                    SetFilter("Source Value", '@' + Format(SourceFldRef.Value) + '*');
                                    SourceFldRef.SetFilter(Format("Source Value") + '*');
                                    if RecRef.FindFirst then
                                        if ValidateFieldText("Target Value", TargetFldRef) then
                                            exit(true);
                                end;
                            end;
                        Matching::"Ends With":
                            begin
                                if "Case Sensitive" then begin
                                    SourceFldRef.SetFilter('*' + Format("Source Value"));
                                    if RecRef.FindFirst then
                                        if ValidateFieldText("Target Value", TargetFldRef) then
                                            exit(true);
                                end else begin
                                    SourceFldRef.SetFilter('*@' + Format("Source Value"));
                                    if RecRef.FindFirst then
                                        if ValidateFieldText("Target Value", TargetFldRef) then
                                            exit(true);
                                end;
                            end;
                        Matching::Contains:
                            begin
                                if "Case Sensitive" then begin
                                    SourceFldRef.SetFilter('*' + Format("Source Value") + '*');
                                    if RecRef.FindFirst then
                                        if ValidateFieldText("Target Value", TargetFldRef) then
                                            exit(true);
                                end else begin
                                    SourceFldRef.SetFilter('*@' + Format("Source Value") + '*');
                                    if RecRef.FindFirst then
                                        if ValidateFieldText("Target Value", TargetFldRef) then
                                            exit(true);
                                end;
                            end;
                    end;
                until Next = 0;
            exit(false);
        end;
        //-NPR5.25 [246088]
    end;

    local procedure ValidateFieldRef(SourceFldRef: FieldRef; TargetFldRef: FieldRef): Boolean
    var
        ItemWorksheetFieldMapping: Record "NPR Item Worksh. Field Mapping";
        TmpInteger: Integer;
        TmpDecimal: Decimal;
        TmpDate: Date;
        TmpTime: Time;
        TmpDateFormula: DateFormula;
        TmpBool: Boolean;
        TmpDateTime: DateTime;
        TxtInvalidBoolean: Label 'Could not evaluate %1 to a Yes/No value.';
    begin
        //-NPR5.25 [246088]
        if Format(SourceFldRef.Value) = Format(TargetFldRef.Value) then
            exit(true); //Skip source and target have the same value
        case UpperCase(Format(TargetFldRef.Type)) of
            'TEXT', 'CODE':
                TargetFldRef.Validate(Format(SourceFldRef.Value));
            'INTEGER':
                if Evaluate(TmpInteger, Format(SourceFldRef.Value)) then begin
                    TargetFldRef.Validate(TmpInteger);
                end else
                    exit(false);
            'OPTION':
                if Evaluate(TmpInteger, Format(SourceFldRef.Value, 0, 2)) then begin
                    if TmpInteger <> 9 then //skip unkown
                        TargetFldRef.Validate(TmpInteger);
                end else
                    exit(false);
            'DECIMAL':
                if Evaluate(TmpDecimal, Format(SourceFldRef.Value)) then begin
                    TargetFldRef.Validate(TmpDecimal);
                end else
                    exit(false);
            'DATE':
                if Evaluate(TmpDate, Format(SourceFldRef.Value)) then begin
                    TargetFldRef.Validate(TmpDate);
                end else
                    exit(false);
            'TIME':
                if Evaluate(TmpTime, Format(SourceFldRef.Value)) then begin
                    TargetFldRef.Validate(TmpTime);
                end else
                    exit(false);
            'DATETIME':
                if Evaluate(TmpDateTime, Format(SourceFldRef.Value)) then begin
                    TargetFldRef.Validate(TmpDateTime);
                end else
                    exit(false);
            'BOOLEAN':
                if Evaluate(TmpInteger, Format(SourceFldRef.Value)) then begin
                    case TmpInteger of
                        0:
                            begin
                                TmpBool := false;
                                TargetFldRef.Validate(TmpBool);
                            end;
                        1:
                            begin
                                TmpBool := true;
                                TargetFldRef.Validate(TmpBool);
                            end;
                        2:
                            ;//Skip unknown
                        else
                            exit(false);
                    end;
                end else begin
                    if Evaluate(TmpBool, Format(SourceFldRef.Value)) then
                        TargetFldRef.Validate(TmpBool);
                end;
            'DATEFORMULA':
                if Evaluate(TmpDateFormula, Format(SourceFldRef.Value)) then begin
                    TargetFldRef.Validate(TmpDateFormula);
                end else
                    exit(false);
        end;
        exit(true);
        //+NPR5.25 [246088]
    end;

    local procedure ValidateFieldText(SourceText: Text; TargetFldRef: FieldRef): Boolean
    var
        TmpInteger: Integer;
        TmpDecimal: Decimal;
        TmpDate: Date;
        TmpTime: Time;
        TmpDateFormula: DateFormula;
        TmpBool: Boolean;
        TmpDateTime: DateTime;
    begin
        //-NPR5.25 [246088]
        if Format(SourceText) = Format(TargetFldRef.Value) then
            exit(true); //Skip source and target have the same value
        case UpperCase(Format(TargetFldRef.Type)) of
            'TEXT', 'CODE':
                TargetFldRef.Validate(Format(SourceText));
            'INTEGER':
                if Evaluate(TmpInteger, Format(SourceText)) then begin
                    TargetFldRef.Validate(TmpInteger);
                end else
                    exit(false);
            'OPTION':
                if Evaluate(TmpInteger, Format(SourceText)) then begin
                    if TmpInteger <> 9 then
                        TargetFldRef.Validate(TmpInteger);
                end else
                    exit(false);
            'DECIMAL':
                if Evaluate(TmpDecimal, Format(SourceText)) then begin
                    TargetFldRef.Validate(TmpDecimal);
                end else
                    exit(false);
            'DATE':
                if Evaluate(TmpDate, Format(SourceText)) then begin
                    TargetFldRef.Validate(TmpDate);
                end else
                    exit(false);
            'TIME':
                if Evaluate(TmpTime, Format(SourceText)) then begin
                    TargetFldRef.Validate(TmpTime);
                end else
                    exit(false);
            'DATETIME':
                if Evaluate(TmpDateTime, Format(SourceText)) then begin
                    TargetFldRef.Validate(TmpDateTime);
                end else
                    exit(false);
            'BOOLEAN':
                if Evaluate(TmpInteger, Format(SourceText)) then begin
                    case TmpInteger of
                        0:
                            begin
                                TmpBool := false;
                                TargetFldRef.Validate(TmpBool);
                            end;
                        1:
                            begin
                                TmpBool := true;
                                TargetFldRef.Validate(TmpBool);
                            end;
                    end;
                end else begin
                    if Evaluate(TmpBool, Format(SourceText)) then
                        TargetFldRef.Validate(TmpBool);
                end;
            'DATEFORMULA':
                if Evaluate(TmpDateFormula, Format(SourceText)) then begin
                    TargetFldRef.Validate(TmpDateFormula);
                end else
                    exit(false);
        end;
        exit(true);
        //+NPR5.25 [246088]
    end;

    local procedure IsBlankFieldRef(FldRef: FieldRef; GoingToFieldRef: FieldRef): Boolean
    var
        TmpInteger: Integer;
        TmpDate: Date;
        TmpTime: Time;
        TmpDateTime: DateTime;
    begin
        //-NPR5.25 [246088]
        case UpperCase(Format(GoingToFieldRef.Type)) of
            'TEXT', 'CODE':
                exit(Format(FldRef.Value) = '');
            'INTEGER':
                exit(Format(FldRef.Value) = '0');
            'OPTION':
                if Evaluate(TmpInteger, Format(FldRef.Value)) then begin
                    exit(TmpInteger = 9);
                end else
                    exit(UpperCase(Format(FldRef.Value)) = 'UNDEFINED');
            'DECIMAL':
                exit(DelChr(Format(FldRef.Value), '=', '-0.,') = '');
            'DATE':
                begin
                    Evaluate(TmpDate, Format(FldRef.Value));
                    exit(TmpDate = 0D);
                end;
            'TIME':
                begin
                    Evaluate(TmpTime, Format(FldRef.Value));
                    exit(TmpTime = 0T);
                end;
            'DATETIME':
                begin
                    Evaluate(TmpDateTime, Format(FldRef.Value));
                    exit(TmpDateTime = 0DT);
                end;
            'BOOLEAN':
                begin
                    if Evaluate(TmpInteger, Format(FldRef.Value)) then
                        exit(TmpInteger = 3);
                end;
            'DATEFORMULA':
                exit(Format(FldRef.Value) = '');
        end;
        exit(true);
        //+NPR5.25 [246088]
    end;

    local procedure InsertChangeRecord(ParItemWorksheetLine: Record "NPR Item Worksheet Line"; ParItemWorksheetFieldSetup: Record "NPR Item Worksh. Field Setup"; SourceFldRef: FieldRef; TargetFldRef: FieldRef)
    var
        ItemWorksheetFieldChange: Record "NPR Item Worksh. Field Change";
    begin
        with ItemWorksheetFieldChange do begin
            Init;
            Validate("Worksheet Template Name", ParItemWorksheetLine."Worksheet Template Name");

            Validate("Worksheet Name", ParItemWorksheetLine."Worksheet Name");
            Validate("Worksheet Line No.", ParItemWorksheetLine."Line No.");
            Validate("Table No.", DATABASE::"NPR Item Worksheet Line");
            Validate("Field Number", SourceFldRef.Number);
            Validate("Target Table No. Update", ParItemWorksheetFieldSetup."Target Table No. Update");
            Validate("Target Field Number Update", ParItemWorksheetFieldSetup."Target Field Number Update");
            Validate(Warning, ParItemWorksheetFieldSetup."Process Update" in [ParItemWorksheetFieldSetup."Process Update"::"Warn and Ignore", ParItemWorksheetFieldSetup."Process Update"::"Warn and Process"]);
            Validate(Process, ParItemWorksheetFieldSetup."Process Update" in [ParItemWorksheetFieldSetup."Process Update"::Process, ParItemWorksheetFieldSetup."Process Update"::"Warn and Process"]);
            Validate("Current Value", CopyStr(Format(TargetFldRef.Value), 1, MaxStrLen("Current Value")));
            Validate("New Value", CopyStr(Format(SourceFldRef.Value), 1, MaxStrLen("New Value")));
            Insert;
        end;
    end;
}

