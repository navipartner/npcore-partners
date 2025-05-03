codeunit 6248230 "NPR External JQ Refresher WS"
{
    Access = Public;

    procedure RefreshJobQueues() Result: Text
    var
        JobQueueRefreshSetup: Record "NPR Job Queue Refresh Setup";
        ExtJQRefresherMgt: Codeunit "NPR External JQ Refresher Mgt.";
        RefresherIsInternallyTurnedOff: Label 'External Refresher is internally turned off.';
        SuccessLbl: Label 'Successfully Refreshed.';
    begin
        JobQueueRefreshSetup.GetSetup();
        if JobQueueRefreshSetup."Use External JQ Refresher" and JobQueueRefreshSetup.Enabled then begin
            ExtJQRefresherMgt.RefreshJobQueueEntries();
            JobQueueRefreshSetup."Last Refreshed" := CurrentDateTime();
            JobQueueRefreshSetup.Modify();
            Result := SuccessLbl;
        end else
            Result := RefresherIsInternallyTurnedOff;
    end;
}