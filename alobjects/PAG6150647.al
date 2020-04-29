page 6150647 "POS Info POS Entry"
{
    // NPR5.41/THRO/20180424 CASE 312185 Page created
    // NPR5.53/ALPO/20200204 CASE 387750 Added fields: "Document No.", "Entry Date", "POS Unit No.", "Salesperson Code"

    Caption = 'POS Info POS Entry';
    Editable = false;
    PageType = List;
    SourceTable = "POS Info POS Entry";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Date";"Entry Date")
                {
                }
                field("POS Entry No.";"POS Entry No.")
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field("Sales Line No.";"Sales Line No.")
                {
                }
                field("POS Unit No.";"POS Unit No.")
                {
                }
                field("Salesperson Code";"Salesperson Code")
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

