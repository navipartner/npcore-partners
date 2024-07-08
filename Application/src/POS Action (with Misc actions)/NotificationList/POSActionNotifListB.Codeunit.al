codeunit 6060037 "NPR POS Action: Notif. List B"
{
    Access = Internal;

    procedure OpenNotificationPage(POSSale: Codeunit "NPR POS Sale");
    var
        SalePOS: Record "NPR POS Sale";
        NotificationList: Page "NPR Notification List";
    begin
        POSSale.GetCurrentSale(SalePOS);

        NotificationList.SetRegister(SalePOS."Register No.");
        NotificationList.Run();
    end;
}