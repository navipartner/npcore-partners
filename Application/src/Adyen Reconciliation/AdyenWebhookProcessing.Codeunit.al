codeunit 6184931 "NPR Adyen Webhook Processing"
{
    TableNo = "NPR Adyen Webhook";
    Access = Internal;

    trigger OnRun()
    var
        ReportReady: Codeunit "NPR Adyen Process Report Ready";
        AdyenPayByLinkStatus: Codeunit "NPR Adyen PayByLink Status";
    begin
        case Rec."Event Code" of
            "NPR Adyen Webhook Event Code"::REPORT_AVAILABLE:
                begin
                    ReportReady.ProcessReportReadyWebhook(Rec);
                end;
            "NPR Adyen Webhook Event Code"::AUTHORISATION:
                begin
                    AdyenPayByLinkStatus.Run(Rec);
                end;
        end;
    end;
}
