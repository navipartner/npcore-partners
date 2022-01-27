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

                    ToolTip = 'Specifies the value of the Name 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Service Flow Profile"; Rec."Service Flow Profile")
                {

                    ToolTip = 'Specifies the value of the Service Flow Profile field';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Kitchen Integration")
            {
                Caption = 'Kitchen Integration';
                field("Auto Send Kitchen Order"; Rec."Auto Send Kitchen Order")
                {

                    ToolTip = 'Specifies the value of the Auto Send Kitchen Order field';
                    ApplicationArea = NPRRetail;
                }
                field("Resend All On New Lines"; Rec."Resend All On New Lines")
                {

                    ToolTip = 'Specifies the value of the Resend All On New Lines field';
                    ApplicationArea = NPRRetail;
                }
                group(Print)
                {
                    Caption = 'Print';
                    field("Kitchen Printing Active"; Rec."Kitchen Printing Active")
                    {

                        ToolTip = 'Specifies the value of the Kitchen Printing Active field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(KDS)
                {
                    Caption = 'KDS';
                    Visible = ShowKDS;
                    field("KDS Active"; Rec."KDS Active")
                    {

                        ToolTip = 'Specifies the value of the KDS Active field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Order ID Assign. Method"; Rec."Order ID Assign. Method")
                    {

                        ToolTip = 'Specifies the value of the Order ID Assign. Method field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Station Req. Handl. On Serving"; Rec."Station Req. Handl. On Serving")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies how kitchen station production requests should be handled, if product has been served prior to finishing production';
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

                    ToolTip = 'Executes the Stations action';
                    ApplicationArea = NPRRetail;
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
