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
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Worksheet Name"; "Worksheet Name")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Item Worksheet Template"; "Item Worksheet Template")
                {
                    ApplicationArea = All;
                }
                field("Registered Date Time"; "Registered Date Time")
                {
                    ApplicationArea = All;
                }
                field("Registered by User ID"; "Registered by User ID")
                {
                    ApplicationArea = All;
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
                RunPageLink = "Registered Worksheet No." = FIELD("No.");
                RunPageView = SORTING("Registered Worksheet No.", "Line No.")
                              ORDER(Ascending);
            }
        }
    }

    var
        ItemWorksheetManagement: Codeunit "Item Worksheet Management";
}

