page 6060067 "NPR Items by Loc.Overv. Matrix"
{
    // NPR5.52/JAKUBV/20191022  CASE 370333 Transport NPR5.52 - 22 October 2019

    Caption = 'Items by Loc. Overview Matrix';
    Editable = false;
    LinksAllowed = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Inv. Overview Line";

    layout
    {
        area(content)
        {
            repeater(Control6014401)
            {
                ShowCaption = false;
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Description field';
                }
                field("Variant Description"; Rec."Variant Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Description field';
                }
                field(Inventory; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Caption = 'Total Inventory';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Total Inventory field';

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(0);
                    end;
                }
                field(Field1; MATRIX_CellData[1])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[1];
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    Visible = Field1Visible;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[1] field';

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(1);
                    end;
                }
                field(Field2; MATRIX_CellData[2])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[2];
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    Visible = Field2Visible;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[2] field';

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(2);
                    end;
                }
                field(Field3; MATRIX_CellData[3])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[3];
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    Visible = Field3Visible;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[3] field';

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(3);
                    end;
                }
                field(Field4; MATRIX_CellData[4])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[4];
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    Visible = Field4Visible;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[4] field';

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(4);
                    end;
                }
                field(Field5; MATRIX_CellData[5])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[5];
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    Visible = Field5Visible;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[5] field';

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(5);
                    end;
                }
                field(Field6; MATRIX_CellData[6])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[6];
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    Visible = Field6Visible;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[6] field';

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(6);
                    end;
                }
                field(Field7; MATRIX_CellData[7])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[7];
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    Visible = Field7Visible;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[7] field';

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(7);
                    end;
                }
                field(Field8; MATRIX_CellData[8])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[8];
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    Visible = Field8Visible;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[8] field';

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(8);
                    end;
                }
                field(Field9; MATRIX_CellData[9])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[9];
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    Visible = Field9Visible;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[9] field';

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(9);
                    end;
                }
                field(Field10; MATRIX_CellData[10])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[10];
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    Visible = Field10Visible;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[10] field';

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(10);
                    end;
                }
                field(Field11; MATRIX_CellData[11])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[11];
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    Visible = Field11Visible;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[11] field';

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(11);
                    end;
                }
                field(Field12; MATRIX_CellData[12])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[12];
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    Visible = Field12Visible;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[12] field';

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(12);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        MATRIX_CurrentColumnOrdinal: Integer;
    begin
        MATRIX_CurrentColumnOrdinal := 0;
        if MatrixRecord.FindSet() then
            repeat
                MATRIX_CurrentColumnOrdinal := MATRIX_CurrentColumnOrdinal + 1;
                MATRIX_CellData[MATRIX_CurrentColumnOrdinal] := MatrixCalcCell(MATRIX_CurrentColumnOrdinal);
            until (MatrixRecord.Next(1) = 0) or (MATRIX_CurrentColumnOrdinal = MatrixMaxNoOfColumns());

        Rec.Quantity := MatrixCalcCell(0);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        exit(false);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        Found: Boolean;
    begin
        ApplyFilters();
        ItemVariantTmp."Item No." := Rec."Item No.";
        ItemVariantTmp.Code := Rec."Variant Code";
        Found := ItemVariantTmp.Find(Which);
        if Found then
            CopyItemVariantToBuf();
        exit(Found);
    end;

    trigger OnInit()
    begin
        SetVisible(true);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        exit(false);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        exit;
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        ResultSteps: Integer;
    begin
        ApplyFilters();
        ItemVariantTmp."Item No." := Rec."Item No.";
        ItemVariantTmp.Code := Rec."Variant Code";
        ResultSteps := ItemVariantTmp.Next(Steps);
        if ResultSteps <> 0 then
            CopyItemVariantToBuf();
        exit(ResultSteps);
    end;

    trigger OnOpenPage()
    begin
        GenerateItemVariantList();
    end;

    var
        ItemVariantTmp: Record "Item Variant" temporary;
        MatrixRecords: array[32] of Record Location;
        MatrixRecord: Record Location temporary;
        MATRIX_CellData: array[32] of Decimal;
        ShowItems: Option "On Inventory","Not on Inventory",All;
        MATRIX_CaptionSet: array[32] of Text[80];
        ItemFilter: Code[250];
        VariantFilter: Code[250];
        VarietyValueFilter: array[4] of Code[250];
        WOutVariantLbl: Label '<W/Out Variant Code>';
        Field1Visible: Boolean;
        Field2Visible: Boolean;
        Field3Visible: Boolean;
        Field4Visible: Boolean;
        Field5Visible: Boolean;
        Field6Visible: Boolean;
        Field7Visible: Boolean;
        Field8Visible: Boolean;
        Field9Visible: Boolean;
        Field10Visible: Boolean;
        Field11Visible: Boolean;
        Field12Visible: Boolean;
        EmtpyCodeValueTxt: Label '<NO CODE>', Comment = 'Maximum length = 10';

    procedure SetFilters(_ItemFilter: Code[250]; _VariantFilter: Code[250]; _VarietyValueFilter: array[4] of Code[250]; _ShowItems: Option "On Inventory","Not on Inventory",All)
    begin
        ItemFilter := _ItemFilter;
        VariantFilter := _VariantFilter;
        CopyArray(VarietyValueFilter, _VarietyValueFilter, 1);
        ShowItems := _ShowItems;
    end;

    procedure Load(_MatrixColumns: array[32] of Text[80]; var _MatrixRecords: array[32] of Record Location; var _MatrixRecord: Record Location)
    begin
        Clear(MATRIX_CellData);
        CopyArray(MATRIX_CaptionSet, _MatrixColumns, 1);
        CopyArray(MatrixRecords, _MatrixRecords, 1);
        MatrixRecord.Copy(_MatrixRecord, true);
        SetVisible(false);
    end;

    local procedure GenerateItemVariantList()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        ItemVariantTmp.DeleteAll();
        if Item.FindSet() then
            repeat
                ItemVariant.SetRange("Item No.", Item."No.");
                if ItemVariant.FindSet() then
                    repeat
                        ItemVariantTmp := ItemVariant;
                        ItemVariantTmp.Insert();
                    until ItemVariant.Next() = 0;
                ItemVariantTmp.Init();
                ItemVariantTmp."Item No." := Item."No.";
                ItemVariantTmp.Code := '';
                ItemVariantTmp.Description := WOutVariantLbl;
                ItemVariantTmp.Insert();
            until Item.Next() = 0;
    end;

    local procedure ApplyFilters()
    begin
        ItemVariantTmp.Reset();
        if ItemFilter <> '' then
            ItemVariantTmp.SetFilter("Item No.", ItemFilter);
        if VariantFilter <> '' then
            ItemVariantTmp.SetFilter(Code, VariantFilter);
        if VarietyValueFilter[1] <> '' then
            ItemVariantTmp.SetFilter("NPR Variety 1 Value", VarietyValueFilter[1]);
        if VarietyValueFilter[2] <> '' then
            ItemVariantTmp.SetFilter("NPR Variety 2 Value", VarietyValueFilter[2]);
        if VarietyValueFilter[3] <> '' then
            ItemVariantTmp.SetFilter("NPR Variety 3 Value", VarietyValueFilter[3]);
        if VarietyValueFilter[4] <> '' then
            ItemVariantTmp.SetFilter("NPR Variety 4 Value", VarietyValueFilter[4]);
    end;

    local procedure CopyItemVariantToBuf()
    var
        Item: Record Item;
    begin
        Item.Get(ItemVariantTmp."Item No.");
        Rec.Init();
        Rec."Item No." := ItemVariantTmp."Item No.";
        Rec."Variant Code" := ItemVariantTmp.Code;
        Rec."Item Description" := Item.Description;
        Rec."Variant Description" := ItemVariantTmp.Description;
    end;

    local procedure MatrixOnDrillDown(ColumnID: Integer)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetCurrentKey(
          "Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Location Code", "Posting Date");
        ItemLedgerEntry.SetRange("Item No.", Rec."Item No.");
        ItemLedgerEntry.SetRange("Variant Code", Rec."Variant Code");
        if ColumnID <> 0 then
            ItemLedgerEntry.SetRange("Location Code", AdjustMatrixRecordCode(MatrixRecords[ColumnID].Code));
        PAGE.Run(0, ItemLedgerEntry);
    end;

    local procedure MatrixCalcCell(ColumnID: Integer): Decimal
    var
        Item: Record Item;
    begin
        Item.Get(ItemVariantTmp."Item No.");
        Item.SetRange("Variant Filter", ItemVariantTmp.Code);
        if ColumnID <> 0 then
            Item.SetRange("Location Filter", AdjustMatrixRecordCode(MatrixRecords[ColumnID].Code));
        Item.CalcFields(Inventory);
        exit(Item.Inventory);
    end;

    procedure MatrixMaxNoOfColumns(): Integer
    begin
        exit(12);
    end;

    local procedure SetVisible(AllVisible: Boolean)
    begin
        Field1Visible := AllVisible or (MATRIX_CaptionSet[1] <> '');
        Field2Visible := AllVisible or (MATRIX_CaptionSet[2] <> '');
        Field3Visible := AllVisible or (MATRIX_CaptionSet[3] <> '');
        Field4Visible := AllVisible or (MATRIX_CaptionSet[4] <> '');
        Field5Visible := AllVisible or (MATRIX_CaptionSet[5] <> '');
        Field6Visible := AllVisible or (MATRIX_CaptionSet[6] <> '');
        Field7Visible := AllVisible or (MATRIX_CaptionSet[7] <> '');
        Field8Visible := AllVisible or (MATRIX_CaptionSet[8] <> '');
        Field9Visible := AllVisible or (MATRIX_CaptionSet[9] <> '');
        Field10Visible := AllVisible or (MATRIX_CaptionSet[10] <> '');
        Field11Visible := AllVisible or (MATRIX_CaptionSet[11] <> '');
        Field12Visible := AllVisible or (MATRIX_CaptionSet[12] <> '');
    end;

    procedure EmptyCodeValue(): Code[10]
    begin
        exit(UpperCase(EmtpyCodeValueTxt));
    end;

    local procedure AdjustMatrixRecordCode("Code": Code[10]): Code[10]
    begin
        if Code = EmptyCodeValue() then
            exit('')
        else
            exit(Code);
    end;
}

