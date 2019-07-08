page 6014582 "Store Groups"
{
    // NPR4.16/TJ/20151115 CASE 222281 Page Created

    Caption = 'Store Groups';
    PageType = List;
    SourceTable = "Store Group";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Blank Location";"Blank Location")
                {
                }
            }
        }
    }

    actions
    {
    }
}

