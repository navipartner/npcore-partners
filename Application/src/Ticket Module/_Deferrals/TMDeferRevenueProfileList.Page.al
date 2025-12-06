page 6151477 "NPR TM DeferRevenueProfileList"
{
    Caption = 'Ticketing Defer Revenue Profile';
    PageType = List;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    UsageCategory = Administration;
    SourceTable = "NPR TM DeferRevenueProfile";
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(DeferRevenueProfileCode; Rec.DeferRevenueProfileCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the DeferRevenueProfileCode field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(AchievedRevenueRecognitionAcc; Rec.AchievedRevenueAccount)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Achieved Revenue Recognition (Ticketing) field.';
                    ShowMandatory = true;
                }
                field(InterimAdjustmentAcc; Rec.InterimAdjustmentAccount)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Interim Adjustment Account (Ticketing) field.';
                    Visible = false;
                }
                field(JournalTemplateName; Rec.JournalTemplateName)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Journal Template Name field.';
                    ShowMandatory = true;
                }
                field(NoSeries; Rec.NoSeries)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the No. Series field.';
                    ShowMandatory = (Rec.PostingMode <> Rec.PostingMode::INLINE);
                }
                field(SourceCode; Rec.SourceCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Source Code field.';
                }
                field(ReversalReasonCode; Rec.ReversalReasonCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Reversal Reason Code field.';
                }
                field(ReversalPostingDescription; Rec.ReversalPostingDescription)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Reversal Posting Description field.';
                }
                field(DeferralReasonCode; Rec.DeferralReasonCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Reversal Reason Code field.';
                }
                field(DeferralPostingDescription; Rec.DeferralPostingDescription)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Deferral Posting Description field.';
                }
                field(PostingMode; Rec.PostingMode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Posting Mode field.';
                }
                field(MaxAttempts; Rec.MaxAttempts)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'After this number of attempts to defer and source document is not found, the status will be set to Unresolved.';
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SetupJobQueue)
            {
                Caption = 'Setup Job Queue';
                ToolTip = 'This action will setup the job-queue automatic deferral posting.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Image = Setup;
                trigger OnAction()
                var
                    JobQueueManagement: Codeunit "NPR Job Queue Management";
                    DescriptionLbl: Label 'Schedule Ticket Deferral Posting';
                    NextRunDateFormula: DateFormula;
                    JobQueueEntry: Record "Job Queue Entry";
                begin
                    Evaluate(NextRunDateFormula, '<1D>');
                    JobQueueManagement.SetJobTimeout(4, 0);
                    JobQueueManagement.SetAutoRescheduleAndNotifyOnError(true, 2700, '');  //Reschedule to run again in 45 minutes on error
                    JobQueueManagement.SetProtected(true);
                    if (JobQueueManagement.InitRecurringJobQueueEntry(
                        JobQueueEntry."Object Type to Run"::codeunit,
                        Codeunit::"NPR TM RevenueDeferral",
                        '',
                        DescriptionLbl,
                        JobQueueManagement.NowWithDelayInSeconds(360),
                        210000T,
                        000000T,
                        NextRunDateFormula,
                        JobQueueManagement.CreateAndAssignJobQueueCategory(),
                        JobQueueEntry))
                    then begin
                        JobQueueManagement.StartJobQueueEntry(JobQueueEntry);
                    end;
                end;
            }
        }
        area(Navigation)
        {
            action(GeneralPostingSetup)
            {
                Caption = 'General Posting Setup';
                ToolTip = 'This action will open the General Posting Setup list page.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Image = GeneralLedger;
                RunObject = Page "General Posting Setup";
            }

        }
    }
}