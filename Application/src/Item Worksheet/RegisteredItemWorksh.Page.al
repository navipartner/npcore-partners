page 6060046 "NPR Registered Item Worksh."
{
    Caption = 'Registered Item Worksheets';
    Editable = false;
    PageType = List;
    SourceTable = "NPR Registered Item Works.";
    UsageCategory = History;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Worksheet Name"; Rec."Worksheet Name")
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Vendor No."; Rec."Vendor No.")
                {

                    ToolTip = 'Specifies the value of the Vendor No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Worksheet Template"; Rec."Item Worksheet Template")
                {

                    ToolTip = 'Specifies the value of the Item Worksheet Template field';
                    ApplicationArea = NPRRetail;
                }
                field("Registered Date Time"; Rec."Registered Date Time")
                {

                    ToolTip = 'Specifies the value of the Registered Date Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Registered by User ID"; Rec."Registered by User ID")
                {

                    ToolTip = 'Specifies the value of the Registered by User ID field';
                    ApplicationArea = NPRRetail;
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Regist. Item Worksh. Page";
                RunPageLink = "Registered Worksheet No." = FIELD("No.");
                RunPageView = SORTING("Registered Worksheet No.", "Line No.")
                              ORDER(Ascending);
                ToolTip = 'Executes the View Registered Item Worksheet action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

