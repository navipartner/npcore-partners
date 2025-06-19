page 6185041 "NPR Monitored JQ Entries"
{
    Extensible = false;
    UsageCategory = None;
    Caption = 'Monitored Jobs';
    PageType = ListPart;
    SourceTable = "NPR Monitored Job Queue Entry";
    InsertAllowed = false;
    DeleteAllowed = true;
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
                field("JQ Runner User Name"; Rec."JQ Runner User Name")
                {
                    ApplicationArea = NPRRetail;
                    Visible = _ExternalJQRefresherIsEnabled;
                    ToolTip = 'Specifies the JQ Runner User Name.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ExternalJQRefresherMgt: Codeunit "NPR External JQ Refresher Mgt.";
                    begin
                        exit(ExternalJQRefresherMgt.LookupJQRefresherUserName(Text));
                    end;
                }
                field("NP Managed Job"; _IsProtectedJob)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'NP Protected Job';
                    ToolTip = 'Specifies whether this is a NaviPartner protected job.';
                    Editable = false;
                }
                field("Parameter String"; Rec."Parameter String")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Parameter String.';
                    Editable = false;
                }
                field("Job Queue Category Code"; Rec."Job Queue Category Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Category Code.';
                    Editable = false;
                    Visible = false;
                }
                field("Starting Time"; Rec."Starting Time")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Starting Time.';
                    Editable = false;
                    Visible = false;
                }
                field("Ending Time"; Rec."Ending Time")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Ending Time.';
                    Editable = false;
                    Visible = false;
                }
                field("No. of Minutes between Runs"; Rec."No. of Minutes between Runs")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the No. of Minutes between Runs.';
                    Editable = false;
                    Visible = false;
                }
                field("Maximum No. of Attempts to Run"; Rec."Maximum No. of Attempts to Run")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Maximum No. of Attempts to Run.';
                    Editable = false;
                    Visible = false;
                }
                field("Last Refresh Status"; Rec."Last Refresh Status")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the status of the last refresh attempt of the monitored job.';
                    Editable = false;
                }
                field("Last Error Message"; Rec.GetErrorMessage(false))
                {
                    Caption = 'Last Error Message';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the error message, if the last refresh attempt failed.';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Message(Rec.GetErrorMessage(true));
                    end;
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
                Tooltip = 'This action will recreate the list of monitored jobs to ensure that all NaviParter protected jobs and any custom job queues manually marked as ''Monitored Job'' are included and properly monitored by the refresher.';

                trigger OnAction()
                var
                    MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
                    ConfirmLbl: Label 'This action will recreate all Monitored Jobs.\Do you want to continue?';
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
            action(New)
            {
                ApplicationArea = NPRRetail;
                Caption = 'New';
                Image = CreateDocument;
                ToolTip = 'Create a new custom monitored job from scratch.';

                trigger OnAction()
                begin
                    _MonitoredJQMgt.ManuallyCreateNewMonitoredJQEntry();
                    CurrPage.Update(false);
                end;
            }
            action(Edit)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Edit';
                Image = Edit;
                ToolTip = 'Edit monitored job.';

                trigger OnAction()
                begin
                    _MonitoredJQMgt.ManuallyModifyExistingMonitoredJQEntry(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        JQRefresherSetup: Record "NPR Job Queue Refresh Setup";
    begin
        JQRefresherSetup.GetSetup();
        _ExternalJQRefresherIsEnabled := JQRefresherSetup."Use External JQ Refresher";
    end;

    trigger OnAfterGetRecord()
    var
        TempJQEntry: Record "Job Queue Entry" temporary;
    begin
        TempJQEntry.Transferfields(Rec);
        _IsProtectedJob := _MonitoredJQMgt.IsNPProtectedJob(TempJQEntry);
    end;

    var
        _MonitoredJQMgt: Codeunit "NPR Monitored Job Queue Mgt.";
        _ExternalJQRefresherIsEnabled: Boolean;
        _IsProtectedJob: Boolean;
}