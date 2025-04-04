﻿codeunit 6059971 "NPR Variety Matrix Management"
{
    var
        TempVRTBuffer_: Record "NPR Variety Buffer" temporary;
        MRecref: RecordRef;
        _Item: Record Item;
        Text002: Label 'You can''t update %1 from this form';
        Text003: Label 'This Barcode cant be used, because its already used on item %1';
        NotUsedText: Label 'Not Used';
        FieldTypeNotSupported: Label 'FieldType Not Supported %1';

    internal procedure SetRecord(MasterRecRef: RecordRef; ItemNo: Code[20])
    begin
        MRecref := MasterRecRef;
    end;

    internal procedure LoadMatrixData(ItemNo: Code[20]; HideInactive: Boolean)
    begin
        TempVRTBuffer_.LoadCombinations(TempVRTBuffer_, ItemNo, MRecref.Number = Database::"Item Variant", MRecref.RecordId, HideInactive);
        if MRecref.Number <> Database::"Item Variant" then
            SetRecordDefault(MRecref);
    end;

    internal procedure GetValue(VRT1Value: Code[50]; VRT2Value: Code[50]; VRT3Value: Code[50]; VRT4Value: Code[50]; VRTFieldSetup: Record "NPR Variety Field Setup"; var ItemFilters: Record Item) TextValue: Text[1024]
    var
        RecRef: RecordRef;
        FRef: FieldRef;
        ItemVariant: Record "Item Variant";
        TextValue2: Text[1024];
    begin
        TempVRTBuffer_.Get(VRT1Value, VRT2Value, VRT3Value, VRT4Value);
        if TempVRTBuffer_."Variant Code" = '' then
            exit('-');

#IF (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
        if ItemVariant.Get(TempVRTBuffer_."Item No.", TempVRTBuffer_."Variant Code") and ItemVariant."NPR Blocked" and ((VRTFieldSetup."Table No." <> Database::"Item Variant") or (VRTFieldSetup."Field No." <> ItemVariant.FieldNo("NPR Blocked"))) then
#ELSE
        if ItemVariant.Get(TempVRTBuffer_."Item No.", TempVRTBuffer_."Variant Code") and ItemVariant.Blocked and ((VRTFieldSetup."Table No." <> Database::"Item Variant") or (VRTFieldSetup."Field No." <> ItemVariant.FieldNo(Blocked))) then
#ENDIF
            exit('-');

        case VRTFieldSetup.Type of
            VRTFieldSetup.Type::Field:
                begin
                    case true of
                        (Format(TempVRTBuffer_."Record ID (TMP)") <> ''):
                            begin
                                if RecRef.Get(TempVRTBuffer_."Record ID (TMP)") then begin
                                    FRef := RecRef.Field(VRTFieldSetup."Field No.");
                                    TextValue := Format(FRef.Value);
                                end;
                            end;
                        VRTFieldSetup."Table No." in [7002, 7012]:
                            begin
                                if (Format(TempVRTBuffer_."Master Record ID") <> '') then begin
                                    RecRef.Get(TempVRTBuffer_."Master Record ID");
                                    FRef := RecRef.Field(VRTFieldSetup."Field No.");
                                    TextValue := '(' + Format(FRef.Value) + ')';
                                end;
                            end;
                    end;
                end;
            VRTFieldSetup.Type::Internal:
                begin
                    TextValue := GetIntFunc(VRTFieldSetup, ItemFilters."Location Filter", ItemFilters."Global Dimension 1 Filter", ItemFilters."Global Dimension 2 Filter");
                end;
            VRTFieldSetup.Type::Subscriber:
                begin
                    GetVarietyMatrixFieldValue(TempVRTBuffer_, VRTFieldSetup, TextValue, VRTFieldSetup."Variety Matrix Subscriber 1", ItemFilters, 0);
                end;
        end;

        if ((VRTFieldSetup."Secondary Type" = VRTFieldSetup."Secondary Type"::Field) and (VRTFieldSetup."Secondary Field No." = 0)) or
           ((VRTFieldSetup."Secondary Type" = VRTFieldSetup."Secondary Type"::Internal) and (VRTFieldSetup."Secondary Field No." = 0)) or
           ((VRTFieldSetup."Secondary Type" = VRTFieldSetup."Secondary Type"::Subscriber) and (VRTFieldSetup."Variety Matrix Subscriber 2" = ''))
        then
            exit;

        case VRTFieldSetup."Secondary Type" of
            VRTFieldSetup."Secondary Type"::Field:
                begin
                    if VRTFieldSetup."Table No." = VRTFieldSetup."Secondary Table No." then begin
                        if Format(TempVRTBuffer_."Record ID (TMP)") <> '' then begin
                            FRef := RecRef.Field(VRTFieldSetup."Secondary Field No.");
                            TextValue += ' (' + Format(FRef.Value) + ')';
                        end;
                    end else begin
                    end;
                end;
            VRTFieldSetup."Secondary Type"::Internal:
                begin
                    TextValue += GetIntFunc2(VRTFieldSetup, ItemFilters."Location Filter", ItemFilters."Global Dimension 1 Filter", ItemFilters."Global Dimension 2 Filter");
                end;
            VRTFieldSetup."Secondary Type"::Subscriber:
                begin
                    GetVarietyMatrixFieldValue(TempVRTBuffer_, VRTFieldSetup, TextValue2, VRTFieldSetup."Variety Matrix Subscriber 2", ItemFilters, 1);
                    TextValue += ' (' + TextValue2 + ')';
                end;
        end;
    end;

    internal procedure SetValue(VRT1Value: Code[50]; VRT2Value: Code[50]; VRT3Value: Code[50]; VRT4Value: Code[50]; VRTFieldSetup: Record "NPR Variety Field Setup"; NewValue: Text[250])
    var
        RecRef: RecordRef;
        FRef: FieldRef;
        Date: Date;
        Int: Integer;
        Dec: Decimal;
        "Code": Code[50];
        Bool: Boolean;
        OldValue: Text;
        VRTCloneData: Codeunit "NPR Variety Clone Data";
        Handled: Boolean;
    begin
        TempVRTBuffer_.Get(VRT1Value, VRT2Value, VRT3Value, VRT4Value);
        GetItem(TempVRTBuffer_."Item No.");

        case VRTFieldSetup.Type of
            VRTFieldSetup.Type::Field:
                begin
                    if Format(TempVRTBuffer_."Record ID (TMP)") = '' then begin
                        //the line is not created. create a line for it, and insert it in the buffer
                        VRTCloneData.SetupNewLine(MRecref, _Item, TempVRTBuffer_, NewValue);
                        //if this is creation of a new variant, we need to exit
                        if (VRTFieldSetup."Table No." = 5401) and (VRTFieldSetup."Field No." = 1) then
                            exit;
                    end;

                    RecRef.Get(TempVRTBuffer_."Record ID (TMP)");
                    FRef := RecRef.Field(VRTFieldSetup."Field No.");
                    OldValue := Format(FRef.Value);
                    OnBeforeSetValue(RecRef, FRef, VRTFieldSetup, NewValue, OldValue, Handled);
                    if not Handled then
                        case UpperCase(Format(FRef.Type)) of
                            'DATE':
                                begin
                                    Evaluate(Date, NewValue);
                                    if VRTFieldSetup."Validate Field" then
                                        FRef.Validate(Date)
                                    else
                                        FRef.Value(Date);
                                end;
                            'INTEGER':
                                begin
                                    Evaluate(Int, NewValue);
                                    if VRTFieldSetup."Validate Field" then
                                        FRef.Validate(Int)
                                    else
                                        FRef.Value(Int);
                                end;
                            'DECIMAL':
                                begin

                                    Evaluate(Dec, NewValue);
                                    if VRTFieldSetup."Validate Field" then
                                        FRef.Validate(Dec)
                                    else
                                        FRef.Value(Dec);
                                end;
                            'TEXT':
                                begin
                                    if VRTFieldSetup."Validate Field" then
                                        FRef.Validate(NewValue)
                                    else
                                        FRef.Value(NewValue);
                                end;
                            'CODE':
                                begin
                                    Evaluate(Code, NewValue);
                                    if VRTFieldSetup."Validate Field" then
                                        FRef.Validate(Code)
                                    else
                                        FRef.Value(Code);
                                end;
                            'BOOLEAN':
                                begin
                                    Evaluate(Bool, NewValue);
                                    if VRTFieldSetup."Validate Field" then
                                        FRef.Validate(Bool)
                                    else
                                        FRef.Value(Bool);
                                end;
                            else
                                Error(FieldTypeNotSupported, Format(FRef.Type));
                        end;
                    RecRef.Modify();

                    DeleteLinesQuantityZero(RecRef, FRef, TempVRTBuffer_, OldValue, Dec);
                end;
            VRTFieldSetup.Type::Internal:
                begin
                    SetValueIntFunc(VRTFieldSetup, NewValue);
                end;
        end;
    end;

    internal procedure GetTotalValue(CurrentCellVarietyBuffer: Record "NPR Variety Buffer" temporary; ShowAsCrossVRT: Option Variety1,Variety2,Variety3,Variety4; VRTFieldSetup: Record "NPR Variety Field Setup"; var ItemFilters: Record Item) TextValue: Text[1024]
    var
        TempVarietyBufferInRange: Record "NPR Variety Buffer" temporary;
        TextValue2: Text[1024];
        TotalValue: Decimal;
    begin
        TempVRTBuffer_.SetRange("Variety 1 Value", CurrentCellVarietyBuffer."Variety 1 Value");
        TempVRTBuffer_.SetRange("Variety 2 Value", CurrentCellVarietyBuffer."Variety 2 Value");
        TempVRTBuffer_.SetRange("Variety 3 Value", CurrentCellVarietyBuffer."Variety 3 Value");
        TempVRTBuffer_.SetRange("Variety 4 Value", CurrentCellVarietyBuffer."Variety 4 Value");
        case ShowAsCrossVRT of
            ShowAsCrossVRT::Variety1:
                TempVRTBuffer_.SetRange("Variety 1 Value");
            ShowAsCrossVRT::Variety2:
                TempVRTBuffer_.SetRange("Variety 2 Value");
            ShowAsCrossVRT::Variety3:
                TempVRTBuffer_.SetRange("Variety 3 Value");
            ShowAsCrossVRT::Variety4:
                TempVRTBuffer_.SetRange("Variety 4 Value");
        end;
        case VRTFieldSetup.Type of
            VRTFieldSetup.Type::Field:
                begin
                    VRTFieldSetup.CalcFields("Field Type Name");
                    if VRTFieldSetup."Field Type Name" in ['Decimal', 'Integer'] then begin
                        if TempVRTBuffer_.FindSet() then
                            repeat
                                TotalValue += GetBufferFieldValue(TempVRTBuffer_, VRTFieldSetup."Field No.");
                            until TempVRTBuffer_.Next() = 0;
                        TextValue := Format(TotalValue);
                    end else
                        TextValue := '';
                end;
            VRTFieldSetup.Type::Internal:  //current no support for Totals
                ;
            VRTFieldSetup.Type::Subscriber:
                begin
                    if TempVRTBuffer_.FindSet() then
                        repeat
                            TempVarietyBufferInRange := TempVRTBuffer_;
                            TempVarietyBufferInRange.Insert(false);
                        until TempVRTBuffer_.Next() = 0;
                    GetVarietyMatrixTotalValue(CurrentCellVarietyBuffer, TempVarietyBufferInRange, VRTFieldSetup, VRTFieldSetup."Variety Matrix Subscriber 1", ItemFilters, 0, TextValue2);
                    TextValue := TextValue2;
                    TextValue2 := '';
                end;
        end;
        case VRTFieldSetup."Secondary Type" of
            VRTFieldSetup."Secondary Type"::Field:
                if VRTFieldSetup."Table No." = VRTFieldSetup."Secondary Table No." then begin
                    VRTFieldSetup.CalcFields("Secondary Field Type Name");
                    if VRTFieldSetup."Secondary Field Type Name" in ['Decimal', 'Integer'] then begin
                        TotalValue := 0;
                        if TempVRTBuffer_.FindSet() then
                            repeat
                                TotalValue += GetBufferFieldValue(TempVRTBuffer_, VRTFieldSetup."Field No.");
                            until TempVRTBuffer_.Next() = 0;
                        TextValue2 := Format(TotalValue);
                    end;
                end;

            VRTFieldSetup."Secondary Type"::Internal:  //current no support for Totals
                ;
            VRTFieldSetup."Secondary Type"::Subscriber:
                begin
                    TempVarietyBufferInRange.Reset();
                    TempVarietyBufferInRange.DeleteAll();
                    if TempVRTBuffer_.FindSet() then
                        repeat
                            TempVarietyBufferInRange := TempVRTBuffer_;
                            TempVarietyBufferInRange.Insert(false);
                        until TempVRTBuffer_.Next() = 0;
                    GetVarietyMatrixTotalValue(CurrentCellVarietyBuffer, TempVarietyBufferInRange, VRTFieldSetup, VRTFieldSetup."Variety Matrix Subscriber 2", ItemFilters, 1, TextValue2);
                end;
        end;
        if TextValue2 <> '' then
            TextValue += ' (' + TextValue2 + ')';
    end;

    local procedure GetBufferFieldValue(VarietyBuffer: Record "NPR Variety Buffer"; FieldNo: Integer): Decimal
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        FieldValue: Decimal;

    begin
        if Format(VarietyBuffer."Record ID (TMP)") <> '' then
            if RecRef.Get(VarietyBuffer."Record ID (TMP)") then begin
                FldRef := RecRef.Field(FieldNo);
                FieldValue := FldRef.Value;
            end;
        exit(FieldValue);
    end;

    internal procedure DeleteLinesQuantityZero(var RecRef: RecordRef; FRef: FieldRef; var TempVRTBuffer: Record "NPR Variety Buffer" temporary; OldVal: Text; Qty: Decimal)
    var
        RecID: RecordId;
    begin
        if (Qty <> 0) or (OldVal = '0') or (TempVRTBuffer."Record ID (TMP)" = TempVRTBuffer."Master Record ID") then
            exit;
        if CheckTablesandFieldNosQtyZero(RecRef, FRef) then begin
            RecRef.Delete(true);
            TempVRTBuffer."Record ID (TMP)" := RecID;
            TempVRTBuffer.Modify();
        end;
    end;

    internal procedure CheckTablesandFieldNosQtyZero(var RecRef: RecordRef; FRef: FieldRef): Boolean
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
        ItemJournalLine: Record "Item Journal Line";
    begin
        case RecRef.Number of
            Database::"Sales Line":
                exit(FRef.Number = SalesLine.FieldNo(Quantity));

            Database::"Purchase Line":
                exit(FRef.Number = PurchaseLine.FieldNo(Quantity));

            Database::"Transfer Line":
                exit(FRef.Number = TransferLine.FieldNo(Quantity));
            Database::"Item Journal Line":
                exit(FRef.Number = ItemJournalLine.FieldNo(Quantity));
            else
                exit(false);
        end;
    end;

    internal procedure SetRecordDefault(var RecRef: RecordRef)
    var
        ItemVariant: Record "Item Variant";
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        RecRef2: RecordRef;
        FRef: FieldRef;
        ItemNo: Code[20];
        ItemVariantCode: Code[10];
        ItemNoField: Integer;
        ItemVariantField: Integer;
        Int: Integer;
    begin
        //filter on the lines so they can be used later
        RecRef2.Open(RecRef.Number);
        MasterLineMapMgt.FilterRecRefOnMasterId(RecRef2, RecRef, false);

        //find the important fields
        for Int := 1 to RecRef.FieldCount do begin
            FRef := RecRef.FieldIndex(Int);
            case true of
                (FRef.Relation = 27) and (ItemNoField = 0):
                    ItemNoField := FRef.Number;
                (FRef.Relation = 5401) and (ItemVariantField = 0):
                    ItemVariantField := FRef.Number;
            end;
        end;

        if RecRef2.FindSet(false) then
            repeat
                ItemNo := RecRef2.Field(ItemNoField).Value;
                ItemVariantCode := RecRef2.Field(ItemVariantField).Value;
                if (ItemVariantCode <> '') then begin
                    ItemVariant.Get(ItemNo, ItemVariantCode);
                    TempVRTBuffer_.Get(ItemVariant."NPR Variety 1 Value", ItemVariant."NPR Variety 2 Value",
                                     ItemVariant."NPR Variety 3 Value", ItemVariant."NPR Variety 4 Value");
                    TempVRTBuffer_."Record ID (TMP)" := RecRef2.RecordId;
                    TempVRTBuffer_.Modify();
                end;
            until RecRef2.Next() = 0;
    end;

    internal procedure GetIntFunc(VRTFieldSetup: Record "NPR Variety Field Setup"; LocationFilter: Code[10]; GD1: Code[20]; GD2: Code[20]): Text[250]
    var
        ItemRef: Record "Item Reference";
    begin
        case VRTFieldSetup."Field No." of
            1: //Inventory
                begin
                    if _Item."No." <> TempVRTBuffer_."Item No." then
                        _Item.Get(TempVRTBuffer_."Item No.");

                    _Item.SetRange("Variant Filter", TempVRTBuffer_."Variant Code");
                    if VRTFieldSetup."Use Location Filter" then begin
                        if LocationFilter <> '' then
                            _Item.SetFilter("Location Filter", LocationFilter)
                        else
                            _Item.SetRange("Location Filter");
                    end;
                    _Item.CalcFields("Net Change");
                    exit(Format(_Item."Net Change"));
                end;
            2: //Variant Created
                begin
                    exit(Format(TempVRTBuffer_."Variant Code" <> ''));
                end;
            3: //Barcode (ItemRef)
                begin
                    ItemRef.SetRange("Item No.", TempVRTBuffer_."Item No.");
                    ItemRef.SetRange("Variant Code", TempVRTBuffer_."Variant Code");
                    if ItemRef.FindFirst() then
                        exit(ItemRef."Reference No.");
                end;
        end;
    end;

    internal procedure GetIntFunc2(VRTFieldSetup: Record "NPR Variety Field Setup"; LocationFilter: Code[10]; GD1: Code[20]; GD2: Code[20]): Text[250]
    begin
        VRTFieldSetup.Type := VRTFieldSetup."Secondary Type";
        VRTFieldSetup."Table No." := VRTFieldSetup."Secondary Table No.";
        VRTFieldSetup."Field No." := VRTFieldSetup."Secondary Field No.";
        VRTFieldSetup."Use Location Filter" := VRTFieldSetup."Use Location Filter (Sec)";
        VRTFieldSetup."Use Global Dim 1 Filter" := VRTFieldSetup."Use Global Dim 1 Filter (Sec)";
        VRTFieldSetup."Use Global Dim 2 Filter" := VRTFieldSetup."Use Global Dim 2 Filter (Sec)";

        exit(CopyStr(' (' + GetIntFunc(VRTFieldSetup, LocationFilter, GD1, GD2) + ')', 1, 250));
    end;

    internal procedure SetValueIntFunc(VRTFieldSetup: Record "NPR Variety Field Setup"; NewValue: Text[250])
    var
        VRTCloneData: Codeunit "NPR Variety Clone Data";
        ItemRef: Record "Item Reference";
        ItemVariant: Record "Item Variant";
    begin
        case VRTFieldSetup."Field No." of
            1: //Inventory
                begin
                    Error(Text002, VRTFieldSetup.Description);
                end;
            2: //Variant Create
                begin
                    if (TempVRTBuffer_."Variant Code" <> '') and (VRTFieldSetup."Table No." = 5401) then begin
                        //delete Variant
                        ItemVariant.Get(TempVRTBuffer_."Item No.", TempVRTBuffer_."Variant Code");
                        ItemVariant.Delete(true);
                        TempVRTBuffer_."Variant Code" := '';
                        TempVRTBuffer_.Modify();
                    end else begin
                        VRTCloneData.SetupVariant(_Item, TempVRTBuffer_, CopyStr(NewValue, 1, 50));
                        TempVRTBuffer_.Modify();
                    end;
                end;
            3: //Barcode (ItemRef)
                begin
                    ItemRef.SetCurrentKey("Reference No.");
                    ItemRef.SetRange("Reference No.", NewValue);
                    if ItemRef.FindFirst() then
                        Error(Text003, ItemRef."Item No.");

                    _Item.Get(TempVRTBuffer_."Item No.");
                    ItemRef.Init();
                    ItemRef."Item No." := TempVRTBuffer_."Item No.";
                    ItemRef."Variant Code" := TempVRTBuffer_."Variant Code";
                    ItemRef."Reference Type" := ItemRef."Reference Type"::"Bar Code";
                    ItemRef."Unit of Measure" := VRTCloneData.GetUnitOfMeasure(ItemRef."Item No.", 1);
                    ItemRef."Reference No." := CopyStr(NewValue, 1, MaxStrLen(ItemRef."Reference No."));
                    ItemRef.Description := _Item.Description;
                    ItemRef.Insert();
                end;
        end;
    end;

    internal procedure GetValueBool(VRT1Value: Code[50]; VRT2Value: Code[50]; VRT3Value: Code[50]; VRT4Value: Code[50]; VRTFieldSetup: Record "NPR Variety Field Setup"; LocationFilter: Code[10]; GD1: Code[10]; GD2: Code[10]): Boolean
    var
        RecRef: RecordRef;
        FRef: FieldRef;
    begin
        TempVRTBuffer_.Get(VRT1Value, VRT2Value, VRT3Value, VRT4Value);
        if TempVRTBuffer_."Variant Code" = '' then
            exit(false);

        case VRTFieldSetup.Type of
            VRTFieldSetup.Type::Field:
                begin
                    case true of
                        (Format(TempVRTBuffer_."Record ID (TMP)") <> ''):
                            begin
                                RecRef.Get(TempVRTBuffer_."Record ID (TMP)");
                                FRef := RecRef.Field(VRTFieldSetup."Field No.");
                                exit(FRef.Value);
                            end;
                    end;
                end;
            VRTFieldSetup.Type::Internal:
                begin
                    case VRTFieldSetup."Field No." of
                        2: //Creation of Item Variants
                            begin
                                exit(RecRef.Get(TempVRTBuffer_."Record ID (TMP)"));
                            end;
                    end;
                end;
        end;
        exit(false);
    end;

    internal procedure OnDrillDown(VrtBuffer: Record "NPR Variety Buffer"; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024]; var ItemFilters: Record Item)
    begin
        TempVRTBuffer_.Get(VrtBuffer."Variety 1 Value", VrtBuffer."Variety 2 Value", VrtBuffer."Variety 3 Value", VrtBuffer."Variety 4 Value");
        if VrtFieldSetup."OnDrillDown Subscriber" <> '' then
            OnDrillDownVarietyMatrix(TempVRTBuffer_, VrtFieldSetup, FieldValue, 0, ItemFilters)
        else
            OnDrillDownEvent(TempVRTBuffer_, VrtFieldSetup, FieldValue);
    end;

    internal procedure OnDrillDownTotal(CurrentCellVarietyBuffer: Record "NPR Variety Buffer"; ShowAsCrossVRT: Option Variety1,Variety2,Variety3,Variety4; VrtFieldSetup: Record "NPR Variety Field Setup"; var ItemFilters: Record Item)
    var
        TempVarietyBufferInRange: Record "NPR Variety Buffer" temporary;
    begin
        if VrtFieldSetup."OnDrillDown Subscriber" = '' then
            exit;
        TempVRTBuffer_.SetRange("Variety 1 Value", CurrentCellVarietyBuffer."Variety 1 Value");
        TempVRTBuffer_.SetRange("Variety 2 Value", CurrentCellVarietyBuffer."Variety 2 Value");
        TempVRTBuffer_.SetRange("Variety 3 Value", CurrentCellVarietyBuffer."Variety 3 Value");
        TempVRTBuffer_.SetRange("Variety 4 Value", CurrentCellVarietyBuffer."Variety 4 Value");
        case ShowAsCrossVRT of
            ShowAsCrossVRT::Variety1:
                TempVRTBuffer_.SetRange("Variety 1 Value");
            ShowAsCrossVRT::Variety2:
                TempVRTBuffer_.SetRange("Variety 2 Value");
            ShowAsCrossVRT::Variety3:
                TempVRTBuffer_.SetRange("Variety 3 Value");
            ShowAsCrossVRT::Variety4:
                TempVRTBuffer_.SetRange("Variety 4 Value");
        end;
        if TempVRTBuffer_.FindSet() then
            repeat
                TempVarietyBufferInRange := TempVRTBuffer_;
                TempVarietyBufferInRange.Insert(false);
            until TempVRTBuffer_.Next() = 0;
        OnDrillDownVarietyMatrixTotal(CurrentCellVarietyBuffer, TempVarietyBufferInRange, VrtFieldSetup, ItemFilters);
    end;


    [IntegrationEvent(false, false)]
    local procedure OnDrillDownEvent(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024])
    begin
    end;

    internal procedure GetTotal(RecRef: RecordRef; FieldNo: Integer): Decimal
    var
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        RecRef2: RecordRef;
        FRef: FieldRef;
        Total: Decimal;
        Dec: Decimal;
    begin
        FRef := RecRef.Field(FieldNo);
        if UpperCase(Format(FRef.Type)) <> 'DECIMAL' then
            exit;
        RecRef2.Open(RecRef.Number);

        MasterLineMapMgt.FilterRecRefOnMasterId(RecRef2, RecRef, false);

        if RecRef2.FindSet(false) then
            repeat
                FRef := RecRef2.Field(FieldNo);
                Evaluate(Dec, Format(FRef.Value));
                Total += Dec;
            until RecRef2.Next() = 0;

        exit(Total);
    end;

    internal procedure MATRIX_GenerateColumnCaptions(MATRIX_SetWanted: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn; Item: Record Item; ShowCrossVRTNo: Option VRT1,VRT2,VRT3,VRT4; var MATRIX_CodeSet: array[30] of Text; var MATRIX_CaptionSet: array[30] of Text; var MATRIX_CurrentNoOfColumns: Integer; var MATRIX_CaptionRange: Text; HideInactive: Boolean; ShowColumnNames: Boolean; var MATRIX_PrimKeyFirstCaptionInCu: Text)
    var
        TempVarietyValue: Record "NPR Variety Value" temporary;
        VarietyValue: Record "NPR Variety Value";
        MatrixMgt: Codeunit "Matrix Management";
        RecRef: RecordRef;
        Variety1UsedValues: Query "NPR Variety 1 Used Values";
        Variety2UsedValues: Query "NPR Variety 2 Used Values";
        Variety3UsedValues: Query "NPR Variety 3 Used Values";
        Variety4UsedValues: Query "NPR Variety 4 Used Values";
        CaptionFieldNo: Integer;
        VarietyNotUsed: Boolean;
    begin
        Clear(MATRIX_CodeSet);
        Clear(MATRIX_CaptionSet);
        MATRIX_CurrentNoOfColumns := ArrayLen(MATRIX_CaptionSet);

        if HideInactive then begin
            TempVarietyValue.DeleteAll();
            case ShowCrossVRTNo of
                ShowCrossVRTNo::VRT1:
                    begin
                        Variety1UsedValues.SetRange(Item_No_Filter, Item."No.");
                        Variety1UsedValues.SetRange(Variety_1, Item."NPR Variety 1");
                        Variety1UsedValues.SetRange(Variety_1_Table, Item."NPR Variety 1 Table");

                        Variety1UsedValues.SetRange(Blocked, false);
                        Variety1UsedValues.Open();
                        while Variety1UsedValues.Read() do begin
                            if VarietyValue.Get(Variety1UsedValues.Variety_1, Variety1UsedValues.Variety_1_Table, Variety1UsedValues.Variety_1_Value) then begin
                                TempVarietyValue.Init();
                                TempVarietyValue := VarietyValue;
                                if ShowColumnNames and (TempVarietyValue.Description = '') then
                                    TempVarietyValue.Description := CopyStr(TempVarietyValue.Value, 1, MaxStrLen(TempVarietyValue.Description));
                                TempVarietyValue.Insert();
                            end else
                                VarietyNotUsed := Variety1UsedValues.Variety_1 = '';
                        end;
                    end;
                ShowCrossVRTNo::VRT2:
                    begin
                        Variety2UsedValues.SetRange(Item_No_Filter, Item."No.");
                        Variety2UsedValues.SetRange(Variety_2, Item."NPR Variety 2");
                        Variety2UsedValues.SetRange(Variety_2_Table, Item."NPR Variety 2 Table");

                        Variety2UsedValues.SetRange(Blocked, false);
                        Variety2UsedValues.Open();
                        while Variety2UsedValues.Read() do begin
                            if VarietyValue.Get(Variety2UsedValues.Variety_2, Variety2UsedValues.Variety_2_Table, Variety2UsedValues.Variety_2_Value) then begin
                                TempVarietyValue.Init();
                                TempVarietyValue := VarietyValue;
                                if ShowColumnNames and (TempVarietyValue.Description = '') then
                                    TempVarietyValue.Description := CopyStr(TempVarietyValue.Value, 1, MaxStrLen(TempVarietyValue.Description));
                                TempVarietyValue.Insert();
                            end else
                                VarietyNotUsed := Variety2UsedValues.Variety_2 = '';

                        end;
                    end;
                ShowCrossVRTNo::VRT3:
                    begin
                        Variety3UsedValues.SetRange(Item_No_Filter, Item."No.");
                        Variety3UsedValues.SetRange(Variety_3, Item."NPR Variety 3");
                        Variety3UsedValues.SetRange(Variety_3_Table, Item."NPR Variety 3 Table");
                        Variety3UsedValues.SetRange(Blocked, false);
                        Variety3UsedValues.Open();
                        while Variety3UsedValues.Read() do begin
                            if VarietyValue.Get(Variety3UsedValues.Variety_3, Variety3UsedValues.Variety_3_Table, Variety3UsedValues.Variety_3_Value) then begin
                                TempVarietyValue.Init();
                                TempVarietyValue := VarietyValue;
                                if ShowColumnNames and (TempVarietyValue.Description = '') then
                                    TempVarietyValue.Description := CopyStr(TempVarietyValue.Value, 1, MaxStrLen(TempVarietyValue.Description));
                                TempVarietyValue.Insert();
                            end;
                        end;
                    end;
                ShowCrossVRTNo::VRT4:
                    begin
                        Variety4UsedValues.SetRange(Item_No_Filter, Item."No.");
                        Variety4UsedValues.SetRange(Variety_4, Item."NPR Variety 4");
                        Variety4UsedValues.SetRange(Variety_4_Table, Item."NPR Variety 4 Table");
                        Variety4UsedValues.SetRange(Blocked, false);
                        Variety4UsedValues.Open();
                        while Variety4UsedValues.Read() do begin
                            if VarietyValue.Get(Variety4UsedValues.Variety_4, Variety4UsedValues.Variety_4_Table, Variety4UsedValues.Variety_4_Value) then begin
                                TempVarietyValue.Init();
                                TempVarietyValue := VarietyValue;
                                if ShowColumnNames and (TempVarietyValue.Description = '') then
                                    TempVarietyValue.Description := CopyStr(TempVarietyValue.Value, 1, MaxStrLen(TempVarietyValue.Description));
                                TempVarietyValue.Insert();
                            end;
                        end;
                    end;
            end;
            TempVarietyValue.SetCurrentKey(Type, Table, "Sort Order");
            RecRef.GetTable(TempVarietyValue);
            RecRef.SetTable(TempVarietyValue);

        end else begin
            VarietyValue.SetCurrentKey(Type, Table, "Sort Order");
            case ShowCrossVRTNo of
                ShowCrossVRTNo::VRT1:
                    begin
                        VarietyNotUsed := Item."NPR Variety 1" = '';
                        VarietyValue.SetRange(Type, Item."NPR Variety 1");
                        VarietyValue.SetRange(Table, Item."NPR Variety 1 Table");
                    end;
                ShowCrossVRTNo::VRT2:
                    begin
                        VarietyNotUsed := Item."NPR Variety 2" = '';
                        VarietyValue.SetRange(Type, Item."NPR Variety 2");
                        VarietyValue.SetRange(Table, Item."NPR Variety 2 Table");
                    end;
                ShowCrossVRTNo::VRT3:
                    begin
                        VarietyNotUsed := Item."NPR Variety 3" = '';
                        VarietyValue.SetRange(Type, Item."NPR Variety 3");
                        VarietyValue.SetRange(Table, Item."NPR Variety 3 Table");
                    end;
                ShowCrossVRTNo::VRT4:
                    begin
                        VarietyNotUsed := Item."NPR Variety 4" = '';
                        VarietyValue.SetRange(Type, Item."NPR Variety 4");
                        VarietyValue.SetRange(Table, Item."NPR Variety 4 Table");
                    end;
            end;

            RecRef.GetTable(VarietyValue);
            RecRef.SetTable(VarietyValue);
        end;

        if VarietyNotUsed then begin
            //insert fake variety to use in the matrix
            TempVarietyValue.Init();
            case ShowCrossVRTNo of
                ShowCrossVRTNo::VRT1:
                    begin
                        TempVarietyValue.Type := Item."NPR Variety 1";
                        TempVarietyValue.Table := Item."NPR Variety 1 Table";
                    end;
                ShowCrossVRTNo::VRT2:
                    begin
                        TempVarietyValue.Type := Item."NPR Variety 2";
                        TempVarietyValue.Table := Item."NPR Variety 2 Table";
                    end;
                ShowCrossVRTNo::VRT3:
                    begin
                        TempVarietyValue.Type := Item."NPR Variety 3";
                        TempVarietyValue.Table := Item."NPR Variety 3 Table";
                    end;
                ShowCrossVRTNo::VRT4:
                    begin
                        TempVarietyValue.Type := Item."NPR Variety 4";
                        TempVarietyValue.Table := Item."NPR Variety 4 Table";
                    end;
            end;

            TempVarietyValue.Description := NotUsedText;
            TempVarietyValue.Insert();

            RecRef.GetTable(TempVarietyValue);
            RecRef.SetTable(TempVarietyValue);
        end;

        MatrixMgt.GenerateMatrixData(
            RecRef, MATRIX_SetWanted, ArrayLen(MATRIX_CodeSet), VarietyValue.FieldNo(Value),
            MATRIX_PrimKeyFirstCaptionInCu, MATRIX_CodeSet, MATRIX_CaptionRange, MATRIX_CurrentNoOfColumns);

        if ShowColumnNames then
            CaptionFieldNo := VarietyValue.FieldNo(Description)
        else
            CaptionFieldNo := VarietyValue.FieldNo(Value);

        MatrixMgt.GenerateMatrixData(
            RecRef, MATRIX_SetWanted, ArrayLen(MATRIX_CaptionSet), CaptionFieldNo,
            MATRIX_PrimKeyFirstCaptionInCu, MATRIX_CaptionSet, MATRIX_CaptionRange, MATRIX_CurrentNoOfColumns);
    end;

    internal procedure TickAllCombinations(VRTFieldSetup: Record "NPR Variety Field Setup")
    var
        ItemVariant: Record "Item Variant";
        VRTCloneData: Codeunit "NPR Variety Clone Data";
    begin
        if TempVRTBuffer_.FindSet() then
            repeat
                if (VRTFieldSetup.Type = VRTFieldSetup.Type::Internal) and (VRTFieldSetup."Field No." = 2) then begin
                    //create Variant
                    if not VRTCloneData.GetFromVariety(ItemVariant, TempVRTBuffer_."Item No.", TempVRTBuffer_."Variety 1 Value", TempVRTBuffer_."Variety 2 Value", TempVRTBuffer_."Variety 3 Value", TempVRTBuffer_."Variety 4 Value") then
                        SetValue(TempVRTBuffer_."Variety 1 Value", TempVRTBuffer_."Variety 2 Value", TempVRTBuffer_."Variety 3 Value", TempVRTBuffer_."Variety 4 Value", VRTFieldSetup, Format(true));
                end else begin
                    if VRTCloneData.GetFromVariety(ItemVariant, TempVRTBuffer_."Item No.", TempVRTBuffer_."Variety 1 Value", TempVRTBuffer_."Variety 2 Value", TempVRTBuffer_."Variety 3 Value", TempVRTBuffer_."Variety 4 Value") then
                        SetValue(TempVRTBuffer_."Variety 1 Value", TempVRTBuffer_."Variety 2 Value", TempVRTBuffer_."Variety 3 Value", TempVRTBuffer_."Variety 4 Value", VRTFieldSetup, Format(true));
                end;
            until TempVRTBuffer_.Next() = 0;
    end;

    internal procedure TickCurrentRow(VRTFieldSetup: Record "NPR Variety Field Setup"; CurrVRTBuffer: Record "NPR Variety Buffer")
    var
        ItemVariant: Record "Item Variant";
        VRTCloneData: Codeunit "NPR Variety Clone Data";
    begin
        if (CurrVRTBuffer."Variety 1 Value" <> '') then
            TempVRTBuffer_.SetRange(TempVRTBuffer_."Variety 1 Value", CurrVRTBuffer."Variety 1 Value");
        if (CurrVRTBuffer."Variety 2 Value" <> '') then
            TempVRTBuffer_.SetRange(TempVRTBuffer_."Variety 2 Value", CurrVRTBuffer."Variety 2 Value");
        if (CurrVRTBuffer."Variety 3 Value" <> '') then
            TempVRTBuffer_.SetRange(TempVRTBuffer_."Variety 3 Value", CurrVRTBuffer."Variety 3 Value");
        if (CurrVRTBuffer."Variety 4 Value" <> '') then
            TempVRTBuffer_.SetRange(TempVRTBuffer_."Variety 4 Value", CurrVRTBuffer."Variety 4 Value");

        if TempVRTBuffer_.FindSet() then
            repeat
                if (VRTFieldSetup.Type = VRTFieldSetup.Type::Internal) and (VRTFieldSetup."Field No." = 2) then begin
                    //create Variant
                    if not VRTCloneData.GetFromVariety(ItemVariant, TempVRTBuffer_."Item No.", TempVRTBuffer_."Variety 1 Value", TempVRTBuffer_."Variety 2 Value", TempVRTBuffer_."Variety 3 Value", TempVRTBuffer_."Variety 4 Value") then
                        SetValue(TempVRTBuffer_."Variety 1 Value", TempVRTBuffer_."Variety 2 Value", TempVRTBuffer_."Variety 3 Value", TempVRTBuffer_."Variety 4 Value", VRTFieldSetup, Format(true));
                end else begin
                    if VRTCloneData.GetFromVariety(ItemVariant, TempVRTBuffer_."Item No.", TempVRTBuffer_."Variety 1 Value", TempVRTBuffer_."Variety 2 Value", TempVRTBuffer_."Variety 3 Value", TempVRTBuffer_."Variety 4 Value") then
                        SetValue(TempVRTBuffer_."Variety 1 Value", TempVRTBuffer_."Variety 2 Value", TempVRTBuffer_."Variety 3 Value", TempVRTBuffer_."Variety 4 Value", VRTFieldSetup, Format(true));
                end;
            until TempVRTBuffer_.Next() = 0;

        TempVRTBuffer_.SetRange(TempVRTBuffer_."Variety 1 Value");
        TempVRTBuffer_.SetRange(TempVRTBuffer_."Variety 2 Value");
        TempVRTBuffer_.SetRange(TempVRTBuffer_."Variety 3 Value");
        TempVRTBuffer_.SetRange(TempVRTBuffer_."Variety 4 Value");

    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        if _Item."No." = ItemNo then
            exit;
        _Item.Get(ItemNo);
    end;

    internal procedure OnLookup(VrtBuffer: Record "NPR Variety Buffer"; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024]; var ItemFilters: Record Item)
    begin
        TempVRTBuffer_.Get(VrtBuffer."Variety 1 Value", VrtBuffer."Variety 2 Value", VrtBuffer."Variety 3 Value", VrtBuffer."Variety 4 Value");
        OnDrillDownVarietyMatrix(TempVRTBuffer_, VrtFieldSetup, FieldValue, 1, ItemFilters);
    end;

    internal procedure OnLookupTotal(CurrentCellVarietyBuffer: Record "NPR Variety Buffer"; ShowAsCrossVRT: Option Variety1,Variety2,Variety3,Variety4; VrtFieldSetup: Record "NPR Variety Field Setup"; var ItemFilters: Record Item)
    var
        TempVarietyBufferInRange: Record "NPR Variety Buffer" temporary;
    begin
        if VrtFieldSetup."OnDrillDown Subscriber" = '' then
            exit;
        TempVRTBuffer_.SetRange("Variety 1 Value", CurrentCellVarietyBuffer."Variety 1 Value");
        TempVRTBuffer_.SetRange("Variety 2 Value", CurrentCellVarietyBuffer."Variety 2 Value");
        TempVRTBuffer_.SetRange("Variety 3 Value", CurrentCellVarietyBuffer."Variety 3 Value");
        TempVRTBuffer_.SetRange("Variety 4 Value", CurrentCellVarietyBuffer."Variety 4 Value");
        case ShowAsCrossVRT of
            ShowAsCrossVRT::Variety1:
                TempVRTBuffer_.SetRange("Variety 1 Value");
            ShowAsCrossVRT::Variety2:
                TempVRTBuffer_.SetRange("Variety 2 Value");
            ShowAsCrossVRT::Variety3:
                TempVRTBuffer_.SetRange("Variety 3 Value");
            ShowAsCrossVRT::Variety4:
                TempVRTBuffer_.SetRange("Variety 4 Value");
        end;
        if TempVRTBuffer_.FindSet() then
            repeat
                TempVarietyBufferInRange := TempVRTBuffer_;
                TempVarietyBufferInRange.Insert(false);
            until TempVRTBuffer_.Next() = 0;
        OnLookupVarietyMatrixTotal(CurrentCellVarietyBuffer, TempVarietyBufferInRange, VrtFieldSetup, ItemFilters);
    end;

    internal procedure ClearMatrixData()
    var
        RecRef: RecordRef;
    begin
        if TempVRTBuffer_.FindSet(true) then
            repeat
                if RecRef.Get(TempVRTBuffer_."Record ID (TMP)") then begin
                    Clear(TempVRTBuffer_."Record ID (TMP)");
                    TempVRTBuffer_.Modify();
                end;
            until TempVRTBuffer_.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDrillDownVarietyMatrix(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024]; CalledFrom: Option OnDrillDown,OnLookup; var ItemFilters: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure GetVarietyMatrixFieldValue(TMPVrtBuffer: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; var FieldValue: Text[1024]; SubscriberName: Text; var ItemFilters: Record Item; CalledFrom: Option PrimaryField,SecondaryField)
    begin
    end;

    /// <summary>
    /// Event for setting the value to be shown in Total Column in Variety Matrix
    /// </summary>
    /// <param name="CurrentCellVarietyBuffer">Buffer Entry with Variety Values for the row</param>
    /// <param name="VarietyBufferInRange">Buffer Entries in the range to be summed. Is var so it can be looped, changes to the Buffer will not be saved</param>
    /// <param name="VrtFieldSetup">The Variety Field Setup shown in the Matrix</param>
    /// <param name="SubscriberName">Name of the subscriber that should return the Value</param>
    /// <param name="ItemFilters">Item Record with the filters used in the Matrix</param>
    /// <param name="CalledFrom">Tells if the value to be returned will be shown in primary or secondary text in Matrix</param>
    /// <param name="FieldValue">The return value - Text to be shown in the Matrix</param>
    [IntegrationEvent(false, false)]
    local procedure GetVarietyMatrixTotalValue(CurrentCellVarietyBuffer: Record "NPR Variety Buffer" temporary; var VarietyBufferInRange: Record "NPR Variety Buffer" temporary; VrtFieldSetup: Record "NPR Variety Field Setup"; SubscriberName: Text; var ItemFilters: Record Item; CalledFrom: Option PrimaryField,SecondaryField; var FieldValue: Text[1024])
    begin
    end;

    /// <summary>
    /// Event for DrillDown in Total Column of Matrix
    /// </summary>
    /// <param name="CurrentCellVarietyBuffer">Buffer Entry with Variety Values for the row</param>
    /// <param name="VarietyBufferInRange">Buffer Entries in the range to be summed. Is var so it can be looped, changes to the Buffer will not be saved</param>
    /// <param name="VrtFieldSetup">The Variety Field Setup shown in the Matrix</param>
    /// <param name="ItemFilters">Item Record with the filters used in the Matrix</param>
    [IntegrationEvent(false, false)]
    local procedure OnDrillDownVarietyMatrixTotal(CurrentCellVarietyBuffer: Record "NPR Variety Buffer"; var VarietyBufferInRange: Record "NPR Variety Buffer"; VrtFieldSetup: Record "NPR Variety Field Setup"; var ItemFilters: Record Item)
    begin
    end;

    /// <summary>
    /// Event for DrillDown in Total Column of Matrix
    /// </summary>
    /// <param name="CurrentCellVarietyBuffer">Buffer Entry with Variety Values for the row</param>
    /// <param name="VarietyBufferInRange">Buffer Entries in the range to be summed. Is var so it can be looped, changes to the Buffer will not be saved</param>
    /// <param name="VrtFieldSetup">The Variety Field Setup shown in the Matrix</param>
    /// <param name="ItemFilters">Item Record with the filters used in the Matrix</param>
    [IntegrationEvent(false, false)]
    local procedure OnLookupVarietyMatrixTotal(CurrentCellVarietyBuffer: Record "NPR Variety Buffer"; var VarietyBufferInRange: Record "NPR Variety Buffer"; VrtFieldSetup: Record "NPR Variety Field Setup"; var ItemFilters: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetValue(RecRef: RecordRef; FldRef: FieldRef; VRTFieldSetup: Record "NPR Variety Field Setup"; NewValue: Text[250]; OldValue: Text; var Handled: Boolean)
    begin
    end;

}
