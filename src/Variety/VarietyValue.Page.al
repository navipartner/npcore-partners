page 6059973 "NPR Variety Value"
{
    Caption = 'Variety Value';
    PageType = List;
    SourceTable = "NPR Variety Value";

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

