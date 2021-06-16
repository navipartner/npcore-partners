codeunit 6060046 "NPR Item Wsht.Register Line"
{
    Permissions = TableData "NPR Registered Item Works." = imd,
                  TableData "NPR Regist. Item Worksh Line" = imd,
                  TableData "NPR Reg. Item Wsht Var. Line" = imd;
    TableNo = "NPR Item Worksheet Line";

    trigger OnRun()
    begin
        GLSetup.Get();
        RunWithCheck(Rec);
    end;

    var
        GLSetup: Record "General Ledger Setup";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemWorksheetTemplate: Record "NPR Item Worksh. Template";
        ItemWkshVariantLine: Record "NPR Item Worksh. Variant Line";
        ItemWorksheetVarietyValue: Record "NPR Item Worksh. Variety Value";
        ItemWkshLine: Record "NPR Item Worksheet Line";
        RegisteredWorksheetVariantLine: Record "NPR Reg. Item Wsht Var. Line";
        RegisteredWorksheetVarietyValue: Record "NPR Reg. Item Wsht Var. Value";
        RegisteredWorksheetLine: Record "NPR Regist. Item Worksh Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        VarietyCloneData: Codeunit "NPR Variety Clone Data";
        CalledFromTest: Boolean;
        NewItemNo: Code[20];
        VariantExistErr: Label 'Variant already exists.';

    procedure RunWithCheck(var ItemWkshLine2: Record "NPR Item Worksheet Line")
    begin
        ItemWkshLine.Copy(ItemWkshLine2);
        Code();
        ItemWkshLine2 := ItemWkshLine;
    end;

    local procedure "Code"()
    begin
        if ItemWkshLine.EmptyLine() then
            exit;

        if ItemWkshLine.Status = ItemWkshLine.Status::Validated then begin
            ItemWorksheetTemplate.Get(ItemWkshLine."Worksheet Template Name");
            if ItemWkshLine.Action <> ItemWkshLine.Action::Skip then
                OnBeforeRegisterLine(ItemWkshLine);
            case ItemWkshLine.Action of
                ItemWkshLine.Action::Skip:
                    begin
                        if ItemWkshLine."Item No." = '' then
                            ItemWkshLine."Item No." := ItemWkshLine."Existing Item No.";
                    end;
                ItemWkshLine.Action::CreateNew:
                    begin
                        Item.Init();
                        if ItemWkshLine."Item No." <> '' then begin
                            Item.Init();
                            Item."No." := ItemWkshLine."Item No.";
                            Item."No. Series" := ItemWkshLine."No. Series";
                            Item.Validate("No.");
                            ItemWkshLine."Item No." := Item."No.";
                            Item."No. Series" := ItemWkshLine."No. Series";
                            Item.Insert(true);
                        end else begin
                            Item.Init();
                            NewItemNo := ItemWkshLine.GetNewItemNo();
                            if NewItemNo = '' then
                                NoSeriesMgt.InitSeries(ItemWkshLine."No. Series", '', 0D, NewItemNo, ItemWkshLine."No. Series");
                            Item."No." := NewItemNo;
                            Item.Validate("No.", NewItemNo);
                            Item."No. Series" := ItemWkshLine."No. Series";
                            Item.Insert(true);
                            ItemWkshLine."Item No." := NewItemNo;
                        end;
                        CreateItem();
                    end;
                ItemWkshLine.Action::UpdateOnly:
                    begin
                        ItemWkshLine."Item No." := ItemWkshLine."Existing Item No.";
                        UpdateItem();
                    end;
                ItemWkshLine.Action::UpdateAndCreateVariants:
                    begin
                        ItemWkshLine."Item No." := ItemWkshLine."Existing Item No.";
                        UpdateItem();
                    end;
            end;

            ItemWkshVariantLine.Reset();
            ItemWkshVariantLine.SetRange("Worksheet Template Name", ItemWkshLine."Worksheet Template Name");
            ItemWkshVariantLine.SetRange("Worksheet Name", ItemWkshLine."Worksheet Name");
            ItemWkshVariantLine.SetRange("Worksheet Line No.", ItemWkshLine."Line No.");
            ItemWkshVariantLine.SetFilter("Heading Text", '%1', '');
            //Skip Headers
            if ItemWkshVariantLine.FindSet() then
                repeat
                    if ItemWkshVariantLine.Action <> ItemWkshVariantLine.Action::Skip then
                        OnBeforeRegisterVariantLine(ItemWkshVariantLine);
                    case ItemWkshVariantLine.Action of
                        ItemWkshVariantLine.Action::CreateNew:
                            begin
                                if (ItemWkshVariantLine."Variety 1 Value" <> '') or
                                   (ItemWkshVariantLine."Variety 2 Value" <> '') or
                                   (ItemWkshVariantLine."Variety 3 Value" <> '') or
                                   (ItemWkshVariantLine."Variety 4 Value" <> '') then begin
                                    UpdateAndCopyVariety(ItemWkshLine."Variety 1", ItemWkshLine."Variety 1 Table (Base)", ItemWkshLine."Variety 1 Table (New)", ItemWkshVariantLine."Variety 1 Value");
                                    UpdateAndCopyVariety(ItemWkshLine."Variety 2", ItemWkshLine."Variety 2 Table (Base)", ItemWkshLine."Variety 2 Table (New)", ItemWkshVariantLine."Variety 2 Value");
                                    UpdateAndCopyVariety(ItemWkshLine."Variety 3", ItemWkshLine."Variety 3 Table (Base)", ItemWkshLine."Variety 3 Table (New)", ItemWkshVariantLine."Variety 3 Value");
                                    UpdateAndCopyVariety(ItemWkshLine."Variety 4", ItemWkshLine."Variety 4 Table (Base)", ItemWkshLine."Variety 4 Table (New)", ItemWkshVariantLine."Variety 4 Value");
                                    if ItemWkshVariantLine."Item No." = '' then
                                        ItemWkshVariantLine."Item No." := ItemWkshLine."Item No.";
                                    CreateVariant(ItemWkshVariantLine);
                                    ItemWkshVariantLine.UpdateBarcode();
                                    ProcessVariantLineSalesPrice();
                                    ProcessVariantLinePurchasePrice();
                                end;
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
                                ItemWkshVariantLine.UpdateBarcode();
                                ProcessVariantLineSalesPrice();
                                ProcessVariantLinePurchasePrice();
                            end;
                    end;
                    ItemWkshVariantLine.Modify(true);
                    if ItemWkshVariantLine.Action <> ItemWkshVariantLine.Action::Skip then
                        OnAfterRegisterVariantLine(ItemWkshVariantLine);
                until ItemWkshVariantLine.Next() = 0;
            ItemWkshLine.Validate(ItemWkshLine.Status, ItemWkshLine.Status::Processed);
            if not CalledFromTest then
                ItemWkshLine.Modify(true);
            if ItemWkshLine.Action <> ItemWkshLine.Action::Skip then
                OnAfterRegisterLine(ItemWkshLine);
        end;
        if not CalledFromTest then
            CreateRegisteredWorksheetLines();

    end;

    local procedure CreateItem()
    begin
        GetItem(ItemWkshLine."Item No.");
        Item.Validate(Item."Vendor Item No.", ItemWkshLine."Vendor Item No.");
        if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Vendor No.")) then
            Item.Validate(Item."Vendor No.", ItemWkshLine."Vendor No.");
        Item.Validate(Item.Description, ItemWkshLine.Description);
        if ItemWkshLine."Direct Unit Cost" <> 0 then
            if (ItemWkshLine."Purchase Price Currency Code" = '') then
                Item.Validate(Item."Last Direct Cost", ItemWkshLine."Direct Unit Cost");
        Item.Validate(Item."Costing Method", ItemWkshLine."Costing Method");
        if ItemWkshLine."Costing Method" = ItemWkshLine."Costing Method"::Standard then
            if (ItemWkshLine."Purchase Price Currency Code" = '') then
                Item.Validate(Item."Standard Cost", ItemWkshLine."Direct Unit Cost");
        if Item."Unit Cost" = 0 then
            Item."Unit Cost" := ItemWkshLine."Direct Unit Cost";
        if (ItemWkshLine."Sales Price Currency Code" = '') then
            if ItemWkshLine."Sales Price Start Date" <= WorkDate() then
                Item.Validate(Item."Unit Price", ItemWkshLine."Sales Price");
        if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Base Unit of Measure")) then
            Item.Validate(Item."Base Unit of Measure", ItemWkshLine."Base Unit of Measure");
        if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Inventory Posting Group")) then
            Item.Validate(Item."Inventory Posting Group", ItemWkshLine."Inventory Posting Group");
        if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Gen. Prod. Posting Group")) then
            Item.Validate(Item."Gen. Prod. Posting Group", ItemWkshLine."Gen. Prod. Posting Group");
        if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Tax Group Code")) then
            Item.Validate(Item."Tax Group Code", ItemWkshLine."Tax Group Code");
        if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("VAT Prod. Posting Group")) then
            Item.Validate(Item."VAT Prod. Posting Group", ItemWkshLine."VAT Prod. Posting Group");
        if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Global Dimension 1 Code")) then
            Item.Validate(Item."Global Dimension 1 Code", ItemWkshLine."Global Dimension 1 Code");
        if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Global Dimension 2 Code")) then
            Item.Validate(Item."Global Dimension 2 Code", ItemWkshLine."Global Dimension 2 Code");
        ItemWkshLine."Variety 1 Table (New)" := FindNewVarietyNames(ItemWkshLine, 1, ItemWkshLine."Variety 1", ItemWkshLine."Variety 1 Table (Base)", ItemWkshLine."Variety 1 Table (New)", ItemWkshLine."Create Copy of Variety 1 Table");
        ItemWkshLine."Variety 2 Table (New)" := FindNewVarietyNames(ItemWkshLine, 2, ItemWkshLine."Variety 2", ItemWkshLine."Variety 2 Table (Base)", ItemWkshLine."Variety 2 Table (New)", ItemWkshLine."Create Copy of Variety 2 Table");
        ItemWkshLine."Variety 3 Table (New)" := FindNewVarietyNames(ItemWkshLine, 3, ItemWkshLine."Variety 3", ItemWkshLine."Variety 3 Table (Base)", ItemWkshLine."Variety 3 Table (New)", ItemWkshLine."Create Copy of Variety 3 Table");
        ItemWkshLine."Variety 4 Table (New)" := FindNewVarietyNames(ItemWkshLine, 4, ItemWkshLine."Variety 4", ItemWkshLine."Variety 4 Table (Base)", ItemWkshLine."Variety 4 Table (New)", ItemWkshLine."Create Copy of Variety 4 Table");
        Item."NPR Variety 1" := ItemWkshLine."Variety 1";
        Item."NPR Variety 1 Table" := ItemWkshLine."Variety 1 Table (New)";
        Item."NPR Variety 2" := ItemWkshLine."Variety 2";
        Item."NPR Variety 2 Table" := ItemWkshLine."Variety 2 Table (New)";
        Item."NPR Variety 3" := ItemWkshLine."Variety 3";
        Item."NPR Variety 3 Table" := ItemWkshLine."Variety 3 Table (New)";
        Item."NPR Variety 4" := ItemWkshLine."Variety 4";
        Item."NPR Variety 4 Table" := ItemWkshLine."Variety 4 Table (New)";
        Item."NPR Cross Variety No." := ItemWkshLine."Cross Variety No.";
        Item."NPR Variety Group" := ItemWkshLine."Variety Group";
        if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Sales Unit of Measure")) then
            Item.Validate(Item."Sales Unit of Measure", ItemWkshLine."Sales Unit of Measure");
        if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Sales Unit of Measure")) then
            Item.Validate(Item."Purch. Unit of Measure", ItemWkshLine."Sales Unit of Measure");
        if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Manufacturer Code")) then
            Item.Validate(Item."Manufacturer Code", ItemWkshLine."Manufacturer Code");
        if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Item Category Code")) then
            Item.Validate(Item."Item Category Code", ItemWkshLine."Item Category Code");
        Item.Validate(Item."Net Weight", ItemWkshLine."Net Weight");
        Item.Validate(Item."Gross Weight", ItemWkshLine."Gross Weight");
        if not MapStandardItemWorksheetLineField(Item, ItemWkshLine.FieldNo("Tariff No.")) then
            Item.Validate(Item."Tariff No.", ItemWkshLine."Tariff No.");
        ValidateFields(Item, ItemWkshLine, true, false);
        Item.Modify(true);


        ItemWkshLine.UpdateBarcode();
        ProcessLineSalesPrices();
        ProcessLinePurchasePrices();
        UpdateAndCopyVarieties(ItemWkshLine, 1, ItemWkshLine."Variety 1", ItemWkshLine."Variety 1 Table (Base)", ItemWkshLine."Variety 1 Table (New)", ItemWkshLine."Create Copy of Variety 1 Table", true);
        UpdateAndCopyVarieties(ItemWkshLine, 2, ItemWkshLine."Variety 2", ItemWkshLine."Variety 2 Table (Base)", ItemWkshLine."Variety 2 Table (New)", ItemWkshLine."Create Copy of Variety 2 Table", true);
        UpdateAndCopyVarieties(ItemWkshLine, 3, ItemWkshLine."Variety 3", ItemWkshLine."Variety 3 Table (Base)", ItemWkshLine."Variety 3 Table (New)", ItemWkshLine."Create Copy of Variety 3 Table", true);
        UpdateAndCopyVarieties(ItemWkshLine, 4, ItemWkshLine."Variety 4", ItemWkshLine."Variety 4 Table (Base)", ItemWkshLine."Variety 4 Table (New)", ItemWkshLine."Create Copy of Variety 4 Table", true);
        UpdateItemAttributes();
    end;

    local procedure UpdateItem()
    begin
        GetItem(ItemWkshLine."Item No.");
        if (Item."Vendor Item No." <> ItemWkshLine."Vendor Item No.") and (ItemWkshLine."Vendor Item No." <> '') then
            Item.Validate(Item."Vendor Item No.", ItemWkshLine."Vendor Item No.");
        if (Item."Vendor No." <> ItemWkshLine."Vendor No.") and (ItemWkshLine."Vendor No." <> '') then
            Item.Validate(Item."Vendor No.", ItemWkshLine."Vendor No.");
        if (Item.Description <> ItemWkshLine.Description) and (ItemWkshLine.Description <> '') then
            Item.Validate(Item.Description, ItemWkshLine.Description);
        if (Item."Tariff No." <> ItemWkshLine."Tariff No.") and (ItemWkshLine."Tariff No." <> '') then
            Item.Validate(Item."Tariff No.", ItemWkshLine."Tariff No.");
        if (Item."Net Weight" <> ItemWkshLine."Net Weight") and (ItemWkshLine."Net Weight" <> 0) then
            Item.Validate(Item."Net Weight", ItemWkshLine."Net Weight");
        if (Item."Gross Weight" <> ItemWkshLine."Gross Weight") and (ItemWkshLine."Gross Weight" <> 0) then
            Item.Validate(Item."Gross Weight", ItemWkshLine."Gross Weight");
        if Item."Unit Cost" = 0 then
            Item."Unit Cost" := ItemWkshLine."Direct Unit Cost";
        Item.Modify(true);
        ValidateFields(Item, ItemWkshLine, true, false);

        ItemWkshLine.UpdateBarcode();
        ProcessLineSalesPrices();
        ProcessLinePurchasePrices();
        UpdateAndCopyVarieties(ItemWkshLine, 1, ItemWkshLine."Variety 1", ItemWkshLine."Variety 1 Table (Base)", ItemWkshLine."Variety 1 Table (New)", ItemWkshLine."Create Copy of Variety 1 Table", false);
        UpdateAndCopyVarieties(ItemWkshLine, 2, ItemWkshLine."Variety 2", ItemWkshLine."Variety 2 Table (Base)", ItemWkshLine."Variety 2 Table (New)", ItemWkshLine."Create Copy of Variety 2 Table", false);
        UpdateAndCopyVarieties(ItemWkshLine, 3, ItemWkshLine."Variety 3", ItemWkshLine."Variety 3 Table (Base)", ItemWkshLine."Variety 3 Table (New)", ItemWkshLine."Create Copy of Variety 3 Table", false);
        UpdateAndCopyVarieties(ItemWkshLine, 4, ItemWkshLine."Variety 4", ItemWkshLine."Variety 4 Table (Base)", ItemWkshLine."Variety 4 Table (New)", ItemWkshLine."Create Copy of Variety 4 Table", false);
        UpdateItemAttributes();
    end;

    local procedure UpdateAndCopyVarieties(var ItemworkshLine: Record "NPR Item Worksheet Line"; VarietyNo: Integer; Variety: Code[10]; VarietyTableFrom: Code[40]; VarietyTableTo: Code[40]; CreateCopy: Boolean; CopyValues: Boolean)
    var
        ItemWorksheetVariantLineToCreate: Record "NPR Item Worksh. Variant Line";
        VarietyGroup: Record "NPR Variety Group";
        NewVarietyTable: Record "NPR Variety Table";
        VarietyTableOld: Record "NPR Variety Table";
        IsUpdated: Boolean;
        NewTableCode: Code[40];
        PrefixCode: Code[40];
        SuffixCode: Code[20];
    begin
        if CreateCopy then begin
            VarietyTableOld.Get(Variety, VarietyTableFrom);
            if (VarietyTableTo = '') or (VarietyTableFrom = VarietyTableTo) then begin
                if ItemworkshLine."Variety Group" <> '' then begin
                    VarietyGroup.Get(ItemworkshLine."Variety Group");
                end else begin
                    VarietyGroup.Init();
                end;
                SuffixCode := ItemworkshLine."Item No.";
                case VarietyNo of
                    1:
                        if (VarietyGroup."Copy Naming Variety 1" = VarietyGroup."Copy Naming Variety 1"::TableCodeAndNoSeries) and
                          (VarietyGroup."No. Series" <> '') then
                            NoSeriesMgt.InitSeries(VarietyGroup."No. Series", '', WorkDate(), SuffixCode, VarietyGroup."No. Series");
                    2:
                        if (VarietyGroup."Copy Naming Variety 2" = VarietyGroup."Copy Naming Variety 2"::TableCodeAndNoSeries) and
                          (VarietyGroup."No. Series" <> '') then
                            NoSeriesMgt.InitSeries(VarietyGroup."No. Series", '', WorkDate(), SuffixCode, VarietyGroup."No. Series");
                    3:
                        if (VarietyGroup."Copy Naming Variety 3" = VarietyGroup."Copy Naming Variety 3"::TableCodeAndNoSeries) and
                          (VarietyGroup."No. Series" <> '') then
                            NoSeriesMgt.InitSeries(VarietyGroup."No. Series", '', WorkDate(), SuffixCode, VarietyGroup."No. Series");
                    4:
                        if (VarietyGroup."Copy Naming Variety 4" = VarietyGroup."Copy Naming Variety 4"::TableCodeAndNoSeries) and
                          (VarietyGroup."No. Series" <> '') then
                            NoSeriesMgt.InitSeries(VarietyGroup."No. Series", '', WorkDate(), SuffixCode, VarietyGroup."No. Series");
                end;
                if StrPos(VarietyTableFrom, '-') > 0 then
                    PrefixCode := CopyStr(VarietyTableFrom, 1, StrPos(VarietyTableFrom, '-') - 1)
                else
                    PrefixCode := VarietyTableFrom;
                NewTableCode := CopyStr(PrefixCode + '-' + SuffixCode, 1, MaxStrLen(NewTableCode));
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
            end else begin
                NewTableCode := VarietyTableTo;
            end;
            if CopyValues then
                if not NewVarietyTable.Get(Variety, NewTableCode) then
                    VarietyGroup.CopyTable2NewTable(Variety, VarietyTableFrom, NewTableCode);

        end else begin
            NewTableCode := VarietyTableTo;
        end;

        //Copy Worksheet Values
        if CopyValues then begin
            ItemWorksheetVarietyValue.Reset();
            ItemWorksheetVarietyValue.SetRange("Worksheet Template Name", ItemWkshLine."Worksheet Template Name");
            ItemWorksheetVarietyValue.SetRange("Worksheet Name", ItemWkshLine."Worksheet Name");
            ItemWorksheetVarietyValue.SetRange("Worksheet Line No.", ItemWkshLine."Line No.");
            ItemWorksheetVarietyValue.SetRange(Type, Variety);
            if ItemWorksheetVarietyValue.FindSet() then
                repeat
                    IsUpdated := false;
                    ItemWorksheetVariantLineToCreate.SetRange("Worksheet Template Name", ItemWkshLine."Worksheet Template Name");
                    ItemWorksheetVariantLineToCreate.SetRange("Worksheet Name", ItemWkshLine."Worksheet Name");
                    ItemWorksheetVariantLineToCreate.SetRange("Worksheet Line No.", ItemWkshLine."Line No.");
                    ItemWorksheetVariantLineToCreate.SetRange(Action, ItemWorksheetVariantLineToCreate.Action::CreateNew);
                    if ItemWorksheetVariantLineToCreate.FindSet() then
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
                        until (ItemWorksheetVariantLineToCreate.Next() = 0) or IsUpdated;
                    if IsUpdated then
                        UpdateVarietyValue(Variety, NewTableCode, ItemWorksheetVarietyValue.Value, ItemWorksheetVarietyValue."Sort Order", ItemWorksheetVarietyValue.Description);
                until ItemWorksheetVarietyValue.Next() = 0;
        end;
    end;

    local procedure FindNewVarietyNames(ItemWkshLine: Record "NPR Item Worksheet Line"; VarietyNo: Integer; Variety: Code[20]; VarietyTableFrom: Code[40]; VarietyTableTo: Code[40]; CreateCopy: Boolean): Code[40]
    var
        VarietyGroup: Record "NPR Variety Group";
        VarietyTableOld: Record "NPR Variety Table";
        NewTableCode: Code[40];
        PrefixCode: Code[40];
        SuffixCode: Code[20];
    begin
        if VarietyTableFrom = '' then
            VarietyTableFrom := VarietyTableTo;
        if CreateCopy then begin
            VarietyTableOld.Get(Variety, VarietyTableFrom);
            if (VarietyTableTo = '') or (VarietyTableFrom = VarietyTableTo) then begin
                if ItemWkshLine."Variety Group" <> '' then begin
                    VarietyGroup.Get(ItemWkshLine."Variety Group");
                end else begin
                    VarietyGroup.Init();
                end;
                SuffixCode := ItemWkshLine."Item No.";
                case VarietyNo of
                    1:
                        if (VarietyGroup."Copy Naming Variety 1" = VarietyGroup."Copy Naming Variety 1"::TableCodeAndNoSeries) and
                          (VarietyGroup."No. Series" <> '') then
                            NoSeriesMgt.InitSeries(VarietyGroup."No. Series", '', WorkDate(), SuffixCode, VarietyGroup."No. Series");
                    2:
                        if (VarietyGroup."Copy Naming Variety 2" = VarietyGroup."Copy Naming Variety 2"::TableCodeAndNoSeries) and
                          (VarietyGroup."No. Series" <> '') then
                            NoSeriesMgt.InitSeries(VarietyGroup."No. Series", '', WorkDate(), SuffixCode, VarietyGroup."No. Series");
                    3:
                        if (VarietyGroup."Copy Naming Variety 3" = VarietyGroup."Copy Naming Variety 3"::TableCodeAndNoSeries) and
                          (VarietyGroup."No. Series" <> '') then
                            NoSeriesMgt.InitSeries(VarietyGroup."No. Series", '', WorkDate(), SuffixCode, VarietyGroup."No. Series");
                    4:
                        if (VarietyGroup."Copy Naming Variety 4" = VarietyGroup."Copy Naming Variety 4"::TableCodeAndNoSeries) and
                          (VarietyGroup."No. Series" <> '') then
                            NoSeriesMgt.InitSeries(VarietyGroup."No. Series", '', WorkDate(), SuffixCode, VarietyGroup."No. Series");
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
    end;

    local procedure UpdateAndCopyVariety(Variety: Code[20]; VarietyTableFrom: Code[40]; VarietyTableTo: Code[40]; VarietyValue: Code[50])
    var
        ExistingVarityValue: Record "NPR Variety Value";
        NewVarietyValue: Record "NPR Variety Value";
    begin
        if Variety <> '' then begin
            if VarietyValue <> '' then begin
                if not ExistingVarityValue.Get(Variety, VarietyTableFrom, VarietyValue) then
                    ExistingVarityValue.Init();
                if not NewVarietyValue.Get(Variety, VarietyTableTo, VarietyValue) then begin
                    NewVarietyValue.Init();
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
    end;

    local procedure UpdateVarietyValue(ParType: Code[10]; ParTable: Code[40]; ParValue: Code[50]; ParSortOrder: Integer; ParDescription: Text[30])
    var
        VarietyValue: Record "NPR Variety Value";
    begin
        if ParType <> '' then begin
            if ParValue <> '' then begin
                Clear(VarietyValue);
                if not VarietyValue.Get(ParType, ParTable, ParValue) then begin
                    VarietyValue.Init();
                    VarietyValue.Type := ParType;
                    VarietyValue.Table := ParTable;
                    VarietyValue.Value := ParValue;
                    VarietyValue.Description := ParDescription;
                    VarietyValue."Sort Order" := ParSortOrder;
                    VarietyValue.Insert();
                end;
            end;
        end;
    end;

    local procedure CreateVariant(var ItemWkshVariantLine: Record "NPR Item Worksh. Variant Line")
    begin
        if VarietyCloneData.GetFromVariety(ItemVariant, ItemWkshVariantLine."Item No.", ItemWkshVariantLine."Variety 1 Value",
                                     ItemWkshVariantLine."Variety 2 Value", ItemWkshVariantLine."Variety 3 Value",
                                     ItemWkshVariantLine."Variety 4 Value") then
            Error(VariantExistErr);

        ItemWkshVariantLine.CalcFields("Variety 1 Table", "Variety 2 Table", "Variety 3 Table", "Variety 4 Table",
                                       "Variety 1", "Variety 2", "Variety 3", "Variety 4");
        ItemVariant.Init();
        ItemVariant."Item No." := ItemWkshVariantLine."Item No.";
        if ItemWkshVariantLine."Variant Code" = '' then begin
            ItemVariant.Code := VarietyCloneData.GetNextVariantCode(ItemWkshVariantLine."Item No.",
                                                                    ItemWkshVariantLine."Variety 1 Value", ItemWkshVariantLine."Variety 2 Value",
                                                                    ItemWkshVariantLine."Variety 3 Value", ItemWkshVariantLine."Variety 4 Value");
            ItemWkshVariantLine."Variant Code" := ItemVariant.Code;
        end else begin
            ItemVariant.Code := ItemWkshVariantLine."Variant Code";
        end;
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


    local procedure GetItem(ItemNo: Code[20])
    begin
        if Item."No." <> ItemNo then
            Item.Get(ItemNo);
    end;

    local procedure UpdateItemAttributes()
    var
        AttributeID: Record "NPR Attribute ID";
        AttributeKey: Record "NPR Attribute Key";
        AttributeValueSet: Record "NPR Attribute Value Set";
        AttributeManagement: Codeunit "NPR Attribute Management";
        TxtAttributeNotSetUp: Label 'Attribute %1 is not set up on the Item table, so it cannot be used with item %2.';
    begin
        AttributeKey.SetCurrentKey("Table ID", "MDR Code PK");
        AttributeKey.SetFilter("Table ID", '=%1', DATABASE::"NPR Item Worksheet Line");
        AttributeKey.SetFilter("MDR Code PK", '=%1', ItemWkshLine."Worksheet Template Name");
        AttributeKey.SetFilter("MDR Code 2 PK", '=%1', ItemWkshLine."Worksheet Name");
        AttributeKey.SetFilter("MDR Line PK", '=%1', ItemWkshLine."Line No.");
        AttributeKey.SetFilter("MDR Line 2 PK", '=%1', 0);

        // Fill array
        if AttributeKey.FindFirst() then begin
            AttributeValueSet.Reset();
            AttributeValueSet.SetRange("Attribute Set ID", AttributeKey."Attribute Set ID");
            if AttributeValueSet.FindSet() then
                repeat
                    if not AttributeID.Get(DATABASE::Item, AttributeValueSet."Attribute Code") then
                        Error(TxtAttributeNotSetUp, AttributeValueSet."Attribute Code", ItemWkshLine."Item No.");
                    AttributeManagement.SetMasterDataAttributeValue(DATABASE::Item, AttributeID."Shortcut Attribute ID", ItemWkshLine."Item No.", AttributeValueSet."Text Value");
                until AttributeValueSet.Next() = 0;
        end;
    end;

    local procedure CreateRegisteredWorksheetLines()
    begin
        if ItemWorksheetTemplate."Register Lines" then begin
            CopyToRegisteredWorksheetLine();

            ItemWkshVariantLine.Reset();
            ItemWkshVariantLine.SetRange("Worksheet Template Name", ItemWkshLine."Worksheet Template Name");
            ItemWkshVariantLine.SetRange("Worksheet Name", ItemWkshLine."Worksheet Name");
            ItemWkshVariantLine.SetRange("Worksheet Line No.", ItemWkshLine."Line No.");
            if ItemWkshVariantLine.FindSet() then
                repeat
                    CopyToRegisteredWorksheetVariantLine();
                until ItemWkshVariantLine.Next() = 0;

            ItemWorksheetVarietyValue.Reset();
            ItemWorksheetVarietyValue.SetRange("Worksheet Template Name", ItemWkshLine."Worksheet Template Name");
            ItemWorksheetVarietyValue.SetRange("Worksheet Name", ItemWkshLine."Worksheet Name");
            ItemWorksheetVarietyValue.SetRange("Worksheet Line No.", ItemWkshLine."Line No.");
            if ItemWorksheetVarietyValue.FindSet() then
                repeat
                    CopyToRegisteredWorksheetVarietyValueLine();
                until ItemWorksheetVarietyValue.Next() = 0;
        end;
    end;

    local procedure CopyToRegisteredWorksheetLine()
    begin
        RegisteredWorksheetLine."Registered Worksheet No." := LastRegisteredWorksheetNo();
        RegisteredWorksheetLine."Line No." := ItemWkshLine."Line No.";
        RegisteredWorksheetLine.Action := ItemWkshLine.Action;
        RegisteredWorksheetLine."Existing Item No." := ItemWkshLine."Existing Item No.";
        RegisteredWorksheetLine."Item No." := ItemWkshLine."Item No.";
        RegisteredWorksheetLine."Vendor Item No." := ItemWkshLine."Vendor Item No.";
        RegisteredWorksheetLine."Internal Bar Code" := ItemWkshLine."Internal Bar Code";
        RegisteredWorksheetLine."Vendor No." := ItemWkshLine."Vendor No.";
        RegisteredWorksheetLine.Description := ItemWkshLine.Description;
        RegisteredWorksheetLine."Direct Unit Cost" := ItemWkshLine."Direct Unit Cost";
        RegisteredWorksheetLine."Unit Price (LCY)" := ItemWkshLine."Sales Price";
        RegisteredWorksheetLine."Use Variant" := ItemWkshLine."Use Variant";
        RegisteredWorksheetLine."Base Unit of Measure" := ItemWkshLine."Base Unit of Measure";
        RegisteredWorksheetLine."Inventory Posting Group" := ItemWkshLine."Inventory Posting Group";
        RegisteredWorksheetLine."Costing Method" := ItemWkshLine."Costing Method";
        RegisteredWorksheetLine."Vendors Bar Code" := ItemWkshLine."Vendors Bar Code";
        RegisteredWorksheetLine."VAT Bus. Posting Group" := ItemWkshLine."VAT Bus. Posting Group";
        RegisteredWorksheetLine."VAT Bus. Posting Gr. (Price)" := ItemWkshLine."VAT Bus. Posting Gr. (Price)";
        RegisteredWorksheetLine."Gen. Prod. Posting Group" := ItemWkshLine."Gen. Prod. Posting Group";
        RegisteredWorksheetLine."No. Series" := ItemWkshLine."No. Series";
        RegisteredWorksheetLine."Tax Group Code" := ItemWkshLine."Tax Group Code";
        RegisteredWorksheetLine."VAT Prod. Posting Group" := ItemWkshLine."VAT Prod. Posting Group";
        RegisteredWorksheetLine."Global Dimension 1 Code" := ItemWkshLine."Global Dimension 2 Code";
        RegisteredWorksheetLine.Status := ItemWkshLine.Status;
        RegisteredWorksheetLine."Status Comment" := ItemWkshLine."Status Comment";
        RegisteredWorksheetLine."Variety 1" := ItemWkshLine."Variety 1";
        RegisteredWorksheetLine."Variety 1 Table (Base)" := ItemWkshLine."Variety 1 Table (Base)";
        RegisteredWorksheetLine."Create Copy of Variety 1 Table" := ItemWkshLine."Create Copy of Variety 1 Table";
        RegisteredWorksheetLine."Variety 1 Table (New)" := ItemWkshLine."Variety 1 Table (New)";
        RegisteredWorksheetLine."Variety 1 Lock Table" := ItemWkshLine."Variety 1 Lock Table";
        RegisteredWorksheetLine."Variety 2" := ItemWkshLine."Variety 1";
        RegisteredWorksheetLine."Variety 2 Table (Base)" := ItemWkshLine."Variety 2 Table (Base)";
        RegisteredWorksheetLine."Create Copy of Variety 2 Table" := ItemWkshLine."Create Copy of Variety 2 Table";
        RegisteredWorksheetLine."Variety 2 Table (New)" := ItemWkshLine."Variety 2 Table (New)";
        RegisteredWorksheetLine."Variety 2 Lock Table" := ItemWkshLine."Variety 2 Lock Table";
        RegisteredWorksheetLine."Variety 3" := ItemWkshLine."Variety 1";
        RegisteredWorksheetLine."Variety 3 Table (Base)" := ItemWkshLine."Variety 3 Table (Base)";
        RegisteredWorksheetLine."Create Copy of Variety 3 Table" := ItemWkshLine."Create Copy of Variety 3 Table";
        RegisteredWorksheetLine."Variety 3 Table (New)" := ItemWkshLine."Variety 3 Table (New)";
        RegisteredWorksheetLine."Variety 3 Lock Table" := ItemWkshLine."Variety 3 Lock Table";
        RegisteredWorksheetLine."Variety 4 Table (Base)" := ItemWkshLine."Variety 4 Table (Base)";
        RegisteredWorksheetLine."Create Copy of Variety 4 Table" := ItemWkshLine."Create Copy of Variety 4 Table";
        RegisteredWorksheetLine."Variety 4 Table (New)" := ItemWkshLine."Variety 4 Table (New)";
        RegisteredWorksheetLine."Variety 4 Lock Table" := ItemWkshLine."Variety 4 Lock Table";
        RegisteredWorksheetLine."Cross Variety No." := ItemWkshLine."Cross Variety No.";
        RegisteredWorksheetLine."Variety Group" := ItemWkshLine."Variety Group";
        RegisteredWorksheetLine."Sales Unit of Measure" := ItemWkshLine."Sales Unit of Measure";
        RegisteredWorksheetLine."Purch. Unit of Measure" := ItemWkshLine."Purch. Unit of Measure";
        RegisteredWorksheetLine."Manufacturer Code" := ItemWkshLine."Manufacturer Code";
        RegisteredWorksheetLine."Item Category Code" := ItemWkshLine."Item Category Code";
        RegisteredWorksheetLine."Product Group Code" := ItemWkshLine."Product Group Code";
        RegisteredWorksheetLine."Variant Code" := ItemWkshLine."Variant Code";
        RegisteredWorksheetLine."Sales Price Currency Code" := ItemWkshLine."Sales Price Currency Code";
        RegisteredWorksheetLine."Purchase Price Currency Code" := ItemWkshLine."Purchase Price Currency Code";
        RegisteredWorksheetLine."Sales Price Start Date" := ItemWkshLine."Sales Price Start Date";
        RegisteredWorksheetLine."Purchase Price Start Date" := ItemWkshLine."Purchase Price Start Date";
        RegisteredWorksheetLine."Tariff No." := ItemWkshLine."Tariff No.";
        RegisteredWorksheetLine."No. 2" := ItemWkshLine."No. 2";
        RegisteredWorksheetLine.Type := ItemWkshLine.Type;
        RegisteredWorksheetLine."Shelf No." := ItemWkshLine."Shelf No.";
        RegisteredWorksheetLine."Item Disc. Group" := ItemWkshLine."Item Disc. Group";
        RegisteredWorksheetLine."Allow Invoice Disc." := ItemWkshLine."Allow Invoice Disc.";
        RegisteredWorksheetLine."Statistics Group" := ItemWkshLine."Statistics Group";
        RegisteredWorksheetLine."Commission Group" := ItemWkshLine."Commission Group";
        RegisteredWorksheetLine."Price/Profit Calculation" := ItemWkshLine."Price/Profit Calculation";
        RegisteredWorksheetLine."Profit %" := ItemWkshLine."Profit %";
        RegisteredWorksheetLine."Lead Time Calculation" := ItemWkshLine."Lead Time Calculation";
        RegisteredWorksheetLine."Reorder Point" := ItemWkshLine."Reorder Point";
        RegisteredWorksheetLine."Maximum Inventory" := ItemWkshLine."Maximum Inventory";
        RegisteredWorksheetLine."Reorder Quantity" := ItemWkshLine."Reorder Quantity";
        RegisteredWorksheetLine."Unit List Price" := ItemWkshLine."Unit List Price";
        RegisteredWorksheetLine."Duty Due %" := ItemWkshLine."Duty Due %";
        RegisteredWorksheetLine."Duty Code" := ItemWkshLine."Duty Code";
        RegisteredWorksheetLine."Units per Parcel" := ItemWkshLine."Units per Parcel";
        RegisteredWorksheetLine."Unit Volume" := ItemWkshLine."Unit Volume";
        RegisteredWorksheetLine.Durability := ItemWkshLine.Durability;
        RegisteredWorksheetLine."Freight Type" := ItemWkshLine."Freight Type";
        RegisteredWorksheetLine."Duty Unit Conversion" := ItemWkshLine."Duty Unit Conversion";
        RegisteredWorksheetLine."Country/Region Purchased Code" := ItemWkshLine."Country/Region Purchased Code";
        RegisteredWorksheetLine."Budget Quantity" := ItemWkshLine."Budget Quantity";
        RegisteredWorksheetLine."Budgeted Amount" := ItemWkshLine."Budgeted Amount";
        RegisteredWorksheetLine."Budget Profit" := ItemWkshLine."Budget Profit";
        RegisteredWorksheetLine.Blocked := ItemWkshLine.Blocked;
        RegisteredWorksheetLine."Price Includes VAT" := ItemWkshLine."Price Includes VAT";
        RegisteredWorksheetLine."Country/Region of Origin Code" := ItemWkshLine."Country/Region of Origin Code";
        RegisteredWorksheetLine."Automatic Ext. Texts" := ItemWkshLine."Automatic Ext. Texts";
        RegisteredWorksheetLine.Reserve := ItemWkshLine.Reserve;
        RegisteredWorksheetLine."Stockout Warning" := ItemWkshLine."Stockout Warning";
        RegisteredWorksheetLine."Prevent Negative Inventory" := ItemWkshLine."Prevent Negative Inventory";
        RegisteredWorksheetLine."Assembly Policy" := ItemWkshLine."Assembly Policy";
        RegisteredWorksheetLine.GTIN := ItemWkshLine.GTIN;
        RegisteredWorksheetLine."Lot Size" := ItemWkshLine."Lot Size";
        RegisteredWorksheetLine."Serial Nos." := ItemWkshLine."Serial Nos.";
        RegisteredWorksheetLine."Scrap %" := ItemWkshLine."Scrap %";
        RegisteredWorksheetLine."Inventory Value Zero" := ItemWkshLine."Inventory Value Zero";
        RegisteredWorksheetLine."Discrete Order Quantity" := ItemWkshLine."Discrete Order Quantity";
        RegisteredWorksheetLine."Minimum Order Quantity" := ItemWkshLine."Minimum Order Quantity";
        RegisteredWorksheetLine."Maximum Order Quantity" := ItemWkshLine."Maximum Order Quantity";
        RegisteredWorksheetLine."Safety Stock Quantity" := ItemWkshLine."Safety Stock Quantity";
        RegisteredWorksheetLine."Order Multiple" := ItemWkshLine."Order Multiple";
        RegisteredWorksheetLine."Safety Lead Time" := ItemWkshLine."Safety Lead Time";
        RegisteredWorksheetLine."Flushing Method" := ItemWkshLine."Flushing Method";
        RegisteredWorksheetLine."Replenishment System" := ItemWkshLine."Replenishment System";
        RegisteredWorksheetLine."Reordering Policy" := ItemWkshLine."Reordering Policy";
        RegisteredWorksheetLine."Include Inventory" := ItemWkshLine."Include Inventory";
        RegisteredWorksheetLine."Manufacturing Policy" := ItemWkshLine."Manufacturing Policy";
        RegisteredWorksheetLine."Rescheduling Period" := ItemWkshLine."Rescheduling Period";
        RegisteredWorksheetLine."Lot Accumulation Period" := ItemWkshLine."Lot Accumulation Period";
        RegisteredWorksheetLine."Dampener Period" := ItemWkshLine."Dampener Period";
        RegisteredWorksheetLine."Dampener Quantity" := ItemWkshLine."Dampener Quantity";
        RegisteredWorksheetLine."Overflow Level" := ItemWkshLine."Overflow Level";
        RegisteredWorksheetLine."Service Item Group" := ItemWkshLine."Service Item Group";
        RegisteredWorksheetLine."Item Tracking Code" := ItemWkshLine."Item Tracking Code";
        RegisteredWorksheetLine."Lot Nos." := ItemWkshLine."Lot Nos.";
        RegisteredWorksheetLine."Expiration Calculation" := ItemWkshLine."Expiration Calculation";
        RegisteredWorksheetLine."Special Equipment Code" := ItemWkshLine."Special Equipment Code";
        RegisteredWorksheetLine."Put-away Template Code" := ItemWkshLine."Put-away Template Code";
        RegisteredWorksheetLine."Put-away Unit of Measure Code" := ItemWkshLine."Put-away Unit of Measure Code";
        RegisteredWorksheetLine."Phys Invt Counting Period Code" := ItemWkshLine."Phys Invt Counting Period Code";
        RegisteredWorksheetLine."Use Cross-Docking" := ItemWkshLine."Use Cross-Docking";
        RegisteredWorksheetLine."Custom Text 1" := ItemWkshLine."Custom Text 1";
        RegisteredWorksheetLine."Custom Text 2" := ItemWkshLine."Custom Text 2";
        RegisteredWorksheetLine."Custom Text 3" := ItemWkshLine."Custom Text 3";
        RegisteredWorksheetLine."Custom Text 4" := ItemWkshLine."Custom Text 4";
        RegisteredWorksheetLine."Custom Text 5" := ItemWkshLine."Custom Text 5";
        RegisteredWorksheetLine."Custom Price 1" := ItemWkshLine."Custom Price 1";
        RegisteredWorksheetLine."Custom Price 2" := ItemWkshLine."Custom Price 2";
        RegisteredWorksheetLine."Custom Price 3" := ItemWkshLine."Custom Price 3";
        RegisteredWorksheetLine."Custom Price 4" := ItemWkshLine."Custom Price 4";
        RegisteredWorksheetLine."Custom Price 5" := ItemWkshLine."Custom Price 5";
        RegisteredWorksheetLine."Group sale" := ItemWkshLine."Group sale";
        RegisteredWorksheetLine.Season := ItemWkshLine.Season;
        RegisteredWorksheetLine."Label Barcode" := ItemWkshLine."Label Barcode";
        RegisteredWorksheetLine."Explode BOM auto" := ItemWkshLine."Explode BOM auto";
        RegisteredWorksheetLine."Guarantee voucher" := ItemWkshLine."Guarantee voucher";
        RegisteredWorksheetLine."Cannot edit unit price" := ItemWkshLine."Cannot edit unit price";
        RegisteredWorksheetLine."Second-hand number" := ItemWkshLine."Second-hand number";
        RegisteredWorksheetLine.Condition := ItemWkshLine.Condition;
        RegisteredWorksheetLine."Second-hand" := ItemWkshLine."Second-hand";
        RegisteredWorksheetLine."Guarantee Index" := ItemWkshLine."Guarantee Index";
        RegisteredWorksheetLine."Insurrance category" := ItemWkshLine."Insurrance category";
        RegisteredWorksheetLine."Item Brand" := ItemWkshLine."Item Brand";
        RegisteredWorksheetLine."Type Retail" := ItemWkshLine."Type Retail";
        RegisteredWorksheetLine."No Print on Reciept" := ItemWkshLine."No Print on Reciept";
        RegisteredWorksheetLine."Print Tags" := ItemWkshLine."Print Tags";
        RegisteredWorksheetLine."Change quantity by Photoorder" := ItemWkshLine."Change quantity by Photoorder";
        RegisteredWorksheetLine."Std. Sales Qty." := ItemWkshLine."Std. Sales Qty.";
        RegisteredWorksheetLine."Blocked on Pos" := ItemWkshLine."Blocked on Pos";
        RegisteredWorksheetLine."Ticket Type" := ItemWkshLine."Ticket Type";
        RegisteredWorksheetLine."Magento Status" := ItemWkshLine."Magento Status";
        RegisteredWorksheetLine.Backorder := ItemWkshLine.Backorder;
        RegisteredWorksheetLine."Product New From" := ItemWkshLine."Product New From";
        RegisteredWorksheetLine."Product New To" := ItemWkshLine."Product New To";
        RegisteredWorksheetLine."Attribute Set ID" := ItemWkshLine."Attribute Set ID";
        RegisteredWorksheetLine."Special Price" := ItemWkshLine."Special Price";
        RegisteredWorksheetLine."Special Price From" := ItemWkshLine."Special Price From";
        RegisteredWorksheetLine."Special Price To" := ItemWkshLine."Special Price To";
        RegisteredWorksheetLine."Magento Brand" := ItemWkshLine."Magento Brand";
        RegisteredWorksheetLine."Display Only" := ItemWkshLine."Display Only";
        RegisteredWorksheetLine."Magento Item" := ItemWkshLine."Magento Item";
        RegisteredWorksheetLine."Magento Name" := ItemWkshLine."Magento Name";
        RegisteredWorksheetLine."Seo Link" := ItemWkshLine."Seo Link";
        RegisteredWorksheetLine."Meta Title" := ItemWkshLine."Meta Title";
        RegisteredWorksheetLine."Meta Description" := ItemWkshLine."Meta Description";
        RegisteredWorksheetLine."Featured From" := ItemWkshLine."Featured From";
        RegisteredWorksheetLine."Featured To" := ItemWkshLine."Featured To";
        RegisteredWorksheetLine."Routing No." := ItemWkshLine."Routing No.";
        RegisteredWorksheetLine."Production BOM No." := ItemWkshLine."Production BOM No.";
        RegisteredWorksheetLine."Overhead Rate" := ItemWkshLine."Overhead Rate";
        RegisteredWorksheetLine."Order Tracking Policy" := ItemWkshLine."Order Tracking Policy";
        RegisteredWorksheetLine.Critical := ItemWkshLine.Critical;
        RegisteredWorksheetLine."Common Item No." := ItemWkshLine."Common Item No.";
        RegisteredWorksheetLine.Insert();
    end;

    local procedure CopyToRegisteredWorksheetVariantLine()
    begin
        RegisteredWorksheetVariantLine."Registered Worksheet No." := LastRegisteredWorksheetNo();
        RegisteredWorksheetVariantLine."Registered Worksheet Line No." := ItemWkshLine."Line No.";
        RegisteredWorksheetVariantLine."Line No." := ItemWkshVariantLine."Line No.";
        RegisteredWorksheetVariantLine.Level := ItemWkshVariantLine.Level;
        RegisteredWorksheetVariantLine.Action := ItemWkshVariantLine.Action;
        RegisteredWorksheetVariantLine."Item No." := ItemWkshVariantLine."Item No.";
        RegisteredWorksheetVariantLine."Existing Item No." := ItemWkshVariantLine."Existing Item No.";
        RegisteredWorksheetVariantLine."Existing Variant Code" := ItemWkshVariantLine."Existing Variant Code";
        RegisteredWorksheetVariantLine."Variant Code" := ItemWkshVariantLine."Variant Code";
        RegisteredWorksheetVariantLine."Internal Bar Code" := ItemWkshVariantLine."Internal Bar Code";
        RegisteredWorksheetVariantLine."Sales Price" := ItemWkshVariantLine."Sales Price";
        RegisteredWorksheetVariantLine."Direct Unit Cost" := ItemWkshVariantLine."Direct Unit Cost";
        RegisteredWorksheetVariantLine."Vendors Bar Code" := ItemWkshVariantLine."Vendors Bar Code";
        RegisteredWorksheetVariantLine."Heading Text" := ItemWkshVariantLine."Heading Text";
        RegisteredWorksheetVariantLine."Variety 1 Value" := ItemWkshVariantLine."Variety 1 Value";
        RegisteredWorksheetVariantLine."Variety 2 Value" := ItemWkshVariantLine."Variety 2 Value";
        RegisteredWorksheetVariantLine."Variety 3 Value" := ItemWkshVariantLine."Variety 3 Value";
        RegisteredWorksheetVariantLine."Variety 4 Value" := ItemWkshVariantLine."Variety 4 Value";
        RegisteredWorksheetVariantLine.Description := ItemWkshVariantLine.Description;
        RegisteredWorksheetVariantLine.Blocked := ItemWkshVariantLine.Blocked;
        RegisteredWorksheetVariantLine.Insert();
    end;

    local procedure CopyToRegisteredWorksheetVarietyValueLine()
    begin
        RegisteredWorksheetVarietyValue."Registered Worksheet No." := LastRegisteredWorksheetNo();
        RegisteredWorksheetVarietyValue."Registered Worksheet Line No." := ItemWorksheetVarietyValue."Worksheet Line No.";
        RegisteredWorksheetVarietyValue.Type := ItemWorksheetVarietyValue.Type;
        RegisteredWorksheetVarietyValue.Table := ItemWorksheetVarietyValue.Table;
        RegisteredWorksheetVarietyValue.Value := ItemWorksheetVarietyValue.Value;
        RegisteredWorksheetVarietyValue."Sort Order" := ItemWorksheetVarietyValue."Sort Order";
        RegisteredWorksheetVarietyValue.Description := ItemWorksheetVarietyValue.Description;
        RegisteredWorksheetVarietyValue.Insert();
    end;

    local procedure LastRegisteredWorksheetNo(): Integer
    var
        RegisteredItemWorksheet: Record "NPR Registered Item Works.";
    begin
        RegisteredItemWorksheet.FindLast();
        exit(RegisteredItemWorksheet."No.");
    end;


    local procedure ProcessLineSalesPrices()
    var
        SalesPrice: Record "Sales Price";
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        SalesUnitOfMeasure: Code[10];
        SalesPriceEndDate: Date;
        SalesPriceStartDate: Date;
    begin
        if ItemWkshLine."Sales Price" = 0 then
            exit;
        GetItem(ItemWkshLine."Item No.");
        if ItemWkshLine."Sales Price" <> Item."Unit Price" then begin
            if ItemWkshLine."Sales Price Currency Code" = '' then begin
                if ItemWkshLine."Sales Price Start Date" <= WorkDate() then begin
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

        SalesPrice.Reset();
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
                    SalesPriceStartDate := WorkDate();
                    if ItemWkshLine."Sales Price Start Date" <> 0D then
                        SalesPriceStartDate := ItemWkshLine."Sales Price Start Date";
                    SalesPrice.SetFilter("Starting Date", '>%1', SalesPriceStartDate);
                    if SalesPrice.FindFirst() then
                        SalesPriceEndDate := SalesPrice."Starting Date" - 1
                    else
                        SalesPriceEndDate := 0D;
                end;
        end;
        SalesPrice.SetRange("Starting Date", SalesPriceStartDate);
        if SalesPrice.FindFirst() then begin
            if SalesPrice."Ending Date" <> SalesPriceEndDate then begin
                SalesPrice.Validate("Ending Date", SalesPriceEndDate);
            end;
            if SalesPrice."Unit Price" <> ItemWkshLine."Sales Price" then begin
                SalesPrice.Validate("Unit Price", ItemWkshLine."Sales Price");
            end;
            SalesPrice.Modify(true);
            if not MasterLineMapMgt.IsMaster(Database::"Sales Price", SalesPrice.SystemId) then
                MasterLineMapMgt.CreateMap(Database::"Sales Price", SalesPrice.SystemId, SalesPrice.SystemId);
        end else begin
            SalesPrice.Init();
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
            SalesPrice.Insert(true);

            MasterLineMapMgt.CreateMap(Database::"Sales Price", SalesPrice.SystemId, SalesPrice.SystemId);
        end;
        case ItemWorksheetTemplate."Sales Price Handling" of
            ItemWorksheetTemplate."Sales Price Handling"::"Item+Variant":
                begin
                    CloseRelatedSalesPrices(SalesPrice, WorkDate() - 1);
                end;
            ItemWorksheetTemplate."Sales Price Handling"::"Item+Date",
            ItemWorksheetTemplate."Sales Price Handling"::"Item+Variant+Date":
                begin
                    CloseRelatedSalesPrices(SalesPrice, SalesPriceStartDate - 1);
                end;
        end;
    end;


    local procedure ProcessVariantLineSalesPrice()
    var
        SalesPrice: Record "Sales Price";
        SalesPriceMaster: Record "Sales Price";
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        OnlyCloseExistingPrices: Boolean;
        SalesUnitOfMeasure: Code[10];
        SalesPriceEndDate: Date;
        SalesPriceStartDate: Date;
        VariantSalesPrice: Decimal;
        MasterLineFound: Boolean;
    begin
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

        SalesPrice.Reset();
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
                    SalesPriceStartDate := WorkDate();
                    if ItemWkshLine."Sales Price Start Date" <> 0D then
                        SalesPriceStartDate := ItemWkshLine."Sales Price Start Date";
                    SalesPrice.SetFilter("Starting Date", '>%1', SalesPriceStartDate);
                    if SalesPrice.FindFirst() then
                        SalesPriceEndDate := SalesPrice."Starting Date" - 1
                    else
                        SalesPriceEndDate := 0D;
                end;
        end;
        SalesPrice.SetRange("Starting Date", SalesPriceStartDate);
        if SalesPrice.FindFirst() then begin
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
            SalesPriceMaster.Reset();
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
            MasterLineFound := false;
            if SalesPriceMaster.FindSet() then // todo: rewrite with query (or not, sales price is going)?
                repeat
                    if MasterLineMapMgt.IsMaster(Database::"Sales Price", SalesPriceMaster.SystemId) then begin
                        MasterLineFound := true;
                        Break;
                    end;
                until SalesPriceMaster.Next() = 0;
            // SalesPriceMaster.SetRange("NPR Is Master", true);
            if MasterLineFound then begin
                SalesPrice := SalesPriceMaster;
                SalesPrice."Variant Code" := ItemWkshVariantLine."Variant Code";
                if (SalesPriceMaster."Unit Price" <> VariantSalesPrice) and (not OnlyCloseExistingPrices) then begin
                    SalesPrice.Validate("Variant Code");
                    SalesPrice.Validate("Unit Price", VariantSalesPrice);
                    SalesPrice.Validate("Ending Date", SalesPriceEndDate);
                    SalesPrice.Insert(true);

                    MasterLineMapMgt.CreateMap(Database::"Sales Line", SalesPrice.SystemId, SalesPriceMaster.SystemId);
                end;
            end else begin
                SalesPrice.Init();
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
                    CloseRelatedSalesPrices(SalesPrice, WorkDate() - 1);
                end;
            ItemWorksheetTemplate."Sales Price Handling"::"Item+Variant+Date":
                begin
                    CloseRelatedSalesPrices(SalesPrice, SalesPriceStartDate - 1);
                end;
        end;
    end;

    procedure SetCalledFromTest(ParCalledFromTest: Boolean)
    begin
        CalledFromTest := ParCalledFromTest;
    end;

    local procedure CloseRelatedSalesPrices(SalesPrice: Record "Sales Price"; EndingDate: Date)
    var
        SalesPrice2: Record "Sales Price";
    begin
        GetItem(SalesPrice."Item No.");
        SalesPrice2.Reset();
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
        if SalesPrice2.FindSet() then
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
            until SalesPrice2.Next() = 0;
    end;

    procedure ProcessLinePurchasePrices()
    var
        PurchasePrice: Record "Purchase Price";
    begin
        if ItemWkshLine."Direct Unit Cost" = 0 then
            exit;
        GetItem(ItemWkshLine."Item No.");
        if ItemWorksheetTemplate."Purchase Price Handling" = ItemWorksheetTemplate."Purchase Price Handling"::Item then begin
            if ItemWkshLine."Direct Unit Cost" <> Item."Last Direct Cost" then begin
                Item.Validate("Last Direct Cost", ItemWkshLine."Direct Unit Cost");
                Item.Modify(true);
            end;
            exit;
        end;
        PurchasePrice.Reset();
        PurchasePrice.SetRange("Vendor No.", ItemWkshLine."Vendor No.");
        PurchasePrice.SetRange("Item No.", ItemWkshLine."Item No.");
        PurchasePrice.SetRange("Variant Code", '');
        PurchasePrice.SetRange("Currency Code", ItemWkshLine."Purchase Price Currency Code");
        if ItemWkshLine."Purchase Price Start Date" <> 0D then
            PurchasePrice.SetRange("Starting Date", ItemWkshLine."Purchase Price Start Date")
        else
            PurchasePrice.SetRange("Starting Date", 0D, WorkDate());
        if PurchasePrice.FindLast() then begin
            //Found Purchase Price
            if PurchasePrice."Direct Unit Cost" <> ItemWkshLine."Direct Unit Cost" then begin
                if (ItemWorksheetTemplate."Purchase Price Handling" = ItemWorksheetTemplate."Purchase Price Handling"::"Item+Variant") or (PurchasePrice."Starting Date" = WorkDate()) or
                  (ItemWkshLine."Purchase Price Start Date" <> 0D) then begin
                    PurchasePrice.Validate("Direct Unit Cost", ItemWkshLine."Direct Unit Cost");
                    PurchasePrice.Modify(true);
                end else begin
                    PurchasePrice.Validate("Ending Date", WorkDate() - 1);
                    PurchasePrice.Modify(true);
                    PurchasePrice.Validate("Ending Date", 0D);
                    PurchasePrice.Validate("Direct Unit Cost", ItemWkshLine."Direct Unit Cost");
                    if ItemWkshLine."Purchase Price Start Date" <> 0D then
                        PurchasePrice.Validate("Starting Date", ItemWkshLine."Purchase Price Start Date")
                    else
                        PurchasePrice.Validate("Starting Date", WorkDate());
                    PurchasePrice.Insert(true);
                end;
            end;
        end else begin
            //Create a new Purchase Price
            PurchasePrice.Init();
            PurchasePrice.Validate("Vendor No.", ItemWkshLine."Vendor No.");
            PurchasePrice.Validate("Item No.", ItemWkshLine."Item No.");
            PurchasePrice.Validate("Unit of Measure Code", Item."Purch. Unit of Measure");
            PurchasePrice.Validate("Direct Unit Cost", ItemWkshLine."Direct Unit Cost");
            PurchasePrice.Validate("Currency Code", ItemWkshLine."Purchase Price Currency Code");
            if (ItemWorksheetTemplate."Purchase Price Handling" <> ItemWorksheetTemplate."Purchase Price Handling"::"Item+Variant") then
                PurchasePrice.Validate("Starting Date", WorkDate());
            if ItemWkshLine."Purchase Price Start Date" <> 0D then
                PurchasePrice.Validate("Starting Date", ItemWkshLine."Purchase Price Start Date");
            PurchasePrice.Insert(true);
        end;
    end;

    local procedure ProcessVariantLinePurchasePrice()
    var
        PurchasePrice: Record "Purchase Price";
        PurchasePriceItem: Record "Purchase Price";
    begin
        if ItemWkshVariantLine."Direct Unit Cost" = 0 then
            exit;
        if ItemWorksheetTemplate."Purchase Price Handling" = ItemWorksheetTemplate."Purchase Price Handling"::"Item+Date" then
            exit;
        PurchasePrice.Reset();
        PurchasePrice.SetRange("Vendor No.", ItemWkshLine."Vendor No.");
        PurchasePrice.SetRange("Item No.", ItemWkshVariantLine."Item No.");
        PurchasePrice.SetRange("Variant Code", ItemWkshVariantLine."Variant Code");
        PurchasePrice.SetRange("Currency Code", ItemWkshLine."Purchase Price Currency Code");
        if ItemWkshLine."Purchase Price Start Date" <> 0D then
            PurchasePrice.SetRange("Starting Date", ItemWkshLine."Purchase Price Start Date")
        else
            PurchasePrice.SetRange("Starting Date", 0D, WorkDate());
        if PurchasePrice.FindLast() then begin
            //existing variant price found
            if ItemWkshVariantLine."Direct Unit Cost" <> PurchasePrice."Direct Unit Cost" then begin
                if (ItemWorksheetTemplate."Purchase Price Handling" = ItemWorksheetTemplate."Purchase Price Handling"::"Item+Variant") or (PurchasePrice."Starting Date" = WorkDate()) or
                  (ItemWkshLine."Purchase Price Start Date" <> 0D) then begin
                    PurchasePrice.Validate("Direct Unit Cost", ItemWkshVariantLine."Direct Unit Cost");
                    PurchasePrice.Modify(true);
                end else begin
                    PurchasePrice.Validate("Ending Date", WorkDate() - 1);
                    PurchasePrice.Modify(true);
                    PurchasePrice.Validate("Ending Date", 0D);
                    PurchasePrice.Validate("Direct Unit Cost", ItemWkshVariantLine."Direct Unit Cost");
                    PurchasePrice.Validate("Starting Date", WorkDate());
                    PurchasePrice.Insert(true);
                end;
            end;
        end else begin
            PurchasePriceItem.Reset();
            PurchasePriceItem.SetRange("Vendor No.", ItemWkshLine."Vendor No.");
            PurchasePriceItem.SetRange("Item No.", ItemWkshVariantLine."Item No.");
            PurchasePriceItem.SetRange("Currency Code", ItemWkshLine."Purchase Price Currency Code");
            if ItemWkshLine."Purchase Price Start Date" <> 0D then
                PurchasePrice.SetRange("Starting Date", ItemWkshLine."Purchase Price Start Date")
            else
                PurchasePrice.SetRange("Starting Date", 0D, WorkDate());
            if PurchasePrice.FindLast() then begin
                //existing item price
                if PurchasePriceItem."Direct Unit Cost" <> ItemWkshVariantLine."Direct Unit Cost" then begin
                    PurchasePrice.Init();
                    PurchasePrice := PurchasePriceItem;
                    PurchasePrice.Validate("Variant Code", ItemWkshVariantLine."Variant Code");
                    PurchasePrice.Validate("Direct Unit Cost", ItemWkshVariantLine."Direct Unit Cost");
                    PurchasePrice.Validate("Currency Code", ItemWkshLine."Purchase Price Currency Code");
                    if (ItemWorksheetTemplate."Purchase Price Handling" <> ItemWorksheetTemplate."Purchase Price Handling"::"Item+Variant") then
                        PurchasePrice.Validate("Starting Date", WorkDate());
                    PurchasePrice.Insert(true);
                end;
            end else begin
                //No Price found
                PurchasePrice.Init();
                PurchasePrice.Validate("Vendor No.", ItemWkshLine."Vendor No.");
                PurchasePrice.Validate("Item No.", ItemWkshLine."Item No.");
                PurchasePrice.Validate("Variant Code", ItemWkshVariantLine."Variant Code");
                PurchasePrice.Validate("Unit of Measure Code", Item."Purch. Unit of Measure");
                PurchasePrice.Validate("Direct Unit Cost", ItemWkshVariantLine."Direct Unit Cost");
                PurchasePrice.Validate("Currency Code", ItemWkshLine."Purchase Price Currency Code");
                if (ItemWorksheetTemplate."Purchase Price Handling" <> ItemWorksheetTemplate."Purchase Price Handling"::"Item+Variant") then
                    PurchasePrice.Validate("Starting Date", WorkDate());
                if ItemWkshLine."Purchase Price Start Date" <> 0D then
                    PurchasePrice.Validate("Starting Date", ItemWkshLine."Purchase Price Start Date");
                PurchasePrice.Insert(true);
            end;
        end;
    end;

    procedure InsertChangeRecords(VarItemWkshLine: Record "NPR Item Worksheet Line")
    var
        ExistingItem: Record Item;
    begin
        if VarItemWkshLine."Existing Item No." = '' then
            exit;
        if not ExistingItem.Get(VarItemWkshLine."Existing Item No.") then
            exit;
        ValidateFields(ExistingItem, VarItemWkshLine, false, true);
    end;

    local procedure ValidateFields(var VarItem: Record Item; var VarItemWkshLine: Record "NPR Item Worksheet Line"; DoValidateFields: Boolean; DoInsertChangeRecords: Boolean)
    var
        SourceFieldRec: Record "Field";
        TargetFieldRec: Record "Field";
        ItemWorksheetFieldChange: Record "NPR Item Worksh. Field Change";
        ItemWorksheetFieldSetup: Record "NPR Item Worksh. Field Setup";
        ItemRecRef: RecordRef;
        ItemWorksheetRecRef: RecordRef;
        ItemFldRef: FieldRef;
        ItemWorksheetFldRef: FieldRef;
        FieldCouldNotValidateErr: Label 'Target field %1 in table %2 could not be validated with value %3.', Comment = '%1 = Field Caption; %2 = Table Name; %3 = Default Value for Create';
    begin
        VarItem.Get(VarItem."No.");
        ItemRecRef.Get(VarItem.RecordId);
        ItemWorksheetRecRef.Get(VarItemWkshLine.RecordId);

        ItemWorksheetFieldChange.Reset();
        ItemWorksheetFieldChange.SetRange("Worksheet Template Name", VarItemWkshLine."Worksheet Template Name");
        ItemWorksheetFieldChange.SetRange("Worksheet Name", VarItemWkshLine."Worksheet Name");
        ItemWorksheetFieldChange.SetRange("Worksheet Line No.", VarItemWkshLine."Line No.");
        ItemWorksheetFieldChange.DeleteAll();

        ItemWorksheetFieldSetup.Reset();
        ItemWorksheetFieldSetup.SetFilter("Worksheet Template Name", '%1|%2', VarItemWkshLine."Worksheet Template Name", '');
        ItemWorksheetFieldSetup.SetFilter("Worksheet Name", '%1|%2', VarItemWkshLine."Worksheet Name", '');
        ItemWorksheetFieldSetup.SetRange("Table No.", DATABASE::"NPR Item Worksheet Line");
        if ItemWorksheetFieldSetup.FindSet() then
            repeat
                //Find the setup on Template, Worksheet or General
                ItemWorksheetFieldSetup.SetRange("Field Number", ItemWorksheetFieldSetup."Field Number");
                ItemWorksheetFieldSetup.FindLast();
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
                                            TargetFieldRec.Init();
                                            if not TargetFieldRec.Get(ItemWorksheetFieldSetup."Target Table No. Create", ItemWorksheetFieldSetup."Target Field Number Create") then
                                                if not TargetFieldRec.Get(DATABASE::Item, ItemWorksheetFieldSetup."Field Number") then
                                                    TargetFieldRec.Init();
                                            if TargetFieldRec."No." <> 0 then begin
                                                ItemFldRef := ItemRecRef.Field(TargetFieldRec."No.");
                                                if not MapField(ItemWorksheetFieldSetup, ItemWorksheetFldRef, ItemFldRef) then
                                                    if not ValidateFieldRef(ItemWorksheetFldRef, ItemFldRef) then
                                                        Error(FieldCouldNotValidateErr, TargetFieldRec."Field Caption", TargetFieldRec.TableName, Format(ItemWorksheetFldRef.Value));
                                            end;
                                        end;
                                    end;
                                ItemWorksheetFieldSetup."Process Create"::"Use Default on Blank":
                                    begin
                                        if SourceFieldRec.Get(ItemWorksheetFieldSetup."Table No.", ItemWorksheetFieldSetup."Field Number") then begin
                                            ItemWorksheetFldRef := ItemWorksheetRecRef.Field(SourceFieldRec."No.");
                                            TargetFieldRec.Init();
                                            if not TargetFieldRec.Get(ItemWorksheetFieldSetup."Target Table No. Create", ItemWorksheetFieldSetup."Target Field Number Create") then
                                                if not TargetFieldRec.Get(DATABASE::Item, ItemWorksheetFieldSetup."Field Number") then
                                                    TargetFieldRec.Init();
                                            if TargetFieldRec."No." <> 0 then begin
                                                ItemFldRef := ItemRecRef.Field(TargetFieldRec."No.");
                                                if IsBlankFieldRef(ItemWorksheetFldRef, ItemFldRef) then begin
                                                    if not ValidateFieldText(ItemWorksheetFieldSetup."Default Value for Create", ItemFldRef) then
                                                        Error(FieldCouldNotValidateErr, TargetFieldRec."Field Caption", TargetFieldRec.TableName, ItemWorksheetFieldSetup."Default Value for Create");
                                                end else begin
                                                    if not MapField(ItemWorksheetFieldSetup, ItemWorksheetFldRef, ItemFldRef) then
                                                        if not ValidateFieldRef(ItemWorksheetFldRef, ItemFldRef) then
                                                            Error(FieldCouldNotValidateErr, TargetFieldRec."Field Caption", TargetFieldRec.TableName, Format(ItemWorksheetFldRef.Value));
                                                end;
                                            end;
                                        end;
                                    end;
                                ItemWorksheetFieldSetup."Process Create"::"Always use Default":
                                    begin
                                        TargetFieldRec.Init();
                                        if not TargetFieldRec.Get(ItemWorksheetFieldSetup."Target Table No. Create", ItemWorksheetFieldSetup."Target Field Number Create") then
                                            if not TargetFieldRec.Get(DATABASE::Item, ItemWorksheetFieldSetup."Field Number") then
                                                TargetFieldRec.Init();
                                        if TargetFieldRec."No." <> 0 then begin
                                            ItemFldRef := ItemRecRef.Field(TargetFieldRec."No.");
                                            if not ValidateFieldText(ItemWorksheetFieldSetup."Default Value for Create", ItemFldRef) then
                                                Error(FieldCouldNotValidateErr, TargetFieldRec."Field Caption", TargetFieldRec.TableName, ItemWorksheetFieldSetup."Default Value for Create");
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
                                TargetFieldRec.Init();
                                if not TargetFieldRec.Get(ItemWorksheetFieldSetup."Target Table No. Create", ItemWorksheetFieldSetup."Target Field Number Update") then
                                    if not TargetFieldRec.Get(DATABASE::Item, ItemWorksheetFieldSetup."Target Field Number Update") then
                                        TargetFieldRec.Init();
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
                                                            Error(FieldCouldNotValidateErr, TargetFieldRec."Field Caption", TargetFieldRec.TableName, Format(ItemWorksheetFldRef.Value));
                                        end;
                                    end;
                                end;
                            end;
                        end;
                end;
            until ItemWorksheetFieldSetup.Next() = 0;
        if DoValidateFields then
            ItemRecRef.Modify(true);
        VarItem.Get(VarItem."No.");
    end;

    local procedure MapStandardItemWorksheetLineField(var VarItem: Record Item; SourceFieldNo: Integer): Boolean
    var
        ItemWorksheetFieldSetup: Record "NPR Item Worksh. Field Setup";
        ItemRecRef: RecordRef;
        ItemWorksheetRecRef: RecordRef;
        ItemFldRef: FieldRef;
        ItemWorksheetFldRef: FieldRef;
    begin
        ItemWorksheetFieldSetup.SetFilter("Worksheet Template Name", '%1|%2', ItemWkshLine."Worksheet Template Name", '');
        ItemWorksheetFieldSetup.SetFilter("Worksheet Name", '%1|%2', ItemWkshLine."Worksheet Name", '');
        ItemWorksheetFieldSetup.SetRange("Table No.", DATABASE::"NPR Item Worksheet Line");
        ItemWorksheetFieldSetup.SetRange("Field Number", SourceFieldNo);
        if not ItemWorksheetFieldSetup.FindLast() then
            exit(false);
        ItemRecRef.Get(VarItem.RecordId);
        ItemWorksheetRecRef.Get(ItemWkshLine.RecordId);
        ItemWorksheetFldRef := ItemWorksheetRecRef.Field(SourceFieldNo);
        ItemFldRef := ItemRecRef.Field(ItemWorksheetFieldSetup."Target Field Number Create");
        if MapField(ItemWorksheetFieldSetup, ItemWorksheetFldRef, ItemFldRef) then begin
            ItemRecRef.Modify();
            exit(true);
        end else
            exit(false);
    end;

    local procedure MapField(ItemWorksheetFieldSetup: Record "NPR Item Worksh. Field Setup"; SourceFldRef: FieldRef; var TargetFldRef: FieldRef): Boolean
    var
        ItemWorksheetFieldMapping: Record "NPR Item Worksh. Field Mapping";
        RecRef: RecordRef;
    begin
        ItemWorksheetFieldMapping.SetRange("Worksheet Template Name", ItemWorksheetFieldSetup."Worksheet Template Name");
        ItemWorksheetFieldMapping.SetRange("Worksheet Name", ItemWorksheetFieldSetup."Worksheet Name");
        ItemWorksheetFieldMapping.SetRange("Table No.", ItemWorksheetFieldSetup."Table No.");
        ItemWorksheetFieldMapping.SetRange("Field Number", ItemWorksheetFieldSetup."Field Number");
        if ItemWorksheetFieldMapping.FindSet() then
            repeat
                RecRef := SourceFldRef.Record();
                RecRef.SetRecFilter();
                //Exact
                case ItemWorksheetFieldMapping.Matching of
                    ItemWorksheetFieldMapping.Matching::Exact:
                        begin
                            if ItemWorksheetFieldMapping."Case Sensitive" then begin
                                ItemWorksheetFieldMapping.SetFilter("Source Value", Format(SourceFldRef.Value));
                                if ItemWorksheetFieldMapping.FindFirst() then
                                    if ValidateFieldText(ItemWorksheetFieldMapping."Target Value", TargetFldRef) then
                                        exit(true);
                            end else begin
                                SourceFldRef.SetFilter('@' + Format(ItemWorksheetFieldMapping."Source Value"));
                                if RecRef.FindFirst() then
                                    if ValidateFieldText(ItemWorksheetFieldMapping."Target Value", TargetFldRef) then
                                        exit(true);
                            end;
                        end;
                    ItemWorksheetFieldMapping.Matching::"Starts With":
                        begin
                            if ItemWorksheetFieldMapping."Case Sensitive" then begin
                                SourceFldRef.SetFilter(Format(ItemWorksheetFieldMapping."Source Value") + '*');
                                if RecRef.FindFirst() then
                                    if ValidateFieldText(ItemWorksheetFieldMapping."Target Value", TargetFldRef) then
                                        exit(true);
                            end else begin
                                ItemWorksheetFieldMapping.SetFilter("Source Value", '@' + Format(SourceFldRef.Value) + '*');
                                SourceFldRef.SetFilter(Format(ItemWorksheetFieldMapping."Source Value") + '*');
                                if RecRef.FindFirst() then
                                    if ValidateFieldText(ItemWorksheetFieldMapping."Target Value", TargetFldRef) then
                                        exit(true);
                            end;
                        end;
                    ItemWorksheetFieldMapping.Matching::"Ends With":
                        begin
                            if ItemWorksheetFieldMapping."Case Sensitive" then begin
                                SourceFldRef.SetFilter('*' + Format(ItemWorksheetFieldMapping."Source Value"));
                                if RecRef.FindFirst() then
                                    if ValidateFieldText(ItemWorksheetFieldMapping."Target Value", TargetFldRef) then
                                        exit(true);
                            end else begin
                                SourceFldRef.SetFilter('*@' + Format(ItemWorksheetFieldMapping."Source Value"));
                                if RecRef.FindFirst() then
                                    if ValidateFieldText(ItemWorksheetFieldMapping."Target Value", TargetFldRef) then
                                        exit(true);
                            end;
                        end;
                    ItemWorksheetFieldMapping.Matching::Contains:
                        begin
                            if ItemWorksheetFieldMapping."Case Sensitive" then begin
                                SourceFldRef.SetFilter('*' + Format(ItemWorksheetFieldMapping."Source Value") + '*');
                                if RecRef.FindFirst() then
                                    if ValidateFieldText(ItemWorksheetFieldMapping."Target Value", TargetFldRef) then
                                        exit(true);
                            end else begin
                                SourceFldRef.SetFilter('*@' + Format(ItemWorksheetFieldMapping."Source Value") + '*');
                                if RecRef.FindFirst() then
                                    if ValidateFieldText(ItemWorksheetFieldMapping."Target Value", TargetFldRef) then
                                        exit(true);
                            end;
                        end;
                end;
            until ItemWorksheetFieldMapping.Next() = 0;
        exit(false);
    end;

    local procedure ValidateFieldRef(SourceFldRef: FieldRef; TargetFldRef: FieldRef): Boolean
    var
        TmpDateFormula: DateFormula;
        TmpBool: Boolean;
        TmpDate: Date;
        TmpDateTime: DateTime;
        TmpDecimal: Decimal;
        TmpInteger: Integer;
        TmpTime: Time;
    begin
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
    end;

    local procedure ValidateFieldText(SourceText: Text; TargetFldRef: FieldRef): Boolean
    var
        TmpDateFormula: DateFormula;
        TmpBool: Boolean;
        TmpDate: Date;
        TmpDateTime: DateTime;
        TmpDecimal: Decimal;
        TmpInteger: Integer;
        TmpTime: Time;
    begin
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
    end;

    local procedure IsBlankFieldRef(FldRef: FieldRef; GoingToFieldRef: FieldRef): Boolean
    var
        TmpDate: Date;
        TmpDateTime: DateTime;
        TmpInteger: Integer;
        TmpTime: Time;
    begin
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
    end;

    local procedure InsertChangeRecord(ParItemWorksheetLine: Record "NPR Item Worksheet Line"; ParItemWorksheetFieldSetup: Record "NPR Item Worksh. Field Setup"; SourceFldRef: FieldRef; TargetFldRef: FieldRef)
    var
        ItemWorksheetFieldChange: Record "NPR Item Worksh. Field Change";
    begin
        ItemWorksheetFieldChange.Init();
        ItemWorksheetFieldChange.Validate("Worksheet Template Name", ParItemWorksheetLine."Worksheet Template Name");
        ItemWorksheetFieldChange.Validate("Worksheet Name", ParItemWorksheetLine."Worksheet Name");
        ItemWorksheetFieldChange.Validate("Worksheet Line No.", ParItemWorksheetLine."Line No.");
        ItemWorksheetFieldChange.Validate("Table No.", DATABASE::"NPR Item Worksheet Line");
        ItemWorksheetFieldChange.Validate("Field Number", SourceFldRef.Number);
        ItemWorksheetFieldChange.Validate("Target Table No. Update", ParItemWorksheetFieldSetup."Target Table No. Update");
        ItemWorksheetFieldChange.Validate("Target Field Number Update", ParItemWorksheetFieldSetup."Target Field Number Update");
        ItemWorksheetFieldChange.Validate(Warning, ParItemWorksheetFieldSetup."Process Update" in [ParItemWorksheetFieldSetup."Process Update"::"Warn and Ignore", ParItemWorksheetFieldSetup."Process Update"::"Warn and Process"]);
        ItemWorksheetFieldChange.Validate(Process, ParItemWorksheetFieldSetup."Process Update" in [ParItemWorksheetFieldSetup."Process Update"::Process, ParItemWorksheetFieldSetup."Process Update"::"Warn and Process"]);
        ItemWorksheetFieldChange.Validate("Current Value", CopyStr(Format(TargetFldRef.Value), 1, MaxStrLen(ItemWorksheetFieldChange."Current Value")));
        ItemWorksheetFieldChange.Validate("New Value", CopyStr(Format(SourceFldRef.Value), 1, MaxStrLen(ItemWorksheetFieldChange."New Value")));
        ItemWorksheetFieldChange.Insert();
    end;

    [BusinessEvent(false)]
    local procedure OnAfterRegisterLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
    end;

    [BusinessEvent(false)]
    local procedure OnAfterRegisterVariantLine(var ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line")
    begin
    end;

    [BusinessEvent(false)]
    local procedure OnBeforeRegisterLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
    end;

    [BusinessEvent(false)]
    local procedure OnBeforeRegisterVariantLine(var ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line")
    begin
    end;
}