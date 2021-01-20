page 6059835 "NPR NP Retail EFT Role Center"
{
    Caption = 'Role Center';
    PageType = RoleCenter;
    UsageCategory = None;
    layout
    {
        area(rolecenter)
        {
            group(Control1900724808)
            {
                ShowCaption = false;
                part(Control1901138408; "Warehouse Worker Activities")
                {
                    ApplicationArea = All;
                }
                part(Control1905989608; "My Items")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
            }
            group(Control1900724708)
            {
                ShowCaption = false;
                part(Control1006; "My Job Queue")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                part(Control4; "Report Inbox Part")
                {
                    ApplicationArea = All;
                }
                systempart(Control1901377608; MyNotes)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(reporting)
        {
            action("Warehouse &Bin List")
            {
                Caption = 'Warehouse &Bin List';
                Image = "Report";
                RunObject = Report "Warehouse Bin List";
                ApplicationArea = All;
                ToolTip = 'Executes the Warehouse &Bin List action';
            }
            action("Warehouse A&djustment Bin")
            {
                Caption = 'Warehouse A&djustment Bin';
                Image = "Report";
                RunObject = Report "Whse. Adjustment Bin";
                ApplicationArea = All;
                ToolTip = 'Executes the Warehouse A&djustment Bin action';
            }
            separator(Separator51)
            {
            }
            action("Whse. P&hys. Inventory List")
            {
                Caption = 'Whse. P&hys. Inventory List';
                Image = "Report";
                RunObject = Report "Whse. Phys. Inventory List";
                ApplicationArea = All;
                ToolTip = 'Executes the Whse. P&hys. Inventory List action';
            }
            separator(Separator19)
            {
            }
            action("Prod. &Order Picking List")
            {
                Caption = 'Prod. &Order Picking List';
                Image = "Report";
                RunObject = Report "Prod. Order - Picking List";
                ApplicationArea = All;
                ToolTip = 'Executes the Prod. &Order Picking List action';
            }
            separator(Separator54)
            {
            }
            action("Customer &Labels")
            {
                Caption = 'Customer &Labels';
                Image = "Report";
                RunObject = Report "Customer - Labels";
                ApplicationArea = All;
                ToolTip = 'Executes the Customer &Labels action';
            }
        }
        area(embedding)
        {
            action(Action26)
            {
                Caption = 'Picks';
                RunObject = Page "Warehouse Picks";
                ApplicationArea = All;
                ToolTip = 'Executes the Picks action';
            }
            action(Action36)
            {
                Caption = 'Put-aways';
                RunObject = Page "Warehouse Put-aways";
                ApplicationArea = All;
                ToolTip = 'Executes the Put-aways action';
            }
            action(Action41)
            {
                Caption = 'Movements';
                RunObject = Page "Warehouse Movements";
                ApplicationArea = All;
                ToolTip = 'Executes the Movements action';
            }
            action(WhseShpt)
            {
                Caption = 'Warehouse Shipments';
                RunObject = Page "Warehouse Shipment List";
                ApplicationArea = All;
                ToolTip = 'Executes the Warehouse Shipments action';
            }
            action(WhseShptReleased)
            {
                Caption = 'Released';
                RunObject = Page "Warehouse Shipment List";
                RunPageView = SORTING("No.")
                              WHERE(Status = FILTER(Released));
                ApplicationArea = All;
                ToolTip = 'Executes the Released action';
            }
            action(WhseShptPartPicked)
            {
                Caption = 'Partially Picked';
                RunObject = Page "Warehouse Shipment List";
                RunPageView = WHERE("Document Status" = FILTER("Partially Picked"));
                ApplicationArea = All;
                ToolTip = 'Executes the Partially Picked action';
            }
            action(WhseShptComplPicked)
            {
                Caption = 'Completely Picked';
                RunObject = Page "Warehouse Shipment List";
                RunPageView = WHERE("Document Status" = FILTER("Completely Picked"));
                ApplicationArea = All;
                ToolTip = 'Executes the Completely Picked action';
            }
            action(WhseShptPartShipped)
            {
                Caption = 'Partially Shipped';
                RunObject = Page "Warehouse Shipment List";
                RunPageView = WHERE("Document Status" = FILTER("Partially Shipped"));
                ApplicationArea = All;
                ToolTip = 'Executes the Partially Shipped action';
            }
            action(WhseReceipts)
            {
                Caption = 'Warehouse Receipts';
                RunObject = Page "Warehouse Receipts";
                ApplicationArea = All;
                ToolTip = 'Executes the Warehouse Receipts action';
            }
            action(WhseReceiptsPartReceived)
            {
                Caption = 'Partially Received';
                RunObject = Page "Warehouse Receipts";
                RunPageView = WHERE("Document Status" = FILTER("Partially Received"));
                ApplicationArea = All;
                ToolTip = 'Executes the Partially Received action';
            }
            action(Action83)
            {
                Caption = 'Transfer Orders';
                Image = Document;
                RunObject = Page "Transfer Orders";
                ApplicationArea = All;
                ToolTip = 'Executes the Transfer Orders action';
            }
            action(Action1)
            {
                Caption = 'Assembly Orders';
                RunObject = Page "Assembly Orders";
                ApplicationArea = All;
                ToolTip = 'Executes the Assembly Orders action';
            }
            action(Action46)
            {
                Caption = 'Bin Contents';
                Image = BinContent;
                RunObject = Page "Bin Contents List";
                ApplicationArea = All;
                ToolTip = 'Executes the Bin Contents action';
            }
            action(Action47)
            {
                Caption = 'Items';
                Image = Item;
                RunObject = Page "Item List";
                ApplicationArea = All;
                ToolTip = 'Executes the Items action';
            }
            action(Customers)
            {
                Caption = 'Customers';
                Image = Customer;
                RunObject = Page "Customer List";
                ApplicationArea = All;
                ToolTip = 'Executes the Customers action';
            }
            action(Action52)
            {
                Caption = 'Vendors';
                Image = Vendor;
                RunObject = Page "Vendor List";
                ApplicationArea = All;
                ToolTip = 'Executes the Vendors action';
            }
            action(Action53)
            {
                Caption = 'Shipping Agents';
                RunObject = Page "Shipping Agents";
                ApplicationArea = All;
                ToolTip = 'Executes the Shipping Agents action';
            }
            action("Warehouse Employees")
            {
                Caption = 'Warehouse Employees';
                RunObject = Page "Warehouse Employee List";
                ApplicationArea = All;
                ToolTip = 'Executes the Warehouse Employees action';
            }
        }
        area(sections)
        {
            group("Registered Documents")
            {
                Caption = 'Registered Documents';
                Image = RegisteredDocs;
                action(Action43)
                {
                    Caption = 'Registered Picks';
                    Image = RegisteredDocs;
                    RunObject = Page "Registered Whse. Picks";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Registered Picks action';
                }
                action(Action44)
                {
                    Caption = 'Registered Put-aways';
                    Image = RegisteredDocs;
                    RunObject = Page "Registered Whse. Put-aways";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Registered Put-aways action';
                }
                action(Action45)
                {
                    Caption = 'Registered Movements';
                    Image = RegisteredDocs;
                    RunObject = Page "Registered Whse. Movements";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Registered Movements action';
                }
                action(Action59)
                {
                    Caption = 'Posted Whse. Receipts';
                    Image = PostedReceipts;
                    RunObject = Page "Posted Whse. Receipt List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Posted Whse. Receipts action';
                }
            }
        }
        area(processing)
        {
            action("Whse. P&hysical Invt. Journal")
            {
                Caption = 'Whse. P&hysical Invt. Journal';
                Image = InventoryJournal;
                RunObject = Page "Whse. Phys. Invt. Journal";
                ToolTip = 'Prepare to count inventories by preparing the documents that warehouse employees use when they perform a physical inventory of selected items or of all the inventory. When the physical count has been made, you enter the number of items that are in the bins in this window, and then you register the physical inventory.';
                Visible = false;
                ApplicationArea = All;
            }
            action("Whse. Item &Journal")
            {
                Caption = 'Whse. Item &Journal';
                Image = BinJournal;
                RunObject = Page "Whse. Item Journal";
                ToolTip = 'Adjust the quantity of an item in a particular bin or bins. For instance, you might find some items in a bin that are not registered in the system, or you might not be able to pick the quantity needed because there are fewer items in a bin than was calculated by the program. The bin is then updated to correspond to the actual quantity in the bin. In addition, it creates a balancing quantity in the adjustment bin, for synchronization with item ledger entries, which you can then post with an item journal.';
                Visible = false;
                ApplicationArea = All;
            }
            action("Pick &Worksheet")
            {
                Caption = 'Pick &Worksheet';
                Image = PickWorksheet;
                RunObject = Page "Pick Worksheet";
                ToolTip = 'Plan and initialize picks of items. ';
                Visible = false;
                ApplicationArea = All;
            }
            action("Put-&away Worksheet")
            {
                Caption = 'Put-&away Worksheet';
                Image = PutAwayWorksheet;
                RunObject = Page "Put-away Worksheet";
                ToolTip = 'Plan and initialize item put-aways.';
                Visible = false;
                ApplicationArea = All;
            }
            action("M&ovement Worksheet")
            {
                Caption = 'M&ovement Worksheet';
                Image = MovementWorksheet;
                RunObject = Page "Movement Worksheet";
                ToolTip = 'Prepare to move items between bins within the warehouse.';
                Visible = false;
                ApplicationArea = All;
            }
            group(ActionGroup6014437)
            {
                action("Warehouse Receipts")
                {
                    Caption = 'Warehouse Receipts';
                    Image = List;
                    RunObject = Page "Warehouse Receipts";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Warehouse Receipts action';
                }
                action("Partially Received")
                {
                    Caption = 'Partially Received';
                    Image = List;
                    RunObject = Page "Warehouse Receipts";
                    RunPageView = WHERE("Document Status" = CONST("Partially Received"));
                    ApplicationArea = All;
                    ToolTip = 'Executes the Partially Received action';
                }
                action("Warehouse Shipments")
                {
                    Caption = 'Warehouse Shipments';
                    Image = List;
                    RunObject = Page "Warehouse Shipment List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Warehouse Shipments action';
                }
                action(Release)
                {
                    Caption = 'Release';
                    Image = List;
                    RunObject = Page "Warehouse Shipment List";
                    RunPageView = SORTING("No.")
                                  ORDER(Ascending)
                                  WHERE(Status = FILTER(Released));
                    ApplicationArea = All;
                    ToolTip = 'Executes the Release action';
                }
                action("Partially Picked")
                {
                    Caption = 'Partially Picked';
                    Image = List;
                    RunObject = Page "Warehouse Shipment List";
                    RunPageView = WHERE("Document Status" = FILTER("Completely Picked"));
                    ApplicationArea = All;
                    ToolTip = 'Executes the Partially Picked action';
                }
                action("Completely Picked")
                {
                    Caption = 'Completely Picked';
                    Image = List;
                    RunObject = Page "Warehouse Shipment List";
                    RunPageView = WHERE("Document Status" = FILTER("Completely Picked"));
                    ApplicationArea = All;
                    ToolTip = 'Executes the Completely Picked action';
                }
                action("Partially Shipped")
                {
                    Caption = 'Partially Shipped';
                    Image = List;
                    RunObject = Page "Warehouse Shipment List";
                    RunPageView = WHERE("Document Status" = FILTER("Partially Shipped"));
                    ApplicationArea = All;
                    ToolTip = 'Executes the Partially Shipped action';
                }
                action("Inventory Put-aways")
                {
                    Caption = 'Inventory Put-aways';
                    Image = List;
                    RunObject = Page "Inventory Put-aways";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Inventory Put-aways action';
                }
                action("Put-aways")
                {
                    Caption = 'Put-aways';
                    Image = List;
                    RunObject = Page "Inventory Picks";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Put-aways action';
                }
                action(Picks)
                {
                    Caption = 'Picks';
                    Image = List;
                    RunObject = Page "Warehouse Picks";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Picks action';
                }
                action(Movements)
                {
                    Caption = 'Movements';
                    Image = List;
                    RunObject = Page "Warehouse Movements";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Movements action';
                }
                action("Transfer Orders")
                {
                    Caption = 'Transfer Orders';
                    Image = List;
                    RunObject = Page "Transfer Orders";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Transfer Orders action';
                }
                action("Assembly Orders")
                {
                    Caption = 'Assembly Orders';
                    Image = List;
                    RunObject = Page "Assembly Orders";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Assembly Orders action';
                }
                action("Bin Contents")
                {
                    Caption = 'Bin Contents';
                    Image = List;
                    RunObject = Page "Bin Contents List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Bin Contents action';
                }
            }
            group("Reference Data")
            {
                Caption = 'Reference Data';
                action(Items)
                {
                    Caption = 'Items';
                    Image = List;
                    RunObject = Page "Item List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Items action';
                }
                action(Customer)
                {
                    Caption = 'Customer';
                    Image = List;
                    RunObject = Page "Customer List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Customer action';
                }
                action(Vendors)
                {
                    Caption = 'Vendors';
                    Image = List;
                    RunObject = Page "Vendor List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Vendors action';
                }
                action("Shipping Agents")
                {
                    Caption = 'Shipping Agents';
                    Image = List;
                    RunObject = Page "Shipping Agents";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Shipping Agents action';
                }
            }
            group(Journal)
            {
                Caption = 'Journal';
                action(WhsePhysInvtJournals)
                {
                    Caption = 'Whse. Phys. Invt. Journals';
                    Image = List;
                    RunObject = Page "Whse. Journal Batches List";
                    RunPageView = WHERE("Template Type" = CONST("Physical Inventory"));
                    ToolTip = 'Prepare to count inventories by preparing the documents that warehouse employees use when they perform a physical inventory of selected items or of all the inventory. When the physical count has been made, you enter the number of items that are in the bins in this window, and then you register the physical inventory.';
                    ApplicationArea = All;
                }
                action("WhseItem Journals")
                {
                    Caption = 'Whse. Item Journals';
                    Image = List;
                    RunObject = Page "Whse. Journal Batches List";
                    RunPageView = WHERE("Template Type" = CONST(Item));
                    ToolTip = 'Adjust the quantity of an item in a particular bin or bins. For instance, you might find some items in a bin that are not registered in the system, or you might not be able to pick the quantity needed because there are fewer items in a bin than was calculated by the program. The bin is then updated to correspond to the actual quantity in the bin. In addition, it creates a balancing quantity in the adjustment bin, for synchronization with item ledger entries, which you can then post with an item journal.';
                    ApplicationArea = All;
                }
            }
            group(Worksheet)
            {
                Caption = 'Worksheet';
                action(PickWorksheets)
                {
                    Caption = 'Pick Worksheets';
                    Image = List;
                    RunObject = Page "Worksheet Names List";
                    RunPageView = WHERE("Template Type" = CONST(Pick));
                    ToolTip = 'Plan and initialize picks of items. ';
                    ApplicationArea = All;
                }
                action(PutawayWorksheets)
                {
                    Caption = 'Put-away Worksheets';
                    Image = List;
                    RunObject = Page "Worksheet Names List";
                    RunPageView = WHERE("Template Type" = CONST("Put-away"));
                    ToolTip = 'Plan and initialize item put-aways.';
                    ApplicationArea = All;
                }
                action(MovementWorksheets)
                {
                    Caption = 'Movement Worksheets';
                    Image = List;
                    RunObject = Page "Worksheet Names List";
                    RunPageView = WHERE("Template Type" = CONST(Movement));
                    ToolTip = 'Plan and initiate movements of items between bins according to an advanced warehouse configuration.';
                    ApplicationArea = All;
                }
            }
            group(ActionGroup6014410)
            {
                Caption = 'Registered Documents';
                action("Registered Picks")
                {
                    Caption = 'Registered Picks';
                    Image = List;
                    RunObject = Page "Registered Whse. Picks";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Registered Picks action';
                }
                action("Registered Put-aways")
                {
                    Caption = 'Registered Put-aways';
                    Image = List;
                    RunObject = Page "Registered Whse. Put-aways";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Registered Put-aways action';
                }
                action("Registered Movements")
                {
                    Caption = 'Registered Movements';
                    Image = List;
                    RunObject = Page "Registered Whse. Movements";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Registered Movements action';
                }
                action("Posted Whse. Receipts")
                {
                    Caption = 'Posted Whse. Receipts';
                    Image = List;
                    RunObject = Page "Posted Whse. Receipt List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Posted Whse. Receipts action';
                }
            }
        }
    }
}

