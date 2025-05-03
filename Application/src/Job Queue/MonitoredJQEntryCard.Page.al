page 6185042 "NPR Monitored JQ Entry Card"
{
    UsageCategory = None;
    Caption = 'Monitored Job Queue Entry';
    PageType = Card;
    SourceTable = "NPR Monitored Job Queue Entry";
    DataCaptionFields = "Object Type to Run", "Object Caption to Run";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    Extensible = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Object Type to Run"; Rec."Object Type to Run")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the type of the object, report or codeunit, that is to be run for the job queue entry. After you specify a type, you then select an object ID of that type in the Object ID to Run field.';
                }
                field("Object ID to Run"; Rec."Object ID to Run")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the ID of the object that is to be run for this job. You can select an ID that is of the object type that you have specified in the Object Type to Run field.';
                }
                field("Object Caption to Run"; Rec."Object Caption to Run")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the name of the object that is selected in the Object ID to Run field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies a description of the job queue entry. You can edit and update the description on the job queue entry card. The description is also displayed in the Job Queue Entries window, but it cannot be updated there.';
                }
                field("Parameter String"; Rec."Parameter String")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies a text string that is used as a parameter by the job queue when it is run.';
                }
                field("Job Queue Category Code"; Rec."Job Queue Category Code")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the code of the job queue category to which the job queue entry belongs. Choose the field to select a code from the list.';
                }
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
                field("Priority Within Category"; Rec."Priority Within Category")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the priority of the job within the job queue category. Only relevant when job queue category code is specified.';
                    Enabled = (Rec."Job Queue Category Code" <> '');
                }
#endif
                field("NPR Entra App User Name"; Rec."NPR Entra App User Name")
                {
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                    ToolTip = 'Specifies the JQ Runner User Name to be used by an External Job Queue Refresher.';
                }
                field("Maximum No. of Attempts to Run"; Rec."Maximum No. of Attempts to Run")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies how many times a job queue task should be rerun after a job queue fails to run. This is useful for situations in which a task might be unresponsive. For example, a task might be unresponsive because it depends on an external resource that is not always available.';
                }
                field("Rerun Delay (sec.)"; Rec."Rerun Delay (sec.)")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies how many seconds to wait before re-running this job queue task in the event of a failure.';
                }
                field(Timeout; Rec."Job Timeout")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the maximum time that the job queue entry is allowed to run.';
                }
                field("NPR Notif. Profile on Error"; Rec."Notif. Profile on Error")
                {
                    ToolTip = 'Specifies a notification profile system should use, when the status of the job queue entry is set to "Error"';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field("NPR Auto-Resched. after Error"; Rec."NPR Auto-Resched. after Error")
                {
                    ToolTip = 'Specifies whether system should automatically reschedule the job queue entry for the next run, in cases when the status of the job queue entry has been set to "Error"';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field("NPR Auto-Resched. Delay (sec.)"; Rec."NPR Auto-Resched. Delay (sec.)")
                {
                    Enabled = Rec."NPR Auto-Resched. after Error";
                    Editable = false;
                    ToolTip = 'Specifies how many seconds to wait before re-running this job queue entry, in cases when you want the job to be automatically rescheduled after status "Error"';
                    ApplicationArea = NPRRetail;
                }
                field("NP Managed Job"; Rec."NP Managed Job")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'NP Managed Job';
                    ToolTip = 'Specifies whether this Job Queue entry is allowed to be managed by the NP Refresher functionality.';
                    Editable = false;
                }
                field("NPR Heartbeat URL"; Rec."NPR Heartbeat URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the URL of where to send a heartbeat on Job Queue''s successful execution.';
                }
            }
            group("Report Parameters")
            {
                Caption = 'Report Parameters';
                Visible = Rec."Object Type to Run" = Rec."Object Type to Run"::Report;
                field("Report Request Page Options"; Rec."Report Request Page Options")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies whether options on the report request page have been set for scheduled report job. If the check box is selected, then options have been set for the scheduled report.';
                }
                field("Report Output Type"; Rec."Report Output Type")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the output of the scheduled report.';
                }
                field("Printer Name"; Rec."Printer Name")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the printer to use to print the scheduled report.';
                }
            }
            group(Recurrence)
            {
                Caption = 'Recurrence';
                field("Recurring Job"; Rec."Recurring Job")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies if the job queue entry is recurring. If the Recurring Job check box is selected, then the job queue entry is recurring. If the check box is cleared, the job queue entry is not recurring. After you specify that a job queue entry is a recurring one, you must specify on which days of the week the job queue entry is to run. Optionally, you can also specify a time of day for the job to run and how many minutes should elapse between runs.';
                }
                field("Run on Mondays"; Rec."Run on Mondays")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies that the job queue entry runs on Mondays.';
                }
                field("Run on Tuesdays"; Rec."Run on Tuesdays")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies that the job queue entry runs on Tuesdays.';
                }
                field("Run on Wednesdays"; Rec."Run on Wednesdays")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies that the job queue entry runs on Wednesdays.';
                }
                field("Run on Thursdays"; Rec."Run on Thursdays")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies that the job queue entry runs on Thursdays.';
                }
                field("Run on Fridays"; Rec."Run on Fridays")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies that the job queue entry runs on Fridays.';
                }
                field("Run on Saturdays"; Rec."Run on Saturdays")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies that the job queue entry runs on Saturdays.';
                }
                field("Run on Sundays"; Rec."Run on Sundays")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies that the job queue entry runs on Sundays.';
                }
                field("Next Run Date Formula"; Rec."Next Run Date Formula")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the date formula that is used to calculate the next time the recurring job queue entry will run. If you use a date formula, all other recurrence settings are cleared.';
                }
                field("Starting Time"; Rec."Starting Time")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the earliest time of the day that the recurring job queue entry is to be run.';
                }
                field("Ending Time"; Rec."Ending Time")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the latest time of the day that the recurring job queue entry is to be run.';
                }
                field("No. of Minutes between Runs"; Rec."No. of Minutes between Runs")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the minimum number of minutes that are to elapse between runs of a job queue entry. The value cannot be less than one minute. This field only has meaning if the job queue entry is set to be a recurring job. If you use a no. of minutes between runs, the date formula setting is cleared.';
                }
                field("Inactivity Timeout Period"; Rec."Inactivity Timeout Period")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    MinValue = 5;
                    ToolTip = 'Specifies the number of minutes that pass before a recurring job that has the status On Hold With Inactivity Timeout is automatically restated. The value cannot be less than five minutes.';
                }
                label(Control33)
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ShowCaption = false;
                    Caption = '';
                }
                label(Control31)
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ShowCaption = false;
                    Caption = '';
                }
                label(Control22)
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ShowCaption = false;
                    Caption = '';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = NPRRetail;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = NPRRetail;
                Visible = false;
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            group("Job Queue")
            {
                action("Job Queue Entry Card")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Job Queue Entry Card';
                    Image = Card;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Open related Job Queue entry card.';

                    trigger OnAction()
                    var
                        JobQueueEntry: Record "Job Queue Entry";
                        MonitoredJQMgt: Codeunit "NPR Monitored Job Queue Mgt.";
                    begin
                        if not MonitoredJQMgt.FindJQEntry(Rec, JobQueueEntry) then
                            exit;

                        Page.Run(PAGE::"Job Queue Entry Card", JobQueueEntry);
                    end;
                }
            }
        }
    }
}
