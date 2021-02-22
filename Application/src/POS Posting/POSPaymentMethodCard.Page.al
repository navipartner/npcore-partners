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
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Processing Type"; Rec."Processing Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Type field';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account Type field.';
                    ShowMandatory = true;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the G/L Account field.';
                    ShowMandatory = true;
                }

                field("Return Payment Method Code"; Rec."Return Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Return Payment Method Code field';
                    ShowMandatory = true;
                }
                field("Block POS Payment"; Rec."Block POS Payment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Block POS Payment field.';
                }
                field("Open Drawer"; Rec."Open Drawer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open Drawer field';
                }

            }
            group(Other)
            {
                Caption = 'Other';

                field("Bin for Virtual-Count"; Rec."Bin for Virtual-Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bin for Virtual-Count field';
                }
                field("Include In Counting"; Rec."Include In Counting")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Include In Counting field.';
                }

                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Method Code field';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field.';
                }
                field("Fixed Rate"; Rec."Fixed Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fixed Rate field.';
                }
                field("Post Condensed"; Rec."Post Condensed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Condensed field';
                }
                field("Condensed Posting Description"; Rec."Condensed Posting Description")
                {
                    ApplicationArea = All;
                    ToolTip = '%1 = POS Unit Code, %2 = POS Store Code, %3 = Posting Date, %4 = POS Period Register No, %5 = POS Payment Date';
                }
                field("Zero as Default on Popup"; Rec."Zero as Default on Popup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Zero as Default on Popup field';
                }

                field("Auto End Sale"; Rec."Auto End Sale")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto end sale field';
                }
                field("Forced Amount"; Rec."Forced Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Forced amount field';
                }
                field("Match Sales Amount"; Rec."Match Sales Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Match Sales Amount field';
                }
                field("Reverse Unrealized VAT"; Rec."Reverse Unrealized VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reverse Unrealized VAT field';
                }

                field("No Min Amount on Web Orders"; Rec."No Min Amount on Web Orders")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No Min Amount on Web Orders field.';
                }
                field("Is Finance Agreement"; Rec."Is Finance Agreement")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Is Finance Agreement field.';
                }


            }
            group(Rounding)
            {
                Caption = 'Rounding';
                field("Rounding Precision"; Rec."Rounding Precision")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Precision field';
                }
                field("Rounding Type"; Rec."Rounding Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Type field';
                }
                field("Rounding Gains Account"; Rec."Rounding Gains Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Gains Account field';
                }
                field("Rounding Losses Account"; Rec."Rounding Losses Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Losses Account field';
                }
            }
            group(Options)
            {
                Caption = 'Option';
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Only used by Global Dimension 1 field';
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Only used by Global Dimension 2 field';
                }
                field("Minimum Amount"; Rec."Minimum Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Min amount field';
                }
                field("Maximum Amount"; Rec."Maximum Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Maximum amount field';
                }
                field("Allow Refund"; Rec."Allow Refund")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Refund field';
                }
                field("EFT Surcharge Service Item No."; Rec."EFT Surcharge Service Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Surcharge Service Item No. field';
                }
                field("EFT Tip Service Item No."; Rec."EFT Tip Service Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tip Service Item No. field';
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

