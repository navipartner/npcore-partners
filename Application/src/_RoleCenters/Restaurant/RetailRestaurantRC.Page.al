page 6151334 "NPR Retail Restaurant RC"
{
    Extensible = False;
    Caption = 'NP Retail Restaurant', Comment = '{Dependency=Match,"ProfileDescription_NPR RESTAURANT"}';
    PageType = RoleCenter;
    UsageCategory = None;

    layout
    {
        area(rolecenter)
        {
            part("NP Retail Resturant Cue"; "NPR Restaurant Activities")
            {
                ApplicationArea = NPRRetail;

            }
            part("Team Member Activities No Msgs"; "Team Member Activities No Msgs")
            {
                ApplicationArea = NPRRetail;

            }
            part("MyReports"; "NPR My Reports")
            {
                ApplicationArea = NPRRetail;

            }
            part(Control21; "Report Inbox Part")
            {
                AccessByPermission = TableData "Report Inbox" = R;
                ApplicationArea = NPRRetail;
            }

            part(PowerBi; "Power BI Report Spinner Part")
            {
                ApplicationArea = NPRRetail;
            }
            systempart(MyNotesPart; MyNotes)
            {
                ApplicationArea = NPRRetail;

            }
        }
    }

    actions
    {
        area(Embedding)
        {
            action(WaiterPads)
            {

                Caption = 'Waiter Pads';
                Image = ShowList;
                RunObject = Page "NPR NPRE Waiter Pad List";
                ToolTip = 'Open waiter pad list.';
                ApplicationArea = NPRRetail;
            }
            action(KitchenRequests)
            {

                Caption = 'Kitchen Requests (Expedite)';
                Image = BlanketOrder;
                RunObject = Page "NPR NPRE Kitchen Req.";
                ToolTip = 'View outstaning kitchen requests (expedite view).';
                ApplicationArea = NPRRetail;
            }
        }
        area(Sections)
        {
            group("Reference Data")
            {
                Caption = 'Reference Data';
                Image = ReferenceData;
                action(Items)
                {

                    Caption = 'Items';
                    Image = Item;
                    RunObject = Page "Item List";
                    ToolTip = 'View or edit detailed information for the products that you trade in.';
                    ApplicationArea = NPRRetail;
                }
                action(Customers)
                {

                    Caption = 'Customers';
                    Image = Customer;
                    RunObject = Page "Customer List";
                    ToolTip = 'View or edit detailed information for the customers that you trade with.';
                    ApplicationArea = NPRRetail;
                }
                action(Vendors)
                {

                    Caption = 'Vendors';
                    Image = Vendor;
                    RunObject = Page "Vendor List";
                    ToolTip = 'View or edit detailed information for the vendors that you trade with.';
                    ApplicationArea = NPRRetail;
                }
                action(Members)
                {

                    Caption = 'Members';
                    Image = Customer;
                    RunObject = page "NPR MM Members";
                    ToolTip = 'View detailed information for the members registered in the system.';
                    ApplicationArea = NPRRetail;
                }
                action(Memberships)
                {

                    Caption = 'Memberships';
                    Image = Customer;
                    RunObject = page "NPR MM Memberships";
                    ToolTip = 'View detailed information for the memberships registered in the system.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(History)
            {
                Caption = 'History';
                Image = FiledPosted;
                ToolTip = 'View the posting history.';
                action(WPSendLog)
                {

                    Caption = 'Waiter Pad Line Send Log';
                    Image = Log;
                    RunObject = Page "NPR NPRE W.Pad Pr.Log Entries";
                    ToolTip = 'View waiter pad line sending log to kitchen.';
                    ApplicationArea = NPRRetail;
                }
                action(POSEntries)
                {

                    Caption = 'POS Entry List';
                    Image = Entries;
                    RunObject = Page "NPR POS Entry List";
                    ToolTip = 'Open the list of registered POS entry list';
                    ApplicationArea = NPRRetail;
                }
                action("Posted Sales Invoices")
                {

                    Caption = 'Posted Sales Invoices';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Invoices";
                    ToolTip = 'Open the list of posted sales invoices.';
                    ApplicationArea = NPRRetail;
                }
                action("Posted Sales Credit Memos")
                {

                    Caption = 'Posted Sales Credit Memos';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Credit Memos";
                    ToolTip = 'Open the list of posted sales credit memos.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Reports)
            {
                action("POS Item Sales")
                {

                    Caption = 'POS Item Sales by Dims';
                    Image = "Report";
                    RunObject = report "NPR POS Item Sales with Dim.";
                    ToolTip = 'Executes the POS Item Sales by Dims action';
                    ApplicationArea = NPRRetail;
                }
                action(RestDailyTurnover)
                {

                    Caption = 'Restaurant Daily Turnover';
                    Image = Report;
                    RunObject = report "NPR NPRE: Rest. Daily Turnover";
                    ToolTip = 'Executes the Restaurant Daily Turnover action';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Setup)
            {
                Caption = 'Setup';
                Image = Setup;
                action(RestaurantSetup)
                {

                    Caption = 'Restaurant Setup';
                    Image = Setup;
                    RunObject = Page "NPR NPRE Restaurant Setup";
                    ToolTip = 'View or edit general module settings.';
                    ApplicationArea = NPRRetail;
                }
                group(Grouping)
                {
                    Caption = 'Grouping';
                    action(FlowStatuses)
                    {

                        Caption = 'Flow Statuses';
                        Image = OrderList;
                        RunObject = Page "NPR NPRE Flow Statuses";
                        ToolTip = 'Set up flow statuses including serving steps.';
                        ApplicationArea = NPRRetail;
                    }
                    action(PrintProdCategories)
                    {

                        Caption = 'Print/Prod. Categories';
                        Image = PrintForm;
                        RunObject = Page "NPR NPRE Print/Prod. Categ.";
                        ToolTip = 'Set up print/production categories.';
                        ApplicationArea = NPRRetail;
                    }
                    action(ItemRoutingProfiles)
                    {

                        Caption = 'Item Routing Profiles';
                        Image = CoupledItem;
                        RunObject = Page "NPR NPRE Item Routing Profiles";
                        ToolTip = 'Set up item routing profiles.';
                        ApplicationArea = NPRRetail;
                    }
                    action(ServiceFlowProfiles)
                    {

                        Caption = 'Service Flow Profiles';
                        Image = Flow;
                        RunObject = Page "NPR NPRE Service Flow Profiles";
                        ToolTip = 'Set up service flow profiles.';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(RestLayout)
                {
                    Caption = 'Restaurant Layout';
                    action(Restaurants)
                    {

                        Caption = 'Restaurants';
                        Image = NewBranch;
                        RunObject = Page "NPR NPRE Restaurants";
                        ToolTip = 'View or edit list of restaurants.';
                        ApplicationArea = NPRRetail;
                    }
                    action(SeatingLocations)
                    {

                        Caption = 'Seating Locations';
                        Image = Zones;
                        RunObject = Page "NPR NPRE Seating Location";
                        ToolTip = 'Set up seating locations available at each restaurant.';
                        ApplicationArea = NPRRetail;
                    }
                    action(Seating)
                    {

                        Caption = 'Seating';
                        Image = Lot;
                        RunObject = Page "NPR NPRE Seating List";
                        ToolTip = 'Set up seatings available at each seating location.';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Kitchen)
                {
                    Caption = 'Kitchen';
                    action(Stations)
                    {

                        Caption = 'Kitchen Stations';
                        Image = Departments;
                        RunObject = Page "NPR NPRE Kitchen Stations";
                        ToolTip = 'Set up kitchen stations, available at each restaurant''s kitchen.';
                        ApplicationArea = NPRRetail;
                    }
                    action(StationSelectionSetup)
                    {

                        Caption = 'Kitchen Station Selection Setup';
                        Image = Troubleshoot;
                        RunObject = Page "NPR NPRE Kitchen Station Slct.";
                        ToolTip = 'Set up when each kitchen station is to be used in production.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }
}
