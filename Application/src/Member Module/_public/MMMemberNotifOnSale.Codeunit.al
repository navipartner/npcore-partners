codeunit 6184768 "NPR MM Member Notif. On Sale"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-03-22';
    ObsoleteReason = 'Send Notification On Sale setting removed. It spawned background sessions on every sale, spamming the NST and killing cache performance.';

    TableNo = "NPR POS Sale";
    trigger OnRun()
    begin
    end;

}