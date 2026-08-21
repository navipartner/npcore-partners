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
            action(Items)
            {
                Caption = 'Items';
                ToolTip = 'View all items flagged as Entria Products.';
                ApplicationArea = NPRRetail;
                Image = Item;
                RunObject = page "Item List";
                RunPageView = where("NPR Entria Product" = const(true));
            }
            action(OrderImportFailures)
            {
                Caption = 'Order Import Failures';
                ToolTip = 'View the Entria orders that could not be imported, with the last error, how much of the retry budget is left and when the next retry is due.';
                ApplicationArea = NPRRetail;
                Image = ErrorLog;
                RunObject = page "NPR Entria Order Imp. Failures";
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