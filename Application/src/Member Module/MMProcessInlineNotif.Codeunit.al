codeunit 6014687 "NPR MM Process Inline Notif"
{
    TableNo = "NPR MM Membership Notific.";

    trigger OnRun()
    var
        MemberNotification: Codeunit "NPR MM Member Notification";
        MembershipNotification: Record "NPR MM Membership Notific.";
    begin
        if (Rec.GetFilters() = '') then
            exit;

        MembershipNotification.CopyFilters(Rec);
        MembershipNotification.SetFilter("Processing Method", '=%1', MembershipNotification."Processing Method"::INLINE);
        MembershipNotification.SetFilter("Notification Status", '=%1', MembershipNotification."Notification Status"::PENDING);
        if (MembershipNotification.IsEmpty()) then
            exit;

        // posting is occurring in a other thread.
        // I want posting to be done before sending out the inline notification
        // (this codeunit is invoked in a background session, so there is no UI blocking)
        Sleep(5000);
        SelectLatestVersion();

        if (not MembershipNotification.FindSet()) then
            exit;

        repeat
            MemberNotification.HandleMembershipNotification(MembershipNotification);
        until (MembershipNotification.Next() = 0);
    end;
}
