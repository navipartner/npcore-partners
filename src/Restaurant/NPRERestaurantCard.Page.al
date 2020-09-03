page 6150684 "NPR NPRE Restaurant Card"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale
    // NPR5.55/ALPO/20200803 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Restaurant Card';
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Kitchen,Layout';
    SourceTable = "NPR NPRE Restaurant";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Name 2"; "Name 2")
                {
                    ApplicationArea = All;
                }
                field("Service Flow Profile"; "Service Flow Profile")
                {
                    ApplicationArea = All;
                }
            }
            group("Kitchen Integration")
            {
                Caption = 'Kitchen Integration';
                field("Auto Send Kitchen Order"; "Auto Send Kitchen Order")
                {
                    ApplicationArea = All;
                }
                field("Resend All On New Lines"; "Resend All On New Lines")
                {
                    ApplicationArea = All;
                }
                group(Print)
                {
                    Caption = 'Print';
                    field("Kitchen Printing Active"; "Kitchen Printing Active")
                    {
                        ApplicationArea = All;
                    }
                }
                group(KDS)
                {
                    Caption = 'KDS';
                    Visible = ShowKDS;
                    field("KDS Active"; "KDS Active")
                    {
                        ApplicationArea = All;
                    }
                    field("Order ID Assign. Method"; "Order ID Assign. Method")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014412; Notes)
            {
            }
            systempart(Control6014413; Links)
            {
                Visible = false;
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
                action(KitchenStations)
                {
                    Caption = 'Stations';
                    Image = Departments;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "NPR NPRE Kitchen Stations";
                    RunPageLink = "Restaurant Code" = FIELD(Code);
                }
                action(KitchenStationSelection)
                {
                    Caption = 'Station Selection Setup';
                    Image = Troubleshoot;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "NPR NPRE Kitchen Station Slct.";
                    RunPageLink = "Restaurant Code" = FIELD(Code);
                }
                action(ShowKitchenRequests)
                {
                    Caption = 'Kitchen Requests (Expedite View)';
                    Image = BlanketOrder;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Scope = Repeater;

                    trigger OnAction()
                    var
                        KitchenRequest: Record "NPR NPRE Kitchen Request";
                        KitchenRequests: Page "NPR NPRE Kitchen Req.";
                    begin
                        Rec.ShowKitchenRequests();  //NPR5.55 [382428]
                    end;
                }
            }
            group(Layout)
            {
                Caption = 'Layout';
                action(Locations)
                {
                    Caption = 'Locations';
                    Image = Zones;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "NPR NPRE Seating Location";
                    RunPageLink = "Restaurant Code" = FIELD(Code);
                }
                action(Seatings)
                {
                    Caption = 'Seatings';
                    Enabled = (Code <> '');
                    Image = Lot;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        Seating: Record "NPR NPRE Seating";
                        SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
                    begin
                        //-NPR5.55 [382428]
                        TestField(Code);
                        Seating.SetFilter("Seating Location", SeatingMgt.RestaurantSeatingLocationFilter(Code));
                        PAGE.Run(0, Seating);
                        //+NPR5.55 [382428]
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

