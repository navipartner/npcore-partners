codeunit 6151509 "NPR Nc Import List Processing"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        NcImportType: Record "NPR Nc Import Type";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
    begin
        JQParamStrMgt.Parse(Rec."Parameter String");
        if not FilterImportType(JQParamStrMgt.GetParamValueAsText(ParamImportType()), NcImportType) then
            exit;

        UpdateImportList(Rec, NcImportType);

        if JQParamStrMgt.ContainsParam(ParamProcessImport()) then
            ProcessImportEntries(NcImportType);
    end;

    var
        DownloadFtpTxt: Label 'Download Ftp';
        ProcessImportListTxt: Label 'Process Import List';
        AllTxt: Label 'All';

    local procedure UpdateImportList(JobQueueEntry: Record "Job Queue Entry"; var ImportType: Record "NPR Nc Import Type")
    var
        NcDependencyFactory: Codeunit "NPR Nc Dependency Factory";
        ImportListUpdater: Interface "NPR Nc Import List IUpdate";
    begin
        if ImportType.FindSet() then
            repeat
                if NcDependencyFactory.CreateNcImportListUpdater(ImportListUpdater, ImportType) then
                    ImportListUpdater.Update(JobQueueEntry, ImportType);
            until ImportType.Next() = 0;
    end;

    procedure ProcessImportEntries(var NcImportType: Record "NPR Nc Import Type")
    var
        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        NcImportEntry: Record "NPR Nc Import Entry";
        NcImportEntry2: Record "NPR Nc Import Entry";
    begin
        if NcImportType.GetFilter(Code) <> '' then
            NcImportType.CopyFilter(Code, NcImportEntry."Import Type");
        NcImportEntry.SetRange(Imported, false);
        NcImportEntry.SetRange("Runtime Error", false);
        NcImportEntry.SetFilter("Earliest Import Datetime", '<=%1', CurrentDateTime);
        if NcImportEntry.IsEmpty then
            exit;
        if NcImportEntry.FindSet(true) then
            repeat
                NcImportEntry2 := NcImportEntry;
                NcSyncMgt.ProcessImportEntry(NcImportEntry2);
            until NcImportEntry.Next() = 0;
    end;

    procedure FilterImportType(ImportTypeParamValue: Text; var NcImportType: Record "NPR Nc Import Type"): Boolean
    begin
        Clear(NcImportType);
        if ImportTypeParamValue <> '' then begin
            if StrLen(ImportTypeParamValue) <= MaxStrLen(NcImportType.Code) then
                if NcImportType.Get(ImportTypeParamValue) then begin
                    NcImportType.SetRecFilter();
                    exit(true);
                end;
            NcImportType.SetFilter(Code, ImportTypeParamValue);
        end;
        exit(not NcImportType.IsEmpty);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnAfterValidateEvent', 'Object ID to Run', true, true)]
    local procedure OnValidateJobQueueEntryObjectIDtoRun(var Rec: Record "Job Queue Entry"; var xRec: Record "Job Queue Entry"; CurrFieldNo: Integer)
    var
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
            exit;
        if Rec."Object ID to Run" <> CurrCodeunitId() then
            exit;

        JQParamStrMgt.ClearParamDict();
        JQParamStrMgt.AddToParamDict(ParamImportType() + '=');
        JQParamStrMgt.AddToParamDict(ParamDownloadFtp());
        JQParamStrMgt.AddToParamDict(ParamProcessImport());

        Rec.Validate("Parameter String", CopyStr(JQParamStrMgt.GetParamListAsCSString(), 1, MaxStrLen(Rec."Parameter String")));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnAfterValidateEvent', 'Parameter String', true, true)]
    local procedure OnValidateJobQueueEntryParameterString(var Rec: Record "Job Queue Entry"; var xRec: Record "Job Queue Entry"; CurrFieldNo: Integer)
    var
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        Description: Text;
        ImportTypeParamValue: Text;
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
            exit;
        if Rec."Object ID to Run" <> CurrCodeunitId() then
            exit;

        JQParamStrMgt.Parse(Rec."Parameter String");
        ImportTypeParamValue := JQParamStrMgt.GetParamValueAsText(ParamImportType());
        if ImportTypeParamValue = '' then
            Description := '{' + AllTxt + '}'
        else
            Description := ImportTypeParamValue;

        if JQParamStrMgt.ContainsParam(ParamDownloadFtp()) then
            Description += ' | ' + DownloadFtpTxt;

        if JQParamStrMgt.ContainsParam(ParamProcessImport()) then
            Description += ' | ' + ProcessImportListTxt;

        Rec.Description := CopyStr(Description, 1, MaxStrLen(Rec.Description));
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Nc Import List Processing");
    end;

    procedure ParamImportType(): Text
    begin
        exit('import_type');
    end;

    procedure ParamDownloadFtp(): Text
    begin
        exit('download_ftp');
    end;

    procedure ParamProcessImport(): Text
    begin
        exit('process_import_list');
    end;
}