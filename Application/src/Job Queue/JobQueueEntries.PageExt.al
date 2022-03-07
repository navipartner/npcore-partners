pageextension 6014413 "NPR Job Queue Entries" extends "Job Queue Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("NPR Notify On Success"; Rec."Notify On Success")
            {
                ToolTip = 'Specifies the value of the Notify On Success field.';
                ApplicationArea = NPRetail;
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
        }
    }

    actions
    {
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
        }
    }
}