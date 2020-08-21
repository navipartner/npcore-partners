page 6060044 "Item Worksheet Variety Values"
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created

    Caption = 'Item Worksheet Variety Values';
    PageType = List;
    SourceTable = "Item Worksheet Variety Value";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table"; Table)
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

