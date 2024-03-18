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
    begin
        SelectLatestVersion();
        NotificationEntry.SetRange("Notification Send Status", NotificationEntry."Notification Send Status"::PENDING);
        NotificationEntry.SetFilter("Notify at Date-Time", '<=%1', CurrentDateTime());
        if NotificationEntry.FindSet() then
            repeat
                if NotificationEntry2.Get(NotificationEntry."Entry No.") and (NotificationEntry2."Notification Send Status" = NotificationEntry2."Notification Send Status"::PENDING) then
                    SendNotification(NotificationEntry2);
                Commit();
            until NotificationEntry.Next() = 0;
    end;

    internal procedure SendNotification(NotificationEntry: Record "NPR NPRE Notification Entry")
    var
        NotificationHandler: Codeunit "NPR NPRE Notification Handler";
        Success: Boolean;
    begin
        ClearLastError();
        Success := Codeunit.Run(Codeunit::"NPR NPRE Send Notification", NotificationEntry);
        if not Success then begin
            NotificationEntry.Find();
            NotificationHandler.SetFailed(NotificationEntry, GetLastErrorText(), true);
        end;
    end;
}