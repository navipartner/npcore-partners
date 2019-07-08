page 6060046 "Registered Item Worksheets"
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created

    Caption = 'Registered Item Worksheets';
    Editable = false;
    PageType = List;
    SourceTable = "Registered Item Worksheet";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No.";"No.")
                {
                }
                field("Worksheet Name";"Worksheet Name")
                {
                }
                field(Description;Description)
                {
                }
                field("Vendor No.";"Vendor No.")
                {
                }
                field("Item Worksheet Template";"Item Worksheet Template")
                {
                }
                field("Registered Date Time";"Registered Date Time")
                {
                }
                field("Registered by User ID";"Registered by User ID")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("View Registered Item Worksheet")
            {
                Caption = 'View Registered Item Worksheet';
                Image = Worksheet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Registered Item Worksheet Page";
                RunPageLink = "Registered Worksheet No."=FIELD("No.");
                RunPageView = SORTING("Registered Worksheet No.","Line No.")
                              ORDER(Ascending);
            }
        }
    }

    var
        ItemWorksheetManagement: Codeunit "Item Worksheet Management";
}

