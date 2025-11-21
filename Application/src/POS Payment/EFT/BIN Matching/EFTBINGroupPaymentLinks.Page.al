page 6248199 "NPR EFT BIN Group PaymentLinks"
{
    Extensible = False;
    Caption = 'EFT Mapping Group Payment Links';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR EFT BIN Group Payment Link";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the value of the Location Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Type POS"; Rec."Payment Type POS")
                {
                    ToolTip = 'Specifies the value of the Payment Type POS field';
                    ApplicationArea = NPRRetail;
                }
                field("From Payment Type POS"; Rec."From Payment Type POS")
                {
                    ToolTip = 'Specifies the value of the From Payment Type POS field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}