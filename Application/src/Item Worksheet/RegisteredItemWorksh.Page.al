page 6060046 "NPR Registered Item Worksh."
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created

    Caption = 'Registered Item Worksheets';
    Editable = false;
    PageType = List;
    SourceTable = "NPR Registered Item Works.";
    UsageCategory = History;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Worksheet Name"; "Worksheet Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor No. field';
                }
                field("Item Worksheet Template"; "Item Worksheet Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Worksheet Template field';
                }
                field("Registered Date Time"; "Registered Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Registered Date Time field';
                }
                field("Registered by User ID"; "Registered by User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Registered by User ID field';
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
                RunObject = Page "NPR Regist. Item Worksh. Page";
                RunPageLink = "Registered Worksheet No." = FIELD("No.");
                RunPageView = SORTING("Registered Worksheet No.", "Line No.")
                              ORDER(Ascending);
                ApplicationArea = All;
                ToolTip = 'Executes the View Registered Item Worksheet action';
            }
        }
    }

    var
        ItemWorksheetManagement: Codeunit "NPR Item Worksheet Mgt.";
}

