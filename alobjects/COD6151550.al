codeunit 6151550 "NpXml Task Mgt."
{
    // NC1.01/MHA /20150201  CASE 199932 Object Created - Connects NpXml with NaviConnect
    //                                 - NaviConnect References/Functions may be removed if [NC] is not installed.
    // NC1.13/MHA /20150414  CASE 211360 Restructured NpXml Codeunits. Independent functions moved to new codeunits
    // NC1.14/MHA /20150424  CASE 212415 Moved Clear of NpXml Mgt. in order to enable multiple template output
    // NC1.20/MHA /20150821  CASE 221229 Trigger Code changed to clearify actions on different table triggers
    // NC1.22/MHA /20160108  CASE 226040 Changed CommitOutput() to Append instead of Replace
    // NC1.22/MHA /20160415  CASE 231214 Added multi company Task Processing
    // NC2.00/MHA /20160525  CASE 240005 NaviConnect
    // NC2.07/MHA /20171027  CASE 294737 PrevRecRef is now a Temporary Rec and can be filtered, thus function added: RecExists()
    // NC2.12/MHA /20180418  CASE 308107 Adjusted Duplicate Check to use UniqueTaskBuffer
    // NC2.14/MHA /20180629  CASE 320762 GetRecRef() moved from NpXmlTriggerMgt to NcTaskMgt

    TableNo = "Nc Task";

    trigger OnRun()
    var
        NpXmlTemplate: Record "NpXml Template";
        TaskProcessor: Record "Nc Task Processor";
        UniqueTaskBuffer: Record "Nc Unique Task Buffer" temporary;
        NcTaskMgt: Codeunit "Nc Task Mgt.";
        RecRef: RecordRef;
        RecRef2: RecordRef;
        PrevRecRef: RecordRef;
        ProcessComplete: Boolean;
    begin
        TaskProcessor.Get("Task Processor Code");
        NpXmlTriggerMgt.ResetOutput();
        //-NC2.12 [308107]
        //TempDataLogRecord.DELETEALL;
        //DataLogEntryNo := 0;
        //+NC2.12 [308107]
        Clear(RecRef);
        Clear(PrevRecRef);
        NcTaskMgt.RestoreRecord("Entry No.",PrevRecRef);
        ProcessComplete := true;
        case Type of
          Type::Insert:
            begin
              //-NC2.14 [320762]
              //IF NpXmlTriggerMgt.GetRecRef("Company Name","Table No.","Record Position",RecRef) THEN BEGIN
              if NcTaskMgt.GetRecRef(Rec,RecRef) then begin
              //+NC2.14 [320762]
                //-NC2.12 [308107]
                //NpXmlTriggerMgt.RunTriggers(TaskProcessor,PrevRecRef,RecRef,Rec,TRUE,FALSE,FALSE,DataLogEntryNo,TempDataLogRecord);
                NpXmlTriggerMgt.RunTriggers(TaskProcessor,PrevRecRef,RecRef,Rec,true,false,false,UniqueTaskBuffer);
                //+NC2.12 [308107]
                ProcessComplete := NpXmlTriggerMgt.GetProcessComplete and ProcessComplete;
              end;
            end;
          Type::Modify:
            begin
              //-NC2.14 [320762]
              //IF NpXmlTriggerMgt.GetRecRef("Company Name","Table No.","Record Position",RecRef) THEN BEGIN
              if NcTaskMgt.GetRecRef(Rec,RecRef) then begin
              //+NC2.14 [320762]
                //-NC2.12 [308107]
                //NpXmlTriggerMgt.RunTriggers(TaskProcessor,PrevRecRef,RecRef,Rec,FALSE,TRUE,FALSE,DataLogEntryNo,TempDataLogRecord);
                NpXmlTriggerMgt.RunTriggers(TaskProcessor,PrevRecRef,RecRef,Rec,false,true,false,UniqueTaskBuffer);
                //+NC2.12 [308107]
                ProcessComplete := NpXmlTriggerMgt.GetProcessComplete and ProcessComplete;
              end;
            end;
          Type::Delete:
            begin
              RecRef2 := PrevRecRef.Duplicate;
              //-NC2.07 [294737]
              //IF NOT RecRef2.FIND THEN BEGIN
              if not NcTaskMgt.RecExists(RecRef2,"Company Name") then begin
              //+NC2.07 [294737]
                //-NC2.12 [308107]
                //NpXmlTriggerMgt.RunTriggers(TaskProcessor,PrevRecRef,RecRef2,Rec,FALSE,FALSE,TRUE,DataLogEntryNo,TempDataLogRecord);
                NpXmlTriggerMgt.RunTriggers(TaskProcessor,PrevRecRef,RecRef2,Rec,false,false,true,UniqueTaskBuffer);
                //+NC2.12 [308107]
                ProcessComplete := NpXmlTriggerMgt.GetProcessComplete and ProcessComplete;
              end;
            end;
          Type::Rename:
            begin
              RecRef2 := PrevRecRef.Duplicate;
              //-NC2.07 [294737]
              //IF NOT RecRef2.FIND THEN BEGIN
              if not NcTaskMgt.RecExists(RecRef2,"Company Name") then begin
              //+NC2.07 [294737]
                //-NC2.12 [308107]
                //NpXmlTriggerMgt.RunTriggers(TaskProcessor,PrevRecRef,RecRef2,Rec,FALSE,FALSE,TRUE,DataLogEntryNo,TempDataLogRecord);
                NpXmlTriggerMgt.RunTriggers(TaskProcessor,PrevRecRef,RecRef2,Rec,false,false,true,UniqueTaskBuffer);
                //+NC2.12 [308107]
                ProcessComplete := NpXmlTriggerMgt.GetProcessComplete and ProcessComplete;
              end;
              //-NC2.14 [320762]
              //IF NpXmlTriggerMgt.GetRecRef("Company Name","Table No.","Record Position",RecRef) THEN BEGIN
              if NcTaskMgt.GetRecRef(Rec,RecRef) then begin
              //+NC2.14 [320762]
                //-NC2.12 [308107]
                //NpXmlTriggerMgt.RunTriggers(TaskProcessor,PrevRecRef,RecRef,Rec,TRUE,TRUE,FALSE,DataLogEntryNo,TempDataLogRecord);
                NpXmlTriggerMgt.RunTriggers(TaskProcessor,PrevRecRef,RecRef,Rec,true,true,false,UniqueTaskBuffer);
                //+NC2.12 [308107]
                ProcessComplete := NpXmlTriggerMgt.GetProcessComplete and ProcessComplete;
              end;
            end;
        end;

        CommitOutput(Rec);
        CommitResponse(Rec);
        if not ProcessComplete then
          Error(GetLastErrorText);
    end;

    var
        NpXmlTriggerMgt: Codeunit "NpXml Trigger Mgt.";
        NpXmlValueMgt: Codeunit "NpXml Value Mgt.";

    local procedure "--- Output"()
    begin
    end;

    local procedure CommitOutput(var Task: Record "Nc Task")
    var
        OutputTempBlob: Record TempBlob temporary;
        TempBlob: Record TempBlob temporary;
        InStream: InStream;
        OutStream: OutStream;
    begin
        Clear(TempBlob);
        TempBlob.Blob.CreateOutStream(OutStream);

        Task.CalcFields("Data Output");
        if Task."Data Output".HasValue then begin
          Task."Data Output".CreateInStream(InStream);
          CopyStream(OutStream,InStream);
        end;

        if NpXmlTriggerMgt.GetOutput(OutputTempBlob) then begin
          OutputTempBlob.Blob.CreateInStream(InStream);
          CopyStream(OutStream,InStream);
        end;

        Task."Data Output" := TempBlob.Blob;
        Task.Modify(true);
        Commit;
    end;

    local procedure CommitResponse(var Task: Record "Nc Task")
    var
        ResponseTempBlob: Record TempBlob temporary;
    begin
        Clear(Task.Response);
        if NpXmlTriggerMgt.GetResponse(ResponseTempBlob) then
          Task.Response := ResponseTempBlob.Blob;
        Task.Modify(true);
        Commit;
        Clear(ResponseTempBlob);
    end;

    procedure "--- Setup"()
    begin
    end;

    procedure SetupNpXml()
    var
        NpXmlTemplate: Record "NpXml Template";
    begin
        NpXmlTemplate.SetRange("Transaction Task",true);
        if NpXmlTemplate.FindSet then
          repeat
            NpXmlTemplate.UpdateNaviConnectSetup();
          until NpXmlTemplate.Next = 0;
    end;

    local procedure "--- Unique Task"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151501, 'IsUniqueTask', '', true, true)]
    local procedure IsUniqueTask(TaskProcessor: Record "Nc Task Processor";var TempTask: Record "Nc Task" temporary;var UniqueTaskBuffer: Record "Nc Unique Task Buffer" temporary;var IsUnique: Boolean;var Checked: Boolean)
    var
        NcTaskMgt: Codeunit "Nc Task Mgt.";
        PrevRecRef: RecordRef;
        RecRef: RecordRef;
    begin
        //-NC2.12 [308107]
        if not TempTask.IsTemporary then
          exit;
        if not IsNpXmlTask(TaskProcessor,TempTask) then
          exit;

        Checked := true;

        if not NcTaskMgt.RestoreRecordFromDataLog(TempTask."Entry No.",TempTask."Company Name",PrevRecRef) then
          exit;

        //-NC2.14 [320762]
        //IF NOT NpXmlTriggerMgt.GetRecRef(TempTask."Company Name",TempTask."Table No.",TempTask."Record Position",RecRef) THEN
        if not NcTaskMgt.GetRecRef(TempTask,RecRef) then
        //+NC2.14 [320762]
          RecRef := PrevRecRef.Duplicate;

        if NpXmlTriggerMgt.IsUniqueTask(TaskProcessor,
          TempTask.Type in [TempTask.Type::Insert,TempTask.Type::Rename],
          TempTask.Type in [TempTask.Type::Modify,TempTask.Type::Rename],
          TempTask.Type in [TempTask.Type::Delete,TempTask.Type::Rename],
          PrevRecRef,
          RecRef,
          UniqueTaskBuffer)
        then
          IsUnique:= true;
        //+NC2.12 [308107]
    end;

    local procedure IsNpXmlTask(TaskProcessor: Record "Nc Task Processor";Task: Record "Nc Task"): Boolean
    var
        NcTaskSetup: Record "Nc Task Setup";
        NpXmlSetup: Record "NpXml Setup";
    begin
        //-NC2.12 [308107]
        if not (NpXmlSetup.Get and NpXmlSetup."NpXml Enabled") then
          exit(false);

        NcTaskSetup.SetRange("Task Processor Code",TaskProcessor.Code);
        NcTaskSetup.SetRange("Table No.",Task."Table No.");
        NcTaskSetup.SetRange("Codeunit ID",CODEUNIT::"NpXml Task Mgt.");
        exit(NcTaskSetup.FindFirst);
        //+NC2.12 [308107]
    end;
}

