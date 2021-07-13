page 6150658 "NPR POS Posting Log"
{
    Caption = 'POS Posting Log';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Posting Log";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posting Timestamp"; Rec."Posting Timestamp")
                {

                    ToolTip = 'Specifies the value of the Posting Timestamp field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Duration"; Rec."Posting Duration")
                {

                    ToolTip = 'Specifies the value of the Posting Duration field';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {

                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("With Error"; Rec."With Error")
                {

                    ToolTip = 'Specifies the value of the With Error field';
                    ApplicationArea = NPRRetail;
                }
                field("Error Description"; Rec."Error Description")
                {

                    ToolTip = 'Specifies the value of the Error Description field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Entry View"; Rec."POS Entry View")
                {

                    ToolTip = 'Specifies the value of the POS Entry View field';
                    ApplicationArea = NPRRetail;
                }
                field("Last POS Entry No. at Posting"; Rec."Last POS Entry No. at Posting")
                {

                    ToolTip = 'Specifies the value of the Last POS Entry No. at Posting field';
                    ApplicationArea = NPRRetail;
                }
                field("No. of POS Entries"; Rec."No. of POS Entries")
                {

                    ToolTip = 'Specifies the value of the No. of POS Entries field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            part(Control6014412; "NPR POS Posting Log Parameters")
            {
                SubPageLink = "Entry No." = FIELD("Entry No.");
                ApplicationArea = NPRRetail;

            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Repost)
            {
                Caption = 'Repost';
                Image = PostBatch;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Executes the Repost action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSPostEntries: Codeunit "NPR POS Post Entries";
                begin
                    POSPostEntries.PostFromPOSPostingLog(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
        area(navigation)
        {
            action("POS Entries")
            {
                Caption = 'POS Entries';
                Image = LedgerEntries;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Entry List";
                RunPageLink = "POS Posting Log Entry No." = FIELD("Entry No.");

                ToolTip = 'Executes the POS Entries action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

