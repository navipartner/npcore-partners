codeunit 6184768 "NPR MM Member Notif. On Sale"
{
    trigger OnRun()
    var
        MMMemberNotification: Codeunit "NPR MM Member Notification";
    begin
        MMMemberNotification.SendMemberNotification();
    end;

}