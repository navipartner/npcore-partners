page 6184512 "NPR EFT BIN Group Paym. Links"
{
    Caption = 'EFT Mapping Group Payment Links';
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR EFT BIN Group Paym. Link";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field("Payment Type POS"; Rec."Payment Type POS")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Type POS field';
                }
            }
        }
    }
}

