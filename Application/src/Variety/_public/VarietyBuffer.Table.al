﻿table 6059974 "NPR Variety Buffer"
{
    Caption = 'Variety Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Variety 1 Value"; Code[50])
        {
            Caption = 'Variety 1 Value';
            DataClassification = CustomerContent;
        }
        field(2; "Variety 2 Value"; Code[50])
        {
            Caption = 'Variety 2 Value';
            DataClassification = CustomerContent;
        }
        field(3; "Variety 3 Value"; Code[50])
        {
            Caption = 'Variety 3 Value';
            DataClassification = CustomerContent;
        }
        field(4; "Variety 4 Value"; Code[50])
        {
            Caption = 'Variety 4 Value';
            DataClassification = CustomerContent;
        }
        field(8; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(9; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(10; "Variety 1 Sort Order"; Integer)
        {
            Caption = 'Variety 1 Sort Order';
            DataClassification = CustomerContent;
        }
        field(11; "Variety 2 Sort Order"; Integer)
        {
            Caption = 'Variety 2 Sort Order';
            DataClassification = CustomerContent;
        }
        field(12; "Variety 3 Sort Order"; Integer)
        {
            Caption = 'Variety 3 Sort Order';
            DataClassification = CustomerContent;
        }
        field(13; "Variety 4 Sort Order"; Integer)
        {
            Caption = 'Variety 4 Sort Order';
            DataClassification = CustomerContent;
        }
        field(20; Description; Text[92])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; "Record ID (TMP)"; RecordID)
        {
            Caption = 'Record ID (TMP)';
            DataClassification = CustomerContent;
        }
        field(31; "Master Record ID"; RecordID)
        {
            Caption = 'Master Record ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Variety 1 Value", "Variety 2 Value", "Variety 3 Value", "Variety 4 Value")
        {
        }
        key(Key2; "Variety 2 Value", "Variety 3 Value", "Variety 4 Value")
        {
        }
        key(Key3; "Variety 3 Value", "Variety 4 Value")
        {
        }
        key(Key4; "Variety 4 Value")
        {
        }
        key(Key5; "Variety 1 Sort Order", "Variety 2 Sort Order", "Variety 3 Sort Order", "Variety 4 Sort Order")
        {
        }
        key(Key6; "Variety 2 Sort Order", "Variety 3 Sort Order", "Variety 4 Sort Order", "Variety 1 Sort Order")
        {
        }
        key(Key7; "Variety 3 Sort Order", "Variety 4 Sort Order", "Variety 1 Sort Order", "Variety 2 Sort Order")
        {
        }
        key(Key8; "Variety 4 Sort Order", "Variety 1 Sort Order", "Variety 2 Sort Order", "Variety 3 Sort Order")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Window: Dialog;
        text000: Label 'Load Varieties #1#######################################';

    internal procedure LoadMatrixRecords(var TMPVRTBuffer: Record "NPR Variety Buffer" temporary; ItemNo: Code[20]; CrossVRTNo: Option VRT1,VRT2,VRT3,VRT4)
    var
        Item: Record Item;
        VRT1: Record "NPR Variety Value";
        VRT2: Record "NPR Variety Value";
        VRT3: Record "NPR Variety Value";
        VRT4: Record "NPR Variety Value";
        TempVRT1: Record "NPR Variety Value" temporary;
        TempVRT2: Record "NPR Variety Value" temporary;
        TempVRT3: Record "NPR Variety Value" temporary;
        TempVRT4: Record "NPR Variety Value" temporary;
        VRT1Desc: Text[30];
        VRT2Desc: Text[30];
        VRT3Desc: Text[30];
        VRT4Desc: Text[30];
    begin
        TMPVRTBuffer.SetRange("Variety 1 Value");
        TMPVRTBuffer.SetRange("Variety 2 Value");
        TMPVRTBuffer.SetRange("Variety 3 Value");
        TMPVRTBuffer.SetRange("Variety 4 Value");
        TMPVRTBuffer.DeleteAll();

        Item.Get(ItemNo);
        case CrossVRTNo of
            CrossVRTNo::VRT1:
                begin
                    TempVRT1.Type := '';
                    TempVRT1.Table := '';
                    TempVRT1.Insert();

                    if Item."NPR Variety 2" = '' then begin
                        TempVRT2.Type := '';
                        TempVRT2.Table := '';
                        TempVRT2.Insert();
                    end else begin
                        VRT2.SetRange(Type, Item."NPR Variety 2");
                        VRT2.SetRange(Table, Item."NPR Variety 2 Table");
                        if VRT2.FindSet() then
                            repeat
                                TempVRT2 := VRT2;
                                TempVRT2.Insert();
                            until VRT2.Next() = 0;
                    end;

                    if Item."NPR Variety 3" = '' then begin
                        TempVRT3.Type := '';
                        TempVRT3.Table := '';
                        TempVRT3.Insert();
                    end else begin
                        VRT3.SetRange(Type, Item."NPR Variety 3");
                        VRT3.SetRange(Table, Item."NPR Variety 3 Table");
                        if VRT3.FindSet() then
                            repeat
                                TempVRT3 := VRT3;
                                TempVRT3.Insert();
                            until VRT3.Next() = 0;
                    end;

                    if Item."NPR Variety 4" = '' then begin
                        TempVRT4.Type := '';
                        TempVRT4.Table := '';
                        TempVRT4.Insert();
                    end else begin
                        VRT4.SetRange(Type, Item."NPR Variety 4");
                        VRT4.SetRange(Table, Item."NPR Variety 4 Table");
                        if VRT4.FindSet() then
                            repeat
                                TempVRT4 := VRT4;
                                TempVRT4.Insert();
                            until VRT4.Next() = 0;
                    end;
                end;
            CrossVRTNo::VRT2:
                begin
                    if Item."NPR Variety 1" = '' then begin
                        TempVRT1.Type := '';
                        TempVRT1.Table := '';
                        TempVRT1.Insert();
                    end else begin
                        VRT1.SetRange(Type, Item."NPR Variety 1");
                        VRT1.SetRange(Table, Item."NPR Variety 1 Table");
                        if VRT1.FindSet() then
                            repeat
                                TempVRT1 := VRT1;
                                TempVRT1.Insert();
                            until VRT1.Next() = 0;
                    end;

                    TempVRT2.Type := '';
                    TempVRT2.Table := '';
                    TempVRT2.Insert();

                    if Item."NPR Variety 3" = '' then begin
                        TempVRT3.Type := '';
                        TempVRT3.Table := '';
                        TempVRT3.Insert();
                    end else begin
                        VRT3.SetRange(Type, Item."NPR Variety 3");
                        VRT3.SetRange(Table, Item."NPR Variety 3 Table");
                        if VRT3.FindSet() then
                            repeat
                                TempVRT3 := VRT3;
                                TempVRT3.Insert();
                            until VRT3.Next() = 0;
                    end;

                    if Item."NPR Variety 4" = '' then begin
                        TempVRT4.Type := '';
                        TempVRT4.Table := '';
                        TempVRT4.Insert();
                    end else begin
                        VRT4.SetRange(Type, Item."NPR Variety 4");
                        VRT4.SetRange(Table, Item."NPR Variety 4 Table");
                        if VRT4.FindSet() then
                            repeat
                                TempVRT4 := VRT4;
                                TempVRT4.Insert();
                            until VRT4.Next() = 0;
                    end;
                end;
            CrossVRTNo::VRT3:
                begin
                    if Item."NPR Variety 1" = '' then begin
                        TempVRT1.Type := '';
                        TempVRT1.Table := '';
                        TempVRT1.Insert();
                    end else begin
                        VRT1.SetRange(Type, Item."NPR Variety 1");
                        VRT1.SetRange(Table, Item."NPR Variety 1 Table");
                        if VRT1.FindSet() then
                            repeat
                                TempVRT1 := VRT1;
                                TempVRT1.Insert();
                            until VRT1.Next() = 0;
                    end;

                    if Item."NPR Variety 2" = '' then begin
                        TempVRT2.Type := '';
                        TempVRT2.Table := '';
                        TempVRT2.Insert();
                    end else begin
                        VRT2.SetRange(Type, Item."NPR Variety 2");
                        VRT2.SetRange(Table, Item."NPR Variety 2 Table");
                        if VRT2.FindSet() then
                            repeat
                                TempVRT2 := VRT2;
                                TempVRT2.Insert();
                            until VRT2.Next() = 0;
                    end;

                    TempVRT3.Type := '';
                    TempVRT3.Table := '';
                    TempVRT3.Insert();

                    if Item."NPR Variety 4" = '' then begin
                        TempVRT4.Type := '';
                        TempVRT4.Table := '';
                        TempVRT4.Insert();
                    end else begin
                        VRT4.SetRange(Type, Item."NPR Variety 4");
                        VRT4.SetRange(Table, Item."NPR Variety 4 Table");
                        if VRT4.FindSet() then
                            repeat
                                TempVRT4 := VRT4;
                                TempVRT4.Insert();
                            until VRT4.Next() = 0;
                    end;
                end;
            CrossVRTNo::VRT4:
                begin
                    if Item."NPR Variety 1" = '' then begin
                        TempVRT1.Type := '';
                        TempVRT1.Table := '';
                        TempVRT1.Insert();
                    end else begin
                        VRT1.SetRange(Type, Item."NPR Variety 1");
                        VRT1.SetRange(Table, Item."NPR Variety 1 Table");
                        if VRT1.FindSet() then
                            repeat
                                TempVRT1 := VRT1;
                                TempVRT1.Insert();
                            until VRT1.Next() = 0;
                    end;

                    if Item."NPR Variety 2" = '' then begin
                        TempVRT2.Type := '';
                        TempVRT2.Table := '';
                        TempVRT2.Insert();
                    end else begin
                        VRT2.SetRange(Type, Item."NPR Variety 2");
                        VRT2.SetRange(Table, Item."NPR Variety 2 Table");
                        if VRT2.FindSet() then
                            repeat
                                TempVRT2 := VRT2;
                                TempVRT2.Insert();
                            until VRT2.Next() = 0;
                    end;

                    if Item."NPR Variety 3" = '' then begin
                        TempVRT3.Type := '';
                        TempVRT3.Table := '';
                        TempVRT3.Insert();
                    end else begin
                        VRT3.SetRange(Type, Item."NPR Variety 3");
                        VRT3.SetRange(Table, Item."NPR Variety 3 Table");
                        if VRT3.FindSet() then
                            repeat
                                TempVRT3 := VRT3;
                                TempVRT3.Insert();
                            until VRT3.Next() = 0;
                    end;

                    TempVRT4.Type := '';
                    TempVRT4.Table := '';
                    TempVRT4.Insert();
                end;
        end;

        TempVRT1.SetCurrentKey(Type, Table, "Sort Order");
        TempVRT2.SetCurrentKey(Type, Table, "Sort Order");
        TempVRT3.SetCurrentKey(Type, Table, "Sort Order");
        TempVRT4.SetCurrentKey(Type, Table, "Sort Order");
        if TempVRT1.FindSet() then
            repeat
                if TempVRT2.FindSet() then
                    repeat
                        if TempVRT3.FindSet() then
                            repeat
                                if TempVRT4.FindSet() then
                                    repeat
                                        TMPVRTBuffer.Init();
                                        TMPVRTBuffer."Variety 1 Value" := TempVRT1.Value;
                                        TMPVRTBuffer."Variety 2 Value" := TempVRT2.Value;
                                        TMPVRTBuffer."Variety 3 Value" := TempVRT3.Value;
                                        TMPVRTBuffer."Variety 4 Value" := TempVRT4.Value;
                                        TMPVRTBuffer."Variety 1 Sort Order" := TempVRT1."Sort Order";
                                        TMPVRTBuffer."Variety 2 Sort Order" := TempVRT2."Sort Order";
                                        TMPVRTBuffer."Variety 3 Sort Order" := TempVRT3."Sort Order";
                                        TMPVRTBuffer."Variety 4 Sort Order" := TempVRT4."Sort Order";
                                        TMPVRTBuffer."Item No." := ItemNo;

                                        if TempVRT1.Description = '' then
                                            VRT1Desc := CopyStr(TempVRT1.Value, 1, MaxStrLen(VRT1Desc))
                                        else
                                            VRT1Desc := TempVRT1.Description;

                                        if TempVRT2.Description = '' then
                                            VRT2Desc := CopyStr(TempVRT2.Value, 1, MaxStrLen(VRT2Desc))
                                        else
                                            VRT2Desc := TempVRT2.Description;

                                        if TempVRT3.Description = '' then
                                            VRT3Desc := CopyStr(TempVRT3.Value, 1, MaxStrLen(VRT3Desc))
                                        else
                                            VRT3Desc := TempVRT3.Description;

                                        if TempVRT4.Description = '' then
                                            VRT4Desc := CopyStr(TempVRT4.Value, 1, MaxStrLen(VRT4Desc))
                                        else
                                            VRT4Desc := TempVRT4.Description;

                                        TMPVRTBuffer.Description := CopyStr(VRT1Desc + ' ' + VRT2Desc + ' ' + VRT3Desc + ' ' + VRT4Desc, 1, MaxStrLen(TMPVRTBuffer.Description));
                                        TMPVRTBuffer.Insert();
                                    until TempVRT4.Next() = 0;
                            until TempVRT3.Next() = 0;
                    until TempVRT2.Next() = 0;
            until TempVRT1.Next() = 0;
    end;

    internal procedure LoadAll(var TMPVRTBuffer: Record "NPR Variety Buffer" temporary; ItemNo: Code[20]; SetRecordID2ItemVar: Boolean; MasterRecordID: RecordID)
    var
        Item: Record Item;
        VRT1: Record "NPR Variety Value";
        VRT2: Record "NPR Variety Value";
        VRT3: Record "NPR Variety Value";
        VRT4: Record "NPR Variety Value";
        TempVRT1: Record "NPR Variety Value" temporary;
        TempVRT2: Record "NPR Variety Value" temporary;
        TempVRT3: Record "NPR Variety Value" temporary;
        TempVRT4: Record "NPR Variety Value" temporary;
        ItemVar: Record "Item Variant";
        RecRef: RecordRef;
        VarietyCloneData: Codeunit "NPR Variety Clone Data";
    begin
        TMPVRTBuffer.Reset();
        TMPVRTBuffer.DeleteAll();

        Item.Get(ItemNo);
        if Item."NPR Variety 1" = '' then begin
            TempVRT1.Type := '';
            TempVRT1.Table := '';
            TempVRT1.Insert();
        end else begin
            VRT1.SetRange(Type, Item."NPR Variety 1");
            VRT1.SetRange(Table, Item."NPR Variety 1 Table");
            if VRT1.FindSet() then
                repeat
                    TempVRT1 := VRT1;
                    TempVRT1.Insert();
                until VRT1.Next() = 0;
        end;

        if Item."NPR Variety 2" = '' then begin
            TempVRT2.Type := '';
            TempVRT2.Table := '';
            TempVRT2.Insert();
        end else begin
            VRT2.SetRange(Type, Item."NPR Variety 2");
            VRT2.SetRange(Table, Item."NPR Variety 2 Table");
            if VRT2.FindSet() then
                repeat
                    TempVRT2 := VRT2;
                    TempVRT2.Insert();
                until VRT2.Next() = 0;
        end;

        if Item."NPR Variety 3" = '' then begin
            TempVRT3.Type := '';
            TempVRT3.Table := '';
            TempVRT3.Insert();
        end else begin
            VRT3.SetRange(Type, Item."NPR Variety 3");
            VRT3.SetRange(Table, Item."NPR Variety 3 Table");
            if VRT3.FindSet() then
                repeat
                    TempVRT3 := VRT3;
                    TempVRT3.Insert();
                until VRT3.Next() = 0;
        end;

        if Item."NPR Variety 4" = '' then begin
            TempVRT4.Type := '';
            TempVRT4.Table := '';
            TempVRT4.Insert();
        end else begin
            VRT4.SetRange(Type, Item."NPR Variety 4");
            VRT4.SetRange(Table, Item."NPR Variety 4 Table");
            if VRT4.FindSet() then
                repeat
                    TempVRT4 := VRT4;
                    TempVRT4.Insert();
                until VRT4.Next() = 0;
        end;

        TempVRT1.SetCurrentKey(Type, Table, "Sort Order");
        TempVRT2.SetCurrentKey(Type, Table, "Sort Order");
        TempVRT3.SetCurrentKey(Type, Table, "Sort Order");
        TempVRT4.SetCurrentKey(Type, Table, "Sort Order");
        if TempVRT1.FindSet() then
            repeat
                if TempVRT2.FindSet() then
                    repeat
                        if TempVRT3.FindSet() then
                            repeat
                                if TempVRT4.FindSet() then
                                    repeat
                                        TMPVRTBuffer.Init();
                                        TMPVRTBuffer."Variety 1 Value" := TempVRT1.Value;
                                        TMPVRTBuffer."Variety 2 Value" := TempVRT2.Value;
                                        TMPVRTBuffer."Variety 3 Value" := TempVRT3.Value;
                                        TMPVRTBuffer."Variety 4 Value" := TempVRT4.Value;
                                        TMPVRTBuffer."Variety 1 Sort Order" := TempVRT1."Sort Order";
                                        TMPVRTBuffer."Variety 2 Sort Order" := TempVRT2."Sort Order";
                                        TMPVRTBuffer."Variety 3 Sort Order" := TempVRT3."Sort Order";
                                        TMPVRTBuffer."Variety 4 Sort Order" := TempVRT4."Sort Order";
                                        TMPVRTBuffer."Item No." := ItemNo;
                                        TMPVRTBuffer."Master Record ID" := MasterRecordID;

                                        if VarietyCloneData.GetFromVariety(ItemVar, ItemNo, TMPVRTBuffer."Variety 1 Value", TMPVRTBuffer."Variety 2 Value",
                                                                          TMPVRTBuffer."Variety 3 Value", TMPVRTBuffer."Variety 4 Value") then begin
                                            TMPVRTBuffer."Variant Code" := ItemVar.Code;
                                            if SetRecordID2ItemVar then begin
                                                RecRef.GetTable(ItemVar);
                                                TMPVRTBuffer."Record ID (TMP)" := RecRef.RecordId;
                                            end;
                                        end;
                                        TMPVRTBuffer.Insert();
                                    until TempVRT4.Next() = 0;
                            until TempVRT3.Next() = 0;
                    until TempVRT2.Next() = 0;
            until TempVRT1.Next() = 0;
    end;

    procedure LoadMatrixRows(var TMPVRTBuffer: Record "NPR Variety Buffer" temporary; Item: Record Item; CrossVRTNo: Option VRT1,VRT2,VRT3,VRT4; HideInactive: Boolean)
    begin
        TMPVRTBuffer.SetRange("Variety 1 Value");
        TMPVRTBuffer.SetRange("Variety 2 Value");
        TMPVRTBuffer.SetRange("Variety 3 Value");
        TMPVRTBuffer.SetRange("Variety 4 Value");
        TMPVRTBuffer.DeleteAll();

        if HideInactive then begin
            case CrossVRTNo of
                CrossVRTNo::VRT1:
                    LoadUsedRowsCrossVRT1(TMPVRTBuffer, Item);
                CrossVRTNo::VRT2:
                    LoadUsedRowsCrossVRT2(TMPVRTBuffer, Item);
                CrossVRTNo::VRT3:
                    LoadUsedRowsCrossVRT3(TMPVRTBuffer, Item);
                CrossVRTNo::VRT4:
                    LoadUsedRowsCrossVRT4(TMPVRTBuffer, Item);
            end;
        end else
            LoadAllRows(TMPVRTBuffer, Item, CrossVRTNo);
    end;

    procedure LoadCombinations(var TMPVRTBuffer: Record "NPR Variety Buffer" temporary; ItemNo: Code[20]; SetRecordID2ItemVar: Boolean; MasterRecordID: RecordID; HideInactive: Boolean)
    var
        Item: Record Item;
        TempVRT1: Record "NPR Variety Value" temporary;
        TempVRT2: Record "NPR Variety Value" temporary;
        TempVRT3: Record "NPR Variety Value" temporary;
        TempVRT4: Record "NPR Variety Value" temporary;
        ItemVar: Record "Item Variant";
        RecRef: RecordRef;
        VarietyCloneData: Codeunit "NPR Variety Clone Data";
    begin
        TMPVRTBuffer.Reset();
        TMPVRTBuffer.DeleteAll();

        Item.Get(ItemNo);

        Window.Open(text000);

        if HideInactive then begin
            //Warning - sort order is not filled into the tmp buffer from below function call (and its not used for anything)
            LoadUsedValuesVRT1(Item, TempVRT1);
            LoadUsedValuesVRT2(Item, TempVRT2);
            LoadUsedValuesVRT3(Item, TempVRT3);
            LoadUsedValuesVRT4(Item, TempVRT4);
        end else begin
            InsertAllValuesInTmpTable(Item."NPR Variety 1", Item."NPR Variety 1 Table", TempVRT1);
            InsertAllValuesInTmpTable(Item."NPR Variety 2", Item."NPR Variety 2 Table", TempVRT2);
            InsertAllValuesInTmpTable(Item."NPR Variety 3", Item."NPR Variety 3 Table", TempVRT3);
            InsertAllValuesInTmpTable(Item."NPR Variety 4", Item."NPR Variety 4 Table", TempVRT4);
        end;

        TempVRT1.SetCurrentKey(Type, Table, "Sort Order");
        TempVRT2.SetCurrentKey(Type, Table, "Sort Order");
        TempVRT3.SetCurrentKey(Type, Table, "Sort Order");
        TempVRT4.SetCurrentKey(Type, Table, "Sort Order");
        if TempVRT1.FindSet() then
            repeat
                if TempVRT2.FindSet() then
                    repeat
                        if TempVRT3.FindSet() then
                            repeat
                                if TempVRT4.FindSet() then
                                    repeat
                                        Window.Update(1, TempVRT1.Value + ' ' + TempVRT2.Value + ' ' + TempVRT3.Value + ' ' + TempVRT4.Value + ' ');
                                        TMPVRTBuffer.Init();
                                        TMPVRTBuffer."Variety 1 Value" := TempVRT1.Value;
                                        TMPVRTBuffer."Variety 2 Value" := TempVRT2.Value;
                                        TMPVRTBuffer."Variety 3 Value" := TempVRT3.Value;
                                        TMPVRTBuffer."Variety 4 Value" := TempVRT4.Value;
                                        TMPVRTBuffer."Variety 1 Sort Order" := TempVRT1."Sort Order";
                                        TMPVRTBuffer."Variety 2 Sort Order" := TempVRT2."Sort Order";
                                        TMPVRTBuffer."Variety 3 Sort Order" := TempVRT3."Sort Order";
                                        TMPVRTBuffer."Variety 4 Sort Order" := TempVRT4."Sort Order";
                                        TMPVRTBuffer."Item No." := ItemNo;
                                        TMPVRTBuffer."Master Record ID" := MasterRecordID;

                                        if VarietyCloneData.GetFromVariety(ItemVar, ItemNo, TMPVRTBuffer."Variety 1 Value", TMPVRTBuffer."Variety 2 Value",
                                                                          TMPVRTBuffer."Variety 3 Value", TMPVRTBuffer."Variety 4 Value") then begin
                                            TMPVRTBuffer."Variant Code" := ItemVar.Code;
                                            if SetRecordID2ItemVar then begin
                                                RecRef.GetTable(ItemVar);
                                                TMPVRTBuffer."Record ID (TMP)" := RecRef.RecordId;
                                            end;
                                        end;
                                        TMPVRTBuffer.Insert();
                                    until TempVRT4.Next() = 0;
                            until TempVRT3.Next() = 0;
                    until TempVRT2.Next() = 0;
            until TempVRT1.Next() = 0;

        Window.Close();
    end;

    local procedure InsertAllValuesInTmpTable(VarietyType: Code[20]; VarietyTable: Code[40]; var TMPVRTValue: Record "NPR Variety Value" temporary)
    var
        VRTValue: Record "NPR Variety Value";
    begin
        if IsVarietyTypeUsed(VarietyType) then begin
            VRTValue.SetRange(Type, VarietyType);
            VRTValue.SetRange(Table, VarietyTable);
            if VRTValue.FindSet() then
                repeat
                    TMPVRTValue := VRTValue;
                    TMPVRTValue.Insert();
                until VRTValue.Next() = 0;
        end else
            InsertEmptyRecord(TMPVRTValue);
    end;

    local procedure LoadTmpValue(var TMPVRTValue: Record "NPR Variety Value" temporary; VarietyType: Code[20]; VarietyTable: Code[40]; ForceEmptyRecord: Boolean)
    begin
        if not IsVarietyTypeUsed(VarietyType) or (ForceEmptyRecord) then
            InsertEmptyRecord(TMPVRTValue)
        else
            InsertAllValuesInTmpTable(VarietyType, VarietyTable, TMPVRTValue); //full load is needed
    end;

    local procedure InsertEmptyRecord(var TMPVRTValue: Record "NPR Variety Value" temporary)
    begin
        TMPVRTValue.Type := '';
        TMPVRTValue.Table := '';
        TMPVRTValue.Insert();
    end;

    local procedure IsVarietyTypeUsed(VarietyType: Code[20]): Boolean
    begin
        exit(VarietyType <> '');
    end;

    local procedure LoadAllRows(var TMPVRTBuffer: Record "NPR Variety Buffer" temporary; Item: Record Item; CrossVRTNo: Option VRT1,VRT2,VRT3,VRT4)
    var
        TempVRT1: Record "NPR Variety Value" temporary;
        TempVRT2: Record "NPR Variety Value" temporary;
        TempVRT3: Record "NPR Variety Value" temporary;
        TempVRT4: Record "NPR Variety Value" temporary;
        VRT1Desc: Text[30];
        VRT2Desc: Text[30];
        VRT3Desc: Text[30];
        VRT4Desc: Text[30];
    begin
        LoadTmpValue(TempVRT1, Item."NPR Variety 1", Item."NPR Variety 1 Table", CrossVRTNo = CrossVRTNo::VRT1);
        LoadTmpValue(TempVRT2, Item."NPR Variety 2", Item."NPR Variety 2 Table", CrossVRTNo = CrossVRTNo::VRT2);
        LoadTmpValue(TempVRT3, Item."NPR Variety 3", Item."NPR Variety 3 Table", CrossVRTNo = CrossVRTNo::VRT3);
        LoadTmpValue(TempVRT4, Item."NPR Variety 4", Item."NPR Variety 4 Table", CrossVRTNo = CrossVRTNo::VRT4);

        TempVRT1.SetCurrentKey(Type, Table, "Sort Order");
        TempVRT2.SetCurrentKey(Type, Table, "Sort Order");
        TempVRT3.SetCurrentKey(Type, Table, "Sort Order");
        TempVRT4.SetCurrentKey(Type, Table, "Sort Order");
        if TempVRT1.FindSet() then
            repeat
                if TempVRT2.FindSet() then
                    repeat
                        if TempVRT3.FindSet() then
                            repeat
                                if TempVRT4.FindSet() then
                                    repeat
                                        TMPVRTBuffer.Init();
                                        TMPVRTBuffer."Variety 1 Value" := TempVRT1.Value;
                                        TMPVRTBuffer."Variety 2 Value" := TempVRT2.Value;
                                        TMPVRTBuffer."Variety 3 Value" := TempVRT3.Value;
                                        TMPVRTBuffer."Variety 4 Value" := TempVRT4.Value;
                                        TMPVRTBuffer."Variety 1 Sort Order" := TempVRT1."Sort Order";
                                        TMPVRTBuffer."Variety 2 Sort Order" := TempVRT2."Sort Order";
                                        TMPVRTBuffer."Variety 3 Sort Order" := TempVRT3."Sort Order";
                                        TMPVRTBuffer."Variety 4 Sort Order" := TempVRT4."Sort Order";
                                        TMPVRTBuffer."Item No." := Item."No.";

                                        if TempVRT1.Description = '' then
                                            VRT1Desc := CopyStr(TempVRT1.Value, 1, MaxStrLen(VRT1Desc))
                                        else
                                            VRT1Desc := TempVRT1.Description;

                                        if TempVRT2.Description = '' then
                                            VRT2Desc := CopyStr(TempVRT2.Value, 1, MaxStrLen(VRT2Desc))
                                        else
                                            VRT2Desc := TempVRT2.Description;

                                        if TempVRT3.Description = '' then
                                            VRT3Desc := CopyStr(TempVRT3.Value, 1, MaxStrLen(VRT3Desc))
                                        else
                                            VRT3Desc := TempVRT3.Description;

                                        if TempVRT4.Description = '' then
                                            VRT4Desc := CopyStr(TempVRT4.Value, 1, MaxStrLen(VRT4Desc))
                                        else
                                            VRT4Desc := TempVRT4.Description;

                                        TMPVRTBuffer.Description := CopyStr(VRT1Desc + ' ' + VRT2Desc + ' ' + VRT3Desc + ' ' + VRT4Desc, 1, MaxStrLen(TMPVRTBuffer.Description));
                                        TMPVRTBuffer.Insert();
                                    until TempVRT4.Next() = 0;
                            until TempVRT3.Next() = 0;
                    until TempVRT2.Next() = 0;
            until TempVRT1.Next() = 0;
    end;

    local procedure LoadUsedRowsCrossVRT1(var TMPVRTBuffer: Record "NPR Variety Buffer" temporary; Item: Record Item)
    var
        GetRowsCrossVariety1: Query "NPR Get Rows - Cross Variety 1";
    begin
        GetRowsCrossVariety1.SetRange(Item_No, Item."No.");
        GetRowsCrossVariety1.SetRange(Variety_2, Item."NPR Variety 2");
        GetRowsCrossVariety1.SetRange(Variety_2_Table, Item."NPR Variety 2 Table");
        GetRowsCrossVariety1.SetRange(Variety_3, Item."NPR Variety 3");
        GetRowsCrossVariety1.SetRange(Variety_3_Table, Item."NPR Variety 3 Table");
        GetRowsCrossVariety1.SetRange(Variety_4, Item."NPR Variety 4");
        GetRowsCrossVariety1.SetRange(Variety_4_Table, Item."NPR Variety 4 Table");
        GetRowsCrossVariety1.Open();

        while GetRowsCrossVariety1.Read() do begin
            TMPVRTBuffer.Init();
            TMPVRTBuffer."Item No." := Item."No.";
            TMPVRTBuffer."Variety 2 Value" := GetRowsCrossVariety1.Variety_2_Value;
            TMPVRTBuffer."Variety 3 Value" := GetRowsCrossVariety1.Variety_3_Value;
            TMPVRTBuffer."Variety 4 Value" := GetRowsCrossVariety1.Variety_4_Value;

            SetBufferValues(TMPVRTBuffer."Variety 2 Sort Order", TMPVRTBuffer.Description, GetRowsCrossVariety1.Variety_2, GetRowsCrossVariety1.Variety_2_Table, GetRowsCrossVariety1.Variety_2_Value);
            SetBufferValues(TMPVRTBuffer."Variety 3 Sort Order", TMPVRTBuffer.Description, GetRowsCrossVariety1.Variety_3, GetRowsCrossVariety1.Variety_3_Table, GetRowsCrossVariety1.Variety_3_Value);
            SetBufferValues(TMPVRTBuffer."Variety 4 Sort Order", TMPVRTBuffer.Description, GetRowsCrossVariety1.Variety_4, GetRowsCrossVariety1.Variety_4_Table, GetRowsCrossVariety1.Variety_4_Value);
            TMPVRTBuffer.Insert();
        end;
    end;

    local procedure LoadUsedRowsCrossVRT2(var TMPVRTBuffer: Record "NPR Variety Buffer" temporary; Item: Record Item)
    var
        GetRowsCrossVariety2: Query "NPR Get Rows - Cross Variety 2";
    begin
        GetRowsCrossVariety2.SetRange(Item_No, Item."No.");
        GetRowsCrossVariety2.SetRange(Variety_1, Item."NPR Variety 1");
        GetRowsCrossVariety2.SetRange(Variety_1_Table, Item."NPR Variety 1 Table");
        GetRowsCrossVariety2.SetRange(Variety_3, Item."NPR Variety 3");
        GetRowsCrossVariety2.SetRange(Variety_3_Table, Item."NPR Variety 3 Table");
        GetRowsCrossVariety2.SetRange(Variety_4, Item."NPR Variety 4");
        GetRowsCrossVariety2.SetRange(Variety_4_Table, Item."NPR Variety 4 Table");

        GetRowsCrossVariety2.Open();

        while GetRowsCrossVariety2.Read() do begin
            TMPVRTBuffer.Init();
            TMPVRTBuffer."Item No." := Item."No.";
            TMPVRTBuffer."Variety 1 Value" := GetRowsCrossVariety2.Variety_1_Value;
            TMPVRTBuffer."Variety 3 Value" := GetRowsCrossVariety2.Variety_3_Value;
            TMPVRTBuffer."Variety 4 Value" := GetRowsCrossVariety2.Variety_4_Value;

            SetBufferValues(TMPVRTBuffer."Variety 1 Sort Order", TMPVRTBuffer.Description, GetRowsCrossVariety2.Variety_1, GetRowsCrossVariety2.Variety_1_Table, GetRowsCrossVariety2.Variety_1_Value);
            SetBufferValues(TMPVRTBuffer."Variety 3 Sort Order", TMPVRTBuffer.Description, GetRowsCrossVariety2.Variety_3, GetRowsCrossVariety2.Variety_3_Table, GetRowsCrossVariety2.Variety_3_Value);
            SetBufferValues(TMPVRTBuffer."Variety 4 Sort Order", TMPVRTBuffer.Description, GetRowsCrossVariety2.Variety_4, GetRowsCrossVariety2.Variety_4_Table, GetRowsCrossVariety2.Variety_4_Value);
            TMPVRTBuffer.Insert();
        end;
    end;

    local procedure LoadUsedRowsCrossVRT3(var TMPVRTBuffer: Record "NPR Variety Buffer" temporary; Item: Record Item)
    var
        GetRowsCrossVariety3: Query "NPR Get Rows - Cross Variety 3";
    begin
        GetRowsCrossVariety3.SetRange(Item_No, Item."No.");
        GetRowsCrossVariety3.SetRange(Variety_1, Item."NPR Variety 1");
        GetRowsCrossVariety3.SetRange(Variety_1_Table, Item."NPR Variety 1 Table");
        GetRowsCrossVariety3.SetRange(Variety_2, Item."NPR Variety 2");
        GetRowsCrossVariety3.SetRange(Variety_2_Table, Item."NPR Variety 2 Table");
        GetRowsCrossVariety3.SetRange(Variety_4, Item."NPR Variety 4");
        GetRowsCrossVariety3.SetRange(Variety_4_Table, Item."NPR Variety 4 Table");

        GetRowsCrossVariety3.Open();

        while GetRowsCrossVariety3.Read() do begin
            TMPVRTBuffer.Init();
            TMPVRTBuffer."Item No." := Item."No.";
            TMPVRTBuffer."Variety 1 Value" := GetRowsCrossVariety3.Variety_1_Value;
            TMPVRTBuffer."Variety 2 Value" := GetRowsCrossVariety3.Variety_2_Value;
            TMPVRTBuffer."Variety 4 Value" := GetRowsCrossVariety3.Variety_4_Value;

            SetBufferValues(TMPVRTBuffer."Variety 1 Sort Order", TMPVRTBuffer.Description, GetRowsCrossVariety3.Variety_1, GetRowsCrossVariety3.Variety_1_Table, GetRowsCrossVariety3.Variety_1_Value);
            SetBufferValues(TMPVRTBuffer."Variety 2 Sort Order", TMPVRTBuffer.Description, GetRowsCrossVariety3.Variety_2, GetRowsCrossVariety3.Variety_2_Table, GetRowsCrossVariety3.Variety_2_Value);
            SetBufferValues(TMPVRTBuffer."Variety 4 Sort Order", TMPVRTBuffer.Description, GetRowsCrossVariety3.Variety_4, GetRowsCrossVariety3.Variety_4_Table, GetRowsCrossVariety3.Variety_4_Value);
            TMPVRTBuffer.Insert();
        end;
    end;

    local procedure LoadUsedRowsCrossVRT4(var TMPVRTBuffer: Record "NPR Variety Buffer" temporary; Item: Record Item)
    var
        GetRowsCrossVariety4: Query "NPR Get Rows - Cross Variety 4";
    begin
        GetRowsCrossVariety4.SetRange(Item_No, Item."No.");
        GetRowsCrossVariety4.SetRange(Variety_1, Item."NPR Variety 1");
        GetRowsCrossVariety4.SetRange(Variety_1_Table, Item."NPR Variety 1 Table");
        GetRowsCrossVariety4.SetRange(Variety_2, Item."NPR Variety 2");
        GetRowsCrossVariety4.SetRange(Variety_2_Table, Item."NPR Variety 2 Table");
        GetRowsCrossVariety4.SetRange(Variety_3, Item."NPR Variety 3");
        GetRowsCrossVariety4.SetRange(Variety_3_Table, Item."NPR Variety 3 Table");

        GetRowsCrossVariety4.Open();

        while GetRowsCrossVariety4.Read() do begin
            TMPVRTBuffer.Init();
            TMPVRTBuffer."Item No." := Item."No.";
            TMPVRTBuffer."Variety 1 Value" := GetRowsCrossVariety4.Variety_1_Value;
            TMPVRTBuffer."Variety 2 Value" := GetRowsCrossVariety4.Variety_2_Value;
            TMPVRTBuffer."Variety 3 Value" := GetRowsCrossVariety4.Variety_3_Value;

            SetBufferValues(TMPVRTBuffer."Variety 1 Sort Order", TMPVRTBuffer.Description, GetRowsCrossVariety4.Variety_1, GetRowsCrossVariety4.Variety_1_Table, GetRowsCrossVariety4.Variety_1_Value);
            SetBufferValues(TMPVRTBuffer."Variety 2 Sort Order", TMPVRTBuffer.Description, GetRowsCrossVariety4.Variety_2, GetRowsCrossVariety4.Variety_2_Table, GetRowsCrossVariety4.Variety_2_Value);
            SetBufferValues(TMPVRTBuffer."Variety 3 Sort Order", TMPVRTBuffer.Description, GetRowsCrossVariety4.Variety_3, GetRowsCrossVariety4.Variety_3_Table, GetRowsCrossVariety4.Variety_3_Value);
            TMPVRTBuffer.Insert();
        end;
    end;

    local procedure SetBufferValues(var BufferSortOrder: Integer; var BufferDescription: Text[92]; VarietyType: Code[10]; VarietyTable: Code[40]; VarietyValue: Code[50])
    var
        VRTValue: Record "NPR Variety Value";
    begin
        if (VarietyType = '') or (VarietyTable = '') or (VarietyValue = '') then
            exit;

        if not VRTValue.Get(VarietyType, VarietyTable, VarietyValue) then
            exit;

        BufferSortOrder := VRTValue."Sort Order";
        if BufferDescription <> '' then
            BufferDescription += ' ';

        if VRTValue.Description = '' then
            BufferDescription += VRTValue.Value
        else
            BufferDescription += VRTValue.Description;
    end;

    local procedure LoadUsedValuesVRT1(Item: Record Item; var TMPVRTValue: Record "NPR Variety Value" temporary)
    var
        Variety1UsedValues: Query "NPR Variety 1 Used Values";
    begin
        Variety1UsedValues.SetRange(Item_No, Item."No.");
        Variety1UsedValues.SetRange(Variety_1, Item."NPR Variety 1");
        Variety1UsedValues.SetRange(Variety_1_Table, Item."NPR Variety 1 Table");
        Variety1UsedValues.Open();

        while Variety1UsedValues.Read() do begin
            TMPVRTValue.Init();
            TMPVRTValue.Type := Variety1UsedValues.Variety_1;
            TMPVRTValue.Table := Variety1UsedValues.Variety_1_Table;
            TMPVRTValue.Value := Variety1UsedValues.Variety_1_Value;
            TMPVRTValue.Insert();
        end;
    end;

    local procedure LoadUsedValuesVRT2(Item: Record Item; var TMPVRTValue: Record "NPR Variety Value" temporary)
    var
        Variety2UsedValues: Query "NPR Variety 2 Used Values";
    begin
        Variety2UsedValues.SetRange(Item_No, Item."No.");
        Variety2UsedValues.SetRange(Variety_2, Item."NPR Variety 2");
        Variety2UsedValues.SetRange(Variety_2_Table, Item."NPR Variety 2 Table");
        Variety2UsedValues.Open();

        while Variety2UsedValues.Read() do begin
            TMPVRTValue.Init();
            TMPVRTValue.Type := Variety2UsedValues.Variety_2;
            TMPVRTValue.Table := Variety2UsedValues.Variety_2_Table;
            TMPVRTValue.Value := Variety2UsedValues.Variety_2_Value;
            TMPVRTValue.Insert();
        end;
    end;

    local procedure LoadUsedValuesVRT3(Item: Record Item; var TMPVRTValue: Record "NPR Variety Value" temporary)
    var
        Variety3UsedValues: Query "NPR Variety 3 Used Values";
    begin
        Variety3UsedValues.SetRange(Item_No, Item."No.");
        Variety3UsedValues.SetRange(Variety_3, Item."NPR Variety 3");
        Variety3UsedValues.SetRange(Variety_3_Table, Item."NPR Variety 3 Table");
        Variety3UsedValues.Open();

        while Variety3UsedValues.Read() do begin
            TMPVRTValue.Init();
            TMPVRTValue.Type := Variety3UsedValues.Variety_3;
            TMPVRTValue.Table := Variety3UsedValues.Variety_3_Table;
            TMPVRTValue.Value := Variety3UsedValues.Variety_3_Value;
            TMPVRTValue.Insert();
        end;
    end;

    local procedure LoadUsedValuesVRT4(Item: Record Item; var TMPVRTValue: Record "NPR Variety Value" temporary)
    var
        Variety4UsedValues: Query "NPR Variety 4 Used Values";
    begin
        Variety4UsedValues.SetRange(Item_No, Item."No.");
        Variety4UsedValues.SetRange(Variety_4, Item."NPR Variety 4");
        Variety4UsedValues.SetRange(Variety_4_Table, Item."NPR Variety 4 Table");

        Variety4UsedValues.Open();

        while Variety4UsedValues.Read() do begin
            TMPVRTValue.Init();
            TMPVRTValue.Type := Variety4UsedValues.Variety_4;
            TMPVRTValue.Table := Variety4UsedValues.Variety_4_Table;
            TMPVRTValue.Value := Variety4UsedValues.Variety_4_Value;
            TMPVRTValue.Insert();
        end;
    end;
}

