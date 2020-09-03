page 6059835 "NPR NP Retail EFT Role Center"
{
    // NPR5.54/YAHA/20200218 CASE 383626 Newly created Role Center

    Caption = 'Role Center';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            group(Control1900724808)
            {
                ShowCaption = false;
                part(Control1901138408; "Warehouse Worker Activities")
                {
                }
                part(Control1905989608; "My Items")
                {
                    Visible = false;
                }
            }
            group(Control1900724708)
            {
                ShowCaption = false;
                part(Control1006; "My Job Queue")
                {
                    Visible = false;
                }
                part(Control4; "Report Inbox Part")
                {
                }
                systempart(Control1901377608; MyNotes)
                {
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
            }
            action("Warehouse A&djustment Bin")
            {
                Caption = 'Warehouse A&djustment Bin';
                Image = "Report";
                RunObject = Report "Whse. Adjustment Bin";
            }
            separator(Separator51)
            {
            }
            action("Whse. P&hys. Inventory List")
            {
                Caption = 'Whse. P&hys. Inventory List';
                Image = "Report";
                RunObject = Report "Whse. Phys. Inventory List";
            }
            separator(Separator19)
            {
            }
            action("Prod. &Order Picking List")
            {
                Caption = 'Prod. &Order Picking List';
                Image = "Report";
                RunObject = Report "Prod. Order - Picking List";
            }
            separator(Separator54)
            {
            }
            action("Customer &Labels")
            {
                Caption = 'Customer &Labels';
                Image = "Report";
                RunObject = Report "Customer - Labels";
            }
        }
        area(embedding)
        {
            action(Action26)
            {
                Caption = 'Picks';
                RunObject = Page "Warehouse Picks";
            }
            action(Action36)
            {
                Caption = 'Put-aways';
                RunObject = Page "Warehouse Put-aways";
            }
            action(Action41)
            {
                Caption = 'Movements';
                RunObject = Page "Warehouse Movements";
            }
            action(WhseShpt)
            {
                Caption = 'Warehouse Shipments';
                RunObject = Page "Warehouse Shipment List";
            }
            action(WhseShptReleased)
            {
                Caption = 'Released';
                RunObject = Page "Warehouse Shipment List";
                RunPageView = SORTING("No.")
                              WHERE(Status = FILTER(Released));
            }
            action(WhseShptPartPicked)
            {
                Caption = 'Partially Picked';
                RunObject = Page "Warehouse Shipment List";
                RunPageView = WHERE("Document Status" = FILTER("Partially Picked"));
            }
            action(WhseShptComplPicked)
            {
                Caption = 'Completely Picked';
                RunObject = Page "Warehouse Shipment List";
                RunPageView = WHERE("Document Status" = FILTER("Completely Picked"));
            }
            action(WhseShptPartShipped)
            {
                Caption = 'Partially Shipped';
                RunObject = Page "Warehouse Shipment List";
                RunPageView = WHERE("Document Status" = FILTER("Partially Shipped"));
            }
            action(WhseReceipts)
            {
                Caption = 'Warehouse Receipts';
                RunObject = Page "Warehouse Receipts";
            }
            action(WhseReceiptsPartReceived)
            {
                Caption = 'Partially Received';
                RunObject = Page "Warehouse Receipts";
                RunPageView = WHERE("Document Status" = FILTER("Partially Received"));
            }
            action(Action83)
            {
                Caption = 'Transfer Orders';
                Image = Document;
                RunObject = Page "Transfer Orders";
            }
            action(Action1)
            {
                Caption = 'Assembly Orders';
                RunObject = Page "Assembly Orders";
            }
            action(Action46)
            {
                Caption = 'Bin Contents';
                Image = BinContent;
                RunObject = Page "Bin Contents List";
            }
            action(Action47)
            {
                Caption = 'Items';
                Image = Item;
                RunObject = Page "Item List";
            }
            action(Customers)
            {
                Caption = 'Customers';
                Image = Customer;
                RunObject = Page "Customer List";
            }
            action(Action52)
            {
                Caption = 'Vendors';
                Image = Vendor;
                RunObject = Page "Vendor List";
            }
            action(Action53)
            {
                Caption = 'Shipping Agents';
                RunObject = Page "Shipping Agents";
            }
            action("Warehouse Employees")
            {
                Caption = 'Warehouse Employees';
                RunObject = Page "Warehouse Employee List";
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
                }
                action(Action44)
                {
                    Caption = 'Registered Put-aways';
                    Image = RegisteredDocs;
                    RunObject = Page "Registered Whse. Put-aways";
                }
                action(Action45)
                {
                    Caption = 'Registered Movements';
                    Image = RegisteredDocs;
                    RunObject = Page "Registered Whse. Movements";
                }
                action(Action59)
                {
                    Caption = 'Posted Whse. Receipts';
                    Image = PostedReceipts;
                    RunObject = Page "Posted Whse. Receipt List";
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
            }
            action("Whse. Item &Journal")
            {
                Caption = 'Whse. Item &Journal';
                Image = BinJournal;
                RunObject = Page "Whse. Item Journal";
                ToolTip = 'Adjust the quantity of an item in a particular bin or bins. For instance, you might find some items in a bin that are not registered in the system, or you might not be able to pick the quantity needed because there are fewer items in a bin than was calculated by the program. The bin is then updated to correspond to the actual quantity in the bin. In addition, it creates a balancing quantity in the adjustment bin, for synchronization with item ledger entries, which you can then post with an item journal.';
                Visible = false;
            }
            action("Pick &Worksheet")
            {
                Caption = 'Pick &Worksheet';
                Image = PickWorksheet;
                RunObject = Page "Pick Worksheet";
                ToolTip = 'Plan and initialize picks of items. ';
                Visible = false;
            }
            action("Put-&away Worksheet")
            {
                Caption = 'Put-&away Worksheet';
                Image = PutAwayWorksheet;
                RunObject = Page "Put-away Worksheet";
                ToolTip = 'Plan and initialize item put-aways.';
                Visible = false;
            }
            action("M&ovement Worksheet")
            {
                Caption = 'M&ovement Worksheet';
                Image = MovementWorksheet;
                RunObject = Page "Movement Worksheet";
                ToolTip = 'Prepare to move items between bins within the warehouse.';
                Visible = false;
            }
            group(ActionGroup6014437)
            {
                action("Warehouse Receipts")
                {
                    Caption = 'Warehouse Receipts';
                    Image = List;
                    RunObject = Page "Warehouse Receipts";
                }
                action("Partially Received")
                {
                    Caption = 'Partially Received';
                    Image = List;
                    RunObject = Page "Warehouse Receipts";
                    RunPageView = WHERE("Document Status" = CONST("Partially Received"));
                }
                action("Warehouse Shipments")
                {
                    Caption = 'Warehouse Shipments';
                    Image = List;
                    RunObject = Page "Warehouse Shipment List";
                }
                action(Release)
                {
                    Caption = 'Release';
                    Image = List;
                    RunObject = Page "Warehouse Shipment List";
                    RunPageView = SORTING("No.")
                                  ORDER(Ascending)
                                  WHERE(Status = FILTER(Released));
                }
                action("Partially Picked")
                {
                    Caption = 'Partially Picked';
                    Image = List;
                    RunObject = Page "Warehouse Shipment List";
                    RunPageView = WHERE("Document Status" = FILTER("Completely Picked"));
                }
                action("Completely Picked")
                {
                    Caption = 'Completely Picked';
                    Image = List;
                    RunObject = Page "Warehouse Shipment List";
                    RunPageView = WHERE("Document Status" = FILTER("Completely Picked"));
                }
                action("Partially Shipped")
                {
                    Caption = 'Partially Shipped';
                    Image = List;
                    RunObject = Page "Warehouse Shipment List";
                    RunPageView = WHERE("Document Status" = FILTER("Partially Shipped"));
                }
                action("Inventory Put-aways")
                {
                    Caption = 'Inventory Put-aways';
                    Image = List;
                    RunObject = Page "Inventory Put-aways";
                }
                action("Put-aways")
                {
                    Caption = 'Put-aways';
                    Image = List;
                    RunObject = Page "Inventory Picks";
                }
                action(Picks)
                {
                    Caption = 'Picks';
                    Image = List;
                    RunObject = Page "Warehouse Picks";
                }
                action(Movements)
                {
                    Caption = 'Movements';
                    Image = List;
                    RunObject = Page "Warehouse Movements";
                }
                action("Transfer Orders")
                {
                    Caption = 'Transfer Orders';
                    Image = List;
                    RunObject = Page "Transfer Orders";
                }
                action("Assembly Orders")
                {
                    Caption = 'Assembly Orders';
                    Image = List;
                    RunObject = Page "Assembly Orders";
                }
                action("Bin Contents")
                {
                    Caption = 'Bin Contents';
                    Image = List;
                    RunObject = Page "Bin Contents List";
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
                }
                action(Customer)
                {
                    Caption = 'Customer';
                    Image = List;
                    RunObject = Page "Customer List";
                }
                action(Vendors)
                {
                    Caption = 'Vendors';
                    Image = List;
                    RunObject = Page "Vendor List";
                }
                action("Shipping Agents")
                {
                    Caption = 'Shipping Agents';
                    Image = List;
                    RunObject = Page "Shipping Agents";
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
                }
                action("WhseItem Journals")
                {
                    Caption = 'Whse. Item Journals';
                    Image = List;
                    RunObject = Page "Whse. Journal Batches List";
                    RunPageView = WHERE("Template Type" = CONST(Item));
                    ToolTip = 'Adjust the quantity of an item in a particular bin or bins. For instance, you might find some items in a bin that are not registered in the system, or you might not be able to pick the quantity needed because there are fewer items in a bin than was calculated by the program. The bin is then updated to correspond to the actual quantity in the bin. In addition, it creates a balancing quantity in the adjustment bin, for synchronization with item ledger entries, which you can then post with an item journal.';
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
                }
                action(PutawayWorksheets)
                {
                    Caption = 'Put-away Worksheets';
                    Image = List;
                    RunObject = Page "Worksheet Names List";
                    RunPageView = WHERE("Template Type" = CONST("Put-away"));
                    ToolTip = 'Plan and initialize item put-aways.';
                }
                action(MovementWorksheets)
                {
                    Caption = 'Movement Worksheets';
                    Image = List;
                    RunObject = Page "Worksheet Names List";
                    RunPageView = WHERE("Template Type" = CONST(Movement));
                    ToolTip = 'Plan and initiate movements of items between bins according to an advanced warehouse configuration.';
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
                }
                action("Registered Put-aways")
                {
                    Caption = 'Registered Put-aways';
                    Image = List;
                    RunObject = Page "Registered Whse. Put-aways";
                }
                action("Registered Movements")
                {
                    Caption = 'Registered Movements';
                    Image = List;
                    RunObject = Page "Registered Whse. Movements";
                }
                action("Posted Whse. Receipts")
                {
                    Caption = 'Posted Whse. Receipts';
                    Image = List;
                    RunObject = Page "Posted Whse. Receipt List";
                }
            }
        }
    }
}

