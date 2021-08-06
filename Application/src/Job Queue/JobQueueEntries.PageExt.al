pageextension 6014413 "NPR Job Queue Entries" extends "Job Queue Entries"
{
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