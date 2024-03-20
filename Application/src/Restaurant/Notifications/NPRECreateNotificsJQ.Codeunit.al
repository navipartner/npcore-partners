codeunit 6184778 "NPR NPRE Create Notifics JQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        CreateDelayedOrderNotifications();
    end;

    local procedure CreateDelayedOrderNotifications()
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        NotificationEntry: Record "NPR NPRE Notification Entry";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NotificationHandler: Codeunit "NPR NPRE Notification Handler";
        NotifTrigger: Enum "NPR NPRE Notification Trigger";
        ResendDelay: Duration;
        Threshold1: DateTime;
        Threshold2: DateTime;
        CreateNotification: Boolean;
    begin
        if not RestaurantSetup.Get() or ((RestaurantSetup."Delayed Ord. Threshold 1 (min)" <= 0) and (RestaurantSetup."Delayed Ord. Threshold 2 (min)" <= 0)) then
            exit;

        ResendDelay := JobQueueMgt.MinutesToDuration(RestaurantSetup."Notif. Resend Delay (min)");

        KitchenOrder.SetRange("Order Status", KitchenOrder."Order Status"::"In-Production", KitchenOrder."Order Status"::Planned);
        KitchenOrder.SetRange("On Hold", false);
        if RestaurantSetup."Delayed Ord. Threshold 1 (min)" > 0 then
            Threshold1 := CurrentDateTime() - JobQueueMgt.MinutesToDuration(RestaurantSetup."Delayed Ord. Threshold 1 (min)");
        if RestaurantSetup."Delayed Ord. Threshold 2 (min)" > 0 then
            Threshold2 := CurrentDateTime() - JobQueueMgt.MinutesToDuration(RestaurantSetup."Delayed Ord. Threshold 2 (min)");
        if Threshold1 <> 0DT then
            KitchenOrder.SetFilter("Created Date-Time", '<%1', Threshold1)
        else
            KitchenOrder.SetFilter("Created Date-Time", '<%1', Threshold2);

        if KitchenOrder.FindSet() then
            repeat
                NotifTrigger := NotifTrigger::" ";
                if (KitchenOrder."Created Date-Time" <= Threshold2) and (Threshold2 <> 0DT) then
                    NotifTrigger := NotifTrigger::KDS_ORDER_DELAYED_2
                else
                    if Threshold1 <> 0DT then
                        NotifTrigger := NotifTrigger::KDS_ORDER_DELAYED_1;

                if NotifTrigger <> NotifTrigger::" " then begin
                    CreateNotification := not NotificationHandler.FindLastOrderDelayedNotification(KitchenOrder."Order ID", NotificationEntry);
                    if not CreateNotification then
                        CreateNotification :=
                            (NotificationEntry."Notification Trigger".AsInteger() < NotifTrigger.AsInteger()) or
                            ((CurrentDateTime() > NotificationEntry.SystemCreatedAt + ResendDelay) and (ResendDelay > 0));
                    if CreateNotification then begin
                        NotificationHandler.CreateOrderNotifications(KitchenOrder, NotifTrigger, 0DT);
                        Commit();
                    end;
                end;
            until KitchenOrder.Next() = 0;
    end;
}