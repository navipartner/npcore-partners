﻿page 6150618 "NPR POS Payment Method List"
{
    Extensible = False;
    Caption = 'POS Payment Method List';
    ContextSensitiveHelpPage = 'docs/retail/pos_processes/how-to/create_payment_method/';
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

                    ToolTip = 'Specifies the Code of the selected POS Payment Method.';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Type"; Rec."Processing Type")
                {

                    ToolTip = 'Specifies the payment method processing type. Cash is for bills and coins in all currencies. Voucher is used for gift cards, coupons and vouchers. Check is used for checks. EFT is used for credit and debit card payments. Customer is currently not supported. Payout is used for cash movements, for example Payin/Payout to/from thePOS.';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {

                    ToolTip = 'Specifies the Currency Code if the POS Payment Method is for a foreign currency.';
                    ApplicationArea = NPRRetail;
                }
                field("Include In Counting"; Rec."Include In Counting")
                {

                    ToolTip = ' Specifies whether the item should be included in the counting process.';
                    ApplicationArea = NPRRetail;
                }
                field("Bin for Virtual-Count"; Rec."Bin for Virtual-Count")
                {

                    ToolTip = 'Specifies which Payment Bin will be used for Auto Count.';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Gains Account"; Rec."Rounding Gains Account")
                {

                    Visible = false;
                    ToolTip = 'Specifies G/L Account No. which will be used for rounding gains.';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Losses Account"; Rec."Rounding Losses Account")
                {

                    Visible = false;
                    ToolTip = 'Specifies G/L Account No. which will be used for rounding losses.';
                    ApplicationArea = NPRRetail;
                }
                field("Vouched By"; Rec."Vouched By")
                {

                    Visible = false;
                    ToolTip = 'Specifies who vouched for the item.';
                    ApplicationArea = NPRRetail;
                }
                field("Post Condensed"; Rec."Post Condensed")
                {

                    Visible = true;
                    ToolTip = 'Specifies if the POS Payment line will be posted uncompressed, per a POS Entry or per a POS Period Register.';
                    ApplicationArea = NPRRetail;
                }
                field("Condensed Posting Description"; Rec."Condensed Posting Description")
                {

                    Visible = false;
                    ToolTip = 'Specifies the Posting Description for condensed POS payment lines. %1 = POS Unit Code, %2 = POS Store Code, %3 = Posting Date, %4 = POS Period Register No, %5 = POS Payment Date."';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Precision"; Rec."Rounding Precision")
                {

                    Visible = false;
                    ToolTip = 'Specifies the decimal precision for rounding.';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Type"; Rec."Rounding Type")
                {

                    Visible = false;
                    ToolTip = 'Specifies the type of rounding to be applied.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Warning pop-up on Return"; Rec."NPR Warning pop-up on Return")
                {
                    Visible = false;
                    ToolTip = 'Specifies pop up warning on return';
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

                ToolTip = 'View or edit the POS Posting Setup';
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
                    ToolTip = 'Opens the POS Payment Lines List';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}