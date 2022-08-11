codeunit 6184852 "NPR POS Unit Notification"
{
    Access = Internal;
    [EventSubscriber(ObjectType::Page, Page::"NPR Activities", 'OnOpenPageEvent', '', false, false)]
    local procedure MissingNotifOnAfterGetCurrRecordEvent()
    begin
        SendOrRecallMissingNotification();
    end;

    //add notification to my notifications
    [EventSubscriber(ObjectType::Page, Page::"My Notifications", 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDefaultState()
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefaultWithTableNum(NotificationIdLbl,
            POSUnitMissingNotificationMsg,
            POSUnitNotificationDescriptionTxt,
            Database::"NPR POS Unit");
    end;

    local procedure SendPOSUnitMissingNotification()
    var
        MyNotification: Notification;
        OpenPOSUnitLbl: Label 'OpenPOSUnitPage', Locked = true;
    begin
        MyNotification.ID := NotificationIdLbl;
        MyNotification.Message := POSUnitMissingNotificationMsg;
        MyNotification.Scope := NotificationScope::LocalScope;
        MyNotification.AddAction(OpenPOSUnitTxt, Codeunit::"NPR POS Unit Notification", OpenPOSUnitLbl);
        MyNotification.Send();
    end;

    procedure OpenPOSUnitPage(MyNotification: Notification)
    begin
        Page.Run(Page::"NPR POS Unit List");
    end;

    local procedure SendOrRecallMissingNotification()
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if not IsPOSUnitNotificationEnabled() then
            exit;

        if POSUnit.IsEmpty() then
            SendPOSUnitMissingNotification()
        else
            RecallMissingNotification();
    end;

    local procedure RecallMissingNotification()
    var
        MyNotification: Notification;
    begin
        MyNotification.ID := NotificationIdLbl;
        MyNotification.Recall();
    end;

    //add isEnabled function
    local procedure IsPOSUnitNotificationEnabled(): Boolean
    var
        MyNotifications: Record "My Notifications";
        POSUnit: Record "NPR POS Unit";
    begin
        exit(MyNotifications.IsEnabledForRecord(NotificationIdLbl, POSUnit));
    end;

    var
        NotificationIdLbl: Label '407f8cda-a82f-46d2-967e-85bb9153aca2', Locked = true;
        POSUnitNotificationDescriptionTxt: Label 'Show warning when POS unit list is empty.';
        OpenPOSUnitTxt: Label 'Open POS unit list';
        POSUnitMissingNotificationMsg: Label 'POS unit list is empty.';
}