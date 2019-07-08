page 6059947 "Sales Price Maintenance Groups"
{
    // NPR5.33/NPKNAV/20170630  CASE 272906 Transport NPR5.33 - 30 June 2017

    Caption = 'Sales Price Maintenance Groups';
    PageType = List;
    SourceTable = "Sales Price Maintenance Groups";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item Group";"Item Group")
                {
                }
                field(Description;Description)
                {
                }
            }
        }
    }

    actions
    {
    }
}

