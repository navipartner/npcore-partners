codeunit 6248230 "NPR External JQ Refresher WS"
{
    Access = Public;

    procedure RefreshJobQueues() Result: Text
    var
        JobQueueRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        RefresherIsInternallyTurnedOff: Label 'External Refresher is not enabled in Business Central.';
        SuccessLbl: Label 'Successfully Refreshed.';
    begin
        JobQueueRefreshSetup.GetSetup();
        if JobQueueRefreshSetup."Use External JQ Refresher" and JobQueueRefreshSetup.Enabled then begin
            JobQueueMgt.RefreshNPRJobQueueList(true);
            JobQueueRefreshSetup.Find();
            JobQueueRefreshSetup."Last Refreshed" := CurrentDateTime();
            JobQueueRefreshSetup.Modify();
            Result := SuccessLbl;
        end else
            Result := RefresherIsInternallyTurnedOff;
    end;
}