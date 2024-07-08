codeunit 6060046 "NPR Item Wsht.Register Line"
{
    Access = Internal;
    Permissions = TableData "NPR Registered Item Works." = imd,
                  TableData "NPR Regist. Item Worksh Line" = imd,
                  TableData "NPR Reg. Item Wsht Var. Line" = imd;
    TableNo = "NPR Item Worksheet Line";

    trigger OnRun()
    begin
        RunWithCheck(Rec);
    end;

    var
        ItemVariant: Record "Item Variant";
        ItemWorksheetTemplate: Record "NPR Item Worksh. Template";
        _ItemWkshVariantLine: Record "NPR Item Worksh. Variant Line";
        ItemWorksheetVarietyValue: Record "NPR Item Worksh. Variety Value";
        _ItemWkshLine: Record "NPR Item Worksheet Line";
        RegisteredWorksheetVarietyValue: Record "NPR Reg. Item Wsht Var. Value";
        RegisteredWorksheetLine: Record "NPR Regist. Item Worksh Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        VarietyCloneData: Codeunit "NPR Variety Clone Data";
        CalledFromTest: Boolean;
        VariantExistErr: Label 'Variant already exists.';

    procedure RunWithCheck(var ItemWkshLine2: Record "NPR Item Worksheet Line")
    begin
        _ItemWkshLine.Copy(ItemWkshLine2);
        Code();
        ItemWkshLine2 := _ItemWkshLine;
    end;

    local procedure "Code"()
    var
        ItemWorksheetCU: Codeunit "NPR Item Worksheet";
        Item: Record Item;
        ItemNo: Code[20];
    begin
        if _ItemWkshLine.EmptyLine() then
            exit;

        if _ItemWkshLine.Status = _ItemWkshLine.Status::Validated then begin
            ItemWorksheetTemplate.Get(_ItemWkshLine."Worksheet Template Name");
            if _ItemWkshLine.Action <> _ItemWkshLine.Action::Skip then
                OnBeforeRegisterLine(_ItemWkshLine);
            case _ItemWkshLine.Action of
                _ItemWkshLine.Action::Skip:
                    begin
                        if _ItemWkshLine."Item No." = '' then
                            _ItemWkshLine."Item No." := _ItemWkshLine."Existing Item No.";
                    end;
                _ItemWkshLine.Action::CreateNew:
                    begin
                        Item.Init();
                        ItemNo := _ItemWkshLine."Item No.";

                        if ItemNo = '' then
                            ItemNo := _ItemWkshLine.GetNewItemNo();

                        if ItemNo = '' then
                            NoSeriesMgt.InitSeries(_ItemWkshLine."No. Series", '', 0D, ItemNo, _ItemWkshLine."No. Series");

                        Item.Validate("No.", ItemNo);
                        Item."No. Series" := _ItemWkshLine."No. Series";
                        Item.Insert(true);

                        if ItemNo <> _ItemWkshLine."Item No." then
                            _ItemWkshLine."Item No." := ItemNo;

                        CreateItem(Item);
                    end;
                _ItemWkshLine.Action::UpdateOnly:
                    begin
                        _ItemWkshLine."Item No." := _ItemWkshLine."Existing Item No.";
                        Item.Get(_ItemWkshLine."Existing Item No.");
                        UpdateItem(Item);
                    end;
                _ItemWkshLine.Action::UpdateAndCreateVariants:
                    begin
                        _ItemWkshLine."Item No." := _ItemWkshLine."Existing Item No.";
                        Item.Get(_ItemWkshLine."Existing Item No.");
                        UpdateItem(Item);
                    end;
            end;

            _ItemWkshVariantLine.Reset();
            _ItemWkshVariantLine.SetRange("Worksheet Template Name", _ItemWkshLine."Worksheet Template Name");
            _ItemWkshVariantLine.SetRange("Worksheet Name", _ItemWkshLine."Worksheet Name");
            _ItemWkshVariantLine.SetRange("Worksheet Line No.", _ItemWkshLine."Line No.");
            _ItemWkshVariantLine.SetFilter("Heading Text", '%1', '');
            //Skip Headers
            if _ItemWkshVariantLine.FindSet() then
                repeat
                    if _ItemWkshVariantLine.Action <> _ItemWkshVariantLine.Action::Skip then
                        OnBeforeRegisterVariantLine(_ItemWkshVariantLine);
                    case _ItemWkshVariantLine.Action of
                        _ItemWkshVariantLine.Action::CreateNew:
                            begin
                                if (_ItemWkshVariantLine."Variety 1 Value" <> '') or
                                   (_ItemWkshVariantLine."Variety 2 Value" <> '') or
                                   (_ItemWkshVariantLine."Variety 3 Value" <> '') or
                                   (_ItemWkshVariantLine."Variety 4 Value" <> '') then begin
                                    UpdateAndCopyVariety(_ItemWkshLine."Variety 1", _ItemWkshLine."Variety 1 Table (Base)", _ItemWkshLine."Variety 1 Table (New)", _ItemWkshVariantLine."Variety 1 Value");
                                    UpdateAndCopyVariety(_ItemWkshLine."Variety 2", _ItemWkshLine."Variety 2 Table (Base)", _ItemWkshLine."Variety 2 Table (New)", _ItemWkshVariantLine."Variety 2 Value");
                                    UpdateAndCopyVariety(_ItemWkshLine."Variety 3", _ItemWkshLine."Variety 3 Table (Base)", _ItemWkshLine."Variety 3 Table (New)", _ItemWkshVariantLine."Variety 3 Value");
                                    UpdateAndCopyVariety(_ItemWkshLine."Variety 4", _ItemWkshLine."Variety 4 Table (Base)", _ItemWkshLine."Variety 4 Table (New)", _ItemWkshVariantLine."Variety 4 Value");
                                    if _ItemWkshVariantLine."Item No." = '' then
                                        _ItemWkshVariantLine."Item No." := _ItemWkshLine."Item No.";
                                    CreateVariant(_ItemWkshVariantLine, Item);
                                    _ItemWkshVariantLine.UpdateBarcode();
                                    ProcessVariantLineSalesPrice(Item);
                                    ProcessVariantLinePurchasePrice(Item);
                                end;
                            end;
                        _ItemWkshVariantLine.Action::Update:
                            begin
                                ItemVariant.Get(_ItemWkshVariantLine."Existing Item No.", _ItemWkshVariantLine."Existing Variant Code");
                                _ItemWkshVariantLine."Item No." := _ItemWkshVariantLine."Existing Item No.";
                                _ItemWkshVariantLine."Variant Code" := _ItemWkshVariantLine."Existing Variant Code";
                                if _ItemWkshVariantLine.Description <> '' then
                                    ItemVariant.Description := _ItemWkshVariantLine.Description;
#IF (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
                                ItemVariant."NPR Blocked" := _ItemWkshVariantLine.Blocked;
#ELSE
                                ItemVariant.Blocked := _ItemWkshVariantLine.Blocked;
#ENDIF
                                ItemVariant.Modify(true);
                                _ItemWkshVariantLine.UpdateBarcode();
                                ProcessVariantLineSalesPrice(Item);
                                ProcessVariantLinePurchasePrice(Item);
                            end;
                    end;
                    _ItemWkshVariantLine.Modify(true);
                    if _ItemWkshVariantLine.Action <> _ItemWkshVariantLine.Action::Skip then
                        OnAfterRegisterVariantLine(_ItemWkshVariantLine);
                until _ItemWkshVariantLine.Next() = 0;
            _ItemWkshLine.Validate(_ItemWkshLine.Status, _ItemWkshLine.Status::Processed);
            if not CalledFromTest then
                _ItemWkshLine.Modify(true);
            if _ItemWkshLine.Action <> _ItemWkshLine.Action::Skip then
                ItemWorksheetCU.OnAfterRegisterLine(_ItemWkshLine);
        end;
        if not CalledFromTest then
            CreateRegisteredWorksheetLines();

    end;

    local procedure CreateItem(var Item: Record Item)
    var
        UnitCostLCY: Decimal;
        UnitPriceLCY: Decimal;
    begin
        UnitCostLCY := CalculateAmountToLCY(_ItemWkshLine."Purchase Price Currency Code", _ItemWkshLine."Direct Unit Cost");

        Item.Validate("Vendor Item No.", _ItemWkshLine."Vend Item No.");
        if not MapStandardItemWorksheetLineField(Item, _ItemWkshLine, _ItemWkshLine.FieldNo("Vendor No.")) then
            Item.Validate("Vendor No.", _ItemWkshLine."Vendor No.");
        Item.Validate(Description, _ItemWkshLine.Description);
        if _ItemWkshLine."Direct Unit Cost" <> 0 then
            Item.Validate("Last Direct Cost", UnitCostLCY);
        Item.Validate("Costing Method", _ItemWkshLine."Costing Method");
        if _ItemWkshLine."Costing Method" = _ItemWkshLine."Costing Method"::Standard then
            Item.Validate("Standard Cost", UnitCostLCY);
        if Item."Unit Cost" = 0 then
            Item."Unit Cost" := UnitCostLCY;
        if _ItemWkshLine."Sales Price Start Date" <= WorkDate() then begin
            UnitPriceLCY := CalculateAmountToLCY(_ItemWkshLine."Sales Price Currency Code", _ItemWkshLine."Sales Price");
            Item.Validate("Unit Price", UnitPriceLCY);
        end;
        if not MapStandardItemWorksheetLineField(Item, _ItemWkshLine, _ItemWkshLine.FieldNo("Base Unit of Measure")) then
            Item.Validate("Base Unit of Measure", _ItemWkshLine."Base Unit of Measure");
        if not MapStandardItemWorksheetLineField(Item, _ItemWkshLine, _ItemWkshLine.FieldNo("Inventory Posting Group")) then
            Item.Validate("Inventory Posting Group", _ItemWkshLine."Inventory Posting Group");
        if not MapStandardItemWorksheetLineField(Item, _ItemWkshLine, _ItemWkshLine.FieldNo("Gen. Prod. Posting Group")) then
            Item.Validate("Gen. Prod. Posting Group", _ItemWkshLine."Gen. Prod. Posting Group");
        if not MapStandardItemWorksheetLineField(Item, _ItemWkshLine, _ItemWkshLine.FieldNo("Tax Group Code")) then
            Item.Validate("Tax Group Code", _ItemWkshLine."Tax Group Code");
        if not MapStandardItemWorksheetLineField(Item, _ItemWkshLine, _ItemWkshLine.FieldNo("VAT Prod. Posting Group")) then
            Item.Validate("VAT Prod. Posting Group", _ItemWkshLine."VAT Prod. Posting Group");
        if not MapStandardItemWorksheetLineField(Item, _ItemWkshLine, _ItemWkshLine.FieldNo("Global Dimension 1 Code")) then
            Item.Validate("Global Dimension 1 Code", _ItemWkshLine."Global Dimension 1 Code");
        if not MapStandardItemWorksheetLineField(Item, _ItemWkshLine, _ItemWkshLine.FieldNo("Global Dimension 2 Code")) then
            Item.Validate("Global Dimension 2 Code", _ItemWkshLine."Global Dimension 2 Code");
        _ItemWkshLine."Variety 1 Table (New)" := FindNewVarietyNames(_ItemWkshLine, 1, _ItemWkshLine."Variety 1", _ItemWkshLine."Variety 1 Table (Base)", _ItemWkshLine."Variety 1 Table (New)", _ItemWkshLine."Create Copy of Variety 1 Table");
        _ItemWkshLine."Variety 2 Table (New)" := FindNewVarietyNames(_ItemWkshLine, 2, _ItemWkshLine."Variety 2", _ItemWkshLine."Variety 2 Table (Base)", _ItemWkshLine."Variety 2 Table (New)", _ItemWkshLine."Create Copy of Variety 2 Table");
        _ItemWkshLine."Variety 3 Table (New)" := FindNewVarietyNames(_ItemWkshLine, 3, _ItemWkshLine."Variety 3", _ItemWkshLine."Variety 3 Table (Base)", _ItemWkshLine."Variety 3 Table (New)", _ItemWkshLine."Create Copy of Variety 3 Table");
        _ItemWkshLine."Variety 4 Table (New)" := FindNewVarietyNames(_ItemWkshLine, 4, _ItemWkshLine."Variety 4", _ItemWkshLine."Variety 4 Table (Base)", _ItemWkshLine."Variety 4 Table (New)", _ItemWkshLine."Create Copy of Variety 4 Table");
        Item."NPR Variety 1" := _ItemWkshLine."Variety 1";
        Item."NPR Variety 1 Table" := _ItemWkshLine."Variety 1 Table (New)";
        Item."NPR Variety 2" := _ItemWkshLine."Variety 2";
        Item."NPR Variety 2 Table" := _ItemWkshLine."Variety 2 Table (New)";
        Item."NPR Variety 3" := _ItemWkshLine."Variety 3";
        Item."NPR Variety 3 Table" := _ItemWkshLine."Variety 3 Table (New)";
        Item."NPR Variety 4" := _ItemWkshLine."Variety 4";
        Item."NPR Variety 4 Table" := _ItemWkshLine."Variety 4 Table (New)";
        Item."NPR Cross Variety No." := _ItemWkshLine."Cross Variety No.";
        Item."NPR Variety Group" := _ItemWkshLine."Variety Group";
        if not MapStandardItemWorksheetLineField(Item, _ItemWkshLine, _ItemWkshLine.FieldNo("Sales Unit of Measure")) then
            Item.Validate("Sales Unit of Measure", _ItemWkshLine."Sales Unit of Measure");
        if not MapStandardItemWorksheetLineField(Item, _ItemWkshLine, _ItemWkshLine.FieldNo("Sales Unit of Measure")) then
            Item.Validate("Purch. Unit of Measure", _ItemWkshLine."Sales Unit of Measure");
        if not MapStandardItemWorksheetLineField(Item, _ItemWkshLine, _ItemWkshLine.FieldNo("Manufacturer Code")) then
            Item.Validate("Manufacturer Code", _ItemWkshLine."Manufacturer Code");
        if not MapStandardItemWorksheetLineField(Item, _ItemWkshLine, _ItemWkshLine.FieldNo("Item Category Code")) then
            Item.Validate("Item Category Code", _ItemWkshLine."Item Category Code");
        Item.Validate("Net Weight", _ItemWkshLine."Net Weight");
        Item.Validate("Gross Weight", _ItemWkshLine."Gross Weight");
        if not MapStandardItemWorksheetLineField(Item, _ItemWkshLine, _ItemWkshLine.FieldNo("Tariff No.")) then
            Item.Validate("Tariff No.", _ItemWkshLine."Tariff No.");
        ValidateFields(Item, _ItemWkshLine, true, false);
        Item.Modify(true);


        _ItemWkshLine.UpdateBarcode();
        ProcessLineSalesPrices(Item);
        ProcessLinePurchasePrices(Item);
        UpdateAndCopyVarieties(_ItemWkshLine, 1, _ItemWkshLine."Variety 1", _ItemWkshLine."Variety 1 Table (Base)", _ItemWkshLine."Variety 1 Table (New)", _ItemWkshLine."Create Copy of Variety 1 Table", true);
        UpdateAndCopyVarieties(_ItemWkshLine, 2, _ItemWkshLine."Variety 2", _ItemWkshLine."Variety 2 Table (Base)", _ItemWkshLine."Variety 2 Table (New)", _ItemWkshLine."Create Copy of Variety 2 Table", true);
        UpdateAndCopyVarieties(_ItemWkshLine, 3, _ItemWkshLine."Variety 3", _ItemWkshLine."Variety 3 Table (Base)", _ItemWkshLine."Variety 3 Table (New)", _ItemWkshLine."Create Copy of Variety 3 Table", true);
        UpdateAndCopyVarieties(_ItemWkshLine, 4, _ItemWkshLine."Variety 4", _ItemWkshLine."Variety 4 Table (Base)", _ItemWkshLine."Variety 4 Table (New)", _ItemWkshLine."Create Copy of Variety 4 Table", true);
        UpdateItemAttributes(_ItemWkshLine);
    end;

    local procedure UpdateItem(var Item: Record Item)
    var
        UnitCostLCY: Decimal;
    begin
        if (Item."Vendor Item No." <> _ItemWkshLine."Vend Item No.") and (_ItemWkshLine."Vend Item No." <> '') then
            Item.Validate("Vendor Item No.", _ItemWkshLine."Vend Item No.");
        if (Item."Vendor No." <> _ItemWkshLine."Vendor No.") and (_ItemWkshLine."Vendor No." <> '') then
            Item.Validate("Vendor No.", _ItemWkshLine."Vendor No.");
        if (Item.Description <> _ItemWkshLine.Description) and (_ItemWkshLine.Description <> '') then
            Item.Validate(Description, _ItemWkshLine.Description);
        if (Item."Tariff No." <> _ItemWkshLine."Tariff No.") and (_ItemWkshLine."Tariff No." <> '') then
            Item.Validate("Tariff No.", _ItemWkshLine."Tariff No.");
        if (Item."Net Weight" <> _ItemWkshLine."Net Weight") and (_ItemWkshLine."Net Weight" <> 0) then
            Item.Validate("Net Weight", _ItemWkshLine."Net Weight");
        if (Item."Gross Weight" <> _ItemWkshLine."Gross Weight") and (_ItemWkshLine."Gross Weight" <> 0) then
            Item.Validate("Gross Weight", _ItemWkshLine."Gross Weight");
        if Item."Costing Method" <> _ItemWkshLine."Costing Method" then
            Item.Validate("Costing Method", _ItemWkshLine."Costing Method");

        if (Item."Last Direct Cost" <> _ItemWkshLine."Direct Unit Cost") and (_ItemWkshLine."Direct Unit Cost" <> 0) then begin
            UnitCostLCY := CalculateAmountToLCY(_ItemWkshLine."Purchase Price Currency Code", _ItemWkshLine."Direct Unit Cost");
            Item.Validate("Last Direct Cost", UnitCostLCY);

            if Item."Unit Cost" = 0 then
                Item."Unit Cost" := UnitCostLCY;
        end;

        Item.Modify(true);
        ValidateFields(Item, _ItemWkshLine, true, false);

        _ItemWkshLine.UpdateBarcode();
        ProcessLineSalesPrices(Item);
        ProcessLinePurchasePrices(Item);
        UpdateAndCopyVarieties(_ItemWkshLine, 1, _ItemWkshLine."Variety 1", _ItemWkshLine."Variety 1 Table (Base)", _ItemWkshLine."Variety 1 Table (New)", _ItemWkshLine."Create Copy of Variety 1 Table", false);
        UpdateAndCopyVarieties(_ItemWkshLine, 2, _ItemWkshLine."Variety 2", _ItemWkshLine."Variety 2 Table (Base)", _ItemWkshLine."Variety 2 Table (New)", _ItemWkshLine."Create Copy of Variety 2 Table", false);
        UpdateAndCopyVarieties(_ItemWkshLine, 3, _ItemWkshLine."Variety 3", _ItemWkshLine."Variety 3 Table (Base)", _ItemWkshLine."Variety 3 Table (New)", _ItemWkshLine."Create Copy of Variety 3 Table", false);
        UpdateAndCopyVarieties(_ItemWkshLine, 4, _ItemWkshLine."Variety 4", _ItemWkshLine."Variety 4 Table (Base)", _ItemWkshLine."Variety 4 Table (New)", _ItemWkshLine."Create Copy of Variety 4 Table", false);
        UpdateItemAttributes(_ItemWkshLine);
    end;

    internal procedure UpdateAndCopyVarieties(var ItemworkshLine: Record "NPR Item Worksheet Line"; VarietyNo: Integer; Variety: Code[10]; VarietyTableFrom: Code[40]; VarietyTableTo: Code[40]; CreateCopy: Boolean; CopyValues: Boolean)
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
                    PrefixCode := CopyStr(CopyStr(VarietyTableFrom, 1, StrPos(VarietyTableFrom, '-') - 1), 1, MaxStrLen(PrefixCode))
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
            ItemWorksheetVarietyValue.SetRange("Worksheet Template Name", ItemworkshLine."Worksheet Template Name");
            ItemWorksheetVarietyValue.SetRange("Worksheet Name", ItemworkshLine."Worksheet Name");
            ItemWorksheetVarietyValue.SetRange("Worksheet Line No.", ItemworkshLine."Line No.");
            ItemWorksheetVarietyValue.SetRange(Type, Variety);
            if ItemWorksheetVarietyValue.FindSet() then
                repeat
                    IsUpdated := false;
                    ItemWorksheetVariantLineToCreate.SetRange("Worksheet Template Name", ItemworkshLine."Worksheet Template Name");
                    ItemWorksheetVariantLineToCreate.SetRange("Worksheet Name", ItemworkshLine."Worksheet Name");
                    ItemWorksheetVariantLineToCreate.SetRange("Worksheet Line No.", ItemworkshLine."Line No.");
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

    local procedure FindNewVarietyNames(NprItemWorksheetLine: Record "NPR Item Worksheet Line"; VarietyNo: Integer; Variety: Code[20]; VarietyTableFrom: Code[40]; VarietyTableTo: Code[40]; CreateCopy: Boolean): Code[40]
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
                if NprItemWorksheetLine."Variety Group" <> '' then begin
                    VarietyGroup.Get(NprItemWorksheetLine."Variety Group");
                end else begin
                    VarietyGroup.Init();
                end;
                SuffixCode := NprItemWorksheetLine."Item No.";
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
                    PrefixCode := CopyStr(CopyStr(VarietyTableFrom, 1, StrPos(VarietyTableFrom, '-') - 1), 1, MaxStrLen(PrefixCode))
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

    local procedure CreateVariant(var NprItemWkshVariantLine: Record "NPR Item Worksh. Variant Line"; var Item: Record Item)
    begin
        if VarietyCloneData.GetFromVariety(ItemVariant, NprItemWkshVariantLine."Item No.", NprItemWkshVariantLine."Variety 1 Value",
                                     NprItemWkshVariantLine."Variety 2 Value", NprItemWkshVariantLine."Variety 3 Value",
                                     NprItemWkshVariantLine."Variety 4 Value") then
            Error(VariantExistErr);

        NprItemWkshVariantLine.CalcFields("Variety 1 Table", "Variety 2 Table", "Variety 3 Table", "Variety 4 Table",
                                       "Variety 1", "Variety 2", "Variety 3", "Variety 4");
        ItemVariant.Init();
        ItemVariant."Item No." := NprItemWkshVariantLine."Item No.";
        if NprItemWkshVariantLine."Variant Code" = '' then begin
            ItemVariant.Code := VarietyCloneData.GetNextVariantCode(NprItemWkshVariantLine."Item No.",
                                                                    NprItemWkshVariantLine."Variety 1 Value", NprItemWkshVariantLine."Variety 2 Value",
                                                                    NprItemWkshVariantLine."Variety 3 Value", NprItemWkshVariantLine."Variety 4 Value");
            NprItemWkshVariantLine."Variant Code" := ItemVariant.Code;
        end else begin
            ItemVariant.Code := NprItemWkshVariantLine."Variant Code";
        end;
        ItemVariant."NPR Variety 1" := NprItemWkshVariantLine."Variety 1";
        ItemVariant."NPR Variety 1 Table" := NprItemWkshVariantLine."Variety 1 Table";
        ItemVariant."NPR Variety 1 Value" := NprItemWkshVariantLine."Variety 1 Value";
        ItemVariant."NPR Variety 2" := NprItemWkshVariantLine."Variety 2";
        ItemVariant."NPR Variety 2 Table" := NprItemWkshVariantLine."Variety 2 Table";
        ItemVariant."NPR Variety 2 Value" := NprItemWkshVariantLine."Variety 2 Value";
        ItemVariant."NPR Variety 3" := NprItemWkshVariantLine."Variety 3";
        ItemVariant."NPR Variety 3 Table" := NprItemWkshVariantLine."Variety 3 Table";
        ItemVariant."NPR Variety 3 Value" := NprItemWkshVariantLine."Variety 3 Value";
        ItemVariant."NPR Variety 4" := NprItemWkshVariantLine."Variety 4";
        ItemVariant."NPR Variety 4 Table" := NprItemWkshVariantLine."Variety 4 Table";
        ItemVariant."NPR Variety 4 Value" := NprItemWkshVariantLine."Variety 4 Value";
#IF (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
        ItemVariant."NPR Blocked" := NprItemWkshVariantLine.Blocked;
#ELSE
        ItemVariant.Blocked := NprItemWkshVariantLine.Blocked;
#ENDIF

        if NprItemWkshVariantLine.Description <> '' then
            ItemVariant.Description := NprItemWkshVariantLine.Description
        else
            VarietyCloneData.FillDescription(ItemVariant, Item);

        ItemVariant.Insert(true);
    end;

    internal procedure UpdateItemAttributes(ItemWorksheetLine: Record "NPR Item Worksheet Line")
    var
        AttributeID: Record "NPR Attribute ID";
        AttributeKey: Record "NPR Attribute Key";
        AttributeValueSet: Record "NPR Attribute Value Set";
        AttributeManagement: Codeunit "NPR Attribute Management";
        TxtAttributeNotSetUp: Label 'Attribute %1 is not set up on the Item table, so it cannot be used with item %2.';
    begin
        AttributeKey.SetCurrentKey("Table ID", "MDR Code PK");
        AttributeKey.SetFilter("Table ID", '=%1', DATABASE::"NPR Item Worksheet Line");
        AttributeKey.SetFilter("MDR Code PK", '=%1', ItemWorksheetLine."Worksheet Template Name");
        AttributeKey.SetFilter("MDR Code 2 PK", '=%1', ItemWorksheetLine."Worksheet Name");
        AttributeKey.SetFilter("MDR Line PK", '=%1', ItemWorksheetLine."Line No.");
        AttributeKey.SetFilter("MDR Line 2 PK", '=%1', 0);

        // Fill array
        if AttributeKey.FindFirst() then begin
            AttributeValueSet.Reset();
            AttributeValueSet.SetRange("Attribute Set ID", AttributeKey."Attribute Set ID");
            if AttributeValueSet.FindSet() then
                repeat
                    if not AttributeID.Get(DATABASE::Item, AttributeValueSet."Attribute Code") then
                        Error(TxtAttributeNotSetUp, AttributeValueSet."Attribute Code", _ItemWkshLine."Item No.");
                    AttributeManagement.SetMasterDataAttributeValue(DATABASE::Item, AttributeID."Shortcut Attribute ID", _ItemWkshLine."Item No.", AttributeValueSet."Text Value");
                until AttributeValueSet.Next() = 0;
        end;
    end;

    local procedure CreateRegisteredWorksheetLines()
    begin
        if ItemWorksheetTemplate."Register Lines" then begin
            CopyToRegisteredWorksheetLine();

            _ItemWkshVariantLine.Reset();
            _ItemWkshVariantLine.SetRange("Worksheet Template Name", _ItemWkshLine."Worksheet Template Name");
            _ItemWkshVariantLine.SetRange("Worksheet Name", _ItemWkshLine."Worksheet Name");
            _ItemWkshVariantLine.SetRange("Worksheet Line No.", _ItemWkshLine."Line No.");
            if _ItemWkshVariantLine.FindSet() then
                repeat
                    CopyToRegisteredWorksheetVariantLine(_ItemWkshLine."Line No.", _ItemWkshVariantLine);
                until _ItemWkshVariantLine.Next() = 0;

            CreateRegisteredWorksheetVarietyValues(_ItemWkshLine);
        end;
    end;

    internal procedure CreateRegisteredWorksheetVarietyValues(ItemWkshLine: Record "NPR Item Worksheet Line")
    var
        ItemWkshVarietyValue: Record "NPR Item Worksh. Variety Value";
    begin
        ItemWkshVarietyValue.Reset();
        ItemWkshVarietyValue.SetRange("Worksheet Template Name", ItemWkshLine."Worksheet Template Name");
        ItemWkshVarietyValue.SetRange("Worksheet Name", ItemWkshLine."Worksheet Name");
        ItemWkshVarietyValue.SetRange("Worksheet Line No.", ItemWkshLine."Line No.");
        if ItemWkshVarietyValue.FindSet() then
            repeat
                CopyToRegisteredWorksheetVarietyValueLine(ItemWkshVarietyValue);
            until ItemWkshVarietyValue.Next() = 0;
    end;

    local procedure CopyToRegisteredWorksheetLine()
    begin
        RegisteredWorksheetLine."Registered Worksheet No." := LastRegisteredWorksheetNo();
        RegisteredWorksheetLine."Line No." := _ItemWkshLine."Line No.";
        RegisteredWorksheetLine.Action := _ItemWkshLine.Action;
        RegisteredWorksheetLine."Existing Item No." := _ItemWkshLine."Existing Item No.";
        RegisteredWorksheetLine."Item No." := _ItemWkshLine."Item No.";
        RegisteredWorksheetLine."Vend Item No." := _ItemWkshLine."Vend Item No.";
        RegisteredWorksheetLine."Internal Bar Code" := _ItemWkshLine."Internal Bar Code";
        RegisteredWorksheetLine."Vendor No." := _ItemWkshLine."Vendor No.";
        RegisteredWorksheetLine.Description := _ItemWkshLine.Description;
        RegisteredWorksheetLine."Direct Unit Cost" := _ItemWkshLine."Direct Unit Cost";
        RegisteredWorksheetLine."Unit Price (LCY)" := _ItemWkshLine."Sales Price";
        RegisteredWorksheetLine."Use Variant" := _ItemWkshLine."Use Variant";
        RegisteredWorksheetLine."Base Unit of Measure" := _ItemWkshLine."Base Unit of Measure";
        RegisteredWorksheetLine."Inventory Posting Group" := _ItemWkshLine."Inventory Posting Group";
        RegisteredWorksheetLine."Costing Method" := _ItemWkshLine."Costing Method";
        RegisteredWorksheetLine."Vendors Bar Code" := _ItemWkshLine."Vendors Bar Code";
        RegisteredWorksheetLine."VAT Bus. Posting Group" := _ItemWkshLine."VAT Bus. Posting Group";
        RegisteredWorksheetLine."VAT Bus. Posting Gr. (Price)" := _ItemWkshLine."VAT Bus. Posting Gr. (Price)";
        RegisteredWorksheetLine."Gen. Prod. Posting Group" := _ItemWkshLine."Gen. Prod. Posting Group";
        RegisteredWorksheetLine."No. Series" := _ItemWkshLine."No. Series";
        RegisteredWorksheetLine."Tax Group Code" := _ItemWkshLine."Tax Group Code";
        RegisteredWorksheetLine."VAT Prod. Posting Group" := _ItemWkshLine."VAT Prod. Posting Group";
        RegisteredWorksheetLine."Global Dimension 1 Code" := _ItemWkshLine."Global Dimension 2 Code";
        RegisteredWorksheetLine.Status := _ItemWkshLine.Status;
        RegisteredWorksheetLine."Status Comment" := _ItemWkshLine."Status Comment";
        RegisteredWorksheetLine."Variety 1" := _ItemWkshLine."Variety 1";
        RegisteredWorksheetLine."Variety 1 Table (New)" := CopyStr(_ItemWkshLine."Variety 1 Table (New)", 1, MaxStrLen(RegisteredWorksheetLine."Variety 1 Table (New)"));
        RegisteredWorksheetLine."Variety 1 Table (Base)" := _ItemWkshLine."Variety 1 Table (Base)";
        RegisteredWorksheetLine."Variety 1 Lock Table" := _ItemWkshLine."Variety 1 Lock Table";
        RegisteredWorksheetLine."Create Copy of Variety 1 Table" := _ItemWkshLine."Create Copy of Variety 1 Table";
        RegisteredWorksheetLine."Variety 2" := _ItemWkshLine."Variety 2";
        RegisteredWorksheetLine."Variety 2 Table (New)" := CopyStr(_ItemWkshLine."Variety 2 Table (New)", 1, MaxStrLen(RegisteredWorksheetLine."Variety 2 Table (New)"));
        RegisteredWorksheetLine."Variety 2 Table (Base)" := _ItemWkshLine."Variety 2 Table (Base)";
        RegisteredWorksheetLine."Variety 2 Lock Table" := _ItemWkshLine."Variety 2 Lock Table";
        RegisteredWorksheetLine."Create Copy of Variety 2 Table" := _ItemWkshLine."Create Copy of Variety 2 Table";
        RegisteredWorksheetLine."Variety 3" := _ItemWkshLine."Variety 3";
        RegisteredWorksheetLine."Variety 3 Table (New)" := CopyStr(_ItemWkshLine."Variety 3 Table (New)", 1, MaxStrLen(RegisteredWorksheetLine."Variety 3 Table (New)"));
        RegisteredWorksheetLine."Variety 3 Table (Base)" := _ItemWkshLine."Variety 3 Table (Base)";
        RegisteredWorksheetLine."Variety 3 Lock Table" := _ItemWkshLine."Variety 3 Lock Table";
        RegisteredWorksheetLine."Create Copy of Variety 3 Table" := _ItemWkshLine."Create Copy of Variety 3 Table";
        RegisteredWorksheetLine."Variety 4" := _ItemWkshLine."Variety 4";
        RegisteredWorksheetLine."Variety 4 Table (New)" := CopyStr(_ItemWkshLine."Variety 4 Table (New)", 1, MaxStrLen(RegisteredWorksheetLine."Variety 4 Table (New)"));
        RegisteredWorksheetLine."Variety 4 Table (Base)" := _ItemWkshLine."Variety 4 Table (Base)";
        RegisteredWorksheetLine."Variety 4 Lock Table" := _ItemWkshLine."Variety 4 Lock Table";
        RegisteredWorksheetLine."Create Copy of Variety 4 Table" := _ItemWkshLine."Create Copy of Variety 4 Table";
        RegisteredWorksheetLine."Cross Variety No." := _ItemWkshLine."Cross Variety No.";
        RegisteredWorksheetLine."Variety Group" := _ItemWkshLine."Variety Group";
        RegisteredWorksheetLine."Sales Unit of Measure" := _ItemWkshLine."Sales Unit of Measure";
        RegisteredWorksheetLine."Purch. Unit of Measure" := _ItemWkshLine."Purch. Unit of Measure";
        RegisteredWorksheetLine."Manufacturer Code" := _ItemWkshLine."Manufacturer Code";
        RegisteredWorksheetLine."Item Category Code" := _ItemWkshLine."Item Category Code";
        RegisteredWorksheetLine."Product Group Code" := _ItemWkshLine."Product Group Code";
        RegisteredWorksheetLine."Variant Code" := _ItemWkshLine."Variant Code";
        RegisteredWorksheetLine."Sales Price Currency Code" := _ItemWkshLine."Sales Price Currency Code";
        RegisteredWorksheetLine."Purchase Price Currency Code" := _ItemWkshLine."Purchase Price Currency Code";
        RegisteredWorksheetLine."Sales Price Start Date" := _ItemWkshLine."Sales Price Start Date";
        RegisteredWorksheetLine."Purchase Price Start Date" := _ItemWkshLine."Purchase Price Start Date";
        RegisteredWorksheetLine."Tariff No." := _ItemWkshLine."Tariff No.";
        RegisteredWorksheetLine."No. 2" := _ItemWkshLine."No. 2";
        RegisteredWorksheetLine.Type := _ItemWkshLine.Type;
        RegisteredWorksheetLine."Shelf No." := _ItemWkshLine."Shelf No.";
        RegisteredWorksheetLine."Item Disc. Group" := _ItemWkshLine."Item Disc. Group";
        RegisteredWorksheetLine."Allow Invoice Disc." := _ItemWkshLine."Allow Invoice Disc.";
        RegisteredWorksheetLine."Statistics Group" := _ItemWkshLine."Statistics Group";
        RegisteredWorksheetLine."Commission Group" := _ItemWkshLine."Commission Group";
        RegisteredWorksheetLine."Price/Profit Calculation" := _ItemWkshLine."Price/Profit Calculation";
        RegisteredWorksheetLine."Profit %" := _ItemWkshLine."Profit %";
        RegisteredWorksheetLine."Lead Time Calculation" := _ItemWkshLine."Lead Time Calculation";
        RegisteredWorksheetLine."Reorder Point" := _ItemWkshLine."Reorder Point";
        RegisteredWorksheetLine."Maximum Inventory" := _ItemWkshLine."Maximum Inventory";
        RegisteredWorksheetLine."Reorder Quantity" := _ItemWkshLine."Reorder Quantity";
        RegisteredWorksheetLine."Unit List Price" := _ItemWkshLine."Unit List Price";
        RegisteredWorksheetLine."Duty Due %" := _ItemWkshLine."Duty Due %";
        RegisteredWorksheetLine."Duty Code" := _ItemWkshLine."Duty Code";
        RegisteredWorksheetLine."Units per Parcel" := _ItemWkshLine."Units per Parcel";
        RegisteredWorksheetLine."Unit Volume" := _ItemWkshLine."Unit Volume";
        RegisteredWorksheetLine.Durability := _ItemWkshLine.Durability;
        RegisteredWorksheetLine."Freight Type" := _ItemWkshLine."Freight Type";
        RegisteredWorksheetLine."Duty Unit Conversion" := _ItemWkshLine."Duty Unit Conversion";
        RegisteredWorksheetLine."Country/Region Purchased Code" := _ItemWkshLine."Country/Region Purchased Code";
        RegisteredWorksheetLine."Budget Quantity" := _ItemWkshLine."Budget Quantity";
        RegisteredWorksheetLine."Budgeted Amount" := _ItemWkshLine."Budgeted Amount";
        RegisteredWorksheetLine."Budget Profit" := _ItemWkshLine."Budget Profit";
        RegisteredWorksheetLine.Blocked := _ItemWkshLine.Blocked;
        RegisteredWorksheetLine."Price Includes VAT" := _ItemWkshLine."Price Includes VAT";
        RegisteredWorksheetLine."Country/Region of Origin Code" := _ItemWkshLine."Country/Region of Origin Code";
        RegisteredWorksheetLine."Automatic Ext. Texts" := _ItemWkshLine."Automatic Ext. Texts";
        RegisteredWorksheetLine.Reserve := _ItemWkshLine.Reserve;
        RegisteredWorksheetLine."Stockout Warning" := _ItemWkshLine."Stockout Warning";
        RegisteredWorksheetLine."Prevent Negative Inventory" := _ItemWkshLine."Prevent Negative Inventory";
        RegisteredWorksheetLine."Assembly Policy" := _ItemWkshLine."Assembly Policy";
        RegisteredWorksheetLine.GTIN := _ItemWkshLine.GTIN;
        RegisteredWorksheetLine."Lot Size" := _ItemWkshLine."Lot Size";
        RegisteredWorksheetLine."Serial Nos." := _ItemWkshLine."Serial Nos.";
        RegisteredWorksheetLine."Scrap %" := _ItemWkshLine."Scrap %";
        RegisteredWorksheetLine."Inventory Value Zero" := _ItemWkshLine."Inventory Value Zero";
        RegisteredWorksheetLine."Discrete Order Quantity" := _ItemWkshLine."Discrete Order Quantity";
        RegisteredWorksheetLine."Minimum Order Quantity" := _ItemWkshLine."Minimum Order Quantity";
        RegisteredWorksheetLine."Maximum Order Quantity" := _ItemWkshLine."Maximum Order Quantity";
        RegisteredWorksheetLine."Safety Stock Quantity" := _ItemWkshLine."Safety Stock Quantity";
        RegisteredWorksheetLine."Order Multiple" := _ItemWkshLine."Order Multiple";
        RegisteredWorksheetLine."Safety Lead Time" := _ItemWkshLine."Safety Lead Time";
        RegisteredWorksheetLine."Flushing Method" := _ItemWkshLine."Flushing Method";
        RegisteredWorksheetLine."Replenishment System" := _ItemWkshLine."Replenishment System";
        RegisteredWorksheetLine."Reordering Policy" := _ItemWkshLine."Reordering Policy";
        RegisteredWorksheetLine."Include Inventory" := _ItemWkshLine."Include Inventory";
        RegisteredWorksheetLine."Manufacturing Policy" := _ItemWkshLine."Manufacturing Policy";
        RegisteredWorksheetLine."Rescheduling Period" := _ItemWkshLine."Rescheduling Period";
        RegisteredWorksheetLine."Lot Accumulation Period" := _ItemWkshLine."Lot Accumulation Period";
        RegisteredWorksheetLine."Dampener Period" := _ItemWkshLine."Dampener Period";
        RegisteredWorksheetLine."Dampener Quantity" := _ItemWkshLine."Dampener Quantity";
        RegisteredWorksheetLine."Overflow Level" := _ItemWkshLine."Overflow Level";
        RegisteredWorksheetLine."Service Item Group" := _ItemWkshLine."Service Item Group";
        RegisteredWorksheetLine."Item Tracking Code" := _ItemWkshLine."Item Tracking Code";
        RegisteredWorksheetLine."Lot Nos." := _ItemWkshLine."Lot Nos.";
        RegisteredWorksheetLine."Expiration Calculation" := _ItemWkshLine."Expiration Calculation";
        RegisteredWorksheetLine."Special Equipment Code" := _ItemWkshLine."Special Equipment Code";
        RegisteredWorksheetLine."Put-away Template Code" := _ItemWkshLine."Put-away Template Code";
        RegisteredWorksheetLine."Put-away Unit of Measure Code" := _ItemWkshLine."Put-away Unit of Measure Code";
        RegisteredWorksheetLine."Phys Invt Counting Period Code" := _ItemWkshLine."Phys Invt Counting Period Code";
        RegisteredWorksheetLine."Use Cross-Docking" := _ItemWkshLine."Use Cross-Docking";
        RegisteredWorksheetLine."Custom Text 1" := _ItemWkshLine."Custom Text 1";
        RegisteredWorksheetLine."Custom Text 2" := _ItemWkshLine."Custom Text 2";
        RegisteredWorksheetLine."Custom Text 3" := _ItemWkshLine."Custom Text 3";
        RegisteredWorksheetLine."Custom Text 4" := _ItemWkshLine."Custom Text 4";
        RegisteredWorksheetLine."Custom Text 5" := _ItemWkshLine."Custom Text 5";
        RegisteredWorksheetLine."Custom Price 1" := _ItemWkshLine."Custom Price 1";
        RegisteredWorksheetLine."Custom Price 2" := _ItemWkshLine."Custom Price 2";
        RegisteredWorksheetLine."Custom Price 3" := _ItemWkshLine."Custom Price 3";
        RegisteredWorksheetLine."Custom Price 4" := _ItemWkshLine."Custom Price 4";
        RegisteredWorksheetLine."Custom Price 5" := _ItemWkshLine."Custom Price 5";
        RegisteredWorksheetLine."Group sale" := _ItemWkshLine."Group sale";
        RegisteredWorksheetLine."Label Barcode" := _ItemWkshLine."Label Barcode";
        RegisteredWorksheetLine."Explode BOM auto" := _ItemWkshLine."Explode BOM auto";
        RegisteredWorksheetLine."Guarantee voucher" := _ItemWkshLine."Guarantee voucher";
        RegisteredWorksheetLine."Cannot edit unit price" := _ItemWkshLine."Cannot edit unit price";
        RegisteredWorksheetLine."Second-hand number" := _ItemWkshLine."Second-hand number";
        RegisteredWorksheetLine.Condition := _ItemWkshLine.Condition;
        RegisteredWorksheetLine."Second-hand" := _ItemWkshLine."Second-hand";
        RegisteredWorksheetLine."Guarantee Index" := _ItemWkshLine."Guarantee Index";
        RegisteredWorksheetLine."Insurrance category" := _ItemWkshLine."Insurrance category";
        RegisteredWorksheetLine."Item Brand" := _ItemWkshLine."Item Brand";
        RegisteredWorksheetLine."Type Retail" := _ItemWkshLine."Type Retail";
        RegisteredWorksheetLine."No Print on Reciept" := _ItemWkshLine."No Print on Reciept";
        RegisteredWorksheetLine."Print Tags" := _ItemWkshLine."Print Tags";
        RegisteredWorksheetLine."Change quantity by Photoorder" := _ItemWkshLine."Change quantity by Photoorder";
        RegisteredWorksheetLine."Std. Sales Qty." := _ItemWkshLine."Std. Sales Qty.";
        RegisteredWorksheetLine."Blocked on Pos" := _ItemWkshLine."Blocked on Pos";
        RegisteredWorksheetLine."Ticket Type" := _ItemWkshLine."Ticket Type";
        RegisteredWorksheetLine."Magento Status" := _ItemWkshLine."Magento Status";
        RegisteredWorksheetLine.Backorder := _ItemWkshLine.Backorder;
        RegisteredWorksheetLine."Product New From" := _ItemWkshLine."Product New From";
        RegisteredWorksheetLine."Product New To" := _ItemWkshLine."Product New To";
        RegisteredWorksheetLine."Attribute Set ID" := _ItemWkshLine."Attribute Set ID";
        RegisteredWorksheetLine."Special Price" := _ItemWkshLine."Special Price";
        RegisteredWorksheetLine."Special Price From" := _ItemWkshLine."Special Price From";
        RegisteredWorksheetLine."Special Price To" := _ItemWkshLine."Special Price To";
        RegisteredWorksheetLine."Magento Brand" := _ItemWkshLine."Magento Brand";
        RegisteredWorksheetLine."Display Only" := _ItemWkshLine."Display Only";
        RegisteredWorksheetLine."Magento Item" := _ItemWkshLine."Magento Item";
        RegisteredWorksheetLine."Magento Name" := _ItemWkshLine."Magento Name";
        RegisteredWorksheetLine."Seo Link" := _ItemWkshLine."Seo Link";
        RegisteredWorksheetLine."Meta Title" := _ItemWkshLine."Meta Title";
        RegisteredWorksheetLine."Meta Description" := _ItemWkshLine."Meta Description";
        RegisteredWorksheetLine."Meta Keywords" := _ItemWkshLine."Meta Keywords";
        RegisteredWorksheetLine."Featured From" := _ItemWkshLine."Featured From";
        RegisteredWorksheetLine."Featured To" := _ItemWkshLine."Featured To";
        RegisteredWorksheetLine."Routing No." := _ItemWkshLine."Routing No.";
        RegisteredWorksheetLine."Production BOM No." := _ItemWkshLine."Production BOM No.";
        RegisteredWorksheetLine."Overhead Rate" := _ItemWkshLine."Overhead Rate";
        RegisteredWorksheetLine."Order Tracking Policy" := _ItemWkshLine."Order Tracking Policy";
        RegisteredWorksheetLine.Critical := _ItemWkshLine.Critical;
        RegisteredWorksheetLine."Common Item No." := _ItemWkshLine."Common Item No.";
        RegisteredWorksheetLine.Insert();
    end;

    internal procedure CopyToRegisteredWorksheetVariantLine(LineNo: Integer; ItemWkshVariantLine: Record "NPR Item Worksh. Variant Line")
    var
        RegisteredWorksheetVariantLine: Record "NPR Reg. Item Wsht Var. Line";
    begin
        RegisteredWorksheetVariantLine."Registered Worksheet No." := LastRegisteredWorksheetNo();
        RegisteredWorksheetVariantLine."Registered Worksheet Line No." := LineNo;
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

    internal procedure CopyToRegisteredWorksheetVarietyValueLine(ItemWkshVarietyValue: Record "NPR Item Worksh. Variety Value")
    begin
        RegisteredWorksheetVarietyValue."Registered Worksheet No." := LastRegisteredWorksheetNo();
        RegisteredWorksheetVarietyValue."Registered Worksheet Line No." := ItemWkshVarietyValue."Worksheet Line No.";
        RegisteredWorksheetVarietyValue.Type := ItemWkshVarietyValue.Type;
        RegisteredWorksheetVarietyValue.Table := ItemWkshVarietyValue.Table;
        RegisteredWorksheetVarietyValue.Value := ItemWkshVarietyValue.Value;
        RegisteredWorksheetVarietyValue."Sort Order" := ItemWkshVarietyValue."Sort Order";
        RegisteredWorksheetVarietyValue.Description := ItemWkshVarietyValue.Description;
        RegisteredWorksheetVarietyValue.Insert();
    end;

    internal procedure LastRegisteredWorksheetNo(): Integer
    var
        RegisteredItemWorksheet: Record "NPR Registered Item Works.";
    begin
        RegisteredItemWorksheet.FindLast();
        exit(RegisteredItemWorksheet."No.");
    end;


    local procedure ProcessLineSalesPrices(var Item: Record Item)
    begin
        if _ItemWkshLine."Sales Price" = 0 then
            exit;

        case ItemWorksheetTemplate."Sales Price Handl." of
            ItemWorksheetTemplate."Sales Price Handl."::Item:
                ProcessItemSalesPrices(Item);
            ItemWorksheetTemplate."Sales Price Handl."::"PriceList":
                ProcessPriceListSalesPrices(Item);
        end;
    end;

    local procedure ProcessLinePurchasePrices(var Item: Record Item)
    begin
        if _ItemWkshLine."Direct Unit Cost" = 0 then
            exit;

        case ItemWorksheetTemplate."Purchase Price Handl." of
            ItemWorksheetTemplate."Purchase Price Handl."::Item:
                ProcessItemPurchasePrices(Item);
            ItemWorksheetTemplate."Purchase Price Handl."::"PriceList":
                ProcessPriceListPurchasePrices(Item);
        end;
    end;

    local procedure ProcessItemSalesPrices(var Item: Record Item)
    var
        UnitPriceLCY: Decimal;
    begin

        if _ItemWkshLine."Sales Price" <> Item."Unit Price" then begin
            UnitPriceLCY := CalculateAmountToLCY(_ItemWkshLine."Sales Price Currency Code", _ItemWkshLine."Sales Price");
            Item.Validate("Unit Price", UnitPriceLCY);
            Item.Modify(true);
        end;
    end;

    local procedure ProcessItemPurchasePrices(var Item: Record Item)
    var
        UnitCostLCY: Decimal;
    begin
        if _ItemWkshLine."Direct Unit Cost" <> Item."Last Direct Cost" then begin
            UnitCostLCY := CalculateAmountToLCY(_ItemWkshLine."Purchase Price Currency Code", _ItemWkshLine."Direct Unit Cost");
            Item.Validate("Last Direct Cost", UnitCostLCY);
            Item.Modify(true);
        end;
    end;

    local procedure ProcessPriceListSalesPrices(var Item: Record Item)
    var
        PriceListHeader: Record "Price List Header";
#IF NOT BC17        
        PriceListLine: Record "Price List Line";
        PriceLineExists: Boolean;
#ENDIF
        SalesUnitOfMeasure: Code[10];
        SalesPriceStartDate: Date;
    begin
        ItemWorksheetTemplate.TestField("Sales Price Handl.", ItemWorksheetTemplate."Sales Price Handl."::PriceList);
        PriceListHeader.Get(ItemWorksheetTemplate."Sales Price List Code");
#IF NOT BC17
        PriceListHeader.TestField("Allow Updating Defaults", true);
#ENDIF
        InitializeSalesUnitOfMeasureAndStartDate(Item, SalesUnitOfMeasure, SalesPriceStartDate);
#IF NOT BC17
        PriceLineExists := FindSalesPriceLine(PriceListLine, PriceListHeader, Item."Sales Unit of Measure", SalesUnitOfMeasure, _ItemWkshLine."Item No.", '');

        if PriceLineExists then begin
            if PriceListLine."Unit Price" = _ItemWkshLine."Sales Price" then
                exit;

            PriceListLine.Validate("Ending Date", SalesPriceStartDate - 1);
            PriceListLine.Modify();
        end;

        CreateSalesPriceListLine(PriceListHeader, SalesUnitOfMeasure, SalesPriceStartDate, _ItemWkshLine."Item No.", '', _ItemWkshLine."Sales Price");
#ELSE
        CreateSalesPriceListLine(PriceListHeader, _ItemWkshLine."Item No.", '', _ItemWkshLine."Sales Price");
#ENDIF
    end;

#if BC17
    [EventSubscriber(ObjectType::Table, Database::"Price List Line", 'OnAfterInitHeaderDefaults', '', true, true)]
    local procedure UpdateLineStatus(var sender: Record "Price List Line"; PriceListHeader: Record "Price List Header")
    begin
        if sender.Status <> sender.Status::Draft then
            sender.Status := sender.Status::Draft;
    end;
#endif

    local procedure ProcessVariantLineSalesPrice(Item: Record Item)
    var
        PriceListHeader: Record "Price List Header";
#IF NOT BC17        
        PriceListLine: Record "Price List Line";
        PriceLineExists: Boolean;
#ENDIF        
        SalesUnitOfMeasure: Code[10];
        SalesPriceStartDate: Date;
    begin
        if ItemWorksheetTemplate."Sales Price Handl." = ItemWorksheetTemplate."Sales Price Handl."::Item then
            exit;

        if _ItemWkshVariantLine."Sales Price" = 0 then
            exit;

        ItemWorksheetTemplate.TestField("Sales Price Handl.", ItemWorksheetTemplate."Sales Price Handl."::PriceList);
        PriceListHeader.Get(ItemWorksheetTemplate."Sales Price List Code");
#IF NOT BC17
        PriceListHeader.TestField("Allow Updating Defaults", true);
#ENDIF
        InitializeSalesUnitOfMeasureAndStartDate(Item, SalesUnitOfMeasure, SalesPriceStartDate);
#IF NOT BC17
        PriceLineExists := FindSalesPriceLine(PriceListLine, PriceListHeader, Item."Sales Unit of Measure", SalesUnitOfMeasure, _ItemWkshVariantLine."Item No.", _ItemWkshVariantLine."Variant Code");

        if PriceLineExists then begin
            if PriceListLine."Unit Price" = _ItemWkshVariantLine."Sales Price" then
                exit;

            PriceListLine.Validate("Ending Date", SalesPriceStartDate - 1);
            PriceListLine.Modify();
        end;

        CreateSalesPriceListLine(PriceListHeader, SalesUnitOfMeasure, SalesPriceStartDate, _ItemWkshVariantLine."Item No.", _ItemWkshVariantLine."Variant Code", _ItemWkshVariantLine."Sales Price");
#ELSE
        CreateSalesPriceListLine(PriceListHeader, _ItemWkshVariantLine."Item No.", _ItemWkshVariantLine."Variant Code", _ItemWkshVariantLine."Sales Price");
#ENDIF
    end;

    procedure SetCalledFromTest(ParCalledFromTest: Boolean)
    begin
        CalledFromTest := ParCalledFromTest;
    end;

    procedure ProcessPriceListPurchasePrices(Item: Record Item)
    var
        PriceListHeader: Record "Price List Header";
#IF NOT BC17        
        PriceListLine: Record "Price List Line";
        PriceLineExists: Boolean;
#ENDIF        
        PurchaseUnitOfMeasure: Code[10];
        PurchasePriceStartDate: Date;
    begin
        ItemWorksheetTemplate.TestField("Purchase Price Handl.", ItemWorksheetTemplate."Purchase Price Handl."::PriceList);
        PriceListHeader.Get(ItemWorksheetTemplate."Purchase Price List Code");
#IF NOT BC17
        PriceListHeader.TestField("Allow Updating Defaults", true);
#ENDIF        
        InitializePurchUnitOfMeasureAndStartDate(Item, PurchaseUnitOfMeasure, PurchasePriceStartDate);
#IF NOT BC17
        PriceLineExists := FindPurchasePriceLine(PriceListLine, Item."Purch. Unit of Measure", PurchaseUnitOfMeasure, _ItemWkshLine."Item No.", '');

        if PriceLineExists then begin
            if PriceListLine."Direct Unit Cost" = _ItemWkshLine."Direct Unit Cost" then
                exit;

            PriceListLine.Validate("Ending Date", PurchasePriceStartDate - 1);
            PriceListLine.Modify();
        end;

        CreatePurchasePriceListLine(PriceListHeader, PurchaseUnitOfMeasure, PurchasePriceStartDate, _ItemWkshLine."Item No.", '', _ItemWkshLine."Direct Unit Cost");
#ELSE
        CreatePurchasePriceListLine(PriceListHeader, _ItemWkshLine."Item No.", '', _ItemWkshLine."Direct Unit Cost");
#ENDIF
    end;

    local procedure ProcessVariantLinePurchasePrice(Item: Record Item)
    var
        PriceListHeader: Record "Price List Header";
#IF NOT BC17        
        PriceListLine: Record "Price List Line";
        PriceLineExists: Boolean;
#ENDIF
        PurchaseUnitOfMeasure: Code[10];
        PurchasePriceStartDate: Date;
    begin
        if ItemWorksheetTemplate."Purchase Price Handl." = ItemWorksheetTemplate."Purchase Price Handl."::Item then
            exit;

        if _ItemWkshVariantLine."Direct Unit Cost" = 0 then
            exit;

        ItemWorksheetTemplate.TestField("Purchase Price Handl.", ItemWorksheetTemplate."Purchase Price Handl."::PriceList);
        PriceListHeader.Get(ItemWorksheetTemplate."Purchase Price List Code");
#IF NOT BC17
        PriceListHeader.TestField("Allow Updating Defaults", true);
#ENDIF
        InitializePurchUnitOfMeasureAndStartDate(Item, PurchaseUnitOfMeasure, PurchasePriceStartDate);
#IF NOT BC17
        PriceLineExists := FindPurchasePriceLine(PriceListLine, Item."Purch. Unit of Measure", PurchaseUnitOfMeasure, _ItemWkshVariantLine."Item No.", _ItemWkshVariantLine."Variant Code");

        if PriceLineExists then begin
            if PriceListLine."Direct Unit Cost" = _ItemWkshVariantLine."Direct Unit Cost" then
                exit;

            PriceListLine.Validate("Ending Date", PurchasePriceStartDate - 1);
            PriceListLine.Modify();
        end;

        CreatePurchasePriceListLine(PriceListHeader, PurchaseUnitOfMeasure, PurchasePriceStartDate, _ItemWkshVariantLine."Item No.", _ItemWkshVariantLine."Variant Code", _ItemWkshVariantLine."Direct Unit Cost");
#ELSE
        CreatePurchasePriceListLine(PriceListHeader, _ItemWkshVariantLine."Item No.", _ItemWkshVariantLine."Variant Code", _ItemWkshVariantLine."Direct Unit Cost");
#ENDIF
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

    internal procedure ValidateFields(var VarItem: Record Item; var VarItemWkshLine: Record "NPR Item Worksheet Line"; DoValidateFields: Boolean; DoInsertChangeRecords: Boolean)
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
                                        if ValuesAreDifferent(ItemFldRef, ItemWorksheetFldRef) then begin
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

    local procedure ValuesAreDifferent(ItemFldRef: FieldRef; ItemWorksheetFldRef: FieldRef) DifferenceExists: Boolean;
    var
        ItemFieldItegerValue: Integer;
        ItemWorksheetIntegerValue: Integer;
        ComapreStringValue: Boolean;
    begin
        ComapreStringValue := (UpperCase(Format(ItemFldRef.Type)) <> 'ENUM') and (UpperCase(Format(ItemFldRef.Type)) <> 'OPTION');
        if not ComapreStringValue then
            ComapreStringValue := not (TryParseOptionToInteger(ItemFieldItegerValue, ItemFldRef) and TryParseOptionToInteger(ItemWorksheetIntegerValue, ItemWorksheetFldRef));

        if not ComapreStringValue then
            DifferenceExists := ItemWorksheetIntegerValue <> ItemFieldItegerValue
        else
            DifferenceExists := Format(ItemFldRef.Value) <> Format(ItemWorksheetFldRef.Value);
    end;

    internal procedure MapStandardItemWorksheetLineField(var VarItem: Record Item; ItemWorksheetLine: Record "NPR Item Worksheet Line"; SourceFieldNo: Integer): Boolean
    var
        ItemWorksheetFieldSetup: Record "NPR Item Worksh. Field Setup";
        ItemRecRef: RecordRef;
        ItemWorksheetRecRef: RecordRef;
        ItemFldRef: FieldRef;
        ItemWorksheetFldRef: FieldRef;
    begin
        ItemWorksheetFieldSetup.SetFilter("Worksheet Template Name", '%1|%2', ItemWorksheetLine."Worksheet Template Name", '');
        ItemWorksheetFieldSetup.SetFilter("Worksheet Name", '%1|%2', ItemWorksheetLine."Worksheet Name", '');
        ItemWorksheetFieldSetup.SetRange("Table No.", DATABASE::"NPR Item Worksheet Line");
        ItemWorksheetFieldSetup.SetRange("Field Number", SourceFieldNo);
        if not ItemWorksheetFieldSetup.FindLast() then
            exit(false);
        ItemRecRef.Get(VarItem.RecordId);
        ItemWorksheetRecRef.Get(ItemWorksheetLine.RecordId);
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

    [TryFunction]
    local procedure TryParseOptionToInteger(var TempInteger: Integer; FldRef: FieldRef)
    begin
        TempInteger := FldRef.Value;
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

#IF NOT BC17
    local procedure FindSalesPriceLine(var PriceListLine: Record "Price List Line"; PriceListHeader: Record "Price List Header"; ItemSalesUnitOfMeasure: Code[10]; SalesUnitOfMeasure: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]): Boolean
    begin
        PriceListLine.SetRange("Price List Code", ItemWorksheetTemplate."Sales Price List Code");
        PriceListLine.SetRange("Source Type", PriceListHeader."Source Type");
        PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);
        PriceListLine.SetRange("Asset No.", ItemNo);
        PriceListLine.SetRange("Variant Code", VariantCode);
        PriceListLine.SetRange("Currency Code", _ItemWkshLine."Sales Price Currency Code");
        PriceListLine.SetRange("Price Type", PriceListLine."Price Type"::Sale);
        PriceListLine.SetRange("Amount Type", PriceListLine."Amount Type"::Price);
        if SalesUnitOfMeasure = ItemSalesUnitOfMeasure then
            PriceListLine.SetFilter("Unit of Measure Code", '%1|%2', '', SalesUnitOfMeasure)
        else
            PriceListLine.SetRange("Unit of Measure Code", SalesUnitOfMeasure);
        PriceListLine.SetRange("Ending Date", 0D);

        exit(PriceListLine.FindFirst());
    end;

    local procedure FindPurchasePriceLine(var PriceListLine: Record "Price List Line"; ItemPurchUnitOfMeasure: Code[10]; PurchaseUnitOfMeasure: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]): Boolean
    begin
        PriceListLine.Reset();
        PriceListLine.SetRange("Price List Code", ItemWorksheetTemplate."Purchase Price List Code");
        PriceListLine.SetRange("Source No.", _ItemWkshLine."Vendor No.");
        PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);
        PriceListLine.SetRange("Asset No.", ItemNo);
        PriceListLine.SetRange("Variant Code", VariantCode);
        PriceListLine.SetRange("Currency Code", _ItemWkshLine."Purchase Price Currency Code");
        PriceListLine.SetRange("Price Type", PriceListLine."Price Type"::Purchase);
        PriceListLine.SetRange("Amount Type", PriceListLine."Amount Type"::Price);
        PriceListLine.SetRange("Ending Date", 0D);
        if PurchaseUnitOfMeasure = ItemPurchUnitOfMeasure then
            PriceListLine.SetFilter("Unit of Measure Code", '%1|%2', '', PurchaseUnitOfMeasure)
        else
            PriceListLine.SetRange("Unit of Measure Code", PurchaseUnitOfMeasure);

        exit(PriceListLine.FindFirst());
    end;
