page 6150658 "POS Posting Log"
{
    // NPR5.36/BR  /20170814  CASE  277096 Object created
    // NPR5.38/BR  /20180119  CASE 302791 Added field Posting Duration

    Caption = 'POS Posting Log';
    Editable = false;
    PageType = List;
    SourceTable = "POS Posting Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posting Timestamp"; "Posting Timestamp")
                {
                    ApplicationArea = All;
                }
                field("Posting Duration"; "Posting Duration")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("With Error"; "With Error")
                {
                    ApplicationArea = All;
                }
                field("Error Description"; "Error Description")
                {
                    ApplicationArea = All;
                }
                field("POS Entry View"; "POS Entry View")
                {
                    ApplicationArea = All;
                }
                field("Last POS Entry No. at Posting"; "Last POS Entry No. at Posting")
                {
                    ApplicationArea = All;
                }
                field("No. of POS Entries"; "No. of POS Entries")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            part(Control6014412; "POS Posting Log Parameters")
            {
                SubPageLink = "Entry No." = FIELD("Entry No.");
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
                PromotedCategory = Process;

                trigger OnAction()
                var
                    POSPostEntries: Codeunit "POS Post Entries";
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "POS Entry List";
                RunPageLink = "POS Posting Log Entry No." = FIELD("Entry No.");
            }
        }
    }
}

