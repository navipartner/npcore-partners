codeunit 6151505 "NPR Nc Sync. Mgt."
{
    TableNo = "NPR Task Line";

    trigger OnRun()
    var
        TaskProcessor: Record "NPR Nc Task Processor";
        NaviConnectTaskMgt: Codeunit "NPR Nc Task Mgt.";
        NcImportMgt: Codeunit "NPR Nc Import Mgt.";
        MaxRetry: Integer;
        ImportTypeCode: Code[20];
    begin
        SyncStartTime := CurrentDateTime;
        SyncEndTime := SyncStartTime + GetMaxSyncDuration();
        TaskProcessor.Code := CopyStr(UpperCase(GetParameterText("Parameter.TaskProcessorCode")), 1, MaxStrLen(TaskProcessor.Code));
        if TaskProcessor.Code = '' then begin
            TaskProcessor.Code := "Task Worker Group";
            SetParameterText(GetParameterText("Parameter.TaskProcessorCode"), TaskProcessor.Code);
        end;
        UpdateTaskProcessor(TaskProcessor);
        Commit;

        ImportTypeCode := CopyStr(UpperCase(GetParameterText("Parameter.DownloadType")), 1, MaxStrLen(ImportTypeCode));
        UpdateImportList(Rec, ImportTypeCode);

        if GetParameterBool("Parameter.ProcessImport") then
            ProcessImportEntries();

        if GetParameterBool("Parameter.ImportNewTasks") then
            NaviConnectTaskMgt.UpdateTasks(TaskProcessor);

        if GetParameterBool("Parameter.ProcessTasks") then begin
            MaxRetry := GetParameterInt("Parameter.TaskRetryCount");
            ProcessTasks(TaskProcessor, MaxRetry);
        end;

        if GetParameterBool("Parameter.ResetTaskCount") then
            TaskResetCount();

        if GetParameterBool("Parameter.CleanupImport") then
            NcImportMgt.CleanupImportTypes();
    end;

    procedure UpdateImportList(TaskLine: Record "NPR Task Line"; ImportTypeCode: Code[20])
    var
        ImportType: Record "NPR Nc Import Type";
        NcDependencyFactory: Codeunit "NPR Nc Dependency Factory";
        ImportListUpdater: Interface "NPR Nc Import List IUpdate";
    begin
        if ImportTypeCode <> '' then
            ImportType.SetRange("Code", ImportTypeCode);
        if ImportType.FindSet() then
            repeat
                if NcDependencyFactory.CreateNcImportListUpdater(ImportListUpdater, ImportType) then
                    ImportListUpdater.Update(TaskLine, ImportType);
            until ImportType.Next() = 0;
    end;

    var
        Text000: Label 'NaviConnect Default';
        Text001: Label 'Error during Ftp Backup (%1):\\%2';
        SyncStartTime: DateTime;
        SyncEndTime: DateTime;

    #region "Download Ftp"
    procedure DownloadFtp()
    var
        ImportType: Record "NPR Nc Import Type";
        LastErrorMessage: Text;
    begin
        ImportType.SetRange("Ftp Enabled", true);
        if not ImportType.FindSet then
            exit;

        LastErrorMessage := '';
        repeat
            if not DownloadFtpType(ImportType) then
                LastErrorMessage := GetLastErrorText;
        until ImportType.Next = 0;
        if LastErrorMessage <> '' then
            Error(CopyStr(LastErrorMessage, 1, 1000));
    end;

    procedure DownloadFtpType(ImportType: Record "NPR Nc Import Type"): Boolean
    var
        ImportEntryTmp: Record "NPR Nc Import Entry" temporary;
        FileList: DotNet NPRNetIList;
        LsEntry: DotNet NPRNetChannelSftp_LsEntry;
        Filename: Text;
        ListDirectory: Text;
    begin
        case true of
            ImportType."Ftp Filename" <> '':
                if TryImportNewEntry(ImportEntryTmp, ImportType, ImportType."Ftp Filename") then
                    SaveNewEntry(ImportEntryTmp);

            ImportType.Sftp:
                if DownloadSftpFilenames(ImportType, ListDirectory) then begin
                    while CutNextFilename(ListDirectory, Filename) do
                        if TryImportNewEntrySftp(ImportEntryTmp, ImportType, Filename) then
                            SaveNewEntry(ImportEntryTmp);
                end;

            DownloadFtpListDirectory(ImportType, ListDirectory):
                while CutNextFilename(ListDirectory, Filename) do
                    if TryImportNewEntry(ImportEntryTmp, ImportType, Filename) then
                        SaveNewEntry(ImportEntryTmp);

            DownloadFtpListDirectoryDetails(ImportType, ListDirectory):
                while CutNextFilenameDetailed(ListDirectory, Filename) do
                    if TryImportNewEntry(ImportEntryTmp, ImportType, Filename) then
                        SaveNewEntry(ImportEntryTmp);

            else
                exit(false);
        end;

        exit(true);
    end;

    local procedure SaveNewEntry(var ImportEntryTmp: Record "NPR Nc Import Entry" temporary)
    begin
        ImportEntryTmp.Insert();
        StoreImportEntries(ImportEntryTmp);
        Commit();
    end;

    [TryFunction]
    procedure TryImportNewEntry(var ImportEntry: Record "NPR Nc Import Entry"; ImportType: Record "NPR Nc Import Type"; Filename: Text)
    var
        FileMgt: Codeunit "File Management";
        Credential: DotNet NPRNetNetworkCredential;
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
        MemoryStream: DotNet NPRNetMemoryStream;
        SourceUri: DotNet NPRNetUri;
        TargetUri: DotNet NPRNetUri;
        OutStream: OutStream;
    begin
        if not ValidFilename(Filename) then
            exit;

        SourceUri := SourceUri.Uri(ImportType."Ftp Host" + '/' + ImportType."Ftp Path" + '/');
        FtpWebRequest := FtpWebRequest.Create(SourceUri.AbsoluteUri + Filename);
        FtpWebRequest.Method := 'RETR'; //WebRequestMethods.Ftp.DownloadFile
        if ImportType."Ftp Binary" then
            FtpWebRequest.UseBinary := true;
        FtpWebRequest.KeepAlive := false;
        FtpWebRequest.Credentials := Credential.NetworkCredential(ImportType."Ftp User", ImportType."Ftp Password");
        FtpWebResponse := FtpWebRequest.GetResponse;
        MemoryStream := FtpWebResponse.GetResponseStream();

        Clear(ImportEntry);
        ImportEntry."Import Type" := ImportType.Code;
        ImportEntry.Date := CurrentDateTime;
        ImportEntry."Document Name" := GetDocName(Filename, MaxStrLen(ImportEntry."Document Name"));
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := false;
        ImportEntry."Document Source".CreateOutStream(OutStream);

        CopyStream(OutStream, MemoryStream);
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);

        if ImportType."Ftp Backup Path" = '' then begin
            if not DeleteFtpFile(SourceUri.AbsoluteUri + Filename, ImportType."Ftp User", ImportType."Ftp Password") then
                Error(CopyStr(StrSubstNo(Text001, Filename, GetLastErrorText), 1, 1000));
        end else begin
            TargetUri := TargetUri.Uri(SourceUri.AbsoluteUri + ImportType."Ftp Backup Path" + '/');
            if (not CheckFtpUrlExists(TargetUri.AbsoluteUri, ImportType."Ftp User", ImportType."Ftp Password")) and
              (not CheckFtpUrlExists2(TargetUri.AbsoluteUri, ImportType."Ftp User", ImportType."Ftp Password"))
            then begin
                if MakeFtpUrl(TargetUri.AbsoluteUri, ImportType."Ftp User", ImportType."Ftp Password") then;
            end;

            if not RenameFtpFile(SourceUri.AbsoluteUri + Filename, ImportType."Ftp User", ImportType."Ftp Password", ImportType."Ftp Backup Path" + '/' + Filename) then
                Error(CopyStr(StrSubstNo(Text001, Filename, GetLastErrorText), 1, 1000));
        end;
    end;

    [TryFunction]
    procedure TryImportNewEntrySftp(var ImportEntry: Record "NPR Nc Import Entry"; ImportType: Record "NPR Nc Import Type"; Filename: Text)
    var
        SharpSFtp: DotNet NPRNetSftp0;
        IOStream: DotNet NPRNetStream;
        OutStream: OutStream;
        RemotePath: Text;
        NewRemotePath: Text;
    begin
        if not ValidFilename(Filename) then
            exit;

        SharpSFtp := SharpSFtp.Sftp(ImportType."Ftp Host", ImportType."Ftp User", ImportType."Ftp Password");
        SharpSFtp.Connect(ImportType."Ftp Port");
        RemotePath := '/';
        if ImportType."Ftp Path" <> '' then begin
            RemotePath += ImportType."Ftp Path";
            if CopyStr(RemotePath, StrLen(RemotePath), 1) <> '/' then
                RemotePath += '/';
        end;

        Clear(ImportEntry);
        ImportEntry."Import Type" := ImportType.Code;
        ImportEntry.Date := CurrentDateTime;
        ImportEntry."Document Name" := GetDocName(Filename, MaxStrLen(ImportEntry."Document Name"));
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := false;
        ImportEntry."Document Source".CreateOutStream(OutStream);
        IOStream := OutStream;
        SharpSFtp.Get(RemotePath + Filename, IOStream);

        if ImportType."Ftp Backup Path" = '' then
            SharpSFtp.DeleteFile(RemotePath + Filename)
        else begin
            NewRemotePath := RemotePath + ImportType."Ftp Backup Path";
            if CopyStr(NewRemotePath, StrLen(NewRemotePath), 1) <> '/' then
                NewRemotePath += '/';

            SharpSFtp.RenameFile(RemotePath + Filename, NewRemotePath + Filename);
        end;

        SharpSFtp.Close;
    end;
    #endregion "Download Ftp"

    #region "Downlod Server File"
    procedure DownloadServerFiles()
    var
        NcImportEntryTmp: Record "NPR Nc Import Entry" temporary;
        NcImportType: Record "NPR Nc Import Type";
        LastErrorText: Text;
    begin
        NcImportType.SetRange("Server File Enabled", true);
        if NcImportType.IsEmpty then
            exit;

        NcImportType.FindSet;
        repeat
            ClearLastError();
            if not TryDownloadServerFile(NcImportType, NcImportEntryTmp) then
                LastErrorText := GetLastErrorText + LastErrorText;
            StoreImportEntries(NcImportEntryTmp);
            Commit;
        until NcImportType.Next = 0;

        if LastErrorText <> '' then
            Error(CopyStr(LastErrorText, 1, 1000));
    end;

    [TryFunction]
    local procedure TryDownloadServerFile(NcImportType: Record "NPR Nc Import Type"; var NcImportEntryTmp: Record "NPR Nc Import Entry" temporary)
    begin
        DownloadServerFile(NcImportType, NcImportEntryTmp);
    end;

    procedure DownloadServerFile(NcImportType: Record "NPR Nc Import Type")
    var
        NcImportEntryTmp: Record "NPR Nc Import Entry" temporary;
    begin
        DownloadServerFile(NcImportType, NcImportEntryTmp);
        StoreImportEntries(NcImportEntryTmp);
    end;

    procedure DownloadServerFile(NcImportType: Record "NPR Nc Import Type"; var NcImportEntryTmp: Record "NPR Nc Import Entry" temporary)
    var
        FileMgt: Codeunit "File Management";
        ArrayHelper: DotNet NPRNetArray;
        ServerDirectoryHelper: DotNet NPRNetDirectory;
        i: Integer;
        Filename: Text;
    begin
        NcImportType.TestField("Server File Enabled");
        NcImportType.TestField("Server File Path");

        ArrayHelper := ServerDirectoryHelper.GetFiles(NcImportType."Server File Path");
        for i := 0 to ArrayHelper.GetLength(0) - 1 do begin
            Filename := ArrayHelper.GetValue(i);
            InsertImportEntry2(NcImportType, NcImportEntryTmp, Filename);
        end;
    end;

    [TryFunction]
    local procedure InsertImportEntry2(NcImportType: Record "NPR Nc Import Type"; var NcImportEntryTmp: Record "NPR Nc Import Entry" temporary; Filename: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        RecRef: RecordRef;
    begin
        FileMgt.BLOBImportFromServerFile(TempBlob, Filename);

        NcImportEntryTmp.Init;
        NcImportEntryTmp."Entry No." := 0;
        NcImportEntryTmp."Import Type" := NcImportType.Code;
        NcImportEntryTmp.Date := CurrentDateTime;
        NcImportEntryTmp."Document Name" := GetDocName(FileMgt.GetFileName(Filename), MaxStrLen(NcImportEntryTmp."Document Name"));
        NcImportEntryTmp.Imported := false;
        NcImportEntryTmp."Runtime Error" := false;

        RecRef.GetTable(NcImportEntryTmp);
        TempBlob.ToRecordRef(RecRef, NcImportEntryTmp.FieldNo("Document Source"));
        RecRef.SetTable(NcImportEntryTmp);

        NcImportEntryTmp.Insert;
        if Erase(Filename) then;
    end;

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
            NcImportEntry := NcImportEntryTmp;
            NcImportEntry."Entry No." := 0;
            NcImportEntry.Insert(true);
        until NcImportEntryTmp.Next() = 0;
        NcImportEntryTmp.DeleteAll();
    end;
    #endregion "Downlod Server File"

    #region "Process Import"
    procedure ProcessImportEntry(var ImportEntry: Record "NPR Nc Import Entry"): Boolean
    var
        DataLogMgt: Codeunit "NPR Data Log Management";
        NaviConnectImportMgt: Codeunit "NPR Nc Import Mgt.";
    begin
        CODEUNIT.Run(CODEUNIT::"NPR Nc Import Processor", ImportEntry);
        if ImportEntry.Get(ImportEntry."Entry No.") then
            exit(ImportEntry.Imported);

        exit(false);
    end;

    procedure ProcessImportEntries()
    var
        ImportEntry: Record "NPR Nc Import Entry";
    begin
        ImportEntry.SetRange(Imported, false);
        ImportEntry.SetRange("Runtime Error", false);
        ImportEntry.SetFilter("Earliest Import Datetime", '<=%1', CurrentDateTime);
        if ImportEntry.FindSet then
            repeat
                ProcessImportEntry(ImportEntry);
                if (CurrentDateTime > SyncEndTime) and (SyncEndTime <> 0DT) then
                    exit;
            until ImportEntry.Next = 0;
    end;

    procedure ProcessTask(var Task: Record "NPR Nc Task"): Boolean
    var
        TaskSetup: Record "NPR Nc Task Setup";
    begin
        TaskReset(Task);
        TaskSetup.SetRange("Task Processor Code", Task."Task Processor Code");
        TaskSetup.SetRange("Table No.", Task."Table No.");
        if TaskSetup.FindSet then
            repeat
                if Task.Get(Task."Entry No.") then;
                ClearLastError;
                if not CODEUNIT.Run(TaskSetup."Codeunit ID", Task) then begin
                    TaskError(Task);
                    exit(false);
                end;
            until TaskSetup.Next = 0;
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
        if Task.FindSet then
            repeat
                ProcessTask(Task);
                if (CurrentDateTime > SyncEndTime) and (SyncEndTime <> 0DT) then
                    exit;
            until Task.Next = 0;
    end;
    #endregion "Process Import"

    #region "Status Mgt."
    local procedure TaskComplete(var NaviConnectTask: Record "NPR Nc Task")
    begin
        NaviConnectTask.LockTable;
        if not NaviConnectTask.Get(NaviConnectTask."Entry No.") then
            exit;
        NaviConnectTask."Last Processing Completed at" := CurrentDateTime;
        NaviConnectTask."Last Processing Duration" := (NaviConnectTask."Last Processing Completed at" - NaviConnectTask."Last Processing Started at") / 1000;
        NaviConnectTask.Processed := true;
        NaviConnectTask."Process Error" := false;
        NaviConnectTask.Modify(true);
        Commit;
    end;

    local procedure TaskError(var NaviConnectTask: Record "NPR Nc Task")
    var
        OutStream: OutStream;
        ErrorText: Text[1024];
    begin
        NaviConnectTask.LockTable;
        if not NaviConnectTask.Get(NaviConnectTask."Entry No.") then
            exit;

        NaviConnectTask."Last Processing Completed at" := CurrentDateTime;
        NaviConnectTask."Last Processing Duration" := (NaviConnectTask."Last Processing Completed at" - NaviConnectTask."Last Processing Started at") / 1000;

        ErrorText := GetLastErrorText;

        if ErrorText <> '' then begin
            NaviConnectTask.Response.CreateOutStream(OutStream);
            OutStream.Write(ErrorText);
            ClearLastError;
        end;

        NaviConnectTask.Modify(true);
        Commit;
    end;

    local procedure TaskReset(var NaviConnectTask: Record "NPR Nc Task")
    begin
        NaviConnectTask.LockTable;
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
        Commit;
    end;

    procedure TaskResetCount()
    var
        NaviConnectTask: Record "NPR Nc Task";
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
    begin
        NcTaskMgt.CleanTasks();
        Commit;

        NaviConnectTask.SetCurrentKey("Log Date", Processed);
        NaviConnectTask.SetRange(Processed, false);
        NaviConnectTask.ModifyAll("Process Count", 0);
        Commit;
    end;

    procedure UpdateTaskProcessor(TaskProcessor: Record "NPR Nc Task Processor")
    begin
        if TaskProcessor.Find then
            exit;

        if TaskProcessor.Code in ['', 'NC'] then begin
            TaskProcessor.Init;
            TaskProcessor.Code := 'NC';
            TaskProcessor.Description := Text000;
            TaskProcessor.Insert(true);
        end;
    end;
    #endregion "Status Mgt."

    #region "Ftp List"
    local procedure CreateFtpWebRequest(ImportType: Record "NPR Nc Import Type"; var FtpWebRequest: DotNet NPRNetFtpWebRequest)
    var
        Uri: DotNet NPRNetUri;
    begin
        Uri := Uri.Uri(ImportType."Ftp Host" + '/' + ImportType."Ftp Path" + '/');
        FtpWebRequest := FtpWebRequest.Create(Uri);
        if ImportType."Ftp Binary" then
            FtpWebRequest.UseBinary := true;
        FtpWebRequest.KeepAlive := false;
    end;

    local procedure CutNextFilename(var ListDirectoryDetails: Text; var Filename: Text): Boolean
    var
        Details: Text;
    begin
        if ListDirectoryDetails = '' then
            exit(false);

        Filename := '';
        repeat
            CutNextLine(ListDirectoryDetails, Details);
            Filename := Details;
        until (Filename <> '') or (ListDirectoryDetails = '');

        exit((Filename <> '') or (ListDirectoryDetails <> ''));
    end;

    local procedure CutNextFilenameDetailed(var ListDirectoryDetails: Text; var Filename: Text): Boolean
    var
        Details: Text;
    begin
        if ListDirectoryDetails = '' then
            exit(false);

        Filename := '';
        repeat
            CutNextLineDetailed(ListDirectoryDetails, Details);
            Filename := ParseFilename(Details);
        until (Filename <> '') or (ListDirectoryDetails = '');

        exit((Filename <> '') or (ListDirectoryDetails <> ''));
    end;

    local procedure CutNextLine(var ListDirectoryDetails: Text; var Details: Text)
    var
        Position: Integer;
    begin
        if ListDirectoryDetails = '' then
            exit;

        Position := StrPos(ListDirectoryDetails, NewLine());
        while Position = 1 do begin
            ListDirectoryDetails := DelStr(ListDirectoryDetails, 1, 2);
            Position := StrPos(ListDirectoryDetails, NewLine());
        end;

        if Position = 0 then begin
            Details := ListDirectoryDetails;
            ListDirectoryDetails := '';
        end else begin
            Details := CopyStr(ListDirectoryDetails, 1, Position - 1);
            ListDirectoryDetails := DelStr(ListDirectoryDetails, 1, Position + 1);
        end;
    end;

    local procedure CutNextLineDetailed(var ListDirectoryDetails: Text; var Details: Text)
    var
        Position: Integer;
    begin
        if ListDirectoryDetails = '' then
            exit;

        Position := StrPos(ListDirectoryDetails, NewLine());
        while Position = 1 do begin
            ListDirectoryDetails := DelStr(ListDirectoryDetails, 1, 2);
            Position := StrPos(ListDirectoryDetails, NewLine());
        end;

        if Position = 0 then begin
            Details := ListDirectoryDetails;
            ListDirectoryDetails := '';
        end else begin
            Details := CopyStr(ListDirectoryDetails, 1, Position - 1);
            ListDirectoryDetails := DelStr(ListDirectoryDetails, 1, Position + 2);
        end;
    end;

    [TryFunction]
    procedure DownloadFtpListDirectory(ImportType: Record "NPR Nc Import Type"; var ListDirectory: Text)
    var
        Credential: DotNet NPRNetNetworkCredential;
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
        MemoryStream: DotNet NPRNetMemoryStream;
        StreamReader: DotNet NPRNetStreamReader;
    begin
        ListDirectory := '';

        if not ImportType."Ftp Enabled" then
            exit;

        CreateFtpWebRequest(ImportType, FtpWebRequest);
        FtpWebRequest.Method := 'NLST'; //WebRequestMethods.Ftp.ListDirectory
        FtpWebRequest.Credentials := Credential.NetworkCredential(ImportType."Ftp User", ImportType."Ftp Password");
        FtpWebResponse := FtpWebRequest.GetResponse;
        MemoryStream := FtpWebResponse.GetResponseStream();
        StreamReader := StreamReader.StreamReader(MemoryStream);
        ListDirectory := StreamReader.ReadToEnd;
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
    end;

    [TryFunction]
    procedure DownloadFtpListDirectoryDetails(ImportType: Record "NPR Nc Import Type"; var ListDirectoryDetails: Text)
    var
        Credential: DotNet NPRNetNetworkCredential;
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
        MemoryStream: DotNet NPRNetMemoryStream;
        StreamReader: DotNet NPRNetStreamReader;
    begin
        ListDirectoryDetails := '';

        if not ImportType."Ftp Enabled" then
            exit;

        CreateFtpWebRequest(ImportType, FtpWebRequest);
        FtpWebRequest.Method := 'LIST'; //WebRequestMethods.Ftp.ListDirectoryDetails
        FtpWebRequest.Credentials := Credential.NetworkCredential(ImportType."Ftp User", ImportType."Ftp Password");
        FtpWebResponse := FtpWebRequest.GetResponse;
        MemoryStream := FtpWebResponse.GetResponseStream();
        StreamReader := StreamReader.StreamReader(MemoryStream);
        ListDirectoryDetails := StreamReader.ReadToEnd;
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
    end;

    [TryFunction]
    local procedure DownloadSftpFilenames(ImportType: Record "NPR Nc Import Type"; var ListDirectory: Text)
    var
        SharpSFtp: DotNet NPRNetSftp0;
        FileList: DotNet NPRNetIList;
        IEnumerator: DotNet NPRNetIEnumerator;
        LsEntry: DotNet NPRNetChannelSftp_LsEntry;
        RemotePath: Text;
        NetConvHelper: Variant;
    begin
        SharpSFtp := SharpSFtp.Sftp(ImportType."Ftp Host", ImportType."Ftp User", ImportType."Ftp Password");
        SharpSFtp.Connect(ImportType."Ftp Port");

        RemotePath := '*';
        if ImportType."Ftp Path" <> '' then
            RemotePath := ImportType."Ftp Path";

        NetConvHelper := SharpSFtp.GetFileList(RemotePath);
        FileList := NetConvHelper;
        foreach LsEntry in FileList do begin
            if ListDirectory <> '' then
                ListDirectory += NewLine();
            ListDirectory += LsEntry.Filename;
        end;
        SharpSFtp.Close;
    end;

    local procedure ParseFilename(Details: Text) Filename: Text
    var
        Position: Integer;
    begin
        if Details = '' then
            exit('');

        Filename := RegExMatch(Details);
        if ValidFilename(Filename) then
            exit(Filename);

        Filename := RegExMatch2(Details);
        if ValidFilename(Filename) then
            exit(Filename);

        Filename := RegExMatch3(Details);
        if ValidFilename(Filename) then
            exit(Filename);

        Filename := RegExMatch4(Details);
        if ValidFilename(Filename) then
            exit(Filename);

        while Position > 0 do begin
            Details := DelStr(Details, 1, Position + 3);
            Position := StrPos(Details, ':');
        end;

        Filename := Details;
        if ValidFilename(Details) then
            Filename := Details;

        exit('');
    end;

    local procedure RegExMatch(Details: Text) Filename: Text
    var
        Match: DotNet NPRNetMatch;
        RegEx: DotNet NPRNetRegex;
    begin
        if Details = '' then
            exit('');

        Match := RegEx.Match(Details, '^' +
                                      '(?<dir>[\-ld])' +
                                      '(?<permission>([\-r][\-w][\-xs]){3})' +
                                      '\s+(?<filecode>\d+)' +
                                      '\s+(?<owner>\w+)' +
                                      '\s+(?<group>\w+)' +
                                      '\s+(?<size>\d+)' +
                                      '\s+(?<timestamp>((?<month>\w{3})' +
                                      '\s+(?<day>\d{1,2})' +
                                      '\s+(?<hour>\d{1,2}):(?<minute>\d{2}))|((?<month>\w{3})' +
                                      '\s+(?<day>\d{2})' +
                                      '\s+(?<year>\d{4})))' +
                                      '\s+(?<filename>(.+\..+))' +
                                      '$');
        exit(Match.Groups.Item('filename').Value);
    end;

    local procedure RegExMatch2(Details: Text) Filename: Text
    var
        Match: DotNet NPRNetMatch;
        RegEx: DotNet NPRNetRegex;
    begin
        if Details = '' then
            exit('');

        Match := RegEx.Match(Details, '^' +
                                      '(?<dir>[\-ld])' +
                                      '(?<permission>[\-rwx]{9})' +
                                      '\s+(?<filecode>\d+)' +
                                      '\s+(?<owner>\w+)' +
                                      '\s+(?<group>\w+)' +
                                      '\s+(?<size>\d+)' +
                                      '\s+(?<month>\w{3})' +
                                      '\s+(?<day>\d{1,2})' +
                                      '\s+(?<timeyear>[\d:]{4,5})' +
                                      '\s+(?<filename>(.+\..+))' +
                                      '$');

        exit(Match.Groups.Item('filename').Value);
    end;

    local procedure RegExMatch3(Details: Text) Filename: Text
    var
        Match: DotNet NPRNetMatch;
        RegEx: DotNet NPRNetRegex;
    begin
        if Details = '' then
            exit('');

        Match := RegEx.Match(Details, '^' +
                                      '(?<permission>([\-r][\-w][\-xs]){3})' +
                                      '\s+(?<filecode>\d+)' +
                                      '\s+(?<owner>\w+)' +
                                      '\s+(?<group>\w+)' +
                                      '\s+(?<size>\d+)' +
                                      '\s+(?<month>\w{3})' +
                                      '\s+(?<day>\d{1,2})' +
                                      '\s+(?<hour>\d{1,2}):(?<minute>\d{2})' +
                                      '\s+(?<filename>(.+\..+))' +
                                      '$');

        exit(Match.Groups.Item('filename').Value);
    end;

    local procedure RegExMatch4(Details: Text) Filename: Text
    var
        Match: DotNet NPRNetMatch;
        RegEx: DotNet NPRNetRegex;
    begin
        if Details = '' then
            exit('');

        Match := RegEx.Match(Details, '^' +
                                      '(?<day>\d{1,2})-(?<month>\d{1,2})-(?<year>\d{4})' +
                                      '\s+(?<hour>\d{1,2}):(?<minute>\d{2})\w{2}' +
                                      '\s+(?<size>\d+)' +
                                      '\s+(?<filename>(.+\..+))' +
                                      '$');

        exit(Match.Groups.Item('filename').Value);
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
            exit;

        exit(true);
    end;
    #endregion "Ftp List"

    #region Aux
    [TryFunction]
    local procedure CheckFtpUrlExists(FtpUrl: Text; Username: Text; Password: Text)
    var
        Credential: DotNet NPRNetNetworkCredential;
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
        MemoryStream: DotNet NPRNetMemoryStream;
    begin
        FtpWebRequest := FtpWebRequest.Create(FtpUrl);
        FtpWebRequest.Method := 'NLST'; //WebRequestMethods.Ftp.ListDirectory
        FtpWebRequest.KeepAlive := false;
        if Username <> '' then
            FtpWebRequest.Credentials := Credential.NetworkCredential(Username, Password);
        FtpWebResponse := FtpWebRequest.GetResponse;
        MemoryStream := FtpWebResponse.GetResponseStream();
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
    end;

    [TryFunction]
    local procedure CheckFtpUrlExists2(FtpUrl: Text; Username: Text; Password: Text)
    var
        Credential: DotNet NPRNetNetworkCredential;
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
        MemoryStream: DotNet NPRNetMemoryStream;
    begin
        FtpWebRequest := FtpWebRequest.Create(FtpUrl);
        FtpWebRequest.Method := 'LIST'; //WebRequestMethods.Ftp.ListDirectory
        FtpWebRequest.KeepAlive := false;
        if Username <> '' then
            FtpWebRequest.Credentials := Credential.NetworkCredential(Username, Password);
        FtpWebResponse := FtpWebRequest.GetResponse;
        MemoryStream := FtpWebResponse.GetResponseStream();
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
    end;

    [TryFunction]
    local procedure DeleteFtpFile(FtpUrl: Text; Username: Text; Password: Text)
    var
        Credential: DotNet NPRNetNetworkCredential;
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
    begin
        FtpWebRequest := FtpWebRequest.Create(FtpUrl);
        if Username <> '' then
            FtpWebRequest.Credentials := Credential.NetworkCredential(Username, Password);
        FtpWebRequest.Method := 'DELE'; //WebRequestMethods.Ftp.DeleteFile
        FtpWebRequest.KeepAlive := false;
        FtpWebResponse := FtpWebRequest.GetResponse;
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
    local procedure MakeFtpUrl(FtpUrl: Text; Username: Text; Password: Text)
    var
        Credential: DotNet NPRNetNetworkCredential;
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
        MemoryStream: DotNet NPRNetMemoryStream;
    begin
        FtpWebRequest := FtpWebRequest.Create(FtpUrl);
        FtpWebRequest.Method := 'MKD'; //WebRequestMethods.Ftp.MakeDirectory
        FtpWebRequest.KeepAlive := false;
        if Username <> '' then
            FtpWebRequest.Credentials := Credential.NetworkCredential(Username, Password);
        FtpWebResponse := FtpWebRequest.GetResponse;
        MemoryStream := FtpWebResponse.GetResponseStream();
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
    end;

    procedure NewLine(): Text[2]
    var
        Cr: Char;
        Lf: Char;
    begin
        Cr := 13;
        Lf := 10;

        exit(Format(Cr) + Format(Lf));
    end;

    [TryFunction]
    local procedure RenameFtpFile(FtpUrl: Text; Username: Text; Password: Text; RenameTo: Text)
    var
        Credential: DotNet NPRNetNetworkCredential;
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
    begin
        FtpWebRequest := FtpWebRequest.Create(FtpUrl);
        if Username <> '' then
            FtpWebRequest.Credentials := Credential.NetworkCredential(Username, Password);
        FtpWebRequest.Method := 'RENAME'; //WebRequestMethods.Ftp.Rename
        FtpWebRequest.KeepAlive := false;
        FtpWebRequest.RenameTo := RenameTo;
        FtpWebResponse := FtpWebRequest.GetResponse;
    end;
    #endregion Aux

    #region Constants
    procedure "Parameter.CleanupImport"(): Code[20]
    begin
        exit('CLEANUP_IMPORT');
    end;

    procedure "Parameter.DownloadFtp"(): Code[20]
    begin
        exit('DOWNLOAD_FTP');
    end;

    procedure "Parameter.DownloadServerFile"(): Code[20]
    begin
        exit('DOWNLOAD_SERVER_FILE');
    end;

    procedure "Parameter.DownloadType"(): Code[20]
    begin
        exit('DOWNLOAD_IMPORT_TYPE');
    end;

    procedure "Parameter.ImportNewTasks"(): Code[20]
    begin
        exit('IMPORT_NEW_TASKS');
    end;

    procedure "Parameter.ProcessImport"(): Code[20]
    begin
        exit('PROCESS_IMPORT');
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

    procedure "Parameter.TaskProcessorCode"(): Code[20]
    begin
        exit('TASK_PROCESSOR_CODE');
    end;
    #endregion Constants

    #region UI
    procedure RunProcess(Filename: Text; Arguments: Text; Modal: Boolean)
    var
        [RunOnClient]
        Process: DotNet NPRNetProcess;
        [RunOnClient]
        ProcessStartInfo: DotNet NPRNetProcessStartInfo;
    begin
        ProcessStartInfo := ProcessStartInfo.ProcessStartInfo(Filename, Arguments);
        Process := Process.Start(ProcessStartInfo);
        if Modal then
            Process.WaitForExit();
    end;

    local procedure GetMaxSyncDuration() SyncDuration: Duration
    begin
        SyncDuration := 120000T - 113000T;
        exit(SyncDuration);
    end;
    #endregion UI
}