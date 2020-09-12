page 6150651 "NPR POS Period Register List"
{
    // NPR5.36/BR  /20170808  CASE 277096 Object created
    // NPR5.37/BR  /20171012  CASE 293227 Added posting actions
    // NPR5.38/BR /20171214 CASE 299888 Renamed from POS Ledger Register to POS Period Register (incl. Captions)
    // NPR5.39/BR  /20180129  CASE 302696 Added POS Balancing Lines

    Caption = 'POS Period Register List';
    Editable = false;
    PageType = List;
    SourceTable = "NPR POS Period Register";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Control6014401)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("POS Store Code"; "POS Store Code")
                {
                    ApplicationArea = All;
                }
                field("POS Unit No."; "POS Unit No.")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("Opening Entry No."; "Opening Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Closing Entry No."; "Closing Entry No.")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Posting Compression"; "Posting Compression")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(POSEntries)
            {
                Caption = 'POS Entries';
                Image = LedgerEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Entry List";
                RunPageLink = "POS Period Register No." = FIELD("No.");
                RunPageView = SORTING("Entry No.")
                              ORDER(Ascending);
                ApplicationArea = All;
            }
            action("Sales Lines")
            {
                Caption = 'Sales Lines';
                Image = Sales;
                RunObject = Page "NPR POS Sales Line List";
                RunPageLink = "POS Period Register No." = FIELD("No.");
                ApplicationArea = All;
            }
            action("Payment Lines")
            {
                Caption = 'Payment Lines';
                Image = Payment;
                RunObject = Page "NPR POS Payment Line List";
                RunPageLink = "POS Period Register No." = FIELD("No.");
                ApplicationArea = All;
            }
            action("Balancing Line")
            {
                Caption = 'Balancing Line';
                Image = Balance;
                RunObject = Page "NPR POS Balancing Line";
                RunPageLink = "POS Period Register No." = FIELD("No.");
                ApplicationArea = All;
            }
        }
        area(processing)
        {
            action("Post Ledger Register")
            {
                Caption = 'Post Ledger Register';
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    POSPostEntries: Codeunit "NPR POS Post Entries";
                    POSEntryToPost: Record "NPR POS Entry";
                begin
                    POSEntryToPost.SetRange("POS Period Register No.", "No.");
                    POSPostEntries.SetPostItemEntries(true);
                    POSPostEntries.SetPostPOSEntries(true);
                    POSPostEntries.SetStopOnError(true);
                    POSPostEntries.SetPostCompressed(false);
                    POSPostEntries.Run(POSEntryToPost);
                    CurrPage.Update(false);
                end;
            }
            action("Preview Post Ledger Register")
            {
                Caption = 'Preview Post Ledger Register';
                Image = ViewPostedOrder;
                ApplicationArea = All;

                trigger OnAction()
                var
                    POSEntryToPost: Record "NPR POS Entry";
                    POSPostEntries: Codeunit "NPR POS Post Entries";
                begin
                    POSEntryToPost.SetRange("POS Period Register No.", "No.");
                    POSPostEntries.SetPostItemEntries(true);
                    POSPostEntries.SetPostPOSEntries(true);
                    POSPostEntries.SetStopOnError(true);
                    POSPostEntries.SetPostCompressed(false);
                    POSPostEntries.Preview(POSEntryToPost);
                    CurrPage.Update(false);
                end;
            }
            action("Compare Preview Ledger Register to Audit Roll Posting")
            {
                Caption = 'Compare Preview Ledger Register to Audit Roll Posting';
                Image = CompareCOA;
                ApplicationArea = All;

                trigger OnAction()
                var
                    POSEntryToPost: Record "NPR POS Entry";
                    POSPostEntries: Codeunit "NPR POS Post Entries";
                begin
                    POSEntryToPost.SetRange("POS Period Register No.", "No.");
                    POSPostEntries.SetPostItemEntries(true);
                    POSPostEntries.SetPostPOSEntries(true);
                    POSPostEntries.SetStopOnError(true);
                    POSPostEntries.SetPostCompressed(false);
                    POSPostEntries.CompareToAuditRoll(POSEntryToPost);
                    CurrPage.Update(false);
                end;
            }
            action("&Navigate")
            {
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc(DT2Date("End of Day Date"), "Document No.");
                    Navigate.Run;
                end;
            }
        }
    }
}

