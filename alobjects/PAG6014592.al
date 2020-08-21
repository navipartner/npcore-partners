page 6014592 "Item Replen. by Stores Matrix"
{
    // NPR4.16/TJ/20151115 CASE 222281 Page Created
    // NPR4.18/TJ/20160121 CASE 222281 Visible removed on action without functionality
    // NPR5.41/TS  /20180105 CASE 300893 Removed BlankZero on Text Array
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action
    // NPR5.49/BHR /20190204 CASE 340712 replace the Lookup Page "Fields" From page 7702  to page 6014547

    Caption = 'Item Replen. by Stores Matrix';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Item Replenishment by Store";
    SourceTableTemporary = true;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(Options)
            {
                Caption = 'Options';
                field(ShowField; ShowField)
                {
                    ApplicationArea = All;
                    Caption = 'Show Field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        "Fields": Page "Fields Lookup";
                    begin
                        FieldTable.SetRange("No.", ShowField);
                        FieldTable.SetRange(Type, FieldTable.Type::Decimal);
                        if FieldTable.FindFirst then
                            Fields.SetRecord(FieldTable);
                        FieldTable.SetRange("No.");
                        Fields.SetTableView(FieldTable);
                        Fields.LookupMode(true);
                        Fields.Editable(false);
                        if Fields.RunModal = ACTION::LookupOK then begin
                            Fields.GetRecord(FieldTable);
                            if ShowField <> FieldTable."No." then begin
                                ShowField := FieldTable."No.";
                                ValidateShowField();
                            end;
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        ValidateShowField();
                    end;
                }
                field(FieldCap; FieldCap)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            repeater(Group)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Variant Description"; "Variant Description")
                {
                    ApplicationArea = All;
                }
                field(Field1; MatrixData[1])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MatrixColumnCaptions[1];
                    Editable = Field1Editable;
                    Style = Strong;
                    StyleExpr = Emphasize1;
                    Visible = Field1Visible;

                    trigger OnAssistEdit()
                    begin
                        CallVarietyWrapper(1);
                    end;

                    trigger OnValidate()
                    begin
                        FieldValidate(1);
                    end;
                }
                field(Field2; MatrixData[2])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MatrixColumnCaptions[2];
                    Editable = Field2Editable;
                    Style = Strong;
                    StyleExpr = Emphasize2;
                    Visible = Field2Visible;

                    trigger OnAssistEdit()
                    begin
                        CallVarietyWrapper(2);
                    end;

                    trigger OnValidate()
                    begin
                        FieldValidate(2);
                    end;
                }
                field(Field3; MatrixData[3])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MatrixColumnCaptions[3];
                    Editable = Field3Editable;
                    Style = Strong;
                    StyleExpr = Emphasize3;
                    Visible = Field3Visible;

                    trigger OnAssistEdit()
                    begin
                        CallVarietyWrapper(3);
                    end;

                    trigger OnValidate()
                    begin
                        FieldValidate(3);
                    end;
                }
                field(Field4; MatrixData[4])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MatrixColumnCaptions[4];
                    Editable = Field4Editable;
                    Style = Strong;
                    StyleExpr = Emphasize4;
                    Visible = Field4Visible;

                    trigger OnAssistEdit()
                    begin
                        CallVarietyWrapper(4);
                    end;

                    trigger OnValidate()
                    begin
                        FieldValidate(4);
                    end;
                }
                field(Field5; MatrixData[5])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MatrixColumnCaptions[5];
                    Editable = Field5Editable;
                    Style = Strong;
                    StyleExpr = Emphasize5;
                    Visible = Field5Visible;

                    trigger OnAssistEdit()
                    begin
                        CallVarietyWrapper(5);
                    end;

                    trigger OnValidate()
                    begin
                        FieldValidate(5);
                    end;
                }
                field(Field6; MatrixData[6])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MatrixColumnCaptions[6];
                    Editable = Field6Editable;
                    Style = Strong;
                    StyleExpr = Emphasize6;
                    Visible = Field6Visible;

                    trigger OnAssistEdit()
                    begin
                        CallVarietyWrapper(6);
                    end;

                    trigger OnValidate()
                    begin
                        FieldValidate(6);
                    end;
                }
                field(Field7; MatrixData[7])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MatrixColumnCaptions[7];
                    Editable = Field7Editable;
                    Style = Strong;
                    StyleExpr = Emphasize7;
                    Visible = Field7Visible;

                    trigger OnAssistEdit()
                    begin
                        CallVarietyWrapper(7);
                    end;

                    trigger OnValidate()
                    begin
                        FieldValidate(7);
                    end;
                }
                field(Field8; MatrixData[8])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MatrixColumnCaptions[8];
                    Editable = Field8Editable;
                    Style = Strong;
                    StyleExpr = Emphasize8;
                    Visible = Field8Visible;

                    trigger OnAssistEdit()
                    begin
                        CallVarietyWrapper(8);
                    end;

                    trigger OnValidate()
                    begin
                        FieldValidate(8);
                    end;
                }
                field(Field9; MatrixData[9])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MatrixColumnCaptions[9];
                    Editable = Field9Editable;
                    Style = Strong;
                    StyleExpr = Emphasize9;
                    Visible = Field9Visible;

                    trigger OnAssistEdit()
                    begin
                        CallVarietyWrapper(9);
                    end;

                    trigger OnValidate()
                    begin
                        FieldValidate(9);
                    end;
                }
                field(Field10; MatrixData[10])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MatrixColumnCaptions[10];
                    Editable = Field10Editable;
                    Style = Strong;
                    StyleExpr = Emphasize10;
                    Visible = Field10Visible;

                    trigger OnAssistEdit()
                    begin
                        CallVarietyWrapper(10);
                    end;

                    trigger OnValidate()
                    begin
                        FieldValidate(10);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Variety)
            {
                Caption = 'Variety';
                Image = ItemVariant;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+Alt+V';
                Visible = false;

                trigger OnAction()
                begin
                    //CallVarietyWrapper();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        PrepareMatrix(false, 3);
        for i := 1 to NoOfColUsed do begin
            SetColProperty(2, i);
            SetColProperty(3, i);
        end;
    end;

    trigger OnOpenPage()
    var
        ItemReplenByStore: Record "Item Replenishment by Store";
    begin
        RecRef.GetTable(ItemReplenByStore);
        FieldTable.SetRange(TableNo, RecRef.Number);
        FieldTable.SetRange(Type, FieldTable.Type::Decimal);
        if FieldTable.FindFirst then begin
            ShowField := FieldTable."No.";
            ValidateShowField();
        end;

        MaxNoOfCol := ArrayLen(MatrixData);

        PrepareMatrix(true, 1);
        if FindFirst then;
    end;

    var
        MatrixData: array[10] of Text;
        MatrixColumnCaptions: array[10] of Text[50];
        ShowField: Integer;
        [InDataSet]
        Field1Visible: Boolean;
        [InDataSet]
        Field2Visible: Boolean;
        [InDataSet]
        Field3Visible: Boolean;
        [InDataSet]
        Field4Visible: Boolean;
        [InDataSet]
        Field5Visible: Boolean;
        [InDataSet]
        Field6Visible: Boolean;
        [InDataSet]
        Field7Visible: Boolean;
        [InDataSet]
        Field8Visible: Boolean;
        [InDataSet]
        Field9Visible: Boolean;
        [InDataSet]
        Field10Visible: Boolean;
        Field1Editable: Boolean;
        Field2Editable: Boolean;
        Field3Editable: Boolean;
        Field4Editable: Boolean;
        Field5Editable: Boolean;
        Field6Editable: Boolean;
        Field7Editable: Boolean;
        Field8Editable: Boolean;
        Field9Editable: Boolean;
        Field10Editable: Boolean;
        Emphasize1: Boolean;
        Emphasize2: Boolean;
        Emphasize3: Boolean;
        Emphasize4: Boolean;
        Emphasize5: Boolean;
        Emphasize6: Boolean;
        Emphasize7: Boolean;
        Emphasize8: Boolean;
        Emphasize9: Boolean;
        Emphasize10: Boolean;
        FieldTable: Record "Field";
        FieldDoesntExist: Label 'Field with ID %1 doesn''t exist.';
        RecRef: RecordRef;
        MaxNoOfCol: Integer;
        NoOfColUsed: Integer;
        i: Integer;
        FldRef: FieldRef;
        FieldCap: Text;
        ErrDecimal: Label 'You can only set decimal values.';
        VarietyErr: Label 'You need to be positioned on one of the data columns.';

    local procedure ValidateShowField()
    begin
        FieldTable.SetRange("No.", ShowField);
        if not FieldTable.FindFirst then
            Error(FieldDoesntExist, ShowField);
        FieldCap := FieldTable."Field Caption";
        CurrPage.Update(false);
    end;

    local procedure PrepareMatrix(PrepareColumnsHeader: Boolean; PrepareRows: Option " ","Fixed Columns","Dynamic Columns","Single Row Dyn. Col.")
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        StoreGroup: Record "Store Group";
    begin
        if PrepareColumnsHeader then begin
            i := 0;
            if StoreGroup.FindSet then
                repeat
                    i += 1;
                    MatrixColumnCaptions[i] := StoreGroup.Code;
                    SetColProperty(1, i);
                until (StoreGroup.Next = 0) or (i = MaxNoOfCol);
            NoOfColUsed := i;
        end;

        case PrepareRows of
            PrepareRows::"Fixed Columns", PrepareRows::"Dynamic Columns":
                if Item.FindSet then
                    repeat
                        FetchItemOrItemVariant(Item."No.", '', PrepareRows);
                        if PrepareRows = PrepareRows::"Fixed Columns" then
                            UpdateRowsFromSavedData(Item."No.");
                    until Item.Next = 0;
            PrepareRows::"Single Row Dyn. Col.":
                FetchItemOrItemVariant("Item No.", "Variant Code", PrepareRows);
        end;
    end;

    local procedure UpdateMatrixData()
    var
        ItemReplenByStore: Record "Item Replenishment by Store";
    begin
        if ShowField <> 0 then begin
            Clear(MatrixData);
            ItemReplenByStore.SetRange("Item No.", "Item No.");
            ItemReplenByStore.SetRange("Variant Code", "Variant Code");
            for i := 1 to NoOfColUsed do begin
                ItemReplenByStore.SetRange("Store Group Code", MatrixColumnCaptions[i]);
                if ItemReplenByStore.FindFirst then begin
                    RecRef.GetTable(ItemReplenByStore);
                    FldRef := RecRef.Field(ShowField + 1);
                    MatrixData[i] := FldRef.Value;
                end else
                    MatrixData[i] := '';
            end;
        end;
    end;

    local procedure FetchItemOrItemVariant(ItemNo: Code[20]; VariantCode: Code[10]; PrepareRows: Option " ","Fixed Columns","Dynamic Columns","Single Row Dyn. Col.")
    begin
        "Item No." := ItemNo;
        "Variant Code" := VariantCode;
        case PrepareRows of
            PrepareRows::"Fixed Columns":
                Insert;
            PrepareRows::"Dynamic Columns", PrepareRows::"Single Row Dyn. Col.":
                UpdateMatrixData();
        end;
    end;

    local procedure AssistEditCol(ColumnNo: Integer)
    begin
    end;

    local procedure SetColProperty(PropertyType: Option " ",Visible,Editable,Emphasize; ColumnNo: Integer)
    begin
        case ColumnNo of
            1:
                begin
                    case PropertyType of
                        PropertyType::Visible:
                            Field1Visible := true;
                        PropertyType::Editable:
                            Field1Editable := "Variant Code" = '';
                        PropertyType::Emphasize:
                            Emphasize1 := MatrixData[ColumnNo] <> '';
                    end;
                end;
            2:
                begin
                    case PropertyType of
                        PropertyType::Visible:
                            Field2Visible := true;
                        PropertyType::Editable:
                            Field2Editable := "Variant Code" = '';
                        PropertyType::Emphasize:
                            Emphasize2 := MatrixData[ColumnNo] <> '';
                    end;
                end;
            3:
                begin
                    case PropertyType of
                        PropertyType::Visible:
                            Field3Visible := true;
                        PropertyType::Editable:
                            Field3Editable := "Variant Code" = '';
                        PropertyType::Emphasize:
                            Emphasize3 := MatrixData[ColumnNo] <> '';
                    end;
                end;
            4:
                begin
                    case PropertyType of
                        PropertyType::Visible:
                            Field4Visible := true;
                        PropertyType::Editable:
                            Field4Editable := "Variant Code" = '';
                        PropertyType::Emphasize:
                            Emphasize4 := MatrixData[ColumnNo] <> '';
                    end;
                end;
            5:
                begin
                    case PropertyType of
                        PropertyType::Visible:
                            Field5Visible := true;
                        PropertyType::Editable:
                            Field5Editable := "Variant Code" = '';
                        PropertyType::Emphasize:
                            Emphasize5 := MatrixData[ColumnNo] <> '';
                    end;
                end;
            6:
                begin
                    case PropertyType of
                        PropertyType::Visible:
                            Field6Visible := true;
                        PropertyType::Editable:
                            Field6Editable := "Variant Code" = '';
                        PropertyType::Emphasize:
                            Emphasize6 := MatrixData[ColumnNo] <> '';
                    end;
                end;
            7:
                begin
                    case PropertyType of
                        PropertyType::Visible:
                            Field7Visible := true;
                        PropertyType::Editable:
                            Field7Editable := "Variant Code" = '';
                        PropertyType::Emphasize:
                            Emphasize7 := MatrixData[ColumnNo] <> '';
                    end;
                end;
            8:
                begin
                    case PropertyType of
                        PropertyType::Visible:
                            Field8Visible := true;
                        PropertyType::Editable:
                            Field8Editable := "Variant Code" = '';
                        PropertyType::Emphasize:
                            Emphasize8 := MatrixData[ColumnNo] <> '';
                    end;
                end;
            9:
                begin
                    case PropertyType of
                        PropertyType::Visible:
                            Field9Visible := true;
                        PropertyType::Editable:
                            Field9Editable := "Variant Code" = '';
                        PropertyType::Emphasize:
                            Emphasize9 := MatrixData[ColumnNo] <> '';
                    end;
                end;
            10:
                begin
                    case PropertyType of
                        PropertyType::Visible:
                            Field10Visible := true;
                        PropertyType::Editable:
                            Field10Editable := "Variant Code" = '';
                        PropertyType::Emphasize:
                            Emphasize10 := MatrixData[ColumnNo] <> '';
                    end;
                end;
        end;
    end;

    local procedure FieldValidate(ColumnNo: Integer)
    var
        ItemReplenByStore: Record "Item Replenishment by Store";
        DecValue: Decimal;
        DeleteRecord: Boolean;
    begin
        if ItemReplenByStore.Get(MatrixColumnCaptions[ColumnNo], "Item No.", "Variant Code") then begin
            RecRef.GetTable(ItemReplenByStore);
            FldRef := RecRef.Field(ShowField + 1);
            if MatrixData[ColumnNo] <> Format(FldRef) then begin
                if MatrixData[ColumnNo] = '' then begin
                    FldRef.Value := MatrixData[ColumnNo];
                    FldRef := RecRef.Field(ShowField);
                    FldRef.Value := 0;
                    RecRef.Modify;
                    CheckAndDelete(ColumnNo);
                end else begin
                    if not Evaluate(DecValue, MatrixData[ColumnNo]) then
                        Error(ErrDecimal);
                    FldRef := RecRef.Field(ShowField);
                    FldRef.Validate(DecValue);
                    RecRef.Modify;
                end;
            end;
        end else begin
            ItemReplenByStore.Init;
            ItemReplenByStore."Store Group Code" := MatrixColumnCaptions[ColumnNo];
            ItemReplenByStore."Item No." := "Item No.";
            ItemReplenByStore."Variant Code" := "Variant Code";
            ItemReplenByStore.Insert;
            RecRef.GetTable(ItemReplenByStore);
            FldRef := RecRef.Field(ShowField);
            if not Evaluate(DecValue, MatrixData[ColumnNo]) then
                Error(ErrDecimal);
            FldRef.Validate(DecValue);
            RecRef.Modify;
        end;
        SetColProperty(3, ColumnNo);
    end;

    local procedure CallVarietyWrapper(ColumnNo: Integer)
    var
        VarietyWrapper: Codeunit "Variety Wrapper";
        ItemReplenishByStore: Record "Item Replenishment by Store";
        Item: Record Item;
        VarietyValue: Record "Variety Value";
        VarietyExists: Boolean;
    begin
        //this block of code can be removed when TestItemIsVariety function in VarietyWrapper is finished
        //from here
        Item.Get("Item No.");
        VarietyExists := ((Item."Variety 1" <> '') and (Item."Variety 1 Table" <> '')) or
                         ((Item."Variety 2" <> '') and (Item."Variety 2 Table" <> '')) or
                         ((Item."Variety 3" <> '') and (Item."Variety 3 Table" <> '')) or
                         ((Item."Variety 4" <> '') and (Item."Variety 4 Table" <> ''));
        if not VarietyExists then
            exit;
        //to here

        if ItemReplenishByStore.Get(MatrixColumnCaptions[ColumnNo], "Item No.", "Variant Code") then
            VarietyWrapper.ItemReplenishmentShowVariety(ItemReplenishByStore, ShowField + 1)
        else begin
            ItemReplenishByStore.Init;
            ItemReplenishByStore."Store Group Code" := MatrixColumnCaptions[ColumnNo];
            ItemReplenishByStore."Item No." := "Item No.";
            ItemReplenishByStore."Variant Code" := "Variant Code";
            ItemReplenishByStore.Insert;
            VarietyWrapper.ItemReplenishmentShowVariety(ItemReplenishByStore, ShowField + 1);
        end;
        CheckAndDelete(ColumnNo);
        UpdateRowsFromSavedData("Item No.");
        CurrPage.Update(false);
    end;

    local procedure CheckAndDelete(ColumnNo: Integer)
    var
        ItemReplenByStore: Record "Item Replenishment by Store";
        ItemReplenByStore2: Record "Item Replenishment by Store";
        CanDelete: Boolean;
    begin
        ItemReplenByStore.Get(MatrixColumnCaptions[ColumnNo], "Item No.", "Variant Code");
        ItemReplenByStore2.SetRange("Master Record Reference", ItemReplenByStore."Master Record Reference");
        ItemReplenByStore2.SetRange("Is Master", false);
        if (ItemReplenByStore."Reorder Point Text" = '') and (ItemReplenByStore."Reorder Quantity Text" = '') and (ItemReplenByStore."Maximum Inventory Text" = '') then begin
            CanDelete := not ItemReplenByStore."Is Master";
            if not CanDelete then
                CanDelete := ItemReplenByStore2.Count = 0;
        end;
        if CanDelete then begin
            ItemReplenByStore.Delete;

            /* if deletion of temp record is needed then uncomment this block
              FOR i := 1 TO NoOfColUsed DO
                CanDelete := CanDelete AND (MatrixData[i] = '');
              IF CanDelete THEN
                DELETE;
            */

            CurrPage.Update(false);
        end;

    end;

    local procedure UpdateRowsFromSavedData(ItemNo: Code[20])
    var
        ItemReplenishByStore: Record "Item Replenishment by Store";
    begin
        ItemReplenishByStore.Reset;
        ItemReplenishByStore.SetRange("Item No.", ItemNo);
        ItemReplenishByStore.SetFilter("Variant Code", '<>%1', '');
        if ItemReplenishByStore.FindSet then
            repeat
                if not Get('', ItemReplenishByStore."Item No.", ItemReplenishByStore."Variant Code") then begin
                    Init;
                    "Item No." := ItemReplenishByStore."Item No.";
                    "Variant Code" := ItemReplenishByStore."Variant Code";
                    Insert;
                end;
            until ItemReplenishByStore.Next = 0;
    end;
}

