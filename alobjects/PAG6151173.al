page 6151173 "NpGp POS Info POS Entry"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales

    Caption = 'Global POS Info Entries';
    Editable = false;
    PageType = List;
    SourceTable = "NpGp POS Info POS Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                field("Sales Line No.";"Sales Line No.")
                {
                }
                field("POS Entry No.";"POS Entry No.")
                {
                }
                field("Entry No.";"Entry No.")
                {
                }
            }
        }
    }

    actions
    {
    }
}

