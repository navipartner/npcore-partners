page 6059973 "Variety Value"
{
    Caption = 'Variety Value';
    PageType = List;
    SourceTable = "Variety Value";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type;Type)
                {
                    Visible = false;
                }
                field("Table";Table)
                {
                    Visible = false;
                }
                field(Value;Value)
                {
                }
                field("Sort Order";"Sort Order")
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

