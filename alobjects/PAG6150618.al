page 6150618 "POS Payment Method List"
{
    // NPR5.29/AP/20170126 CASE 261728 Recreated ENU-captions
    // NPR5.36/BR/20170810 CASE 277096 Added Action to navigate to POS Posting Setup
    // NPR5.38/BR/20171024 CASE 294311 Made Non-Editable, Set CardPageID
    // NPR5.38/BR/20171117 CASE 295255 Added Action POS Payment Lines
    // NPR5.45/TSA /20180808 CASE 324360 Added fields to pages

    Caption = 'POS Payment Method List';
    CardPageID = "POS Payment Method Card";
    Editable = false;
    PageType = List;
    SourceTable = "POS Payment Method";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field("Processing Type"; "Processing Type")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Vouched By"; "Vouched By")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Is Finance Agreement"; "Is Finance Agreement")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Include In Counting"; "Include In Counting")
                {
                    ApplicationArea = All;
                }
                field("Post Condensed"; "Post Condensed")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Condensed Posting Description"; "Condensed Posting Description")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Rounding Precision"; "Rounding Precision")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Rounding Type"; "Rounding Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Rounding Gains Account"; "Rounding Gains Account")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Rounding Losses Account"; "Rounding Losses Account")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(POSPostingSetup)
            {
                Caption = 'POS Posting Setup';
                Image = GeneralPostingSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "POS Posting Setup";
                RunPageLink = "POS Payment Method Code" = FIELD(Code);
            }
            group(History)
            {
                Caption = 'History';
                action("POS Payment Lines")
                {
                    Caption = 'POS Payment Lines';
                    Image = LedgerEntries;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "POS Payment Line List";
                    RunPageLink = "POS Payment Method Code" = FIELD(Code);
                }
            }
        }
    }
}

