page 6150669 "NPR NPRE Restaurant Setup"
{
    Caption = 'Restaurant Setup';
    PageType = Card;
    SourceTable = "NPR NPRE Restaurant Setup";
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Waiter Pad No. Serie"; "Waiter Pad No. Serie")
                {
                    ApplicationArea = All;
                }
                field("Default Service Flow Profile"; "Default Service Flow Profile")
                {
                    ApplicationArea = All;
                }
            }
            group(Seating)
            {
                Caption = 'Seating';
                group(Statuses)
                {
                    Caption = 'Statuses';
                    field("Seat.Status: Ready"; "Seat.Status: Ready")
                    {
                        ApplicationArea = All;
                        Caption = 'Ready for New Guests';
                    }
                    field("Seat.Status: Occupied"; "Seat.Status: Occupied")
                    {
                        ApplicationArea = All;
                        Caption = 'Occupied';
                    }
                    field("Seat.Status: Reserved"; "Seat.Status: Reserved")
                    {
                        ApplicationArea = All;
                        Caption = 'Reserved';
                    }
                    field("Seat.Status: Cleaning Required"; "Seat.Status: Cleaning Required")
                    {
                        ApplicationArea = All;
                        Caption = 'Cleaning Required';
                    }
                }
            }
            group(KitchenInegration)
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
                field("Serving Step Discovery Method"; "Serving Step Discovery Method")
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
            part(PrintTemplates; "NPR NPRE Print Templ. Subpage")
            {
                Caption = 'Print Templates';
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Print Categories")
            {
                Caption = 'Print Categories';
                Image = PrintForm;
                RunObject = Page "NPR NPRE Slct Prnt Cat.";
                ApplicationArea = All;
            }
            action(Restaurants)
            {
                Caption = 'Restaurants';
                Image = NewBranch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR NPRE Restaurants";
                ApplicationArea = All;
            }
            group(Kitchen)
            {
                Caption = 'Kitchen';
                action(KitchenStations)
                {
                    Caption = 'Stations';
                    Image = Departments;
                    RunObject = Page "NPR NPRE Kitchen Stations";
                    RunPageLink = "Restaurant Code" = CONST('');
                    ApplicationArea = All;
                }
                action(KitchenStationSelection)
                {
                    Caption = 'Station Selection Setup';
                    Image = Troubleshoot;
                    RunObject = Page "NPR NPRE Kitchen Station Slct.";
                    RunPageLink = "Restaurant Code" = CONST('');
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
    begin
        if not Get() then
            Insert();

        ShowKDS := KitchenOrderMgt.KDSAvailable();
    end;

    var
        ShowKDS: Boolean;
}
