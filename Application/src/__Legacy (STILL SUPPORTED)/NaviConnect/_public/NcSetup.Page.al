page 6151500 "NPR Nc Setup"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Caption = 'NaviConnect Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "NPR Nc Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRNaviConnect;

    layout
    {
        area(content)
        {
            field("Keep Tasks for"; Rec."Keep Tasks for")
            {

                ToolTip = 'Specifies the value of the Keep Tasks for field';
                ApplicationArea = NPRNaviConnect;
            }
            group(General)
            {
                Caption = 'General';
                field("Max Task Count per Batch"; Rec."Max Task Count per Batch")
                {

                    ToolTip = 'Specifies the value of the Max Task Count per batch field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
            field("Task Worker Group"; Rec."Task Worker Group")
            {

                ToolTip = 'Specifies the value of the Task Worker Group field';
                ApplicationArea = NPRNaviConnect;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Setup Job Queue")
            {
                Caption = 'Setup Job Queue';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = NPRNaviConnect;
                ToolTip = 'Sets up Job Queue Entry for Task List Processing';

                trigger OnAction()
                var
                    JobQueueEntry: Record "Job Queue Entry";
                    NaviConnectMgt: Codeunit "NPR Nc Setup Mgt.";
                begin
                    CurrPage.SaveRecord();
                    NaviConnectMgt.SetupTaskProcessingJobQueue(JobQueueEntry, false);
                    if not IsNullGuid(JobQueueEntry.ID) then
                        Page.Run(Page::"Job Queue Entry Card", JobQueueEntry);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        NaviConnectMgt: Codeunit "NPR Nc Setup Mgt.";
    begin
        Rec.Reset();
        if not Rec.Get() then
            NaviConnectMgt.InitNaviConnectSetup();
    end;
}
