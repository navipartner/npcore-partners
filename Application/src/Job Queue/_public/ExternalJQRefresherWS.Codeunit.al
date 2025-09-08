codeunit 6248230 "NPR External JQ Refresher WS"
{
    Access = Public;

    procedure RefreshJobQueues() Result: Text
    var
        JobQueueRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        JobQueueUserHandler: Codeunit "NPR Job Queue User Handler";
        RefresherIsInternallyTurnedOff: Label 'External Refresher is not enabled in Business Central.';
        SuccessLbl: Label 'Successfully Refreshed.';
    begin
        JobQueueRefreshSetup.GetSetup();
        if JobQueueRefreshSetup."Use External JQ Refresher" and JobQueueRefreshSetup.Enabled then begin
            JobQueueMgt.RefreshNPRJobQueueList(true);
            JobQueueUserHandler.UpdateLastRefreshed();
            Result := SuccessLbl;
        end else
            Result := RefresherIsInternallyTurnedOff;
    end;
}