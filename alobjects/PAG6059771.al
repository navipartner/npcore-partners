page 6059771 "Member Card Types"
{
    Caption = 'Point Card - Types';
    CardPageID = "Member Card Types Card";
    PageType = List;
    SourceTable = "Member Card Types";

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

