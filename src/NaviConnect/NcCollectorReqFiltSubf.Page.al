page 6151534 "NPR Nc Collector Req.Filt.Subf"
{
    // NC2.01\BR\20160909  CASE 250447 Object created

    Caption = 'Nc Collector Req. Filter Subf.';
    PageType = ListPart;
    SourceTable = "NPR Nc Collector Req. Filter";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                }
                field("Filter Text"; "Filter Text")
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

