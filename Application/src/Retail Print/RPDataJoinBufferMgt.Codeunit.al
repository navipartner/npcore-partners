codeunit 6014558 "NPR RP Data Join Buffer Mgt."
{
    var
        Buffer: Record "NPR RP Data Join Buffer" temporary;
        RecIDBuffer: Record "NPR RP DataJoin Rec.ID Buffer" temporary;
        FieldMap: Record "NPR RP Data Join Field Map" temporary;
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
        exit(Buffer.IsEmpty());
    end;

    procedure DeleteSet()
    begin
        Buffer.DeleteAll();
    end;

    procedure FindBufferSet(DataItemName: Text; var CurrentRecNo: Integer) Result: Boolean
    begin
        Buffer.SetRange("Data Item Name", DataItemName);
        Result := Buffer.FindFirst();
        if Result then
            CurrentRecNo := Buffer."Unique Record No.";
        Buffer.SetRange("Data Item Name");

        CurrentDataItemName := DataItemName;
    end;

    procedure FindSubset(CurrentRecNo: Integer; UpperBound: Integer) NewUpperBound: Integer
    begin
        if CurrentRecNo = UpperBound then
            exit(NewUpperBound);

        Buffer.SetRange("Join Level", Buffer."Join Level");

        if UpperBound = 0 then
            Buffer.SetFilter("Unique Record No.", '>%1', CurrentRecNo)
        else
            Buffer.SetRange("Unique Record No.", CurrentRecNo + 1, UpperBound);

        if Buffer.FindFirst() then
            NewUpperBound := Buffer."Unique Record No." - 1
        else
            NewUpperBound := 0;

        Buffer.SetRange("Join Level");
        Buffer.SetRange("Unique Record No.");
    end;

    procedure GetField(FieldNo: Integer; DataItemName: Text) Value: Text
    begin
        Buffer.SetRange("Data Item Name", DataItemName);
        Buffer.SetRange("Field No.", FieldNo);
        if Buffer.FindFirst() then
            Value := Buffer.Value;
        Buffer.SetRange("Data Item Name");
        Buffer.SetRange("Field No.");
        exit(Value);
    end;

    procedure GetFieldFromRecordRootNo(FieldNo: Integer; RootNo: Integer; DataItemName: Text) Value: Text
    var
        ExistingFilter: Text;
    begin
        if RootNo > 1 then begin
            ExistingFilter := Buffer.GetView();
            if not (SetRootSubsetFilter(RootNo)) then
                exit('');
        end;

        Value := GetField(FieldNo, DataItemName);

        if RootNo > 1 then
            Buffer.SetView(ExistingFilter);
    end;

    procedure GetFieldFromRecordIterationNo(FieldNo: Integer; IterationNo: Integer; DataItemName: Text) Value: Text
    var
        ExistingFilter: Text;
    begin
        ExistingFilter := Buffer.GetView();

        if not (SetIterationSubsetFilter(IterationNo, DataItemName)) then
            exit('');
        Value := GetField(FieldNo, DataItemName);

        Buffer.SetView(ExistingFilter);
    end;

    procedure GetRecID(DataItemName: Text; var RecIDOut: RecordID) Result: Boolean
    begin
        if (DataItemName = '') then
            exit(false);

        Buffer.SetRange("Data Item Name", DataItemName);
        Result := Buffer.FindFirst();
        if Result then begin
            RecIDBuffer.Get(Buffer."Unique Record No.");
            RecIDOut := RecIDBuffer."Buffer Record ID";
        end;
        Buffer.SetRange("Data Item Name");
    end;

    procedure GetRecIDFromRecordRootNo(RootNo: Integer; DataItemName: Text; var RecIDOut: RecordID) Result: Boolean
    var
        ExistingFilter: Text;
    begin
        if RootNo > 1 then begin
            ExistingFilter := Buffer.GetView();
            SetRootSubsetFilter(RootNo);
        end;

        Result := GetRecID(DataItemName, RecIDOut);

        if RootNo > 1 then
            Buffer.SetView(ExistingFilter);
    end;

    procedure GetRecIDFromRecordIterationNo(IterationNo: Integer; DataItemName: Text; var RecIDOut: RecordID) Result: Boolean
    var
        ExistingFilter: Text;
    begin
        ExistingFilter := Buffer.GetView();

        SetIterationSubsetFilter(IterationNo, DataItemName);
        Result := GetRecID(DataItemName, RecIDOut);

        Buffer.SetView(ExistingFilter);
    end;

    procedure GetBuffer(var BufferOut: Record "NPR RP Data Join Buffer" temporary)
    begin
        BufferOut.Copy(Buffer, true);
    end;

    procedure NextRecord(DataItemName: Text; var CurrentRecNo: Integer; UpperBound: Integer) Result: Boolean
    begin
        if CurrentRecNo = UpperBound then
            exit(false);

        Buffer.SetRange("Data Item Name", DataItemName);
        if UpperBound = 0 then
            Buffer.SetFilter("Unique Record No.", '>%1', CurrentRecNo)
        else
            Buffer.SetRange("Unique Record No.", CurrentRecNo + 1, UpperBound);
        Result := Buffer.FindFirst();
        if Result then
            CurrentRecNo := Buffer."Unique Record No.";
        Buffer.SetRange("Data Item Name");
        Buffer.SetRange("Unique Record No.");
    end;

    procedure SetBounds(LowerBound: Integer; UpperBound: Integer)
    begin
        if (UpperBound = LowerBound) and (UpperBound > 0) then
            Buffer.SetRange("Unique Record No.", LowerBound)
        else
            if (UpperBound = 0) and (LowerBound > 0) then
                Buffer.SetFilter("Unique Record No.", '>=%1', LowerBound)
            else
                if (UpperBound > 0) then
                    Buffer.SetRange("Unique Record No.", LowerBound, UpperBound)
                else
                    Buffer.SetRange("Unique Record No.");
    end;

    local procedure "// Aux"()
    begin
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
        Buffer.Reset();
        if not (FindBufferSet(DataItemName, TempRecordNo)) then
            exit(false);
        if IterationNo > 1 then
            for i := 1 to IterationNo - 1 do
                if not NextRecord(DataItemName, TempRecordNo, 0) then
                    exit(false);
        Buffer.SetRange("Unique Record No.", TempRecordNo);

        exit(true);
    end;

    procedure AddFieldToMap(DataItemName: Text; FieldNo: Integer)
    begin
        FieldMap."Data Item Name" := DataItemName;
        FieldMap."Data Item Field No." := FieldNo;
        if FieldMap.Insert() then;
    end;

    procedure SetDecimalRounding(DecimalRoundingIn: Option "2","3","4","5")
    begin
        DecimalRounding := DecimalRoundingIn;
    end;

    local procedure "// Locals"()
    begin
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
        tmpDistinctValueList: Record "NPR Retail List" temporary;
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
            if TestConstraint(ParentDataItem, ParentRecRef) and TestDistinct(ParentDataItem, ParentRecRef, tmpDistinctValueList) then begin
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
        FieldMap.SetRange("Data Item Name", ParentDataItem.Name);
        if FieldMap.FindSet() then begin
            Buffer."Unique Record No." += 1;
            repeat
                Buffer."Field No." := FieldMap."Data Item Field No.";
                Buffer."Join Level" := ParentDataItem.Level;
                Buffer."Data Item Name" := ParentDataItem.Name;
                if FieldMap."Data Item Field No." > 0 then begin
                    FieldRef := RecRef.Field(FieldMap."Data Item Field No.");
                    if UpperCase(Format(FieldRef.Class)) = 'FLOWFIELD' then
                        FieldRef.CalcField();

                    if UpperCase(Format(FieldRef.Type)) = 'DECIMAL' then
                        case DecimalRounding of
                            DecimalRounding::"2":
                                Buffer.Value := Format(FieldRef.Value, 0, '<Precision,2:2><Standard Format,2>');
                            DecimalRounding::"3":
                                Buffer.Value := Format(FieldRef.Value, 0, '<Precision,3:3><Standard Format,2>');
                            DecimalRounding::"4":
                                Buffer.Value := Format(FieldRef.Value, 0, '<Precision,4:4><Standard Format,2>');
                            DecimalRounding::"5":
                                Buffer.Value := Format(FieldRef.Value, 0, '<Precision,5:5><Standard Format,2>');
                        end
                    else
                        Buffer.Value := Format(FieldRef.Value);
                end else
                    Clear(Buffer.Value);
                Buffer.Insert();
            until FieldMap.Next() = 0;

            RecIDBuffer."Unique Record No." := Buffer."Unique Record No.";
            RecIDBuffer."Buffer Record ID" := RecRef.RecordId;
            RecIDBuffer.Insert();
        end;
        FieldMap.Reset();
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
        TemplateLine: Record "NPR RP Template Line";
        RecRef: RecordRef;
        KeyRef: KeyRef;
        FieldRef: FieldRef;
    begin
        AddFieldToMap(ParentDataItem.Name, 0);

        TemplateLine.SetRange("Template Code", Template);
        TemplateLine.SetFilter(Type, '%1|%2', TemplateLine.Type::Data, TemplateLine.Type::Loop);
        TemplateLine.SetFilter("Data Item Name", '<>%1', '');
        if TemplateLine.FindSet() then
            repeat
                RecRef.Open(TemplateLine."Data Item Table");
                KeyRef := RecRef.KeyIndex(RecRef.CurrentKeyIndex());
                FieldRef := KeyRef.FieldIndex(1);
                AddFieldToMap(TemplateLine."Data Item Name", FieldRef.Number);
                Clear(RecRef);
                AddFieldToMap(TemplateLine."Data Item Name", TemplateLine.Field);
                if TemplateLine."Field 2" > 0 then
                    AddFieldToMap(TemplateLine."Data Item Name", TemplateLine."Field 2");
            until TemplateLine.Next() = 0;
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

