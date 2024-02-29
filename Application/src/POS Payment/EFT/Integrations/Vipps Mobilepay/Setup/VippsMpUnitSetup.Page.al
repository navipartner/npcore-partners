page 6151349 "NPR Vipps Mp Unit Setup"
{
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR Vipps Mp Unit Setup";
    Extensible = False;
    Caption = 'Vipps Mobilepay Unit Configuration';

    layout
    {
        area(Content)
        {
            group("POS Unit")
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the POS Unit you are setting the integration up for.';
#if NOT BC17
                    AboutTitle = 'POS Unit No.';
                    AboutText = 'Specifies the POS Unit you are setting the integration up for.';
#endif
                }
                field("POS Unit Name"; Rec."POS Unit Name")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the name POS Unit you are setting the integration up for.';
#if NOT BC17
                    AboutTitle = 'POS Unit Name';
                    AboutText = 'Specifies the name POS Unit you are setting the integration up for.';
#endif
                }
            }
            group(Vipps)
            {
                field("Merchant Store Id"; Rec."Merchant Serial Number")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the unique identifier for your Sales Unit/Store.';
#if NOT BC17
                    AboutTitle = 'Merchant Serial Number (MSN)';
                    AboutText = 'Specifies the unique identifier for your Sales Unit/Store.';
#endif
                }
                field("Merchant Store Name"; Rec."Merchant Store Name")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the Name of the Store';
#if NOT BC17
                    AboutTitle = 'Store name';
                    AboutText = 'Specifies the Name of the Store';
#endif
                }
                field("Static QR ID"; Rec."Merchant Qr Id")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies which static QR the POS Unit should be using for payments.';
#if NOT BC17
                    AboutTitle = 'Static Qr Id';
                    AboutText = 'Specifies which static QR the POS Unit should be using for payments.';
#endif
                }
            }
        }
    }
}