codeunit 6151526 "NPR Nc Endpoint File Mgt."
{
    var
        TextFileDownloaded: Label 'The file was downloaded to %1.';
        TextFileExistsSkipped: Label 'The file was not exported because the file %1 already exists.';
        TextFileExistsOverwitten: Label 'The file was exported, overwriting the file %1 that already existed.';
        TextFileExistsAppendedSuffix: Label 'The file was exported to %1 with an appended Timestamp in the filename because the file already existed.';
        TextFileExported: Label 'The file was exported to %1.';

    local procedure ProcessNcEndpoints(NcTriggerCode: Code[20]; Output: Text; var NcTask: Record "NPR Nc Task"; Filename: Text)
    var
        NcEndpoint: Record "NPR Nc Endpoint";
        NcEndpointFile: Record "NPR Nc Endpoint File";
        NcEndpointTriggerLink: Record "NPR Nc Endpoint Trigger Link";
    begin
        case NcTask."Table No." of
            DATABASE::"NPR Nc Trigger":
                begin
                    NcEndpointTriggerLink.Reset();
                    NcEndpointTriggerLink.SetRange("Trigger Code", NcTriggerCode);
                    if NcEndpointTriggerLink.FindSet() then
                        repeat
                            if NcEndpoint.Get(NcEndpointTriggerLink."Endpoint Code") then begin
                                if NcEndpoint."Endpoint Type" = NcEndpointFile.GetEndpointTypeCode() then begin
                                    if NcEndpointFile.Get(NcEndpointTriggerLink."Endpoint Code") then begin
                                        ProcessNcEndpointTrigger(NcTriggerCode, Output, Filename, NcTask, NcEndpointFile);
                                    end;
                                end;
                            end;
                        until NcEndpointTriggerLink.Next() = 0;
                end;
            DATABASE::"NPR Nc Endpoint File":
                begin
                    //Process Endpoint Task
                    NcEndpointFile.SetPosition(NcTask."Record Position");
                    NcEndpointFile.SetRange(Code, NcEndpointFile.Code);
                    NcEndpointFile.SetRange(Enabled, true);
                    if NcEndpointFile.FindFirst() then begin
                        ProcessEndPointTask(NcEndpointFile, NcTask, Output, Filename);
                        NcTask.Modify();
                    end;
                end;
        end;
    end;

    procedure ProcessNcEndpointTrigger(NcTriggerCode: Code[20]; Output: Text; Filename: Text; var NcTask: Record "NPR Nc Task"; NcEndpointFile: Record "NPR Nc Endpoint File")
    var
        NcTrigger: Record "NPR Nc Trigger";
    begin
        if not NcEndpointFile.Enabled then
            exit;
        NcTrigger.Get(NcTriggerCode);
        if not NcTrigger."Split Trigger and Endpoint" then begin
            //Process Trigger Task Directly
            FileProcess(NcTask, NcEndpointFile, Output, Filename);
            NcTask.Modify();
        end else begin
            //Insert New Task per Endpoint
            InsertEndpointTask(NcEndpointFile, NcTask, Filename);
            NcTask.Modify();
        end;
    end;

    local procedure InsertEndpointTask(var NcEndpointFile: Record "NPR Nc Endpoint File"; var NcTask: Record "NPR Nc Task"; Filename: Text)
    var
        NcTriggerSyncMgt: Codeunit "NPR Nc Trigger Sync. Mgt.";
        NewTask: Record "NPR Nc Task";
        TempNcEndPointFile: Record "NPR Nc Endpoint File" temporary;
        RecRef: RecordRef;
        TextTaskInserted: Label 'File Export Task inserted for Nc Endpoint File %1 %2, to file: %3 with path %4. Nc Task Entry No. %5';
        TaskEntryNo: BigInteger;
    begin
        RecRef.Get(NcEndpointFile.RecordId);
        NcTriggerSyncMgt.InsertTask(RecRef, TaskEntryNo);
        NewTask.Get(TaskEntryNo);
        TempNcEndPointFile.Init();
        TempNcEndPointFile.Copy(NcEndpointFile);
        TempNcEndPointFile."Output Nc Task Entry No." := NcTask."Entry No.";
        if Filename <> '' then
            TempNcEndPointFile.Filename := Filename;
        NcTriggerSyncMgt.FillFields(NewTask, TempNcEndPointFile);
        NcTriggerSyncMgt.AddResponse(NcTask, StrSubstNo(TextTaskInserted, NcEndpointFile.Code, NcEndpointFile.Description, NcEndpointFile.Filename, NcEndpointFile.Path, NewTask."Entry No."));
    end;

    procedure ProcessEndPointTask(var NcEndpointFile: Record "NPR Nc Endpoint File"; var NcTask: Record "NPR Nc Task"; Output: Text; Filename: Text)
    var
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
        RecRef: RecordRef;
        FldRef: FieldRef;
        TextNoOutput: Label 'FTP Task not executed because there was no output to send.';
    begin
        NcTaskMgt.RestoreRecord(NcTask."Entry No.", RecRef);
        if Output = '' then
            Error(TextNoOutput);
        FldRef := RecRef.Field(NcEndpointFile.FieldNo(Filename));
        if Format(FldRef.Value) <> '' then
            Filename := Format(FldRef.Value);
        FileProcess(NcTask, NcEndpointFile, Output, Filename);
    end;

    local procedure FileProcess(var NcTask: Record "NPR Nc Task"; NcEndpointFile: Record "NPR Nc Endpoint File"; OutputText: Text; Filename: Text)
    var
        NcTriggerSyncMgt: Codeunit "NPR Nc Trigger Sync. Mgt.";
        FileMgt: Codeunit "File Management";
        Encoding: TextEncoding;
        UseDefaultEncoding: Boolean;
        OutStr: OutStream;
        Tempfile: File;
        ExportFile: File;
        DirectoryPathfromFile: Text;
        FullName: Text;
        ToFile: Text;
    begin
        NcEndpointFile.TestField(Path);
        if NcEndpointFile."Client Path" then begin
            Tempfile.CreateTempFile();
            FullName := Tempfile.Name;
            Tempfile.Close();
        end else begin
            FullName := StrSubstNo('%1\%2', DelChr(NcEndpointFile.Path, '>', '\'), Filename);
            if StrLen(Filename) = (StrLen(DelChr(Filename, '=', '\')) + 1) then begin
                DirectoryPathfromFile := NcEndpointFile.Path + '\' + CopyStr(Filename, 1, StrPos(Filename, '\') - 1);
                if not FileMgt.ServerDirectoryExists(NcEndpointFile.Path + '\' + DirectoryPathfromFile) then
                    FileMgt.ServerCreateDirectory(DirectoryPathfromFile);
            end;
        end;

        if Exists(FullName) then begin
            case NcEndpointFile."Handle Exiting File" of
                NcEndpointFile."Handle Exiting File"::KeepExisting:
                    begin
                        NcTriggerSyncMgt.AddResponse(NcTask, ConvertStr(StrSubstNo(TextFileExistsSkipped, FullName), '\', '/'));
                        exit;
                    end;
                NcEndpointFile."Handle Exiting File"::AddSuffix:
                    begin
                        FullName := AddSuffixToFileName(FullName);
                        NcTriggerSyncMgt.AddResponse(NcTask, ConvertStr(StrSubstNo(TextFileExistsAppendedSuffix, FullName), '\', '/'));
                    end;
                NcEndpointFile."Handle Exiting File"::Replace:
                    begin
                        Erase(FullName);
                        NcTriggerSyncMgt.AddResponse(NcTask, ConvertStr(StrSubstNo(TextFileExistsOverwitten, FullName), '\', '/'));
                    end;
            end;
        end else begin
            NcTriggerSyncMgt.AddResponse(NcTask, ConvertStr(StrSubstNo(TextFileExported, FullName), '\', '/'));
        end;

        UseDefaultEncoding := false;
        case NcEndpointFile."File Encoding" of
            NcEndpointFile."File Encoding"::ANSI:
                Encoding := TextEncoding::Windows;
            NcEndpointFile."File Encoding"::UTF8:
                Encoding := TextEncoding::UTF8;
            else
                UseDefaultEncoding := true;
        end;
        if UseDefaultEncoding then
            ExportFile.Create(FullName)
        else
            ExportFile.Create(FullName, Encoding);

        ExportFile.Write(OutputText);

        if NcEndpointFile."Client Path" then begin
            ToFile := NcEndpointFile.Path + Filename;
            FileMgt.CopyServerFile(FullName, FullName + '.file', true);
            ExportFile.Open(FullName);
            FileMgt.DownloadToFile(ExportFile.Name + '.file', ToFile);
            ExportFile.Close();
            Erase(FullName);
            NcTriggerSyncMgt.AddResponse(NcTask, NewLine() + StrSubstNo(TextFileDownloaded, ConvertStr(ToFile, '\', '/')));
        end;
    end;

    local procedure FileProcessOutput(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpointFile: Record "NPR Nc Endpoint File")
    var
        FileMgt: Codeunit "File Management";
        Encoding: TextEncoding;
        UseDefaultEncoding: Boolean;
        Tempfile: File;
        ExportFile: File;
        InStr: InStream;
        OutStr: OutStream;
        DirectoryPathfromFile: Text;
        FullName: Text;
        ToFile: Text;
    begin
        NcEndpointFile.TestField(Path);

        if NcEndpointFile."Client Path" then begin
            Tempfile.CreateTempFile();
            FullName := Tempfile.Name;
            Tempfile.Close();
        end else begin
            FullName := StrSubstNo('%1\%2', DelChr(NcEndpointFile.Path, '>', '\'), NcTaskOutput.Name);
            if StrLen(NcTaskOutput.Name) = (StrLen(DelChr(NcTaskOutput.Name, '=', '\')) + 1) then begin
                DirectoryPathfromFile := NcEndpointFile.Path + '\' + CopyStr(NcTaskOutput.Name, 1, StrPos(NcTaskOutput.Name, '\') - 1);
                if not FileMgt.ServerDirectoryExists(NcEndpointFile.Path + '\' + DirectoryPathfromFile) then
                    FileMgt.ServerCreateDirectory(DirectoryPathfromFile);
            end;
        end;

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

        NcTaskOutput.Data.CreateInStream(InStr);
        UseDefaultEncoding := false;
        case NcEndpointFile."File Encoding" of
            NcEndpointFile."File Encoding"::ANSI:
                Encoding := TextEncoding::Windows;
            NcEndpointFile."File Encoding"::UTF8:
                Encoding := TextEncoding::UTF8;
            else
                UseDefaultEncoding := true;
        end;

        if UseDefaultEncoding then
            ExportFile.Create(FullName)
        else
            ExportFile.Create(FullName, Encoding);

        ExportFile.CreateOutStream(OutStr);
        CopyStream(OutStr, InStr);

        if NcEndpointFile."Client Path" then begin
            ToFile := NcEndpointFile.Path + NcTaskOutput.Name;
            FileMgt.CopyServerFile(FullName, FullName + '.file', true);
            ExportFile.Open(FullName);
            FileMgt.DownloadToFile(ExportFile.Name + '.file', ToFile);
            ExportFile.Close();
            Erase(FullName);
        end;
    end;

    local procedure AddSuffixToFileName(FilePath: Text): Text
    var
        Suffix: Text;
        FileMgt: Codeunit "File Management";
    begin
        Suffix := Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2>-<Hours24,2><Minutes,2><Seconds,2>');
        exit(FileMgt.GetDirectoryName(FilePath) +
              '\' + FileMgt.GetFileNameWithoutExtension(FilePath) +
             Suffix + '.' + FileMgt.GetExtension(FilePath));
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151522, 'OnAfterGetOutputTriggerTask', '', false, false)]
    local procedure OnAfterGetOutputTriggerTaskFileOutput(NcTriggerCode: Code[20]; Output: Text; var NcTask: Record "NPR Nc Task"; Filename: Text; Subject: Text; Body: Text)
    begin
        ProcessNcEndpoints(NcTriggerCode, Output, NcTask, Filename);
    end;

    [EventSubscriber(ObjectType::Table, 6151531, 'OnSetupEndpointTypes', '', false, false)]
    local procedure OnSetupEndpointTypeInsertEndpointTypeCode()
    var
        NcEndpointFile: Record "NPR Nc Endpoint File";
        NcEndpointType: Record "NPR Nc Endpoint Type";
    begin
        if not NcEndpointType.Get(NcEndpointFile.GetEndpointTypeCode()) then begin
            NcEndpointType.Init();
            NcEndpointType.Code := NcEndpointFile.GetEndpointTypeCode();
            NcEndpointType.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6151533, 'OnOpenEndpointSetup', '', false, false)]
    local procedure OnOpenEndpointSetupOpenPage(var Sender: Record "NPR Nc Endpoint"; var Handled: Boolean)
    var
        NcEndpointFile: Record "NPR Nc Endpoint File";
    begin
        if Handled then
            exit;
        if Sender."Endpoint Type" <> NcEndpointFile.GetEndpointTypeCode() then
            exit;
        if not NcEndpointFile.Get(Sender.Code) then begin
            NcEndpointFile.Init();
            NcEndpointFile.Validate(Code, Sender.Code);
            NcEndpointFile.Description := Sender.Description;
            NcEndpointFile.Insert();
        end else begin
            if NcEndpointFile.Description <> Sender.Description then begin
                NcEndpointFile.Description := Sender.Description;
                NcEndpointFile.Modify(true);
            end;
        end;
        PAGE.Run(PAGE::"NPR Nc Endpoint File Card", NcEndpointFile);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, 6151533, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnDeleteEndpoint(var Rec: Record "NPR Nc Endpoint"; RunTrigger: Boolean)
    var
        NcEndpointFile: Record "NPR Nc Endpoint File";
    begin
        if NcEndpointFile.Get(Rec.Code) then
            NcEndpointFile.Delete(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151519, 'OnRunEndpoint', '', true, true)]
    local procedure OnRunEndpoint(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpoint: Record "NPR Nc Endpoint")
    var
        NcEndpointFile: Record "NPR Nc Endpoint File";
    begin
        if NcEndpoint."Endpoint Type" <> NcEndpointFile.GetEndpointTypeCode() then
            exit;
        if not NcEndpointFile.Get(NcEndpoint.Code) then
            exit;

        FileProcessOutput(NcTaskOutput, NcEndpointFile);
    end;

    local procedure NewLine() CRLF: Text
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        exit(CRLF);
    end;
}