#ENDIF

#IF NOT BC17
    local procedure CreateSalesPriceListLine(var PriceListHeader: Record "Price List Header"; SalesUnitOfMeasure: Code[10]; SalesPriceStartDate: Date; ItemNo: Code[20]; VariantCode: Code[10]; SalesPrice: Decimal)
#ELSE
    local procedure CreateSalesPriceListLine(var PriceListHeader: Record "Price List Header"; ItemNo: Code[20]; VariantCode: Code[10]; SalesPrice: Decimal)
#ENDIF
    var
        PriceListLine: Record "Price List Line";
        xPriceListHeader: Record "Price List Header";
    begin
        xPriceListHeader := PriceListHeader;
        if PriceListHeader.Status <> PriceListHeader.Status::Draft then begin
            PriceListHeader.Status := PriceListHeader.Status::Draft;
            PriceListHeader.Modify();
        end;

        PriceListLine.Init();
        PriceListLine."Price List Code" := PriceListHeader.Code;

#IF NOT BC17
        PriceListLine.CopySourceFrom(PriceListHeader);
#ELSE
        PriceListLine.CopyFrom(PriceListHeader);
#ENDIF

        PriceListLine.Validate("Asset Type", PriceListLine."Asset Type"::Item);
        PriceListLine.Validate("Asset No.", ItemNo);
        PriceListLine.Validate("Amount Type", PriceListLine."Amount Type"::Price);
