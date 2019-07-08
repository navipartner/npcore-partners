page 6060008 "GIM - Data Type Properties"
{
    Caption = 'GIM - Data Type Properties';
    PageType = List;
    SourceTable = "GIM - Data Type Property";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Property;Property)
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

