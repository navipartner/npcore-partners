page 6151059 "Distribution Lines"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    AutoSplitKey = true;
    Caption = 'Distribution Lines';
    PageType = List;
    SourceTable = "Distribution Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Distribution Line";"Distribution Line")
                {
                }
                field("Distribution Item";"Distribution Item")
                {
                }
                field("Item Variant";"Item Variant")
                {
                }
                field(Location;Location)
                {
                }
                field(Description;Description)
                {
                }
                field("Distribution Group Member";"Distribution Group Member")
                {
                }
                field("Action Required";"Action Required")
                {
                    Visible = false;
                }
                field("Distribution Quantity";"Distribution Quantity")
                {
                }
                field("Avaliable Quantity";"Avaliable Quantity")
                {
                }
                field("Demanded Quantity";"Demanded Quantity")
                {
                }
                field("Org. Distribution Quantity";"Org. Distribution Quantity")
                {
                }
                field("Distribution Cost Value (LCY)";"Distribution Cost Value (LCY)")
                {
                }
                field("Date Created";"Date Created")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
        }
    }
}

