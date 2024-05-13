codeunit 6184768 "NPR MM Member Notif. On Sale"
{
    TableNo = "NPR POS Sale";
    trigger OnRun()
    var
        MMMemberNotification: Codeunit "NPR MM Member Notification";
        POSUnit: Record "NPR POS Unit";
        POSMemberProfile: Record "NPR MM POS Member Profile";
    begin
        if not POSUnit.Get(Rec."Register No.") then
            exit;

        if not POSUnit.GetProfile(POSMemberProfile) then
            exit;

        if not POSMemberProfile."Send Notification On Sale" then
            exit;

        MMMemberNotification.SendMemberNotification();
    end;

}