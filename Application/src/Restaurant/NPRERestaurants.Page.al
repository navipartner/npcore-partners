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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Name 2"; Rec."Name 2")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Name 2 field';
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
                action(KitchenStations)
                {
                    Caption = 'Stations';
                    Image = Departments;
                    RunObject = Page "NPR NPRE Kitchen Stations";
                    RunPageLink = "Restaurant Code" = FIELD(Code);

                    ToolTip = 'Executes the Stations action';
                    ApplicationArea = NPRRetail;
                }
                action(KitchenStationSelection)
                {
                    Caption = 'Station Selection Setup';
                    Image = Troubleshoot;
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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Scope = Repeater;
                    Visible = ShowRequests;

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
                action(Locations)
                {
                    Caption = 'Locations';
                    Image = Zones;
                    RunObject = Page "NPR NPRE Seating Location";
                    RunPageLink = "Restaurant Code" = FIELD(Code);

                    ToolTip = 'Executes the Locations action';
                    ApplicationArea = NPRRetail;
                }
                action(Seatings)
                {
                    Caption = 'Seatings';
                    Image = Lot;

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
    begin
        ShowRequests := not CurrPage.LookupMode;
    end;

    var
        ShowRequests: Boolean;
}
