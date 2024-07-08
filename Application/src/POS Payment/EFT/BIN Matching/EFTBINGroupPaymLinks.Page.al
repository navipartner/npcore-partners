page 6184512 "NPR EFT BIN Group Paym. Links"
{
    Extensible = False;
    Caption = 'EFT Mapping Group Payment Links';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR EFT BIN Group Paym. Link";

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
            }
        }
    }
}

