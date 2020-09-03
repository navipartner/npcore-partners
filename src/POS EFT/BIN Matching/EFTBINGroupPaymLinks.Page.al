page 6184512 "NPR EFT BIN Group Paym. Links"
{
    // NPR5.42/NPKNAV/20180525  CASE 306689 Transport NPR5.42 - 25 May 2018

    Caption = 'EFT BIN Group Payment Links';
    PageType = ListPart;
    SourceTable = "NPR EFT BIN Group Paym. Link";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field("Payment Type POS"; "Payment Type POS")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

