page 6014553 "Mixed Discount Levels"
{
    // NPR5.55/ALPO/20200714 CASE 412946 Mixed Discount enhancement: support for multiple discount amount levels

    Caption = 'Mix Discount Levels';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Mixed Discount Level";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Mixed Discount Code";"Mixed Discount Code")
                {
                    Visible = false;
                }
                field(Quantity;Quantity)
                {
                }
                field("Multiple Of";"Multiple Of")
                {
                }
                field("Discount Amount";"Discount Amount")
                {
                }
                field("Discount %";"Discount %")
                {
                }
            }
        }
    }

    actions
    {
    }
}

