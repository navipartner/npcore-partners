page 6014463 "NPR Item ListPart"
{
    Extensible = False;
    Caption = 'Items';
    CardPageID = "Item Card";
    Editable = false;
    PageType = ListPart;
    PromotedActionCategories = 'New,Process,Report,Item,History,Special Prices & Discounts,Request Approval,Periodic Activities,Inventory,Attributes';
    RefreshOnActivate = true;
    SourceTable = Item;
    UsageCategory = None;
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                Caption = 'Item';
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the number of the item.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies a description of the item.';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies if the item card represents a physical inventory unit (Inventory), a labor time unit (Service), or a physical unit that is not tracked in inventory (Non-Inventory).';
                    Visible = IsFoundationEnabled;
                    ApplicationArea = NPRRetail;
                }
                field(InventoryField; Rec.Inventory)
                {

                    HideValue = IsNonInventoriable;
                    ToolTip = 'Specifies how many units, such as pieces, boxes, or cans, of the item are in inventory.';
                    ApplicationArea = NPRRetail;
                }
                field("Created From Nonstock Item"; Rec."Created From Nonstock Item")
                {

                    ToolTip = 'Specifies that the item was created from a catalog item.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Substitutes Exist"; Rec."Substitutes Exist")
                {

                    ToolTip = 'Specifies that a substitute exists for this item.';
                    ApplicationArea = NPRRetail;
                }
                field("Stockkeeping Unit Exists"; Rec."Stockkeeping Unit Exists")
                {

                    ToolTip = 'Specifies that a stockkeeping unit exists for this item.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Assembly BOM"; Rec."Assembly BOM")
                {
                    AccessByPermission = TableData "BOM Component" = R;

                    ToolTip = 'Specifies if the item is an assembly BOM.';
                    ApplicationArea = NPRRetail;
                }
                field("Production BOM No."; Rec."Production BOM No.")
                {

                    ToolTip = 'Specifies the number of the production BOM that the item represents.';
                    ApplicationArea = NPRRetail;
                }
                field("Routing No."; Rec."Routing No.")
                {

                    ToolTip = 'Specifies the number of the production routing that the item is used in.';
                    ApplicationArea = NPRRetail;
                }
                field("Base Unit of Measure"; Rec."Base Unit of Measure")
                {

                    ToolTip = 'Specifies the base unit used to measure the item, such as piece, box, or pallet. The base unit of measure also serves as the conversion basis for alternate units of measure.';
                    ApplicationArea = NPRRetail;
                }
                field("Shelf No."; Rec."Shelf No.")
                {

                    ToolTip = 'Specifies where to find the item in the warehouse. This is informational only.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Costing Method"; Rec."Costing Method")
                {

                    ToolTip = 'Specifies how the item''s cost flow is recorded and whether an actual or budgeted value is capitalized and used in the cost calculation.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Cost is Adjusted"; Rec."Cost is Adjusted")
                {

                    ToolTip = 'Specifies whether the item''s unit cost has been adjusted, either automatically or manually.';
                    ApplicationArea = NPRRetail;
                }
                field("Standard Cost"; Rec."Standard Cost")
                {

                    ToolTip = 'Specifies the unit cost that is used as an estimation to be adjusted with variances later. It is typically used in assembly and production where costs can vary.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {

                    ToolTip = 'Specifies the cost per unit of the item.';
                    ApplicationArea = NPRRetail;
                }
                field("Last Direct Cost"; Rec."Last Direct Cost")
                {

                    ToolTip = 'Specifies the most recent direct unit cost that was paid for the item.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Price/Profit Calculation"; Rec."Price/Profit Calculation")
                {

                    ToolTip = 'Specifies the relationship between the Unit Cost, Unit Price, and Profit Percentage fields associated with this item.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Profit %"; Rec."Profit %")
                {

                    ToolTip = 'Specifies the profit margin that you want to sell the item at. You can enter a profit percentage manually or have it entered according to the Price/Profit Calculation field';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price"; Rec."Unit Price")
                {

                    ToolTip = 'Specifies the price for one unit of the item, in LCY.';
                    ApplicationArea = NPRRetail;
                }
                field("Inventory Posting Group"; Rec."Inventory Posting Group")
                {

                    ToolTip = 'Specifies links between business transactions made for the item and an inventory account in the general ledger, to group amounts for that item type.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {

                    ToolTip = 'Specifies the item''s product type to link transactions made for this item with the appropriate general ledger account according to the general posting setup.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {

                    ToolTip = 'Specifies the VAT product posting group. Links business transactions made for the item, resource, or G/L account with the general ledger, to account for VAT amounts resulting from trade with that record.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Item Disc. Group"; Rec."Item Disc. Group")
                {

                    ToolTip = 'Specifies an item group code that can be used as a criterion to grant a discount when the item is sold to a certain customer.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Vendor No."; Rec."Vendor No.")
                {

                    ToolTip = 'Specifies the vendor code of who supplies this item by default.';
                    ApplicationArea = NPRRetail;
                }
                field("Vendor Item No."; Rec."Vendor Item No.")
                {

                    ToolTip = 'Specifies the number that the vendor uses for this item.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Tariff No."; Rec."Tariff No.")
                {

                    ToolTip = 'Specifies a code for the item''s tariff number.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Search Description"; Rec."Search Description")
                {

                    ToolTip = 'Specifies a search description that you use to find the item in lists.';
                    ApplicationArea = NPRRetail;
                }
                field("Overhead Rate"; Rec."Overhead Rate")
                {

                    ToolTip = 'Specifies the item''s indirect cost as an absolute amount.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Indirect Cost %"; Rec."Indirect Cost %")
                {

                    ToolTip = 'Specifies the percentage of the item''s last purchase cost that includes indirect costs, such as freight that is associated with the purchase of the item.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {

                    ToolTip = 'Specifies the category that the item belongs to. Item categories also contain any assigned item attributes.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies that transactions with the item cannot be posted, for example, because the item is in quarantine.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {

                    ToolTip = 'Specifies when the item card was last modified.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Sales Unit of Measure"; Rec."Sales Unit of Measure")
                {

                    ToolTip = 'Specifies the unit of measure code used when you sell the item.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Replenishment System"; Rec."Replenishment System")
                {

                    ToolTip = 'Specifies the type of supply order created by the planning system when the item needs to be replenished.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Purch. Unit of Measure"; Rec."Purch. Unit of Measure")
                {

                    ToolTip = 'Specifies the unit of measure code used when you purchase the item.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Lead Time Calculation"; Rec."Lead Time Calculation")
                {

                    ToolTip = 'Specifies a date formula for the amount of time it takes to replenish the item.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Manufacturing Policy"; Rec."Manufacturing Policy")
                {

                    ToolTip = 'Specifies if additional orders for any related components are calculated.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Flushing Method"; Rec."Flushing Method")
                {

                    ToolTip = 'Specifies how consumption of the item (component) is calculated and handled in production processes. Manual: Enter and post consumption in the consumption journal manually. Forward: Automatically posts consumption according to the production order component lines when the first operation starts. Backward: Automatically calculates and posts consumption according to the production order component lines when the production order is finished. Pick + Forward / Pick + Backward: Variations with warehousing.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Assembly Policy"; Rec."Assembly Policy")
                {

                    ToolTip = 'Specifies which default order flow is used to supply this assembly item.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Item Tracking Code"; Rec."Item Tracking Code")
                {
                    ToolTip = 'Specifies how items are tracked in the supply chain.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Default Deferral Template Code"; Rec."Default Deferral Template Code")
                {

                    Caption = 'Default Deferral Template';
                    Importance = Additional;
                    ToolTip = 'Specifies the default template that governs how to defer revenues and expenses to the periods when they occurred.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        EnableControls();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        Found: Boolean;
    begin
        if RunOnTempRec then begin
            TempItemFilteredFromAttributes.Copy(Rec);
            Found := TempItemFilteredFromAttributes.Find(Which);
            if Found then
                Rec := TempItemFilteredFromAttributes;
            exit(Found);
        end;
        exit(Rec.Find(Which));
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        ResultSteps: Integer;
    begin
        if RunOnTempRec then begin
            TempItemFilteredFromAttributes.Copy(Rec);
            ResultSteps := TempItemFilteredFromAttributes.Next(Steps);
            if ResultSteps <> 0 then
                Rec := TempItemFilteredFromAttributes;
            exit(ResultSteps);
        end;
        exit(Rec.Next(Steps));
    end;

    trigger OnOpenPage()
    begin
        IsFoundationEnabled := ApplicationAreaMgmtFacade.IsFoundationEnabled();
    end;

    var
        TempItemFilteredFromAttributes: Record Item temporary;
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        IsFoundationEnabled: Boolean;
        RunOnTempRec: Boolean;
        [InDataSet]
        IsNonInventoriable: Boolean;

    procedure SelectInItemList(var Item: Record Item): Text
    var
        ItemListPage: Page "Item List";
    begin
        Item.SetRange(Blocked, false);
        ItemListPage.SetTableView(Item);
        ItemListPage.LookupMode(true);
        if ItemListPage.RunModal() = ACTION::LookupOK then
            exit(ItemListPage.GetSelectionFilter());
    end;

    local procedure EnableControls()
    begin
        IsNonInventoriable := Rec.IsNonInventoriableType();
    end;


}
