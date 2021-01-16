page 6151534 "NPR Nc Collector Req.Filt.Subf"
{
    // NC2.01\BR\20160909  CASE 250447 Object created

    Caption = 'Nc Collector Req. Filter Subf.';
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field("Filter Text"; "Filter Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filter Text field';
                }
            }
        }
    }

    actions
    {
    }
}

