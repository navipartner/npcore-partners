﻿page 6150619 "NPR POS Payment Method Card"
{
    Extensible = False;
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

                    ToolTip = 'Specifies Code of selected POS Payment Method.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies Description of selected POS Payment Method.';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Type"; Rec."Processing Type")
                {

                    ToolTip = 'Specifies the value of the Processing Type field. Possible values are Cash,Voucher,Check,EFT,Customer,PayOut. Use Cash for bills and coins in all currencies. Voucher is used for gift cards, coupons and vouchers. Check is used for checks. EFT for credit and debit card payments. Customer is currently not supported. Payout is used for cash movements, for example Payin/Payout to/from the POS.';
                    ApplicationArea = NPRRetail;
                    ValuesAllowed = CASH, VOUCHER, CHECK, EFT, PAYOUT, "FOREIGN VOUCHER";
                }

                field("Return Payment Method Code"; Rec."Return Payment Method Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies which return payment method will be used for the return of the overpaid amount. For foreign currency, it''s necessary to set it to the POS Payment Method used for the local currency, as we return the overpaid amount in the local currency.';
                    ShowMandatory = true;
                }
                field("Block POS Payment"; Rec."Block POS Payment")
                {

                    ToolTip = 'Specifies if selected POS Payment Method is blocked for use in POS Transaction.';
                    ApplicationArea = NPRRetail;
                }
                field("Open Drawer"; Rec."Open Drawer")
                {

                    ToolTip = 'Specifies if drawer will open after POS Transaction ends if selected POS Payment Mehod is used in transaction.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Other)
            {
                Caption = 'Other';

                field("Bin for Virtual-Count"; Rec."Bin for Virtual-Count")
                {

                    ToolTip = 'Specifies which Payment Bin will be used for Auto Count.';
                    ApplicationArea = NPRRetail;
                }
                field("Include In Counting"; Rec."Include In Counting")
                {

                    ToolTip = 'Specifies if selected POS Payment Mehod will be included in counting.';
                    ApplicationArea = NPRRetail;
                }

                field("Currency Code"; Rec."Currency Code")
                {

                    ToolTip = 'Here you can specify Currency code if POS Payment Method is for foreign currency.';
                    ApplicationArea = NPRRetail;
                }
                field("Fixed Rate"; Rec."Fixed Rate")
                {

                    ToolTip = 'You can specify the Fixed Rate which will be used to convert 100 units of foreign currency into local currency. For example 1 FCY = 6.15 LCY , hence the value to be inserted = 100 x 6.15 = 615 instead of 6.15.';
                    ApplicationArea = NPRRetail;
                }
                field("Use Stand. Exc. Rate for Bal."; Rec."Use Stand. Exc. Rate for Bal.")
                {
                    ToolTip = 'Specify whether fixed rate should be applied on transaction amount.';
                    ApplicationArea = NPRRetail;
                }                
                field("Post Condensed"; Rec."Post Condensed")
                {
                    ToolTip = 'Enable "Post Condensed" to be able to set placeholders in "Condensed Posting Description".';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Condensed Posting Description"; Rec."Condensed Posting Description")
                {
                    ToolTip = 'Default placeholders, when "Post Condensed" is enabled, for uncompressed entries are %6 - %3, for compression per POS entry %6 - %3, for compression per POS Period %2/%1/%6 - %4/%3. When POS payment is posted, placeholders (values %1, %2 ... %6) will be replaced with real values where %1 will be replaced with actual value of "POS Unit No.", %2 with "POS Store Code", %3 with "Posting Date", %4 with "POS Period Register No.", %5 with "POS Payment Bin Code", %6 with "POS Payment Method Code". You can choose any order of placeholders from %1 to %6 (e.g. %4_%1%2).';
                    ApplicationArea = NPRRetail;
                    Editable = IsPostCondensed;
                }
                field("Zero as Default on Popup"; Rec."Zero as Default on Popup")
                {

                    ToolTip = 'Specifies if Payment input popup for selected POS Payment Method defaults to zero.';
                    ApplicationArea = NPRRetail;
                }
                field("Auto End Sale"; Rec."Auto End Sale")
                {

                    ToolTip = 'Specifies if the POS transaction automatically ends when the POS Payment Method is selected if all other conditions are met.';
                    ApplicationArea = NPRRetail;
                }

                field("No Min Amount on Web Orders"; Rec."No Min Amount on Web Orders")
                {

                    ToolTip = 'Specifies if there is limit for Minimum Amount for selected POS Payment Method on Web Orders.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Rounding)
            {
                Caption = 'Rounding';
                field("Rounding Precision"; Rec."Rounding Precision")
                {

                    ToolTip = 'Specifies how precise the rounding is. The field should represent lowest denomination used for the selected POS Payment Method.';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Type"; Rec."Rounding Type")
                {

                    ToolTip = 'Specifies which rounding type will be applied to the amount.';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Gains Account"; Rec."Rounding Gains Account")
                {

                    ToolTip = 'Specifies G/L Account No. which will be used for rounding gains.';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Losses Account"; Rec."Rounding Losses Account")
                {

                    ToolTip = 'Specifies G/L Account No. which will be used for rounding losses.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Options)
            {
                Caption = 'Option';
                field("Minimum Amount"; Rec."Minimum Amount")
                {

                    ToolTip = 'Specifies the minimum amount that can be paid using the selected POS Payment Method.';
                    ApplicationArea = NPRRetail;
                }
                field("Maximum Amount"; Rec."Maximum Amount")
                {

                    ToolTip = 'Specifies the maximum amount that can be paid using the selected POS Payment Method.';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Refund"; Rec."Allow Refund")
                {

                    ToolTip = 'Specifies if refund is allowed for selected POS Payment Method.';
                    ApplicationArea = NPRRetail;
                }

            }
            group(EFT)
            {
                Caption = 'EFT';
                Visible = Rec."Processing Type" = Rec."Processing Type"::EFT;
                field("Forced Amount"; Rec."Forced Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if amount is forced when using selected POS Payment Method in transaction or you can enter the amount yourself. Works on POS Payment Methods type EFT.';
                }
                field("Match Sales Amount"; Rec."Match Sales Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if EFT Terminal matches amount of POS Transaction.';
                }
                field("EFT Surcharge Service Item No."; Rec."EFT Surcharge Service Item No.")
                {

                    ToolTip = 'Specifies which Service Item will be used for EFT Surcharge.';
                    ApplicationArea = NPRRetail;
                }
                field("EFT Tip Service Item No."; Rec."EFT Tip Service Item No.")
                {

                    ToolTip = 'Specifies which Service Item will be used for EFT Tip.';
                    ApplicationArea = NPRRetail;
                }
            }

            group(Vouchers)
            {
                Caption = 'Vouchers';
                Visible = Rec."Processing Type" = Rec."Processing Type"::VOUCHER;
                field("Reverse Unrealized VAT"; Rec."Reverse Unrealized VAT")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if Unrealized VAT will be reversed when posting Payment line.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            Action(POSPostingSetup)
            {
                Caption = 'POS Posting Setup';
                Image = GeneralPostingSetup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Posting Setup";
                RunPageLink = "POS Payment Method Code" = field(Code);

                ToolTip = 'Action opens POS Posting Setup for selected POS Payment Method';
                ApplicationArea = NPRRetail;
            }
            Action(Denominations)
            {
                Caption = 'Denominations';
                Image = Currency;
                ShortCutKey = 'Ctrl+F5';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Payment Method Denom";
                RunPageLink = "POS Payment Method Code" = field(Code);

                ToolTip = 'Executes the Denominations action';
                ApplicationArea = NPRRetail;
            }
            group(History)
            {
                Caption = 'History';
                Action("POS Payment Lines")
                {
                    Caption = 'POS Payment Lines';
                    Image = LedgerEntries;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "NPR POS Entry Pmt. Line List";
                    RunPageLink = "POS Payment Method Code" = field(Code);

                    ToolTip = 'Action opens POS Payment Lines for selected POS Payment Method.';
                    ApplicationArea = NPRRetail;
                }
                action(Statistics)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F7';
                    ToolTip = 'View statistical information, such as the value of posted entries, for the record.';

                    trigger OnAction()
                    var
                        POSEntryStatistics: Record "NPR POS Entry Statistics";
                    begin
                        POSEntryStatistics.Calculate(Rec);
                        POSEntryStatistics.SetFilter("POS Payment Method Filter", Rec.Code);
                        Page.Run(POSEntryStatistics.GetPageId(), POSEntryStatistics);
                    end;
                }
            }
        }
    }

    var
        IsPostCondensed: Boolean;
    
    trigger OnAfterGetCurrRecord()
    begin
        IsPostCondensed := Rec."Post Condensed";
    end;
}

