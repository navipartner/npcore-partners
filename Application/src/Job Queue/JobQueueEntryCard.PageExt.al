pageextension 6014424 "NPR Job Queue Entry Card" extends "Job Queue Entry Card"
{
    layout
    {
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
        }
    }
}