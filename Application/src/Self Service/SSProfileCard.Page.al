page 6150699 "NPR SS Profile Card"
{
    Extensible = False;
    Caption = 'POS Self Service Profile';
    PageType = Card;
    SourceTable = "NPR SS Profile";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Kiosk Mode Unlock PIN"; Rec."Kiosk Mode Unlock PIN")
                {

                    ToolTip = 'Specifies the value of the Kios Mode Unlock PIN field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Payments)
            {
                Caption = 'Payment Methods';
                field("QR Card Payment Method"; Rec."QR Card Payment Method")
                {
                    ToolTip = 'Specifies the default POS payment method to use for QR code card payments in self-service scenarios. This can be mapped to a more specific card payment method via EFT BIN matching.';
                    ApplicationArea = NPRRetail;
                }
                field("Selfservice Card Payment Meth."; Rec."Selfservice Card Payment Meth.")
                {
                    ToolTip = 'Specifies the POS payment method used for selfservice EFT terminal payments. This payment method is used to find the EFT Setup when preparing API-driven card transactions.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }


}
