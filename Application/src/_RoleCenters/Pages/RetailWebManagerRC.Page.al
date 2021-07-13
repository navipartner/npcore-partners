page 6151244 "NPR Retail Web Manager RC"
{
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
        area(reporting)
        {
            group("Report")
            {
                Caption = 'Reports';
                action("Discount Statistics")
                {
                    Caption = 'Discount Statistics';
                    Image = "Report";
                    RunObject = Report "NPR Discount Statistics";

                    ToolTip = 'Executes the Discount Statistics action';
                    ApplicationArea = NPRRetail;
                }
                action("Customer Analysis")
                {
                    Caption = 'Customer Analysis';
                    Image = "Report";
                    RunObject = Report "NPR Customer Analysis";

                    ToolTip = 'Executes the Customer Analysis action';
                    ApplicationArea = NPRRetail;
                }
                action("Sale Statistics per Vendor")
                {
                    Caption = 'Sale Statistics per Vendor';
                    Image = "Report";
                    RunObject = Report "NPR Sale Statistics per Vendor";

                    ToolTip = 'Executes the Sale Statistics per Vendor action';
                    ApplicationArea = NPRRetail;
                }
                action("Vendor/Salesperson")
                {
                    Caption = 'Vendor/Salesperson';
                    Image = "Report";
                    RunObject = Report "NPR Vendor/Salesperson";

                    ToolTip = 'Executes the Vendor/Salesperson action';
                    ApplicationArea = NPRRetail;
                }
                action("Item Group Overview")
                {
                    Caption = 'Item Group Overview';
                    Image = "Report";
                    RunObject = Report "NPR Item Group Overview";

                    ToolTip = 'Executes the Item Group Overview action';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(Processing)
        {

            group("Setup Group")
            {
                Caption = 'Set up';
                action("Magento Setup")

                {
                    Caption = 'Magento Setup';
                    Image = List;
                    RunObject = Page "NPR Magento Setup";

                    ToolTip = 'Executes the Magento Setup action';
                    ApplicationArea = NPRRetail;
                }
                action(Websites)
                {
                    Caption = 'Websites';
                    Image = Setup;
                    RunObject = Page "NPR Magento Website List";

                    ToolTip = 'Executes the Websites action';
                    ApplicationArea = NPRRetail;
                }
                action(Pictures)
                {
                    Caption = 'Pictures';
                    Image = Setup;
                    RunObject = Page "NPR Magento Pictures";

                    ToolTip = 'Executes the Pictures action';
                    ApplicationArea = NPRRetail;
                }
                action("Shipping Method Mapping")
                {
                    Caption = 'Shipping Method Mapping';
                    Image = Setup;
                    RunObject = Page "NPR Magento Shipment Mapping";

                    ToolTip = 'Executes the Shipping Method Mapping action';
                    ApplicationArea = NPRRetail;
                }

                action("Payment Method Mapping")
                {
                    Caption = 'Payment Method Mapping';
                    Image = Setup;
                    RunObject = page "NPR Magento Payment Mapping";

                    ToolTip = 'Executes the Payment Method Mapping action';
                    ApplicationArea = NPRRetail;
                }

                action("Payment Gateways")
                {
                    Caption = 'Payment Gateways';
                    Image = Setup;
                    RunObject = page "NPR Magento Payment Gateways";

                    ToolTip = 'Executes the Payment Gateways action';
                    ApplicationArea = NPRRetail;
                }

                action("VAT Business Posting Groups")
                {
                    Caption = 'VAT Business Posting Groups';
                    Image = Setup;
                    RunObject = page "VAT Business Posting Groups";

                    ToolTip = 'Executes the VAT Business Posting Groups action';
                    ApplicationArea = NPRRetail;
                }
                action("VAT Product Posting Groups")
                {
                    Caption = 'VAT Product Posting Groups';
                    Image = Setup;
                    RunObject = page "VAT Product Posting Groups";

                    ToolTip = 'Executes the VAT Product Posting Groups action';
                    ApplicationArea = NPRRetail;
                }
                action("Tax Classes")
                {
                    Caption = 'Tax Classes';
                    Image = Setup;
                    RunObject = page "NPR Magento Tax Classes";

                    ToolTip = 'Executes the Tax Classes action';
                    ApplicationArea = NPRRetail;
                }

                action(Webshops)
                {
                    Caption = 'Webshops';
                    Image = List;
                    RunObject = page "NPR Magento Store List";

                    ToolTip = 'Executes the Webshops action';
                    ApplicationArea = NPRRetail;
                }

                action("Customer Mapping")
                {
                    Caption = 'Magento Customer Mapping';
                    Image = List;
                    RunObject = page "NPR Magento Customer Mapping";

                    ToolTip = 'Executes the Magento Customer Mapping action';
                    ApplicationArea = NPRRetail;
                }
            }

            group(Content)
            {
                Caption = 'Content';
                group(Lists)
                {
                    Caption = 'Lists';
                    Image = List;
                    action(Items)
                    {
                        Caption = 'Items';
                        Image = List;
                        RunObject = page "Item List";

                        ToolTip = 'Executes the Items action';
                        ApplicationArea = NPRRetail;
                    }
                    action(ItemGroups)
                    {
                        Caption = 'Items Groups';
                        Image = List;
                        RunObject = page "Item List";

                        ToolTip = 'Executes the Items Groups action';
                        ApplicationArea = NPRRetail;
                    }
                    action(Brands)
                    {
                        Caption = 'Brands';
                        Image = List;
                        RunObject = page "Item List";

                        ToolTip = 'Executes the Brands action';
                        ApplicationArea = NPRRetail;
                    }
                    action(CustomOptions)
                    {
                        Caption = 'Customer Options';
                        Image = List;
                        RunObject = page "Item List";

                        ToolTip = 'Executes the Customer Options action';
                        ApplicationArea = NPRRetail;
                    }
                    action(AttributeSets)
                    {
                        Caption = 'Attribute Sets';
                        Image = List;
                        RunObject = page "Item List";

                        ToolTip = 'Executes the Attribute Sets action';
                        ApplicationArea = NPRRetail;
                    }
                    action(AttributeGroup)
                    {
                        Caption = 'Attribute Group';
                        Image = List;
                        RunObject = page "Item List";

                        ToolTip = 'Executes the Attribute Group action';
                        ApplicationArea = NPRRetail;
                    }
                    action(Attributes)
                    {
                        Caption = 'Attributes';
                        Image = List;
                        RunObject = page "Item List";

                        ToolTip = 'Executes the Attributes action';
                        ApplicationArea = NPRRetail;
                    }
                }

                group(Business2Business)
                {
                    Caption = 'Business2Business';
                    Image = BusinessRelation;
                    action(DisplayGroups)
                    {
                        Caption = 'Display Group';
                        Image = List;
                        RunObject = page "Item List";

                        ToolTip = 'Executes the Display Group action';
                        ApplicationArea = NPRRetail;
                    }
                    action(DisplayConfig)
                    {
                        Caption = 'Display Config';
                        Image = List;
                        RunObject = page "Item List";

                        ToolTip = 'Executes the Display Config action';
                        ApplicationArea = NPRRetail;
                    }
                }
            }

            Group(Sales)
            {
                group(OrderProcessing)
                {
                    Caption = 'Order Processing';
                    Image = Order;
                    action(Contacts)
                    {
                        Caption = 'Contacts';
                        Image = List;
                        RunObject = page "Contact List";

                        ToolTip = 'Executes the Contacts action';
                        ApplicationArea = NPRRetail;
                    }
                    action(Customersales)
                    {
                        Caption = 'Customers';
                        Image = List;
                        RunObject = page "Customer List";

                        ToolTip = 'Executes the Customers action';
                        ApplicationArea = NPRRetail;
                    }
                    action(SalesOrders)
                    {
                        Caption = 'Sales Orders';
                        Image = List;
                        RunObject = page "Sales Order List";

                        ToolTip = 'Executes the Sales Orders action';
                        ApplicationArea = NPRRetail;
                    }
                    action(PaymentLineList)
                    {
                        Caption = 'Payment Line List';
                        Image = List;
                        RunObject = page "NPR Magento Payment Line List";

                        ToolTip = 'Executes the Payment Line List action';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Tasks)
                {
                    Caption = 'Tasks';
                    Image = Task;
                    action(ImportList)
                    {
                        Caption = 'Import List';
                        Image = List;

                        RunObject = page "NPR Nc Import List";

                        ToolTip = 'Executes the Import List action';
                        ApplicationArea = NPRRetail;
                    }

                    action("Task List")
                    {
                        Caption = 'Task List';
                        Image = List;
                        RunObject = page "Task List";

                        ToolTip = 'Executes the Task List action';
                        ApplicationArea = NPRRetail;
                    }

                    action(UnProcessedImportList)
                    {
                        Caption = 'Unprocessed Import List';
                        Image = List;

                        RunObject = page "NPR Nc Import List";
                        RunPageView = WHERE("Runtime Error" = const(true));

                        ToolTip = 'Executes the Unprocessed Import List action';
                        ApplicationArea = NPRRetail;
                    }

                    action("UnProcessedTask List")
                    {
                        Caption = 'Unprocessed Task List';
                        Image = List;
                        RunObject = page "NPR Nc Task List";
                        RunPageView = WHERE("Process Error" = const(true));

                        ToolTip = 'Executes the Unprocessed Task List action';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Archive)
                {
                    Caption = 'Archive';
                    Image = Archive;
                    action(PostedSalesInv)
                    {
                        Caption = 'Posted Sales Invoices';
                        Image = List;
                        RunObject = page "Posted Sales Invoice";

                        ToolTip = 'Executes the Posted Sales Invoices action';
                        ApplicationArea = NPRRetail;
                    }
                    action(PostedSalesShipments)
                    {
                        Caption = 'Posted Sales Shipments';
                        Image = List;
                        RunObject = page "Posted Sales Shipment";

                        ToolTip = 'Executes the Posted Sales Shipments action';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            Group(NaviConnectSetup)
            {
                Caption = 'NaviConnect Setup';
                action(NaviConnectSetupAction)
                {
                    Caption = 'NaviConnect Setup';
                    Image = Setup;
                    RunObject = page "NPR Nc Setup";

                    ToolTip = 'Executes the NaviConnect Setup action';
                    ApplicationArea = NPRRetail;
                }
                action(NpXmlSetup)
                {
                    Caption = 'NpXml Setup';
                    Image = Setup;
                    RunObject = page "NPR NpXml Setup";

                    ToolTip = 'Executes the NpXml Setup action';
                    ApplicationArea = NPRRetail;
                }

                action(TaskProcessors)
                {
                    Caption = 'Task Processors';
                    Image = List;
                    RunObject = page "NPR Nc Task Proces. List";

                    ToolTip = 'Executes the Task Processors action';
                    ApplicationArea = NPRRetail;
                }
                action(TaskSetup)
                {
                    Caption = 'Task Setup';
                    Image = Setup;
                    RunObject = page "NPR NpXml Setup";

                    ToolTip = 'Executes the Task Setup action';
                    ApplicationArea = NPRRetail;
                }
                action(ImportTypes)
                {
                    Caption = 'Import Types';
                    Image = List;
                    RunObject = page "NPR Nc Import Types";

                    ToolTip = 'Executes the Import Types action';
                    ApplicationArea = NPRRetail;
                }
                action(DataLogSetup)
                {
                    Caption = 'Data Log Setup';
                    Image = SetupLines;
                    RunObject = page "NPR Data Log Setup";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Data Log Setup action';
                }

            }
        }
        area(embedding)
        {
            action("Item List")
            {
                Caption = 'Item List';
                RunObject = Page "Item List";

                ToolTip = 'Executes the Item List action';
                ApplicationArea = NPRRetail;
            }
            action("Item Groups")
            {
                Caption = 'Item Groups';
                RunObject = Page "NPR Magento Categories";

                ToolTip = 'Executes the Item Groups action';
                ApplicationArea = NPRRetail;
            }
            action("Sale Orders")
            {
                Caption = 'Sale Orders';
                RunObject = Page "Sales Order List";

                ToolTip = 'Executes the Sale Orders action';
                ApplicationArea = NPRRetail;
            }


            action("POS Entry List")
            {
                Caption = 'POS Entry List';
                RunObject = Page "NPR POS Entry List";

                ToolTip = 'Executes the POS Entry List action';
                ApplicationArea = NPRRetail;
            }
            action("Contacts ")
            {
                Caption = 'Contact List';
                RunObject = Page "Contact List";

                ToolTip = 'Executes the Contact List action';
                ApplicationArea = NPRRetail;
            }
            action(Customers)
            {
                Caption = 'Customer List';
                RunObject = Page "Customer List";

                ToolTip = 'Executes the Customer List action';
                ApplicationArea = NPRRetail;
            }

            action("Xml Templates")
            {
                Caption = 'Xml Templates';
                RunObject = Page "NPR NpXml Template List";

                ToolTip = 'Executes the Xml Templates action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

