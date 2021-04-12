page 6060046 "NPR Registered Item Worksh."
{
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
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Worksheet Name"; Rec."Worksheet Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor No. field';
                }
                field("Item Worksheet Template"; Rec."Item Worksheet Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Worksheet Template field';
                }
                field("Registered Date Time"; Rec."Registered Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Registered Date Time field';
                }
                field("Registered by User ID"; Rec."Registered by User ID")
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
                ApplicationArea = All;
                Caption = 'View Registered Item Worksheet';
                Image = Worksheet;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Regist. Item Worksh. Page";
                RunPageLink = "Registered Worksheet No." = FIELD("No.");
                RunPageView = SORTING("Registered Worksheet No.", "Line No.")
                              ORDER(Ascending);
                ToolTip = 'Executes the View Registered Item Worksheet action';
            }
        }
    }
}

