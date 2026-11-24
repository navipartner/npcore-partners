codeunit 6248230 "NPR External JQ Refresher WS"
{
    Access = Public;

    procedure RefreshJobQueues() Result: Text
    var
        JobQueueRefreshSetup: Record "NPR Job Queue Refresh Setup";
        Sentry: Codeunit "NPR Sentry";
        ErrorText: Text;
        RefresherIsInternallyTurnedOff: Label 'External Refresher is not enabled in Business Central.';
        SuccessLbl: Label 'Successfully Refreshed.';
    begin
        JobQueueRefreshSetup.GetSetup();
        if JobQueueRefreshSetup."Use External JQ Refresher" and JobQueueRefreshSetup.Enabled then begin
            // Every company and runner user calls this each hour, so the transaction is not sampled: it is only sent
            // together with an error, when the call failed or a job could not be refreshed.
            Sentry.InitScopeAndTransaction('External JQ Refresher: RefreshJobQueues', 'bc.jobqueue.external-refresher', 0);
            // Run separately, so a failed call still sends its transaction to Sentry before the error goes back to the caller.
            if not Codeunit.Run(Codeunit::"NPR External JQ Refresher Run") then begin
                ErrorText := GetLastErrorText();
                Sentry.AddLastErrorInEnglish();
                Sentry.FinalizeScope();
                Error(ErrorText);
            end;
            Sentry.FinalizeScope();
            Result := SuccessLbl;
        end else
            Result := RefresherIsInternallyTurnedOff;
    end;
}