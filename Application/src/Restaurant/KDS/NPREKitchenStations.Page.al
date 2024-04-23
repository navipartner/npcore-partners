page 6150685 "NPR NPRE Kitchen Stations"
{
    Extensible = False;
    Caption = 'Restaurant Kitchen Stations';
    ContextSensitiveHelpPage = 'docs/restaurant/explanation/kitchen/';
    CardPageID = "NPR NPRE Kitchen Station Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NPRE Kitchen Station";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    ToolTip = 'Specifies the restaurant this kitchen station belongs to.';
                    ApplicationArea = NPRRetail;
                }
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies a code to identify this kitchen station.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a text that describes the kitchen station.';
                    ApplicationArea = NPRRetail;
                }
                field("Description 2"; Rec."Description 2")
                {
                    Visible = false;
                    ToolTip = 'Specifies optional information in addition to the description.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014407; Notes)
            {
                Visible = false;
                ApplicationArea = NPRRetail;
            }
            systempart(Control6014408; Links)
            {
                Visible = false;
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(KitchenStationSelection)
            {
                Caption = 'Station Selection Setup';
                Image = Flow;
                RunObject = Page "NPR NPRE Kitchen Station Slct.";
                RunPageLink = "Production Restaurant Code" = FIELD("Restaurant Code"),
                              "Kitchen Station" = FIELD(Code);
                ToolTip = 'View or edit kitchen station selection setup. You can define which kitchen stations should be used to prepare products depending on item categories, serving steps etc.';
                ApplicationArea = NPRRetail;
            }
            action(ShowKitchenRequests)
            {
                Caption = 'Kitchen Requests';
                Image = BlanketOrder;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;
                ToolTip = 'View outstaning kitchen requests for the kitchen station.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.ShowKitchenRequests();
                end;
            }
        }
    }
}
