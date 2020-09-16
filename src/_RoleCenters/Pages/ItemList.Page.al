page 6014463 "NPR Item List"
{
    AdditionalSearchTerms = 'product,finished good,component,raw material,assembly item';
    Caption = 'Items';
    CardPageID = "Item Card";
    Editable = false;
    PageType = ListPart;
    PromotedActionCategories = 'New,Process,Report,Item,History,Special Prices & Discounts,Request Approval,Periodic Activities,Inventory,Attributes';
    QueryCategory = 'Item List';
    RefreshOnActivate = true;
    SourceTable = Item;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                Caption = 'Item';
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the item.';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the item.';
                }
                field(Type; Type)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the item card represents a physical inventory unit (Inventory), a labor time unit (Service), or a physical unit that is not tracked in inventory (Non-Inventory).';
                    Visible = IsFoundationEnabled;
                }
                field(InventoryField; Inventory)
                {
                    ApplicationArea = Basic, Suite, Invoicing;
                    HideValue = IsNonInventoriable;
                    ToolTip = 'Specifies how many units, such as pieces, boxes, or cans, of the item are in inventory.';
                }
                field("Created From Nonstock Item"; "Created From Nonstock Item")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the item was created from a catalog item.';
                    Visible = false;
                }
                field("Substitutes Exist"; "Substitutes Exist")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies that a substitute exists for this item.';
                }
                field("Stockkeeping Unit Exists"; "Stockkeeping Unit Exists")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies that a stockkeeping unit exists for this item.';
                    Visible = false;
                }
                field("Assembly BOM"; "Assembly BOM")
                {
                    AccessByPermission = TableData "BOM Component" = R;
                    ApplicationArea = Assembly;
                    ToolTip = 'Specifies if the item is an assembly BOM.';
                }
                field("Production BOM No."; "Production BOM No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the production BOM that the item represents.';
                }
                field("Routing No."; "Routing No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the production routing that the item is used in.';
                }
                field("Base Unit of Measure"; "Base Unit of Measure")
                {
                    ApplicationArea = Basic, Suite, Invoicing;
                    ToolTip = 'Specifies the base unit used to measure the item, such as piece, box, or pallet. The base unit of measure also serves as the conversion basis for alternate units of measure.';
                }
                field("Shelf No."; "Shelf No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies where to find the item in the warehouse. This is informational only.';
                    Visible = false;
                }
                field("Costing Method"; "Costing Method")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how the item''s cost flow is recorded and whether an actual or budgeted value is capitalized and used in the cost calculation.';
                    Visible = false;
                }
                field("Cost is Adjusted"; "Cost is Adjusted")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the item''s unit cost has been adjusted, either automatically or manually.';
                }
                field("Standard Cost"; "Standard Cost")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the unit cost that is used as an estimation to be adjusted with variances later. It is typically used in assembly and production where costs can vary.';
                    Visible = false;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the cost per unit of the item.';
                }
                field("Last Direct Cost"; "Last Direct Cost")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the most recent direct unit cost that was paid for the item.';
                    Visible = false;
                }
                field("Price/Profit Calculation"; "Price/Profit Calculation")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the relationship between the Unit Cost, Unit Price, and Profit Percentage fields associated with this item.';
                    Visible = false;
                }
                field("Profit %"; "Profit %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the profit margin that you want to sell the item at. You can enter a profit percentage manually or have it entered according to the Price/Profit Calculation field';
                    Visible = false;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = Basic, Suite, Invoicing;
                    ToolTip = 'Specifies the price for one unit of the item, in LCY.';
                }
                field("Inventory Posting Group"; "Inventory Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies links between business transactions made for the item and an inventory account in the general ledger, to group amounts for that item type.';
                    Visible = false;
                }
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the item''s product type to link transactions made for this item with the appropriate general ledger account according to the general posting setup.';
                    Visible = false;
                }
                field("VAT Prod. Posting Group"; "VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT product posting group. Links business transactions made for the item, resource, or G/L account with the general ledger, to account for VAT amounts resulting from trade with that record.';
                    Visible = false;
                }
                field("Item Disc. Group"; "Item Disc. Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an item group code that can be used as a criterion to grant a discount when the item is sold to a certain customer.';
                    Visible = false;
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor code of who supplies this item by default.';
                }
                field("Vendor Item No."; "Vendor Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number that the vendor uses for this item.';
                    Visible = false;
                }
                field("Tariff No."; "Tariff No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code for the item''s tariff number.';
                    Visible = false;
                }
                field("Search Description"; "Search Description")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies a search description that you use to find the item in lists.';
                }
                field("Overhead Rate"; "Overhead Rate")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the item''s indirect cost as an absolute amount.';
                    Visible = false;
                }
                field("Indirect Cost %"; "Indirect Cost %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the percentage of the item''s last purchase cost that includes indirect costs, such as freight that is associated with the purchase of the item.';
                    Visible = false;
                }
                field("Item Category Code"; "Item Category Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the category that the item belongs to. Item categories also contain any assigned item attributes.';
                    Visible = false;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that transactions with the item cannot be posted, for example, because the item is in quarantine.';
                    Visible = false;
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies when the item card was last modified.';
                    Visible = false;
                }
                field("Sales Unit of Measure"; "Sales Unit of Measure")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the unit of measure code used when you sell the item.';
                    Visible = false;
                }
                field("Replenishment System"; "Replenishment System")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of supply order created by the planning system when the item needs to be replenished.';
                    Visible = false;
                }
                field("Purch. Unit of Measure"; "Purch. Unit of Measure")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the unit of measure code used when you purchase the item.';
                    Visible = false;
                }
                field("Lead Time Calculation"; "Lead Time Calculation")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a date formula for the amount of time it takes to replenish the item.';
                    Visible = false;
                }
                field("Manufacturing Policy"; "Manufacturing Policy")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies if additional orders for any related components are calculated.';
                    Visible = false;
                }
                field("Flushing Method"; "Flushing Method")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies how consumption of the item (component) is calculated and handled in production processes. Manual: Enter and post consumption in the consumption journal manually. Forward: Automatically posts consumption according to the production order component lines when the first operation starts. Backward: Automatically calculates and posts consumption according to the production order component lines when the production order is finished. Pick + Forward / Pick + Backward: Variations with warehousing.';
                    Visible = false;
                }
                field("Assembly Policy"; "Assembly Policy")
                {
                    ApplicationArea = Assembly;
                    ToolTip = 'Specifies which default order flow is used to supply this assembly item.';
                    Visible = false;
                }
                field("Item Tracking Code"; "Item Tracking Code")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies how items are tracked in the supply chain.';
                    Visible = false;
                }
                field("Default Deferral Template Code"; "Default Deferral Template Code")
                {
                    ApplicationArea = Suite;
                    Caption = 'Default Deferral Template';
                    Importance = Additional;
                    ToolTip = 'Specifies the default template that governs how to defer revenues and expenses to the periods when they occurred.';
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        CRMCouplingManagement: Codeunit "CRM Coupling Management";
        SocialListeningMgt: Codeunit "Social Listening Management";
        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
    begin
        if SocialListeningSetupVisible then
            SocialListeningMgt.GetItemFactboxVisibility(Rec, SocialListeningSetupVisible, SocialListeningVisible);

        if CRMIntegrationEnabled then
            CRMIsCoupledToRecord := CRMCouplingManagement.IsRecordCoupledToCRM(RecordId);

        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(RecordId);

        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(RecordId);

        WorkflowWebhookManagement.GetCanRequestAndCanCancel(RecordId, CanRequestApprovalForFlow, CanCancelApprovalForFlow);

        SetWorkflowManagementEnabledState;
    end;

    trigger OnAfterGetRecord()
    begin
        EnableControls;
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
        exit(Find(Which));
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
        exit(Next(Steps));
    end;

    trigger OnOpenPage()
    var
        SocialListeningSetup: Record "Social Listening Setup";
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
        ClientTypeManagement: Codeunit "Client Type Management";
    begin
        CRMIntegrationEnabled := CRMIntegrationManagement.IsCRMIntegrationEnabled;
        with SocialListeningSetup do
            SocialListeningSetupVisible := Get and "Show on Customers" and "Accept License Agreement" and ("Solution ID" <> '');
        IsFoundationEnabled := ApplicationAreaMgmtFacade.IsFoundationEnabled;
        SetWorkflowManagementEnabledState;
        IsOnPhone := ClientTypeManagement.GetCurrentClientType = CLIENTTYPE::Phone;
    end;

    var
        TempFilterItemAttributesBuffer: Record "Filter Item Attributes Buffer" temporary;
        TempItemFilteredFromAttributes: Record Item temporary;
        TempItemFilteredFromPickItem: Record Item temporary;
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        CalculateStdCost: Codeunit "Calculate Standard Cost";
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        ClientTypeManagement: Codeunit "Client Type Management";
        SkilledResourceList: Page "Skilled Resource List";
        IsFoundationEnabled: Boolean;
        [InDataSet]
        SocialListeningSetupVisible: Boolean;
        [InDataSet]
        SocialListeningVisible: Boolean;
        CRMIntegrationEnabled: Boolean;
        CRMIsCoupledToRecord: Boolean;
        OpenApprovalEntriesExist: Boolean;
        EnabledApprovalWorkflowsExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        IsOnPhone: Boolean;
        RunOnTempRec: Boolean;
        EventFilter: Text;
        PowerBIVisible: Boolean;
        CanRequestApprovalForFlow: Boolean;
        CanCancelApprovalForFlow: Boolean;
        [InDataSet]
        IsNonInventoriable: Boolean;
        [InDataSet]
        IsInventoriable: Boolean;
        RunOnPickItem: Boolean;

    procedure SelectInItemList(var Item: Record Item): Text
    var
        ItemListPage: Page "Item List";
    begin
        Item.SetRange(Blocked, false);
        ItemListPage.SetTableView(Item);
        ItemListPage.LookupMode(true);
        if ItemListPage.RunModal = ACTION::LookupOK then
            exit(ItemListPage.GetSelectionFilter);
    end;

    local procedure EnableControls()
    begin
        IsNonInventoriable := IsNonInventoriableType;
        IsInventoriable := IsInventoriableType;
    end;

    local procedure SetWorkflowManagementEnabledState()
    var
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
    begin
        EventFilter := WorkflowEventHandling.RunWorkflowOnSendItemForApprovalCode + '|' +
          WorkflowEventHandling.RunWorkflowOnItemChangedCode;

        EnabledApprovalWorkflowsExist := WorkflowManagement.EnabledWorkflowExist(DATABASE::Item, EventFilter);
    end;
}