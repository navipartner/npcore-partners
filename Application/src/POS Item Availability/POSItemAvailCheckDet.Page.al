page 6059852 "NPR POS Item Avail. Check Det."
{
    Extensible = false;
    Caption = 'Availability Check Details';
    PageType = ListPart;
    SourceTable = "NPR POS Item Availability";
    SourceTableTemporary = true;
    Editable = false;
    LinksAllowed = false;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the number of the item.';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies a variant code of the item.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the item.';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the location Code the item is to be taken from.';
                    ApplicationArea = NPRRetail;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ToolTip = 'Specifies the unit of measure code all the quantities are calculated in.';
                    ApplicationArea = NPRRetail;
                }
                field("Available Inventory"; Rec."Available Inventory")
                {
                    Caption = 'Available';
                    ToolTip = 'Specifies the quantity of the item that is currently in inventory and not reserved for other demand.';
                    ApplicationArea = NPRRetail;
                }
                field("Available Inventory (Other)"; Rec."Available Inventory (Other)")
                {
                    Caption = 'Available (Other Locations)';
                    ToolTip = 'Specifies the total quantity of the item that is currently in inventory at all other locations.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        Item: Record Item;
                    begin
                        Item.Get(Rec."Item No.");
                        Item.SetRange("Variant Filter", Rec."Variant Code");
                        Item.SetRange("Location Filter", Rec."Location Code");
                        PAGE.RunModal(PAGE::"Item Availability by Location", Item);
                    end;
                }
                field("Gross Requirement"; Rec."Gross Requirement")
                {
                    ToolTip = 'Specifies the total required quantity of the item for the POS sale transaction.';
                    ApplicationArea = NPRRetail;
                }
                field("Current Quantity"; Rec."Current Quantity")
                {
                    ToolTip = 'Specifies the quantity on current POS sale transaction line.';
                    ApplicationArea = NPRRetail;
                    Visible = CurrentLineQtyColumnVisible;
                }
                field("Inventory Shortage"; Rec."Inventory Shortage")
                {
                    ToolTip = 'Specifies the total quantity of the item/variant at the location that is currently insufficient to cover the demand.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    procedure SetDataset(var PosItemAvailability: Record "NPR POS Item Availability")
    begin
        Rec.Copy(PosItemAvailability, true);
    end;

    procedure SetShowCurrentLineQtyColumn(Set: Boolean)
    begin
        CurrentLineQtyColumnVisible := Set;
    end;

    var
        CurrentLineQtyColumnVisible: Boolean;
}
