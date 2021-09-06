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
        area(sections)
        {
            group("Magento Integration")
            {
                Caption = 'Magento Integration';
                action(MagentoSetup)
                {
                    Caption = 'Magento Setup';
                    Image = List;
                    RunObject = page "NPR Magento Setup";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Magento Setup action';
                }
                action("Magento Websites Setup")
                {
                    Caption = 'Magento Websites Setup';
                    Image = List;
                    RunObject = page "NPR Magento Websites";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Magento Websites Setup action';
                }
                action("Magento Stores")
                {
                    Caption = 'Magento Stores';
                    Image = List;
                    RunObject = page "NPR Magento Store List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Magento Stores action';
                }
                action("Magento Tax Classes")
                {
                    Caption = 'Magento Tax Classes';
                    Image = List;
                    RunObject = page "NPR Magento Tax Classes";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Magento Tax Classes action';
                }
                action("VAT Business Posting Groups Mapping")
                {
                    Caption = 'VAT Business Posting Groups Mapping';
                    Image = List;
                    RunObject = page "NPR Magento VAT Bus. Groups";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the VAT Business Posting Groups Mapping action';
                }
                action("VAT Product Posting Groups Mapping")
                {
                    Caption = 'VAT Product Posting Groups Mapping';
                    Image = List;
                    RunObject = page "NPR Magento VAT Prod. Groups";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the VAT Product Posting Groups Mapping action';
                }
                action("Magento Shipment Method Mapping")
                {
                    Caption = 'Magento Shipment Method Mapping';
                    Image = List;
                    RunObject = page "NPR Magento Shipment Mapping";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Magento Shipment Method Mapping action';
                }
                action("Magento Payment Method Mapping")
                {
                    Caption = 'Magento Payment Method Mapping';
                    Image = List;
                    RunObject = page "NPR Magento Payment Mapping";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Magento Payment Method Mapping action';
                }
                action("Payment Gateway Setup")
                {
                    Caption = 'Payment Gateway Setup';
                    Image = List;
                    RunObject = page "NPR Magento Payment Gateways";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Payment Gateway Setup action';
                }
            }
            group("Magento Items")
            {
                Caption = 'Magento Items';
                action("Item List")
                {
                    Caption = 'Item List';
                    RunObject = Page "Item List";

                    ToolTip = 'Executes the Item List action';
                    ApplicationArea = NPRRetail;
                }
                action("Magento Categories")
                {
                    Caption = 'Magento Categories';
                    Image = List;
                    RunObject = page "NPR Magento Categories";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Magento Categories action';
                }
                action("Magento Brands")
                {
                    Caption = 'Magento Brands';
                    Image = List;
                    RunObject = page "NPR Magento Brands";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Magento Brands action';
                }
                action("Magento Attributes")
                {
                    Caption = 'Magento Attributes';
                    Image = List;
                    RunObject = page "NPR Magento Attributes";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Magento Attributes action';
                }
                action("Magento Attribute Groups")
                {
                    Caption = 'Magento Attribute Groups';
                    Image = List;
                    RunObject = page "NPR Magento Attr. Group List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Magento Attribute Groups action';
                }
                action("Magento Attribute Sets")
                {
                    Caption = 'Magento Attribute Sets';
                    Image = List;
                    RunObject = page "NPR Magento Attribute Sets";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Magento Attribute Sets action';
                }
                action("Magento Custom Options")
                {
                    Caption = 'Magento Custom Options';
                    Image = List;
                    RunObject = page "NPR Magento Custom Option List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Magento Custom Options action';
                }
                action("Magento Pictures")
                {
                    Caption = 'Magento Pictures';
                    Image = List;
                    RunObject = page "NPR Magento Pictures";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Magento Pictures action';
                }
            }
            group("Magento Sales")
            {
                Caption = 'Magento Sales';
                action("Sales Orders")
                {
                    Caption = 'Sales Orders';
                    Image = List;
                    RunObject = page "Sales Orders";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Sales Orders action';
                }
                action("Sales Invoices")
                {
                    Caption = 'Sales Invoices';
                    Image = List;
                    RunObject = page "Posted Sales Invoices";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Sales Invoices action';
                }
                action("Sales Shipments")
                {
                    Caption = 'Sales Shipments';
                    Image = List;
                    RunObject = page "Posted Sales Shipments";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Sales Shipments action';
                }
                action("Sales Credit Memos")
                {
                    Caption = 'Sales Credit Memos';
                    Image = List;
                    RunObject = page "Posted Sales Credit Memos";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Sales Credit Memos action';
                }
                action("Payment Lines")
                {
                    Caption = 'Payment Lines';
                    Image = List;
                    RunObject = page "NPR Magento Payment Line List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Payment Lines action';
                }
                action("Sales Return Orders")
                {
                    Caption = 'Sales Return Orders';
                    Image = List;
                    RunObject = page "Sales Return Order List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Sales Return Orders action';
                }
            }
            group("Magento Customers")
            {
                Caption = 'Magento Customers';
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
                action(CustomerMapping)
                {
                    Caption = 'Customer Mapping';
                    Image = List;
                    RunObject = page "NPR Magento Customer Mapping";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Customer Mapping action';
                }
                action("Customer Config. Templates")
                {
                    Caption = 'Customer Config. Templates';
                    Image = List;
                    RunObject = page "Config. Template List";
                    RunPageLink = "Table ID" = const(18);
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Customer Config. Templates action';
                }
                action("Post Code")
                {
                    Caption = 'Post Code';
                    Image = List;
                    RunObject = page "Post Codes";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Post Code action';
                }
                action("Customer GDPR")
                {
                    Caption = 'Customer GDPR';
                    Image = List;
                    RunObject = page "NPR Customer GDPR Setup";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Customer GDPR action';
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
                action("Voucher Types")
                {
                    Caption = 'Voucher Types';
                    Image = List;
                    RunObject = page "NPR NpRv Voucher Types";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Voucher Types action';
                }
                action("Voucher Modules")
                {
                    Caption = 'Voucher Modules';
                    Image = List;
                    RunObject = page "NPR NpRv Voucher Modules";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Voucher Modules action';
                }
                action("Retail Voucher Partners")
                {
                    Caption = 'Retail Voucher Partners';
                    Image = List;
                    RunObject = page "NPR NpRv Partners";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Retail Voucher Partners action';
                }
            }
            group(NaviConnect)
            {
                Caption = 'NaviConnect';
                action("NaviConnect Setup")
                {
                    Caption = 'NaviConnect Setup';
                    Image = List;
                    RunObject = page "NPR Nc Setup";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the NaviConnect Setup action';
                }
                action("NpXml Templates Setup")
                {
                    Caption = 'NpXml Templates Setup';
                    Image = List;
                    RunObject = page "NPR NpXml Setup";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the NpXml Templates Setup action';
                }
                action("Task Processors")
                {
                    Caption = 'Task Processors';
                    Image = List;
                    RunObject = page "NPR Nc Task Proces. List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Task Processors action';
                }
                action("Task Setup")
                {
                    Caption = 'Task Setup';
                    Image = List;
                    RunObject = page "NPR Nc Task Setup";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Task Setup action';
                }
                action("Import Types")
                {
                    Caption = 'Import Types';
                    Image = List;
                    RunObject = page "NPR Nc Import Types";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Import Types action';
                }
                action("Web Services")
                {
                    Caption = 'Web Services';
                    Image = List;
                    RunObject = page "Web Services";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Web Services action';
                }
                action("NpXml Template")
                {
                    Caption = 'NpXml Template';
                    Image = List;
                    RunObject = page "NPR NpXml Template List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the NpXml Template action';
                }
                action("Data Log Setup")
                {
                    Caption = 'Data Log Setup';
                    Image = List;
                    RunObject = page "NPR Data Log Setup";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Data Log Setup action';
                }
                action(TaskList)
                {
                    Caption = 'Task List';
                    Image = List;
                    RunObject = page "NPR Nc Task List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Task List action';
                }
                action("Import List")
                {
                    Caption = 'Import List';
                    Image = List;
                    RunObject = page "NPR Nc Import List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Import List action';
                }
                action("Email Templates")
                {
                    Caption = 'Email Templates';
                    Image = List;
                    RunObject = page "NPR E-mail Templates";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Email Templates action';
                }
            }
            group("Collect Store")
            {
                Caption = 'Collect Store';
                action("Sent to Store Orders")
                {
                    Caption = 'Sent to Store Orders';
                    Image = List;
                    RunObject = page "NPR NpCs Send to Store Orders";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Sent to Store Orders action';
                }
                action("Collect in Store Orders")
                {
                    Caption = 'Collect in Store Orders';
                    Image = List;
                    RunObject = page "NPR NpCs Coll. Store Orders";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Collect in Store Orders action';
                }
                action("Archived Collect Document List")
                {
                    Caption = 'Archived Collect Document List';
                    Image = List;
                    RunObject = page "NPR NpCs Arch. Doc. List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Archived Collect Document List action';
                }
                action("Collect Stores")
                {
                    Caption = 'Collect Stores';
                    Image = List;
                    RunObject = page "NPR NpCs Stores";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Collect Stores action';
                }
                action("Collect Workflows")
                {
                    Caption = 'Collect Workflows';
                    Image = List;
                    RunObject = page "NPR NpCs Workflows";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Collect Workflows action';
                }
                action("Collect Store Opening Hour Sets")
                {
                    Caption = 'Collect Store Opening Hour Sets';
                    Image = List;
                    RunObject = page "NPR NpCs Open. Hour Sets";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Collect Store Opening Hour Sets action';
                }
                action("Collect Workflows Modules")
                {
                    Caption = 'Collect Workflows Modules';
                    Image = List;
                    RunObject = page "NPR NpCs Workflow Modules";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Collect Workflows Modules action';
                }
                action("Collect Document Mapping")
                {
                    Caption = 'Collect Document Mapping';
                    Image = List;
                    RunObject = page "NPR NpCs Document Mapping";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Collect Document Mapping action';
                }
            }

            group(Membership)
            {
                Caption = 'Membership';
                action(Members)
                {
                    Caption = 'Members';
                    Image = List;
                    RunObject = page "NPR MM Members";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Members action';
                }
                action(Memberships)
                {
                    Caption = 'Memberships';
                    Image = List;
                    RunObject = page "NPR MM Memberships";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Memberships action';
                }
                action("Member Cards")
                {
                    Caption = 'Member Cards';
                    Image = List;
                    RunObject = page "NPR MM Member Card List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Member Cards action';
                }
                action("MCS Person")
                {
                    Caption = 'MCS Person';
                    Image = List;
                    RunObject = page "NPR MCS Person";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the MCS Person action';
                }
                action("MCS Faces")
                {
                    Caption = 'MCS Faces';
                    Image = List;
                    RunObject = page "NPR MCS Faces";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the MCS Faces action';
                }
                action("MCS Person Business Entries")
                {
                    Caption = 'MCS Person Business Entries';
                    Image = List;
                    RunObject = page "NPR MCS Person Bus. Entities";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the MCS Person Business Entries action';
                }
                action("Create Membership")
                {
                    Caption = 'Create Membership';
                    Image = List;
                    RunObject = page "NPR MM Create Membership";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Create Membership action';
                }
                action("Membership Alteration Journal")
                {
                    Caption = 'Membership Alteration Journal';
                    Image = List;
                    RunObject = page "NPR MM Members. Alteration Jnl";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Membership Alteration Journal action';
                }
                action("Membership Auto Renew List")
                {
                    Caption = 'Membership Auto Renew List';
                    Image = List;
                    RunObject = page "NPR MM Members. AutoRenew List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Membership Auto Renew List action';
                }
                action("Membership Offline Print Journal")
                {
                    Caption = 'Membership Offline Print Journal';
                    Image = List;
                    RunObject = page "NPR MM Membership Print Jnl";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Membership Offline Print Journal action';
                }
                action("Membership Status")
                {
                    Caption = 'Membership Status';
                    Image = List;
                    RunObject = report "NPR MM Membership Status";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Membership Status action';
                }
                action("Membership Not Renewed")
                {
                    Caption = 'Membership Not Renewed';
                    Image = List;
                    RunObject = report "NPR MM Membership Not Renewed";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Membership Not Renewed action';
                }
                action("Membership Sales Setup")
                {
                    Caption = 'Membership Sales Setup';
                    Image = List;
                    RunObject = page "NPR MM Membership Sales Setup";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Membership Sales Setup action';
                }
                action("Membership Alteration")
                {
                    Caption = 'Membership Alteration';
                    Image = List;
                    RunObject = page "NPR MM Membership Alter.";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Membership Alteration action';
                }
                action("Member Community")
                {
                    Caption = 'Member Community';
                    Image = List;
                    RunObject = page "NPR MM Member Community";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Member Community action';
                }
                action("Membership Setup")
                {
                    Caption = 'Membership Setup';
                    Image = List;
                    RunObject = page "NPR MM Membership Setup";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Membership Setup action';
                }
                action("MCS Person Group Setup")
                {
                    Caption = 'MCS Person Group Setup';
                    Image = List;
                    RunObject = page "NPR MCS Person Group Setup";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the MCS Person Group Setup action';
                }
                action("MCS Person Groups")
                {
                    Caption = 'MCS Person Groups';
                    Image = List;
                    RunObject = page "NPR MCS Person Groups";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the MCS Person Groups action';
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
                action("Coupon Types")
                {
                    Caption = 'Coupon Types';
                    Image = List;
                    RunObject = page "NPR NpDc Coupon Types";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Coupon Types action';
                }
                action("Open/Archived Coupon Statistics")
                {
                    Caption = 'Open/Archived Coupon Statistics';
                    Image = List;
                    RunObject = report "NPR Open/Archive Coupon Stat.";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Open/Archived Coupon Statistics action';
                }
                action("Archived Coupons")
                {
                    Caption = 'Archived Coupons';
                    Image = List;
                    RunObject = page "NPR NpDc Arch. Coupons";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Archived Coupons action';
                }
                action("Coupon Setup")
                {
                    Caption = 'Coupon Setup';
                    Image = List;
                    RunObject = page "NPR NpDc Coupon Setup";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Coupon Setup action';
                }
                action("Coupon Modules")
                {
                    Caption = 'Coupon Modules';
                    Image = List;
                    RunObject = page "NPR NpDc Coupon Modules";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the Coupon Modules action';
                }
            }
        }
    }
}
