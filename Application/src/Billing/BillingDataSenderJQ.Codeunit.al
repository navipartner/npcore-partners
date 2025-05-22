#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6060051 "NPR Billing Data Sender JQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";
    Permissions =
        tabledata "Job Queue Log Entry" = R;

    var
        NumberOfDateToCheckInvalidErr: Label 'Number of days without processing must be greater than 0.';

    trigger OnRun()
    begin
        ForwardDataToBillingDatabase();
    end;

    procedure CheckNonRunningTaskViaJQAndProcess(AsBackgroundTask: Boolean; NumberOfDaysWithoutProcessing: Integer) RetVal: Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueLogEntry: Record "Job Queue Log Entry";
        BillingClient: Codeunit "NPR Event Billing Client";
        LogCustDims: Dictionary of [Text, Text];
        DateTimeRangeToCheck: DateTime;
        SessionId: Integer;
    begin
        if (NumberOfDaysWithoutProcessing < 1) then
            Error(NumberOfDateToCheckInvalidErr);

        if (not BillingClient.HasPendingChanges(NumberOfDaysWithoutProcessing)) then
            exit(true);

        DateTimeRangeToCheck := CreateDateTime(CalcDate(StrSubstNo('<-%1D>', NumberOfDaysWithoutProcessing), Today()), 0T);

        JobQueueLogEntry.ReadIsolation := JobQueueLogEntry.ReadIsolation::ReadCommitted;
        JobQueueLogEntry.Reset();
        JobQueueLogEntry.SetCurrentKey("Object Type to Run", "Object ID to Run", Status);
        JobQueueLogEntry.SetRange("Object Type to Run", JobQueueLogEntry."Object Type to Run"::Codeunit);
        JobQueueLogEntry.SetRange("Object ID to Run", Codeunit::"NPR Billing Data Sender JQ");
        JobQueueLogEntry.SetFilter("Start Date/Time", '>=%1', DateTimeRangeToCheck);
        if (not JobQueueLogEntry.IsEmpty) then
            exit(true);

        if (AsBackgroundTask) then begin
            Clear(JobQueueEntry);

            RetVal := Session.StartSession(SessionId, Codeunit::"NPR Billing Data Sender JQ", CompanyName, JobQueueEntry);

            if (not RetVal) then begin
                Clear(LogCustDims);
                Session.LogMessage('NPR_API_NpBilling', StrSubstNo('Running "NPR Billing Data Sender JQ".CheckNonRunningTaskViaJQAndProcess() failed. The error message is: %1', GetLastErrorText()), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, LogCustDims);
            end;

            exit(RetVal);
        end else begin
            ForwardDataToBillingDatabase();
            exit(true);
        end;
    end;

    local procedure ForwardDataToBillingDatabase()
    var
        BillingClient: Codeunit "NPR Event Billing Client";
    begin
        BillingClient.ForwardDataToBillingDatabase();
    end;
}
#endif