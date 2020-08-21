page 6150669 "NPRE Restaurant Setup"
{
    // NPR5.34/ANEN /2017012 CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.41/THRO/20180412 CASE 309873 Replaced 2 template fields by a listpart page for setup of multiple templates
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Restaurant Setup';
    PageType = Card;
    SourceTable = "NPRE Restaurant Setup";
    UsageCategory = Administration;

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
            part(PrintTemplates; "NPRE Print Templates Subpage")
            {
                Caption = 'Print Templates';
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
                RunObject = Page "NPRE Select Print Categories";
            }
            action(Restaurants)
            {
                Caption = 'Restaurants';
                Image = NewBranch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPRE Restaurants";
            }
            group(Kitchen)
            {
                Caption = 'Kitchen';
                action(KitchenStations)
                {
                    Caption = 'Stations';
                    Image = Departments;
                    RunObject = Page "NPRE Kitchen Stations";
                    RunPageLink = "Restaurant Code" = CONST('');
                }
                action(KitchenStationSelection)
                {
                    Caption = 'Station Selection Setup';
                    Image = Troubleshoot;
                    RunObject = Page "NPRE Kitchen Station Selection";
                    RunPageLink = "Restaurant Code" = CONST('');
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        KitchenOrderMgt: Codeunit "NPRE Kitchen Order Mgt.";
    begin
        ShowKDS := KitchenOrderMgt.KDSAvailable();
    end;

    var
        ShowKDS: Boolean;
}

