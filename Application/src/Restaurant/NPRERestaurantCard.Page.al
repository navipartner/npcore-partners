page 6150684 "NPR NPRE Restaurant Card"
{
    Extensible = False;
    Caption = 'Restaurant Card';
    PageType = Card;
    UsageCategory = None;
    PromotedActionCategories = 'New,Process,Report,Kitchen,Layout';
    SourceTable = "NPR NPRE Restaurant";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies a code for the Restaurant.';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the Restaurant.';
                    ApplicationArea = NPRRetail;
                }
                field("Name 2"; Rec."Name 2")
                {
                    ToolTip = 'Specifies optional additional information about the Restaurant name.';
                    ApplicationArea = NPRRetail;
                }
                field("Service Flow Profile"; Rec."Service Flow Profile")
                {
                    ToolTip = 'Specifies the selected Service Flow Profile. A new profile can be created if needed.';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Kitchen Integration")
            {
                Caption = 'Kitchen Integration';
                field("Auto Send Kitchen Order"; Rec."Auto Send Kitchen Order")
                {
                    ToolTip = 'Specifies whether the order will be automatically sent to the kitchen once captured.';
                    ApplicationArea = NPRRetail;
                }
                group(Print)
                {
                    Caption = 'Print';
                    field("Kitchen Printing Active"; Rec."Kitchen Printing Active")
                    {
                        ToolTip = 'Specifies whether the kitchen printing is active.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Resend All On New Lines"; Rec."Resend All On New Lines")
                    {
                        ToolTip = 'Specifies whether all lines on the waiter pad are sent to the kitchen when new lines are added to the waiter pad.';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(KDS)
                {
                    Caption = 'KDS';
                    Visible = ShowKDS;
                    field("KDS Active"; Rec."KDS Active")
                    {
                        ToolTip = 'Specifies whether the KDS is active.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Order ID Assign. Method"; Rec."Order ID Assign. Method")
                    {
                        ToolTip = 'Specifies the assignment method of the order ID.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Station Req. Handl. On Serving"; Rec."Station Req. Handl. On Serving")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies how kitchen station production requests should be handled, if the product has been served prior to finishing production.';
                    }
                    field("Order Is Ready For Serving"; Rec."Order Is Ready For Serving")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies when kitchen order is assigned "Ready for Serving" status';
                    }
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014412; Notes)
            {
                ApplicationArea = NPRRetail;
            }
            systempart(Control6014413; Links)
            {
                Visible = false;
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Kitchen)
            {
                Caption = 'Kitchen';
                Image = Departments;
                action(KitchenStations)
                {
                    Caption = 'Stations';
                    Image = Category;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "NPR NPRE Kitchen Stations";
                    RunPageLink = "Restaurant Code" = FIELD(Code);
                    ToolTip = 'Executes the Stations action';
                    ApplicationArea = NPRRetail;
                }
                action(KitchenStationSelection)
                {
                    Caption = 'Station Selection Setup';
                    Image = Flow;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "NPR NPRE Kitchen Station Slct.";
                    RunPageLink = "Restaurant Code" = FIELD(Code);
                    ToolTip = 'Executes the Station Selection Setup action';
                    ApplicationArea = NPRRetail;
                }
                action(ShowKitchenRequests)
                {
                    Caption = 'Kitchen Requests (Expedite View)';
                    Image = BlanketOrder;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Scope = Repeater;
                    ToolTip = 'Executes the Kitchen Requests (Expedite View) action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ShowKitchenRequests();
                    end;
                }
            }
            group(Layout)
            {
                Caption = 'Layout';
                Image = ServiceZones;
                action(Locations)
                {
                    Caption = 'Locations';
                    Image = Zones;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "NPR NPRE Seating Location";
                    RunPageLink = "Restaurant Code" = FIELD(Code);
                    ToolTip = 'Executes the Locations action';
                    ApplicationArea = NPRRetail;
                }
                action(Seatings)
                {
                    Caption = 'Seatings';
                    Enabled = (Rec.Code <> '');
                    Image = Lot;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ToolTip = 'Executes the Seatings action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        Seating: Record "NPR NPRE Seating";
                        SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
                    begin
                        Rec.TestField(Code);
                        Seating.SetFilter("Seating Location", SeatingMgt.RestaurantSeatingLocationFilter(Rec.Code));
                        PAGE.Run(0, Seating);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
    begin
        ShowKDS := KitchenOrderMgt.KDSAvailable();
    end;

    var
        ShowKDS: Boolean;
}
