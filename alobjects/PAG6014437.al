page 6014437 "Sale POS - Saved Sale Line"
{
    Caption = 'Saved Sales Lines';
    PageType = ListPart;
    SourceTable = "Sale Line POS";

    layout
    {
        area(content)
        {
            repeater("Saved Sales Lines")
            {
                field("No.";"No.")
                {
                }
                field(Description;Description)
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Amount Including VAT";"Amount Including VAT")
                {
                }
            }
        }
    }

    actions
    {
    }
}

