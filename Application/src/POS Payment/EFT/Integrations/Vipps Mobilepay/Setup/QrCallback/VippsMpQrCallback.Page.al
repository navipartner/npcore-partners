page 6151463 "NPR Vipps Mp QrCallback"
{
    PageType = Card;
    Caption = 'Vipps Mobilepay Static QR';
    UsageCategory = None;
    Extensible = False;
    InsertAllowed = True;
    DeleteAllowed = False;
    SourceTable = "NPR Vipps Mp QrCallback";

    layout
    {
        area(Content)
        {
            field("Merchant Qr Id"; Rec."Merchant Qr Id")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the unique identifier of the new static QR or the old beacon id from the old integration.';
                Editable = CanChangeId;
            }
            field("Location Description"; Rec."Location Description")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the Location Description, which is displayed on the user device during a payment.';
            }
            field("Merchant Serial Number"; Rec."Merchant Serial Number")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies which MSN the static QR belongs too.';
                TableRelation = "NPR Vipps Mp Store";
                Editable = CanChangeMsn;
            }
        }
    }
    trigger OnOpenPage()
    begin
        CanChangeMsn := Rec."Merchant Serial Number" = '';
        CanChangeId := Rec."Merchant Qr Id" = '';
    end;

    var
        CanChangeMsn: Boolean;
        CanChangeId: Boolean;
}