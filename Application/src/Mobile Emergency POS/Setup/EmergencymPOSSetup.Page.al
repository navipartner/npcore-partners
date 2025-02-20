page 6184928 "NPR Emergency mPOS Setup"
{
    PageType = Card;
    UsageCategory = None;
    Extensible = false;
    SourceTable = "NPR Emergency mPOS Setup";
    CardPageId = "NPR Emergency mPOS Setup";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Code';
                    ToolTip = 'Specifies the unique Id of the Emergency mPOS Setup.';
                }
                field("NP Pay POS Payment Setup"; Rec."NP Pay POS Payment Setup")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'NP Pay POS Payment Setup';
                    ToolTip = 'Specifies the which NP Pay POS Payment setup to use.';
                }
                field("Cash Payment Method"; Rec."Cash Payment Method")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Cash Payment Method Code';
                    ToolTip = 'Specifies which Payment Method code to use for cash payments.';
                }
                field("Card Payment Method"; Rec."EFT Payment Method")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Card Payment Method Code';
                    ToolTip = 'Specifies which Payment Method code to use for card payments.';
                }
                field("SMS Header Template"; Rec."SMS Template")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'SMS Template';
                    ToolTip = 'Specifies which SMS template to use when sending SMS receipt.';
                }
                field("E-mail Header Template"; Rec."Email Template")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Email Template';
                    ToolTip = 'Specifies which Email template to use when sending Email receipt.';
                }
                field("Salespers/Purchaser Code"; Rec."Salespers/Purchaser Code")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Salesperson / Purchaser Code';
                    ToolTip = 'Specifies which Salesperson / Purchaser Code fo which to put the sale under';
                }
                field("CSV Url"; Rec."CSV Url")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'CSV Url';
                    ToolTip = 'Specifies a url from which to download a self-hosted CSV containing Item shortcuts';
                }
            }
            group("Payment Methods")
            {
                part("POS Payment Methods"; "NPR Emergency POS Pay. Methods")
                {
                    Caption = 'Additional POS Payment Methods';
                    ApplicationArea = NPRRetail;
                    SubPageLink = "Emergency POS Setup Code" = field(Code);
                }
            }
        }
    }
}