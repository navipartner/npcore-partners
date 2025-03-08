codeunit 6248230 "NPR External JQ Refresher WS"
{
    Access = Public;

    procedure RefreshJobQueues() Result: Text
    var
        JobQueueRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueUserHandler: Codeunit "NPR Job Queue User Handler";
        RefresherIsInternallyTurnedOff: Label 'External Refresher is internally turned off.';
        SuccessLbl: Label 'Successfully Refreshed.';
    begin
        JobQueueRefreshSetup.GetSetup();
        if JobQueueRefreshSetup."Use External JQ Refresher" then begin
            JobQueueUserHandler.Run();
            JobQueueRefreshSetup."Last Refreshed" := CurrentDateTime();
            JobQueueRefreshSetup.Modify();
            Result := SuccessLbl;
        end else
            Result := RefresherIsInternallyTurnedOff;
    end;
}