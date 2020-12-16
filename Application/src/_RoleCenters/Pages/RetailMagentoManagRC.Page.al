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
                }
                action("Discount Statistics")
                {
                    Caption = 'Discount Statistics';
                    Image = "Report";
                    RunObject = Report "NPR Discount Statistics";
                    ApplicationArea = All;
                }
                action("Customer Analysis")
                {
                    Caption = 'Customer Analysis';
                    Image = "Report";
                    RunObject = Report "NPR Customer Analysis";
                    ApplicationArea = All;
                }
                action("Sale Statistics per Vendor")
                {
                    Caption = 'Sale Statistics per Vendor';
                    Image = "Report";
                    RunObject = Report "NPR Sale Statistics per Vendor";
                    ApplicationArea = All;
                }
                action("Vendor/Salesperson")
                {
                    Caption = 'Vendor/Salesperson';
                    Image = "Report";
                    RunObject = Report "NPR Vendor/Salesperson";
                    ApplicationArea = All;
                }
                action("Item Group Overview")
                {
                    Caption = 'Item Group Overview';
                    Image = "Report";
                    RunObject = Report "NPR Item Group Overview";
                    ApplicationArea = All;
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
                }
                action(Websites)
                {
                    Caption = 'Websites';
                    Image = Setup;
                    RunObject = Page "NPR Magento Website List";
                    ApplicationArea = All;
                }
                action(Pictures)
                {
                    Caption = 'Pictures';
                    Image = Setup;
                    RunObject = Page "NPR Magento Pictures";
                    ApplicationArea = All;
                }
                action("Shipping Method Mapping")
                {
                    Caption = 'Shipping Method Mapping';
                    Image = Setup;
                    RunObject = Page "NPR Magento Shipment Mapping";
                    ApplicationArea = All;
                }

                action("Payment Method Mapping")
                {
                    Caption = 'Payment Method Mapping';
                    Image = Setup;
                    RunObject = page "NPR Magento Payment Mapping";
                    ApplicationArea = All;
                }

                action("Payment Gateways")
                {
                    Caption = 'Payment Gateways';
                    Image = Setup;
                    RunObject = page "NPR Magento Payment Gateways";
                    ApplicationArea = All;
                }

                action("VAT Business Posting Groups")
                {
                    Caption = 'VAT Business Posting Groups';
                    Image = Setup;
                    RunObject = page "VAT Business Posting Groups";
                    ApplicationArea = All;
                }
                action("VAT Product Posting Groups")
                {
                    Caption = 'VAT Product Posting Groups';
                    Image = Setup;
                    RunObject = page "VAT Product Posting Groups";
                    ApplicationArea = All;
                }
                action("Tax Classes")
                {
                    Caption = 'Tax Classes';
                    Image = Setup;
                    RunObject = page "NPR Magento Tax Classes";
                    ApplicationArea = All;
                }

                action(Webshops)
                {
                    Caption = 'Webshops';
                    Image = List;
                    RunObject = page "NPR Magento Store List";
                    ApplicationArea = All;
                }

                action("Customer Mapping")
                {
                    Caption = 'Magento Customer Mapping';
                    Image = List;
                    RunObject = page "NPR Magento Customer Mapping";
                    ApplicationArea = All;
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
                    }
                    action(ItemGroups)
                    {
                        Caption = 'Items Groups';
                        Image = List;
                        RunObject = page "Item List";
                        ApplicationArea = All;
                    }
                    action(Brands)
                    {
                        Caption = 'Brands';
                        Image = List;
                        RunObject = page "Item List";
                        ApplicationArea = All;
                    }
                    action(CustomOptions)
                    {
                        Caption = 'Customer Options';
                        Image = List;
                        RunObject = page "Item List";
                        ApplicationArea = All;
                    }
                    action(AttributeSets)
                    {
                        Caption = 'Attribute Sets';
                        Image = List;
                        RunObject = page "Item List";
                        ApplicationArea = All;
                    }
                    action(AttributeGroup)
                    {
                        Caption = 'Attribute Group';
                        Image = List;
                        RunObject = page "Item List";
                        ApplicationArea = All;
                    }
                    action(Attributes)
                    {
                        Caption = 'Attributes';
                        Image = List;
                        RunObject = page "Item List";
                        ApplicationArea = All;
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
                    }
                    action(DisplayConfig)
                    {
                        Caption = 'Display Config';
                        Image = List;
                        RunObject = page "Item List";
                        ApplicationArea = All;
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
                    }
                    action(Customersales)
                    {
                        Caption = 'Customers';
                        Image = List;
                        RunObject = page "Customer List";
                        ApplicationArea = All;
                    }
                    action(SalesOrders)
                    {
                        Caption = 'Sales Orders';
                        Image = List;
                        RunObject = page "Sales Order List";
                        ApplicationArea = All;
                    }
                    action(PaymentLineList)
                    {
                        Caption = 'Payment Line List';
                        Image = List;
                        RunObject = page "NPR Magento Payment Line List";
                        ApplicationArea = All;
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
                    }

                    action("Task List")
                    {
                        Caption = 'Task List';
                        Image = List;
                        RunObject = page "Task List";
                        ApplicationArea = All;
                    }

                    action(UnProcessedImportList)
                    {
                        Caption = 'Unprocessed Import List';
                        Image = List;

                        RunObject = page "NPR Nc Import List";
                        RunPageView = WHERE("Runtime Error" = const(true));
                        ApplicationArea = All;
                    }

                    action("UnProcessedTask List")
                    {
                        Caption = 'Unprocessed Task List';
                        Image = List;
                        RunObject = page "NPR Nc Task List";
                        RunPageView = WHERE("Process Error" = const(true));
                        ApplicationArea = All;
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
                    }
                    action(PostedSalesShipments)
                    {
                        Caption = 'Posted Sales Shipments';
                        Image = List;
                        RunObject = page "Posted Sales Shipment";
                        ApplicationArea = All;
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
                }
                action(NpXmlSetup)
                {
                    Caption = 'NpXml Setup';
                    Image = List;
                    RunObject = page "NPR NpXml Setup";
                    ApplicationArea = All;
                }

                action(TaskProcessors)
                {
                    Caption = 'Task Processors';
                    Image = List;
                    RunObject = page "NPR Nc Task Proces. List";
                    ApplicationArea = All;
                }

                action(TaskSetup)
                {
                    Caption = 'Task Setup';
                    Image = List;
                    RunObject = page "NPR NpXml Setup";
                    ApplicationArea = All;
                }
                action(ImportTypes)
                {
                    Caption = 'Import Types';
                    Image = List;
                    RunObject = page "NPR Nc Import Types";
                    ApplicationArea = All;
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
            }
            action("Item Groups")
            {
                Caption = 'Item Groups';
                RunObject = Page "NPR Magento Categories";
                ApplicationArea = All;
            }
            action("Sale Orders")
            {
                Caption = 'Sale Orders';
                RunObject = Page "Sales Order List";
                ApplicationArea = All;
            }


            action("POS Entry List")
            {
                Caption = 'POS Entry List';
                RunObject = Page "NPR POS Entry List";
                ApplicationArea = All;
            }
            action("Contacts ")
            {
                Caption = 'Contact List';
                RunObject = Page "Contact List";
                ApplicationArea = All;
            }
            action(Customers)
            {
                Caption = 'Customer List';
                RunObject = Page "Customer List";
                ApplicationArea = All;
            }

            action("Xml Templates")
            {
                Caption = 'Xml Templates';
                RunObject = Page "NPR NpXml Template List";
                ApplicationArea = All;
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

