page 6014685 "NPR Sales Price Maint. Setup"
{
    // NPR5.25/CLVA/20160628 CASE 244461 : Sales Price Maintenance

    AutoSplitKey = true;
    Caption = 'Sales Price Maintenance Setup';
    PageType = List;
    SourceTable = "NPR Sales Price Maint. Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Id; Id)
                {
                    ApplicationArea = All;
                }
                field("Sales Type"; "Sales Type")
                {
                    ApplicationArea = All;
                }
                field("Sales Code"; "Sales Code")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Prices Including VAT"; "Prices Including VAT")
                {
                    ApplicationArea = All;
                }
                field("VAT Bus. Posting Gr. (Price)"; "VAT Bus. Posting Gr. (Price)")
                {
                    ApplicationArea = All;
                }
                field("Allow Invoice Disc."; "Allow Invoice Disc.")
                {
                    ApplicationArea = All;
                }
                field("Allow Line Disc."; "Allow Line Disc.")
                {
                    ApplicationArea = All;
                }
                field("Internal Unit Price"; "Internal Unit Price")
                {
                    ApplicationArea = All;
                }
                field(Factor; Factor)
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

