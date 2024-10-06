codeunit 6184931 "NPR Adyen Webhook Processing"
{
    TableNo = "NPR Adyen Webhook";
    Access = Internal;

    trigger OnRun()
    var
        ReportReady: Codeunit "NPR Adyen Process Report Ready";
        AdyenPayByLinkStatus: Codeunit "NPR Adyen PayByLink Status";
        AdyenWebhook: Record "NPR Adyen Webhook";
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        AdyenWebhook.ReadIsolation := IsolationLevel::UpdLock;
#else
        AdyenWebhook.LockTable();
#endif
        AdyenWebhook.Get(Rec."Entry No.");
        if AdyenWebhook.Status = AdyenWebhook.Status::Processed then
            exit;
        case AdyenWebhook."Event Code" of
            "NPR Adyen Webhook Event Code"::REPORT_AVAILABLE:
                begin
                    ReportReady.ProcessReportReadyWebhook(AdyenWebhook);
                end;
            "NPR Adyen Webhook Event Code"::AUTHORISATION:
                begin
                    AdyenPayByLinkStatus.Run(AdyenWebhook);
                end;
        end;
    end;
}
