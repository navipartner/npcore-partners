codeunit 6014558 "NPR RP Data Join Buffer Mgt."
{
    Access = Internal;
    var
        TempBuffer: Record "NPR RP Data Join Buffer" temporary;
        TempRecIDBuffer: Record "NPR RP DataJoin Rec.ID Buffer" temporary;
        TempFieldMap: Record "NPR RP Data Join Field Map" temporary;
        CurrentDataItemName: Text;
        Error_InvalidTable: Label 'Invalid table was passed to template %1. It was expecting a table with ID %2';
        DecimalRounding: Option "2","3","4","5";

    procedure ProcessDataJoin(var RecRefIn: RecordRef; Template: Code[20])
    var
        ParentDataItem: Record "NPR RP Data Items";
        First: Boolean;
        RecRef: RecordRef;
        ClosedRecRef: RecordRef;
    begin
        ParentDataItem.SetCurrentKey(Code, Level, "Parent Line No.", "Line No.");
        ParentDataItem.SetRange(Code, Template);
        ParentDataItem.SetRange(Level, 0);
        ParentDataItem.SetRange("Parent Line No.", 0);
        if ParentDataItem.FindSet() then begin
            if not (ParentDataItem."Table ID" = RecRefIn.Number) then
                Error(Error_InvalidTable, Template, ParentDataItem."Table ID");

            SetFieldMapping(Template, ParentDataItem);

            First := true;
            repeat
                if First then
                    RecRef := RecRefIn
                else
                    RecRef.Open(ParentDataItem."Table ID"); //Any other level 0 data items. These cannot be based on pre-existing filters, marks etc. since RecordRefIn parameter is only used for the first data item present.

                SetupTableJoin(ParentDataItem, ParentDataItem, ClosedRecRef, RecRef);
                if First then
                    if RecRef.IsEmpty then
                        exit; //Implicitly skip if filters on first data item has no match.

                if not ProcessDataItem(ParentDataItem, RecRef) then begin
                    DeleteSet();
                    ClearAll();
                    exit; //Skip
                end;

                First := false;
                RecRef.Close();
            until ParentDataItem.Next() = 0;
        end;
    end;

    procedure IsEmpty(): Boolean
    begin
        exit(TempBuffer.IsEmpty());
    end;

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

        CurrentDataItemName := DataItemName;
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
        FindBufferSet(CurrentDataItemName, TempRecordNo); //Set cursor back to dataitem line
        for i := 1 to RootNo - 1 do
            if not NextRecord(CurrentDataItemName, TempRecordNo, 0) then
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

    procedure AddFieldToMap(DataItemName: Text; FieldNo: Integer)
    begin
        TempFieldMap."Data Item Name" := DataItemName;
        TempFieldMap."Data Item Field No." := FieldNo;
        if TempFieldMap.Insert() then;
    end;

    procedure SetDecimalRounding(DecimalRoundingIn: Option "2","3","4","5")
    begin
        DecimalRounding := DecimalRoundingIn;
    end;

    local procedure ProcessDataItem(ParentDataItem: Record "NPR RP Data Items"; var ParentRecRef: RecordRef): Boolean
    var
        ChildDataItems: Record "NPR RP Data Items";
        ChildRecRef: RecordRef;
        StringList: List of [Text];
        String: Text;
        IntegerBuffer: Integer;
        FieldRef: FieldRef;
        DataProcessed: Boolean;
        TempDistinctValueList: Record "NPR Retail List" temporary;
        FieldValue: Integer;
        Itt: Integer;
        StopIterating: Boolean;
    begin
        if ParentDataItem."Key ID" > 0 then
            ParentRecRef.CurrentKeyIndex(ParentDataItem."Key ID");

        if ParentDataItem."Sort Order" > 0 then
            ParentRecRef.Ascending(ParentDataItem."Sort Order" = ParentDataItem."Sort Order"::Ascending);

        case ParentDataItem."Iteration Type" of
            //-NPR5.50 [353588]
            ParentDataItem."Iteration Type"::"Distinct Values",
          //+NPR5.50 [353588]
          ParentDataItem."Iteration Type"::" ":
                if not ParentRecRef.FindSet() then
                    exit(ShouldProcessingContinue(ParentDataItem, false));

            ParentDataItem."Iteration Type"::First:
                if ParentRecRef.FindFirst() then
                    ParentRecRef.SetRecFilter()
                else
                    exit(ShouldProcessingContinue(ParentDataItem, false));

            ParentDataItem."Iteration Type"::Last:
                if ParentRecRef.FindLast() then
                    ParentRecRef.SetRecFilter()
                else
                    exit(ShouldProcessingContinue(ParentDataItem, false));

            ParentDataItem."Iteration Type"::Total:
                begin
                    if ParentRecRef.FindFirst() then; //Attempt fill of non-totalled fields with first record of set to allow printing of these as well.

                    StringList := ParentDataItem."Total Fields".Split(',');
                    foreach String in StringList do begin
                        Evaluate(IntegerBuffer, String);
                        FieldRef := ParentRecRef.Field(IntegerBuffer);
                        FieldRef.CalcSum();
                    end;
                    ParentRecRef.SetRecFilter();
                end;
            //-NPR5.51 [354694]
            ParentDataItem."Iteration Type"::"Field Value":
                begin
                    if ParentRecRef.FindFirst() then
                        ParentRecRef.SetRecFilter()
                    else
                        exit(ShouldProcessingContinue(ParentDataItem, false));

                    FieldValue := ParentRecRef.Field(ParentDataItem."Field ID").Value;
                    if FieldValue < 1 then
                        exit(true);
                end;
        //+NPR5.51 [354694]
        end;

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

            //-NPR5.51 [354694]
            Itt += 1;

            if ParentDataItem."Iteration Type" = ParentDataItem."Iteration Type"::"Field Value" then
                StopIterating := FieldValue = Itt
            else
                StopIterating := ParentRecRef.Next() = 0;

        until StopIterating;
        //UNTIL ParentRecRef.Next() = 0;
        //+NPR5.51 [354694]

        exit(ShouldProcessingContinue(ParentDataItem, DataProcessed));
    end;

    local procedure FillRecord(var RecRef: RecordRef; ParentDataItem: Record "NPR RP Data Items")
    var
        FieldRef: FieldRef;
    begin
        TempFieldMap.SetRange("Data Item Name", ParentDataItem.Name);
        if TempFieldMap.FindSet() then begin
            TempBuffer."Unique Record No." += 1;
            repeat
                TempBuffer."Field No." := TempFieldMap."Data Item Field No.";
                TempBuffer."Join Level" := ParentDataItem.Level;
                TempBuffer."Data Item Name" := ParentDataItem.Name;
                if TempFieldMap."Data Item Field No." > 0 then begin
                    FieldRef := RecRef.Field(TempFieldMap."Data Item Field No.");
                    if UpperCase(Format(FieldRef.Class)) = 'FLOWFIELD' then
                        FieldRef.CalcField();

                    if UpperCase(Format(FieldRef.Type)) = 'DECIMAL' then
                        case DecimalRounding of
                            DecimalRounding::"2":
                                TempBuffer.Value := Format(FieldRef.Value, 0, '<Precision,2:2><Standard Format,2>');
                            DecimalRounding::"3":
                                TempBuffer.Value := Format(FieldRef.Value, 0, '<Precision,3:3><Standard Format,2>');
                            DecimalRounding::"4":
                                TempBuffer.Value := Format(FieldRef.Value, 0, '<Precision,4:4><Standard Format,2>');
                            DecimalRounding::"5":
                                TempBuffer.Value := Format(FieldRef.Value, 0, '<Precision,5:5><Standard Format,2>');
                        end
                    else
                        TempBuffer.Value := Format(FieldRef.Value);
                end else
                    Clear(TempBuffer.Value);
                TempBuffer.Insert();
            until TempFieldMap.Next() = 0;

            TempRecIDBuffer."Unique Record No." := TempBuffer."Unique Record No.";
            TempRecIDBuffer."Buffer Record ID" := RecRef.RecordId;
            TempRecIDBuffer.Insert();
        end;
        TempFieldMap.Reset();
    end;

    local procedure SetupTableJoin(ParentRecord: Record "NPR RP Data Items"; ChildRecord: Record "NPR RP Data Items"; var ParentRecRef: RecordRef; var ChildRecRef: RecordRef)
    var
        DataItemLinks: Record "NPR RP Data Item Links";
        ParentFieldRef: FieldRef;
        ChildFieldRef: FieldRef;
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
                ChildFieldRef := ChildRecRef.Field(DataItemLinks."Field ID");
                case DataItemLinks."Filter Type" of
                    DataItemLinks."Filter Type"::TableLink:
                        begin
                            ParentFieldRef := ParentRecRef.Field(DataItemLinks."Parent Field ID");
                            SetLinkFilter(ParentFieldRef, ChildFieldRef, DataItemLinks."Link Type");
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
                    FieldRef := RecRef.Field(DataItemConstraintLinks."Field ID");
                    case DataItemConstraintLinks."Filter Type" of
                        DataItemConstraintLinks."Filter Type"::TableLink:
                            begin
                                DataItemFieldRef := RecRefIn.Field(DataItemConstraintLinks."Data Item Field ID");
                                SetLinkFilter(DataItemFieldRef, FieldRef, DataItemConstraintLinks."Link Type");
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
        //-NPR5.50 [353588]
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
        //+NPR5.50 [353588]
    end;

    local procedure SetLinkFilter(var ParentFieldRef: FieldRef; var ChildFieldRef: FieldRef; LinkType: Option "=",">","<","<>")
    begin
        case UpperCase(Format(ParentFieldRef.Class)) of
            'FLOWFIELD':
                begin
                    ParentFieldRef.CalcField();
                    case LinkType of
                        LinkType::"=":
                            ChildFieldRef.SetFilter('=%1', ParentFieldRef.Value);
                        LinkType::">":
                            ChildFieldRef.SetFilter('>%1', ParentFieldRef.Value);
                        LinkType::"<":
                            ChildFieldRef.SetFilter('<%1', ParentFieldRef.Value);
                        LinkType::"<>":
                            ChildFieldRef.SetFilter('<>%1', ParentFieldRef.Value);
                    end;
                end;
            'FLOWFILTER':
                ChildFieldRef.SetFilter(ParentFieldRef.GetFilter);
            else begin
                    case LinkType of
                        LinkType::"=":
                            ChildFieldRef.SetFilter('=%1', ParentFieldRef.Value);
                        LinkType::">":
                            ChildFieldRef.SetFilter('>%1', ParentFieldRef.Value);
                        LinkType::"<":
                            ChildFieldRef.SetFilter('<%1', ParentFieldRef.Value);
                        LinkType::"<>":
                            ChildFieldRef.SetFilter('<>%1', ParentFieldRef.Value);
                    end;
                end;
        end;
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

    local procedure ShouldProcessingContinue(DataItem: Record "NPR RP Data Items"; DataFound: Boolean): Boolean
    begin
        if DataFound and DataItem."Skip Template If Not Empty" then
            exit(false);
        if (not DataFound) and DataItem."Skip Template If Empty" then
            exit(false);
        exit(true);
    end;
}

