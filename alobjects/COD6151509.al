codeunit 6151509 "Nc Import List Processing"
{
    // NC2.23/MHA /20191018  CASE 358499 Object created - Process Nc Import List via Job Queue

    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        NcImportType: Record "Nc Import Type";
        NcSyncMgt: Codeunit "Nc Sync. Mgt.";
    begin
        FindImportType(Rec,NcImportType);
        if HasParameter(Rec,ParamDownloadFtp()) then begin
          if NcImportType.Code <> '' then
            NcSyncMgt.DownloadFtpType(NcImportType)
          else
            NcSyncMgt.DownloadFtp();
          Commit;
        end;

        if HasParameter(Rec,ParamDownloadServerFile()) then begin
          if NcImportType.Code <> '' then
            NcSyncMgt.DownloadServerFile(NcImportType)
          else
            NcSyncMgt.DownloadServerFiles();
          Commit;
        end;

        if HasParameter(Rec,ParamProcessImport()) then
          ProcessImportEntries(NcImportType);
    end;

    var
        Text000: Label 'Download Ftp';
        Text001: Label 'Download Server File';
        Text002: Label 'Process Import List';
        Text003: Label 'All';

    procedure ProcessImportEntries(NcImportType: Record "Nc Import Type")
    var
        NcSyncMgt: Codeunit "Nc Sync. Mgt.";
        NcImportEntry: Record "Nc Import Entry";
    begin
        NcImportEntry.SetFilter("Import Type",NcImportType.Code);
        NcImportEntry.SetRange(Imported,false);
        NcImportEntry.SetRange("Runtime Error",false);
        if NcImportEntry.FindSet then
          repeat
            NcSyncMgt.ProcessImportEntry(NcImportEntry);
          until NcImportEntry.Next = 0;
    end;

    local procedure FindImportType(JobQueueEntry: Record "Job Queue Entry";var NcImportType: Record "Nc Import Type")
    var
        ImportTypeCode: Text;
    begin
        Clear(NcImportType);

        ImportTypeCode := GetParameterValue(JobQueueEntry,ParamImportType());
        if StrLen(ImportTypeCode) > MaxStrLen(NcImportType.Code) then
          exit;

        if NcImportType.Get(UpperCase(ImportTypeCode)) then;
    end;

    local procedure GetParameterValue(JobQueueEntry: Record "Job Queue Entry";ParameterName: Text) ParameterValue: Text
    var
        Position: Integer;
    begin
        if ParameterName = '' then
          exit('');

        ParameterValue := JobQueueEntry."Parameter String";
        Position := StrPos(LowerCase(ParameterValue),LowerCase(ParameterName));
        if Position = 0 then
          exit('');

        if Position > 1 then
          ParameterValue := DelStr(ParameterValue,1,Position - 1);

        ParameterValue := DelStr(ParameterValue,1,StrLen(ParameterName));
        if ParameterValue = '' then
          exit('');
        if ParameterValue[1] = '=' then
          ParameterValue := DelStr(ParameterValue,1,1);

        Position := FindDelimiterPosition(ParameterValue);
        if Position > 0 then
          ParameterValue := DelStr(ParameterValue,Position);

        exit(ParameterValue);
    end;

    local procedure HasParameter(JobQueueEntry: Record "Job Queue Entry";ParameterName: Text): Boolean
    var
        Position: Integer;
    begin
        Position := StrPos(LowerCase(JobQueueEntry."Parameter String"),LowerCase(ParameterName));
        exit(Position > 0);
    end;

    local procedure FindDelimiterPosition(ParameterString: Text) Position: Integer
    var
        NewPosition: Integer;
    begin
        if ParameterString = '' then
          exit(0);

        Position := StrPos(ParameterString,',');

        NewPosition := StrPos(ParameterString,';');
        if (NewPosition > 0) and ((Position = 0) or (NewPosition < Position)) then
          Position := NewPosition;

        NewPosition := StrPos(ParameterString,'|');
        if (NewPosition > 0) and ((Position = 0) or (NewPosition < Position)) then
          Position := NewPosition;

        exit(Position);
    end;

    [EventSubscriber(ObjectType::Table, 472, 'OnAfterValidateEvent', 'Object ID to Run', true, true)]
    local procedure OnValidateJobQueueEntryObjectIDtoRun(var Rec: Record "Job Queue Entry";var xRec: Record "Job Queue Entry";CurrFieldNo: Integer)
    var
        NcTaskProcessor: Record "Nc Task Processor";
        ParameterString: Text;
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
          exit;
        if Rec."Object ID to Run" <> CurrCodeunitId() then
          exit;

        ParameterString := ParamImportType() + '=';
        ParameterString += ',' + ParamDownloadFtp();
        ParameterString += ',' + ParamDownloadServerFile();
        ParameterString += ',' + ParamProcessImport();

        Rec.Validate("Parameter String",CopyStr(ParameterString,1,MaxStrLen(Rec."Parameter String")));
    end;

    [EventSubscriber(ObjectType::Table, 472, 'OnAfterValidateEvent', 'Parameter String', true, true)]
    local procedure OnValidateJobQueueEntryParameterString(var Rec: Record "Job Queue Entry";var xRec: Record "Job Queue Entry";CurrFieldNo: Integer)
    var
        NcImportType: Record "Nc Import Type";
        ParameterString: Text;
        Description: Text;
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
          exit;
        if Rec."Object ID to Run" <> CurrCodeunitId() then
          exit;

        FindImportType(Rec,NcImportType);
        if NcImportType.Code = '' then
          Description := '{' + Text003 + '}'
        else
          Description := NcImportType.Code;

        if HasParameter(Rec,ParamDownloadFtp()) then
          Description += ' | ' + Text000;

        if HasParameter(Rec,ParamDownloadServerFile()) then
          Description += ' | ' + Text001;

        if HasParameter(Rec,ParamProcessImport()) then
          Description += ' | ' + Text002;

        Rec.Description := CopyStr(Description,1,MaxStrLen(Rec.Description));
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"Nc Import List Processing");
    end;

    local procedure ParamImportType(): Text
    begin
        exit('import_type');
    end;

    local procedure ParamDownloadFtp(): Text
    begin
        exit('download_ftp');
    end;

    local procedure ParamDownloadServerFile(): Text
    begin
        exit('download_server_file');
    end;

    local procedure ParamProcessImport(): Text
    begin
        exit('process_import_list');
    end;
}

