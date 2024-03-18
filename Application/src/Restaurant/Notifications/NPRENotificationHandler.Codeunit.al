codeunit 6184777 "NPR NPRE Notification Handler"
{
    Access = Internal;

    internal procedure CreateOrderNotifications(KitchenOrder: Record "NPR NPRE Kitchen Order"; NotificationTrigger: Enum "NPR NPRE Notification Trigger"; NotifyAt: DateTime)
    var
        NotificationSetup: Record "NPR NPRE Notification Setup";
    begin
        NotificationSetup."Notification Trigger" := NotificationTrigger;
        NotificationSetup."Restaurant Code" := KitchenOrder."Restaurant Code";
        if not GetNotificationSetup(NotificationSetup) then
            exit;
        repeat
            if NotificationSetup."Sms Notification" then
                ScheduleNotification("NPR NPRE Notification Method"::SMS, NotificationSetup, KitchenOrder."Order ID", 0, NotifyAt);
            if NotificationSetup."E-Mail Notification" then
                ScheduleNotification("NPR NPRE Notification Method"::EMAIL, NotificationSetup, KitchenOrder."Order ID", 0, NotifyAt);
        until NotificationSetup.Next() = 0;
    end;

    local procedure GetNotificationSetup(var NotificationSetup: Record "NPR NPRE Notification Setup"): Boolean
    begin
        NotificationSetup.SetRange("Notification Trigger", NotificationSetup."Notification Trigger");
        NotificationSetup.SetRange("Restaurant Code", NotificationSetup."Restaurant Code");
        if NotificationSetup."Production Restaurant Code" <> '' then
            NotificationSetup.SetFilter("Production Restaurant Code", '%1|%2', '', NotificationSetup."Production Restaurant Code")
        else
            NotificationSetup.SetRange("Production Restaurant Code", '');
        if NotificationSetup."Kitchen Station" <> '' then
            NotificationSetup.SetFilter("Kitchen Station", '%1|%2', '', NotificationSetup."Kitchen Station")
        else
            NotificationSetup.SetRange("Kitchen Station", '');
        if NotificationSetup.IsEmpty() and (NotificationSetup."Restaurant Code" <> '') then begin
            NotificationSetup."Restaurant Code" := '';
            exit(GetNotificationSetup(NotificationSetup));
        end;
        exit(NotificationSetup.FindSet());
    end;

    local procedure ScheduleNotification(Method: Enum "NPR NPRE Notification Method"; NotificationSetup: Record "NPR NPRE Notification Setup"; KitchenOrderID: BigInteger; KitchenRequestID: BigInteger; NotifyAt: DateTime): Boolean
    var
        NotificationEntry: Record "NPR NPRE Notification Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NotificationAddresses: List of [Text[100]];
        NotificationAddress: Text[100];
    begin
        if not (((Method = Method::SMS) and NotificationSetup."Sms Notification") or ((Method = Method::EMAIL) and NotificationSetup."E-Mail Notification")) then
            exit(false);
        if NotifyAt = 0DT then
            NotifyAt := CurrentDateTime();

        NotificationEntry.Init();
        NotificationEntry."Notification Send Status" := NotificationEntry."Notification Send Status"::PENDING;
        NotificationEntry."Kitchen Order ID" := KitchenOrderID;
        NotificationEntry."Kitchen Request No." := KitchenRequestID;
        NotificationEntry."Setup Entry No." := NotificationSetup."Entry No.";
        NotificationEntry."Notification Trigger" := NotificationSetup."Notification Trigger";
        NotificationEntry."Notify at Date-Time" := NotifyAt;
        if NotificationSetup."Notification Expires in (sec.)" > 0 then
            NotificationEntry."Expires at Date-Time" := JobQueueMgt.NowWithDelayInSeconds(NotificationSetup."Notification Expires in (sec.)");
        NotificationEntry."Notification Method" := Method;
        NotificationEntry.Recipient := NotificationSetup.Recipient;
        case Method of
            Method::SMS:
                NotificationEntry."Notification Template" := NotificationSetup."Sms Notif. Template";
            Method::EMAIL:
                NotificationEntry."Notification Template" := NotificationSetup."E-Mail Notif. Template";
        end;
        GetNotificationAddresses(NotificationEntry, NotificationSetup, NotificationAddresses);
        if NotificationAddresses.Count() = 0 then begin
            NotificationEntry."Notification Address" := '';
            InsertNotificationEntry(NotificationEntry);
        end else
            foreach NotificationAddress in NotificationAddresses do begin
                NotificationEntry."Notification Address" := NotificationAddress;
                InsertNotificationEntry(NotificationEntry);
            end;
    end;

    local procedure InsertNotificationEntry(var NotificationEntry: Record "NPR NPRE Notification Entry")
    begin
        NotificationEntry."Entry No." := 0;
        NotificationEntry.Insert();
    end;

    local procedure GetNotificationAddresses(NotificationEntry: Record "NPR NPRE Notification Entry"; NotificationSetup: Record "NPR NPRE Notification Setup"; var NotificationAddresses: List of [Text[100]])
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        Salesperson: Record "Salesperson/Purchaser";
        UserSetup: Record "User Setup";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        KitchReqSrcbyDoc: Query "NPR NPRE Kitch.Req.Src. by Doc";
    begin
        Clear(NotificationAddresses);
        if NotificationEntry."Notification Method" = NotificationEntry."Notification Method"::NA then
            exit;
        case NotificationEntry.Recipient of
            NotificationEntry.Recipient::TEMPLATE:
                exit;  //Use default recipient from the template

            NotificationEntry.Recipient::CUSTOMER,
            NotificationEntry.Recipient::WAITER:
                begin
                    if (NotificationEntry."Kitchen Request No." = 0) and (NotificationEntry."Kitchen Order ID" = 0) then
                        exit;
                    if NotificationEntry."Kitchen Request No." <> 0 then
                        KitchenRequest.SetRange("Request No.", NotificationEntry."Kitchen Request No.")
                    else begin
                        KitchenRequest.SetCurrentKey("Order ID");
                        KitchenRequest.SetRange("Order ID", NotificationEntry."Kitchen Order ID");
                    end;
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
                    KitchenRequest.ReadIsolation := IsolationLevel::ReadUncommitted;
                    WaiterPad.ReadIsolation := IsolationLevel::ReadUncommitted;
#ENDIF
                    if KitchenRequest.FindSet() then
                        repeat
                            KitchReqSrcbyDoc.SetRange(Request_No_, KitchenRequest."Request No.");
                            KitchReqSrcbyDoc.SetFilter(QuantityBase, '<>%1', 0);
                            if KitchReqSrcbyDoc.Open() then begin
                                while KitchReqSrcbyDoc.Read() do
                                    case KitchReqSrcbyDoc.Source_Document_Type of
                                        KitchReqSrcbyDoc.Source_Document_Type::"Waiter Pad":
                                            begin
                                                WaiterPad."No." := KitchReqSrcbyDoc.Source_Document_No_;
                                                if not WaiterPad.Mark() then begin
                                                    if WaiterPad.Find() then begin
                                                        if NotificationEntry.Recipient = NotificationEntry.Recipient::CUSTOMER then begin
                                                            case NotificationEntry."Notification Method" of
                                                                NotificationEntry."Notification Method"::SMS:
                                                                    if WaiterPad."Customer Phone No." <> '' then
                                                                        if not NotificationAddresses.Contains(WaiterPad."Customer Phone No.") then
                                                                            NotificationAddresses.Add(WaiterPad."Customer Phone No.");
                                                                NotificationEntry."Notification Method"::EMAIL:
                                                                    if WaiterPad."Customer E-Mail" <> '' then
                                                                        if not NotificationAddresses.Contains(WaiterPad."Customer E-Mail") then
                                                                            NotificationAddresses.Add(WaiterPad."Customer E-Mail");
                                                            end;
                                                        end else
                                                            if Salesperson.Get(WaiterPad."Assigned Waiter Code") then
                                                                case NotificationEntry."Notification Method" of
                                                                    NotificationEntry."Notification Method"::SMS:
                                                                        if Salesperson."Phone No." <> '' then
                                                                            if not NotificationAddresses.Contains(Salesperson."Phone No.") then
                                                                                NotificationAddresses.Add(Salesperson."Phone No.");
                                                                    NotificationEntry."Notification Method"::EMAIL:
                                                                        if Salesperson."E-Mail" <> '' then
                                                                            if not NotificationAddresses.Contains(Salesperson."E-Mail") then
                                                                                NotificationAddresses.Add(Salesperson."E-Mail");
                                                                end;
                                                    end;
                                                    WaiterPad.Mark(true);
                                                end;
                                            end;
                                    end;
                                KitchReqSrcbyDoc.Close();
                            end;
                        until KitchenRequest.Next() = 0;
                end;

            NotificationEntry.Recipient::USER:
                begin
                    if NotificationSetup."User ID (Recipient)" = '' then
                        exit;
                    if not UserSetup.Get(NotificationSetup."User ID (Recipient)") then
                        exit;
                    case NotificationEntry."Notification Method" of
                        NotificationEntry."Notification Method"::SMS:
                            if UserSetup."Phone No." <> '' then
                                NotificationAddresses.Add(UserSetup."Phone No.");
                        NotificationEntry."Notification Method"::EMAIL:
                            if UserSetup."E-Mail" <> '' then
                                NotificationAddresses.Add(UserSetup."E-Mail");
                    end;
                end;
        end;
    end;

    internal procedure FindLastOrderDelayedNotification(OrderID: BigInteger; var NotificationEntry: Record "NPR NPRE Notification Entry"): Boolean
    begin
        FilterNotifEntryByOrderID(OrderID, NotificationEntry);
        NotificationEntry.SetRange("Notification Trigger", NotificationEntry."Notification Trigger"::KDS_ORDER_DELAYED_1, NotificationEntry."Notification Trigger"::KDS_ORDER_DELAYED_2);
        exit(NotificationEntry.FindLast());
    end;

    internal procedure FindLastOrderReadyNotification(OrderID: BigInteger; NotifRecipient: Enum "NPR NPRE Notif. Recipient"; var NotificationEntry: Record "NPR NPRE Notification Entry"): Boolean
    begin
        FilterNotifEntryByOrderID(OrderID, NotificationEntry);
        NotificationEntry.SetRange("Notification Trigger", NotificationEntry."Notification Trigger"::KDS_ORDER_READY_FOR_SERVING);
        NotificationEntry.SetRange(Recipient, NotifRecipient);
        exit(NotificationEntry.FindLast());
    end;

    local procedure FilterNotifEntryByOrderID(OrderID: BigInteger; var NotificationEntry: Record "NPR NPRE Notification Entry")
    begin
        Clear(NotificationEntry);
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        NotificationEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
#ENDIF
        NotificationEntry.SetRange("Kitchen Order ID", OrderID);
    end;

    internal procedure SetFailed(var NotificationEntry: Record "NPR NPRE Notification Entry"; ErrorMessageText: Text; AddCallStack: Boolean)
    var
        TypeHelper: Codeunit "Type Helper";
        OutStr: OutStream;
    begin
        NotificationEntry."Notification Send Status" := NotificationEntry."Notification Send Status"::FAILED;
        NotificationEntry."Sending Result Message" := CopyStr(ErrorMessageText, 1, MaxStrLen(NotificationEntry."Sending Result Message"));
        NotificationEntry."Sending Result Details".CreateOutStream(OutStr, TextEncoding::UTF8);
        if AddCallStack then
            OutStr.WriteText(ErrorMessageText + TypeHelper.CRLFSeparator() + GetLastErrorCallStack())
        else
            OutStr.WriteText(ErrorMessageText);
        NotificationEntry.Modify();
    end;

    internal procedure SetNotSent(var NotificationEntry: Record "NPR NPRE Notification Entry"; ErrorMessageText: Text)
    begin
        NotificationEntry."Notification Send Status" := NotificationEntry."Notification Send Status"::NOT_SENT;
        NotificationEntry."Sending Result Message" := CopyStr(ErrorMessageText, 1, MaxStrLen(NotificationEntry."Sending Result Message"));
        NotificationEntry.Modify();
    end;

    internal procedure SetSent(var NotificationEntry: Record "NPR NPRE Notification Entry")
    begin
        NotificationEntry."Notification Send Status" := NotificationEntry."Notification Send Status"::SENT;
        NotificationEntry."Sending Result Message" := '';
        NotificationEntry."Sent at" := CurrentDateTime();
        NotificationEntry."Sent By" := CopyStr(UserId(), 1, MaxStrLen(NotificationEntry."Sent By"));
        NotificationEntry.Modify();
    end;

    internal procedure CreateNotificationJobQueues(KDSActivated: Boolean)
    var
        NotificationSetup: Record "NPR NPRE Notification Setup";
        NotificationSetupExist: Boolean;
    begin
        if KDSActivated then begin
            NotificationSetup.SetRange("Notification Trigger", NotificationSetup."Notification Trigger"::KDS_ORDER_DELAYED_1, NotificationSetup."Notification Trigger"::KDS_ORDER_DELAYED_2);
            NotificationSetupExist := not NotificationSetup.IsEmpty();
        end;
        ToggleAutomaticNotifJob(KDSActivated and NotificationSetupExist);

        if KDSActivated and not NotificationSetupExist then begin
            NotificationSetup.Reset();
            NotificationSetupExist := not NotificationSetup.IsEmpty();
        end;
        ToggleSendNotifJob(KDSActivated and NotificationSetupExist);
    end;

    local procedure ToggleAutomaticNotifJob(EnableJob: Boolean)
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        JobQueueDescrLbl: Label 'Create restaurant delayed order notifications.';
    begin
        if EnableJob then
            EnableJob :=
                RestaurantSetup.Get() and
                ((RestaurantSetup."Delayed Ord. Threshold 1 (min)" <> 0) or (RestaurantSetup."Delayed Ord. Threshold 2 (min)" <> 0));
        AddRemoveJobQueueEntry(EnableJob, Codeunit::"NPR NPRE Create Notifics JQ", JobQueueDescrLbl);
    end;

    local procedure ToggleSendNotifJob(EnableJob: Boolean)
    var
        JobQueueDescrLbl: Label 'Send restaurant notifications.';
    begin
        AddRemoveJobQueueEntry(EnableJob, Codeunit::"NPR NPRE Send Notifications JQ", JobQueueDescrLbl);
    end;

    local procedure AddRemoveJobQueueEntry(EnableJob: Boolean; CodeunitID: Integer; JobQueueDescr: Text)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        if EnableJob then begin
            JobQueueMgt.SetJobTimeout(4, 0);
            JobQueueMgt.SetAutoRescheduleAndNotifyOnError(true, 600, '');  //Reschedule to run again in 10 minutes on error
            if JobQueueMgt.InitRecurringJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit,
                CodeunitID,
                '',
                JobQueueDescr,
                JobQueueMgt.NowWithDelayInSeconds(60),
                070000T,
                230000T,
                1,
                GetJobQueueCategoryCode(),
                JobQueueEntry)
            then
                JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
        end else
            if JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, CodeunitID) then
                JobQueueEntry.Cancel();
    end;

    local procedure GetJobQueueCategoryCode(): Code[10]
    var
        SmsMgt: Codeunit "NPR SMS Implementation";
    begin
        exit(SmsMgt.GetJobQueueCategoryCode());
    end;

    local procedure UpdateJobQueuesFromNotificationSetup(NotificationSetup: Record "NPR NPRE Notification Setup")
    var
        NotificationSetup2: Record "NPR NPRE Notification Setup";
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
    begin
        NotificationSetup2.SetFilter("Entry No.", '<>%1', NotificationSetup."Entry No.");
        if NotificationSetup2.IsEmpty() then begin
            if not SetupProxy.KDSActivatedForAnyRestaurant() then
                exit;
            CreateNotificationJobQueues(true);
            exit;
        end;

        NotificationSetup2.SetRange("Notification Trigger", NotificationSetup2."Notification Trigger"::KDS_ORDER_DELAYED_1, NotificationSetup2."Notification Trigger"::KDS_ORDER_DELAYED_2);
        if not NotificationSetup2.IsEmpty() then
            exit;
        if not SetupProxy.KDSActivatedForAnyRestaurant() then
            exit;
        CreateNotificationJobQueues(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure RefreshJobQueueEntries()
    var
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
    begin
        CreateNotificationJobQueues(SetupProxy.KDSActivatedForAnyRestaurant());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnCheckIfIsNPRecurringJob', '', false, false)]
    local procedure CheckIfIsNPRecurringJob(JobQueueEntry: Record "Job Queue Entry"; var IsNpJob: Boolean; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and
           (JobQueueEntry."Object ID to Run" in [Codeunit::"NPR NPRE Create Notifics JQ", Codeunit::"NPR NPRE Send Notifications JQ"])
        then begin
            IsNpJob := true;
            Handled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Notification Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateJobQueuesOnAfterNotificationSetupInsert(var Rec: Record "NPR NPRE Notification Setup")
    begin
        UpdateJobQueuesFromNotificationSetup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Notification Setup", 'OnAfterModifyEvent', '', false, false)]
    local procedure UpdateJobQueuesOnAfterNotificationSetupModify(var Rec: Record "NPR NPRE Notification Setup")
    begin
        UpdateJobQueuesFromNotificationSetup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Notification Setup", 'OnAfterDeleteEvent', '', false, false)]
    local procedure UpdateJobQueuesOnAfterNotificationSetupDelete(var Rec: Record "NPR NPRE Notification Setup")
    begin
        UpdateJobQueuesFromNotificationSetup(Rec);
    end;
}