page 6150619 "NPR POS Payment Method Card"
{
    // NPR5.29/AP/20170126 CASE 261728 Recreated ENU-captions
    // NPR5.36/BR/20170810 CASE 277096 Added Action to navigate to POS Posting Setup
    // NPR5.38/BR  /20171109  CASE 294722 Added field Condensed Posting Description
    // NPR5.38/BR  /20171117  CASE 295255 Added Action POS Payment Lines
    // NPR5.38/BR  /20171214  CASE 299888 Changed ENU ToolTip from POS Ledger Register to POS Period Register
    // NPR5.46/TSA /20181002 CASE 322769 Added field "Bin for Auto-Count"

    Caption = 'POS Payment Method Card';
    SourceTable = "NPR POS Payment Method";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
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
                }
                field("Is Finance Agreement"; "Is Finance Agreement")
                {
                    ApplicationArea = All;
                }
                field("Include In Counting"; "Include In Counting")
                {
                    ApplicationArea = All;
                }
                field("Bin for Virtual-Count"; "Bin for Virtual-Count")
                {
                    ApplicationArea = All;
                }
                field("Post Condensed"; "Post Condensed")
                {
                    ApplicationArea = All;
                }
                field("Condensed Posting Description"; "Condensed Posting Description")
                {
                    ApplicationArea = All;
                    ToolTip = '%1 = POS Unit Code, %2 = POS Store Code, %3 = Posting Date, %4 = POS Period Register No, %5 = POS Payment Date';
                }
            }
            group(Rounding)
            {
                Caption = 'Rounding';
                field("Rounding Precision"; "Rounding Precision")
                {
                    ApplicationArea = All;
                }
                field("Rounding Type"; "Rounding Type")
                {
                    ApplicationArea = All;
                }
                field("Rounding Gains Account"; "Rounding Gains Account")
                {
                    ApplicationArea = All;
                }
                field("Rounding Losses Account"; "Rounding Losses Account")
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
            action(POSPostingSetup)
            {
                Caption = 'POS Posting Setup';
                Image = GeneralPostingSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Posting Setup";
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
                    RunObject = Page "NPR POS Payment Line List";
                    RunPageLink = "POS Payment Method Code" = FIELD(Code);
                }
            }
        }
    }
}

