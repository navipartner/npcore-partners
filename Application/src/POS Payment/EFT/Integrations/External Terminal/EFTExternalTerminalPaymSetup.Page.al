page 6184520 "NPR EFT Ext. Term. Paym. Setup"
{
    Caption = 'EFT External Terminal Payment Setup';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR EFT Ext. Term. Paym. Setup";
    Extensible = false;
    layout
    {
        area(content)
        {
            group(Popup)
            {
                field("Enable Card Digits Popup"; Rec."Enable Card Digits Popup")
                {
                    ToolTip = 'If Enabled window for entering card digits will pop up.';
                    ApplicationArea = NPRRetail;
                }
                field("Enable Cardholder Popup"; Rec."Enable Cardholder Popup")
                {
                    ToolTip = 'If Enabled window for entering cardholder will pop up.';
                    ApplicationArea = NPRRetail;
                }
                field("Enable Approval Code Popup"; Rec."Enable Approval Code Popup")
                {
                    ToolTip = 'If Enabled window for entering bank approval code will pop up.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

