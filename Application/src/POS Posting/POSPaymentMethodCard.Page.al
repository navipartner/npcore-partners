page 6150619 "NPR POS Payment Method Card"
{
    UsageCategory = None;
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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Processing Type"; "Processing Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Type field';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Vouched By"; "Vouched By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vouched By field';
                }
                field("Is Finance Agreement"; "Is Finance Agreement")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Is Finance Agreement field';
                }
                field("Include In Counting"; "Include In Counting")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Include In Counting field';
                }
                field("Bin for Virtual-Count"; "Bin for Virtual-Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bin for Virtual-Count field';
                }
                field("Post Condensed"; "Post Condensed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Condensed field';
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
                    ToolTip = 'Specifies the value of the Rounding Precision field';
                }
                field("Rounding Type"; "Rounding Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Type field';
                }
                field("Rounding Gains Account"; "Rounding Gains Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Gains Account field';
                }
                field("Rounding Losses Account"; "Rounding Losses Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Losses Account field';
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
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Posting Setup";
                RunPageLink = "POS Payment Method Code" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the POS Posting Setup action';
            }
            group(History)
            {
                Caption = 'History';
                action("POS Payment Lines")
                {
                    Caption = 'POS Payment Lines';
                    Image = LedgerEntries;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "NPR POS Payment Line List";
                    RunPageLink = "POS Payment Method Code" = FIELD(Code);
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Payment Lines action';
                }
            }
        }
    }
}