#IF NOT BC17
        PriceListLine.Validate("Price Type", PriceListLine."Price Type"::Sale);
        PriceListLine.Validate("Starting Date", SalesPriceStartDate);
        PriceListLine.Validate("Currency Code", _ItemWkshLine."Sales Price Currency Code");
        PriceListLine.Validate("Unit of Measure Code", SalesUnitOfMeasure);
#ENDIF

        if VariantCode <> '' then
            PriceListLine.Validate("Variant Code", VariantCode);

        PriceListLine.Status := xPriceListHeader.Status;
        PriceListLine."Unit Price" := SalesPrice;

        if PriceListLine."Unit Price" <> 0 then
            PriceListLine."Cost Factor" := 0;
        PriceListLine.Insert(true);

        if PriceListHeader.Status <> xPriceListHeader.Status then begin
            PriceListHeader.Status := xPriceListHeader.Status;
            PriceListHeader.Modify();
        end;
    end;

#IF NOT BC17
    local procedure CreatePurchasePriceListLine(var PriceListHeader: Record "Price List Header"; PurchaseUnitOfMeasure: Code[10]; PurchasePriceStartDate: Date; ItemNo: Code[20]; VariantCode: Code[10]; UnitCost: Decimal)
#ELSE    
    local procedure CreatePurchasePriceListLine(var PriceListHeader: Record "Price List Header"; ItemNo: Code[20]; VariantCode: Code[10]; UnitCost: Decimal)
