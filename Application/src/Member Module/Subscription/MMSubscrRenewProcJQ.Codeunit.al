codeunit 6185034 "NPR MM Subscr. Renew Proc. JQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        NpPaySetup: Record "NPR Adyen Setup";
        SubscrRenewProcess: Codeunit "NPR MM Subscr. Renew: Process";
    begin
        if not NpPaySetup.Get() then
            exit;

        SubscriptionRequest.SetFilter(Type, '%1|%2|%3', SubscriptionRequest.Type::Renew, SubscriptionRequest.Type::Regret, SubscriptionRequest.Type::"Partial Regret");
        if NpPaySetup."Auto Process Subs Req Errors" then begin
            SubscriptionRequest.SetFilter("Processing Status", '%1|%2', SubscriptionRequest."Processing Status"::Pending, SubscriptionRequest."Processing Status"::Error);
            SubscriptionRequest.SetFilter(Status, '%1|%2|%3', SubscriptionRequest.Status::Confirmed, SubscriptionRequest.Status::Rejected, SubscriptionRequest.Status::"Request Error");
        end else begin
            SubscriptionRequest.SetRange("Processing Status", SubscriptionRequest."Processing Status"::Pending);
            SubscriptionRequest.SetFilter(Status, '%1|%2', SubscriptionRequest.Status::Confirmed, SubscriptionRequest.Status::Rejected);
        end;
        if SubscriptionRequest.FindSet() then
            repeat
                SubscrRenewProcess.ProcessSubscriptionRequest(SubscriptionRequest, false, false);
            until SubscriptionRequest.Next() = 0;
    end;
}