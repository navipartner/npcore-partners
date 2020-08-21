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
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Table"; Table)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Value; Value)
                {
                    ApplicationArea = All;
                }
                field("Sort Order"; "Sort Order")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

