codeunit 6151510 "NPR Nc Cleanup Processing"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        NcImportMgt: Codeunit "NPR Nc Import Mgt.";
    begin
        if HasParameter(Rec, ResetTaskCountParameter()) then
            NcSyncMgt.TaskResetCount();
        if HasParameter(Rec, CleanupImportParameter()) then
            NcImportMgt.CleanupImportTypes();
    end;

    var
        ResetTaskCountTxt: Label 'Reset Retry Count';
        CleanupImportTxt: Label 'Cleanup Import';

    local procedure HasParameter(JobQueueEntry: Record "Job Queue Entry"; ParameterName: Text): Boolean
    var
        Position: Integer;
    begin
        Position := StrPos(LowerCase(JobQueueEntry."Parameter String"), LowerCase(ParameterName));
        exit(Position > 0);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnAfterValidateEvent', 'Object ID to Run', true, true)]
    local procedure OnValidateJobQueueEntryObjectIDtoRun(var Rec: Record "Job Queue Entry"; var xRec: Record "Job Queue Entry"; CurrFieldNo: Integer)
    var
        ParameterString: Text;
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
            exit;
        if Rec."Object ID to Run" <> CurrCodeunitId() then
            exit;

        ParameterString := ResetTaskCountParameter();
        ParameterString += ',' + CleanupImportParameter();

        Rec.Validate("Parameter String", CopyStr(ParameterString, 1, MaxStrLen(Rec."Parameter String")));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnAfterValidateEvent', 'Parameter String', true, true)]
    local procedure OnValidateJobQueueEntryParameterString(var Rec: Record "Job Queue Entry"; var xRec: Record "Job Queue Entry"; CurrFieldNo: Integer)
    var
        Desc: Text;
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
            exit;
        if Rec."Object ID to Run" <> CurrCodeunitId() then
            exit;

        if HasParameter(Rec, ResetTaskCountParameter()) then
            Desc := ResetTaskCountTxt;

        if HasParameter(Rec, CleanupImportParameter()) then
            Desc += ' | ' + CleanupImportTxt;

        Rec.Description := CopyStr(Desc, 1, MaxStrLen(Rec.Description));
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Nc Cleanup Processing");
    end;

    local procedure ResetTaskCountParameter(): Text
    begin
        exit('reset_retry_count');
    end;

    local procedure CleanupImportParameter(): Text
    begin
        exit('cleanup_import');
    end;
}

