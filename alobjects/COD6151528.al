codeunit 6151528 "Nc Collector Management"
{
    // NC2.01/BR  /20160909  CASE 250447 NaviConnect: Object created
    // NC2.04/BR  /20170510  CASE 274524 Fix potential update conflicts
    // NC2.09/BR  /20180130  CASE 303885 Fix "Send as Modify" function
    // NC2.13/MHA /20180528  CASE 314683 Added DataLog Insert Trigger to consider Autoincrement Primary Key


    trigger OnRun()
    begin
    end;

    procedure GetNcCollectionNo(CollectorCode: Code[20]): BigInteger
    var
        NcCollection: Record "Nc Collection";
        NcCollector: Record "Nc Collector";
        DataLogMgt: Codeunit "Data Log Management";
        RecRef: RecordRef;
    begin
        NcCollector.Get(CollectorCode);
        with NcCollection do begin
          Reset;
          SetCurrentKey("Collector Code",Status);
          SetRange("Collector Code",NcCollector.Code);
          SetRange(Status,Status::Collecting);
          if FindLast then begin
            if NcCollector."Max. Lines per Collection" = 0 then
              exit("No.");
            CalcFields("No. of Lines");
            if "No. of Lines" < NcCollector."Max. Lines per Collection" then
              exit("No.");
            //-NC2.04 [274524]
            //IF NcCollector."Send when Max. Lines" THEN BEGIN
            //  VALIDATE(Status,Status::"Ready to Send");
            //  MODIFY(TRUE);
            //END;
            //+NC2.04 [274524]
          end;
          Init;
          "No." := 0;
          Validate("Collector Code",NcCollector.Code);
          Validate(Status,Status::Collecting);
          "Table No." := NcCollector."Table No.";
          "Creation Date" := CurrentDateTime;
          Insert(true);
          //-NC2.13 [314683]
          RecRef.GetTable(NcCollection);
          DataLogMgt.OnDatabaseInsert(RecRef);
          //+NC2.13 [314683]
          exit("No.");
        end;
    end;

    procedure PopulatePKFields(var NcCollectionLine: Record "Nc Collection Line";RecRef: RecordRef)
    var
        RecIDChange: RecordID;
        RecRefchange: RecordRef;
        FieldRefPKField: FieldRef;
        ToRecRef: RecordRef;
        ToFieldRef: FieldRef;
        PKKeyRef: KeyRef;
        I: Integer;
    begin
        case NcCollectionLine."Table No." of
          127 :
            begin
              FieldRefPKField := RecRef.Field(1);
              NcCollectionLine."PK Code 1" :=Format(FieldRefPKField.Value);
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
                else if NcCollectionLine."PK Code 2" = '' then
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

    procedure CreateModifyCollectionLines(NcCollector: Record "Nc Collector")
    var
        RecRef: RecordRef;
        NcCollectorFilter: Record "Nc Collector Filter";
        FieldRefTemp: FieldRef;
        FieldRefChange: FieldRef;
        RecReftemp: RecordRef;
        SkipRecord: Boolean;
    begin
        RecRef.Open(NcCollector."Table No.");
        RecReftemp.Open(NcCollector."Table No.",true);
        if RecRef.FindFirst then repeat
          SkipRecord := false;
          NcCollectorFilter.Reset;
          NcCollectorFilter.SetRange("Collector Code",NcCollector.Code);
          NcCollectorFilter.SetRange("Table No.",NcCollector."Table No.");
          if NcCollectorFilter.FindSet then repeat
            FieldRefTemp := RecReftemp.Field(NcCollectorFilter."Field No.");
            FieldRefChange := RecRef.Field(NcCollectorFilter."Field No.");
            FieldRefTemp.Value := FieldRefChange.Value;
            RecReftemp.Insert;
            FieldRefTemp.SetFilter(NcCollectorFilter."Filter Text");
            if RecReftemp.IsEmpty then
               SkipRecord := true;
            RecReftemp.Delete;
          until (NcCollectorFilter.Next = 0) or SkipRecord;
          if not SkipRecord then
            //-NC2.09 [303885]
            //InsertModifyCollectionLine(RecReftemp,NcCollector.Code);
            InsertModifyCollectionLine(RecRef,NcCollector.Code);
            //+NC2.09 [303885]
        until RecRef.Next = 0 ;
    end;

    local procedure InsertModifyCollectionLine(RecRef: RecordRef;NcCollectorCode: Code[20])
    var
        NcCollectionLine: Record "Nc Collection Line";
        DataLogMgt: Codeunit "Data Log Management";
        RecRef2: RecordRef;
    begin
        with NcCollectionLine do begin
          Init;
          "No." := 0;
          "Collector Code" := NcCollectorCode;
          "Collection No." := GetNcCollectionNo(NcCollectorCode);
          "Type of Change" := "Type of Change"::Modify ;
          //"Record ID" := DataLogRecord."Record ID";
          "Record Position" := RecRef.GetPosition(false);
          "Table No." := RecRef.Number;
          "Data log Record No." := 0;
          PopulatePKFields(NcCollectionLine,RecRef);
          Insert(true);
          //-NC2.13 [314683]
          RecRef2.GetTable(NcCollectionLine);
          DataLogMgt.OnDatabaseInsert(RecRef2);
          //+NC2.13 [314683]
        end;

        MarkPreviousCollectionLinesAsObsolete(NcCollectionLine);
    end;

    procedure MarkPreviousCollectionLinesAsObsolete(NcCollectionLine: Record "Nc Collection Line")
    var
        OldNcCollectionLine: Record "Nc Collection Line";
        NcCollector: Record "Nc Collector";
    begin
        NcCollector.Get(NcCollectionLine."Collector Code");
        with OldNcCollectionLine do begin
          Reset;
          SetFilter("Collection No.",'=%1',NcCollectionLine."Collection No.");
          SetFilter("No.",'<%1',NcCollectionLine."No.");
          SetFilter("Table No.",'=%1',NcCollectionLine."Table No.");
          SetFilter("Type of Change",'=%1',NcCollectionLine."Type of Change");
          SetFilter("PK Code 1",'=%1',NcCollectionLine."PK Code 1");
          SetFilter("PK Code 2",'=%1',NcCollectionLine."PK Code 2");
          SetFilter("PK Line 1",'=%1',NcCollectionLine."PK Line 1");
          SetFilter("PK Option 1",'=%1',NcCollectionLine."PK Option 1");
          if NcCollector."Delete Obsolete Lines" then begin
            DeleteAll(true);
          end else begin
            if FindSet then repeat
              Validate(Obsolete,true);
              Modify(true);
            until Next = 0;
          end;
        end;
    end;

    procedure SetCollectionStatus(NcCollection: Record "Nc Collection";NewStatus: Option Collecting,"Ready to Send",Sent)
    var
        TxtStatusAllready: Label '%1 %2 is already %3.';
        TxtCollectionWillNotbeSent: Label '%1 %2 be marked as sent without being sent.';
        TxtCollectionWillBeResentSent: Label '%1 %2 be marked unsent and %3 requests will be resent.';
    begin
        if NewStatus = NcCollection.Status then
          exit;
        case NcCollection.Status of
          NcCollection.Status  :: Collecting :
            begin
              case NewStatus of
                NewStatus :: "Ready to Send" :
                  begin
                    NcCollection.CalcFields("No. of Lines");
                    NcCollection.TestField("No. of Lines");
                    NcCollection.Validate(Status,NewStatus);
                    NcCollection.Modify(true);
                  end;
                NewStatus :: Sent :
                  begin
                    if Confirm(StrSubstNo(TxtCollectionWillNotbeSent,NcCollection.TableCaption,NcCollection."No.")) then begin
                      NcCollection.Validate(Status,NewStatus);
                      NcCollection.Modify(true);
                    end;
                  end;
              end;
            end;
          NcCollection.Status  :: "Ready to Send" :
            begin
              case NewStatus of
                NewStatus :: Collecting :
                  begin
                    NcCollection.Validate(Status,NewStatus);
                    NcCollection.Modify(true);
                  end;
                NewStatus :: Sent :
                  begin
                    if Confirm(StrSubstNo(TxtCollectionWillNotbeSent,NcCollection.TableCaption,NcCollection."No.")) then begin
                      NcCollection.Validate(Status,NewStatus);
                      NcCollection."Sent Date" := 0DT;
                      NcCollection.Modify(true);
                    end;
                  end;
              end;
            end;
          NcCollection.Status  :: Sent :
            begin
              NcCollection.CalcFields("No. of Lines");
              if NcCollection."No. of Lines" = 0 then begin
                NcCollection.Validate(Status,NewStatus);
                NcCollection.Modify(true);
              end else begin
                if Confirm(StrSubstNo(TxtCollectionWillBeResentSent,NcCollection.TableCaption,NcCollection."No.",NcCollection."No. of Lines")) then begin
                  NcCollection.Validate(Status,NewStatus);
                  if NewStatus = NewStatus::Collecting then
                    NcCollection."Ready to Send Date" := 0DT;
                  NcCollection."Sent Date" := 0DT;
                  NcCollection.Modify(true);
                end;
              end;
            end;
        end;
    end;

    procedure CreateOutboundCollectorRequest(RequestName: Text[30];RecordToRequest: Variant;OnlyNewAndModified: Boolean)
    var
        TextOnlyRecords: Label 'You can only create Requests for Records.';
        FieldRec: Record "Field";
        RecRef: RecordRef;
        RecRef2: RecordRef;
        FldRef: FieldRef;
        FilterText: Text[250];
        NcCollectorRequest: Record "Nc Collector Request";
        NcCollectorRequestFilter: Record "Nc Collector Request Filter";
        ActiveSession: Record "Active Session";
        DataLogMgt: Codeunit "Data Log Management";
    begin
        if not RecordToRequest.IsRecord then
          Error(TextOnlyRecords);

        NcCollectorRequest.Init;
        NcCollectorRequest.Validate(Direction,NcCollectorRequest.Direction::Outgoing);
        NcCollectorRequest.Validate(Name,RequestName);
        NcCollectorRequest.Validate("Only New and Modified Records",OnlyNewAndModified);
        NcCollectorRequest.Insert(true);
        //-NC2.13 [314683]
        RecRef2.GetTable(NcCollectorRequest);
        DataLogMgt.OnDatabaseInsert(RecRef2);
        //+NC2.13 [314683]

        RecRef.GetTable(RecordToRequest);
        InsertFilterRecords(NcCollectorRequest,RecRef);
    end;

    procedure InsertFilterRecords(NcCollectorRequest: Record "Nc Collector Request";RecRef: RecordRef)
    var
        NcCollectorRequestFilter: Record "Nc Collector Request Filter";
        FieldRec: Record "Field";
        DataLogMgt: Codeunit "Data Log Management";
        RecRef2: RecordRef;
        FldRef: FieldRef;
        FilterText: Text;
    begin
        NcCollectorRequest.TestField("No.");
        NcCollectorRequestFilter.Reset;
        NcCollectorRequestFilter.SetRange("Nc Collector Request No.",NcCollectorRequest."No.");
        NcCollectorRequestFilter.DeleteAll(true);
        if RecRef.HasFilter then begin
          FieldRec.Reset;
          FieldRec.SetRange(TableNo,RecRef.Number);
          FieldRec.SetRange(Class,FieldRec.Class::Normal);
          if FieldRec.FindSet then repeat
            FldRef  := RecRef.Field(FieldRec."No.");
            FilterText := CopyStr(Format(FldRef.GetFilter,0,9) ,1,MaxStrLen(NcCollectorRequestFilter."Filter Text"));
            if FilterText <> '' then begin
              NcCollectorRequestFilter.Init;
              NcCollectorRequestFilter.Validate("Nc Collector Request No.",NcCollectorRequest."No.");
              NcCollectorRequestFilter.Validate("Table No.",RecRef.Number);
              NcCollectorRequestFilter.Validate("Field No.",FldRef.Number);
              NcCollectorRequestFilter.Validate("Filter Text",FilterText);
              NcCollectorRequestFilter.Insert(true);
              //-NC2.13 [314683]
              RecRef2.GetTable(NcCollectorRequestFilter);
              DataLogMgt.OnDatabaseInsert(RecRef2);
              //-NC2.13 [314683]
            end;
          until FieldRec.Next = 0;
        end;
        //+NPR5.25
    end;
}

