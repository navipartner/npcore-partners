codeunit 6151505 "Nc Sync. Mgt."
{
    // NC1.00/MHA /20150113  CASE 199932 Refactored object from Web Integration
    // NC1.01/MHA /20150115  CASE 199932 Added functions for managing retry of failed tasks
    // NC1.04/MHA /20150213  CASE 199932 Renamed functions:
    //                                    - CommitCheckPoint --> TaskComplete
    //                                    - CommitErrorPoint --> TaskError
    //                                    - CommitErrorPointImport --> ImportEntryError
    //                                    - Export --> ProcessTasks
    //                                    - Import --> ProcessImportEntries
    //                                    - ResetExecutionCount --> TaskResetCount
    //                                    - SendChange --> ProcessTask
    //                                    - SetCheckPoint --> TaskReset
    //                                   Added Functions:
    //                                    - ImportEntryComplete
    //                                    - ImportEntryReset
    //                                    - ProcessImportEntry
    //                                    - Constants
    //                                   Restructured TaskParameters.
    // NC1.08/MHA /20150311  CASE 206395 Added function RunProcess() for launching launching Applications
    // NC1.11/MHA /20150325  CASE 209616 Removed Task.SETRANGE("Process Error",FALSE) in ProcessTasks() as it is redundant because of Max Count
    // NC1.14/MHA /20150415  CASE 211360 Added Timestamp Fields
    // NC1.16/TS  /20150514  CASE 213778 Added ImportEntry.Type::Customer to import customers for B2B
    // NC1.16/TS  /20150423  CASE 212103 Replaced hardcoded Import Codeunit Id with the NaviConnect Setup Import Codeunit
    // NC1.17/MHA /20150622  CASE 215533 Changed key in TaskResetCount() for performance
    //                                   Moved Import Codeunit Run to new codeunit
    // NC1.18/MHA /20150710  CASE 218282 Added COMMIT in TaskResetCount()
    // NC1.20/MHA /20150811  CASE 220379 Added GET when modifying ImportEntry after Processing
    // NC1.21/MHA /20151022  CASE 225667 Added missing GET in ImportEntryReset()
    // NC1.22/MHA /20160108  CASE 226040 Added Task.GET before executing processing in case of multiple processing codeunits
    // NC1.22/MHA /20160317  CASE 237167 Implemented Import Type in FTPDownload()
    // NC1.22/MHA /20160125  CASE 232733 Task Queue Worker Group replaced by NaviConnect Task Processor
    // NC1.22/MHA /20160216  CASE 226995 Added LOCKTABLE to Task Update functions in case multiple threads tries to handle the same task
    // NC2.00/MHA /20160525  CASE 240005 NaviConnect
    // NC2.01/MHA /20161012  CASE 242552 Added function DownloadFTPType() and Ftp Backup functionality
    // NC2.01/MHA /20161014  CASE 255397 Added Cleanup of Import Entries
    // NC2.02/MHA /20170227  CASE 262318 Added Try function SendErrorMail()
    // NC2.05/TR  /20170602  CASE 275177 Replaced FtpWebRequest.Method from LIST to NLST such that only filenames are retrieved. Updated subfunctions to handle the new response.
    // NC2.06/MHA /20170918  CASE 290633 ReAdded FTP LIST in case NLST is not supported
    // NC2.08/MHA /20171127  CASE 297750 CleanTasks() included in TaskResetCount()
    // NC2.08/BR  /20171221  CASE 295322 Added FTP Binary support
    // NC2.12/MHA /20180424  CASE 308107 DataLog is now enabled after each import in ProcessImportEntry()
    // NC2.12/MHA /20180502  CASE 313362 Added Server File Download
    // NC2.15/MHA /20180801  CASE 306532 Added function GetDocName() to truncate long filenames
    // NC2.15/MHA /20180814  CASE 313184 Reworked Client File Download to support long filenames
    // NC2.16/MHA /20180907  CASE 313184 Added Import Diagnostics and SyncEndTime to prevet NAS Threads to run for more than 30 minutes
    // NC2.16/MHA /20180917  CASE 328432 Added Sftp Download functionality
    // NC2.17/MHA /20181126  CASE 334216 Changed all functions to be External
    // NC2.19/MHA /20180107  CASE 340695 Removed KeepAlive from FtpWebRequest and invoked SFTP.Close to clean up connections
    // NC2.22/MHA /20190605  CASE 334216 Adjusted ImportEntryError() to only overwrite Error Message if Last Error Text has value
    // NC2.22/MHA /20190613  CASE 358499 Added ClearLastErrorText before Task- and Import Processing
    // NC2.22/MHA /20190715  CASE 361919 Parsed OutStream to IOStream in InsertImportEntrySftp() for AL Compatability
    // NC2.23/MHA /20190927  CASE 369170 SendErrorMail() is no longer a Try function as it contains MODIFY transaction and removed Gambit integration
    // NC2.25/MHA /20200120  CASE 386177 Ftp 'LIST' replaced with 'NLST' in CheckFtpUrlExists()

    TableNo = "Task Line";

    trigger OnRun()
    var
        ImportType: Record "Nc Import Type";
        TaskProcessor: Record "Nc Task Processor";
        NaviConnectTaskMgt: Codeunit "Nc Task Mgt.";
        NcImportMgt: Codeunit "Nc Import Mgt.";
        MaxRetry: Integer;
        ImportTypeCode: Code[20];
    begin
        //-NC2.16 [313184]
        SyncStartTime := CurrentDateTime;
        SyncEndTime := SyncStartTime + GetMaxSyncDuration();
        //+NC2.16 [313184]
        TaskProcessor.Code := CopyStr(UpperCase(GetParameterText("Parameter.TaskProcessorCode")), 1, MaxStrLen(TaskProcessor.Code));
        if TaskProcessor.Code = '' then begin
            TaskProcessor.Code := "Task Worker Group";
            SetParameterText(GetParameterText("Parameter.TaskProcessorCode"), TaskProcessor.Code);
        end;
        UpdateTaskProcessor(TaskProcessor);
        Commit;
        //-NC2.12 [313362]
        ImportTypeCode := CopyStr(UpperCase(GetParameterText("Parameter.DownloadType")), 1, MaxStrLen(ImportType.Code));
        //+NC2.12 [313362]
        if GetParameterBool("Parameter.DownloadFtp") then begin
            if ImportTypeCode = '' then
                DownloadFtp()
            else
                if ImportType.Get(ImportTypeCode) then
                    DownloadFtpType(ImportType);
        end;

        //-NC2.12 [313362]
        if GetParameterBool("Parameter.DownloadServerFile") then begin
            if ImportTypeCode = '' then
                DownloadServerFiles()
            else
                if ImportType.Get(ImportTypeCode) then
                    DownloadServerFile(ImportType);
        end;
        //+NC2.12 [313362]

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

    var
        Text000: Label 'NaviConnect Default';
        Text001: Label 'Error during Ftp Backup (%1):\\%2';
        SyncStartTime: DateTime;
        SyncEndTime: DateTime;

    local procedure "--- Download Ftp"()
    begin
    end;

    [Scope('Personalization')]
    procedure DownloadFtp()
    var
        ImportType: Record "Nc Import Type";
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

    [Scope('Personalization')]
    procedure DownloadFtpType(ImportType: Record "Nc Import Type"): Boolean
    var
        FileList: DotNet npNetIList;
        LsEntry: DotNet npNetChannelSftp_LsEntry;
        Filename: Text;
        ListDirectory: Text;
    begin
        //-NC2.06 [290633]
        //-NC2.08 [295322]
        if ImportType."Ftp Filename" <> '' then begin
            InsertImportEntry(ImportType, ImportType."Ftp Filename");
            exit(true);
        end;
        //+NC2.08 [295322]
        //-NC2.16 [328432]
        if ImportType.Sftp then begin
            if DownloadSftpFilenames(ImportType, ListDirectory) then begin
                while CutNextFilename(ListDirectory, Filename) do
                    InsertImportEntrySftp(ImportType, Filename);
            end;

            exit(true);
        end;
        //+NC2.16 [328432]
        if DownloadFtpListDirectory(ImportType, ListDirectory) then begin
            while CutNextFilename(ListDirectory, Filename) do
                InsertImportEntry(ImportType, Filename);

            exit(true);
        end;

        if DownloadFtpListDirectoryDetails(ImportType, ListDirectory) then begin
            while CutNextFilenameDetailed(ListDirectory, Filename) do
                InsertImportEntry(ImportType, Filename);

            exit(true);
        end;

        exit(false);
        //+NC2.06 [290633]
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure InsertImportEntry(ImportType: Record "Nc Import Type"; Filename: Text)
    var
        ImportEntry: Record "Nc Import Entry";
        FileMgt: Codeunit "File Management";
        Credential: DotNet npNetNetworkCredential;
        FtpWebRequest: DotNet npNetFtpWebRequest;
        FtpWebResponse: DotNet npNetFtpWebResponse;
        MemoryStream: DotNet npNetMemoryStream;
        SourceUri: DotNet npNetUri;
        TargetUri: DotNet npNetUri;
        OutStream: OutStream;
    begin
        //-NC2.06 [290633]
        if not ValidFilename(Filename) then
            exit;

        SourceUri := SourceUri.Uri(ImportType."Ftp Host" + '/' + ImportType."Ftp Path" + '/');
        FtpWebRequest := FtpWebRequest.Create(SourceUri.AbsoluteUri + Filename);
        FtpWebRequest.Method := 'RETR'; //WebRequestMethods.Ftp.DownloadFile
        //-NC2.08 [295322]
        if ImportType."Ftp Binary" then
            FtpWebRequest.UseBinary := true;
        //+NC2.08 [295322]
        //-NC2.19 [340695]
        FtpWebRequest.KeepAlive := false;
        //-NC2.19 [340695]
        FtpWebRequest.Credentials := Credential.NetworkCredential(ImportType."Ftp User", ImportType."Ftp Password");
        FtpWebResponse := FtpWebRequest.GetResponse;
        MemoryStream := FtpWebResponse.GetResponseStream();

        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := ImportType.Code;
        ImportEntry.Date := CurrentDateTime;
        //-NC.2.15 [306532]
        ImportEntry."Document Name" := GetDocName(Filename, MaxStrLen(ImportEntry."Document Name"));
        //+NC.2.15 [306532]
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := false;
        ImportEntry."Document Source".CreateOutStream(OutStream);

        CopyStream(OutStream, MemoryStream);
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);

        ImportEntry.Insert(true);

        if ImportType."Ftp Backup Path" = '' then begin
            if not DeleteFtpFile(SourceUri.AbsoluteUri + Filename, ImportType."Ftp User", ImportType."Ftp Password") then
                Error(CopyStr(StrSubstNo(Text001, Filename, GetLastErrorText), 1, 1000));
        end else begin
            TargetUri := TargetUri.Uri(SourceUri.AbsoluteUri + ImportType."Ftp Backup Path" + '/');
            if not CheckFtpUrlExists(TargetUri.AbsoluteUri, ImportType."Ftp User", ImportType."Ftp Password") then begin
                if not MakeFtpUrl(TargetUri.AbsoluteUri, ImportType."Ftp User", ImportType."Ftp Password") then
                    Error(CopyStr(StrSubstNo(Text001, Filename, GetLastErrorText), 1, 1000));
            end;

            if not RenameFtpFile(SourceUri.AbsoluteUri + Filename, ImportType."Ftp User", ImportType."Ftp Password", ImportType."Ftp Backup Path" + '/' + Filename) then
                Error(CopyStr(StrSubstNo(Text001, Filename, GetLastErrorText), 1, 1000));
        end;
        Commit;
        //+NC2.06 [290633]
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure InsertImportEntrySftp(ImportType: Record "Nc Import Type"; Filename: Text)
    var
        ImportEntry: Record "Nc Import Entry";
        SharpSFtp: DotNet npNetSftp0;
        IOStream: DotNet npNetStream;
        OutStream: OutStream;
        RemotePath: Text;
        NewRemotePath: Text;
    begin
        //-NC2.16 [328432]
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

        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := ImportType.Code;
        ImportEntry.Date := CurrentDateTime;
        ImportEntry."Document Name" := GetDocName(Filename, MaxStrLen(ImportEntry."Document Name"));
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := false;
        ImportEntry."Document Source".CreateOutStream(OutStream);
        //-NC2.22 [361919]
        IOStream := OutStream;
        SharpSFtp.Get(RemotePath + Filename, IOStream);
        //+NC2.22 [361919]

        ImportEntry.Insert(true);

        if ImportType."Ftp Backup Path" = '' then
            SharpSFtp.DeleteFile(RemotePath + Filename)
        else begin
            NewRemotePath := RemotePath + ImportType."Ftp Backup Path";
            if CopyStr(NewRemotePath, StrLen(NewRemotePath), 1) <> '/' then
                NewRemotePath += '/';

            SharpSFtp.RenameFile(RemotePath + Filename, NewRemotePath + Filename);
        end;

        Commit;
        //+NC2.16 [328432]
        //-NC2.19 [340695]
        SharpSFtp.Close;
        //+NC2.19 [340695]
    end;

    local procedure "--- Downlod Server File"()
    begin
    end;

    [Scope('Personalization')]
    procedure DownloadServerFiles()
    var
        NcImportType: Record "Nc Import Type";
        LastErrorText: Text;
    begin
        //-NC2.12 [313362]
        NcImportType.SetRange("Server File Enabled", true);
        if NcImportType.IsEmpty then
            exit;

        NcImportType.FindSet;
        repeat
            asserterror
            begin
                DownloadServerFile(NcImportType);
                Commit;

                Error('');
            end;

            LastErrorText := GetLastErrorText + LastErrorText;
        until NcImportType.Next = 0;

        if LastErrorText <> '' then
            Error(CopyStr(LastErrorText, 1, 1000));
        //+NC2.12 [313362]
    end;

    [Scope('Personalization')]
    procedure DownloadServerFile(NcImportType: Record "Nc Import Type")
    var
        FileMgt: Codeunit "File Management";
        ArrayHelper: DotNet npNetArray;
        ServerDirectoryHelper: DotNet npNetDirectory;
        i: Integer;
        Filename: Text;
    begin
        //-NC2.12 [313362]
        NcImportType.TestField("Server File Enabled");
        NcImportType.TestField("Server File Path");

        //-NC.2.15 [313184]
        ArrayHelper := ServerDirectoryHelper.GetFiles(NcImportType."Server File Path");
        for i := 0 to ArrayHelper.GetLength(0) - 1 do begin
            Filename := ArrayHelper.GetValue(i);
            InsertImportEntry2(NcImportType, Filename);
        end;
        //+NC.2.15 [313184]
        //+NC2.12 [313362]
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure InsertImportEntry2(NcImportType: Record "Nc Import Type"; Filename: Text)
    var
        NcImportEntry: Record "Nc Import Entry";
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        RecRef: RecordRef;
    begin
        //-NC2.12 [313362]
        FileMgt.BLOBImportFromServerFile(TempBlob, Filename);
        //+NC.2.15 [313184]

        NcImportEntry.Init;
        NcImportEntry."Entry No." := 0;
        NcImportEntry."Import Type" := NcImportType.Code;
        NcImportEntry.Date := CurrentDateTime;
        //-NC.2.15 [306532]
        NcImportEntry."Document Name" := GetDocName(FileMgt.GetFileName(Filename), MaxStrLen(NcImportEntry."Document Name"));
        //+NC.2.15 [306532]
        NcImportEntry.Imported := false;
        NcImportEntry."Runtime Error" := false;

        RecRef.GetTable(NcImportEntry);
        TempBlob.ToRecordRef(RecRef, NcImportEntry.FieldNo("Document Source"));
        RecRef.SetTable(NcImportEntry);

        NcImportEntry.Insert(true);

        if Erase(Filename) then;
        Commit;
        //+NC2.06 [290633]
    end;

    local procedure "--- Process Import"()
    begin
    end;

    [Scope('Personalization')]
    procedure ProcessImportEntry(var ImportEntry: Record "Nc Import Entry"): Boolean
    var
        DataLogMgt: Codeunit "Data Log Management";
        NaviConnectImportMgt: Codeunit "Nc Import Mgt.";
    begin
        Clear(NaviConnectImportMgt);
        ImportEntryReset(ImportEntry);
        //-NC2.22 [358499]
        ClearLastError;
        //+NC2.22 [358499]
        if NaviConnectImportMgt.Run(ImportEntry) then begin
            //-NC2.12 [308107]
            DataLogMgt.DisableDataLog(false);
            //+NC2.12 [308107]
            ImportEntryComplete(ImportEntry);
            exit(true);
        end;

        //-NC2.12 [308107]
        DataLogMgt.DisableDataLog(false);
        //+NC2.12 [308107]
        ImportEntryError(ImportEntry);
        exit(false);
    end;

    [Scope('Personalization')]
    procedure ProcessImportEntries()
    var
        ImportEntry: Record "Nc Import Entry";
    begin
        ImportEntry.SetRange(Imported, false);
        ImportEntry.SetRange("Runtime Error", false);
        if ImportEntry.FindSet then
            repeat
                ProcessImportEntry(ImportEntry);
                //-NC2.16 [313184]
                if (CurrentDateTime > SyncEndTime) and (SyncEndTime <> 0DT) then
                    exit;
            //+NC2.16 [313184]
            until ImportEntry.Next = 0;
    end;

    [Scope('Personalization')]
    procedure ProcessTask(var Task: Record "Nc Task"): Boolean
    var
        TaskSetup: Record "Nc Task Setup";
    begin
        TaskReset(Task);
        TaskSetup.SetRange("Task Processor Code", Task."Task Processor Code");
        TaskSetup.SetRange("Table No.", Task."Table No.");
        if TaskSetup.FindSet then
            repeat
                if Task.Get(Task."Entry No.") then;
                //-NC2.22 [358499]
                ClearLastError;
                //+NC2.22 [358499]
                if not CODEUNIT.Run(TaskSetup."Codeunit ID", Task) then begin
                    TaskError(Task);
                    exit(false);
                end;
            until TaskSetup.Next = 0;
        TaskComplete(Task);
        exit(true);
    end;

    [Scope('Personalization')]
    procedure ProcessTasks(TaskProcessor: Record "Nc Task Processor"; MaxRetry: Integer)
    var
        Task: Record "Nc Task";
    begin
        if MaxRetry < 1 then
            MaxRetry := 1;

        Task.SetRange("Task Processor Code", TaskProcessor.Code);
        Task.SetRange(Processed, false);
        Task.SetFilter("Process Count", '<%1', MaxRetry);
        if Task.FindSet then
            repeat
                ProcessTask(Task);
                //-NC2.16 [313184]
                if (CurrentDateTime > SyncEndTime) and (SyncEndTime <> 0DT) then
                    exit;
            //+NC2.16 [313184]
            until Task.Next = 0;
    end;

    local procedure "--- Status Mgt."()
    begin
    end;

    local procedure ImportEntryComplete(var ImportEntry: Record "Nc Import Entry")
    var
        ErrorText: Text[1024];
    begin
        if not ImportEntry.Get(ImportEntry."Entry No.") then
            exit;
        ErrorText := GetLastErrorText;
        Clear(ImportEntry."Last Error Message");
        ImportEntry."Error Message" := '';
        ImportEntry.Imported := true;
        ImportEntry."Runtime Error" := false;
        //-NC2.16 [313184]
        ImportEntry."Import Completed at" := CurrentDateTime;
        ImportEntry."Import Duration" := (ImportEntry."Import Completed at" - ImportEntry."Import Started at") / 1000;
        //+NC2.16 [313184]
        ImportEntry.Modify(true);
        ClearLastError;
        Commit;
    end;

    local procedure ImportEntryError(var ImportEntry: Record "Nc Import Entry")
    var
        NcImportMgt: Codeunit "Nc Import Mgt.";
        OutStream: OutStream;
        ErrorText: Text[1024];
    begin
        if not ImportEntry.Get(ImportEntry."Entry No.") then
            exit;
        ErrorText := GetLastErrorText;
        //-NC2.22 [334216]
        if ErrorText <> '' then begin
            Clear(ImportEntry."Last Error Message");
            ImportEntry."Error Message" := CopyStr(ErrorText, 1, MaxStrLen(ImportEntry."Error Message"));
            ImportEntry."Last Error Message".CreateOutStream(OutStream);
            OutStream.Write(ErrorText);
        end;
        //+NC2.22 [334216]
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := true;
        //-NC2.16 [313184]
        ImportEntry."Import Completed at" := CurrentDateTime;
        ImportEntry."Import Duration" := (ImportEntry."Import Completed at" - ImportEntry."Import Started at") / 1000;
        //+NC2.16 [313184]
        ImportEntry.Modify(true);
        ClearLastError;
        Commit;
        //-NC2.23 [369170]
        asserterror
        begin
            NcImportMgt.SendErrorMail(ImportEntry);
            Commit;
            Error('');
        end;
        //+NC2.23 [369170]
    end;

    local procedure ImportEntryReset(var ImportEntry: Record "Nc Import Entry")
    var
        OutStream: OutStream;
        ErrorText: Text[1024];
    begin
        Clear(ImportEntry."Last Error Message");
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := true;
        //-NC2.16 [313184]
        ImportEntry."Import Started at" := CurrentDateTime;
        ImportEntry."Import Duration" := 0;
        ImportEntry."Import Completed at" := 0DT;
        //+NC2.16 [313184]
        ImportEntry.Modify(true);
        Commit;
    end;

    local procedure TaskComplete(var NaviConnectTask: Record "Nc Task")
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

    local procedure TaskError(var NaviConnectTask: Record "Nc Task")
    var
        OutStream: OutStream;
        ErrorText: Text[1024];
    begin
        NaviConnectTask.LockTable;
        if not NaviConnectTask.Get(NaviConnectTask."Entry No.") then
            exit;

        //-NC2.16 [313184]
        NaviConnectTask."Last Processing Completed at" := CurrentDateTime;
        NaviConnectTask."Last Processing Duration" := (NaviConnectTask."Last Processing Completed at" - NaviConnectTask."Last Processing Started at") / 1000;
        //+NC2.16 [313184]

        ErrorText := GetLastErrorText;

        if ErrorText <> '' then begin
            NaviConnectTask.Response.CreateOutStream(OutStream);
            OutStream.Write(ErrorText);
            ClearLastError;
        end;

        //-NC2.16 [313184]
        NaviConnectTask.Modify(true);
        //+NC2.16 [313184]
        Commit;
    end;

    local procedure TaskReset(var NaviConnectTask: Record "Nc Task")
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

    local procedure TaskResetCount()
    var
        NaviConnectTask: Record "Nc Task";
        NcTaskMgt: Codeunit "Nc Task Mgt.";
    begin
        //-NC2.08 [297750]
        NcTaskMgt.CleanTasks();
        Commit;
        //+NC2.08 [297750]
        NaviConnectTask.SetCurrentKey("Log Date", Processed);
        NaviConnectTask.SetRange(Processed, false);
        NaviConnectTask.ModifyAll("Process Count", 0);
        Commit;
    end;

    [Scope('Personalization')]
    procedure UpdateTaskProcessor(TaskProcessor: Record "Nc Task Processor")
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

    local procedure "--- Ftp List"()
    begin
    end;

    local procedure CreateFtpWebRequest(ImportType: Record "Nc Import Type"; var FtpWebRequest: DotNet npNetFtpWebRequest)
    var
        Uri: DotNet npNetUri;
    begin
        //-NC2.06 [290633]
        Uri := Uri.Uri(ImportType."Ftp Host" + '/' + ImportType."Ftp Path" + '/');
        FtpWebRequest := FtpWebRequest.Create(Uri);
        //+NC2.06 [290633]
        //-NC2.08 [295322]
        if ImportType."Ftp Binary" then
            FtpWebRequest.UseBinary := true;
        //+NC2.08 [295322]
        //-NC2.19 [340695]
        FtpWebRequest.KeepAlive := false;
        //+NC2.19 [340695]
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
            //-NC2.05 [275177]
            Filename := Details;
        //+NC2.05 [275177]
        until (Filename <> '') or (ListDirectoryDetails = '');

        exit((Filename <> '') or (ListDirectoryDetails <> ''));
    end;

    local procedure CutNextFilenameDetailed(var ListDirectoryDetails: Text; var Filename: Text): Boolean
    var
        Details: Text;
    begin
        //-NC2.06 [290633]
        if ListDirectoryDetails = '' then
            exit(false);

        Filename := '';
        repeat
            CutNextLineDetailed(ListDirectoryDetails, Details);
            Filename := ParseFilename(Details);
        until (Filename <> '') or (ListDirectoryDetails = '');

        exit((Filename <> '') or (ListDirectoryDetails <> ''));
        //+NC2.06 [290633]
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
            //-NC2.05 [275177]
            ListDirectoryDetails := DelStr(ListDirectoryDetails, 1, Position + 1);
            //-NC2.05 [275177]
        end;
    end;

    local procedure CutNextLineDetailed(var ListDirectoryDetails: Text; var Details: Text)
    var
        Position: Integer;
    begin
        //-NC2.06 [290633]
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
        //+NC2.06 [290633]
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure DownloadFtpListDirectory(ImportType: Record "Nc Import Type"; var ListDirectory: Text)
    var
        Credential: DotNet npNetNetworkCredential;
        FtpWebRequest: DotNet npNetFtpWebRequest;
        FtpWebResponse: DotNet npNetFtpWebResponse;
        MemoryStream: DotNet npNetMemoryStream;
        StreamReader: DotNet npNetStreamReader;
    begin
        //-NC2.06 [290633]
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
        //+NC2.06 [290633]
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure DownloadFtpListDirectoryDetails(ImportType: Record "Nc Import Type"; var ListDirectoryDetails: Text)
    var
        Credential: DotNet npNetNetworkCredential;
        FtpWebRequest: DotNet npNetFtpWebRequest;
        FtpWebResponse: DotNet npNetFtpWebResponse;
        MemoryStream: DotNet npNetMemoryStream;
        StreamReader: DotNet npNetStreamReader;
    begin
        //-NC2.06 [290633]
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
        //+NC2.06 [290633]
    end;

    [TryFunction]
    local procedure DownloadSftpFilenames(ImportType: Record "Nc Import Type"; var ListDirectory: Text)
    var
        SharpSFtp: DotNet npNetSftp0;
        FileList: DotNet npNetIList;
        IEnumerator: DotNet npNetIEnumerator;
        LsEntry: DotNet npNetChannelSftp_LsEntry;
        RemotePath: Text;
        NetConvHelper: Variant;
    begin
        //-NC2.16 [328432]
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
        //+NC2.16 [328432]
        //-NC2.19 [340695]
        SharpSFtp.Close;
        //+NC2.19 [340695]
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
        Match: DotNet npNetMatch;
        RegEx: DotNet npNetRegex;
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
        Match: DotNet npNetMatch;
        RegEx: DotNet npNetRegex;
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
        Match: DotNet npNetMatch;
        RegEx: DotNet npNetRegex;
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
        Match: DotNet npNetMatch;
        RegEx: DotNet npNetRegex;
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
        //-NC2.05 [275177]
        //IF Position = 1 THEN
        if (Position = 1) or (Position = 0) then
            exit(false);
        //+NC2.05 [275177]
        if Position = StrLen(Filename) then
            exit;

        exit(true);
    end;

    local procedure "--- Aux"()
    begin
    end;

    [TryFunction]
    local procedure CheckFtpUrlExists(FtpUrl: Text; Username: Text; Password: Text)
    var
        Credential: DotNet npNetNetworkCredential;
        FtpWebRequest: DotNet npNetFtpWebRequest;
        FtpWebResponse: DotNet npNetFtpWebResponse;
        MemoryStream: DotNet npNetMemoryStream;
    begin
        FtpWebRequest := FtpWebRequest.Create(FtpUrl);
        //-NC2.25 [386177]
        FtpWebRequest.Method := 'NLST'; //WebRequestMethods.Ftp.ListDirectory
        //+NC2.25 [386177]
        //-NC2.19 [340695]
        FtpWebRequest.KeepAlive := false;
        //-NC2.19 [340695]
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
        Credential: DotNet npNetNetworkCredential;
        FtpWebRequest: DotNet npNetFtpWebRequest;
        FtpWebResponse: DotNet npNetFtpWebResponse;
    begin
        FtpWebRequest := FtpWebRequest.Create(FtpUrl);
        if Username <> '' then
            FtpWebRequest.Credentials := Credential.NetworkCredential(Username, Password);
        FtpWebRequest.Method := 'DELE'; //WebRequestMethods.Ftp.DeleteFile
        //-NC2.19 [340695]
        FtpWebRequest.KeepAlive := false;
        //-NC2.19 [340695]
        FtpWebResponse := FtpWebRequest.GetResponse;
    end;

    local procedure GetDocName(Filename: Text; MaxLength: Integer) DocName: Text
    var
        FileMgt: Codeunit "File Management";
        DocExt: Text;
    begin
        //-NC.2.15 [306532]
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
        //+NC.2.15 [306532]
    end;

    [TryFunction]
    local procedure MakeFtpUrl(FtpUrl: Text; Username: Text; Password: Text)
    var
        Credential: DotNet npNetNetworkCredential;
        FtpWebRequest: DotNet npNetFtpWebRequest;
        FtpWebResponse: DotNet npNetFtpWebResponse;
        MemoryStream: DotNet npNetMemoryStream;
    begin
        FtpWebRequest := FtpWebRequest.Create(FtpUrl);
        FtpWebRequest.Method := 'MKD'; //WebRequestMethods.Ftp.MakeDirectory
        //-NC2.19 [340695]
        FtpWebRequest.KeepAlive := false;
        //-NC2.19 [340695]
        if Username <> '' then
            FtpWebRequest.Credentials := Credential.NetworkCredential(Username, Password);
        FtpWebResponse := FtpWebRequest.GetResponse;
        MemoryStream := FtpWebResponse.GetResponseStream();
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
    end;

    [Scope('Personalization')]
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
        Credential: DotNet npNetNetworkCredential;
        FtpWebRequest: DotNet npNetFtpWebRequest;
        FtpWebResponse: DotNet npNetFtpWebResponse;
    begin
        FtpWebRequest := FtpWebRequest.Create(FtpUrl);
        if Username <> '' then
            FtpWebRequest.Credentials := Credential.NetworkCredential(Username, Password);
        FtpWebRequest.Method := 'RENAME'; //WebRequestMethods.Ftp.Rename
        //-NC2.19 [340695]
        FtpWebRequest.KeepAlive := false;
        //-NC2.19 [340695]
        FtpWebRequest.RenameTo := RenameTo;
        FtpWebResponse := FtpWebRequest.GetResponse;
    end;

    [Scope('Personalization')]
    procedure "--- Constants"()
    begin
    end;

    [Scope('Personalization')]
    procedure "Parameter.CleanupImport"(): Code[20]
    begin
        exit('CLEANUP_IMPORT');
    end;

    [Scope('Personalization')]
    procedure "Parameter.DownloadFtp"(): Code[20]
    begin
        exit('DOWNLOAD_FTP');
    end;

    [Scope('Personalization')]
    procedure "Parameter.DownloadServerFile"(): Code[20]
    begin
        //-NC2.12 [313362]
        exit('DOWNLOAD_SERVER_FILE');
        //+NC2.12 [313362]
    end;

    [Scope('Personalization')]
    procedure "Parameter.DownloadType"(): Code[20]
    begin
        exit('DOWNLOAD_IMPORT_TYPE');
    end;

    [Scope('Personalization')]
    procedure "Parameter.ImportNewTasks"(): Code[20]
    begin
        exit('IMPORT_NEW_TASKS');
    end;

    [Scope('Personalization')]
    procedure "Parameter.ProcessImport"(): Code[20]
    begin
        exit('PROCESS_IMPORT');
    end;

    [Scope('Personalization')]
    procedure "Parameter.ProcessTasks"(): Code[20]
    begin
        exit('PROCESS_TASKS');
    end;

    [Scope('Personalization')]
    procedure "Parameter.ResetTaskCount"(): Code[20]
    begin
        exit('RESET_RETRY_COUNT');
    end;

    [Scope('Personalization')]
    procedure "Parameter.TaskRetryCount"(): Code[20]
    begin
        exit('TASK_RETRY_COUNT');
    end;

    [Scope('Personalization')]
    procedure "Parameter.TaskProcessorCode"(): Code[20]
    begin
        exit('TASK_PROCESSOR_CODE');
    end;

    [Scope('Personalization')]
    procedure "--- UI"()
    begin
    end;

    [Scope('Personalization')]
    procedure RunProcess(Filename: Text; Arguments: Text; Modal: Boolean)
    var
        [RunOnClient]
        Process: DotNet npNetProcess;
        [RunOnClient]
        ProcessStartInfo: DotNet npNetProcessStartInfo;
    begin
        ProcessStartInfo := ProcessStartInfo.ProcessStartInfo(Filename, Arguments);
        Process := Process.Start(ProcessStartInfo);
        if Modal then
            Process.WaitForExit();
    end;

    local procedure GetMaxSyncDuration() SyncDuration: Duration
    begin
        //-NC2.16 [313184]
        SyncDuration := 120000T - 113000T;
        exit(SyncDuration);
        //+NC2.16 [313184]
    end;
}

