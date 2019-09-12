page 6150671 "POS Entry Factbox"
{
    // NPR5.39/BR  /20180129  CASE 302696 Object Created

    Caption = 'POS Entry Factbox';
    PageType = CardPart;
    SourceTable = "POS Entry";

    layout
    {
        area(content)
        {
            field("Currency Code";"Currency Code")
            {
            }
            field("Item Sales (LCY)";"Item Sales (LCY)")
            {
            }
            field("Discount Amount";"Discount Amount")
            {
            }
            field("Amount Excl. Tax";"Amount Excl. Tax")
            {
            }
            field("Tax Amount";"Tax Amount")
            {
            }
            field("Amount Incl. Tax";"Amount Incl. Tax")
            {
            }
            field("Rounding Amount (LCY)";"Rounding Amount (LCY)")
            {
            }
            field("Sales Quantity";"Sales Quantity")
            {
                DecimalPlaces = 0:2;
            }
            field("Return Sales Quantity";"Return Sales Quantity")
            {
                DecimalPlaces = 0:2;
            }
        }
    }

    actions
    {
    }
}

