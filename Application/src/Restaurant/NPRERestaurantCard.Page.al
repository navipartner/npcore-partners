page 6150684 "NPR NPRE Restaurant Card"
{
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
                    ToolTip = 'Specifies the value of the Name 2 field';
                }
                field("Service Flow Profile"; Rec."Service Flow Profile")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Service Flow Profile field';
                }
            }
            group("Kitchen Integration")
            {
                Caption = 'Kitchen Integration';
                field("Auto Send Kitchen Order"; Rec."Auto Send Kitchen Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto Send Kitchen Order field';
                }
                field("Resend All On New Lines"; Rec."Resend All On New Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Resend All On New Lines field';
                }
                group(Print)
                {
                    Caption = 'Print';
                    field("Kitchen Printing Active"; Rec."Kitchen Printing Active")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Kitchen Printing Active field';
                    }
                }
                group(KDS)
                {
                    Caption = 'KDS';
                    Visible = ShowKDS;
                    field("KDS Active"; Rec."KDS Active")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the KDS Active field';
                    }
                    field("Order ID Assign. Method"; Rec."Order ID Assign. Method")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Order ID Assign. Method field';
                    }
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014412; Notes)
            {
                ApplicationArea = All;
            }
            systempart(Control6014413; Links)
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
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "NPR NPRE Kitchen Stations";
                    RunPageLink = "Restaurant Code" = FIELD(Code);
                    ApplicationArea = All;
                    ToolTip = 'Executes the Stations action';
                }
                action(KitchenStationSelection)
                {
                    Caption = 'Station Selection Setup';
                    Image = Troubleshoot;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
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
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Scope = Repeater;
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
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "NPR NPRE Seating Location";
                    RunPageLink = "Restaurant Code" = FIELD(Code);
                    ApplicationArea = All;
                    ToolTip = 'Executes the Locations action';
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
    var
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
    begin
        ShowKDS := KitchenOrderMgt.KDSAvailable();
    end;

    var
        ShowKDS: Boolean;
}
