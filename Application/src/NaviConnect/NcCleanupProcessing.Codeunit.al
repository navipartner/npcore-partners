codeunit 6151510 "NPR Nc Cleanup Processing"
{
    // NC2.26/TJ  /20200506 CASE 401322 New object

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
        ResetTaskCountText: Label 'Reset Retry Count';
        CleanupImportText: Label 'Cleanup Import';

    local procedure GetParameterValue(JobQueueEntry: Record "Job Queue Entry"; ParameterName: Text) ParameterValue: Text
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

    local procedure HasParameter(JobQueueEntry: Record "Job Queue Entry"; ParameterName: Text): Boolean
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

        ParameterString := ResetTaskCountParameter();
        ParameterString += ',' + CleanupImportParameter();

        Rec.Validate("Parameter String", CopyStr(ParameterString, 1, MaxStrLen(Rec."Parameter String")));
    end;

    [EventSubscriber(ObjectType::Table, 472, 'OnAfterValidateEvent', 'Parameter String', true, true)]
    local procedure OnValidateJobQueueEntryParameterString(var Rec: Record "Job Queue Entry"; var xRec: Record "Job Queue Entry"; CurrFieldNo: Integer)
    var
        Description: Text;
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
            exit;
        if Rec."Object ID to Run" <> CurrCodeunitId() then
            exit;

        if HasParameter(Rec, ResetTaskCountParameter()) then
            Description := ResetTaskCountText;

        if HasParameter(Rec, CleanupImportParameter()) then
            Description += ' | ' + CleanupImportText;

        Rec.Description := CopyStr(Description, 1, MaxStrLen(Rec.Description));
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

