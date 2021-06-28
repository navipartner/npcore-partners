codeunit 6014441 "NPR Get Started Notification"
{
    local procedure SendOrRecallGetStartedNotification()
    begin
        if not IsNotificationEnabled() then
            exit;

        // SendGetStartedNotification();
    end;

    procedure DisableNotificationAction(Notification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.Disable(NotificationIDLbl);
    end;

    procedure GetStartedVideoAction(GettingStartedNotification: Notification)
    begin
        PAGE.RunModal(PAGE::"NPR Getting Started");
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup Act - Scenarios", 'OnOpenPageEvent', '', false, false)]
    local procedure SendNotificationOnEvent()
    begin
        SendOrRecallGetStartedNotification();
    end;

    local procedure IsNotificationEnabled(): Boolean
    var
        MyNotifications: Record "My Notifications";
    begin
        exit(MyNotifications.IsEnabled(NotificationIDLbl));
    end;

    [EventSubscriber(ObjectType::Page, Page::"My Notifications", 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure "MyNotifications.OnInitializingNotificationWithDefaultState"()
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefaultWithTableNum(NotificationIDLbl,
                                                GetStartedMyNotificationMsg,
                                                GetStartedNotificationDescription,
                                                0);
    end;

    var
        NotificationIDLbl: Label '637ad99b-140d-4f2a-a865-e1b275c0a2a6', Locked = true;
        GetStartedMyNotificationMsg: Label 'Get Started Guide';
        GetStartedNotificationDescription: Label 'Show reminder to watch get started guide';
}