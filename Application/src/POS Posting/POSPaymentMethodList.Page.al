page 6150618 "NPR POS Payment Method List"
{
    Caption = 'POS Payment Method List';
    CardPageID = "NPR POS Payment Method Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR POS Payment Method";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                field("Rounding Gains Account"; "Rounding Gains Account")
                {
                    ApplicationArea = All;
                    Visible = true;
                    ToolTip = 'Specifies the value of the Rounding Gains Account field';
                }
                field("Rounding Losses Account"; "Rounding Losses Account")
                {
                    ApplicationArea = All;
                    Visible = true;
                    ToolTip = 'Specifies the value of the Rounding Losses Account field';
                }
                field("Vouched By"; "Vouched By")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Vouched By field';
                }
                field("Is Finance Agreement"; "Is Finance Agreement")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Is Finance Agreement field';
                }
                field("Post Condensed"; "Post Condensed")
                {
                    ApplicationArea = All;
                    Visible = true;
                    ToolTip = 'Specifies the value of the Post Condensed field';
                }
                field("Condensed Posting Description"; "Condensed Posting Description")
                {
                    ApplicationArea = All;
                    Visible = true;
                    ToolTip = 'Specifies the value of the Condensed Posting Description field';
                }
                field("Rounding Precision"; "Rounding Precision")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Rounding Precision field';
                }
                field("Rounding Type"; "Rounding Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Rounding Type field';
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

