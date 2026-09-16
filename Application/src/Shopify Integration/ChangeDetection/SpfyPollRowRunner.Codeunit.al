codeunit 6151275 "NPR Spfy Poll Row Runner"
{
    Access = Internal;
    SingleInstance = true;

    var
        _TableNo: Integer;
        _RecordId: RecordId;
        _SystemId: Guid;

    trigger OnRun()
    var
        SpfyChangeTrackerMgt: Codeunit "NPR Spfy Change Tracker Mgt.";
        SpfyChangeDispatcher: Codeunit "NPR Spfy Change Dispatcher";
        DetectedChange: Codeunit "NPR Spfy Detected Change";
    begin
        DetectedChange.Init(SpfyChangeTrackerMgt.IntegrationAreaForTable(_TableNo), "NPR Spfy Change Type"::Modify, _TableNo, _RecordId, _SystemId);
        SpfyChangeDispatcher.Dispatch(DetectedChange);
    end;

    internal procedure SetStagedRow(TableNo: Integer; StagedRecordId: RecordId; StagedSystemId: Guid)
    begin
        _TableNo := TableNo;
        _RecordId := StagedRecordId;
        _SystemId := StagedSystemId;
    end;
}
