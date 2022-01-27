codeunit 6151574 "NPR AF API - Notification Hub"
{
    Access = Internal;
    procedure ReSendPushNotification(AFNotificationHub: Record "NPR AF Notification Hub")
    var
        NewAFNotificationHub: Record "NPR AF Notification Hub";
    begin
        NewAFNotificationHub.TransferFields(AFNotificationHub, false);
        NewAFNotificationHub.Insert(true);
    end;


}

