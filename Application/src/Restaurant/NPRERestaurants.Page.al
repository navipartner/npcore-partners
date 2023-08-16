page 6150683 "NPR NPRE Restaurants"
{
    Extensible = False;
    Caption = 'Restaurants';
    CardPageID = "NPR NPRE Restaurant Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NPRE Restaurant";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                    Visible = false;
                    ToolTip = 'Specifies optional information in addition to the name.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014406; Notes)
            {
                Visible = false;
                ApplicationArea = NPRRetail;
            }
            systempart(Control6014407; Links)
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
                    RunObject = Page "NPR NPRE Kitchen Stations";
                    RunPageLink = "Restaurant Code" = FIELD(Code);
                    ToolTip = 'View restaurant kitchen stations.';
                    ApplicationArea = NPRRetail;
                }
                action(KitchenStationSelection)
                {
                    Caption = 'Station Selection Setup';
                    Image = Flow;
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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Scope = Repeater;
                    Visible = ShowRequests;
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
                    RunObject = Page "NPR NPRE Seating Location";
                    RunPageLink = "Restaurant Code" = FIELD(Code);
                    ToolTip = 'View restaurant seating locations.';
                    ApplicationArea = NPRRetail;
                }
                action(Seatings)
                {
                    Caption = 'Seatings';
                    Image = Lot;
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
    begin
        ShowRequests := not CurrPage.LookupMode;
    end;

    internal procedure GetSelectionFilter(): Text
    var
        Restaurant: Record "NPR NPRE Restaurant";
    begin
        CurrPage.SetSelectionFilter(Restaurant);
        exit(GetSelectionFilter(Restaurant));
    end;

    internal procedure GetSelectionFilter(var Restaurant: Record "NPR NPRE Restaurant"): Text
    var
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Restaurant);
        exit(SelectionFilterManagement.GetSelectionFilter(RecRef, Restaurant.FieldNo(Code)));
    end;

    var
        ShowRequests: Boolean;
}
