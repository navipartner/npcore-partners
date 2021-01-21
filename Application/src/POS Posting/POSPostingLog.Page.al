page 6150658 "NPR POS Posting Log"
{
    Caption = 'POS Posting Log';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Posting Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posting Timestamp"; "Posting Timestamp")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Timestamp field';
                }
                field("Posting Duration"; "Posting Duration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Duration field';
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("With Error"; "With Error")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the With Error field';
                }
                field("Error Description"; "Error Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Description field';
                }
                field("POS Entry View"; "POS Entry View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Entry View field';
                }
                field("Last POS Entry No. at Posting"; "Last POS Entry No. at Posting")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last POS Entry No. at Posting field';
                }
                field("No. of POS Entries"; "No. of POS Entries")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of POS Entries field';
                }
            }
        }
        area(factboxes)
        {
            part(Control6014412; "NPR POS Posting Log Parameters")
            {
                SubPageLink = "Entry No." = FIELD("Entry No.");
                ApplicationArea = All;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Repost action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the POS Entries action';
            }
        }
    }
}

