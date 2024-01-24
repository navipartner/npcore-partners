page 6150757 "NPR POS Receipt Profile"
{
    Extensible = false;
    Caption = 'POS Receipt Profile';
    PageType = Card;
    SourceTable = "NPR POS Receipt Profile";
    UsageCategory = None;
    ContextSensitiveHelpPage = 'docs/retail/pos_profiles/reference/receipt_profile/';


    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies unique identifier for the receipt profile. This code helps distinguish and manage different POS receipt profiles.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies brief description of the POS receipt profile for easy identification and reference.';
                }
                field("Receipt Discount Information"; Rec."Receipt Discount Information")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Choose how discount information should be displayed on the receipt: per line, summary, or no information.';
                }
            }
            group("Digital Receipt")
            {
                Caption = 'Digital Receipt';
                field("Enable Digital Receipt"; Rec."Enable Digital Receipt")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Toggle to enable or disable the entire digital receipt functionality for this profile. When enabled, digital receipts will be generated for transactions using this profile.';

                    trigger OnValidate()
                    var
                        DigitalReceiptSetup: Record "NPR Digital Receipt Setup";
                        CredentialsNotValidLbl: Label 'API Credentials are not valid or not tested.';
                    begin
                        if not Rec."Enable Digital Receipt" then
                            exit;
                        if (DigitalReceiptSetup.Get()) and (DigitalReceiptSetup."Credentials Test Success") then
                            Rec."Enable Digital Receipt" := true
                        else
                            Error(CredentialsNotValidLbl);
                    end;
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
    actions
    {
        area(Processing)
        {
            action(OpenDigitalReceiptSetup)
            {
                Caption = 'Digital Receipt Setup';
                Image = ServiceSetup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Navigate to the Digital Receipt Setup page to Configure API credentials and settings for digital receipts.';
                ApplicationArea = NPRRetail;
                RunObject = Page "NPR Digital Receipt Setup";
            }
        }
    }
}