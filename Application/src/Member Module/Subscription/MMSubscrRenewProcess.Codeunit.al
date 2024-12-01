codeunit 6185036 "NPR MM Subscr. Renew: Process"
{
    Access = Internal;
    TableNo = "NPR MM Subscr. Request";


    internal procedure ProcessSubscriptionRequest(var SubscriptionRequest: Record "NPR MM Subscr. Request"; SkipTryCountUpdate: Boolean; Manual: Boolean) Success: Boolean;
    var
        NpPaySetup: Record "NPR Adyen Setup";
        SubsReqLogEntry: Record "NPR MM Subs Req Log Entry";
        SubsTryRenewProcess: Codeunit "NPR MM Subs Try Renew Process";
    begin
        NpPaySetup.Get();

        PrepareRecords(SubscriptionRequest, SubsReqLogEntry, SkipTryCountUpdate, Manual);
        ClearLastError();
        Commit();

        SubsTryRenewProcess.SetManual(Manual);
        SubsTryRenewProcess.SetSkipTryCountUpdate(SkipTryCountUpdate);
        Success := SubsTryRenewProcess.Run(SubscriptionRequest);
        if not Success then begin
            //Refresh record
            SubscriptionRequest.Get(SubscriptionRequest.RecordId);
            ProcessErrorResponse(SubscriptionRequest, SubsReqLogEntry, NpPaySetup."Max Sub Req Process Try Count");
        end;
        Commit();
    end;

    local procedure PrepareRecords(var SubscriptionRequest: Record "NPR MM Subscr. Request"; var SubsReqLogEntry: Record "NPR MM Subs Req Log Entry"; SkipTryCountUpdate: Boolean; Manual: Boolean)
    var
        SubsReqLogUtils: Codeunit "NPR MM Subs Req Log Utils";
    begin
        SubsReqLogUtils.LogEntry(SubscriptionRequest, Manual, SubsReqLogEntry);
        if not SkipTryCountUpdate then begin
            SubscriptionRequest."Process Try Count" += 1;
            SubscriptionRequest.Modify(true);
        end;
    end;

    local procedure ProcessErrorResponse(var SubscrRequest: Record "NPR MM Subscr. Request"; var SubsReqLogEntry: Record "NPR MM Subs Req Log Entry"; MaxProcessTryCount: Integer)
    var
        SubsReqLogUtils: Codeunit "NPR MM Subs Req Log Utils";
    begin
        UpdateSubscriptionRequestErrorProcessingStatus(SubscrRequest, MaxProcessTryCount);

        SubsReqLogUtils.UpdateEntry(SubsReqLogEntry, SubsReqLogEntry."Processing Status"::Error, GetLastErrorText());
    end;

    local procedure UpdateSubscriptionRequestErrorProcessingStatus(var SubscrRequest: Record "NPR MM Subscr. Request"; MaxProcessTryCount: Integer)
    begin
        if SubscrRequest."Processing Status" = SubscrRequest."Processing Status"::Success then
            exit;

        if SubscrRequest."Process Try Count" < MaxProcessTryCount then
            exit;

        if SubscrRequest."Processing Status" = SubscrRequest."Processing Status"::Error then
            exit;

        SubscrRequest.Validate("Processing Status", SubscrRequest."Processing Status"::Error);
        SubscrRequest.Modify(true);
    end;
}