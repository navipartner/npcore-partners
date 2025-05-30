﻿page 6014592 "NPR Item Repl. by Store Matrix"
{
    Extensible = False;
    Caption = 'Item Replen. by Stores Matrix';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Item Repl. by Store";
    SourceTableTemporary = true;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    layout
    {
        area(content)
        {
            group(Options)
            {
                Caption = 'Options';
                field(ShowField; ShowField)
                {

                    Caption = 'Show Field';
                    ToolTip = 'Specifies the value of the Show Field field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        "Fields": Page "Fields Lookup";
                    begin
                        FieldTable.SetRange("No.", ShowField);
                        FieldTable.SetRange(Type, FieldTable.Type::Decimal);
                        if FieldTable.FindFirst() then
                            Fields.SetRecord(FieldTable);
                        FieldTable.SetRange("No.");
                        Fields.SetTableView(FieldTable);
                        Fields.LookupMode(true);
                        Fields.Editable(false);
                        if Fields.RunModal() = ACTION::LookupOK then begin
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

                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the FieldCap field';
                    ApplicationArea = NPRRetail;
                }
            }
            repeater(Group)
            {
                field("Item No."; Rec."Item No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Description"; Rec."Item Description")
                {

                    ToolTip = 'Specifies the value of the Item Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Description"; Rec."Variant Description")
                {

                    ToolTip = 'Specifies the value of the Variant Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Field1; MatrixData[1])
                {

                    CaptionClass = '3,' + MatrixColumnCaptions[1];
                    Editable = Field1Editable;
                    Style = Strong;
                    StyleExpr = Emphasize1;
                    Visible = Field1Visible;
                    ToolTip = 'Specifies the value of the MatrixData[1] field';
                    ApplicationArea = NPRRetail;

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

                    CaptionClass = '3,' + MatrixColumnCaptions[2];
                    Editable = Field2Editable;
                    Style = Strong;
                    StyleExpr = Emphasize2;
                    Visible = Field2Visible;
                    ToolTip = 'Specifies the value of the MatrixData[2] field';
                    ApplicationArea = NPRRetail;

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

                    CaptionClass = '3,' + MatrixColumnCaptions[3];
                    Editable = Field3Editable;
                    Style = Strong;
                    StyleExpr = Emphasize3;
                    Visible = Field3Visible;
                    ToolTip = 'Specifies the value of the MatrixData[3] field';
                    ApplicationArea = NPRRetail;

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

                    CaptionClass = '3,' + MatrixColumnCaptions[4];
                    Editable = Field4Editable;
                    Style = Strong;
                    StyleExpr = Emphasize4;
                    Visible = Field4Visible;
                    ToolTip = 'Specifies the value of the MatrixData[4] field';
                    ApplicationArea = NPRRetail;

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

                    CaptionClass = '3,' + MatrixColumnCaptions[5];
                    Editable = Field5Editable;
                    Style = Strong;
                    StyleExpr = Emphasize5;
                    Visible = Field5Visible;
                    ToolTip = 'Specifies the value of the MatrixData[5] field';
                    ApplicationArea = NPRRetail;

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

                    CaptionClass = '3,' + MatrixColumnCaptions[6];
                    Editable = Field6Editable;
                    Style = Strong;
                    StyleExpr = Emphasize6;
                    Visible = Field6Visible;
                    ToolTip = 'Specifies the value of the MatrixData[6] field';
                    ApplicationArea = NPRRetail;

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

                    CaptionClass = '3,' + MatrixColumnCaptions[7];
                    Editable = Field7Editable;
                    Style = Strong;
                    StyleExpr = Emphasize7;
                    Visible = Field7Visible;
                    ToolTip = 'Specifies the value of the MatrixData[7] field';
                    ApplicationArea = NPRRetail;

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

                    CaptionClass = '3,' + MatrixColumnCaptions[8];
                    Editable = Field8Editable;
                    Style = Strong;
                    StyleExpr = Emphasize8;
                    Visible = Field8Visible;
                    ToolTip = 'Specifies the value of the MatrixData[8] field';
                    ApplicationArea = NPRRetail;

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

                    CaptionClass = '3,' + MatrixColumnCaptions[9];
                    Editable = Field9Editable;
                    Style = Strong;
                    StyleExpr = Emphasize9;
                    Visible = Field9Visible;
                    ToolTip = 'Specifies the value of the MatrixData[9] field';
                    ApplicationArea = NPRRetail;

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

                    CaptionClass = '3,' + MatrixColumnCaptions[10];
                    Editable = Field10Editable;
                    Style = Strong;
                    StyleExpr = Emphasize10;
                    Visible = Field10Visible;
                    ToolTip = 'Specifies the value of the MatrixData[10] field';
                    ApplicationArea = NPRRetail;

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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+Alt+V';
                Visible = false;

                ToolTip = 'Executes the Variety action';
                ApplicationArea = NPRRetail;
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
        ItemReplenByStore: Record "NPR Item Repl. by Store";
    begin
        RecRef.GetTable(ItemReplenByStore);
        FieldTable.SetRange(TableNo, RecRef.Number);
        FieldTable.SetRange(Type, FieldTable.Type::Decimal);
        if FieldTable.FindFirst() then begin
            ShowField := FieldTable."No.";
            ValidateShowField();
        end;

        MaxNoOfCol := ArrayLen(MatrixData);

        PrepareMatrix(true, 1);
        if Rec.FindFirst() then;
    end;

    var
        MatrixData: array[10] of Text;
        MatrixColumnCaptions: array[10] of Text[50];
        ShowField: Integer;
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

    local procedure ValidateShowField()
    begin
        FieldTable.SetRange("No.", ShowField);
        if not FieldTable.FindFirst() then
            Error(FieldDoesntExist, ShowField);
        FieldCap := FieldTable."Field Caption";
        CurrPage.Update(false);
    end;

    local procedure PrepareMatrix(PrepareColumnsHeader: Boolean; PrepareRows: Option " ","Fixed Columns","Dynamic Columns","Single Row Dyn. Col.")
    var
        Item: Record Item;
        StoreGroup: Record "NPR Store Group";
    begin
        if PrepareColumnsHeader then begin
            i := 0;
            if StoreGroup.FindSet() then
                repeat
                    i += 1;
                    MatrixColumnCaptions[i] := StoreGroup.Code;
                    SetColProperty(1, i);
                until (StoreGroup.Next() = 0) or (i = MaxNoOfCol);
            NoOfColUsed := i;
        end;

        case PrepareRows of
            PrepareRows::"Fixed Columns", PrepareRows::"Dynamic Columns":
                if Item.FindSet() then
                    repeat
                        FetchItemOrItemVariant(Item."No.", '', PrepareRows);
                        if PrepareRows = PrepareRows::"Fixed Columns" then
                            UpdateRowsFromSavedData(Item."No.");
                    until Item.Next() = 0;
            PrepareRows::"Single Row Dyn. Col.":
                FetchItemOrItemVariant(Rec."Item No.", Rec."Variant Code", PrepareRows);
        end;
    end;

    local procedure UpdateMatrixData()
    var
        ItemReplenByStore: Record "NPR Item Repl. by Store";
    begin
        if ShowField <> 0 then begin
            Clear(MatrixData);
            ItemReplenByStore.SetRange("Item No.", Rec."Item No.");
            ItemReplenByStore.SetRange("Variant Code", Rec."Variant Code");
            for i := 1 to NoOfColUsed do begin
                ItemReplenByStore.SetRange("Store Group Code", MatrixColumnCaptions[i]);
                if ItemReplenByStore.FindFirst() then begin
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
        Rec."Item No." := ItemNo;
        Rec."Variant Code" := VariantCode;
        case PrepareRows of
            PrepareRows::"Fixed Columns":
                Rec.Insert();
            PrepareRows::"Dynamic Columns", PrepareRows::"Single Row Dyn. Col.":
                UpdateMatrixData();
        end;
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
                            Field1Editable := Rec."Variant Code" = '';
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
                            Field2Editable := Rec."Variant Code" = '';
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
                            Field3Editable := Rec."Variant Code" = '';
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
                            Field4Editable := Rec."Variant Code" = '';
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
                            Field5Editable := Rec."Variant Code" = '';
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
                            Field6Editable := Rec."Variant Code" = '';
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
                            Field7Editable := Rec."Variant Code" = '';
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
                            Field8Editable := Rec."Variant Code" = '';
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
                            Field9Editable := Rec."Variant Code" = '';
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
                            Field10Editable := Rec."Variant Code" = '';
                        PropertyType::Emphasize:
                            Emphasize10 := MatrixData[ColumnNo] <> '';
                    end;
                end;
        end;
    end;

    local procedure FieldValidate(ColumnNo: Integer)
    var
        ItemReplenByStore: Record "NPR Item Repl. by Store";
        DecValue: Decimal;
    begin
        if ItemReplenByStore.Get(MatrixColumnCaptions[ColumnNo], Rec."Item No.", Rec."Variant Code") then begin
            RecRef.GetTable(ItemReplenByStore);
            FldRef := RecRef.Field(ShowField + 1);
            if MatrixData[ColumnNo] <> Format(FldRef) then begin
                if MatrixData[ColumnNo] = '' then begin
                    FldRef.Value := MatrixData[ColumnNo];
                    FldRef := RecRef.Field(ShowField);
                    FldRef.Value := 0;
                    RecRef.Modify();
                    CheckAndDelete(ColumnNo);
                end else begin
                    if not Evaluate(DecValue, MatrixData[ColumnNo]) then
                        Error(ErrDecimal);
                    FldRef := RecRef.Field(ShowField);
                    FldRef.Validate(DecValue);
                    RecRef.Modify();
                end;
            end;
        end else begin
            ItemReplenByStore.Init();
            ItemReplenByStore."Store Group Code" := MatrixColumnCaptions[ColumnNo];
            ItemReplenByStore."Item No." := Rec."Item No.";
            ItemReplenByStore."Variant Code" := Rec."Variant Code";
            ItemReplenByStore.Insert();
            RecRef.GetTable(ItemReplenByStore);
            FldRef := RecRef.Field(ShowField);
            if not Evaluate(DecValue, MatrixData[ColumnNo]) then
                Error(ErrDecimal);
            FldRef.Validate(DecValue);
            RecRef.Modify();
        end;
        SetColProperty(3, ColumnNo);
    end;

    local procedure CallVarietyWrapper(ColumnNo: Integer)
    var
        VarietyWrapper: Codeunit "NPR Variety Wrapper";
        ItemReplenishByStore: Record "NPR Item Repl. by Store";
        Item: Record Item;
        VarietyExists: Boolean;
    begin
        //this block of code can be removed when TestItemIsVariety function in VarietyWrapper is finished
        //from here
        Item.Get(Rec."Item No.");
        VarietyExists := ((Item."NPR Variety 1" <> '') and (Item."NPR Variety 1 Table" <> '')) or
                         ((Item."NPR Variety 2" <> '') and (Item."NPR Variety 2 Table" <> '')) or
                         ((Item."NPR Variety 3" <> '') and (Item."NPR Variety 3 Table" <> '')) or
                         ((Item."NPR Variety 4" <> '') and (Item."NPR Variety 4 Table" <> ''));
        if not VarietyExists then
            exit;
        //to here

        if ItemReplenishByStore.Get(MatrixColumnCaptions[ColumnNo], Rec."Item No.", Rec."Variant Code") then
            VarietyWrapper.ItemReplenishmentShowVariety(ItemReplenishByStore, ShowField + 1)
        else begin
            ItemReplenishByStore.Init();
            ItemReplenishByStore."Store Group Code" := MatrixColumnCaptions[ColumnNo];
            ItemReplenishByStore."Item No." := Rec."Item No.";
            ItemReplenishByStore."Variant Code" := Rec."Variant Code";
            ItemReplenishByStore.Insert();
            VarietyWrapper.ItemReplenishmentShowVariety(ItemReplenishByStore, ShowField + 1);
        end;
        CheckAndDelete(ColumnNo);
        UpdateRowsFromSavedData(Rec."Item No.");
        CurrPage.Update(false);
    end;

    local procedure CheckAndDelete(ColumnNo: Integer)
    var
        ItemReplenByStore: Record "NPR Item Repl. by Store";
        MasterLineMap: Record "NPR Master Line Map";
        RR: RecordRef;
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        CanDelete: Boolean;
    begin
        ItemReplenByStore.Get(MatrixColumnCaptions[ColumnNo], Rec."Item No.", Rec."Variant Code");
        if (ItemReplenByStore."Reorder Point Text" = '') and (ItemReplenByStore."Reorder Quantity Text" = '') and (ItemReplenByStore."Maximum Inventory Text" = '') then begin
            if not MasterLineMap.Get(Database::"NPR Item Repl. by Store", ItemReplenByStore.SystemId) then
                Clear(MasterLineMap);

            // Can delete if it is not master or if is master without children
            CanDelete := not MasterLineMap."Is Master";
            if not CanDelete then begin
                RR.GetTable(ItemReplenByStore);
                MasterLineMapMgt.FilterRecRefOnMasterId(RR, RR, true);
                CanDelete := RR.Count() = 0;
            end;
        end;

        if CanDelete then begin
            ItemReplenByStore.Delete();

            CurrPage.Update(false);
        end;
    end;

    local procedure UpdateRowsFromSavedData(ItemNo: Code[20])
    var
        ItemReplenishByStore: Record "NPR Item Repl. by Store";
    begin
        ItemReplenishByStore.Reset();
        ItemReplenishByStore.SetRange("Item No.", ItemNo);
        ItemReplenishByStore.SetFilter("Variant Code", '<>%1', '');
        if ItemReplenishByStore.FindSet() then
            repeat
                if not Rec.Get('', ItemReplenishByStore."Item No.", ItemReplenishByStore."Variant Code") then begin
                    Rec.Init();
                    Rec."Item No." := ItemReplenishByStore."Item No.";
                    Rec."Variant Code" := ItemReplenishByStore."Variant Code";
                    Rec.Insert();
                end;
            until ItemReplenishByStore.Next() = 0;
    end;
}
