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
                    ToolTip = 'Specifies a code to identify this restaurant.';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies a text that describes the restaurant.';
                    ApplicationArea = NPRRetail;
                }
                field("Name 2"; Rec."Name 2")
                {
                    ToolTip = 'Specifies optional information in addition to the name.';
                    ApplicationArea = NPRRetail;
                }
                field("Service Flow Profile"; Rec."Service Flow Profile")
                {
                    ToolTip = 'Specifies the service flow profile, assigned to the restaurant. Service flow profiles define general restaurant servise flow options, such as at what stage waiter pads should be closed, or when seating should be cleared.';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Kitchen Integration")
            {
                Caption = 'Kitchen Integration';
                field("Auto Send Kitchen Order"; Rec."Auto Send Kitchen Order")
                {
                    ToolTip = 'Specifies if system should automatically create or update kitchen orders as soon as new products are saved to waiter pads.';
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
                        ToolTip = 'Specifies if each time, when a new set of products are saved to a waiter pad, system should resend to kitchen both new and existing products from the waiter pad.';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(KDS)
                {
                    Caption = 'KDS';
                    Visible = ShowKDS;
                    field("KDS Active"; Rec."KDS Active")
                    {
                        ToolTip = 'Specifies whether the Kitchen Display Systme (KDS) is active.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Order ID Assign. Method"; Rec."Order ID Assign. Method")
                    {
                        ToolTip = 'Specifies whether system should update existing kitchen order or create a new one, when a new set of products is added to an existing waiter pad. This can affect the order products are prepared at kitchen stations.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Station Req. Handl. On Serving"; Rec."Station Req. Handl. On Serving")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies how existing kitchen station production requests should be handled, if a product has been served prior to finishing production.';
                    }
                    field("Order Is Ready For Serving"; Rec."Order Is Ready For Serving")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies when kitchen order is assigned "Ready for Serving" status.';
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
                    ToolTip = 'View restaurant kitchen stations.';
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
                    ToolTip = 'View or edit kitchen station selection setup. You can define which kitchen stations should be used to prepare products depending on item categories, serving steps etc.';
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
                    ToolTip = 'View outstaning kitchen requests (expedite view) for the restaurant.';
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
                    ToolTip = 'View restaurant seating locations.';
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
                    ToolTip = 'View seatings defined at the restaurant.';
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
