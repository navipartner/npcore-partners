codeunit 6184504 "NPR SAF-T Cash Export Mgt."
{
    Access = Internal;
    TableNo = "NPR SAF-T Cash Export Header";

    trigger OnRun()
    begin
        StartExport(Rec);
    end;

    var
        CancelExportIsInProgressQst: Label 'Do you want to cancel all export jobs and restart?';
        DeleteExportIsInProgressQst: Label 'Do you want to delete the export entry?';
        ExportFileAlreadyExistQst: Label 'The export ZIP files already exist and are ready for download. Do you want to generate the ZIP files again?';
        ExportIsCompletedQst: Label 'The export was completed. You can download the export result choosing the Download SAF-T File action.\';
        ExportIsInProgressMsg: Label 'The export is in progress. Starting a new job cancels the current progress.\';
        FilesExistsInFolderErr: Label 'One or more files exist in the folder that you want to export the SAF-T file to. Specify a folder with no files in it.';
        GenerateSAFTFileImmediatelyQst: Label 'Since you did not schedule the SAF-T file generation, it will be generated immediately which can take a while. Do you want to continue?';
        JobsStartedOrFailedTxt: Label 'There are %1 jobs not started or failed', Comment = '%1 = number';
        LinesInProgressOrCompletedMsg: Label 'One or more export lines are in progress or completed.\';
        MasterDataMsg: Label 'Master Data without Transactions & Events';
        NoErrorMessageErr: Label 'The generation of a SAF-T file failed but no error message was logged.';
        NoOfJobsInProgressTxt: Label 'No of jobs in progress: %1', Comment = '%1 = number';
        NotPossibleToScheduleMsg: Label 'You are not allowed to schedule the SAF-T file generation';
        NotPossibleToScheduleTxt: Label 'It is not possible to schedule the task for line %1 because the Max. No. of Jobs field contains %2.', Comment = '%1,%2 = numbers';
        NoZipFileGeneratedErr: Label 'No zip file generated.';
        ParallelSAFTFileGenerationTxt: Label 'Parallel SAF-T file generation';
        RestartExportLineQst: Label 'Do you want to restart the export for this line?';
        RestartExportQst: Label 'Do you want to restart the export to get a new SAF-T file?';
        SAFTFileGeneratedTxt: Label 'SAF-T file generated.';
        SAFTFileNotGeneratedTxt: Label 'SAF-T file not generated.';
        SAFTZipFileTxt: Label 'SAF-T Cash Register_%1.zip', Locked = true;
        ScheduleTaskForLineTxt: Label 'Schedule a task for line %1.', Comment = '%1 = number';
        SessionLostTxt: Label 'The task for line %1 was lost.', Comment = '%1 = number';
        SetStartDateTimeAsCurrentQst: Label 'The Earliest Start Date/Time field is not filled in. Do you want to proceed and start the export immediately?';
        TransactionsMsg: Label 'Transactions & Events from %1 to %2';
        ZipArchiveFilterTxt: Label 'Zip File (*.zip)|*.zip', Locked = true;
        ZipArchiveSaveDialogTxt: Label 'Export SAF-T archive';

    local procedure StartExport(var SAFTExportHeader: Record "NPR SAF-T Cash Export Header")
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        if not PrepareForExport(SAFTExportHeader) then
            exit;

        CreateExportLines(SAFTExportHeader);

        SAFTExportHeader.Validate(Status, SAFTExportHeader.Status::"In Progress");
        SAFTExportHeader.Validate("Execution Start Date/Time", TypeHelper.GetCurrentDateTimeInUserTimeZone());
        SAFTExportHeader.Validate("Execution End Date/Time", 0DT);
        SAFTExportHeader.Modify(true);

        Commit();

        StartExportLines(SAFTExportHeader);
        SAFTExportHeader.Find();
    end;

    internal procedure DeleteExport(var SAFTExportHeader: Record "NPR SAF-T Cash Export Header")
    var
        SAFTExportLine: Record "NPR SAF-T Cash Export Line";
    begin
        if not CheckStatus(SAFTExportHeader.Status, DeleteExportIsInProgressQst) then
            exit;

        SAFTExportLine.SetRange(ID, SAFTExportHeader.ID);
        SAFTExportLine.SetRange(Status, SAFTExportLine.Status::"In Progress");
        if SAFTExportLine.FindSet() then
            repeat
                CancelTask(SAFTExportLine);
            until SAFTExportLine.Next() = 0;

        SAFTExportLine.SetRange(Status);
        SAFTExportLine.DeleteAll(true);
    end;

    internal procedure ThrowNoParallelExecutionNotification()
    var
        ParallelExecutionNotification: Notification;
    begin
        ParallelExecutionNotification.Message := NotPossibleToScheduleMsg;
        ParallelExecutionNotification.Scope := NotificationScope::LocalScope;
        ParallelExecutionNotification.Send();
    end;

    internal procedure RestartTaskOnExportLine(var SAFTExportLine: Record "NPR SAF-T Cash Export Line")
    var
        SAFTExportHeader: Record "NPR SAF-T Cash Export Header";
        NotBefore: DateTime;
        DummyNoOfJobs: Integer;
    begin
        if not CheckLineStatusForRestart(SAFTExportLine) then
            exit;

        if not SAFTExportLine.FindSet() then
            exit;

        repeat
            SAFTExportLine.SetRange(ID, SAFTExportLine.ID);
            repeat
                CancelTask(SAFTExportLine);
                SAFTExportHeader.Get(SAFTExportLine.ID);
                NotBefore := CurrentDateTime();
                RunGenerateSAFTFileOnSingleLine(SAFTExportLine, DummyNoOfJobs, NotBefore, SAFTExportHeader);
            until SAFTExportLine.Next() = 0;

            SAFTExportHeader.Find();
            UpdateExportStatus(SAFTExportHeader);
            SAFTExportLine.SetRange(ID);
        until SAFTExportLine.Next() = 0;
    end;

    internal procedure UpdateExportStatus(var SAFTExportHeader: Record "NPR SAF-T Cash Export Header")
    var
        SAFTExportLine: Record "NPR SAF-T Cash Export Line";
        TypeHelper: Codeunit "Type Helper";
        Status: Enum "NPR SAF-T Cash Export Status";
        TotalCount: Integer;
    begin
        if SAFTExportHeader.ID = 0 then
            exit;

        SAFTExportLine.SetRange(ID, SAFTExportHeader.ID);
        TotalCount := SAFTExportLine.Count();
        SAFTExportLine.SetRange(Status, SAFTExportLine.Status::Completed);
        if SAFTExportLine.Count() = TotalCount then begin
            SAFTExportHeader.Validate(Status, SAFTExportHeader.Status::Completed);
            SAFTExportHeader.Validate("Execution End Date/Time", TypeHelper.GetCurrentDateTimeInUserTimeZone());
            SAFTExportHeader.Modify(true);
            exit;
        end;

        SAFTExportLine.SetRange(Status, SAFTExportLine.Status::Failed);
        if SAFTExportLine.IsEmpty() then
            Status := SAFTExportHeader.Status::"In Progress"
        else
            Status := SAFTExportHeader.Status::Failed;

        SAFTExportHeader.Validate(Status, Status);
        SAFTExportHeader.Modify(true);
    end;

    internal procedure StartExportLinesNotStartedYet(SAFTExportHeader: Record "NPR SAF-T Cash Export Header")
    var
        SAFTExportLine: Record "NPR SAF-T Cash Export Line";
        RunThisLine: Boolean;
        NotBefore: DateTime;
        NoOfJobs: Integer;
    begin
        if not SAFTExportHeader."Parallel Processing" then
            exit;

        NoOfJobs := GetNoOfJobsInProgress();
        LogState(SAFTExportLine, StrSubstNo(NoOfJobsInProgressTxt, NoOfJobs));
        if NoOfJobs > SAFTExportHeader."Max No. Of Jobs" then
            exit;

        SAFTExportLine.LockTable();
        SAFTExportLine.SetRange(ID, SAFTExportHeader.ID);
        SAFTExportLine.SetFilter("No. Of Retries", '<>%1', 0);
        SAFTExportLine.SetFilter(Status, '<>%1', SAFTExportLine.Status::Completed);
        LogState(SAFTExportLine, StrSubstNo(JobsStartedOrFailedTxt, SAFTExportLine.Count()));
        if not SAFTExportLine.FindSet() then
            exit;

        NotBefore := CurrentDateTime();
        repeat
            RunThisLine := false;
            if SAFTExportLine.Status = SAFTExportLine.Status::"In Progress" then begin
                RunThisLine := not IsSessionActive(SAFTExportLine);
                if RunThisLine then
                    LogState(SAFTExportLine, StrSubstNo(SessionLostTxt, SAFTExportLine."Line No."));
            end else
                RunThisLine := true;

            if RunThisLine then
                RunGenerateSAFTFileOnSingleLine(SAFTExportLine, NoOfJobs, NotBefore, SAFTExportHeader);
        until SAFTExportLine.Next() = 0;
    end;

    internal procedure ShowActivityLog(SAFTExportLine: Record "NPR SAF-T Cash Export Line")
    var
        ActivityLog: Record "Activity Log";
        ActivityLogPage: Page "Activity Log";
    begin
        ActivityLog.SetRange("Record ID", SAFTExportLine.RecordId());
        ActivityLogPage.SetTableView(ActivityLog);
        ActivityLogPage.Run();
    end;

    internal procedure ShowErrorOnExportLine(SAFTExportLine: Record "NPR SAF-T Cash Export Line")
    var
        ActivityLog: Record "Activity Log";
        Stream: InStream;
        ErrorMessage: Text;
    begin
        ActivityLog.SetRange("Record ID", SAFTExportLine.RecordId());
        if not ActivityLog.FindLast() or (ActivityLog.Status <> ActivityLog.Status::Failed) then
            exit;

        ActivityLog.CalcFields("Detailed Info");
        if not ActivityLog."Detailed Info".HasValue() then
            Error(NoErrorMessageErr);

        ActivityLog."Detailed Info".CreateInStream(Stream);
        Stream.ReadText(ErrorMessage);
        if ErrorMessage = '' then
            Error(NoErrorMessageErr);

        Message(ErrorMessage);
    end;

    internal procedure LogSuccess(SAFTExportLine: Record "NPR SAF-T Cash Export Line")
    var
        ActivityLog: Record "Activity Log";
    begin
        ActivityLog.LogActivity(SAFTExportLine.RecordId(), ActivityLog.Status::Success, '', SAFTFileGeneratedTxt, '');
    end;

    internal procedure LogError(SAFTExportLine: Record "NPR SAF-T Cash Export Line")
    var
        ActivityLog: Record "Activity Log";
        ErrorMessage: Text;
    begin
        ErrorMessage := GetLastErrorText();
        ActivityLog.LogActivity(SAFTExportLine.RecordId(), ActivityLog.Status::Failed, '', SAFTFileNotGeneratedTxt, ErrorMessage);
        ActivityLog.SetDetailedInfoFromText(ErrorMessage);
    end;

    local procedure LogState(SAFTExportLine: Record "NPR SAF-T Cash Export Line"; Description: Text[250])
    var
        ActivityLog: Record "Activity Log";
    begin
        ActivityLog.LogActivity(SAFTExportLine.RecordId(), ActivityLog.Status::Success, '', ParallelSAFTFileGenerationTxt, Description);
    end;

    local procedure StartExportLines(SAFTExportHeader: Record "NPR SAF-T Cash Export Header")
    var
        SAFTExportLine: Record "NPR SAF-T Cash Export Line";
        NotBefore: DateTime;
        NoOfJobs: Integer;
    begin
        SAFTExportLine.LockTable();
        SAFTExportLine.SetRange(ID, SAFTExportHeader.ID);
        SAFTExportLine.FindSet();
        NoOfJobs := 1;
        NotBefore := SAFTExportHeader."Earliest Start Date/Time";
        repeat
            RunGenerateSAFTFileOnSingleLine(SAFTExportLine, NoOfJobs, NotBefore, SAFTExportHeader);
        until SAFTExportLine.Next() = 0;
    end;

    local procedure RunGenerateSAFTFileOnSingleLine(var SAFTExportLine: Record "NPR SAF-T Cash Export Line"; var NoOfJobs: Integer; var NotBefore: DateTime; SAFTExportHeader: Record "NPR SAF-T Cash Export Header")
    var
        DoNotScheduleTask: Boolean;
        TaskID: Guid;
    begin
        if SAFTExportHeader."Parallel Processing" and (NoOfJobs > SAFTExportHeader."Max No. Of Jobs") then begin
            LogState(
                SAFTExportLine, StrSubstNo(NotPossibleToScheduleTxt, SAFTExportLine."Line No.", NoOfJobs));
            exit;
        end;

        SAFTExportLine.Validate(Status, SAFTExportLine.Status::"In Progress");
        Clear(SAFTExportLine."SAF-T File");
        SAFTExportLine.Validate(Progress, 0);
        if SAFTExportHeader."Parallel Processing" then begin
            LogState(SAFTExportLine, StrSubstNo(ScheduleTaskForLineTxt, SAFTExportLine."Line No."));

            NotBefore += 3000; // have a delay between running jobs to avoid deadlocks
            OnBeforeScheduleTask(DoNotScheduleTask, TaskID);
            if DoNotScheduleTask then
                SAFTExportLine."Task ID" := TaskID
            else
                SAFTExportLine."Task ID" :=
                    TaskScheduler.CreateTask(
                        Codeunit::"NPR Generate SAF-T Cash File", Codeunit::"NPR SAF-T Export Error Handler", true, CompanyName(),
                        NotBefore, SAFTExportLine.RecordId());
            SAFTExportLine.Modify(true);
            Commit();
            NoOfJobs += 1;
            exit;
        end;
        SAFTExportLine."Task ID" := CreateGuid();
        SAFTExportLine.Modify(true);
        Commit();

        ClearLastError();
        if not Codeunit.Run(Codeunit::"NPR Generate SAF-T Cash File", SAFTExportLine) then
            Codeunit.Run(Codeunit::"NPR SAF-T Export Error Handler", SAFTExportLine);
        Commit();
    end;

    local procedure PrepareForExport(var SAFTExportHeader: Record "NPR SAF-T Cash Export Header"): Boolean
    var
        ErrorMessageHandler: Codeunit "Error Message Handler";
        ErrorMessageManagement: Codeunit "Error Message Management";
        SAFTExportCheck: Codeunit "NPR SAF-T Cash Export Check";
    begin
        ErrorMessageManagement.Activate(ErrorMessageHandler);
        SAFTExportCheck.Run(SAFTExportHeader);
        if ErrorMessageManagement.GetLastErrorID() <> 0 then begin
            ErrorMessageHandler.ShowErrors();
            exit(false);
        end;

        if SAFTExportHeader.Status = SAFTExportHeader.Status::"In Progress" then
            if HandleConfirm(StrSubstNo('%1%2', ExportIsInProgressMsg, CancelExportIsInProgressQst)) then
                RemoveExportLines(SAFTExportHeader)
            else
                exit(false);

        if SAFTExportHeader.Status = SAFTExportHeader.Status::Completed then
            if not HandleConfirm(StrSubstNo('%1%2', ExportIsCompletedQst, RestartExportQst)) then
                exit(false);

        if (SAFTExportHeader."Parallel Processing") and (SAFTExportHeader."Earliest Start Date/Time" = 0DT) then begin
            if not HandleConfirm(SetStartDateTimeAsCurrentQst) then
                exit(false);

            SAFTExportHeader."Earliest Start Date/Time" := CurrentDateTime();
        end;
        if not SAFTExportHeader."Parallel Processing" then
            if not HandleConfirm(GenerateSAFTFileImmediatelyQst) then
                exit(false);

        exit(true)
    end;

    local procedure CreateExportLines(SAFTExportHeader: Record "NPR SAF-T Cash Export Header")
    var
        POSEntry: Record "NPR POS Entry";
        SAFTExportLine: Record "NPR SAF-T Cash Export Line";
        ShiftDateFormula: DateFormula;
        StopExportEntriesByPeriod: Boolean;
        EndingDate: Date;
        StartingDate: Date;
        LineNo: Integer;
    begin
        SAFTExportLine.SetRange(ID, SAFTExportHeader.ID);
        SAFTExportLine.DeleteAll(true);

        // Master data
        InsertSAFTExportLine(SAFTExportLine, LineNo, SAFTExportHeader, true, MasterDataMsg, SAFTExportHeader."Starting Date", SAFTExportHeader."Ending Date");
        if (not SAFTExportHeader."Split By Month") and (not SAFTExportHeader."Split By Date") then begin
            // Transaction & Events
            InsertSAFTExportLine(
                SAFTExportLine, LineNo, SAFTExportHeader, false,
                StrSubstNo(TransactionsMsg, SAFTExportHeader."Starting Date", SAFTExportHeader."Ending Date"),
                SAFTExportHeader."Starting Date", SAFTExportHeader."Ending Date");
            exit;
        end;

        StartingDate := SAFTExportHeader."Starting Date";
        if SAFTExportHeader."Split By Month" then
            Evaluate(ShiftDateFormula, '<CM>')
        else
            Evaluate(ShiftDateFormula, '<0D>');

        EndingDate := CalcDate(ShiftDateFormula, SAFTExportHeader."Starting Date");
        repeat
            StopExportEntriesByPeriod := EndingDate >= SAFTExportHeader."Ending Date";
            if CalcDate(ShiftDateFormula, EndingDate) >= SAFTExportHeader."Ending Date" then
                EndingDate := ClosingDate(EndingDate);

            POSEntry.SetRange("Entry Date", StartingDate, EndingDate);
            if not POSEntry.IsEmpty() then
                InsertSAFTExportLine(
                    SAFTExportLine, LineNo, SAFTExportHeader, false,
                    StrSubstNo(TransactionsMsg, StartingDate, EndingDate), StartingDate, EndingDate);

            StartingDate := NormalDate(EndingDate) + 1;
            EndingDate := CalcDate(ShiftDateFormula, StartingDate);
        until StopExportEntriesByPeriod;
    end;

    local procedure InsertSAFTExportLine(var SAFTExportLine: Record "NPR SAF-T Cash Export Line"; var LineNo: Integer; SAFTExportHeader: Record "NPR SAF-T Cash Export Header"; MasterData: Boolean; Description: Text; StartingDate: Date; EndingDate: Date)
    begin
        SAFTExportLine.Init();
        SAFTExportLine.Validate(ID, SAFTExportHeader.ID);
        LineNo += 1;
        SAFTExportLine.Validate("Line No.", LineNo);
        SAFTExportLine.Validate("Master Data", MasterData);
        SAFTExportLine.Validate(Description, CopyStr(Description, 1, MaxStrLen(Description)));
        SAFTExportLine.Validate("Starting Date", StartingDate);
        SAFTExportLine.Validate("Ending Date", EndingDate);
        SAFTExportLine.Insert(true);
    end;

    local procedure RemoveExportLines(var SAFTExportHeader: Record "NPR SAF-T Cash Export Header")
    var
        SAFTExportLine: Record "NPR SAF-T Cash Export Line";
    begin
        SAFTExportLine.SetRange(ID, SAFTExportHeader.ID);
        if not SAFTExportLine.FindSet() then
            exit;

        repeat
            RemoveExportLine(SAFTExportLine);
        until SAFTExportLine.Next() = 0;
    end;

    local procedure RemoveExportLine(var SAFTExportLine: Record "NPR SAF-T Cash Export Line")
    begin
        CancelTask(SAFTExportLine);
        SAFTExportLine.Delete(true);
    end;

    local procedure CancelTask(SAFTExportLine: Record "NPR SAF-T Cash Export Line")
    var
        DoNotCancelTask: Boolean;
    begin
        if IsNullGuid(SAFTExportLine."Task ID") then
            exit;

        OnBeforeCancelTask(DoNotCancelTask);
        if not DoNotCancelTask then
            if TaskScheduler.TaskExists(SAFTExportLine."Task ID") then
                TaskScheduler.CancelTask(SAFTExportLine."Task ID");
    end;

    internal procedure GenerateZipFileWithCheck(SAFTExportHeader: Record "NPR SAF-T Cash Export Header")
    var
        ConfirmationMgt: Codeunit "Confirm Management";
    begin
        if ExportFilesExist(SAFTExportHeader) then
            if not ConfirmationMgt.GetResponseOrDefault(ExportFileAlreadyExistQst, false) then
                exit;

        GenerateZipFile(SAFTExportHeader);
    end;

    internal procedure GenerateZipFile(SAFTExportHeader: Record "NPR SAF-T Cash Export Header")
    begin
        if SAFTExportHeader.Status <> SAFTExportHeader.Status::Completed then
            exit;

        ClearExportFiles(SAFTExportHeader);

        if SAFTExportHeader.AllowedToExportIntoFolder() then begin
            if not SAFTExportHeader."Disable Zip File Generation" then
                GenerateZipFileFromSavedFiles(SAFTExportHeader);
        end else
            BuildZipFilesWithAllRelatedXmlFiles(SAFTExportHeader);
    end;

    internal procedure BuildZipFilesWithAllRelatedXmlFiles(SAFTExportHeader: Record "NPR SAF-T Cash Export Header")
    var
        CompanyInformation: Record "Company Information";
        SAFTExportLine: Record "NPR SAF-T Cash Export Line";
        SAFTXMLHelper: Codeunit "NPR SAF-T XML Helper";
        TotalNumberOfFiles: Integer;
    begin
        CompanyInformation.Get();
        SAFTExportLine.SetRange(ID, SAFTExportHeader.ID);
        SAFTExportLine.FindSet();
        TotalNumberOfFiles := SAFTExportLine.Count();
        repeat
            SAFTXMLHelper.ExportSAFTExportLineBlobToFile(
                SAFTExportLine,
                SAFTXMLHelper.GetFilePath(
                    CompanyInformation."VAT Registration No.", SAFTExportLine."Created Date/Time",
                    SAFTExportLine."Line No.", TotalNumberOfFiles));
        until SAFTExportLine.Next() = 0;

        ZipMultipleXMLFilesInServerFolder(SAFTExportHeader);
    end;

    internal procedure GenerateZipFileFromSavedFiles(SAFTExportHeader: Record "NPR SAF-T Cash Export Header")
    begin
        if not SAFTExportHeader.AllowedToExportIntoFolder() then
            exit;

        SaveZipOfMultipleXMLFiles(SAFTExportHeader);
    end;

    internal procedure DownloadZipFileFromExportHeader(SAFTExportHeader: Record "NPR SAF-T Cash Export Header")
    var
        SAFTExportFile: Record "NPR SAF-T Cash Export Zip";
        ZipFileInStream: InStream;
        FileName: Text;
    begin
        SAFTExportFile.SetRange("Export ID", SAFTExportHeader.ID);
        if not SAFTExportFile.FindSet() then
            Error(NoZipFileGeneratedErr);

        repeat
            SAFTExportFile.CalcFields("SAF-T File");
            SAFTExportFile."SAF-T File".CreateInStream(ZipFileInStream);
            FileName := StrSubstNo(SAFTZipFileTxt, SAFTExportFile."Zip No.");

            DownloadFromStream(ZipFileInStream, ZipArchiveSaveDialogTxt, '', ZipArchiveFilterTxt, FileName);
        until SAFTExportFile.Next() = 0;
    end;

    internal procedure DownloadExportFile(SAFTExportFile: Record "NPR SAF-T Cash Export Zip")
    var
        ZipFileInStream: InStream;
        FileName: Text;
    begin
        SAFTExportFile.CalcFields("SAF-T File");
        if not SAFTExportFile."SAF-T File".HasValue() then
            Error(NoZipFileGeneratedErr);

        SAFTExportFile."SAF-T File".CreateInStream(ZipFileInStream);
        FileName := StrSubstNo(SAFTZipFileTxt, SAFTExportFile."Zip No.");

        DownloadFromStream(ZipFileInStream, ZipArchiveSaveDialogTxt, '', ZipArchiveFilterTxt, FileName);
    end;

    internal procedure ZipMultipleXMLFilesInServerFolder(var SAFTExportHeader: Record "NPR SAF-T Cash Export Header")
    var
        SAFTCashExportFile: Record "NPR SAF-T Cash Export File";
        DataCompression: Codeunit "Data Compression";
        EntryFileInStream: InStream;
        FilesHandled: Integer;
        FilesPerZip: Integer;
    begin
        SAFTCashExportFile.SetRange("Export ID", SAFTExportHeader.ID);
        FilesPerZip := SAFTCashExportFile.Count();
        SAFTCashExportFile.FindSet();
        repeat
            if FilesHandled > FilesPerZip then
                SaveZipFile(DataCompression, FilesHandled, SAFTExportHeader);

            if FilesHandled = 0 then
                DataCompression.CreateZipArchive();

            SAFTCashExportFile.CalcFields("SAF-T File");
            SAFTCashExportFile."SAF-T File".CreateInStream(EntryFileInStream);
            DataCompression.AddEntry(EntryFileInStream, SAFTCashExportFile."File Name");
            FilesHandled += 1;
        until SAFTCashExportFile.Next() = 0;
        if FilesHandled <> 0 then
            SaveZipFile(DataCompression, FilesHandled, SAFTExportHeader);

        SAFTCashExportFile.DeleteAll();
    end;

    local procedure SaveZipOfMultipleXMLFiles(SAFTExportHeader: Record "NPR SAF-T Cash Export Header")
    var
        SAFTCashExportFile: Record "NPR SAF-T Cash Export File";
        DataCompression: Codeunit "Data Compression";
        EntryFileInStream: InStream;
        FilesHandled: Integer;
        FilesPerZip: Integer;
        ZipNo: Integer;
    begin
        SAFTCashExportFile.SetRange("Export ID", SAFTExportHeader.ID);
        FilesPerZip := SAFTCashExportFile.Count();
        DataCompression.CreateZipArchive();
        SAFTCashExportFile.FindSet();
        repeat
            if FilesHandled > FilesPerZip then
                ExportZipFile(DataCompression, FilesHandled, ZipNo, SAFTExportHeader);

            if FilesHandled = 0 then
                DataCompression.CreateZipArchive();

            SAFTCashExportFile."SAF-T File".CreateInStream(EntryFileInStream);
            DataCompression.AddEntry(EntryFileInStream, SAFTCashExportFile."File Name");
            FilesHandled += 1;
        until SAFTCashExportFile.Next() = 0;

        if FilesHandled <> 0 then
            ExportZipFile(DataCompression, FilesHandled, ZipNo, SAFTExportHeader);
    end;

    local procedure SaveZipFile(var DataCompression: Codeunit "Data Compression"; var FilesHandled: Integer; SAFTExportHeader: Record "NPR SAF-T Cash Export Header")
    var
        SAFTExportFile: Record "NPR SAF-T Cash Export Zip";
        ZipOutStream: OutStream;
    begin
        InitExportFile(SAFTExportFile, SAFTExportHeader);

        SAFTExportFile."SAF-T File".CreateOutStream(ZipOutStream);
        DataCompression.SaveZipArchive(ZipOutStream);
        DataCompression.CloseZipArchive();

        SAFTExportFile.Insert(true);
        FilesHandled := 0;
    end;

    local procedure ExportZipFile(var DataCompression: Codeunit "Data Compression"; var FilesHandled: Integer; var ZipNo: Integer; SAFTExportHeader: Record "NPR SAF-T Cash Export Header")
    var
        ZipTempBlob: Codeunit "Temp Blob";
        SAFTCashExportZip: Record "NPR SAF-T Cash Export Zip";
        ZipInStream: InStream;
        ZipOutStream: OutStream;
    begin
        ZipTempBlob.CreateOutStream(ZipOutStream);
        DataCompression.SaveZipArchive(ZipOutStream);
        DataCompression.CloseZipArchive();
        ZipTempBlob.CreateInStream(ZipInStream);
        ZipNo += 1;
        InitExportFile(SAFTCashExportZip, SAFTExportHeader);
        SAFTCashExportZip."SAF-T File".CreateOutStream(ZipOutStream);
        CopyStream(ZipOutStream, ZipInStream);
        SAFTCashExportZip.Insert();
        FilesHandled := 0;
    end;

    internal procedure CheckNoFilesInFolder(SAFTExportHeader: Record "NPR SAF-T Cash Export Header")
    var
        SAFTCashExportFile: Record "NPR SAF-T Cash Export File";
        ErrorMessageManagement: Codeunit "Error Message Management";
    begin
        if not SAFTExportHeader.AllowedToExportIntoFolder() then
            exit;

        SAFTCashExportFile.SetRange("Export ID", SAFTExportHeader.ID);
        if SAFTCashExportFile.Count() <> 0 then
            ErrorMessageManagement.LogError(SAFTExportHeader, FilesExistsInFolderErr, '');
    end;

    internal procedure ClearExportFiles(SAFTExportHeader: Record "NPR SAF-T Cash Export Header")
    var
        SAFTExportFile: Record "NPR SAF-T Cash Export Zip";
    begin
        SAFTExportFile.SetRange("Export ID", SAFTExportHeader.ID);
        SAFTExportFile.DeleteAll(true);
    end;

    local procedure InitExportFile(var SAFTExportFile: Record "NPR SAF-T Cash Export Zip"; SAFTExportHeader: Record "NPR SAF-T Cash Export Header")
    var
        FileNo: Integer;
    begin
        SAFTExportFile.Reset();
        SAFTExportFile.SetRange("Export ID", SAFTExportHeader.ID);
        if SAFTExportFile.FindLast() then
            FileNo := SAFTExportFile."Zip No.";
        FileNo += 1;

        SAFTExportFile.Init();
        SAFTExportFile."Export ID" := SAFTExportHeader.ID;
        SAFTExportFile."Zip No." := FileNo;
    end;

    internal procedure InitExportFile(var SAFTExportFile: Record "NPR SAF-T Cash Export File"; ExportHeaderID: Integer)
    var
        FileNo: Integer;
    begin
        SAFTExportFile.Reset();
        SAFTExportFile.SetRange("Export ID", ExportHeaderID);
        if SAFTExportFile.FindLast() then
            FileNo := SAFTExportFile."File No.";
        FileNo += 1;

        SAFTExportFile.Init();
        SAFTExportFile."Export ID" := ExportHeaderID;
        SAFTExportFile."File No." := FileNo;
    end;

    internal procedure ExportFilesExist(SAFTExportHeader: Record "NPR SAF-T Cash Export Header"): Boolean
    var
        SAFTExportFile: Record "NPR SAF-T Cash Export Zip";
    begin
        SAFTExportFile.SetRange("Export ID", SAFTExportHeader.ID);
        exit(not SAFTExportFile.IsEmpty());
    end;

    // internal procedure GetNotApplicationVATCode(): Code[10]
    // var
    //     NOFiscalizationSetup: Record "NPR NO Fiscalization Setup";
    // begin
    //     NOFiscalizationSetup.Get();
    //     exit(NOFiscalizationSetup."Not Applicable VAT Code");
    // end;

    local procedure IsSessionActive(SAFTExportLine: Record "NPR SAF-T Cash Export Line"): Boolean
    var
        ActiveSession: Record "Active Session";
    begin
        if SAFTExportLine."Server Instance ID" = ServiceInstanceId() then
            exit(ActiveSession.Get(SAFTExportLine."Server Instance ID", SAFTExportLine."Session ID"));

        if SAFTExportLine."Server Instance ID" <= 0 then
            exit(false);

        exit(not IsSessionLoggedOff(SAFTExportLine));
    end;

    local procedure IsSessionLoggedOff(SAFTExportLine: Record "NPR SAF-T Cash Export Line"): Boolean
    var
        SAFTExportHeader: Record "NPR SAF-T Cash Export Header";
        SessionEvent: Record "Session Event";
    begin
        SessionEvent.SetRange("Server Instance ID", SAFTExportLine."Server Instance ID");
        SessionEvent.SetRange("Session ID", SAFTExportLine."Session ID");
        SessionEvent.SetRange("Event Type", SessionEvent."Event Type"::Logoff);
        SAFTExportHeader.Get(SAFTExportLine.ID);
        SessionEvent.SetFilter("Event Datetime", '>%1', SAFTExportHeader."Earliest Start Date/Time");
        SessionEvent.SetRange("User SID", UserSecurityId());
        exit(not SessionEvent.IsEmpty());
    end;

    local procedure GetNoOfJobsInProgress(): Integer
    var
        ScheduledTask: Record "Scheduled Task";
    begin
        ScheduledTask.SetRange("Run Codeunit", Codeunit::"NPR Generate SAF-T Cash File");
        exit(ScheduledTask.Count());
    end;

    local procedure HandleConfirm(ConfirmText: Text): Boolean
    begin
        if not GuiAllowed() then
            exit(true);

        exit(Confirm(ConfirmText, false));
    end;

    local procedure CheckStatus(Status: Enum "NPR SAF-T Cash Export Status"; Question: Text): Boolean
    var
        SAFTExportHeader: Record "NPR SAF-T Cash Export Header";
        StatusMessage: Text;
    begin
        if Status = SAFTExportHeader.Status::"In Progress" then
            StatusMessage := ExportIsInProgressMsg;
        if Status = SAFTExportHeader.Status::Completed then
            StatusMessage := ExportIsCompletedQst;

        if StatusMessage <> '' then
            exit(HandleConfirm(StatusMessage + Question));

        exit(true);
    end;

    local procedure CheckLineStatusForRestart(var SAFTExportLine: Record "NPR SAF-T Cash Export Line"): Boolean;
    begin
        SAFTExportLine.SetFilter(Status, '%1|%2', SAFTExportLine.Status::Failed, SAFTExportLine.Status::Completed);
        if not SAFTExportLine.IsEmpty() then
            exit(HandleConfirm(LinesInProgressOrCompletedMsg + RestartExportLineQst));

        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeScheduleTask(var DoNotScheduleTask: Boolean; var TaskID: Guid)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCancelTask(var DoNotCancelTask: Boolean)
    begin
    end;
}
