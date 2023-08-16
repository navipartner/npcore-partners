codeunit 6151505 "NPR Nc Sync. Mgt."
{
    var
        FtpBackupErr: Label 'Error during Ftp Backup (%1):\\%2', Comment = '%1=Filename;%2=GetLastErrorText()';
        FileIsNotValidErr: Label 'File %1 is not valid', Comment = '%1=FileName';
        SyncEndTime: DateTime;
        AuthorizationFailedErrorText: Label 'Authorization failed. Wrong FTP username/password.';
        FTPClient: Codeunit "NPR AF FTP Client";
        SFTPClient: Codeunit "NPR AF Sftp Client";

    #region "Download Ftp"

    internal procedure DownloadFtpType(ImportType: Record "NPR Nc Import Type"): Boolean
    var
        TempImportEntry: Record "NPR Nc Import Entry" temporary;
        Filename: Text;
        ListOfDirectory: List of [Text];
    begin
        ClearLastError();
        if ImportType."Ftp Filename" <> '' then
            ListOfDirectory.Add(ImportType."Ftp Filename")
        else
            ListDirectory(ImportType, ListOfDirectory);

        OnBeforeDownloadDirectory(ImportType, ListOfDirectory);
        foreach Filename in ListOfDirectory do
            if DownloadFileToImportEntry(TempImportEntry, ImportType, Filename) then
                SaveNewEntry(TempImportEntry);

        if GetLastErrorText() = '' then
            exit(true);

        if GuiAllowed then
            Error(GetLastErrorText());

        exit(false);
    end;

    local procedure SaveNewEntry(var ImportEntryTmp: Record "NPR Nc Import Entry" temporary)
    begin
        StoreImportEntries(ImportEntryTmp);
        Commit();
    end;

    local procedure DownloadFileToImportEntry(var TempImportEntry: Record "NPR Nc Import Entry" temporary; ImportType: Record "NPR Nc Import Type"; Filename: Text): Boolean
    var
        ftpConn: Record "NPR FTP Connection";
        sftpConn: Record "NPR SFTP Connection";
    begin

        if (ImportType."Ftp Enabled" and ftpConn.Get(ImportType."FTP Connection")) then
            exit(TryImportNewEntryFtp(TempImportEntry, ImportType, Filename));
        if (ImportType."Sftp Enabled" and sftpConn.Get(ImportType."SFTP Connection")) then
            exit(TryImportNewEntrySftp(TempImportEntry, ImportType, Filename));

    end;

    [TryFunction]
    internal procedure TryImportNewEntryFtp(var TempImportEntry: Record "NPR Nc Import Entry" temporary; ImportType: Record "NPR Nc Import Type"; Filename: Text)
    var
        Path: Text;
        NewPath: Text;
        DirPath: Text;
        OutStr: OutStream;
        Base64Convert: Codeunit "Base64 Convert";
        FTPResponse: JsonObject;
        JToken: JsonToken;
        ResponseCodeText: Text;
        FileContent: Text;
        FTPConn: Record "NPR FTP Connection";
        NoConLbl: Label 'No FTP Connection is specified.';
        MakeFtpUrlErr: Label 'Creation of directory %1 failed.\\(%2)', Comment = '%1=Foldername;%2=GetLastErrorText()';
    begin
        if not ValidFilename(Filename) then
            Error(FileIsNotValidErr, Filename);
        if (not FTPConn.Get(ImportType."FTP Connection")) then
            Error(NoConLbl);

        FTPClient.Construct(FTPConn."Server Host", FTPConn.Username, FTPConn.Password, FTPConn."Server Port", 10000, FTPConn."FTP Passive Transfer Mode", FTPConn."FTP Enc. Mode");
        DirPath := ManagePathSlashes(ImportType."Ftp Path");
        Path := DirPath + Filename;
        FTPResponse := FTPClient.DownloadFile(Path);

        FTPResponse.Get('StatusCode', JToken);
        ResponseCodeText := JToken.AsValue().AsText();

        case ResponseCodeText of
            '200':
                FTPResponse.Get('base64String', JToken);
            '401':
                Error(AuthorizationFailedErrorText);
            else begin
                FTPResponse.Get('Error', JToken);
                Error(JToken.AsValue().AsText());
            end;
        end;

        Clear(TempImportEntry);
        TempImportEntry."Import Type" := ImportType.Code;
        TempImportEntry.Date := CurrentDateTime;
        TempImportEntry."Document Name" := GetDocName(Filename, MaxStrLen(TempImportEntry."Document Name"));
        TempImportEntry.Imported := false;
        TempImportEntry."Runtime Error" := false;
        TempImportEntry."Document Source".CreateOutStream(OutStr, TextEncoding::UTF8);

        FileContent := Base64Convert.FromBase64(JToken.AsValue().AsText());
        OutStr.WriteText(FileContent);

        if ImportType."Ftp Backup Dir Path" = '' then begin
            if not DeleteFtpFile(Path) then
                Error(FtpBackupErr, Filename, GetLastErrorText());
        end else begin
            NewPath := ImportType."Ftp Backup Dir Path" + Filename;
            if not FtpDirExists(ImportType."Ftp Backup Dir Path") then
                if not MakeFtpUrl(ImportType."Ftp Backup Dir Path") then
                    Error(MakeFtpUrlErr, ImportType."Ftp Backup Dir Path", GetLastErrorText());

            if not RenameFtpFile(Path, NewPath) then
                Error(FtpBackupErr, Filename, GetLastErrorText());
        end;

        TempImportEntry.Insert();
        FTPClient.Destruct();
    end;

    [TryFunction]
    internal procedure TryImportNewEntrySftp(var TempImportEntry: Record "NPR Nc Import Entry" temporary; ImportType: Record "NPR Nc Import Type"; Filename: Text)
    var
        OutStr: OutStream;
        Path: Text;
        NewPath: Text;
        DirPath: Text;
        SFTPConn: Record "NPR SFTP Connection";
        SFTPJson: JsonObject;
        Blobber: Codeunit "Temp Blob";
        InS: InStream;
        NoConLbl: Label 'No SFTP Connection is specified.';
    begin
        if not ValidFilename(Filename) then
            Error(FileIsNotValidErr, Filename);
        if (not SFTPConn.Get(ImportType."SFTP Connection")) then
            Error(NoConLbl);

        SFTPJson := SFTPClient.GetFileServerJsonRequest(SFTPConn);
        DirPath := ManagePathSlashes(ImportType."Ftp Path");
        Path := DirPath + Filename;
        SFTPClient.DownloadFile(Path, Blobber, SFTPJson);

        Clear(TempImportEntry);
        TempImportEntry."Import Type" := ImportType.Code;
        TempImportEntry.Date := CurrentDateTime;
        TempImportEntry."Document Name" := GetDocName(Filename, MaxStrLen(TempImportEntry."Document Name"));
        TempImportEntry.Imported := false;
        TempImportEntry."Runtime Error" := false;
        TempImportEntry."Document Source".CreateOutStream(OutStr, TextEncoding::UTF8);

        Blobber.CreateInStream(InS);
        CopyStream(OutStr, InS);

        if ImportType."Ftp Backup Dir Path" = '' then
            SFTPClient.DeleteFile(Path, SFTPJson)
        else begin
            NewPath := ImportType."Ftp Backup Dir Path" + Filename;
            SFTPClient.MoveFile(Path, NewPath, SFTPJson);
        end;

        TempImportEntry.Insert();
    end;
    #endregion "Download Ftp"

    local procedure StoreImportEntries(var NcImportEntryTmp: Record "NPR Nc Import Entry" temporary)
    var
        NcImportEntry: Record "NPR Nc Import Entry";
        MustBeTemporaryErr: Label '%1: function call on a non-temporary variable. This is a programming bug, not a user error. Please contact system vendor.';
    begin
        if not NcImportEntryTmp.IsTemporary then
            Error(MustBeTemporaryErr, 'CU6151505.StoreImportEntries');
        if not NcImportEntryTmp.FindSet() then
            exit;
        repeat
            NcImportEntryTmp.CalcFields("Document Source");
            NcImportEntry := NcImportEntryTmp;
            NcImportEntry."Entry No." := 0;
            NcImportEntry.Insert(true);
        until NcImportEntryTmp.Next() = 0;
        NcImportEntryTmp.DeleteAll();
    end;

    #region "Process Import"
    procedure ProcessImportEntry(var ImportEntry: Record "NPR Nc Import Entry"): Boolean
    begin
        Codeunit.Run(Codeunit::"NPR Nc Import Processor", ImportEntry);
        if ImportEntry.Get(ImportEntry."Entry No.") then
            exit(ImportEntry.Imported);

        exit(false);
    end;

    procedure ProcessTask(var Task: Record "NPR Nc Task"): Boolean
    var
        TaskSetup: Record "NPR Nc Task Setup";
    begin
        OnBeforeProcessTask(Task);
        TaskReset(Task);
        TaskSetup.SetCurrentKey("Task Processor Code", "Table No.", "Codeunit ID");
        TaskSetup.SetRange("Task Processor Code", Task."Task Processor Code");
        TaskSetup.SetRange("Table No.", Task."Table No.");
        if TaskSetup.FindSet() then
            repeat
                // Due to NST caching and the possiblity that another
                // NST has updated the records in the meantime, we
                // skip caching here.
                SelectLatestVersion();

                if Task.Get(Task."Entry No.") then;
                ClearLastError();
                if not Codeunit.Run(TaskSetup."Codeunit ID", Task) then begin
                    TaskError(Task);
                    exit(false);
                end;
            until TaskSetup.Next() = 0;
        TaskComplete(Task);
        exit(true);
    end;

    internal procedure ProcessTasks(TaskProcessor: Record "NPR Nc Task Processor"; MaxRetry: Integer)
    var
        Task: Record "NPR Nc Task";
        Task2: Record "NPR Nc Task";
    begin
        if MaxRetry < 1 then
            MaxRetry := 1;

        SyncEndTime := CurrentDateTime() + GetMaxSyncDuration();

        Task.SetCurrentKey("Task Processor Code", Processed);
        Task.SetRange("Task Processor Code", TaskProcessor.Code);
        Task.SetRange(Processed, false);
        Task.SetFilter("Process Count", '<%1', MaxRetry);
        if Task.FindSet() then
            repeat
                Task2 := Task;
                ProcessTask(Task2);
                if (CurrentDateTime > SyncEndTime) and (SyncEndTime <> 0DT) then
                    exit;
            until Task.Next() = 0;
    end;
    #endregion "Process Import"

    #region "Status Mgt."
    local procedure TaskComplete(var NaviConnectTask: Record "NPR Nc Task")
    begin
        NaviConnectTask.LockTable();
        if not NaviConnectTask.Get(NaviConnectTask."Entry No.") then
            exit;
        NaviConnectTask."Last Processing Completed at" := CurrentDateTime;
        NaviConnectTask."Last Processing Duration" := (NaviConnectTask."Last Processing Completed at" - NaviConnectTask."Last Processing Started at") / 1000;
        NaviConnectTask.Processed := true;
        NaviConnectTask."Process Error" := false;
        NaviConnectTask.Modify(true);
        Commit();
    end;

    local procedure TaskError(var NaviConnectTask: Record "NPR Nc Task")
    var
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
        OutStream: OutStream;
        ErrorText: Text;
        SkipErrorClearing: Boolean;
    begin
        NaviConnectTask.LockTable();
        if not NaviConnectTask.Get(NaviConnectTask."Entry No.") then
            exit;

        NaviConnectTask."Last Processing Completed at" := CurrentDateTime;
        NaviConnectTask."Last Processing Duration" := (NaviConnectTask."Last Processing Completed at" - NaviConnectTask."Last Processing Started at") / 1000;

        ErrorText := GetLastErrorText;

        if ErrorText <> '' then begin
            NaviConnectTask.Response.CreateOutStream(OutStream);
            OutStream.Write(ErrorText);
            OnBeforeClearLastErrorInTaskError(SkipErrorClearing);
            if not SkipErrorClearing then
                ClearLastError();

            NcTaskMgt.EmitTelemetryDataOnError(NaviConnectTask, ErrorText, Verbosity::Error);
        end;

        NaviConnectTask.Modify(true);
        Commit();
    end;

    local procedure TaskReset(var NaviConnectTask: Record "NPR Nc Task")
    begin
        NaviConnectTask.LockTable();
        if not NaviConnectTask.Get(NaviConnectTask."Entry No.") then
            exit;
        Clear(NaviConnectTask."Data Output");
        Clear(NaviConnectTask.Response);
        NaviConnectTask."Last Processing Started at" := CurrentDateTime;
        NaviConnectTask."Last Processing Completed at" := 0DT;
        NaviConnectTask."Last Processing Duration" := 0;
        NaviConnectTask.Processed := false;
        NaviConnectTask."Process Error" := true;
        NaviConnectTask."Process Count" += 1;
        NaviConnectTask.Modify(true);
        Commit();
    end;

    internal procedure TaskResetCount()
    var
        NaviConnectTask: Record "NPR Nc Task";
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
    begin
        NcTaskMgt.CleanTasks();
        Commit();

        NaviConnectTask.SetCurrentKey("Log Date", Processed);
        NaviConnectTask.SetRange(Processed, false);
        NaviConnectTask.ModifyAll("Process Count", 0);
        Commit();
    end;

    internal procedure UpdateTaskProcessor(var TaskProcessor: Record "NPR Nc Task Processor")
    var
        NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
        TaskProcDescrLbl: Label 'NaviConnect Default';
    begin
        if TaskProcessor.Find() then
            exit;

        if TaskProcessor.Code in ['', NcSetupMgt.NaviConnectDefaultTaskProcessorCode()] then begin
            TaskProcessor.Init();
            TaskProcessor.Code := NcSetupMgt.NaviConnectDefaultTaskProcessorCode();
            TaskProcessor.Description := TaskProcDescrLbl;
        end;
        TaskProcessor.Insert(true);
    end;
    #endregion "Status Mgt."

    #region "Ftp List"
    local procedure ListDirectory(NcImportType: Record "NPR Nc Import Type"; var ListDirectoryDetails: List of [Text]): Boolean
    var
        ftpConn: Record "NPR FTP Connection";
        sftpConn: Record "NPR SFTP Connection";
    begin
        if (NcImportType."Ftp Enabled" and ftpConn.Get(NcImportType."FTP Connection")) then
            exit(DownloadFtpListDirectoryDetails(NcImportType, ListDirectoryDetails));
        if (NcImportType."Sftp Enabled" and sftpConn.Get(NcImportType."SFTP Connection")) then
            exit(DownloadSftpFilenames(NcImportType, ListDirectoryDetails));
    end;

    [TryFunction]
    local procedure DownloadFtpListDirectoryDetails(ImportType: Record "NPR Nc Import Type"; var ListDirectoryDetails: List of [Text])
    var
        FTPResponse: JsonObject;
        FileObject: JsonObject;
        JToken: JsonToken;
        JArray: JsonArray;
        i: Integer;
        ResponseCodeText: Text;
        FTPConn: Record "NPR FTP Connection";
        NoConLbl: Label 'No FTP Connection is specified.';
    begin
        Clear(ListDirectoryDetails);

        if not ImportType."Ftp Enabled" then
            exit;
        if (not FTPConn.Get(ImportType."FTP Connection")) then
            Error(NoConLbl);
        FTPClient.Construct(FTPConn."Server Host", FTPConn.Username, FTPConn.Password, FTPConn."Server Port", 10000, FTPConn."FTP Passive Transfer Mode", FTPConn."FTP Enc. Mode");

        FTPResponse := FTPClient.ListDirectory(ManagePathSlashes(ImportType."Ftp Path"));

        FTPResponse.Get('StatusCode', JToken);
        ResponseCodeText := JToken.AsValue().AsText();

        FTPClient.Destruct();

        case ResponseCodeText of
            '200':
                begin
                    FTPResponse.Get('Files', JToken);
                    JArray := JToken.AsArray();

                    for i := 0 to JArray.Count - 1 do begin
                        JArray.Get(i, JToken);
                        FileObject := JToken.AsObject();

                        FileObject.Get('IsDirectory', JToken);
                        if not JToken.AsValue().AsBoolean() then begin
                            FileObject.Get('Name', JToken);
                            ListDirectoryDetails.Add(JToken.AsValue().AsText());
                        end;
                    end;
                end;
            '401':
                Error(AuthorizationFailedErrorText);
            else begin
                FTPResponse.Get('Error', JToken);
                Error(JToken.AsValue().AsText());
            end;
        end;
    end;

    [TryFunction]
    local procedure DownloadSftpFilenames(ImportType: Record "NPR Nc Import Type"; var ParamListDirectory: List of [Text])
    var
        RemotePath: Text;
        FileObject: JsonObject;
        JToken: JsonToken;
        JArray: JsonArray;
        i: Integer;
        SFTPConn: Record "NPR SFTP Connection";
        SFTPJson: JsonObject;
        NoConLbl: Label 'No SFTP Connection is specified.';
    begin
        if (not SFTPConn.Get(ImportType."SFTP Connection")) then
            Error(NoConLbl);
        SFTPJson := SFTPClient.GetFileServerJsonRequest(SFTPConn);

        RemotePath := ManagePathSlashes(ImportType."Ftp Path");

        SFTPClient.ListDirectory(RemotePath, JArray, SFTPJson);

        for i := 0 to JArray.Count - 1 do begin
            JArray.Get(i, JToken);
            FileObject := JToken.AsObject();

            FileObject.Get('IsDirectory', JToken);
            if not JToken.AsValue().AsBoolean() then begin
                FileObject.Get('Name', JToken);
                ParamListDirectory.Add(JToken.AsValue().AsText());
            end;
        end;
    end;

    local procedure ManagePathSlashes(RemotePath: Text) FormattedPath: Text
    begin
        if StrPos(RemotePath, '/') > 1 then
            FormattedPath := '/';
        FormattedPath += RemotePath;
        if CopyStr(FormattedPath, StrLen(FormattedPath), 1) <> '/' then
            FormattedPath += '/';
    end;

    local procedure ValidFilename(Filename: Text): Boolean
    var
        Position: Integer;
    begin
        if Filename = '' then
            exit(false);

        Position := StrPos(Filename, '.');
        if (Position = 1) or (Position = 0) then
            exit(false);
        if Position = StrLen(Filename) then
            exit(false);

        exit(true);
    end;
    #endregion "Ftp List"

    local procedure FtpDirExists(FtpUrl: Text): Boolean
    var
        FolderExist: Boolean;
        FtpUrlExistsErr: Label 'Test of directory exists failed (%1):\\(%2)', Comment = '%1=Foldername;%2=GetLastErrorText()';
    begin
        if not TryFtpDirExists(FtpUrl, FolderExist) then
            Error(FtpUrlExistsErr, FtpUrl, GetLastErrorText());
        exit(FolderExist);
    end;

    #region Aux
    [TryFunction]
    local procedure TryFtpDirExists(FtpUrl: Text; var FolderExist: Boolean)
    var
        FTPResponse: JsonObject;
        JToken: JsonToken;
        ResponseCodeText: Text;
    begin
        FTPResponse := FTPClient.DirectoryExists(FtpUrl);

        FTPResponse.Get('StatusCode', JToken);
        ResponseCodeText := JToken.AsValue().AsText();

        case ResponseCodeText of
            '200':
                begin
                    FTPResponse.Get('Exists', JToken);
                    FolderExist := JToken.AsValue().AsBoolean();
                end;
            '401':
                Error(AuthorizationFailedErrorText);
            else begin
                FTPResponse.Get('Error', JToken);
                Error(JToken.AsValue().AsText());
            end;
        end;
    end;

    [TryFunction]
    local procedure DeleteFtpFile(FtpUrl: Text)
    var
        FTPResponse: JsonObject;
        JToken: JsonToken;
        ResponseCodeText: Text;
    begin
        FTPResponse := FTPClient.DeleteFile(FtpUrl);

        FTPResponse.Get('StatusCode', JToken);
        ResponseCodeText := JToken.AsValue().AsText();
        if ResponseCodeText <> '200' then
            Error(ResponseCodeText);
    end;

#pragma warning disable AA0139
    local procedure GetDocName(Filename: Text; MaxLength: Integer) DocName: Text[100]
    var
        FileMgt: Codeunit "File Management";
        DocExt: Text;
    begin
        DocName := Filename;
        if MaxLength <= 0 then
            exit(DocName);
        if StrLen(DocName) <= MaxLength then
            exit(DocName);

        DocExt := FileMgt.GetExtension(DocName);
        if DocExt <> '' then
            DocExt := '.' + DocExt;
        DocName := CopyStr(FileMgt.GetFileNameWithoutExtension(DocName), 1, MaxLength - StrLen(DocExt));
        DocName += DocExt;

        exit(DocName);
    end;
#pragma warning restore AA0139

    [TryFunction]
    local procedure MakeFtpUrl(FtpUrl: Text)
    var
        FTPResponse: JsonObject;
        JToken: JsonToken;
        ResponseCodeText: Text;
    begin
        FTPResponse := FTPClient.CreateDirectory(FtpUrl);

        FTPResponse.Get('StatusCode', JToken);
        ResponseCodeText := JToken.AsValue().AsText();
        if ResponseCodeText <> '200' then
            Error(ResponseCodeText);
    end;

    [TryFunction]
    local procedure RenameFtpFile(Path: Text; NewPath: Text)
    var
        FTPResponse: JsonObject;
        JToken: JsonToken;
        ResponseCodeText: Text;
    begin
        FTPResponse := FTPClient.RenameFile(Path, NewPath);

        FTPResponse.Get('StatusCode', JToken);
        ResponseCodeText := JToken.AsValue().AsText();

        if ResponseCodeText <> '200' then
            Error(ResponseCodeText);
    end;
    #endregion Aux

    #region Constants
    internal procedure "Parameter.DownloadFtp"(): Code[20]
    begin
        exit('DOWNLOAD_FTP');
    end;

    internal procedure "Parameter.DownloadType"(): Code[20]
    begin
        exit('DOWNLOAD_IMPORT_TYPE');
    end;

    internal procedure "Parameter.ImportNewTasks"(): Code[20]
    begin
        exit('IMPORT_NEW_TASKS');
    end;

    internal procedure "Parameter.ProcessTasks"(): Code[20]
    begin
        exit('PROCESS_TASKS');
    end;

    internal procedure "Parameter.ResetTaskCount"(): Code[20]
    begin
        exit('RESET_RETRY_COUNT');
    end;

    internal procedure "Parameter.TaskRetryCount"(): Code[20]
    begin
        exit('TASK_RETRY_COUNT');
    end;
    #endregion Constants

    #region UI
    local procedure GetMaxSyncDuration(): Duration
    begin
        exit(120000T - 113000T);
    end;
    #endregion UI

    #region events
    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessTask(var Task: Record "NPR Nc Task")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeClearLastErrorInTaskError(var SkipErrorClearing: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDownloadDirectory(ImportType: Record "NPR Nc Import Type"; var ListOfDirectory: List of [Text])
    begin
    end;
    #endregion events
}
