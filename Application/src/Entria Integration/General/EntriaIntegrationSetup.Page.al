#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6150928 "NPR Entria Integration Setup"
{
    Caption = 'Entria Integration Setup';
    PageType = Card;
    SourceTable = "NPR Entria Integration Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    AdditionalSearchTerms = 'entria, medusa, ecommerce, integration';
    DeleteAllowed = false;
    InsertAllowed = false;
    Extensible = false;
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Enable Integration"; Rec."Enable Integration")
                {
                    ToolTip = 'Specifies whether the integration with Entria is enabled.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Stores)
            {
                Caption = 'Stores';
                ToolTip = 'Open the list of Entria stores.';
                ApplicationArea = NPRRetail;
                Image = Navigate;
                RunObject = page "NPR Entria Stores";
            }
            action(JobQueueEntries)
            {
                Caption = 'Job Queue Entries';
                ApplicationArea = NPRRetail;
                Image = JobListSetup;
                ToolTip = 'View the job queue entries for Entria order import and processing.';
                trigger OnAction()
                var
                    JobQueueEntry: Record "Job Queue Entry";
                begin
                    JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
                    JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Entria Order Import JQ");
                    Page.Run(Page::"Job Queue Entries", JobQueueEntry);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
#endif