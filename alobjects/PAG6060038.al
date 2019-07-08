page 6060038 "GIM - Data Format List"
{
    Caption = 'GIM - Data Format List';
    CardPageID = "GIM - Data Format Card";
    PageType = List;
    SourceTable = "GIM - Data Format";

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
            }
        }
    }

    actions
    {
    }
}

