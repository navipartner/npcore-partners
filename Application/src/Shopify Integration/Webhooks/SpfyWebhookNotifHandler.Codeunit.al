#if not BC17
codeunit 6184954 "NPR Spfy Webhook Notif.Handler"
{
    Access = Internal;
    TableNo = "NPR Spfy Webhook Notification";

    trigger OnRun()
    var
        SpfyWebhookNotification: Record "NPR Spfy Webhook Notification";
        SpfyWebhookNotifIHndlr: Interface "NPR Spfy Webhook Notif. IHndlr";
    begin
        SelectLatestVersion();
#if not (BC18 or BC19 or BC20 or BC21)
        SpfyWebhookNotification.ReadIsolation := IsolationLevel::UpdLock;
#else
        SpfyWebhookNotification.LockTable();
#endif
        SpfyWebhookNotification.Get(Rec."Entry No.");
        if SpfyWebhookNotification.Status = SpfyWebhookNotification.Status::Processed then
            exit;  //already processed elsewhere

        Clear(SpfyWebhookNotification."Last Error Message");
        SpfyWebhookNotification.Status := SpfyWebhookNotification.Status::New;

        SpfyWebhookNotifIHndlr := SpfyWebhookNotification.Topic;
        SpfyWebhookNotifIHndlr.ProcessWebhookNotification(SpfyWebhookNotification);
    end;

    internal procedure ProcessWebhookNotifications(var SpfyWebhookNotificationIn: Record "NPR Spfy Webhook Notification"; WithDialog: Boolean)
    var
        SpfyWebhookNotification: Record "NPR Spfy Webhook Notification";
        Window: Dialog;
        RecNo: Integer;
        TotalRecNo: Integer;
        ShowDialog: Boolean;
        DialogTxt1: Label 'Processing Shopify webhook notifications...\\';
        DialogTxt2: Label 'Notification #1####### of #2#######';
        DoneTxt: Label 'Shopify webhook notification processing completed successfully.';
    begin
        SpfyWebhookNotification.Copy(SpfyWebhookNotificationIn);
        SpfyWebhookNotification.FilterGroup(10);
        SpfyWebhookNotification.SetFilter(Status, '<>%1', SpfyWebhookNotification.Status::Processed);
        SpfyWebhookNotification.FilterGroup(0);
        SpfyWebhookNotification.SetCurrentKey("Entry No.");
        SpfyWebhookNotification.Ascending := true;

        if WithDialog then begin
            TotalRecNo := SpfyWebhookNotification.Count();
            ShowDialog := TotalRecNo > 1;
        end;
        if ShowDialog then begin
            Window.Open(DialogTxt1 + DialogTxt2);
            Window.Update(2, TotalRecNo);
        end;

        if SpfyWebhookNotification.FindSet() then
            repeat
                ProcessOneWebhookNotification(SpfyWebhookNotification);

                if ShowDialog then begin
                    RecNo += 1;
                    Window.Update(1, RecNo);
                end;
            until SpfyWebhookNotification.Next() = 0;

        if ShowDialog then begin
            Window.Close();
            Message(DoneTxt);
        end;
    end;

    internal procedure ProcessOneWebhookNotification(SpfyWebhookNotification: Record "NPR Spfy Webhook Notification")
    begin
        ClearLastError();
        if not Codeunit.Run(Codeunit::"NPR Spfy Webhook Notif.Handler", SpfyWebhookNotification) then begin
            SpfyWebhookNotification.Find();
            SpfyWebhookNotification."Number of Process Attempts" += 1;
            if SpfyWebhookNotification."Number of Process Attempts" > 3 then
                SpfyWebhookNotification.Status := SpfyWebhookNotification.Status::Cancelled
            else
                SpfyWebhookNotification.Status := SpfyWebhookNotification.Status::Error;
            SpfyWebhookNotification."Processed at" := 0DT;
            SpfyWebhookNotification.SetErrorMessage(GetLastErrorText());
            SpfyWebhookNotification.Modify();
            Commit();
        end;
    end;
}
#endif