#ENDIF    
    var
        PriceListLine: Record "Price List Line";
        xPriceListHeader: Record "Price List Header";
    begin
        xPriceListHeader := PriceListHeader;
        if PriceListHeader.Status <> PriceListHeader.Status::Draft then begin
            PriceListHeader.Status := PriceListHeader.Status::Draft;
            PriceListHeader.Modify();
        end;

        PriceListLine.Init();
        PriceListLine."Price List Code" := PriceListHeader.Code;

#IF NOT BC17
        PriceListLine.CopySourceFrom(PriceListHeader);
#ELSE
        PriceListLine.CopyFrom(PriceListHeader);
#ENDIF

        if _ItemWkshLine."Vendor No." <> '' then begin
            PriceListLine.Validate("Source Type", PriceListLine."Source Type"::Vendor);
            PriceListLine.Validate("Source No.", _ItemWkshLine."Vendor No.");
        end;

        PriceListLine.Validate("Asset Type", PriceListLine."Asset Type"::Item);
        PriceListLine.Validate("Asset No.", ItemNo);
        PriceListLine.Validate("Amount Type", PriceListLine."Amount Type"::Price);
#IF NOT BC17
        PriceListLine.Validate("Price Type", PriceListLine."Price Type"::Purchase);
        PriceListLine.Validate("Starting Date", PurchasePriceStartDate);
        PriceListLine.Validate("Currency Code", _ItemWkshLine."Purchase Price Currency Code");
        PriceListLine.Validate("Unit of Measure Code", PurchaseUnitOfMeasure);
