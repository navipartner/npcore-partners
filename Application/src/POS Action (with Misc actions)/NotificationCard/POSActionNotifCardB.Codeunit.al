codeunit 6060036 "NPR POS Action: Notif. Card B"
{
    Access = Internal;
    procedure OpenNotificationPage(Sale: Codeunit "NPR POS Sale")
    var
        SalePOS: Record "NPR POS Sale";
        NotificationDialog: Page "NPR Notification Dialog";
    begin
        Sale.GetCurrentSale(SalePOS);

        NotificationDialog.SetRegister(SalePOS."Register No.");
        NotificationDialog.RunModal();
    end;

}