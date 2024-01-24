page 6151321 "NPR POS Receipt Profiles"
{
    Extensible = false;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    Caption = 'POS Receipt Profiles';
    PageType = List;
    Editable = false;
    SourceTable = "NPR POS Receipt Profile";
    CardPageID = "NPR POS Receipt Profile";
    ContextSensitiveHelpPage = 'docs/retail/pos_profiles/reference/receipt_profile/';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies unique identifier for the receipt profile. This code helps distinguish and manage different POS receipt profiles.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies brief description of the POS receipt profile for easy identification and reference.';
                }
                field("Enable Digital Receipt"; Rec."Enable Digital Receipt")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Toggle to enable or disable the entire digital receipt functionality for this profile. When enabled, digital receipts will be generated for transactions using this profile.';
                }
                field("Receipt Discount Information"; Rec."Receipt Discount Information")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Choose how discount information should be displayed on the receipt: per line, summary, or no information.';
                }
                field("QRCode Timeout Interval Enabled"; Rec."QRCode Time Interval Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Toggle to automatically close the QR code displayed at the end of a transaction. When enabled, the QR code will close based on the specified timeout interval.';
                }
                field("QRCode Timeout Interval(sec.)"; Rec."QRCode Timeout Interval(sec.)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Set the timeout interval, in seconds, for automatically closing the QR code at the end of a transaction. Defines the duration before the QR code is automatically closed.';
                }
            }
        }
    }
}
