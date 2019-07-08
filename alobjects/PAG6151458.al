page 6151458 "Magento Attribute Group List"
{
    // MAG2.18/TS  /20180910  CASE 323934 Attribute Group Created

    Caption = 'Attribute Groups';
    Editable = true;
    PageType = List;
    SourceTable = "Magento Attribute Group";
    SourceTableView = SORTING("Attribute Group ID")
                      ORDER(Ascending);
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Attribute Group ID";"Attribute Group ID")
                {
                }
                field(Description;Description)
                {
                }
                field("Attribute Set ID";"Attribute Set ID")
                {
                }
                field("Sort Order";"Sort Order")
                {
                }
            }
        }
    }

    actions
    {
    }
}

