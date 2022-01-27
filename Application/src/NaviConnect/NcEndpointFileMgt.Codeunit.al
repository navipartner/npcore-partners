codeunit 6151526 "NPR Nc Endpoint File Mgt."
{
    Access = Internal;
    var
        TextFileDownloadedLbl: Label 'The file was downloaded.';
        TextFileExportedLbl: Label 'The file was exported.';

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
        InStm: InStream;
        OutStm: OutStream;
        TempBlob: Codeunit "Temp Blob";
    begin
        NcEndpointFile.TestField(Path);

        NcTriggerSyncMgt.AddResponse(NcTask, TextFileExportedLbl);

        TempBlob.CreateOutStream(OutStm);
        OutStm.WriteText(OutputText);

        case NcEndpointFile."File Encoding" of
            NcEndpointFile."File Encoding"::ANSI:
                TempBlob.CreateInStream(InStm, TextEncoding::Windows);
            NcEndpointFile."File Encoding"::UTF8:
                TempBlob.CreateInStream(InStm, TextEncoding::UTF8);
            else
                TempBlob.CreateInStream(InStm);
        end;

        if NcEndpointFile."Client Path" then begin
            DownloadFromStream(InStm, 'Save file as...', NcEndpointFile.Path, 'All Files|*.*', Filename);
            NcTriggerSyncMgt.AddResponse(NcTask, NewLine() + TextFileDownloadedLbl);
        end;
    end;

    local procedure FileProcessOutput(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpointFile: Record "NPR Nc Endpoint File")
    var
        InStr: InStream;
    begin
        NcEndpointFile.TestField(Path);

        case NcEndpointFile."File Encoding" of
            NcEndpointFile."File Encoding"::ANSI:
                NcTaskOutput.Data.CreateInStream(InStr, TextEncoding::Windows);
            NcEndpointFile."File Encoding"::UTF8:
                NcTaskOutput.Data.CreateInStream(InStr, TextEncoding::UTF8);
            else
                NcTaskOutput.Data.CreateInStream(InStr);
        end;

        if NcEndpointFile."Client Path" then
            DownloadFromStream(InStr, 'Save file as...', NcEndpointFile.Path, 'All Files|*.*', NcTaskOutput.Name);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Trigger Task Mgt.", 'OnAfterGetOutputTriggerTask', '', false, false)]
    local procedure OnAfterGetOutputTriggerTaskFileOutput(NcTriggerCode: Code[20]; Output: Text; var NcTask: Record "NPR Nc Task"; Filename: Text; Subject: Text; Body: Text)
    begin
        ProcessNcEndpoints(NcTriggerCode, Output, NcTask, Filename);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Nc Endpoint Type", 'OnSetupEndpointTypes', '', false, false)]
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

    [EventSubscriber(ObjectType::Table, Database::"NPR Nc Endpoint", 'OnOpenEndpointSetup', '', false, false)]
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

    [EventSubscriber(ObjectType::Table, Database::"NPR Nc Endpoint", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnDeleteEndpoint(var Rec: Record "NPR Nc Endpoint"; RunTrigger: Boolean)
    var
        NcEndpointFile: Record "NPR Nc Endpoint File";
    begin
        if NcEndpointFile.Get(Rec.Code) then
            NcEndpointFile.Delete(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Endpoint Mgt.", 'OnRunEndpoint', '', true, true)]
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

