page 6185041 "NPR Monitored JQ Entries"
{
    Extensible = false;
    UsageCategory = None;
    Caption = 'Monitored Job Queue Entries';
    PageType = ListPart;
    SourceTable = "NPR Monitored Job Queue Entry";
    CardPageId = "NPR Monitored JQ Entry Card";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Object Type to Run"; Rec."Object Type to Run")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Object Type to Run.';
                    Editable = false;
                }
                field("Object ID to Run"; Rec."Object ID to Run")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Object ID to Run.';
                    Editable = false;
                }
                field("Object Caption to Run"; Rec."Object Caption to Run")
                {
                    ApplicationArea = NPRRetail;
                    Tooltip = 'Specifies the Object Caption to Run';
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Description.';
                    Editable = false;
                }
                field("NPR Entra App User Name"; Rec."NPR Entra App User Name")
                {
                    ApplicationArea = NPRRetail;
                    Visible = _ExternalJQRefresherIsEnabled;
                    ToolTip = 'Specifies the JQ Runner User Name.';
                }
                field("NP Managed Job"; Rec."NP Managed Job")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'NP Managed Job';
                    ToolTip = 'Specifies whether this Job Queue entry is allowed to be managed by the NP Refresher functionality.';
                    Editable = false;
                }
                field("Parameter String"; Rec."Parameter String")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Parameter String.';
                    Editable = false;
                }
                field("No. of Minutes between Runs"; Rec."No. of Minutes between Runs")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the No. of Minutes between Runs.';
                    Editable = false;
                }
                field("Job Queue Category Code"; Rec."Job Queue Category Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Category Code.';
                    Editable = false;
                }
                field("Maximum No. of Attempts to Run"; Rec."Maximum No. of Attempts to Run")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Maximum No. of Attempts to Run.';
                    Editable = false;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Entry No.';
                    Editable = false;
                }
            }
        }

    }
    actions
    {
        area(Processing)
        {
            action("Recreate Monitored Jobs")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Recreate Monitored Jobs';
                Image = RefreshLines;
                Tooltip = 'This action will recreate the list of monitored job queue entries to ensure that all mandatory NaviParter job queues and any custom job queues manually marked as ''Managed by App'' are included and properly monitored by the refresher.';

                trigger OnAction()
                var
                    MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
                    ConfirmLbl: Label 'This action will recreate all Monitored Job Queue entries.\Do you want to continue?';
                begin
                    if Confirm(ConfirmLbl) then begin
                        MonitoredJobQueueMgt.RecreateMonitoredJobQueueEntries();
                        CurrPage.Update(false);
                    end;
                end;
            }
            action("Job Queue Entry Card")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Job Queue Entry Card';
                Image = Card;
                ToolTip = 'Open related Job Queue entry card.';

                trigger OnAction()
                var
                    JobQueueEntry: Record "Job Queue Entry";
                begin
                    if not _MonitoredJQMgt.FindJQEntry(Rec, JobQueueEntry) then
                        exit;

                    Page.Run(PAGE::"Job Queue Entry Card", JobQueueEntry);
                end;
            }
            action("Add Custom Job Queue Entry")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Add Custom Job Queue Entry';
                Image = Add;
                ToolTip = 'Select a custom job queue entry from the full list to add it to the monitored jobs.';

                trigger OnAction()
                var
                    JobQueueEntry: Record "Job Queue Entry";
                begin
                    if _MonitoredJQMgt.LookUpJobQueues(JobQueueEntry) then
                        CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        JQRefresherSetup: Record "NPR Job Queue Refresh Setup";
    begin
        if JQRefresherSetup.Get() then
            _ExternalJQRefresherIsEnabled := JQRefresherSetup."Use External JQ Refresher";
    end;

    var
        _ExternalJQRefresherIsEnabled: Boolean;
        _MonitoredJQMgt: Codeunit "NPR Monitored Job Queue Mgt.";
}