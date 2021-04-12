page 6150683 "NPR NPRE Restaurants"
{
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
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Name 2"; Rec."Name 2")
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
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Scope = Repeater;
                    Visible = ShowRequests;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Kitchen Requests (Expedite View) action';

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
