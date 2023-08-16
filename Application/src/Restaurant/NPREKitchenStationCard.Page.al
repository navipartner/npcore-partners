page 6150686 "NPR NPRE Kitchen Station Card"
{
    Extensible = False;
    Caption = 'Restaurant Kitchen Station Card';
    PageType = Card;
    SourceTable = "NPR NPRE Kitchen Station";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
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
                    ToolTip = 'Specifies optional information in addition to the description.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014407; Notes)
            {
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
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR NPRE Kitchen Station Slct.";
                RunPageLink = "Restaurant Code" = FIELD("Restaurant Code"),
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
