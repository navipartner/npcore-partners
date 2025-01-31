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
            }
        }
    }
}