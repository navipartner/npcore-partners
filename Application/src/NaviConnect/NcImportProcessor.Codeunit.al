codeunit 6151511 "NPR Nc Import Processor"
{
    TableNo = "NPR Nc Import Entry";

    var
        BatchEntriesMustBeImportedInOrderErr: Label 'Cannot Import the entry because Batch Entries should be imported in the order of creation. There are one or more entries with Entry No. lower than the Entry No. ''%1''. Please import first the oldest entry from Batch Id ''%2''.';

    trigger OnRun()
    begin
        if Rec.HasActiveImport() then
            exit;

        if Rec."Earliest Import Datetime" > CurrentDateTime then
            Sleep(Rec."Earliest Import Datetime" - CurrentDateTime);

        ProcessImportEntry(Rec);
    end;

    procedure ProcessImportEntry(var NcImportEntry: Record "NPR Nc Import Entry") Success: Boolean
    var
        DataLogMgt: Codeunit "NPR Data Log Management";
        LastErrorMessage: Text;
    begin
        CheckBatchImportEntriesOrder(NcImportEntry);

        MarkAsStarted(NcImportEntry);
        Success := CODEUNIT.Run(CODEUNIT::"NPR Nc Import Mgt.", NcImportEntry);
        DataLogMgt.DisableDataLog(false);
        LastErrorMessage := GetLastErrorText();
        MarkAsCompleted(Success, NcImportEntry);

        EmitTelemetryData(NcImportEntry, LastErrorMessage);

        if Success then
            exit;

        ScheduleRetry(NcImportEntry);
    end;

    local procedure EmitTelemetryData(NcImportEntry: Record "NPR Nc Import Entry"; LastErrorMessage: Text)
    var
        CustomDimensions: Dictionary of [Text, Text];
        ActiveSession: Record "Active Session";
        VerbosityLevel: Verbosity;
    begin

        if (not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId())) then
            Clear(ActiveSession);

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");

        CustomDimensions.Add('NPR_Nc_SystemId', NcImportEntry.SystemId);
        CustomDimensions.Add('NPR_Nc_ImportType', NcImportEntry."Import Type");
        CustomDimensions.Add('NPR_Nc_DocumentId', NcImportEntry."Document ID");
        CustomDimensions.Add('NPR_Nc_DocumentName', NcImportEntry."Document Name");
        CustomDimensions.Add('NPR_Nc_SequenceNo', Format(NcImportEntry."Sequence No.", 0, 9));
        CustomDimensions.Add('NPR_Nc_ErrorMessage', LastErrorMessage);
        CustomDimensions.Add('NPR_Nc_ImportStartedAt', Format(NcImportEntry."Import Started at", 0, 9));
        CustomDimensions.Add('NPR_Nc_ImportCompletedAt', Format(NcImportEntry."Import Completed at", 0, 9));
        CustomDimensions.Add('NPR_Nc_ImportDuration', Format(NcImportEntry."Import Duration", 0, 9));
        CustomDimensions.Add('NPR_Nc_ImportCount', Format(NcImportEntry."Import Count", 0, 9));
        CustomDimensions.Add('NPR_Nc_ImportStartedBy', Format(NcImportEntry."Import Started by", 0, 9));
        CustomDimensions.Add('NPR_Nc_Imported', Format(NcImportEntry.Imported, 0, 9));
        CustomDimensions.Add('NPR_Nc_RuntimeError', Format(NcImportEntry."Runtime Error", 0, 9));
        if (NcImportEntry."Runtime Error") then
            CustomDimensions.Add('NPR_Nc_CallStack', GetLastErrorCallStack());

        VerbosityLevel := VerbosityLevel::Normal;

        if (LastErrorMessage <> '') then
            VerbosityLevel := VerbosityLevel::Warning;

        if (NcImportEntry."Runtime Error") then
            VerbosityLevel := VerbosityLevel::Error;

        Session.LogMessage('NPR_ImportList', 'NC Import List', VerbosityLevel, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    local procedure MarkAsStarted(var NcImportEntry: Record "NPR Nc Import Entry")
    begin
        ClearLastError();
        NcImportEntry.LockTable();
        NcImportEntry.Get(NcImportEntry."Entry No.");
        Clear(NcImportEntry."Last Error Message");
        NcImportEntry.Imported := false;
        NcImportEntry."Runtime Error" := true;
        NcImportEntry."Error Message" := '';
        NcImportEntry."Import Started at" := CurrentDateTime;
        NcImportEntry."Import Duration" := 0;
        NcImportEntry."Import Completed at" := 0DT;
        NcImportEntry."Import Count" += 1;
        NcImportEntry."Import Started by" := UserId;
        NcImportEntry."Server Instance Id" := ServiceInstanceId();
        NcImportEntry."Session Id" := SessionId();
        NcImportEntry.Modify(true);
        Commit();
    end;

    local procedure MarkAsCompleted(Success: Boolean; var NcImportEntry: Record "NPR Nc Import Entry")
    var
        NcImportType: Record "NPR Nc Import Type";
        TempErrorMessage: Record "Error Message" temporary;
        TempEmailItem: Record "Email Item" temporary;
        NcImportMgt: Codeunit "NPR Nc Import Mgt.";
        OutStr: OutStream;
        LastErrorText: Text;
    begin
        NcImportEntry.LockTable();
        NcImportEntry.Get(NcImportEntry."Entry No.");
        NcImportEntry."Import Completed at" := CurrentDateTime;
        if NcImportEntry."Import Started at" <> 0DT then
            NcImportEntry."Import Duration" := (NcImportEntry."Import Completed at" - NcImportEntry."Import Started at") / 1000;
        NcImportEntry."Server Instance Id" := 0;
        NcImportEntry."Session Id" := 0;
        NcImportEntry.Imported := Success;
        NcImportEntry."Runtime Error" := not Success;
        LastErrorText := GetLastErrorText;
        if LastErrorText <> '' then begin
            NcImportEntry."Error Message" := CopyStr(LastErrorText, 1, MaxStrLen(NcImportEntry."Error Message"));
            NcImportEntry."Last Error Message".CreateOutStream(OutStr, TEXTENCODING::UTF8);
            OutStr.WriteText(LastErrorText);
        end;
        NcImportEntry.Modify(true);
        MarkUnimportedEntriesWithSameBatchIdAsError(NcImportEntry);
        Commit();

        if Success then
            exit;

        ClearLastError();
        if not NcImportType.Get(NcImportEntry."Import Type") then
            exit;
        if NcImportType."Send e-mail on Error" then begin
            NcImportMgt.SendErrorMail(NcImportEntry, TempErrorMessage, TempEmailItem);
            if TempErrorMessage.IsEmpty() then begin
                NcImportEntry.LockTable();
                NcImportEntry.Get(NcImportEntry."Entry No.");
                NcImportEntry."Last Error E-mail Sent at" := CurrentDateTime;
                NcImportEntry."Last Error E-mail Sent to" := NcImportType."E-mail address on Error";
                NcImportEntry.Modify(true);
                Commit();
            end;
        end;
    end;

    procedure ScheduleRetry(var NcImportEntry: Record "NPR Nc Import Entry")
    var
        NcImportType: Record "NPR Nc Import Type";
    begin
        if not NcImportType.Get(NcImportEntry."Import Type") then
            exit;
        if NcImportType."Max. Retry Count" <= 0 then
            exit;
        if NcImportType."Max. Retry Count" < NcImportEntry."Import Count" then
            exit;

        if NcImportType."Delay between Retries" > 0 then begin
            NcImportEntry.LockTable();
            NcImportEntry.Get(NcImportEntry."Entry No.");
            NcImportEntry."Earliest Import Datetime" := CurrentDateTime + NcImportType."Delay between Retries";
            NcImportEntry.Modify(true);
            Commit();
        end;

        ScheduleImport(NcImportEntry);
    end;

    procedure ScheduleImport(var NcImportEntry: Record "NPR Nc Import Entry")
    var
        SessionId: Integer;
    begin
        SESSION.StartSession(SessionId, CurrCodeunitId(), CompanyName, NcImportEntry);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Nc Import Processor");
    end;

    local procedure MarkUnimportedEntriesWithSameBatchIdAsError(NcImportEntry: Record "NPR Nc Import Entry")
    var
        NcImportEntry2: Record "NPR Nc Import Entry";
        ErrorTxt: Text;
        OutStr: OutStream;
        ErrorTxtLabel: Label 'Import stopped because an error occured in Entry No. ''%1'' which is related to same Batch Id.', Locked = true;
    begin
        IF NcImportEntry."Runtime Error" AND (NOT IsNullGuid(NcImportEntry."Batch Id")) then begin
            NcImportEntry2.SetRange("Import Type", NcImportEntry."Import Type");
            NcImportEntry2.SetRange("Batch Id", NcImportEntry."Batch Id");
            NcImportEntry2.SetRange(Imported, false);
            NcImportEntry2.SetFilter("Entry No.", '>%1', NcImportEntry."Entry No.");
            IF NcImportEntry2.FindSet(true, false) then
                repeat
                    NcImportEntry2."Runtime Error" := true;
                    ErrorTxt := StrSubstNo(ErrorTxtLabel, NcImportEntry."Entry No.");
                    NcImportEntry2."Error Message" := CopyStr(ErrorTxt, 1, MaxStrLen(NcImportEntry2."Error Message"));
                    NcImportEntry2."Last Error Message".CreateOutStream(OutStr, TEXTENCODING::UTF8);
                    OutStr.WriteText(ErrorTxt);
                    NcImportEntry2.Modify(true);
                until NcImportEntry2.Next() = 0;
        end;
        OAfterMarkUnimportedEntriesWithSameBatchIdAsError(NcImportEntry);
    end;

    local procedure CheckBatchImportEntriesOrder(pImportEntry: Record "NPR Nc Import Entry")
    var
        ImportEntry: Record "NPR Nc Import Entry";
    begin
        If NOT ISNULLGUID(pImportEntry."Batch Id") then begin
            ImportEntry.SetRange("Import Type", pImportEntry."Import Type");
            ImportEntry.SetRange("Batch Id", pImportEntry."Batch Id");
            ImportEntry.SetRange(Imported, false);
            ImportEntry.SetFilter("Entry No.", '<%1', pImportEntry."Entry No.");
            IF NOT ImportEntry.IsEmpty then
                Error(BatchEntriesMustBeImportedInOrderErr, pImportEntry."Entry No.", pImportEntry."Batch Id");
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OAfterMarkUnimportedEntriesWithSameBatchIdAsError(NcImportEntry: Record "NPR Nc Import Entry")
    begin
    end;
}

