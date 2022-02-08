page 6151244 "NPR Retail Web Manager RC"
{
    Extensible = False;
    Caption = 'NP Retail Web Manag. Role Center';
    PageType = RoleCenter;
    UsageCategory = None;

    layout
    {
        area(rolecenter)
        {
            part(NPRETAILACTIVITIES; "NPR Activities")
            {
                ApplicationArea = NPRRetail;

            }
            part(MyJobQueue; "My Job Queue")
            {
                Caption = 'Job Queue';
                ApplicationArea = NPRRetail;
            }
            part(Control21; "Report Inbox Part")
            {
                AccessByPermission = TableData "Report Inbox" = R;
                ApplicationArea = NPRRetail;

            }
            part(Control6014400; "NPR My Reports")
            {
                ApplicationArea = NPRRetail;
            }
            part(Control6150616; "NPR Web Manager Activ.")
            {
                Visible = false;
                ApplicationArea = NPRRetail;
            }
            systempart(Control1901377608; MyNotes)
            {
                ApplicationArea = NPRRetail;
            }
            part(PowerBi; "Power BI Report Spinner Part")
            {
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(sections)
        {

            group("Magento Content")
            {
                Caption = 'Magento Content';
                action(Attributes)
                {
                    Caption = 'Attributes';
                    Image = List;
                    RunObject = page "NPR Magento Attributes";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Magento Attributes action';
                }
                action("Attribute Sets")
                {
                    Caption = 'Attribute Sets';
                    Image = List;
                    RunObject = page "NPR Magento Attribute Sets";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Magento Attribute Sets action';
                }
                action("Attribute Groups")
                {
                    Caption = 'Attribute Groups';
                    Image = List;
                    RunObject = page "NPR Magento Attr. Group List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Magento Attribute Groups action';
                }

                action(Categories)
                {
                    Caption = 'Categories';
                    Image = List;
                    RunObject = page "NPR Magento Categories";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Magento Categories action';
                }


                action(Brands)
                {
                    Caption = 'Brands';
                    Image = List;
                    RunObject = page "NPR Magento Brands";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Magento Brands action';
                }

            }
            group("Magento Orders")
            {
                Caption = 'Magento Orders';

                action(Customer)
                {
                    Caption = 'Customers';
                    Image = List;
                    RunObject = page "Customer List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Customers action';
                }
                action(Contact)
                {
                    Caption = 'Contacts';
                    Image = List;
                    RunObject = page "Contact List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Contacts action';
                }


                action("Sales Orders")
                {
                    Caption = 'Sales Orders';
                    Image = List;
                    RunObject = page "Sales Orders";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Sales Orders action';
                }
                action("Sales Return Orders")
                {
                    Caption = 'Sales Return Orders';
                    Image = List;
                    RunObject = page "Sales Return Order List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Sales Return Orders action';
                }
                action("Posted Sales Invoices")
                {
                    Caption = 'Posted Sales Invoices';
                    Image = List;
                    RunObject = page "Posted Sales Invoices";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Sales Invoices action';
                }

                action("Posted Sales Credit Memos")
                {
                    Caption = 'Posted Sales Credit Memos';
                    Image = List;
                    RunObject = page "Posted Sales Credit Memos";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Sales Credit Memos action';
                }


            }

            group("Retail Vouchers")
            {
                Caption = 'Retail Vouchers';
                action(Vouchers)
                {
                    Caption = 'Vouchers';
                    Image = List;
                    RunObject = page "NPR NpRv Vouchers";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Vouchers action';
                }
                action("Archived Vouchers")
                {
                    Caption = 'Archived Vouchers';
                    Image = List;
                    RunObject = page "NPR NpRv Arch. Vouchers";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Archived Vouchers action';
                }

            }

            group("Discount Coupons")
            {
                Caption = 'Discount Coupons';
                action(Coupons)
                {
                    Caption = 'Coupons';
                    Image = List;
                    RunObject = page "NPR NpDc Coupons";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Coupons action';
                }
                action("Archived Coupons")
                {
                    Caption = 'Archived Coupons';
                    Image = List;
                    RunObject = page "NPR NpDc Arch. Coupons";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Archived Coupons action';
                }

            }
        }
        area(Creation)
        {
            action(Items)
            {
                Caption = 'Items';
                RunObject = Page "Item List";

                ToolTip = 'Executes the Item List action';
                ApplicationArea = NPRRetail;
            }

            action("Sales &Order")
            {
                Caption = 'Sales &Order';
                Image = Document;
                Promoted = false;
                RunObject = Page "Sales Order";
                RunPageMode = Create;

                ToolTip = 'Executes the Sales &Order action';
                ApplicationArea = NPRRetail;
            }
            action("Import List")
            {
                Caption = 'Import List';
                RunObject = Page "NPR Nc Import List";

                ToolTip = 'Executes the Import List action';
                ApplicationArea = NPRRetail;
            }
        }
        area(processing)
        {
            group(Tasks)
            {
                Caption = 'Tasks';
                action("Service Tas&ks")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Service Tas&ks';
                    Image = ServiceTasks;
                    RunObject = Page "Service Tasks";
                    ToolTip = 'View or edit service task information, such as service order number, service item description, repair status, and service item. You can print a list of the service tasks that have been entered.';
                }
                action("C&reate Contract Service Orders")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'C&reate Contract Service Orders';
                    Image = "Report";
                    RunObject = Report "Create Contract Service Orders";
                    ToolTip = 'Copy information from an existing production order record to a new one. This can be done regardless of the status type of the production order. You can, for example, copy from a released production order to a new planned production order. Note that before you start to copy, you have to create the new record.';
                }
                action("Create Contract In&voices")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Create Contract In&voices';
                    Image = "Report";
                    RunObject = Report "Create Contract Invoices";
                    ToolTip = 'Create service invoices for service contracts that are due for invoicing. ';
                }
                action("Post &Prepaid Contract Entries")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Post &Prepaid Contract Entries';
                    Image = "Report";
                    RunObject = Report "Post Prepaid Contract Entries";
                    ToolTip = 'Transfers prepaid service contract ledger entries amounts from prepaid accounts to income accounts.';
                }
                action("Order Pla&nning")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Order Pla&nning';
                    Image = Planning;
                    RunObject = Page "Order Planning";
                    ToolTip = 'Plan supply orders order by order to fulfill new demand.';
                }
            }

        }
    }
}