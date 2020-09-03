page 6060044 "NPR Item Worksh.Vrty. Values"
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created

    Caption = 'Item Worksheet Variety Values';
    PageType = List;
    SourceTable = "NPR Item Worksh. Variety Value";

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

