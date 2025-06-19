pageextension 6014413 "NPR Job Queue Entries" extends "Job Queue Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("NPR Notify On Success"; Rec."Notify On Success")
            {
                ToolTip = 'Specifies the value of the Notify On Success field.';
                ApplicationArea = NPRRetail;
            }
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
                ToolTip = 'Specifies how many seconds to wait before re-running this job queue entry, in cases when you want the job to be automatically rescheduled after status "Error"';
                ApplicationArea = NPRRetail;
            }
            field("NPR Manually Set On Hold"; Rec."NPR Manually Set On Hold")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies whether the job queue entry was manually set on hold.';
            }
        }
    }

    actions
    {
        modify(Suspend)
        {
            Visible = not NPRRetailAppAreaEnabled;
            Enabled = not NPRRetailAppAreaEnabled;
        }
#if not (BC17 or BC18 or BC19 or BC20)
        modify(Suspend_Promoted)
        {
            Visible = not NPRRetailAppAreaEnabled;
        }
#endif
        addafter(Suspend)
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
                ToolTip = 'Change the status of the selected entry.';
                Visible = NPRRetailAppAreaEnabled;

                trigger OnAction()
                var
                    UpdateJQOnHoldStatus: Codeunit "NPR Update JQ OnHold Status";
                begin
                    BindSubscription(UpdateJQOnHoldStatus);
                    Rec.SetStatus(Rec.Status::"On Hold");
                    UnbindSubscription(UpdateJQOnHoldStatus);
                end;
            }
        }
#if not (BC17 or BC18 or BC19 or BC20)
        addafter(Suspend_Promoted)
        {
            actionref("NPR Suspend_Promoted"; "NPR Suspend") { }
        }
#endif
        addlast(Action15)
        {
            action("NPR AddLogCleanupJob")
            {
                Caption = 'Add Log Cleanup Job';
                ToolTip = 'Adds a new job, responsible for purging outdated (older than 30 days) Joq Queue Log entries';
                Image = AddAction;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    JobQueueEntry: Record "Job Queue Entry";
                    CleanupJQLog: Codeunit "NPR Cleanup JQ Log Entries";
                begin
                    if CleanupJQLog.AddJQLogCleanupJob(JobQueueEntry, false) then begin
                        Rec := JobQueueEntry;
                        if Rec.Find() then
                            Page.Run(Page::"Job Queue Entry Card", Rec);
                    end;
                end;
            }
            action("NPR RefreshList")
            {
                Caption = 'NPR Refresh List';
                ToolTip = 'Refreshes the list of NP Retail related job queue entries.';
                Image = RefreshLines;
                ApplicationArea = NPRRetail;
                Visible = false;

                trigger OnAction()
                var
                    JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
                    UserPersonalization: Record "User Personalization";
                    JobQueueMgt: Codeunit "NPR Job Queue Management";
                    ConfirmQst: Label 'The action is going to refresh the list of NP Retail related job queue entries. As a result, some of currently existing job queue entries may be deleted or modified, and new entries may be added.\Are you absolutely sure you want to proceed with the action?';
                    WrongTimeZoneErr: Label 'Before running this function, please change your time zone to "%1". This must match the time zone selected on the Job Queue Refresh Setup page.';
                begin
                    if not Confirm(ConfirmQst, false) then
                        exit;
                    if not JQRefreshSetup.Get() then
                        Clear(JQRefreshSetup);
                    JQRefreshSetup.TestField("Default Job Time Zone");
                    if not UserPersonalization.Get(UserSecurityId()) then
                        Clear(UserPersonalization);
                    if UserPersonalization."Time Zone" <> JQRefreshSetup."Default Job Time Zone" then
                        Error(WrongTimeZoneErr, JQRefreshSetup.GetTimeZoneName());
                    JobQueueMgt.RefreshNPRJobQueueList(true);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        EnableApplicationAreas: Codeunit "NPR Enable Application Areas";
    begin
        NPRRetailAppAreaEnabled := EnableApplicationAreas.IsNPRRetailApplicationAreaEnabled();
    end;

    var
        NPRRetailAppAreaEnabled: Boolean;
}