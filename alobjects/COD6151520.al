codeunit 6151520 "Nc Trigger Sync. Mgt."
{
    // NC2.01/BR /20160809  CASE 247479 NaviConnect: Object created

    TableNo = "Task Line";

    trigger OnRun()
    var
        NcTriggerScheduler: Codeunit "Nc Trigger Scheduler";
        DataLogSubscriberMgt: Codeunit "Data Log Subscriber Mgt.";
        NcTrigger: Record "Nc Trigger";
        TriggerCode: Code[20];
        RecRef: RecordRef;
        TaskEntryNo: BigInteger;
    begin
        TriggerCode := CopyStr(UpperCase(GetParameterText(NcTriggerScheduler.GetParamName)),1,MaxStrLen(NcTrigger.Code));
        if TriggerCode = '' then
          exit;
        NcTrigger.Get(TriggerCode);
        RecRef.Get(NcTrigger.RecordId);
        InsertTask(RecRef,TaskEntryNo);
    end;

    procedure InsertTask(var Recref: RecordRef;var TaskEntryNo: BigInteger)
    var
        NcTaskSetup: Record "Nc Task Setup";
        NcTask: Record "Nc Task";
        FldRef: FieldRef;
        NcTaskProcessor: Record "Nc Task Processor";
    begin
        NcTaskSetup.SetRange("Table No.",Recref.Number);
        if not NcTaskSetup.FindFirst then begin
          InsertSetup (NcTaskSetup,Recref);
        end;

        NcTask.Init;
        NcTask."Entry No." := 0;
        NcTask."Task Processor Code" := NcTaskSetup."Task Processor Code";
        if Recref.Number = DATABASE::"Nc Trigger" then begin
          FldRef := Recref.Field(60);
          if Format(FldRef.Value) <> '' then
            if NcTaskProcessor.Get(Format(FldRef.Value)) then
              NcTask."Task Processor Code" := NcTaskProcessor.Code;
        end;
        NcTask.Validate(Type,NcTask.Type::Insert);
        NcTask."Company Name" := CompanyName;
        NcTask."Table No." := Recref.Number;
        NcTask."Table Name" := Recref.Name;
        NcTask."Record Position" := Recref.GetPosition(false);
        NcTask."Log Date" := CurrentDateTime;
        NcTask."Record Value" := CopyStr(DelStr(Format(Recref.RecordId),1,StrLen(Recref.Name) + 2),1,MaxStrLen(NcTask."Record Value"));
        NcTask.Insert;
        TaskEntryNo := NcTask."Entry No.";
    end;

    procedure AddResponse(var NcTask: Record "Nc Task";ResponseText: Text)
    var
        StreamOut: OutStream;
        StreamIn: InStream;
        PreviousResponse: Text;
    begin
        NcTask.CalcFields(Response);
        if NcTask.Response.HasValue then begin
          NcTask.Response.CreateInStream(StreamIn,TEXTENCODING::UTF8);
          StreamIn.Read(PreviousResponse);
        end else begin
          PreviousResponse := '';
        end;
        NcTask.Response.CreateOutStream(StreamOut,TEXTENCODING::UTF8);
        StreamOut.Write(PreviousResponse  + ResponseText );
    end;

    procedure FillFields(NcTask: Record "Nc Task";TempEndpoint: Variant)
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        FieldRecord: Record "Field";
        NcTaskField: Record "Nc Task Field";
    begin
        if not TempEndpoint.IsRecord then
          exit;
        RecRef.GetTable(TempEndpoint);
        FieldRecord.Reset;
        FieldRecord.SetRange(TableNo,RecRef.Number);
        if FieldRecord.FindSet then repeat
          FieldRecord.Init;
          FldRef := RecRef.Field(FieldRecord."No.");
          NcTaskField."Entry No." := 0;
          NcTaskField."Field No." := FieldRecord."No.";
          NcTaskField."Field Name" := FldRef.Name;
          NcTaskField."Previous Value" := Format(FldRef.Value,0,9);
          NcTaskField."New Value" := FldRef.Value;
          NcTaskField."Log Date" := CurrentDateTime;
          NcTaskField."Task Entry No." := NcTask."Entry No.";
          NcTaskField.Insert;
        until FieldRecord.Next = 0;
    end;

    procedure GetOutput(NcTaskentryNo: Integer): Text
    var
        NcTask: Record "Nc Task";
        TextNoOutput: Label 'FTP Task not executed because there was no output to send.';
        TextOutputNotFound: Label 'Output Task %1 could not be found. The task with output may have been deleted before it could be transferred.';
        IStream: InStream;
        StreamReader: DotNet StreamReader;
    begin
        if not NcTask.Get(NcTaskentryNo) then
          Error(TextOutputNotFound,Format(NcTaskentryNo));

        if not NcTask."Data Output".HasValue then
          Error(TextNoOutput);

        NcTask.CalcFields("Data Output");
        NcTask."Data Output".CreateInStream(IStream,TEXTENCODING::UTF8);
        StreamReader := StreamReader.StreamReader(IStream);
        exit(StreamReader.ReadToEnd());
    end;

    local procedure InsertSetup(var NcTaskSetup: Record "Nc Task Setup";RecRef: RecordRef)
    var
        NcTaskProcessor: Record "Nc Task Processor";
    begin
        NcTaskSetup.Init;
        NcTaskProcessor.FindFirst;
        NcTaskSetup."Task Processor Code" := NcTaskProcessor.Code;
        NcTaskSetup."Entry No." := 0;
        NcTaskSetup.Validate("Table No.",RecRef.Number);
        NcTaskSetup.Validate("Codeunit ID",CODEUNIT::"Nc Trigger Task Mgt.");
        NcTaskSetup.Insert(true);
    end;
}

