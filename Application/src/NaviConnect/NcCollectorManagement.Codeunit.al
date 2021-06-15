codeunit 6151528 "NPR Nc Collector Management"
{
    procedure GetNcCollectionNo(CollectorCode: Code[20]): BigInteger
    var
        NcCollection: Record "NPR Nc Collection";
        NcCollector: Record "NPR Nc Collector";
        DataLogMgt: Codeunit "NPR Data Log Management";
        RecRef: RecordRef;
    begin
        NcCollector.Get(CollectorCode);
        NcCollection.Reset();
        NcCollection.SetCurrentKey("Collector Code", Status);
        NcCollection.SetRange("Collector Code", NcCollector.Code);
        NcCollection.SetRange(Status, NcCollection.Status::Collecting);
        if NcCollection.FindLast() then begin
            if NcCollector."Max. Lines per Collection" = 0 then
                exit(NcCollection."No.");
            NcCollection.CalcFields("No. of Lines");
            if NcCollection."No. of Lines" < NcCollector."Max. Lines per Collection" then
                exit(NcCollection."No.");
        end;
        NcCollection.Init();
        NcCollection."No." := 0;
        NcCollection.Validate("Collector Code", NcCollector.Code);
        NcCollection.Validate(Status, NcCollection.Status::Collecting);
        NcCollection."Table No." := NcCollector."Table No.";
        NcCollection."Creation Date" := CurrentDateTime;
        NcCollection.Insert(true);
        RecRef.GetTable(NcCollection);
        DataLogMgt.LogDatabaseInsert(RecRef);
        exit(NcCollection."No.");
    end;

    procedure PopulatePKFields(var NcCollectionLine: Record "NPR Nc Collection Line"; RecRef: RecordRef)
    var
        FieldRefPKField: FieldRef;
        ToRecRef: RecordRef;
        ToFieldRef: FieldRef;
        PKKeyRef: KeyRef;
        I: Integer;
    begin
        case NcCollectionLine."Table No." of
            127:
                begin
                    FieldRefPKField := RecRef.Field(1);
                    NcCollectionLine."PK Code 1" := Format(FieldRefPKField.Value);
                end;
            else begin
                    PKKeyRef := RecRef.KeyIndex(1);
                    ToRecRef.GetTable(NcCollectionLine);
                    for I := 1 to PKKeyRef.FieldCount do begin
                        FieldRefPKField := PKKeyRef.FieldIndex(I);
                        ToFieldRef := ToRecRef.Field(NcCollectionLine.FieldNo("PK Code 1"));
                        if FieldRefPKField.Type = ToFieldRef.Type then begin
                            if NcCollectionLine."PK Code 1" = '' then
                                NcCollectionLine."PK Code 1" := FieldRefPKField.Value
                            else
                                if NcCollectionLine."PK Code 2" = '' then
                                    NcCollectionLine."PK Code 2" := FieldRefPKField.Value;
                        end else begin
                            ToFieldRef := ToRecRef.Field(NcCollectionLine.FieldNo("PK Line 1"));
                            if FieldRefPKField.Type = ToFieldRef.Type then begin
                                if NcCollectionLine."PK Line 1" = 0 then
                                    NcCollectionLine."PK Line 1" := FieldRefPKField.Value
                                else
                                    NcCollectionLine."PK Line 2" := FieldRefPKField.Value;
                            end else begin
                                ToFieldRef := ToRecRef.Field(NcCollectionLine.FieldNo("PK Option 1"));
                                if FieldRefPKField.Type = ToFieldRef.Type then begin
                                    if NcCollectionLine."PK Option 1" = 20 then
                                        NcCollectionLine."PK Option 1" := FieldRefPKField.Value;
                                end;
                            end;
                        end;
                    end;
                end;
        end;
    end;

    procedure CreateModifyCollectionLines(NcCollector: Record "NPR Nc Collector")
    var
        RecRef: RecordRef;
        NcCollectorFilter: Record "NPR Nc Collector Filter";
        FieldRefTemp: FieldRef;
        FieldRefChange: FieldRef;
        RecReftemp: RecordRef;
        SkipRecord: Boolean;
    begin
        RecRef.Open(NcCollector."Table No.");
        RecReftemp.Open(NcCollector."Table No.", true);
        if RecRef.FindFirst() then
            repeat
                SkipRecord := false;
                NcCollectorFilter.Reset();
                NcCollectorFilter.SetRange("Collector Code", NcCollector.Code);
                NcCollectorFilter.SetRange("Table No.", NcCollector."Table No.");
                if NcCollectorFilter.FindSet() then
                    repeat
                        FieldRefTemp := RecReftemp.Field(NcCollectorFilter."Field No.");
                        FieldRefChange := RecRef.Field(NcCollectorFilter."Field No.");
                        FieldRefTemp.Value := FieldRefChange.Value;
                        RecReftemp.Insert();
                        FieldRefTemp.SetFilter(NcCollectorFilter."Filter Text");
                        if RecReftemp.IsEmpty then
                            SkipRecord := true;
                        RecReftemp.Delete();
                    until (NcCollectorFilter.Next() = 0) or SkipRecord;
                if not SkipRecord then
                    InsertModifyCollectionLine(RecRef, NcCollector.Code);
            until RecRef.Next() = 0;
    end;

    local procedure InsertModifyCollectionLine(RecRef: RecordRef; NcCollectorCode: Code[20])
    var
        NcCollectionLine: Record "NPR Nc Collection Line";
        DataLogMgt: Codeunit "NPR Data Log Management";
        RecRef2: RecordRef;
    begin
        NcCollectionLine.Init();
        NcCollectionLine."No." := 0;
        NcCollectionLine."Collector Code" := NcCollectorCode;
        NcCollectionLine."Collection No." := GetNcCollectionNo(NcCollectorCode);
        NcCollectionLine."Type of Change" := NcCollectionLine."Type of Change"::Modify;
        NcCollectionLine."Record Position" := RecRef.GetPosition(false);
        NcCollectionLine."Table No." := RecRef.Number;
        NcCollectionLine."Data log Record No." := 0;
        PopulatePKFields(NcCollectionLine, RecRef);
        NcCollectionLine.Insert(true);
        RecRef2.GetTable(NcCollectionLine);
        DataLogMgt.LogDatabaseInsert(RecRef2);

        MarkPreviousCollectionLinesAsObsolete(NcCollectionLine);
    end;

    procedure MarkPreviousCollectionLinesAsObsolete(NcCollectionLine: Record "NPR Nc Collection Line")
    var
        OldNcCollectionLine: Record "NPR Nc Collection Line";
        NcCollector: Record "NPR Nc Collector";
    begin
        NcCollector.Get(NcCollectionLine."Collector Code");
        OldNcCollectionLine.Reset();
        OldNcCollectionLine.SetFilter("Collection No.", '=%1', NcCollectionLine."Collection No.");
        OldNcCollectionLine.SetFilter("No.", '<%1', NcCollectionLine."No.");
        OldNcCollectionLine.SetFilter("Table No.", '=%1', NcCollectionLine."Table No.");
        OldNcCollectionLine.SetFilter("Type of Change", '=%1', NcCollectionLine."Type of Change");
        OldNcCollectionLine.SetFilter("PK Code 1", '=%1', NcCollectionLine."PK Code 1");
        OldNcCollectionLine.SetFilter("PK Code 2", '=%1', NcCollectionLine."PK Code 2");
        OldNcCollectionLine.SetFilter("PK Line 1", '=%1', NcCollectionLine."PK Line 1");
        OldNcCollectionLine.SetFilter("PK Option 1", '=%1', NcCollectionLine."PK Option 1");
        if NcCollector."Delete Obsolete Lines" then begin
            OldNcCollectionLine.DeleteAll(true);
        end else begin
            if OldNcCollectionLine.FindSet() then
                repeat
                    OldNcCollectionLine.Validate(Obsolete, true);
                    OldNcCollectionLine.Modify(true);
                until OldNcCollectionLine.Next() = 0;
        end;
    end;

    procedure SetCollectionStatus(NcCollection: Record "NPR Nc Collection"; NewStatus: Option Collecting,"Ready to Send",Sent)
    var
        TxtCollectionWillNotbeSent: Label '%1 %2 be marked as sent without being sent.';
        TxtCollectionWillBeResentSent: Label '%1 %2 be marked unsent and %3 requests will be resent.';
    begin
        if NewStatus = NcCollection.Status then
            exit;
        case NcCollection.Status of
            NcCollection.Status::Collecting:
                begin
                    case NewStatus of
                        NewStatus::"Ready to Send":
                            begin
                                NcCollection.CalcFields("No. of Lines");
                                NcCollection.TestField("No. of Lines");
                                NcCollection.Validate(Status, NewStatus);
                                NcCollection.Modify(true);
                            end;
                        NewStatus::Sent:
                            begin
                                if Confirm(StrSubstNo(TxtCollectionWillNotbeSent, NcCollection.TableCaption, NcCollection."No.")) then begin
                                    NcCollection.Validate(Status, NewStatus);
                                    NcCollection.Modify(true);
                                end;
                            end;
                    end;
                end;
            NcCollection.Status::"Ready to Send":
                begin
                    case NewStatus of
                        NewStatus::Collecting:
                            begin
                                NcCollection.Validate(Status, NewStatus);
                                NcCollection.Modify(true);
                            end;
                        NewStatus::Sent:
                            begin
                                if Confirm(StrSubstNo(TxtCollectionWillNotbeSent, NcCollection.TableCaption, NcCollection."No.")) then begin
                                    NcCollection.Validate(Status, NewStatus);
                                    NcCollection."Sent Date" := 0DT;
                                    NcCollection.Modify(true);
                                end;
                            end;
                    end;
                end;
            NcCollection.Status::Sent:
                begin
                    NcCollection.CalcFields("No. of Lines");
                    if NcCollection."No. of Lines" = 0 then begin
                        NcCollection.Validate(Status, NewStatus);
                        NcCollection.Modify(true);
                    end else begin
                        if Confirm(StrSubstNo(TxtCollectionWillBeResentSent, NcCollection.TableCaption, NcCollection."No.", NcCollection."No. of Lines")) then begin
                            NcCollection.Validate(Status, NewStatus);
                            if NewStatus = NewStatus::Collecting then
                                NcCollection."Ready to Send Date" := 0DT;
                            NcCollection."Sent Date" := 0DT;
                            NcCollection.Modify(true);
                        end;
                    end;
                end;
        end;
    end;

    procedure CreateOutboundCollectorRequest(RequestName: Text[30]; RecordToRequest: Variant; OnlyNewAndModified: Boolean)
    var
        TextOnlyRecords: Label 'You can only create Requests for Records.';
        RecRef: RecordRef;
        RecRef2: RecordRef;
        NcCollectorRequest: Record "NPR Nc Collector Request";
        DataLogMgt: Codeunit "NPR Data Log Management";
    begin
        if not RecordToRequest.IsRecord then
            Error(TextOnlyRecords);

        NcCollectorRequest.Init();
        NcCollectorRequest.Validate(Direction, NcCollectorRequest.Direction::Outgoing);
        NcCollectorRequest.Validate(Name, RequestName);
        NcCollectorRequest.Validate("Only New and Modified Records", OnlyNewAndModified);
        NcCollectorRequest.Insert(true);
        RecRef2.GetTable(NcCollectorRequest);
        DataLogMgt.LogDatabaseInsert(RecRef2);

        RecRef.GetTable(RecordToRequest);
        InsertFilterRecords(NcCollectorRequest, RecRef);
    end;

    procedure InsertFilterRecords(NcCollectorRequest: Record "NPR Nc Collector Request"; RecRef: RecordRef)
    var
        NcCollectorRequestFilter: Record "NPR Nc Collector Req. Filter";
        FieldRec: Record "Field";
        DataLogMgt: Codeunit "NPR Data Log Management";
        RecRef2: RecordRef;
        FldRef: FieldRef;
        FilterText: Text;
    begin
        NcCollectorRequest.TestField("No.");
        NcCollectorRequestFilter.Reset();
        NcCollectorRequestFilter.SetRange("Nc Collector Request No.", NcCollectorRequest."No.");
        NcCollectorRequestFilter.DeleteAll(true);
        if RecRef.HasFilter then begin
            FieldRec.Reset();
            FieldRec.SetRange(TableNo, RecRef.Number);
            FieldRec.SetRange(Class, FieldRec.Class::Normal);
            if FieldRec.FindSet() then
                repeat
                    FldRef := RecRef.Field(FieldRec."No.");
                    FilterText := CopyStr(Format(FldRef.GetFilter, 0, 9), 1, MaxStrLen(NcCollectorRequestFilter."Filter Text"));
                    if FilterText <> '' then begin
                        NcCollectorRequestFilter.Init();
                        NcCollectorRequestFilter.Validate("Nc Collector Request No.", NcCollectorRequest."No.");
                        NcCollectorRequestFilter.Validate("Table No.", RecRef.Number);
                        NcCollectorRequestFilter.Validate("Field No.", FldRef.Number);
                        NcCollectorRequestFilter.Validate("Filter Text", FilterText);
                        NcCollectorRequestFilter.Insert(true);
                        RecRef2.GetTable(NcCollectorRequestFilter);
                        DataLogMgt.LogDatabaseInsert(RecRef2);
                    end;
                until FieldRec.Next() = 0;
        end;
    end;
}

