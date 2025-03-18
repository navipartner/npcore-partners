codeunit 6184931 "NPR Adyen Webhook Processing"
{
    TableNo = "NPR Adyen Webhook";
    Access = Internal;

    trigger OnRun()
    var
        AdyenWebhook: Record "NPR Adyen Webhook";
        TryWebhookProcess: Codeunit "NPR Adyen Try Webhook Process";
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        AdyenWebhook.ReadIsolation := IsolationLevel::UpdLock;
#else
        AdyenWebhook.LockTable();
#endif
        AdyenWebhook.Get(Rec."Entry No.");
        if AdyenWebhook.Status = AdyenWebhook.Status::Processed then
            exit;

        Commit();
        if not TryWebhookProcess.Run(AdyenWebhook) then begin
            AdyenManagement.CreateGeneralLog(Enum::"NPR Adyen Webhook Log Type"::Error, false, GetLastErrorText(), Rec."Entry No.");
            AdyenWebhook.Status := Rec.Status::Error;
            AdyenWebhook."Processed Date" := CurrentDateTime();
            AdyenWebhook.Modify();
        end;
        Commit();
    end;
}
