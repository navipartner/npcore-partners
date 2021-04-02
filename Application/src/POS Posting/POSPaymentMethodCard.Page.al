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
                    ToolTip = 'Specifies Code of selected POS Payment Method.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Description of selected POS Payment Method.';
                }
                field("Processing Type"; Rec."Processing Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Type field. Possible values are Cash,Voucher,Check,EFT,Customer,PayOut.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account field related to the General Ledger.';
                    ShowMandatory = true;
                }

                field("Return Payment Method Code"; Rec."Return Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Return Payment Method Code field. Return Payment Method will be used for return of overpaid amount.';
                    ShowMandatory = true;
                }
                field("Block POS Payment"; Rec."Block POS Payment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if selected POS Payment Method is blocked for use in POS Transaction.';
                }
                field("Open Drawer"; Rec."Open Drawer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if drawer will open after POS Transaction ends if selected POS Payment Mehod is used in transaction.';
                }

            }
            group(Other)
            {
                Caption = 'Other';

                field("Bin for Virtual-Count"; Rec."Bin for Virtual-Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which Payment Bin will be used for Auto Count.';
                }
                field("Include In Counting"; Rec."Include In Counting")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if selected POS Payment Mehod will be included in counting.';
                }

                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which Payment Method is connected to selected POS Payment Mehod.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Here you can specify Currency code if POS Payment Method is for foreign currency.';
                }
                field("Fixed Rate"; Rec."Fixed Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'You can specify Fixed rate which will be used for converting foreign currency amounts.';
                }
                field("Post Condensed"; Rec."Post Condensed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if POS Payment line will be posted uncompressed, per POS Entry or per POS Period Register';
                }
                field("Condensed Posting Description"; Rec."Condensed Posting Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Posting Description for condensed POS Payment lines %1 = POS Unit Code, %2 = POS Store Code, %3 = Posting Date, %4 = POS Period Register No, %5 = POS Payment Date';
                }
                field("Zero as Default on Popup"; Rec."Zero as Default on Popup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if Payment input popup for selected POS Payment Method defaults to zero.';
                }

                field("Auto End Sale"; Rec."Auto End Sale")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if POS Transaction automatically ends when POS Payment method is selected.';
                }
                field("Forced Amount"; Rec."Forced Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which amount is forced when using selected POS Payment Method in transaction.';
                }
                field("Match Sales Amount"; Rec."Match Sales Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if EFT Terminal matches amount of POS Transaction.';
                }
                field("Reverse Unrealized VAT"; Rec."Reverse Unrealized VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if Unrealized VAT will be reversed when posting Payment line.';
                }

                field("No Min Amount on Web Orders"; Rec."No Min Amount on Web Orders")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if there is limit for Minimum Amount for selected POS Payment Method on Web Orders.';
                }


            }
            group(Rounding)
            {
                Caption = 'Rounding';
                field("Rounding Precision"; Rec."Rounding Precision")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Precision field. Field should represent lowest denomination used for selected POS Payment Method.';
                }
                field("Rounding Type"; Rec."Rounding Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Type field. Possible roudings are Nearest, Up or Down';
                }
                field("Rounding Gains Account"; Rec."Rounding Gains Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies G/L Account No. which will be used for rounding gains.';
                }
                field("Rounding Losses Account"; Rec."Rounding Losses Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies G/L Account No. which will be used for rounding losses.';
                }
            }
            group(Options)
            {
                Caption = 'Option';
                field("Minimum Amount"; Rec."Minimum Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Minimum Amout that can be paid using selected POS Payment Method.';
                }
                field("Maximum Amount"; Rec."Maximum Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Maximum Amout that can be paid using selected POS Payment Method.';
                }
                field("Allow Refund"; Rec."Allow Refund")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if refund is allowed for selected POS Payment Method.';
                }
                field("EFT Surcharge Service Item No."; Rec."EFT Surcharge Service Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which Service Item will be used for EFT Surcharge.';
                }
                field("EFT Tip Service Item No."; Rec."EFT Tip Service Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which Service Item will be used for EFT Tip.';
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
                ToolTip = 'Action opens POS Posting Setup for selected POS Payment Method';
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
                    ToolTip = 'Action opens POS Payment Lines for selected POS Payment Method.';
                }
            }
        }
    }
}

