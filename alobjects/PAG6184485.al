page 6184485 "Pepper Card Types"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Card Types';
    PageType = List;
    SourceTable = "Pepper Card Type";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Payment Type POS"; "Payment Type POS")
                {
                    ApplicationArea = All;
                }
                field("Card Type Group Code"; "Card Type Group Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Fees)
            {
                Caption = 'Fees';
                Image = InsertStartingFee;
                RunObject = Page "Pepper Card Type Fees";
                RunPageLink = "Card Type Code" = FIELD(Code);
                RunPageView = SORTING("Card Type Code", "Minimum Amount")
                              ORDER(Ascending);
            }
        }
    }
}

