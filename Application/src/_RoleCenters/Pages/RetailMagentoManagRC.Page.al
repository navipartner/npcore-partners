page 6151244 "NPR Retail Magento Manag. RC"
{
    // MAG1.17/MH/20150423  CASE 212263 Created NaviConnect Role Center
    // MAG1.17/BHR/20150428 CASE 212069 Removed "retail Document Activities
    // MAG1.20/BHR/20150925 CASE 223709 Added part 'NaviConnect Top 10 SalesPerson'
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.00/TS/20160627 CASE 245496 Removed Part Sale POS Activities
    // MAG2.00/TS/20160715 CASE 246438 Added Rss Activities

    Caption = 'NP Retail Magento Manag. Role Center';
    PageType = RoleCenter;
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(rolecenter)
        {



            part(Control7; "Headline RC Order Processor")
            {
                ApplicationArea = Basic, Suite;
            }

            part("NP Retail SO Processor Act"; "NPR SO Processor Act")
            {
                ApplicationArea = All;

            }


            part(NPRETAILACTIVITIES; "NPR Activities")
            {
                ApplicationArea = All;
            }


            part(Control6151403; "NPR Magento Top10 Items by Qty")
            {
                ApplicationArea = Basic, Suite;
            }
            part(Control1905989608; "My Items")
            {
                AccessByPermission = TableData "My Item" = R;
                ApplicationArea = Basic, Suite;
            }
            part(Control21; "Report Inbox Part")
            {
                AccessByPermission = TableData "Report Inbox" = R;
                ApplicationArea = Suite;
            }


            part(Control6014400; "NPR My Reports")
            {
                ApplicationArea = All;
            }


            part(Control6150616; "NPR Web Manager Activ.")
            {
                Visible = false;
                ApplicationArea = All;

            }

            systempart(Control1901377608; MyNotes)
            {
                ApplicationArea = Basic, Suite;
            }

            part(PowerBi; "Power BI Report Spinner Part")
            {
                ApplicationArea = All;

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
                action("Sale Statistics")
                {
                    Caption = 'Sale Statistics';
                    Image = "Report";
                    RunObject = Report "NPR Sales Ticket Stat.";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sale Statistics action';
                }
                action("Discount Statistics")
                {
                    Caption = 'Discount Statistics';
                    Image = "Report";
                    RunObject = Report "NPR Discount Statistics";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Discount Statistics action';
                }
                action("Customer Analysis")
                {
                    Caption = 'Customer Analysis';
                    Image = "Report";
                    RunObject = Report "NPR Customer Analysis";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Customer Analysis action';
                }
                action("Sale Statistics per Vendor")
                {
                    Caption = 'Sale Statistics per Vendor';
                    Image = "Report";
                    RunObject = Report "NPR Sale Statistics per Vendor";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sale Statistics per Vendor action';
                }
                action("Vendor/Salesperson")
                {
                    Caption = 'Vendor/Salesperson';
                    Image = "Report";
                    RunObject = Report "NPR Vendor/Salesperson";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Vendor/Salesperson action';
                }
                action("Item Group Overview")
                {
                    Caption = 'Item Group Overview';
                    Image = "Report";
                    RunObject = Report "NPR Item Group Overview";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Group Overview action';
                }
            }

            group("Setup Group")
            {
                Caption = 'Set up';
                action("Magento Setup")

                {
                    Caption = 'Magento Setup';
                    Image = List;
                    RunObject = Page "NPR Magento Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Magento Setup action';
                }
                action(Websites)
                {
                    Caption = 'Websites';
                    Image = Setup;
                    RunObject = Page "NPR Magento Website List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Websites action';
                }
                action(Pictures)
                {
                    Caption = 'Pictures';
                    Image = Setup;
                    RunObject = Page "NPR Magento Pictures";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Pictures action';
                }
                action("Shipping Method Mapping")
                {
                    Caption = 'Shipping Method Mapping';
                    Image = Setup;
                    RunObject = Page "NPR Magento Shipment Mapping";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Shipping Method Mapping action';
                }

                action("Payment Method Mapping")
                {
                    Caption = 'Payment Method Mapping';
                    Image = Setup;
                    RunObject = page "NPR Magento Payment Mapping";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Payment Method Mapping action';
                }

                action("Payment Gateways")
                {
                    Caption = 'Payment Gateways';
                    Image = Setup;
                    RunObject = page "NPR Magento Payment Gateways";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Payment Gateways action';
                }

                action("VAT Business Posting Groups")
                {
                    Caption = 'VAT Business Posting Groups';
                    Image = Setup;
                    RunObject = page "VAT Business Posting Groups";
                    ApplicationArea = All;
                    ToolTip = 'Executes the VAT Business Posting Groups action';
                }
                action("VAT Product Posting Groups")
                {
                    Caption = 'VAT Product Posting Groups';
                    Image = Setup;
                    RunObject = page "VAT Product Posting Groups";
                    ApplicationArea = All;
                    ToolTip = 'Executes the VAT Product Posting Groups action';
                }
                action("Tax Classes")
                {
                    Caption = 'Tax Classes';
                    Image = Setup;
                    RunObject = page "NPR Magento Tax Classes";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Tax Classes action';
                }

                action(Webshops)
                {
                    Caption = 'Webshops';
                    Image = List;
                    RunObject = page "NPR Magento Store List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Webshops action';
                }

                action("Customer Mapping")
                {
                    Caption = 'Magento Customer Mapping';
                    Image = List;
                    RunObject = page "NPR Magento Customer Mapping";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Magento Customer Mapping action';
                }
            }

            /*
            group(Departments)
            {
                action(MagentoSetup)
                {
                    Caption = 'Magento Setup';
                    Image = List;
                    RunObject = page "Magento Setup";
                }
            }
            */


            group(Content)
            {
                Caption = 'Content';
                group(Lists)
                {
                    Caption = 'Lists';
                    action(Items)
                    {
                        Caption = 'Items';
                        Image = List;
                        RunObject = page "Item List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Items action';
                    }
                    action(ItemGroups)
                    {
                        Caption = 'Items Groups';
                        Image = List;
                        RunObject = page "Item List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Items Groups action';
                    }
                    action(Brands)
                    {
                        Caption = 'Brands';
                        Image = List;
                        RunObject = page "Item List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Brands action';
                    }
                    action(CustomOptions)
                    {
                        Caption = 'Customer Options';
                        Image = List;
                        RunObject = page "Item List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Customer Options action';
                    }
                    action(AttributeSets)
                    {
                        Caption = 'Attribute Sets';
                        Image = List;
                        RunObject = page "Item List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Attribute Sets action';
                    }
                    action(AttributeGroup)
                    {
                        Caption = 'Attribute Group';
                        Image = List;
                        RunObject = page "Item List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Attribute Group action';
                    }
                    action(Attributes)
                    {
                        Caption = 'Attributes';
                        Image = List;
                        RunObject = page "Item List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Attributes action';
                    }
                }

                group(Business2Business)
                {
                    Caption = 'Business2Business';
                    action(DisplayGroups)
                    {
                        Caption = 'Display Group';
                        Image = List;
                        RunObject = page "Item List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Display Group action';
                    }
                    action(DisplayConfig)
                    {
                        Caption = 'Display Config';
                        Image = List;
                        RunObject = page "Item List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Display Config action';
                    }
                }
                /*
                group(ContentSetup)
                {
                    Caption = 'Setup';
                    action(WebshopsContent)
                    {
                        Caption = 'Webshops';
                        Image = List;
                        RunObject = page "Magento Store List";
                    }

                }
                
                group(ContentTasks)
                {
                    Caption = 'Tasks';
                    action(TasKList)
                    {
                        Caption = 'Task List';
                        Image = List;
                        RunObject = page "Nc Task List";
                    }
                }
                group(ContentAdministration)
                {
                    Caption = 'Administration';

                    action(Website)
                    {
                        Caption = 'Websites';
                        Image = List;
                        RunObject = page "Magento Websites";
                    }
                    action(ContentPictures)
                    {
                        Caption = 'Pictures';
                        Image = List;
                        RunObject = page "Magento Pictures";
                    }
                }
                */
            }

            Group(Sales)
            {
                group(OrderProcessing)
                {
                    Caption = 'Order Processing';
                    action(Contacts)
                    {
                        Caption = 'Contacts';
                        Image = List;
                        RunObject = page "Contact List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Contacts action';
                    }
                    action(Customersales)
                    {
                        Caption = 'Customers';
                        Image = List;
                        RunObject = page "Customer List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Customers action';
                    }
                    action(SalesOrders)
                    {
                        Caption = 'Sales Orders';
                        Image = List;
                        RunObject = page "Sales Order List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Sales Orders action';
                    }
                    action(PaymentLineList)
                    {
                        Caption = 'Payment Line List';
                        Image = List;
                        RunObject = page "NPR Magento Payment Line List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Payment Line List action';
                    }
                }
                group(Tasks)
                {
                    action(ImportList)
                    {
                        Caption = 'Import List';
                        Image = List;

                        RunObject = page "NPR Nc Import List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Import List action';
                    }

                    action("Task List")
                    {
                        Caption = 'Task List';
                        Image = List;
                        RunObject = page "Task List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Task List action';
                    }

                    action(UnProcessedImportList)
                    {
                        Caption = 'Unprocessed Import List';
                        Image = List;

                        RunObject = page "NPR Nc Import List";
                        RunPageView = WHERE("Runtime Error" = const(true));
                        ApplicationArea = All;
                        ToolTip = 'Executes the Unprocessed Import List action';
                    }

                    action("UnProcessedTask List")
                    {
                        Caption = 'Unprocessed Task List';
                        Image = List;
                        RunObject = page "NPR Nc Task List";
                        RunPageView = WHERE("Process Error" = const(true));
                        ApplicationArea = All;
                        ToolTip = 'Executes the Unprocessed Task List action';
                    }



                }
                group(Archive)
                {
                    action(PostedSalesInv)
                    {
                        Caption = 'Posted Sales Invoices';
                        Image = List;
                        RunObject = page "Posted Sales Invoice";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Posted Sales Invoices action';
                    }
                    action(PostedSalesShipments)
                    {
                        Caption = 'Posted Sales Shipments';
                        Image = List;
                        RunObject = page "Posted Sales Shipment";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Posted Sales Shipments action';
                    }
                }

            }

            Group(NaviConnectSetup)
            {
                Caption = 'NaviConnect Setup';
                action(NaviConnectSetupAction)
                {
                    Caption = 'NaviConnect Setup';
                    Image = List;
                    RunObject = page "NPR Nc Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the NaviConnect Setup action';
                }
                action(NpXmlSetup)
                {
                    Caption = 'NpXml Setup';
                    Image = List;
                    RunObject = page "NPR NpXml Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the NpXml Setup action';
                }

                action(TaskProcessors)
                {
                    Caption = 'Task Processors';
                    Image = List;
                    RunObject = page "NPR Nc Task Proces. List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Task Processors action';
                }

                action(TaskSetup)
                {
                    Caption = 'Task Setup';
                    Image = List;
                    RunObject = page "NPR NpXml Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Task Setup action';
                }
                action(ImportTypes)
                {
                    Caption = 'Import Types';
                    Image = List;
                    RunObject = page "NPR Nc Import Types";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Import Types action';
                }

            }

        }

        area(embedding)
        {
            action("Item List")
            {
                Caption = 'Item List';
                RunObject = Page "Item List";
                ApplicationArea = All;
                ToolTip = 'Executes the Item List action';
            }
            action("Item Groups")
            {
                Caption = 'Item Groups';
                RunObject = Page "NPR Magento Categories";
                ApplicationArea = All;
                ToolTip = 'Executes the Item Groups action';
            }
            action("Sale Orders")
            {
                Caption = 'Sale Orders';
                RunObject = Page "Sales Order List";
                ApplicationArea = All;
                ToolTip = 'Executes the Sale Orders action';
            }


            action("POS Entry List")
            {
                Caption = 'POS Entry List';
                RunObject = Page "NPR POS Entry List";
                ApplicationArea = All;
                ToolTip = 'Executes the POS Entry List action';
            }
            action("Contacts ")
            {
                Caption = 'Contact List';
                RunObject = Page "Contact List";
                ApplicationArea = All;
                ToolTip = 'Executes the Contact List action';
            }
            action(Customers)
            {
                Caption = 'Customer List';
                RunObject = Page "Customer List";
                ApplicationArea = All;
                ToolTip = 'Executes the Customer List action';
            }

            action("Xml Templates")
            {
                Caption = 'Xml Templates';
                RunObject = Page "NPR NpXml Template List";
                ApplicationArea = All;
                ToolTip = 'Executes the Xml Templates action';
            }
        }
        area(sections)
        {
            group(Statistics)
            {
                Caption = 'Statistics';
                Image = Statistics;
            }
        }

    }
}

