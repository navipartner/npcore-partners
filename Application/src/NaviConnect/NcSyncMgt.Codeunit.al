codeunit 6151505 "NPR Nc Sync. Mgt."
{
    var
        FtpBackupErr: Label 'Error during Ftp Backup (%1):\\%2', Comment = '%1=Filename;%2=GetLastErrorText()';
        FileIsNotValidErr: Label 'File %1 is not valid', Comment = '%1=FileName';
        SyncEndTime: DateTime;
        AuthorizationFailedErrorText: Label 'Authorization failed. Wrong FTP username/password.';
        FTPClient: Codeunit "NPR AF FTP Client";
        SFTPClient: Codeunit "NPR AF SFTP Client";

    #region "Download Ftp"

    procedure DownloadFtpType(ImportType: Record "NPR Nc Import Type"): Boolean
    var
        TempImportEntry: Record "NPR Nc Import Entry" temporary;
        Filename: Text;
        ListOfDirectory: List of [Text];
    begin
        case true of
            ImportType."Ftp Filename" <> '':
                if TryImportNewEntry(TempImportEntry, ImportType, ImportType."Ftp Filename") then
                    SaveNewEntry(TempImportEntry);

            ImportType.Sftp:
                if DownloadSftpFilenames(ImportType, ListOfDirectory) then begin
                    foreach Filename in ListOfDirectory do
                        if TryImportNewEntrySftp(TempImportEntry, ImportType, Filename) then
                            SaveNewEntry(TempImportEntry);
                end;

            DownloadFtpListDirectoryDetails(ImportType, ListOfDirectory):
                foreach FileName in ListOfDirectory do begin
                    if TryImportNewEntry(TempImportEntry, ImportType, Filename) then
                        SaveNewEntry(TempImportEntry);
                end;
            else
                exit(false);
        end;

        exit(true);
    end;

    local procedure SaveNewEntry(var ImportEntryTmp: Record "NPR Nc Import Entry" temporary)
    begin
        StoreImportEntries(ImportEntryTmp);
        Commit();
    end;

    [TryFunction]
    procedure TryImportNewEntry(var TempImportEntry: Record "NPR Nc Import Entry" temporary; ImportType: Record "NPR Nc Import Type"; Filename: Text)
    var
        SourceUri: Text;
        TargetUri: Text;
        OutStr: OutStream;
        Base64Convert: Codeunit "Base64 Convert";
        FtpPort: Integer;
        FTPResponse: JsonObject;
        JToken: JsonToken;
        ResponseCodeText: Text;
        FileContent: Text;
    begin
        if not ValidFilename(Filename) then
            Error(FileIsNotValidErr, Filename);

        SourceUri := ManagePathSlashes(ImportType."Ftp Path");

        FtpPort := ImportType."Ftp Port";
        if FtpPort = 0 then
            FtpPort := 21;

        //Check for Binary property (probably not needed anymore): if ImportType."Ftp Binary" then FtpWebRequest.UseBinary := true;

        FTPClient.Construct(ImportType."Ftp Host", ImportType."Ftp User", ImportType."Ftp Password", FtpPort, 10000, ImportType."Ftp Passive");
        FTPResponse := FTPClient.DownloadFile(SourceUri + Filename);

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

        if ImportType."Ftp Backup Path" = '' then begin
            if not DeleteFtpFile(SourceUri + Filename) then
                Error(FtpBackupErr, Filename, GetLastErrorText());
        end else begin
            TargetUri := ManagePathSlashes(ImportType."Ftp Backup Path");
            if not CheckFtpUrlExists(TargetUri) then
                if MakeFtpUrl(TargetUri) then;

            if not RenameFtpFile(ManagePathSlashes(SourceUri) + Filename, ManagePathSlashes(ImportType."Ftp Backup Path") + Filename) then
                Error(FtpBackupErr, Filename, GetLastErrorText());
        end;

        TempImportEntry.Insert();
        FTPClient.Destruct();
    end;

    [TryFunction]
    procedure TryImportNewEntrySftp(var TempImportEntry: Record "NPR Nc Import Entry" temporary; ImportType: Record "NPR Nc Import Type"; Filename: Text)
    var
        OutStr: OutStream;
        RemotePath: Text;
        NewRemotePath: Text;
        Base64Convert: Codeunit "Base64 Convert";
        FtpPort: Integer;
        FTPResponse: JsonObject;
        JToken: JsonToken;
        ResponseCodeText: Text;
        FileContent: Text;
    begin
        if not ValidFilename(Filename) then
            Error(FileIsNotValidErr, Filename);

        RemotePath := ManagePathSlashes(ImportType."Ftp Path");

        FtpPort := ImportType."Ftp Port";
        if FtpPort = 0 then
            FtpPort := 21;

        SFTPClient.Construct(ImportType."Ftp Host", ImportType."Ftp User", ImportType."Ftp Password", FtpPort, 10000);
        FTPResponse := SFTPClient.DownloadFile(RemotePath + Filename);

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
        TempImportEntry."Document Source".CreateOutStream(OutStr);

        FileContent := Base64Convert.FromBase64(JToken.AsValue().AsText());
        OutStr.WriteText(FileContent);

        if ImportType."Ftp Backup Path" = '' then
            SFTPClient.DeleteFile(RemotePath + Filename)
        else begin
            NewRemotePath := ManagePathSlashes(RemotePath + ImportType."Ftp Backup Path");
            SFTPClient.MoveFile(RemotePath + Filename, NewRemotePath + Filename);
        end;

        TempImportEntry.Insert();
        SFTPClient.Destruct();
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
        CODEUNIT.Run(CODEUNIT::"NPR Nc Import Processor", ImportEntry);
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
        TaskSetup.SetRange("Task Processor Code", Task."Task Processor Code");
        TaskSetup.SetRange("Table No.", Task."Table No.");
        if TaskSetup.FindSet() then
            repeat
                if Task.Get(Task."Entry No.") then;
                ClearLastError();
                if not CODEUNIT.Run(TaskSetup."Codeunit ID", Task) then begin
                    TaskError(Task);
                    exit(false);
                end;
            until TaskSetup.Next() = 0;
        TaskComplete(Task);
        exit(true);
    end;

    procedure ProcessTasks(TaskProcessor: Record "NPR Nc Task Processor"; MaxRetry: Integer)
    var
        Task: Record "NPR Nc Task";
    begin
        if MaxRetry < 1 then
            MaxRetry := 1;

        Task.SetRange("Task Processor Code", TaskProcessor.Code);
        Task.SetRange(Processed, false);
        Task.SetFilter("Process Count", '<%1', MaxRetry);
        if Task.FindSet() then
            repeat
                ProcessTask(Task);
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
        OutStream: OutStream;
        ErrorText: Text[1024];
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
            ClearLastError();
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

    procedure TaskResetCount()
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

    procedure UpdateTaskProcessor(var TaskProcessor: Record "NPR Nc Task Processor")
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
    [TryFunction]
    procedure DownloadFtpListDirectory(ImportType: Record "NPR Nc Import Type"; var DirectoryList: List of [Text])
    var
        FtpPort: Integer;
        FTPResponse: JsonObject;
        FileObject: JsonObject;
        JToken: JsonToken;
        JArray: JsonArray;
        i: Integer;
        ResponseCodeText: Text;
    begin
        Clear(DirectoryList);

        if not ImportType."Ftp Enabled" then
            exit;

        FtpPort := ImportType."Ftp Port";
        IF FtpPort = 0 then
            FtpPort := 21;

        //Check for Binary property (probably not needed anymore): if ImportType."Ftp Binary" then FtpWebRequest.UseBinary := true;

        FTPClient.Construct(ImportType."Ftp Host", ImportType."Ftp User", ImportType."Ftp Password", FtpPort, 10000, ImportType."Ftp Passive");
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
                        if Jtoken.AsValue().AsBoolean() then begin
                            FileObject.Get('Name', JToken);
                            DirectoryList.Add(JToken.AsValue().AsText());
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
    procedure DownloadFtpListDirectoryDetails(ImportType: Record "NPR Nc Import Type"; var ListDirectoryDetails: List of [Text])
    var
        FtpPort: Integer;
        FTPResponse: JsonObject;
        FileObject: JsonObject;
        JToken: JsonToken;
        JArray: JsonArray;
        i: Integer;
        ResponseCodeText: Text;
    begin
        Clear(ListDirectoryDetails);

        if not ImportType."Ftp Enabled" then
            exit;

        FtpPort := ImportType."Ftp Port";
        IF FtpPort = 0 then
            FtpPort := 21;

        FTPClient.Construct(ImportType."Ftp Host", ImportType."Ftp User", ImportType."Ftp Password", FtpPort, 10000, ImportType."Ftp Passive");
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
                        if not Jtoken.AsValue().AsBoolean() then begin
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
    local procedure DownloadSftpFilenames(ImportType: Record "NPR Nc Import Type"; var ListDirectory: List of [Text])
    var
        RemotePath: Text;
        FtpPort: Integer;
        FTPResponse: JsonObject;
        FileObject: JsonObject;
        JToken: JsonToken;
        JArray: JsonArray;
        i: Integer;
        ResponseCodeText: Text;
    begin
        FtpPort := ImportType."Ftp Port";
        IF FtpPort = 0 then
            FtpPort := 21;

        RemotePath := ManagePathSlashes(ImportType."Ftp Path");

        SFTPClient.Construct(ImportType."Ftp Host", ImportType."Ftp User", ImportType."Ftp Password", FtpPort, 10000);
        FTPResponse := SFTPClient.ListDirectory(RemotePath);

        FTPResponse.Get('StatusCode', JToken);
        ResponseCodeText := JToken.AsValue().AsText();

        SFTPClient.Destruct();

        case ResponseCodeText of
            '200':
                begin
                    FTPResponse.Get('Files', JToken);
                    JArray := JToken.AsArray();

                    for i := 0 to JArray.Count - 1 do begin
                        JArray.Get(i, JToken);
                        FileObject := JToken.AsObject();

                        FileObject.Get('IsDirectory', JToken);
                        if not Jtoken.AsValue().AsBoolean() then begin
                            FileObject.Get('Name', JToken);
                            ListDirectory.Add(JToken.AsValue().AsText());
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

    local procedure ManagePathSlashes(RemotePath: Text) FormattedPath: Text
    begin
        if StrPos(RemotePath, '/') > 1 then
            FormattedPath := '/';
        FormattedPath += RemotePath;
        if CopyStr(FormattedPath, StrLen(FormattedPath), 1) <> '/' then
            FormattedPath += '/';
    end;

    local procedure PathOneLevelUp(RemotePath: Text; var ReturnedFromFolder: Text): Text
    var
        i: Integer;
        lastSlashPosition: Integer;
    begin
        if CopyStr(RemotePath, StrLen(RemotePath), 1) = '/' then
            RemotePath := CopyStr(RemotePath, 1, StrLen(RemotePath) - 1);

        for i := 1 to StrLen(RemotePath) do begin
            if RemotePath[StrLen(RemotePath) + 1 - i] = '/' then
                lastSlashPosition := StrLen(RemotePath) - i;
        end;

        ReturnedFromFolder := CopyStr(RemotePath, lastSlashPosition, StrLen(RemotePath));
        exit(CopyStr(RemotePath, 1, lastSlashPosition - 1));
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

    #region Aux
    [TryFunction]
    local procedure CheckFtpUrlExists(FtpUrl: Text)
    var
        FTPResponse: JsonObject;
        JToken: JsonToken;
        ResponseCodeText: Text;
        FolderName: Text;
        i: Integer;
        FolderExist: Boolean;
        JArray: JsonArray;
        FileObject: JsonObject;
    begin
        FtpUrl := PathOneLevelUp(FtpUrl, FolderName);

        FTPResponse := FTPClient.ListDirectory(FtpUrl);

        FTPResponse.Get('StatusCode', JToken);
        ResponseCodeText := JToken.AsValue().AsText();

        SFTPClient.Destruct();

        case ResponseCodeText of
            '200':
                begin
                    FTPResponse.Get('Files', JToken);
                    JArray := JToken.AsArray();

                    for i := 0 to JArray.Count - 1 do begin
                        JArray.Get(i, JToken);
                        FileObject := JToken.AsObject();

                        FileObject.Get('IsDirectory', JToken);
                        if Jtoken.AsValue().AsBoolean() then begin
                            FileObject.Get('Name', JToken);
                            if JToken.AsValue().AsText() = FolderName then
                                FolderExist := true;
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

        exit(FolderExist);
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

        exit(ResponseCodeText = '200');
    end;

    local procedure GetDocName(Filename: Text; MaxLength: Integer) DocName: Text
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

    [TryFunction]
    local procedure MakeFtpUrl(FtpUrl: Text)
    var
        FTPResponse: JsonObject;
        JToken: JsonToken;
        ResponseCodeText: Text;
    begin
        FTPClient.CreateDirectory(FtpUrl);

        FTPResponse.Get('StatusCode', JToken);
        ResponseCodeText := JToken.AsValue().AsText();

        exit(ResponseCodeText = '200');
    end;

    [TryFunction]
    local procedure RenameFtpFile(FtpUrl: Text; RenameTo: Text)
    var
        FTPResponse: JsonObject;
        JToken: JsonToken;
        ResponseCodeText: Text;
    begin
        FTPResponse := FTPClient.RenameFile(FtpUrl, RenameTo);

        FTPResponse.Get('StatusCode', JToken);
        ResponseCodeText := JToken.AsValue().AsText();

        exit(ResponseCodeText = '200');
    end;
    #endregion Aux

    #region Constants
    procedure "Parameter.DownloadFtp"(): Code[20]
    begin
        exit('DOWNLOAD_FTP');
    end;

    procedure "Parameter.DownloadType"(): Code[20]
    begin
        exit('DOWNLOAD_IMPORT_TYPE');
    end;

    procedure "Parameter.ImportNewTasks"(): Code[20]
    begin
        exit('IMPORT_NEW_TASKS');
    end;

    procedure "Parameter.ProcessTasks"(): Code[20]
    begin
        exit('PROCESS_TASKS');
    end;

    procedure "Parameter.ResetTaskCount"(): Code[20]
    begin
        exit('RESET_RETRY_COUNT');
    end;

    procedure "Parameter.TaskRetryCount"(): Code[20]
    begin
        exit('TASK_RETRY_COUNT');
    end;
    #endregion Constants

    #region UI

    #endregion UI

    #region events
    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessTask(var Task: Record "NPR Nc Task")
    begin
    end;
    #endregion events
}