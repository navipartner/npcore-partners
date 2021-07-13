codeunit 6151527 "NPR Nc Collector DataLog Proc."
{
    TableNo = "NPR Data Log Record";

    trigger OnRun()
    begin
        CheckCollectors(Rec);
    end;

    local procedure CheckCollectors(Datalogrecord: Record "NPR Data Log Record")
    var
        NcCollector: Record "NPR Nc Collector";
    begin
        NcCollector.Reset();
        NcCollector.SetRange("Table No.", Datalogrecord."Table ID");
        NcCollector.SetRange(Active, true);
        if NcCollector.FindSet() then
            repeat
                if ((Datalogrecord."Type of Change" = Datalogrecord."Type of Change"::Insert) and NcCollector."Record Insert") or
                   ((Datalogrecord."Type of Change" = Datalogrecord."Type of Change"::Delete) and NcCollector."Record Delete") or
                   ((Datalogrecord."Type of Change" = Datalogrecord."Type of Change"::Rename) and NcCollector."Record Rename") or
                   ((Datalogrecord."Type of Change" = Datalogrecord."Type of Change"::Modify) and NcCollector."Record Modify") then
                    ProcessChange(Datalogrecord, NcCollector.Code);
            until NcCollector.Next() = 0;
    end;

    local procedure ProcessChange(DataLogRecord: Record "NPR Data Log Record"; NcCollectorCode: Code[20])
    var
        NcCollectionLine: Record "NPR Nc Collection Line";
        DataLogMgt: Codeunit "NPR Data Log Management";
        NcCollectorManagement: Codeunit "NPR Nc Collector Management";
        RecRef: RecordRef;
    begin
        if DataLogRecord."Type of Change" <> DataLogRecord."Type of Change"::Delete then
            if not CheckFilter(DataLogRecord, NcCollectorCode) then
                exit;

        if DataLogRecord."Type of Change" = DataLogRecord."Type of Change"::Modify then
            if not CheckModifyTriggers(DataLogRecord, NcCollectorCode) then
                exit;
        NcCollectionLine.Init();
        NcCollectionLine."No." := 0;
        NcCollectionLine."Collector Code" := NcCollectorCode;
        NcCollectionLine."Collection No." := NcCollectorManagement.GetNcCollectionNo(NcCollectorCode);
        NcCollectionLine."Type of Change" := DataLogRecord."Type of Change";
        RecRef.Get(DataLogRecord."Record ID");
        NcCollectionLine."Record Position" := RecRef.GetPosition(false);
        NcCollectionLine."Table No." := DataLogRecord."Table ID";
        NcCollectionLine."Data log Record No." := DataLogRecord."Entry No.";
        NcCollectorManagement.PopulatePKFields(NcCollectionLine, RecRef);
        NcCollectionLine.Insert(true);
        RecRef.GetTable(NcCollectionLine);
        DataLogMgt.LogDatabaseInsert(RecRef);

        if NcCollectionLine."Type of Change" in [NcCollectionLine."Type of Change"::Modify, NcCollectionLine."Type of Change"::Delete] then
            NcCollectorManagement.MarkPreviousCollectionLinesAsObsolete(NcCollectionLine);
    end;

    local procedure CheckFilter(DataLogRecord: Record "NPR Data Log Record"; NcCollectorCode: Code[20]): Boolean
    var
        NcCollectorFilter: Record "NPR Nc Collector Filter";
        DataLogField: Record "NPR Data Log Field";
        RecRefchange: RecordRef;
        RecReftemp: RecordRef;
        FieldRefTemp: FieldRef;
        FieldRefChange: FieldRef;
    begin
        if not RecRefchange.Get(DataLogRecord."Record ID") then
            exit(false);
        RecReftemp.Open(RecRefchange.Number, true);
        NcCollectorFilter.Reset();
        NcCollectorFilter.SetRange("Collector Code", NcCollectorCode);
        NcCollectorFilter.SetRange("Table No.", DataLogRecord."Table ID");
        if NcCollectorFilter.FindSet() then
            repeat
                FieldRefTemp := RecReftemp.Field(NcCollectorFilter."Field No.");
                FieldRefChange := RecRefchange.Field(NcCollectorFilter."Field No.");
                FieldRefTemp.Value := FieldRefChange.Value;
                DataLogField.SetRange("Table ID", DataLogRecord."Table ID");
                DataLogField.SetRange("Data Log Record Entry No.", DataLogRecord."Entry No.");
                DataLogField.SetRange("Field No.", NcCollectorFilter."Field No.");
                DataLogField.SetRange("Field Value Changed", true);
                if DataLogField.FindFirst() then
                    AssignValue(FieldRefTemp, DataLogField."Field Value");
                RecReftemp.Insert();
                FieldRefTemp.SetFilter(NcCollectorFilter."Filter Text");
                if RecReftemp.IsEmpty() then
                    exit(false);
                RecReftemp.Delete();
            until NcCollectorFilter.Next() = 0;

        exit(true);
    end;

    local procedure CheckModifyTriggers(DataLogRecord: Record "NPR Data Log Record"; NcCollectorCode: Code[20]): Boolean
    var
        NcCollectorFilter: Record "NPR Nc Collector Filter";
        DataLogField: Record "NPR Data Log Field";
        DataLogSetupTable: Record "NPR Data Log Setup (Table)";
    begin
        if not DataLogSetupTable.Get(DataLogRecord."Table ID") then
            exit(true);
        if DataLogSetupTable."Log Modification" = DataLogSetupTable."Log Modification"::Simple then
            exit(true);
        NcCollectorFilter.Reset();
        NcCollectorFilter.SetRange("Collector Code", NcCollectorCode);
        NcCollectorFilter.SetRange("Table No.", DataLogRecord."Table ID");
        NcCollectorFilter.SetRange("Collect When Modified", true);
        if NcCollectorFilter.FindSet() then begin
            repeat
                DataLogField.Reset();
                DataLogField.SetRange("Table ID", DataLogRecord."Table ID");
                DataLogField.SetRange("Data Log Record Entry No.", DataLogRecord."Entry No.");
                DataLogField.SetRange("Field No.", NcCollectorFilter."Field No.");
                DataLogField.SetRange("Field Value Changed", true);
                if not DataLogField.IsEmpty() then
                    exit(true);
            until (NcCollectorFilter.Next() = 0);
            exit(false);
        end else
            exit(true);
    end;

    local procedure AssignValue(var FieldRef: FieldRef; Value: Text[250])
    var
        TextValue: Text[250];
        DecimalValue: Decimal;
        IntegerValue: Integer;
        BooleanValue: Boolean;
        DateValue: Date;
        TimeValue: Time;
        DateFormulaValue: DateFormula;
        BigIntegerValue: BigInteger;
        DateTimeValue: DateTime;
    begin
        case LowerCase(Format(FieldRef.Type)) of
            'code', 'text':
                begin
                    TextValue := Value;
                    FieldRef.Value := TextValue;
                end;
            'decimal':
                begin
                    if Value = '' then
                        Value := Format(DecimalValue, 0, 9);
                    Evaluate(DecimalValue, Value, 9);
                    FieldRef.Value := DecimalValue;
                end;
            'boolean':
                begin
                    if Value = '' then
                        Value := Format(BooleanValue, 0, 9);
                    Evaluate(BooleanValue, Value, 9);
                    FieldRef.Value := BooleanValue;
                end;
            'dateformula':
                begin
                    if Value = '' then
                        Value := Format(DateFormulaValue, 0, 9);
                    Evaluate(DateFormulaValue, Value, 9);
                    FieldRef.Value := DateFormulaValue;
                end;
            'biginteger':
                begin
                    if Value = '' then
                        Value := Format(BigIntegerValue, 0, 9);
                    Evaluate(BigIntegerValue, Value, 9);
                    FieldRef.Value := BigIntegerValue;
                end;
            'datetime':
                begin
                    if Value = '' then
                        Value := Format(DateTimeValue, 0, 9);
                    Evaluate(DateTimeValue, Value, 9);
                    FieldRef.Value := DateTimeValue;
                end;
            'option', 'integer':
                begin
                    if Value = '' then
                        Value := Format(IntegerValue, 0, 9);
                    Evaluate(IntegerValue, Value, 9);
                    FieldRef.Value := IntegerValue;
                end;
            'date':
                begin
                    if Value = '' then
                        Value := Format(DateValue, 0, 9);
                    Evaluate(DateValue, Value, 9);
                    FieldRef.Value := DateValue;
                end;
            'time':
                begin
                    if Value = '' then
                        Value := Format(TimeValue, 0, 9);
                    Evaluate(TimeValue, Value, 9);
                    FieldRef.Value := TimeValue;
                end;
        end;
    end;
}

