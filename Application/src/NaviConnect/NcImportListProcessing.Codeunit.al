codeunit 6151509 "NPR Nc Import List Processing"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        NcImportType: Record "NPR Nc Import Type";
    begin
        FindImportType(Rec, NcImportType);
        UpdateImportList(Rec, NcImportType.Code);

        if HasParameter(Rec, ParamProcessImport()) then
            ProcessImportEntries(NcImportType);
    end;

    var
        DownloadFtpTxt: Label 'Download Ftp';
        ProcessImportListTxt: Label 'Process Import List';
        AllTxt: Label 'All';

    local procedure UpdateImportList(JobQueueEntry: Record "Job Queue Entry"; ImportTypeCode: Code[20])
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
                    ImportListUpdater.Update(JobQueueEntry, ImportType);
            until ImportType.Next() = 0;
    end;

    procedure ProcessImportEntries(NcImportType: Record "NPR Nc Import Type")
    var
        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        NcImportEntry: Record "NPR Nc Import Entry";
    begin
        NcImportEntry.SetFilter("Import Type", NcImportType.Code);
        NcImportEntry.SetRange(Imported, false);
        NcImportEntry.SetRange("Runtime Error", false);
        NcImportEntry.SetFilter("Earliest Import Datetime", '<=%1', CurrentDateTime);
        if NcImportEntry.FindSet() then
            repeat
                NcSyncMgt.ProcessImportEntry(NcImportEntry);
            until NcImportEntry.Next() = 0;
    end;

    local procedure FindImportType(JobQueueEntry: Record "Job Queue Entry"; var NcImportType: Record "NPR Nc Import Type")
    var
        ImportTypeCode: Text;
    begin
        Clear(NcImportType);

        ImportTypeCode := GetParameterValue(JobQueueEntry, ParamImportType());
        if StrLen(ImportTypeCode) > MaxStrLen(NcImportType.Code) then
            exit;

        if NcImportType.Get(UpperCase(ImportTypeCode)) then;
    end;

    procedure GetParameterValue(JobQueueEntry: Record "Job Queue Entry"; ParameterName: Text) ParameterValue: Text
    var
        Position: Integer;
    begin
        if ParameterName = '' then
            exit('');

        ParameterValue := JobQueueEntry."Parameter String";
        Position := StrPos(LowerCase(ParameterValue), LowerCase(ParameterName));
        if Position = 0 then
            exit('');

        if Position > 1 then
            ParameterValue := DelStr(ParameterValue, 1, Position - 1);

        ParameterValue := DelStr(ParameterValue, 1, StrLen(ParameterName));
        if ParameterValue = '' then
            exit('');
        if ParameterValue[1] = '=' then
            ParameterValue := DelStr(ParameterValue, 1, 1);

        Position := FindDelimiterPosition(ParameterValue);
        if Position > 0 then
            ParameterValue := DelStr(ParameterValue, Position);

        exit(ParameterValue);
    end;

    procedure HasParameter(JobQueueEntry: Record "Job Queue Entry"; ParameterName: Text): Boolean
    var
        Position: Integer;
    begin
        Position := StrPos(LowerCase(JobQueueEntry."Parameter String"), LowerCase(ParameterName));
        exit(Position > 0);
    end;

    local procedure FindDelimiterPosition(ParameterString: Text) Position: Integer
    var
        NewPosition: Integer;
    begin
        if ParameterString = '' then
            exit(0);

        Position := StrPos(ParameterString, ',');

        NewPosition := StrPos(ParameterString, ';');
        if (NewPosition > 0) and ((Position = 0) or (NewPosition < Position)) then
            Position := NewPosition;

        NewPosition := StrPos(ParameterString, '|');
        if (NewPosition > 0) and ((Position = 0) or (NewPosition < Position)) then
            Position := NewPosition;

        exit(Position);
    end;

    [EventSubscriber(ObjectType::Table, 472, 'OnAfterValidateEvent', 'Object ID to Run', true, true)]
    local procedure OnValidateJobQueueEntryObjectIDtoRun(var Rec: Record "Job Queue Entry"; var xRec: Record "Job Queue Entry"; CurrFieldNo: Integer)
    var
        ParameterString: Text;
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
            exit;
        if Rec."Object ID to Run" <> CurrCodeunitId() then
            exit;

        ParameterString := ParamImportType() + '=';
        ParameterString += ',' + ParamDownloadFtp();
        ParameterString += ',' + ParamProcessImport();

        Rec.Validate("Parameter String", CopyStr(ParameterString, 1, MaxStrLen(Rec."Parameter String")));
    end;

    [EventSubscriber(ObjectType::Table, 472, 'OnAfterValidateEvent', 'Parameter String', true, true)]
    local procedure OnValidateJobQueueEntryParameterString(var Rec: Record "Job Queue Entry"; var xRec: Record "Job Queue Entry"; CurrFieldNo: Integer)
    var
        NcImportType: Record "NPR Nc Import Type";
        Description: Text;
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
            exit;
        if Rec."Object ID to Run" <> CurrCodeunitId() then
            exit;

        FindImportType(Rec, NcImportType);
        if NcImportType.Code = '' then
            Description := '{' + AllTxt + '}'
        else
            Description := NcImportType.Code;

        if HasParameter(Rec, ParamDownloadFtp()) then
            Description += ' | ' + DownloadFtpTxt;

        if HasParameter(Rec, ParamProcessImport()) then
            Description += ' | ' + ProcessImportListTxt;

        Rec.Description := CopyStr(Description, 1, MaxStrLen(Rec.Description));
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Nc Import List Processing");
    end;

    local procedure ParamImportType(): Text
    begin
        exit('import_type');
    end;

    procedure ParamDownloadFtp(): Text
    begin
        exit('download_ftp');
    end;

    local procedure ParamProcessImport(): Text
    begin
        exit('process_import_list');
    end;
}