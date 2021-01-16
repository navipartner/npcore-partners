page 6150683 "NPR NPRE Restaurants"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant
    // NPR5.55/ALPO/20200803 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Restaurants';
    CardPageID = "NPR NPRE Restaurant Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NPRE Restaurant";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Name 2"; "Name 2")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Name 2 field';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014406; Notes)
            {
                Visible = false;
                ApplicationArea = All;
            }
            systempart(Control6014407; Links)
            {
                Visible = false;
                ApplicationArea = All;
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Stations action';
                }
                action(KitchenStationSelection)
                {
                    Caption = 'Station Selection Setup';
                    Image = Troubleshoot;
                    RunObject = Page "NPR NPRE Kitchen Station Slct.";
                    RunPageLink = "Restaurant Code" = FIELD(Code);
                    ApplicationArea = All;
                    ToolTip = 'Executes the Station Selection Setup action';
                }
                action(ShowKitchenRequests)
                {
                    Caption = 'Kitchen Requests (Expedite View)';
                    Image = BlanketOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Scope = Repeater;
                    Visible = ShowRequests;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Kitchen Requests (Expedite View) action';

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
                    RunObject = Page "NPR NPRE Seating Location";
                    RunPageLink = "Restaurant Code" = FIELD(Code);
                    ApplicationArea = All;
                    ToolTip = 'Executes the Locations action';
                }
                action(Seatings)
                {
                    Caption = 'Seatings';
                    Image = Lot;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Seatings action';

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
    begin
        ShowRequests := not CurrPage.LookupMode;  //NPR5.55 [382428]
    end;

    var
        ShowRequests: Boolean;
}

