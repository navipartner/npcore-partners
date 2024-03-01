page 6151463 "NPR Vipps Mp QrCallback"
{
    PageType = Card;
    Caption = 'Vipps Mobilepay Static QR';
    UsageCategory = None;
    Extensible = False;
    InsertAllowed = False;
    DeleteAllowed = False;
    SourceTable = "NPR Vipps Mp QrCallback";

    layout
    {
        area(Content)
        {
            field("Location Description"; Rec."Location Description")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the Location Description, which is displayed on the user device during a payment.';
            }
            field("Merchant Qr Id"; Rec."Merchant Qr Id")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the unique identifier of the static QR.';
                Editable = IsMobilePaySetup;
            }
            field("Merchant Serial Number"; Rec."Merchant Serial Number")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies which MSN the static QR belongs too.';
                Editable = false;
            }

            field("Qr Content"; Rec."Qr Content")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies what the QR code contains.';
                Editable = False;
            }
        }
    }



    internal procedure SetMobilePaySetup()
    begin
        IsMobilePaySetup := True;
    end;

    var
        IsMobilePaySetup: Boolean;
}