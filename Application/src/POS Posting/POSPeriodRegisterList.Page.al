page 6150651 "NPR POS Period Register List"
{
    Caption = 'POS Period Register List';
    Editable = false;
    PageType = List;
    SourceTable = "NPR POS Period Register";
    UsageCategory = History;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Control6014401)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store Code"; Rec."POS Store Code")
                {

                    ToolTip = 'Specifies the value of the POS Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Opening Entry No."; Rec."Opening Entry No.")
                {

                    ToolTip = 'Specifies the value of the From Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Closing Entry No."; Rec."Closing Entry No.")
                {

                    ToolTip = 'Specifies the value of the To Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Compression"; Rec."Posting Compression")
                {

                    ToolTip = 'Specifies the value of the Posting Compression field';
                    ApplicationArea = NPRRetail;
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Entry List";
                RunPageLink = "POS Period Register No." = FIELD("No.");
                RunPageView = SORTING("Entry No.")
                              ORDER(Ascending);

                ToolTip = 'Executes the POS Entries action';
                ApplicationArea = NPRRetail;
            }
            action("Sales Lines")
            {
                Caption = 'Sales Lines';
                Image = Sales;
                RunObject = Page "NPR POS Entry Sales Line List";
                RunPageLink = "POS Period Register No." = FIELD("No.");

                ToolTip = 'Executes the Sales Lines action';
                ApplicationArea = NPRRetail;
            }
            action("Payment Lines")
            {
                Caption = 'Payment Lines';
                Image = Payment;
                RunObject = Page "NPR POS Entry Pmt. Line List";
                RunPageLink = "POS Period Register No." = FIELD("No.");

                ToolTip = 'Executes the Payment Lines action';
                ApplicationArea = NPRRetail;
            }
            action("Balancing Line")
            {
                Caption = 'Balancing Line';
                Image = Balance;
                RunObject = Page "NPR POS Balancing Line";
                RunPageLink = "POS Period Register No." = FIELD("No.");

                ToolTip = 'Executes the Balancing Line action';
                ApplicationArea = NPRRetail;
            }
        }
        area(processing)
        {
            action("Post Ledger Register")
            {
                Caption = 'Post Ledger Register';
                Image = Post;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Post Ledger Register action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSPostEntries: Codeunit "NPR POS Post Entries";
                    POSEntryToPost: Record "NPR POS Entry";
                begin
                    POSEntryToPost.SetCurrentKey("POS Period Register No.");
                    POSEntryToPost.SetRange("POS Period Register No.", Rec."No.");
                    POSPostEntries.SetPostItemEntries(true);
                    POSPostEntries.SetPostPOSEntries(true);
                    POSPostEntries.SetStopOnError(true);
                    POSPostEntries.SetPostCompressed(false);
                    POSPostEntries.Run(POSEntryToPost);
                    CurrPage.Update(false);
                end;
            }
            action("&Navigate")
            {
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Executes the &Navigate action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc(DT2Date(Rec."End of Day Date"), Rec."Document No.");
                    Navigate.Run();
                end;
            }
        }
    }
}

