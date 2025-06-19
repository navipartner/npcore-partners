pageextension 6014424 "NPR Job Queue Entry Card" extends "Job Queue Entry Card"
{
    layout
    {
        modify("Starting Time")
        {
            trigger OnAfterValidate()
            begin
                SetShowTimeZone();
            end;
        }
        modify("Ending Time")
        {
            trigger OnAfterValidate()
            begin
                SetShowTimeZone();
            end;
        }
        addlast(General)
        {
            field("NPR Notif. Profile on Error"; Rec."NPR Notif. Profile on Error")
            {
                ToolTip = 'Specifies a notification profile system should use, when the status of the job queue entry is set to "Error"';
                ApplicationArea = NPRRetail;
            }
            field("NPR Auto-Resched. after Error"; Rec."NPR Auto-Resched. after Error")
            {
                ToolTip = 'Specifies whether system should automatically reschedule the job queue entry for the next run, in cases when the status of the job queue entry has been set to "Error"';
                ApplicationArea = NPRRetail;
            }
            field("NPR Auto-Resched. Delay (sec.)"; Rec."NPR Auto-Resched. Delay (sec.)")
            {
                Enabled = Rec."NPR Auto-Resched. after Error";
                ToolTip = 'Specifies how many seconds to wait before re-running this job queue entry, in cases when you want the job to be automatically rescheduled after status "Error"';
                ApplicationArea = NPRRetail;
            }
            field("NPR Manually Set On Hold"; Rec."NPR Manually Set On Hold")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies whether the job queue entry was manually set on hold.';
            }
            field("NPR Managed by App"; _ManagedByApp)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Monitored Job';
                ToolTip = 'Specifies whether this Job Queue entry is monitored by the NP Refresher functionality.';
                Editable = _RefreshingCanBeToggled;

                trigger OnValidate()
                var
                    ManagedByAppJobQueue: Record "NPR Managed By App Job Queue";
                    MonitoredJQMgt: Codeunit "NPR Monitored Job Queue Mgt.";
                begin
                    CurrPage.SaveRecord();
                    Commit();
                    if not _ManagedByApp then begin
                        if ManagedByAppJobQueue.Get(Rec.ID) then
                            ManagedByAppJobQueue.Delete();
                        MonitoredJQMgt.RemoveMonitoredJobQueueEntry(Rec);
                    end else
                        MonitoredJQMgt.AssignJobQueueEntryToManagedAndMonitored(true, true, Rec);
                    CurrPage.Update(false);
                end;
            }
            field("NPR Heartbeat URL"; Rec."NPR Heartbeat URL")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the URL of where to send a heartbeat on Job Queue''s successful execution.';
            }
        }
        addafter("Ending Time")
        {
            group("NPR TimeZone")
            {
                ShowCaption = false;
                Visible = _ShowTimeZone;

                field("NPR Time Zone"; Rec.GetTimeZoneName())
                {
                    Caption = 'Time Zone';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the time zone in which the job queue entry run window has been set up. The "Starting Time" and "Ending Time" fields are displayed in this time zone.';
                    Editable = false;
                }
            }
        }
    }
    actions
    {
        modify("Set On Hold")
        {
            Visible = not _NPRRetailAppAreaEnabled;
            Enabled = not _NPRRetailAppAreaEnabled;
        }
#if not (BC17 or BC18 or BC19 or BC20)
        modify("Set On Hold_Promoted")
        {
            Visible = not _NPRRetailAppAreaEnabled;
        }
#endif
        addafter("Set On Hold")
        {
            action("NPR Suspend")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Set On Hold';
                Image = Pause;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedCategory = Process;
#endif
                ToolTip = 'Change the status of the entry.';
                Visible = _NPRRetailAppAreaEnabled;

                trigger OnAction()
                var
                    UpdateJQOnHoldStatus: Codeunit "NPR Update JQ OnHold Status";
                begin
                    BindSubscription(UpdateJQOnHoldStatus);
                    Rec.SetStatus(Rec.Status::"On Hold");
                    UnbindSubscription(UpdateJQOnHoldStatus);
                    RecallModifyOnlyWhenReadOnlyNotification();
                end;
            }
        }
#if not (BC17 or BC18 or BC19 or BC20)
        addafter("Set On Hold_Promoted")
        {
            actionref("NPR Suspend_Promoted"; "NPR Suspend") { }
        }
#endif
    }

    trigger OnOpenPage()
    var
        EnableApplicationAreas: Codeunit "NPR Enable Application Areas";
    begin
        _NPRRetailAppAreaEnabled := EnableApplicationAreas.IsNPRRetailApplicationAreaEnabled();
    end;

    trigger OnAfterGetCurrRecord()
    var
        JobQueueManagement: Codeunit "NPR Job Queue Management";
    begin
        _ManagedByApp := JobQueueManagement.JobQueueIsManagedByApp(Rec, _RefreshingCanBeToggled);
        SetShowTimeZone();
    end;

    local procedure SetShowTimeZone()
    begin
        _ShowTimeZone := (Rec."Starting Time" <> 0T) or (Rec."Ending Time" <> 0T);
    end;

    local procedure RecallModifyOnlyWhenReadOnlyNotification()
    var
        ModifyOnlyWhenReadOnlyNotification: Notification;
    begin
        ModifyOnlyWhenReadOnlyNotification.Id := GetModifyOnlyWhenReadOnlyNotificationId();
        ModifyOnlyWhenReadOnlyNotification.Recall();
    end;

    local procedure GetModifyOnlyWhenReadOnlyNotificationId(): Guid
    var
        ModifyOnlyWhenReadOnlyNotificationId: Guid;
        ModifyOnlyWhenReadOnlyNotificationIdTxt: Label '509FD112-31EC-4CDC-AEBF-19B8FEBA526F', Locked = true;
    begin
        Evaluate(ModifyOnlyWhenReadOnlyNotificationId, ModifyOnlyWhenReadOnlyNotificationIdTxt);
        exit(ModifyOnlyWhenReadOnlyNotificationId);
    end;

    var
        _NPRRetailAppAreaEnabled: Boolean;
        _ManagedByApp: Boolean;
        _RefreshingCanBeToggled: Boolean;
        _ShowTimeZone: Boolean;
}