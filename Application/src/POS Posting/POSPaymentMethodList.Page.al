page 6150618 "NPR POS Payment Method List"
{
    Caption = 'POS Payment Method List';
    CardPageID = "NPR POS Payment Method Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR POS Payment Method";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Type"; Rec."Processing Type")
                {

                    ToolTip = 'Specifies the value of the Processing Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {

                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Include In Counting"; Rec."Include In Counting")
                {

                    ToolTip = 'Specifies the value of the Include In Counting field';
                    ApplicationArea = NPRRetail;
                }
                field("Bin for Virtual-Count"; Rec."Bin for Virtual-Count")
                {

                    ToolTip = 'Specifies the value of the Bin for Virtual-Count field';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Gains Account"; Rec."Rounding Gains Account")
                {

                    Visible = true;
                    ToolTip = 'Specifies the value of the Rounding Gains Account field';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Losses Account"; Rec."Rounding Losses Account")
                {

                    Visible = true;
                    ToolTip = 'Specifies the value of the Rounding Losses Account field';
                    ApplicationArea = NPRRetail;
                }
                field("Vouched By"; Rec."Vouched By")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Vouched By field';
                    ApplicationArea = NPRRetail;
                }
                field("Post Condensed"; Rec."Post Condensed")
                {

                    Visible = true;
                    ToolTip = 'Specifies the value of the Post Condensed field';
                    ApplicationArea = NPRRetail;
                }
                field("Condensed Posting Description"; Rec."Condensed Posting Description")
                {

                    Visible = true;
                    ToolTip = 'Specifies the value of the Condensed Posting Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Precision"; Rec."Rounding Precision")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Rounding Precision field';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Type"; Rec."Rounding Type")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Rounding Type field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the POS Posting Setup action';
                ApplicationArea = NPRRetail;
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
                    RunObject = Page "NPR POS Entry Pmt. Line List";
                    RunPageLink = "POS Payment Method Code" = FIELD(Code);

                    ToolTip = 'Executes the POS Payment Lines action';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

