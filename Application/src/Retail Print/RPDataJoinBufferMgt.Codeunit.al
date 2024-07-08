codeunit 6014558 "NPR RP Data Join Buffer Mgt."
{
    Access = Internal;

    var
        TempBuffer: Record "NPR RP Data Join Buffer" temporary;
        TempRecIDBuffer: Record "NPR RP DataJoin Rec.ID Buffer" temporary;
        _FieldMap: Dictionary of [Text, Dictionary of [Integer, Boolean]];
        _CurrentDataItemName: Text;
        _DecimalRounding: Option "2","3","4","5";

    procedure ProcessDataJoin(var RecRefIn: RecordRef; Template: Code[20]): Boolean;
    var
        ParentDataItem: Record "NPR RP Data Items";
        RecRef: RecordRef;
    begin
        ParentDataItem.SetCurrentKey(Code, Level, "Parent Line No.", "Line No.");
        ParentDataItem.SetRange(Code, Template);
        ParentDataItem.SetRange(Level, 0);
        ParentDataItem.SetRange("Parent Line No.", 0);
        if not ParentDataItem.FindSet() then
            exit(false);

        if RecRefIn.IsEmpty() then
            exit(false); //Implicitly skip if filters on first data item has no match.

        if not (ParentDataItem."Table ID" = RecRefIn.Number) then
            ParentDataItem.TestField("Table ID", RecRefIn.Number);

        SetFieldMapping(Template, ParentDataItem);

        repeat
            if RecRef.Number = 0 then begin
                RecRef := RecRefIn;
            end else begin
                RecRef.Close();
                RecRef.Open(ParentDataItem."Table ID");
            end;

            if not ProcessDataItem(ParentDataItem, RecRef) then begin
                TempBuffer.DeleteAll();
                ClearAll();
                exit(false);
            end;
        until ParentDataItem.Next() = 0;

        exit(true);
    end;

    local procedure ProcessDataItem(ParentDataItem: Record "NPR RP Data Items"; var ParentRecRef: RecordRef): Boolean
    var
        ChildDataItems: Record "NPR RP Data Items";
        ChildRecRef: RecordRef;
        DataProcessed: Boolean;
        TempDistinctValueList: Record "NPR Retail List" temporary;
        FieldValue: Integer;
        Itt: Integer;
        StopIterating: Boolean;
    begin
        if not ApplyIterationType(ParentDataItem, ParentRecRef, FieldValue) then
            exit(ShouldProcessingContinue(ParentDataItem, false));

        if (ParentDataItem."Iteration Type" = ParentDataItem."Iteration Type"::"Field Value") and (FieldValue < 1) then
            exit(true);

        repeat
            if TestConstraint(ParentDataItem, ParentRecRef) and TestDistinct(ParentDataItem, ParentRecRef, TempDistinctValueList) then begin
                DataProcessed := true;
                FillRecord(ParentRecRef, ParentDataItem);

                ChildDataItems.SetCurrentKey(Code, Level, "Parent Line No.", "Line No.");
                ChildDataItems.SetRange(Code, ParentDataItem.Code);
                ChildDataItems.SetRange(Level, ParentDataItem.Level + 1);
                ChildDataItems.SetRange("Parent Line No.", ParentDataItem."Line No.");

                if ChildDataItems.FindSet() then
                    repeat
                        SetupTableJoin(ParentDataItem, ChildDataItems, ParentRecRef, ChildRecRef);
                        if not ProcessDataItem(ChildDataItems, ChildRecRef) then
                            exit(false);
                        ChildRecRef.Close();
                    until ChildDataItems.Next() = 0;
            end;

            Itt += 1;

            if ParentDataItem."Iteration Type" = ParentDataItem."Iteration Type"::"Field Value" then
                StopIterating := FieldValue = Itt
            else
                StopIterating := ParentRecRef.Next() = 0;
        until StopIterating;

        exit(ShouldProcessingContinue(ParentDataItem, DataProcessed));
    end;

    local procedure FillRecord(var RecRef: RecordRef; ParentDataItem: Record "NPR RP Data Items")
    var
        FieldRef: FieldRef;
        FieldList: Dictionary of [Integer, Boolean];
        FieldId: Integer;
    begin
        if not _FieldMap.Get(ParentDataItem.Name, FieldList) then
            exit;

        TempBuffer."Unique Record No." += 1;
        foreach FieldId in FieldList.Keys() do begin

            TempBuffer."Field No." := FieldId;
            TempBuffer."Join Level" := ParentDataItem.Level;
            TempBuffer."Data Item Name" := ParentDataItem.Name;
            if FieldId > 0 then begin
                FieldRef := RecRef.Field(FieldId);
                if UpperCase(Format(FieldRef.Class)) = 'FLOWFIELD' then
                    FieldRef.CalcField();

                if UpperCase(Format(FieldRef.Type)) = 'DECIMAL' then
                    case _DecimalRounding of
                        _DecimalRounding::"2":
                            TempBuffer.Value := Format(FieldRef.Value, 0, '<Precision,2:2><Standard Format,2>');
                        _DecimalRounding::"3":
                            TempBuffer.Value := Format(FieldRef.Value, 0, '<Precision,3:3><Standard Format,2>');
                        _DecimalRounding::"4":
                            TempBuffer.Value := Format(FieldRef.Value, 0, '<Precision,4:4><Standard Format,2>');
                        _DecimalRounding::"5":
                            TempBuffer.Value := Format(FieldRef.Value, 0, '<Precision,5:5><Standard Format,2>');
                    end
                else
                    TempBuffer.Value := Format(FieldRef.Value);
            end else
                Clear(TempBuffer.Value);
            TempBuffer.Insert();
        end;

        TempRecIDBuffer."Unique Record No." := TempBuffer."Unique Record No.";
        TempRecIDBuffer."Buffer Record ID" := RecRef.RecordId;
        TempRecIDBuffer.Insert();
    end;

    local procedure ApplyIterationType(DataItem: Record "NPR RP Data Items"; RecRef: RecordRef; var FieldValueOut: Integer): Boolean
    var
        FieldNoText: Text;
        FieldNo: Integer;
        FieldRef: FieldRef;
    begin
        if DataItem."Key ID" > 0 then
            RecRef.CurrentKeyIndex(DataItem."Key ID");

        if DataItem."Sort Order" > 0 then
            RecRef.Ascending(DataItem."Sort Order" = DataItem."Sort Order"::Ascending);

        case DataItem."Iteration Type" of
            DataItem."Iteration Type"::"Distinct Values",
          DataItem."Iteration Type"::" ":
                exit(RecRef.FindSet());

            DataItem."Iteration Type"::First:
                if RecRef.FindFirst() then begin
                    RecRef.SetRecFilter();
                    exit(true);
                end else begin
                    exit(false);
                end;

            DataItem."Iteration Type"::Last:
                if RecRef.FindLast() then begin
                    RecRef.SetRecFilter();
                    exit(true);
                end else begin
                    exit(false);
                end;

            DataItem."Iteration Type"::Total:
                begin
                    if RecRef.FindFirst() then; //Attempt fill of non-totalled fields with first record of set to allow printing of these as well.

                    foreach FieldNoText in DataItem."Total Fields".Split(',') do begin
                        Evaluate(FieldNo, FieldNoText);
                        FieldRef := RecRef.Field(FieldNo);
                        if not FieldRef.CalcSum() then
                            exit(false);
                    end;
                    RecRef.SetRecFilter();
                    exit(true);
                end;

            DataItem."Iteration Type"::"Field Value":
                begin
                    if RecRef.FindFirst() then begin
                        RecRef.SetRecFilter();
                    end else begin
                        exit(false);
                    end;

                    FieldValueOut := RecRef.Field(DataItem."Field ID").Value;
                    exit(true);
                end;
        end;
    end;

    local procedure SetupTableJoin(ParentRecord: Record "NPR RP Data Items"; ChildRecord: Record "NPR RP Data Items"; var ParentRecRef: RecordRef; var ChildRecRef: RecordRef)
    var
        DataItemLinks: Record "NPR RP Data Item Links";
        ParentFieldRef: FieldRef;
        ChildFieldRef: FieldRef;
        DataItemLinkFailedErr: Label 'System was not able to apply print template data item link at %1 due to the following error: %2', Comment = '%1 - data item link record ID, %2 - error text';
    begin
        if ChildRecRef.Number = 0 then //If not OPEN already
            ChildRecRef.Open(ChildRecord."Table ID");

        DataItemLinks.SetRange("Data Item Code", ParentRecord.Code);
        if ChildRecord.Level = 0 then
            DataItemLinks.SetRange("Parent Line No.", 0)
        else
            DataItemLinks.SetRange("Parent Line No.", ParentRecord."Line No.");
        DataItemLinks.SetRange("Child Line No.", ChildRecord."Line No.");
        DataItemLinks.SetRange("Parent Table ID", ParentRecRef.Number);
        DataItemLinks.SetRange("Table ID", ChildRecRef.Number);
        if DataItemLinks.FindSet() then
            repeat
                if DataItemLinks."Link On" = DataItemLinks."Link On"::Field then
                    ChildFieldRef := ChildRecRef.Field(DataItemLinks."Field ID")
                else
                    Clear(ChildFieldRef);
                case DataItemLinks."Filter Type" of
                    DataItemLinks."Filter Type"::TableLink:
                        begin
                            if DataItemLinks."Parent Link On" = DataItemLinks."Parent Link On"::Field then
                                ParentFieldRef := ParentRecRef.Field(DataItemLinks."Parent Field ID")
                            else
                                Clear(ParentFieldRef);
                            ClearLastError();
                            if not SetLinkFilter(DataItemLinks."Parent Link On", ParentRecRef, ParentFieldRef, DataItemLinks."Link On", ChildRecRef, ChildFieldRef, DataItemLinks."Link Type") then
                                Error(DataItemLinkFailedErr, DataItemLinks.RecordId(), GetLastErrorText());
                        end;
                    DataItemLinks."Filter Type"::"Fixed Filter":
                        ChildFieldRef.SetFilter(DataItemLinks."Filter Value");
                end;
            until DataItemLinks.Next() = 0;
    end;

    local procedure TestConstraint(DataItem: Record "NPR RP Data Items"; var RecRefIn: RecordRef) Result: Boolean
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        DataItemConstraint: Record "NPR RP Data Item Constr.";
        DataItemConstraintLinks: Record "NPR RP Data Item Constr. Links";
        DataItemFieldRef: FieldRef;
        DataItemConstraintLinkFailedErr: Label 'System was not able to apply print template data item constraint link at %1 due to the following error: %2', Comment = '%1 - data item constraint link record ID, %2 - error text';
    begin
        if (RecRefIn.Number = 0) then
            exit(true);

        Result := true;

        DataItemConstraint.SetRange("Data Item Code", DataItem.Code);
        DataItemConstraint.SetRange("Data Item Line No.", DataItem."Line No.");
        if DataItemConstraint.FindSet() then
            repeat
                RecRef.Open(DataItemConstraint."Table ID");
                DataItemConstraintLinks.SetRange("Data Item Code", DataItemConstraint."Data Item Code");
                DataItemConstraintLinks.SetRange("Constraint Line No.", DataItemConstraint."Line No.");
                DataItemConstraintLinks.FindSet();
                repeat
                    if DataItemConstraintLinks."Link On" = DataItemConstraintLinks."Link On"::Field then
                        FieldRef := RecRef.Field(DataItemConstraintLinks."Field ID")
                    else
                        Clear(FieldRef);
                    case DataItemConstraintLinks."Filter Type" of
                        DataItemConstraintLinks."Filter Type"::TableLink:
                            begin
                                if DataItemConstraintLinks."Data Item Link On" = DataItemConstraintLinks."Data Item Link On"::Field then
                                    DataItemFieldRef := RecRefIn.Field(DataItemConstraintLinks."Data Item Field ID")
                                else
                                    Clear(DataItemFieldRef);
                                ClearLastError();
                                if not SetLinkFilter(DataItemConstraintLinks."Data Item Link On", RecRefIn, DataItemFieldRef, DataItemConstraintLinks."Link On", RecRef, FieldRef, DataItemConstraintLinks."Link Type") then
                                    Error(DataItemConstraintLinkFailedErr, DataItemConstraintLinks.RecordId(), GetLastErrorText());
                            end;
                        DataItemConstraintLinks."Filter Type"::"Fixed Filter":
                            FieldRef.SetFilter(DataItemConstraintLinks."Filter Value");
                    end;
                until DataItemConstraintLinks.Next() = 0;

                case DataItemConstraint."Constraint Type" of
                    DataItemConstraint."Constraint Type"::IsEmpty:
                        Result := Result and RecRef.IsEmpty();
                    DataItemConstraint."Constraint Type"::IsNotEmpty:
                        Result := Result and (not RecRef.IsEmpty());
                end;
                RecRef.Close();
            until (DataItemConstraint.Next() = 0) or (not Result);

        exit(Result);
    end;

    local procedure TestDistinct(DataItem: Record "NPR RP Data Items"; var RecRefIn: RecordRef; var tmpDistinctValueList: Record "NPR Retail List" temporary): Boolean
    var
        FieldRef: FieldRef;
    begin
        if DataItem."Iteration Type" <> DataItem."Iteration Type"::"Distinct Values" then
            exit(true);

        FieldRef := RecRefIn.Field(DataItem."Field ID");
        tmpDistinctValueList.SetRange(Value, Format(FieldRef.Value, 0, 9));
        if not tmpDistinctValueList.IsEmpty then
            exit(false);

        tmpDistinctValueList.SetRange(Value);
        if tmpDistinctValueList.FindLast() then;
        tmpDistinctValueList.Number += 1;
        tmpDistinctValueList.Value := Format(FieldRef.Value, 0, 9);
        tmpDistinctValueList.Insert();
        exit(true);
    end;

    [TryFunction]
    local procedure SetLinkFilter(ParentLinkOn: Enum "NPR RP Data Item Link On"; ParentRecRef: RecordRef; var ParentFieldRef: FieldRef; ChildLinkOn: Enum "NPR RP Data Item Link On"; var ChildRecRef: RecordRef; var ChildFieldRef: FieldRef; LinkType: Enum "NPR RP Data Item Link Type")
    var
        RecID: RecordId;
        PositionString: Text;
        RecIDFound: Boolean;
        ParentLinkedTxt: Label 'Parent,Linked';
        WrontFieldTypeErr: Label '%1 table field must be of type "%2"', Comment = '%1 - Parent/Linked, %2 - required field type';
        WrontRecordIdTableErr: Label 'Parent field %1 contains a record id of table %2. Required table is %3.', Comment = '%1 - field caption, %2 - current table No., %3 - required table No.';
    begin
        if ParentLinkOn = ParentLinkOn::"Field" then
            if ParentFieldRef.Class() = FieldClass::FlowField then
                ParentFieldRef.CalcField();

        if (ParentLinkOn <> ParentLinkOn::"Field") or (ChildLinkOn <> ChildLinkOn::"Field") then begin
            case true of
                ParentLinkOn = ParentLinkOn::Position:
                    begin
                        ChildFieldRef.SetRange(ParentRecRef.GetPosition(false));
                    end;
                ParentLinkOn = ParentLinkOn::"Record ID":
                    begin
                        if ChildFieldRef.Type() <> FieldType::RecordId then
                            Error(WrontFieldTypeErr, SelectStr(2, ParentLinkedTxt), Format(FieldType::RecordId));
                        ChildFieldRef.SetRange(ParentRecRef.RecordId());
                    end;
                ChildLinkOn = ChildLinkOn::Position:
                    begin
                        if ParentFieldRef.Class() = FieldClass::FlowFilter then
                            PositionString := ParentFieldRef.GetFilter()
                        else
                            PositionString := Format(ParentFieldRef.Value);
                        if PositionString = '' then
                            Clear(ChildRecRef)  //init primary key fields to default values
                        else
                            ChildRecRef.SetPosition(ParentFieldRef.Value);
                        ChildRecRef.SetRecFilter();
                    end;
                ChildLinkOn = ChildLinkOn::"Record ID":
                    begin
                        if ParentFieldRef.Type() <> FieldType::RecordId then
                            Error(WrontFieldTypeErr, SelectStr(1, ParentLinkedTxt), Format(FieldType::RecordId));
                        if (ParentFieldRef.Class() = FieldClass::FlowFilter) then begin
                            if ParentFieldRef.GetFilter() <> '' then begin
                                RecID := ParentFieldRef.GetRangeMax();
                                RecIDFound := true;
                            end;
                        end else
                            if Format(ParentFieldRef.Value()) <> '' then begin
                                Evaluate(RecID, ParentFieldRef.Value());
                                RecIDFound := true;
                            end;
                        if RecIDFound then begin
                            if RecID.TableNo() <> ChildRecRef.Number() then
                                Error(WrontRecordIdTableErr, ParentFieldRef.Caption(), RecID.TableNo(), ChildRecRef.Number());
                            ChildRecRef := RecID.GetRecord();
                        end else
                            Clear(ChildRecRef);  //init primary key fields to default values
                        ChildRecRef.SetRecFilter();
                    end;
            end;
            exit;
        end;

        if ParentFieldRef.Class() = FieldClass::FlowFilter then begin
            ChildFieldRef.SetFilter(ParentFieldRef.GetFilter());
            exit;
        end;

        case LinkType of
            LinkType::"=":
                ChildFieldRef.SetFilter('=%1', ParentFieldRef.Value());
            LinkType::">":
                ChildFieldRef.SetFilter('>%1', ParentFieldRef.Value());
            LinkType::"<":
                ChildFieldRef.SetFilter('<%1', ParentFieldRef.Value());
            LinkType::"<>":
                ChildFieldRef.SetFilter('<>%1', ParentFieldRef.Value());
        end;
    end;

    procedure SetDecimalRounding(DecimalRoundingIn: Option "2","3","4","5")
    begin
        _DecimalRounding := DecimalRoundingIn;
    end;

    local procedure SetFieldMapping(Template: Code[20]; ParentDataItem: Record "NPR RP Data Items")
    var
        RPTemplateLine: Record "NPR RP Template Line";
        RecRef: RecordRef;
        KeyRef: KeyRef;
        FieldRef: FieldRef;
    begin
        AddFieldToMap(ParentDataItem.Name, 0);

        RPTemplateLine.SetRange("Template Code", Template);
        RPTemplateLine.SetFilter(Type, '%1|%2', RPTemplateLine.Type::Data, RPTemplateLine.Type::Loop);
        RPTemplateLine.SetFilter("Data Item Name", '<>%1', '');
        if RPTemplateLine.FindSet() then
            repeat
                RecRef.Open(RPTemplateLine."Data Item Table");
                KeyRef := RecRef.KeyIndex(RecRef.CurrentKeyIndex());
                FieldRef := KeyRef.FieldIndex(1);
                AddFieldToMap(RPTemplateLine."Data Item Name", FieldRef.Number);
                Clear(RecRef);
                AddFieldToMap(RPTemplateLine."Data Item Name", RPTemplateLine.Field);
                if RPTemplateLine."Field 2" > 0 then
                    AddFieldToMap(RPTemplateLine."Data Item Name", RPTemplateLine."Field 2");
            until RPTemplateLine.Next() = 0;
    end;

    procedure AddFieldToMap(DataItemName: Text; FieldNumber: Integer)
    var
        FieldSet: Dictionary of [Integer, Boolean];
    begin
        if _FieldMap.Get(DataItemName, FieldSet) then;
        if FieldSet.ContainsKey(FieldNumber) then
            exit;
        FieldSet.Add(FieldNumber, false);
        _FieldMap.Set(DataItemName, FieldSet);
    end;

    local procedure ShouldProcessingContinue(DataItem: Record "NPR RP Data Items"; DataFound: Boolean): Boolean
    begin
        if DataFound and DataItem."Skip Template If Not Empty" then
            exit(false);
        if (not DataFound) and DataItem."Skip Template If Empty" then
            exit(false);
        exit(true);
    end;

    #region Buffer Accessors
    procedure DeleteSet()
    begin
        TempBuffer.DeleteAll();
    end;

    procedure FindBufferSet(DataItemName: Text; var CurrentRecNo: Integer) Result: Boolean
    begin
        TempBuffer.SetRange("Data Item Name", DataItemName);
        Result := TempBuffer.FindFirst();
        if Result then
            CurrentRecNo := TempBuffer."Unique Record No.";
        TempBuffer.SetRange("Data Item Name");

        _CurrentDataItemName := DataItemName;
    end;

    procedure FindSubset(CurrentRecNo: Integer; UpperBound: Integer) NewUpperBound: Integer
    begin
        if CurrentRecNo = UpperBound then
            exit(NewUpperBound);

        TempBuffer.SetRange("Join Level", TempBuffer."Join Level");

        if UpperBound = 0 then
            TempBuffer.SetFilter("Unique Record No.", '>%1', CurrentRecNo)
        else
            TempBuffer.SetRange("Unique Record No.", CurrentRecNo + 1, UpperBound);

        if TempBuffer.FindFirst() then
            NewUpperBound := TempBuffer."Unique Record No." - 1
        else
            NewUpperBound := 0;

        TempBuffer.SetRange("Join Level");
        TempBuffer.SetRange("Unique Record No.");
    end;

    procedure GetField(FieldNo: Integer; DataItemName: Text) Value: Text
    begin
        TempBuffer.SetRange("Data Item Name", DataItemName);
        TempBuffer.SetRange("Field No.", FieldNo);
        if TempBuffer.FindFirst() then
            Value := TempBuffer.Value;
        TempBuffer.SetRange("Data Item Name");
        TempBuffer.SetRange("Field No.");
        exit(Value);
    end;

    procedure GetFieldFromRecordRootNo(FieldNo: Integer; RootNo: Integer; DataItemName: Text) Value: Text
    var
        ExistingFilter: Text;
    begin
        if RootNo > 1 then begin
            ExistingFilter := TempBuffer.GetView();
            if not (SetRootSubsetFilter(RootNo)) then
                exit('');
        end;

        Value := GetField(FieldNo, DataItemName);

        if RootNo > 1 then
            TempBuffer.SetView(ExistingFilter);
    end;

    procedure GetFieldFromRecordIterationNo(FieldNo: Integer; IterationNo: Integer; DataItemName: Text) Value: Text
    var
        ExistingFilter: Text;
    begin
        ExistingFilter := TempBuffer.GetView();

        if not (SetIterationSubsetFilter(IterationNo, DataItemName)) then
            exit('');
        Value := GetField(FieldNo, DataItemName);

        TempBuffer.SetView(ExistingFilter);
    end;

    procedure GetRecID(DataItemName: Text; var RecIDOut: RecordID) Result: Boolean
    begin
        if (DataItemName = '') then
            exit(false);

        TempBuffer.SetRange("Data Item Name", DataItemName);
        Result := TempBuffer.FindFirst();
        if Result then begin
            TempRecIDBuffer.Get(TempBuffer."Unique Record No.");
            RecIDOut := TempRecIDBuffer."Buffer Record ID";
        end;
        TempBuffer.SetRange("Data Item Name");
    end;

    procedure GetRecIDFromRecordRootNo(RootNo: Integer; DataItemName: Text; var RecIDOut: RecordID) Result: Boolean
    var
        ExistingFilter: Text;
    begin
        if RootNo > 1 then begin
            ExistingFilter := TempBuffer.GetView();
            SetRootSubsetFilter(RootNo);
        end;

        Result := GetRecID(DataItemName, RecIDOut);

        if RootNo > 1 then
            TempBuffer.SetView(ExistingFilter);
    end;

    procedure GetRecIDFromRecordIterationNo(IterationNo: Integer; DataItemName: Text; var RecIDOut: RecordID) Result: Boolean
    var
        ExistingFilter: Text;
    begin
        ExistingFilter := TempBuffer.GetView();

        SetIterationSubsetFilter(IterationNo, DataItemName);
        Result := GetRecID(DataItemName, RecIDOut);

        TempBuffer.SetView(ExistingFilter);
    end;

    procedure GetBuffer(var BufferOut: Record "NPR RP Data Join Buffer" temporary)
    begin
        BufferOut.Copy(TempBuffer, true);
    end;

    procedure NextRecord(DataItemName: Text; var CurrentRecNo: Integer; UpperBound: Integer) Result: Boolean
    begin
        if CurrentRecNo = UpperBound then
            exit(false);

        TempBuffer.SetRange("Data Item Name", DataItemName);
        if UpperBound = 0 then
            TempBuffer.SetFilter("Unique Record No.", '>%1', CurrentRecNo)
        else
            TempBuffer.SetRange("Unique Record No.", CurrentRecNo + 1, UpperBound);
        Result := TempBuffer.FindFirst();
        if Result then
            CurrentRecNo := TempBuffer."Unique Record No.";
        TempBuffer.SetRange("Data Item Name");
        TempBuffer.SetRange("Unique Record No.");
    end;

    procedure SetBounds(LowerBound: Integer; UpperBound: Integer)
    begin
        if (UpperBound = LowerBound) and (UpperBound > 0) then
            TempBuffer.SetRange("Unique Record No.", LowerBound)
        else
            if (UpperBound = 0) and (LowerBound > 0) then
                TempBuffer.SetFilter("Unique Record No.", '>=%1', LowerBound)
            else
                if (UpperBound > 0) then
                    TempBuffer.SetRange("Unique Record No.", LowerBound, UpperBound)
                else
                    TempBuffer.SetRange("Unique Record No.");
    end;

    local procedure SetRootSubsetFilter(RootNo: Integer): Boolean
    var
        TempRecordNo: Integer;
        TempUpperBound: Integer;
        i: Integer;
    begin
        FindBufferSet(_CurrentDataItemName, TempRecordNo); //Set cursor back to dataitem line
        for i := 1 to RootNo - 1 do
            if not NextRecord(_CurrentDataItemName, TempRecordNo, 0) then
                exit(false);
        FindSubset(TempRecordNo, TempUpperBound);
        SetBounds(TempRecordNo, 0);

        exit(true);
    end;

    local procedure SetIterationSubsetFilter(IterationNo: Integer; DataItemName: Text): Boolean
    var
        TempRecordNo: Integer;
        i: Integer;
    begin
        TempBuffer.Reset();
        if not (FindBufferSet(DataItemName, TempRecordNo)) then
            exit(false);
        if IterationNo > 1 then
            for i := 1 to IterationNo - 1 do
                if not NextRecord(DataItemName, TempRecordNo, 0) then
                    exit(false);
        TempBuffer.SetRange("Unique Record No.", TempRecordNo);

        exit(true);
    end;
    #endregion
}

