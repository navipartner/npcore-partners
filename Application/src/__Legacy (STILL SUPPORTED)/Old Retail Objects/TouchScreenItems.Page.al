page 6014525 "NPR Touch Screen - Items"
{
    // NPR4.14/TS/20150805 CASE 219343 Added Field Vendor Item No.
    // NPR4.15/RMT/20150909 CASE 221106 Added field "Unit Cost"

    Caption = 'Touch Screen - Select item';
    CardPageID = "NPR Retail Item Card";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = Item;

    layout
    {
        area(content)
        {
            repeater(Control6150624)
            {
                ShowCaption = false;
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(ItemGroupName; ItemGroupName)
                {
                    ApplicationArea = All;
                    Caption = 'Item Group';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Vendor Item No."; "Vendor Item No.")
                {
                    ApplicationArea = All;
                }
                field(VendorName; VendorName)
                {
                    ApplicationArea = All;
                    Caption = 'Vendor';
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                }
                field(Inventory; Inventory)
                {
                    ApplicationArea = All;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Availability)
            {
                Caption = 'Availability';
                Image = Item;
                action("Items b&y Location")
                {
                    Caption = 'Items b&y Location';
                    Image = ItemAvailbyLoc;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        ItemsByLocation: Page "Items by Location";
                    begin
                        ItemsByLocation.SetRecord(Rec);
                        ItemsByLocation.Run;
                    end;
                }
                group("&Item Availability by")
                {
                    Caption = '&Item Availability by';
                    Image = ItemAvailability;
                    action("<Action5>")
                    {
                        Caption = 'Event';
                        Image = "Event";
                        ApplicationArea = All;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItem(Rec, ItemAvailFormsMgt.ByEvent);
                        end;
                    }
                    action(Period)
                    {
                        Caption = 'Period';
                        Image = Period;
                        RunObject = Page "Item Availability by Periods";
                        RunPageLink = "No." = FIELD("No."),
                                      "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                      "Location Filter" = FIELD("Location Filter"),
                                      "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                                      "Variant Filter" = FIELD("Variant Filter");
                        ApplicationArea = All;
                    }
                    action("Variant")
                    {
                        Caption = 'Variant';
                        Image = ItemVariant;
                        RunObject = Page "Item Availability by Variant";
                        RunPageLink = "No." = FIELD("No."),
                                      "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                      "Location Filter" = FIELD("Location Filter"),
                                      "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                                      "Variant Filter" = FIELD("Variant Filter");
                        ApplicationArea = All;
                    }
                    action(Location)
                    {
                        Caption = 'Location';
                        Image = Warehouse;
                        RunObject = Page "Item Availability by Location";
                        RunPageLink = "No." = FIELD("No."),
                                      "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                      "Location Filter" = FIELD("Location Filter"),
                                      "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                                      "Variant Filter" = FIELD("Variant Filter");
                        ApplicationArea = All;
                    }
                    action("BOM Level")
                    {
                        Caption = 'BOM Level';
                        Image = BOMLevel;
                        ApplicationArea = All;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItem(Rec, ItemAvailFormsMgt.ByBOM);
                        end;
                    }
                    action(Timeline)
                    {
                        Caption = 'Timeline';
                        Image = Timeline;
                        ApplicationArea = All;

                        trigger OnAction()
                        begin
                            ShowTimelineFromItem(Rec);
                        end;
                    }
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        ItemGroup: Record "NPR Item Group";
        Vendor: Record Vendor;
    begin
        if ItemGroup.Get("NPR Item Group") then;
        ItemGroupName := ItemGroup.Description;

        if Vendor.Get("Vendor No.") then
            VendorName := Vendor.Name
        else
            VendorName := '';
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        RecordCount: Integer;
    begin
        RecordCount := Count;
    end;

    var
        t001: Label 'The item is not ready for sale. Correct the fields on the item card!';
        searchTypeTxt: Label 'Description,Vendor No.,Vendor Item No.,Item Group,Unit price,Item No.';
        SkilledResourceList: Page "Skilled Resource List";
        CalculateStdCost: Codeunit "Calculate Standard Cost";
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        ItemGroupName: Text;
        VendorName: Text;

    procedure GetItemNo() itemno: Code[21]
    begin
        exit("No.");
    end;
}

