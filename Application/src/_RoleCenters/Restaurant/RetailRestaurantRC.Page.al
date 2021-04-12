page 6151334 "NPR Retail Restaurant RC"
{
    Caption = 'NP Retail Restaurant', Comment = '{Dependency=Match,"ProfileDescription_NPR RESTAURANT"}';
    PageType = RoleCenter;
    UsageCategory = None;

    layout
    {
        area(rolecenter)
        {
            part("NP Retail Resturant Cue"; "NPR Restaurant Activities")
            {
                ApplicationArea = Basic, Suite;
            }
            part("Team Member Activities No Msgs"; "Team Member Activities No Msgs")
            {
                ApplicationArea = Suite;
            }
            part(PowerBi; "Power BI Report Spinner Part")
            {
                ApplicationArea = Basic, Suite;
            }
            part("MyReports"; "NPR My Reports")
            {
                ApplicationArea = Basic, Suite;
            }
            part(Control21; "Report Inbox Part")
            {
                AccessByPermission = TableData "Report Inbox" = R;
                ApplicationArea = Suite;
            }
            systempart(MyNotesPart; MyNotes)
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }

    actions
    {
        area(Embedding)
        {
            action(WaiterPads)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Waiter Pads';
                Image = ShowList;
                RunObject = Page "NPR NPRE Waiter Pad List";
                ToolTip = 'Open waiter pad list.';
            }
            action(KitchenRequests)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Kitchen Requests (Expedite)';
                Image = BlanketOrder;
                RunObject = Page "NPR NPRE Kitchen Req.";
                ToolTip = 'View outstaning kitchen requests (expedite view).';
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
                    ApplicationArea = Basic, Suite;
                    Caption = 'Items';
                    Image = Item;
                    RunObject = Page "Item List";
                    ToolTip = 'View or edit detailed information for the products that you trade in.';
                }
                action(Customers)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Customers';
                    Image = Customer;
                    RunObject = Page "Customer List";
                    ToolTip = 'View or edit detailed information for the customers that you trade with.';
                }
                action(Vendors)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Vendors';
                    Image = Vendor;
                    RunObject = Page "Vendor List";
                    ToolTip = 'View or edit detailed information for the vendors that you trade with.';
                }
                action(Members)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Members';
                    Image = Customer;
                    RunObject = page "NPR MM Members";
                    ToolTip = 'View detailed information for the members registered in the system.';
                }
                action(Memberships)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Memberships';
                    Image = Customer;
                    RunObject = page "NPR MM Memberships";
                    ToolTip = 'View detailed information for the memberships registered in the system.';
                }
            }
            group(History)
            {
                Caption = 'History';
                Image = FiledPosted;
                ToolTip = 'View the posting history.';
                action(WPSendLog)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Waiter Pad Line Send Log';
                    Image = Log;
                    RunObject = Page "NPR NPRE W.Pad Pr.Log Entries";
                    ToolTip = 'View waiter pad line sending log to kitchen.';
                }
                action(POSEntries)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'POS Entries';
                    Image = Entries;
                    RunObject = Page "NPR POS Entry List";
                    ToolTip = 'Open the list of registered POS entries.';
                }
                action("Posted Sales Invoices")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Sales Invoices';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Invoices";
                    ToolTip = 'Open the list of posted sales invoices.';
                }
                action("Posted Sales Credit Memos")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Sales Credit Memos';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Credit Memos";
                    ToolTip = 'Open the list of posted sales credit memos.';
                }
            }
            group(Reports)
            {
                action("POS Item Sales")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'POS Item Sales by Dims';
                    Image = "Report";
                    RunObject = report "NPR POS Item Sales with Dim.";
                    ToolTip = 'Executes the POS Item Sales by Dims action';
                }
                action(RestDailyTurnover)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Restaurant Daily Turnover';
                    Image = Report;
                    RunObject = report "NPR NPRE: Rest. Daily Turnover";
                    ToolTip = 'Executes the Restaurant Daily Turnover action';
                }
            }
            group(Setup)
            {
                Caption = 'Setup';
                Image = Setup;
                action(RestaurantSetup)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Restaurant Setup';
                    Image = Setup;
                    RunObject = Page "NPR NPRE Restaurant Setup";
                    ToolTip = 'View or edit general module settings.';
                }
                group(Grouping)
                {
                    Caption = 'Grouping';
                    action(FlowStatuses)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Flow Statuses';
                        Image = OrderList;
                        RunObject = Page "NPR NPRE Flow Statuses";
                        ToolTip = 'Set up flow statuses including serving steps.';
                    }
                    action(PrintProdCategories)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print/Prod. Categories';
                        Image = PrintForm;
                        RunObject = Page "NPR NPRE Print/Prod. Categ.";
                        ToolTip = 'Set up print/production categories.';
                    }
                    action(ItemRoutingProfiles)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Item Routing Profiles';
                        Image = CoupledItem;
                        RunObject = Page "NPR NPRE Item Routing Profiles";
                        ToolTip = 'Set up item routing profiles.';
                    }
                    action(ServiceFlowProfiles)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Service Flow Profiles';
                        Image = Flow;
                        RunObject = Page "NPR NPRE Service Flow Profiles";
                        ToolTip = 'Set up service flow profiles.';
                    }
                }
                group(RestLayout)
                {
                    Caption = 'Restaurant Layout';
                    action(Restaurants)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Restaurants';
                        Image = NewBranch;
                        RunObject = Page "NPR NPRE Restaurants";
                        ToolTip = 'View or edit list of restaurants.';
                    }
                    action(SeatingLocations)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Seating Locations';
                        Image = Zones;
                        RunObject = Page "NPR NPRE Seating Location";
                        ToolTip = 'Set up seating locations available at each restaurant.';
                    }
                    action(Seating)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Seating';
                        Image = Lot;
                        RunObject = Page "NPR NPRE Seating List";
                        ToolTip = 'Set up seatings available at each seating location.';
                    }
                }
                group(Kitchen)
                {
                    Caption = 'Kitchen';
                    action(Stations)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Kitchen Stations';
                        Image = Departments;
                        RunObject = Page "NPR NPRE Kitchen Stations";
                        ToolTip = 'Set up kitchen stations, available at each restaurant''s kitchen.';
                    }
                    action(StationSelectionSetup)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Kitchen Station Selection Setup';
                        Image = Troubleshoot;
                        RunObject = Page "NPR NPRE Kitchen Station Slct.";
                        ToolTip = 'Set up when each kitchen station is to be used in production.';
                    }
                }
            }
        }
    }
}
