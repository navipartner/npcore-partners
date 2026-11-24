codeunit 6184568 "NPR External JQ Refresher Run"
{
    Access = Internal;

    trigger OnRun()
    var
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        JobQueueUserHandler: Codeunit "NPR Job Queue User Handler";
    begin
        JobQueueMgt.RefreshNPRJobQueueList(true, true);
        JobQueueUserHandler.UpdateLastRefreshed();
    end;
}
