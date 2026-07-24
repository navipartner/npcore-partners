codeunit 6184780 "NPR NPRE Send Notifications JQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        SendOutstandingNotifications();
    end;

    internal procedure SendOutstandingNotifications()
    var
        NotificationEntry: Record "NPR NPRE Notification Entry";
        NotificationEntry2: Record "NPR NPRE Notification Entry";
        Sentry: Codeunit "NPR Sentry";
    begin
        SelectLatestVersion();
        NotificationEntry.SetRange("Notification Send Status", NotificationEntry."Notification Send Status"::PENDING);
        NotificationEntry.SetFilter("Notify at Date-Time", '<=%1', CurrentDateTime());
        if not NotificationEntry.FindSet() then
            exit;

        Sentry.InitScopeAndTransaction('NPRE Send Outstanding Notifications JQ', 'bc.restaurant.notif.send-outstanding', 0.1); // runs every minute - low sampling
        repeat
            if NotificationEntry2.Get(NotificationEntry."Entry No.") and (NotificationEntry2."Notification Send Status" = NotificationEntry2."Notification Send Status"::PENDING) then
                SendNotification(NotificationEntry2);
            Commit();
        until NotificationEntry.Next() = 0;
        Sentry.FinalizeScope();
    end;

    internal procedure SendNotification(NotificationEntry: Record "NPR NPRE Notification Entry")
    var
        NotificationHandler: Codeunit "NPR NPRE Notification Handler";
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
        Success: Boolean;
        ErrorText: Text;
    begin
        ClearLastError();

        Sentry.StartSpan(Span, 'bc.restaurant.notif.send');
        Success := Codeunit.Run(Codeunit::"NPR NPRE Send Notification", NotificationEntry);
        if Success then
            Span.Finish()
        else begin
            ErrorText := GetLastErrorText();
            Sentry.AddLastErrorIfProgrammingBug();
            Span.Finish("NPR Sentry Span Status"::InternalError);
        end;

        if not Success then begin
            NotificationEntry.Find();
            NotificationHandler.SetFailed(NotificationEntry, ErrorText, true);
        end;
    end;
}