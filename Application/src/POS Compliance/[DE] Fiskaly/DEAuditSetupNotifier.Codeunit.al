codeunit 6059849 "NPR DE Audit Setup Notifier"
{
    Access = Internal;
    SingleInstance = true;

    var
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";

    local procedure ShowDEAuditSetupNotification()
    var
        DEAuditSetupNotification: Notification;
        LearnMoreActionLbl: Label 'Learn more';
        NotificationActionLbl: Label 'Open Setup Page';
        NotificationTxt: Label 'Selected audit handler requires you to set up Fiskaly POS units.';
    begin
        DEAuditSetupNotification.Id := GetNotificationId();
        DEAuditSetupNotification.Message(NotificationTxt);
        DEAuditSetupNotification.AddAction(NotificationActionLbl, Codeunit::"NPR DE Audit Setup Notifier", 'OnActionShowSetup');
        DEAuditSetupNotification.AddAction(LearnMoreActionLbl, Codeunit::"NPR DE Audit Setup Notifier", 'OnActionLearnMore');
        DEAuditSetupNotification.Send();
        OnNotificationSent();
    end;

    procedure OnActionShowSetup(Notification: Notification)
    begin
        DEAuditMgt.OnActionShowSetup();
    end;

    procedure OnActionLearnMore(Notification: Notification)
    begin
        DEAuditMgt.OnActionLearnMore();
    end;

    local procedure GetNotificationId(): Guid
    begin
        exit('80f26c6e-e8e7-ec11-aa88-9bd193dab5dc');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Audit Profile", 'OnAfterValidateEvent', 'Audit Handler', false, false)]
    local procedure OnAfterValidateAuditHandler(var Rec: Record "NPR POS Audit Profile"; var xRec: Record "NPR POS Audit Profile")
    begin
        if DEAuditMgt.ShouldDisplayNotification(Rec, xRec) then
            ShowDEAuditSetupNotification();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnNotificationSent()
    begin
    end;
}