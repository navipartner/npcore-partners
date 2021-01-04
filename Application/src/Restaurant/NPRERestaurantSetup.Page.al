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
                    ToolTip = 'Specifies the value of the Waiter Pad No. Serie field';
                }
                field("Default Service Flow Profile"; "Default Service Flow Profile")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Service Flow Profile field';
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
                        ToolTip = 'Specifies the value of the Ready for New Guests field';
                    }
                    field("Seat.Status: Occupied"; "Seat.Status: Occupied")
                    {
                        ApplicationArea = All;
                        Caption = 'Occupied';
                        ToolTip = 'Specifies the value of the Occupied field';
                    }
                    field("Seat.Status: Reserved"; "Seat.Status: Reserved")
                    {
                        ApplicationArea = All;
                        Caption = 'Reserved';
                        ToolTip = 'Specifies the value of the Reserved field';
                    }
                    field("Seat.Status: Cleaning Required"; "Seat.Status: Cleaning Required")
                    {
                        ApplicationArea = All;
                        Caption = 'Cleaning Required';
                        ToolTip = 'Specifies the value of the Cleaning Required field';
                    }
                }
            }
            group(KitchenInegration)
            {
                Caption = 'Kitchen Integration';
                field("Auto Send Kitchen Order"; "Auto Send Kitchen Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto Send Kitchen Order field';
                }
                field("Resend All On New Lines"; "Resend All On New Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Resend All On New Lines field';
                }
                field("Serving Step Discovery Method"; "Serving Step Discovery Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serving Step Discovery Method field';
                }
                group(Print)
                {
                    Caption = 'Print';
                    field("Kitchen Printing Active"; "Kitchen Printing Active")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Kitchen Printing Active field';
                    }
                }
                group(KDS)
                {
                    Caption = 'KDS';
                    Visible = ShowKDS;
                    field("KDS Active"; "KDS Active")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the KDS Active field';
                    }
                    field("Order ID Assign. Method"; "Order ID Assign. Method")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Order ID Assign. Method field';
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
                ToolTip = 'Executes the Print Categories action';
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
                ToolTip = 'Executes the Restaurants action';
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
                    ToolTip = 'Executes the Stations action';
                }
                action(KitchenStationSelection)
                {
                    Caption = 'Station Selection Setup';
                    Image = Troubleshoot;
                    RunObject = Page "NPR NPRE Kitchen Station Slct.";
                    RunPageLink = "Restaurant Code" = CONST('');
                    ApplicationArea = All;
                    ToolTip = 'Executes the Station Selection Setup action';
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
