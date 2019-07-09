codeunit 6151526 "Nc Endpoint File Mgt."
{
    // NC2.01/BR  /20160829  CASE 248630 NaviConnect
    // NC2.01/BR  /20161003  CASE 248630 Auto add directory implemented.
    // NC2.01/JC  /20161014  CASE 254997 Add support for client file location, ProcessNcEndpointTrigger & ProcessEndPointTask set Local to No
    // NC2.12/BR  /20161024  CASE 254072 Added support for textencoding
    // NC2.12/MHA /20180418  CASE 308107 Added functions FileProcessOutput(),OnRunEndpoint()
    // NC2.12/MHA /20180502  CASE 313362 Added explicit Client/Server Side definition in FileProcess() and FileProcessOutput()


    trigger OnRun()
    begin
    end;

    var
        TextFileDownloaded: Label 'The file was downloaded to %1.';
        TextFileExistsSkipped: Label 'The file was not exported because the file %1 already exists.';
        TextFileExistsOverwitten: Label 'The file was exported, overwriting the file %1 that already existed.';
        TextFileExistsAppendedSuffix: Label 'The file was exported to %1 with an appended Timestamp in the filename because the file already existed.';
        TextFileExported: Label 'The file was exported to %1.';
        TextFileNotExported: Label 'The file could not be exported to %1.';

    local procedure ProcessNcEndpoints(NcTriggerCode: Code[20];Output: Text;var NcTask: Record "Nc Task";Filename: Text)
    var
        NcTrigger: Record "Nc Trigger";
        NcEndpoint: Record "Nc Endpoint";
        NcEndpointFile: Record "Nc Endpoint File";
        NcEndpointTriggerLink: Record "Nc Endpoint Trigger Link";
    begin
        case NcTask."Table No." of
          DATABASE :: "Nc Trigger" :
            begin
              NcEndpointTriggerLink.Reset;
              NcEndpointTriggerLink.SetRange("Trigger Code",NcTriggerCode);
              if NcEndpointTriggerLink.FindSet then repeat
                if NcEndpoint.Get(NcEndpointTriggerLink."Endpoint Code") then begin
                  if NcEndpoint."Endpoint Type" = NcEndpointFile.GetEndpointTypeCode then begin
                    if NcEndpointFile.Get(NcEndpointTriggerLink."Endpoint Code") then begin
                      ProcessNcEndpointTrigger(NcTriggerCode,Output,Filename,NcTask,NcEndpointFile);
                    end;
                  end;
                end;
              until NcEndpointTriggerLink.Next = 0;
            end;
          DATABASE :: "Nc Endpoint File":
            begin
              //Process Endpoint Task
              NcEndpointFile.SetPosition(NcTask."Record Position");
              NcEndpointFile.SetRange(Code,NcEndpointFile.Code);
              NcEndpointFile.SetRange(Enabled,true);
              if NcEndpointFile.FindFirst then begin
                ProcessEndPointTask(NcEndpointFile,NcTask,Output,Filename);
                NcTask.Modify;
              end;
            end;
        end;
    end;

    procedure ProcessNcEndpointTrigger(NcTriggerCode: Code[20];Output: Text;Filename: Text;var NcTask: Record "Nc Task";NcEndpointFile: Record "Nc Endpoint File")
    var
        NcTrigger: Record "Nc Trigger";
    begin
        if not NcEndpointFile.Enabled then
          exit;
        NcTrigger.Get(NcTriggerCode);
        if not NcTrigger."Split Trigger and Endpoint" then begin
          //Process Trigger Task Directly
          FileProcess (NcTask,NcEndpointFile,Output,Filename);
          NcTask.Modify;
        end else begin
          //Insert New Task per Endpoint
          InsertEndpointTask(NcEndpointFile,NcTask,Filename);
          NcTask.Modify;
        end;
    end;

    local procedure InsertEndpointTask(var NcEndpointFile: Record "Nc Endpoint File";var NcTask: Record "Nc Task";Filename: Text)
    var
        NcTriggerSyncMgt: Codeunit "Nc Trigger Sync. Mgt.";
        NewTask: Record "Nc Task";
        TempNcEndPointFile: Record "Nc Endpoint File" temporary;
        RecRef: RecordRef;
        TextTaskInserted: Label 'File Export Task inserted for Nc Endpoint File %1 %2, to file: %3 with path %4. Nc Task Entry No. %5';
        TaskEntryNo: BigInteger;
    begin
        RecRef.Get(NcEndpointFile.RecordId);
        NcTriggerSyncMgt.InsertTask(RecRef,TaskEntryNo);
        NewTask.Get(TaskEntryNo);
        TempNcEndPointFile.Init;
        TempNcEndPointFile.Copy(NcEndpointFile);
        TempNcEndPointFile."Output Nc Task Entry No." := NcTask."Entry No.";
        if Filename <> '' then
          TempNcEndPointFile.Filename:= Filename;
        NcTriggerSyncMgt.FillFields(NewTask,TempNcEndPointFile);
        NcTriggerSyncMgt.AddResponse(NcTask,StrSubstNo(TextTaskInserted,NcEndpointFile.Code,NcEndpointFile.Description,NcEndpointFile.Filename,NcEndpointFile.Path,NewTask."Entry No."));
    end;

    procedure ProcessEndPointTask(var NcEndpointFile: Record "Nc Endpoint File";var NcTask: Record "Nc Task";Output: Text;Filename: Text)
    var
        NcTaskMgt: Codeunit "Nc Task Mgt.";
        RecRef: RecordRef;
        FldRef: FieldRef;
        TextNoOutput: Label 'FTP Task not executed because there was no output to send.';
    begin
        NcTaskMgt.RestoreRecord(NcTask."Entry No.",RecRef);
        if Output = '' then
          Error(TextNoOutput);
        FldRef := RecRef.Field(NcEndpointFile.FieldNo(Filename));
        if Format(FldRef.Value) <> '' then
          Filename := Format(FldRef.Value);
        FileProcess(NcTask,NcEndpointFile,Output,Filename);
    end;

    local procedure FileProcess(var NcTask: Record "Nc Task";NcEndpointFile: Record "Nc Endpoint File";OutputText: Text;Filename: Text)
    var
        NcTriggerSyncMgt: Codeunit "Nc Trigger Sync. Mgt.";
        FileMgt: Codeunit "File Management";
        Encoding: DotNet npNetEncoding;
        StreamWriter: DotNet npNetStreamWriter;
        Tempfile: File;
        ExportFile: File;
        DirectoryPathfromFile: Text;
        FullName: Text;
        ResponseDescriptionText: Text;
        ResponseCodeText: Text;
        ToFile: Text;
    begin
        NcEndpointFile.TestField(Path);
        //-NC2.12 [313362]
        // //-NC2.01 [#254997]
        // IF COPYSTR(NcEndpointFile.Path,1,1) <> '\' THEN BEGIN
        //  LocalPath := TRUE;
        //  Tempfile.CREATETEMPFILE();
        //  FullName := Tempfile.NAME;
        //  Tempfile.CLOSE();
        // END ELSE BEGIN
        // //+NC2.01 [#254997]
        //  FullName := STRSUBSTNO('%1\%2',DELCHR(NcEndpointFile.Path,'>','\'),Filename);
        //  IF STRLEN(Filename) = (STRLEN(DELCHR(Filename,'=','\')) + 1) THEN BEGIN
        //    DirectoryPathfromFile := NcEndpointFile.Path + '\' + COPYSTR(Filename,1,STRPOS(Filename,'\')-1);
        //    IF NOT FileMgt.ServerDirectoryExists(NcEndpointFile.Path + '\' + DirectoryPathfromFile) THEN
        //      FileMgt.ServerCreateDirectory(DirectoryPathfromFile);
        //  END;
        // END;
        if NcEndpointFile."Client Path" then begin
          Tempfile.CreateTempFile();
          FullName := Tempfile.Name;
          Tempfile.Close();
        end else begin
          FullName := StrSubstNo('%1\%2',DelChr(NcEndpointFile.Path,'>','\'),Filename);
          if StrLen(Filename) = (StrLen(DelChr(Filename,'=','\')) + 1) then begin
            DirectoryPathfromFile := NcEndpointFile.Path + '\' + CopyStr(Filename,1,StrPos(Filename,'\')-1);
            if not FileMgt.ServerDirectoryExists(NcEndpointFile.Path + '\' + DirectoryPathfromFile) then
              FileMgt.ServerCreateDirectory(DirectoryPathfromFile);
          end;
        end;
        //+NC2.12 [313362]

        if Exists(FullName) then begin
          case NcEndpointFile."Handle Exiting File" of
            NcEndpointFile."Handle Exiting File"  :: KeepExisting :
              begin
                NcTriggerSyncMgt.AddResponse(NcTask,ConvertStr(StrSubstNo(TextFileExistsSkipped,FullName),'\','/'));
                exit;
              end;
            NcEndpointFile."Handle Exiting File"  :: AddSuffix :
              begin
                FullName := AddSuffixToFileName(FullName);
                NcTriggerSyncMgt.AddResponse(NcTask,ConvertStr(StrSubstNo(TextFileExistsAppendedSuffix,FullName),'\','/'));
              end;
            NcEndpointFile."Handle Exiting File"  :: Replace :
              begin
                Erase(FullName);
                NcTriggerSyncMgt.AddResponse(NcTask,ConvertStr(StrSubstNo(TextFileExistsOverwitten,FullName),'\','/'));
              end;
          end;
        end else begin
          NcTriggerSyncMgt.AddResponse(NcTask,ConvertStr(StrSubstNo(TextFileExported,FullName),'\','/'));
        end;
        ExportFile.Create(FullName);
        ExportFile.Close;
        //-NC2.12 [#254072]
        case NcEndpointFile."File Encoding" of
          NcEndpointFile."File Encoding"::ANSI: Encoding := Encoding.GetEncoding('windows-1252');
          NcEndpointFile."File Encoding"::Unicode: Encoding := Encoding.Unicode;
          NcEndpointFile."File Encoding"::UTF8: Encoding := Encoding.UTF8;
        end;
        StreamWriter := StreamWriter.StreamWriter(FullName,true,Encoding);
        StreamWriter.Write(OutputText);
        StreamWriter.Flush;
        StreamWriter.Close;
        //+NC2.12 [#254072]

        //-NC2.12 [313362]
        // //-NC2.01 [#254997]
        // IF LocalPath THEN BEGIN
        //  ToFile:=NcEndpointFile.Path + Filename;
        //  FileMgt.CopyServerFile(FullName,FullName+'.file', TRUE);
        //  //-NC2.12 [#254072]
        //  ExportFile.OPEN(FullName);
        //  //+NC2.12 [#254072]
        //  FileMgt.DownloadToFile(ExportFile.NAME +'.file', ToFile);
        //  ExportFile.CLOSE;
        //  ERASE(FullName);
        //  //-NC2.12 [#254072]
        //  NcTriggerSyncMgt.AddResponse(NcTask,NewLine() + STRSUBSTNO(TextFileDownloaded,CONVERTSTR(ToFile,'\','/')));
        //  //+NC2.12 [#254072]
        // END;
        // //+NC2.01 [#254997]
        if NcEndpointFile."Client Path" then begin
          ToFile := NcEndpointFile.Path + Filename;
          FileMgt.CopyServerFile(FullName,FullName+'.file',true);
          ExportFile.Open(FullName);
          FileMgt.DownloadToFile(ExportFile.Name +'.file',ToFile);
          ExportFile.Close;
          Erase(FullName);
          NcTriggerSyncMgt.AddResponse(NcTask,NewLine() + StrSubstNo(TextFileDownloaded,ConvertStr(ToFile,'\','/')));
        end;
        //+NC2.12 [313362]
    end;

    local procedure FileProcessOutput(NcTaskOutput: Record "Nc Task Output";NcEndpointFile: Record "Nc Endpoint File")
    var
        TempBlob: Record TempBlob temporary;
        FileMgt: Codeunit "File Management";
        Encoding: DotNet npNetEncoding;
        StreamReader: DotNet npNetStreamReader;
        StreamWriter: DotNet npNetStreamWriter;
        Tempfile: File;
        ExportFile: File;
        InStream: InStream;
        DirectoryPathfromFile: Text;
        FullName: Text;
        ToFile: Text;
        ReturnValue: Boolean;
    begin
        //-NC2.12 [308107]
        NcEndpointFile.TestField(Path);
        //-NC2.12 [313362]
        // IF COPYSTR(NcEndpointFile.Path,1,1) <> '\' THEN BEGIN
        //  LocalPath := TRUE;
        //  Tempfile.CREATETEMPFILE();
        //  FullName := Tempfile.NAME;
        //  Tempfile.CLOSE();
        // END ELSE BEGIN
        //  FullName := STRSUBSTNO('%1\%2',DELCHR(NcEndpointFile.Path,'>','\'),NcTaskOutput.Name);
        //  IF STRLEN(NcTaskOutput.Name) = (STRLEN(DELCHR(NcTaskOutput.Name,'=','\')) + 1) THEN BEGIN
        //    DirectoryPathfromFile := NcEndpointFile.Path + '\' + COPYSTR(NcTaskOutput.Name,1,STRPOS(NcTaskOutput.Name,'\')-1);
        //    IF NOT FileMgt.ServerDirectoryExists(NcEndpointFile.Path + '\' + DirectoryPathfromFile) THEN
        //      FileMgt.ServerCreateDirectory(DirectoryPathfromFile);
        //  END;
        // END;
        if NcEndpointFile."Client Path" then begin
          Tempfile.CreateTempFile();
          FullName := Tempfile.Name;
          Tempfile.Close();
        end else begin
          FullName := StrSubstNo('%1\%2',DelChr(NcEndpointFile.Path,'>','\'),NcTaskOutput.Name);
          if StrLen(NcTaskOutput.Name) = (StrLen(DelChr(NcTaskOutput.Name,'=','\')) + 1) then begin
            DirectoryPathfromFile := NcEndpointFile.Path + '\' + CopyStr(NcTaskOutput.Name,1,StrPos(NcTaskOutput.Name,'\')-1);
            if not FileMgt.ServerDirectoryExists(NcEndpointFile.Path + '\' + DirectoryPathfromFile) then
              FileMgt.ServerCreateDirectory(DirectoryPathfromFile);
          end;
        end;
        //+NC2.12 [313362]

        if Exists(FullName) then begin
          case NcEndpointFile."Handle Exiting File" of
            NcEndpointFile."Handle Exiting File"::KeepExisting:
              exit;
            NcEndpointFile."Handle Exiting File"::AddSuffix:
              FullName := AddSuffixToFileName(FullName);
            NcEndpointFile."Handle Exiting File"::Replace:
              Erase(FullName);
          end;
        end;

        //-NC2.12 [313362]
        //TempBlob.Blob := NcTaskOutput.Data;
        //FileMgt.BLOBExportToServerFile(TempBlob,FullName);
        //
        // IF LocalPath THEN BEGIN
        //  ToFile := NcEndpointFile.Path + NcTaskOutput.Name;
        //  FileMgt.CopyServerFile(FullName,FullName+'.file', TRUE);
        //  ExportFile.OPEN(FullName);
        //  FileMgt.DownloadToFile(ExportFile.NAME +'.file', ToFile);
        //  ExportFile.CLOSE;
        //  ERASE(FullName);
        // END;
        NcTaskOutput.Data.CreateInStream(InStream);
        ExportFile.Create(FullName);
        ExportFile.Close;
        case NcEndpointFile."File Encoding" of
          NcEndpointFile."File Encoding"::ANSI: Encoding := Encoding.GetEncoding('windows-1252');
          NcEndpointFile."File Encoding"::Unicode: Encoding := Encoding.Unicode;
          NcEndpointFile."File Encoding"::UTF8: Encoding := Encoding.UTF8;
        end;
        StreamWriter := StreamWriter.StreamWriter(FullName,true,Encoding);
        CopyStream(StreamWriter.BaseStream,InStream);
        StreamWriter.Flush;
        StreamWriter.Close;

        if NcEndpointFile."Client Path" then begin
          ToFile := NcEndpointFile.Path + NcTaskOutput.Name;
          FileMgt.CopyServerFile(FullName,FullName+'.file', true);
          ExportFile.Open(FullName);
          FileMgt.DownloadToFile(ExportFile.Name +'.file', ToFile);
          ExportFile.Close;
          Erase(FullName);
        end;
        //+NC2.12 [313362]
        //+NC2.12 [308107]
    end;

    local procedure AddSuffixToFileName(FilePath: Text): Text
    var
        Suffix: Text;
        FileMgt: Codeunit "File Management";
    begin
        Suffix := Format(CurrentDateTime,0,'<Year4><Month,2><Day,2>-<Hours24,2><Minutes,2><Seconds,2>');
        exit(FileMgt.GetDirectoryName(FilePath) +
              '\' + FileMgt.GetFileNameWithoutExtension(FilePath) +
             Suffix + '.' + FileMgt.GetExtension(FilePath));
    end;

    local procedure "---Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151522, 'OnAfterGetOutputTriggerTask', '', false, false)]
    local procedure OnAfterGetOutputTriggerTaskFileOutput(NcTriggerCode: Code[20];Output: Text;var NcTask: Record "Nc Task";Filename: Text;Subject: Text;Body: Text)
    begin
        ProcessNcEndpoints(NcTriggerCode,Output,NcTask,Filename);
    end;

    [EventSubscriber(ObjectType::Table, 6151531, 'OnSetupEndpointTypes', '', false, false)]
    local procedure OnSetupEndpointTypeInsertEndpointTypeCode()
    var
        NcEndpointFile: Record "Nc Endpoint File";
        NcEndpointType: Record "Nc Endpoint Type";
    begin
        if not NcEndpointType.Get(NcEndpointFile.GetEndpointTypeCode) then begin
          NcEndpointType.Init;
          NcEndpointType.Code := NcEndpointFile.GetEndpointTypeCode;
          NcEndpointType.Insert;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6151533, 'OnOpenEndpointSetup', '', false, false)]
    local procedure OnOpenEndpointSetupOpenPage(var Sender: Record "Nc Endpoint";var Handled: Boolean)
    var
        NcEndpointFile: Record "Nc Endpoint File";
    begin
        if Handled then
          exit;
        if Sender."Endpoint Type" <> NcEndpointFile.GetEndpointTypeCode then
          exit;
        if not NcEndpointFile.Get(Sender.Code) then begin
          NcEndpointFile.Init;
          NcEndpointFile.Validate(Code,Sender.Code);
          NcEndpointFile.Description := Sender.Description;
          NcEndpointFile.Insert;
        end else begin
          if NcEndpointFile.Description <> Sender.Description then begin
            NcEndpointFile.Description := Sender.Description;
            NcEndpointFile.Modify(true);
          end;
        end;
        PAGE.Run(PAGE::"Nc Endpoint File Card", NcEndpointFile);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, 6151533, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnDeleteEndpoint(var Rec: Record "Nc Endpoint";RunTrigger: Boolean)
    var
        NcEndpointFile: Record "Nc Endpoint File";
    begin
        if NcEndpointFile.Get(Rec.Code) then
          NcEndpointFile.Delete(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151519, 'OnRunEndpoint', '', true, true)]
    local procedure OnRunEndpoint(NcTaskOutput: Record "Nc Task Output";NcEndpoint: Record "Nc Endpoint")
    var
        NcEndpointFile: Record "Nc Endpoint File";
    begin
        //-NC2.12 [308107]
        if NcEndpoint."Endpoint Type" <> NcEndpointFile.GetEndpointTypeCode() then
          exit;
        if not NcEndpointFile.Get(NcEndpoint.Code) then
          exit;

        FileProcessOutput(NcTaskOutput,NcEndpointFile);
        //+NC2.12 [308107]
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure NewLine() CRLF: Text
    begin
        //-NC2.12 [#254072]
        CRLF[1] := 13;
        CRLF[2] := 10;
        exit(CRLF);
        //+NC2.12 [#254072]
    end;
}

