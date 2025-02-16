codeunit 6248230 "NPR External JQ Refresher WS"
{
    Access = Public;

    procedure RefreshJobQueues(): Text
    var
        JobQueueRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueUserHandler: Codeunit "NPR Job Queue User Handler";
        SuccessLbl: Label 'Successfully Refreshed.';
    begin
        JobQueueUserHandler.Run();
        JobQueueRefreshSetup.GetSetup();
        JobQueueRefreshSetup."Last Refreshed" := CurrentDateTime();
        JobQueueRefreshSetup.Modify();
        exit(SuccessLbl);
    end;
}