#ENDIF

        if VariantCode <> '' then
            PriceListLine.Validate("Variant Code", VariantCode);

        PriceListLine.Status := xPriceListHeader.Status;
#IF NOT BC17
        PriceListLine."Direct Unit Cost" := UnitCost;

        if PriceListLine."Direct Unit Cost" <> 0 then
#ELSE
        PriceListLine."Unit Cost" := UnitCost;

        if PriceListLine."Unit Cost" <> 0 then
#ENDIF
            PriceListLine."Cost Factor" := 0;
        PriceListLine.Insert(true);

        if PriceListHeader.Status <> xPriceListHeader.Status then begin
            PriceListHeader.Status := xPriceListHeader.Status;
            PriceListHeader.Modify();
        end;
    end;

    local procedure InitializeSalesUnitOfMeasureAndStartDate(Item: Record Item; var SalesUnitOfMeasure: Code[10]; var SalesPriceStartDate: Date)
    var
        SalesDateInPastLbl: Label 'The Sales Price Start Date %1 cannot be older than today.';
    begin
        if _ItemWkshLine."Sales Unit of Measure" <> '' then
            SalesUnitOfMeasure := _ItemWkshLine."Sales Unit of Measure"
        else
            SalesUnitOfMeasure := Item."Sales Unit of Measure";

        SalesPriceStartDate := WorkDate() + 1;

        if _ItemWkshLine."Sales Price Start Date" = 0D then
            exit;

        if _ItemWkshLine."Sales Price Start Date" < WorkDate() then
            Error(SalesDateInPastLbl, _ItemWkshLine."Sales Price Start Date");

        SalesPriceStartDate := _ItemWkshLine."Sales Price Start Date";
    end;

    local procedure InitializePurchUnitOfMeasureAndStartDate(Item: Record Item; var PurchUnitOfMeasure: Code[10]; var PurchPriceStartDate: Date)
    var
        PurchaseDateInPastLbl: Label 'The Purchase Price Start Date %1 cannot be older than today.';
    begin
        if _ItemWkshLine."Purch. Unit of Measure" <> '' then
            PurchUnitOfMeasure := _ItemWkshLine."Purch. Unit of Measure"
        else
            PurchUnitOfMeasure := Item."Purch. Unit of Measure";

        PurchPriceStartDate := WorkDate() + 1;

        if _ItemWkshLine."Purchase Price Start Date" = 0D then
            exit;

        if _ItemWkshLine."Purchase Price Start Date" < WorkDate() then
            Error(PurchaseDateInPastLbl, _ItemWkshLine."Purchase Price Start Date");

        PurchPriceStartDate := _ItemWkshLine."Purchase Price Start Date";
    end;

    local procedure CalculateAmountToLCY(FromCurrencyCode: Code[10]; Amount: Decimal): Decimal
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        GeneralLedgerSetup: Record "General Ledger Setup";
        CurrencyFactor: Decimal;
        ExchRateDate: Date;
    begin
        if FromCurrencyCode = '' then
            exit(Amount);

        GeneralLedgerSetup.Get();
        if FromCurrencyCode = GeneralLedgerSetup."LCY Code" then
            exit(Amount);

        ExchRateDate := Today();
        CurrencyFactor := CurrencyExchangeRate.ExchangeRate(ExchRateDate, FromCurrencyCode);
        Amount := Round(CurrencyExchangeRate.ExchangeAmtFCYToLCY(ExchRateDate, FromCurrencyCode, Amount, CurrencyFactor));
        exit(Amount);
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
