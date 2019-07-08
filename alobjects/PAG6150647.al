page 6150647 "POS Info POS Entry"
{
    // NPR5.41/THRO/20180424 CASE 312185 Page created

    Caption = 'POS Info POS Entry';
    Editable = false;
    PageType = List;
    SourceTable = "POS Info POS Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Entry No.";"POS Entry No.")
                {
                }
                field("Sales Line No.";"Sales Line No.")
                {
                }
                field("Receipt Type";"Receipt Type")
                {
                }
                field("Entry No.";"Entry No.")
                {
                }
                field("POS Info Code";"POS Info Code")
                {
                }
                field("POS Info";"POS Info")
                {
                }
                field("No.";"No.")
                {
                }
                field(Quantity;Quantity)
                {
                }
                field(Price;Price)
                {
                }
                field("Net Amount";"Net Amount")
                {
                }
                field("Gross Amount";"Gross Amount")
                {
                }
                field("Discount Amount";"Discount Amount")
                {
                }
            }
        }
    }

    actions
    {
    }
}

