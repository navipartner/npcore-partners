page 6059871 "NPR Retail Web Admin RC"
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
        }
    }

    actions
    {
        area(sections)
        {
            group("Magento Integration")
            {
                Caption = 'Magento Integration';
                action("Magento Setup")
                {
                    Caption = 'Magento Setup';
                    Image = List;
                    RunObject = page "NPR Magento Setup";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Magento Setup';
                }
                action("Magento Websites Setup")
                {
                    Caption = 'Magento Websites Setup';
                    Image = List;
                    RunObject = page "NPR Magento Websites";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Magento Websites Setup';
                }
                action("Magento Stores")
                {
                    Caption = 'Magento Stores';
                    Image = List;
                    RunObject = page "NPR Magento Store List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Magento Stores';
                }
                action("Magento Tax Classes")
                {
                    Caption = 'Magento Tax Classes';
                    Image = List;
                    RunObject = page "NPR Magento Tax Classes";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Magento Tax Classes';
                }
                action("VAT Business Posting Groups Mapping")
                {
                    Caption = 'VAT Business Posting Groups Mapping';
                    Image = List;
                    RunObject = page "NPR Magento VAT Bus. Groups";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the VAT Business Posting Groups Mapping';
                }
                action("VAT Product Posting Groups Mapping")
                {
                    Caption = 'VAT Product Posting Groups Mapping';
                    Image = List;
                    RunObject = page "NPR Magento VAT Prod. Groups";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the VAT Product Posting Groups Mapping';
                }
                action("Magento Shipment Method Mapping")
                {
                    Caption = 'Magento Shipment Method Mapping';
                    Image = List;
                    RunObject = page "NPR Magento Shipment Mapping";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Magento Shipment Method Mapping';
                }
                action("Magento Payment Method Mapping")
                {
                    Caption = 'Magento Payment Method Mapping';
                    Image = List;
                    RunObject = page "NPR Magento Payment Mapping";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Magento Payment Method Mapping';
                }
                action("Magento Payment Gateway Setup")
                {
                    Caption = 'Magento Payment Gateway Setup';
                    Image = List;
                    RunObject = page "NPR Magento Payment Gateways";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Payment Gateway Setup';
                }
            }
            group("Magento Content")
            {
                Caption = 'Magento Content';
                action("Items/Product list")
                {
                    Caption = 'Items/Product list';
                    Image = List;
                    RunObject = page "Item List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Item List';
                }
                action("Magento Attributes")
                {
                    Caption = 'Magento Attributes';
                    Image = List;
                    RunObject = page "NPR Magento Attributes";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Magento Attributes';
                }
                action("Magento Attribute Sets")
                {
                    Caption = 'Magento Attribute Sets';
                    Image = List;
                    RunObject = page "NPR Magento Attribute Sets";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Magento Attribute Sets';
                }
                action("Magento Attribute Groups")
                {
                    Caption = 'Magento Attribute Groups';
                    Image = List;
                    RunObject = page "NPR Magento Attr. Group List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Magento Attribute Groups';
                }

                action("Magento Categories")
                {
                    Caption = 'Magento Categories';
                    Image = List;
                    RunObject = page "NPR Magento Categories";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Magento Categories';
                }


                action("Magento Brands")
                {
                    Caption = 'Magento Brands';
                    Image = List;
                    RunObject = page "NPR Magento Brands";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Magento Brands';
                }
                action("Magento Custom Options")
                {
                    Caption = 'Magento Custom Options';
                    Image = List;
                    RunObject = page "NPR Magento Custom Option List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Custom Options';
                }
                action("Magento Pictures")
                {
                    Caption = 'Magento Pictures';
                    Image = Picture;
                    RunObject = page "NPR Magento Pictures";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Pictures';
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
                    ToolTip = 'View or edit the Customers';
                }
                action(Contact)
                {
                    Caption = 'Contacts';
                    Image = List;
                    RunObject = page "Contact List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Contacts';
                }
                action("Magento Customer Mapping")
                {
                    Caption = 'Magento Customer Mapping';
                    Image = List;
                    RunObject = page "NPR Magento Customer Mapping";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Customer Mapping';
                }
                action("Customer Config. Templates")
                {
                    Caption = 'Customer Config. Templates';
                    Image = List;
                    RunObject = page "Config. Template List";
                    RunPageLink = "Table ID" = const(18);
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Customer Config. Templates';
                }
                action("Post Code")
                {
                    Caption = 'Post Code';
                    Image = List;
                    RunObject = page "Post Codes";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Post Code';
                }
                action("Customer GDPR")
                {
                    Caption = 'Customer GDPR';
                    Image = List;
                    RunObject = page "NPR Customer GDPR Setup";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Customer GDPR';
                }
            }
            group("Magento Sales")
            {
                Caption = 'Magento Sales';
                action("Sales Orders")
                {
                    Caption = 'Sales Orders';
                    Image = Document;
                    RunObject = page "Sales Order List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Sales Orders';
                }

                action("Sales Invoices")
                {
                    Caption = 'Sales Invoices';
                    Image = Document;
                    RunObject = page "Sales Invoice List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Sales Invoices';
                }
                action("Sales Shipment")
                {
                    Caption = 'Sales Shipment';
                    Image = List;
                    RunObject = page "Posted Sales Shipments";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Sales Shipments';
                }
                action("Sales Credit Memos")
                {
                    Caption = 'Sales Credit Memos';
                    Image = Document;
                    RunObject = page "Sales Credit Memos";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Sales Credit Memos';
                }
                action("Payment Lines")
                {
                    Caption = 'Payment Lines';
                    Image = Document;
                    RunObject = page "NPR Magento Payment Line List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Payment Lines';
                }
                action("Sales Return Orders")
                {
                    Caption = 'Sales Return Orders';
                    Image = List;
                    RunObject = page "Sales Return Order List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Sales Return Orders';
                }
                action("Posted Sales Invoices")
                {
                    Caption = 'Posted Sales Invoices';
                    Image = List;
                    RunObject = page "Posted Sales Invoices";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Posted Sales Invoices';
                }
                action("Posted Sales Credit Memos")
                {
                    Caption = 'Posted Sales Credit Memos';
                    Image = List;
                    RunObject = page "Posted Sales Credit Memos";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Sales Credit Memos';
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
                    ToolTip = 'View or edit the Vouchers';
                }
                action("Archived Vouchers")
                {
                    Caption = 'Archived Vouchers';
                    Image = List;
                    RunObject = page "NPR NpRv Arch. Vouchers";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Archived Vouchers';
                }
                action("Voucher Types")
                {
                    Caption = 'Voucher Types';
                    Image = List;
                    RunObject = page "NPR NpRv Voucher Types";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Voucher Types';
                }
                action("Voucher Modules")
                {
                    Caption = 'Voucher Modules';
                    Image = List;
                    RunObject = page "NPR NpRv Voucher Modules";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Voucher Modules';
                }
                action("Retail Voucher Partners")
                {
                    Caption = 'Retail Voucher Partners';
                    Image = List;
                    RunObject = page "NPR NpRv Partners";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Retail Voucher Partners';
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
                    ToolTip = 'View or edit the NaviConnect Setup';
                }
                action("NpXml Templates Setup")
                {
                    Caption = 'NpXml Templates Setup';
                    Image = List;
                    RunObject = page "NPR NpXml Setup";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the NpXml Templates Setup';
                }
                action("Task Processors")
                {
                    Caption = 'Task Processors';
                    Image = List;
                    RunObject = page "NPR Nc Task Proces. List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Task Processors';
                }
                action("Task Setup")
                {
                    Caption = 'Task Setup';
                    Image = List;
                    RunObject = page "NPR Nc Task Setup";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Task Setup';
                }
                action("Import Types")
                {
                    Caption = 'Import Types';
                    Image = List;
                    RunObject = page "NPR Nc Import Types";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Import Types';
                }
                action("Web Services")
                {
                    Caption = 'Web Services';
                    Image = List;
                    RunObject = page "Web Services";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Web Services';
                }
                action("NpXml Template")
                {
                    Caption = 'NpXml Template';
                    Image = List;
                    RunObject = page "NPR NpXml Template List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the NpXml Template';
                }
                action("Data Log Setup")
                {
                    Caption = 'Data Log Setup';
                    Image = List;
                    RunObject = page "NPR Data Log Setup";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Data Log Setup';
                }
                action(TaskList)
                {
                    Caption = 'Task List';
                    Image = List;
                    RunObject = page "NPR Nc Task List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Task List';
                }
                action("Email Templates")
                {
                    Caption = 'Email Templates';
                    Image = List;
                    RunObject = page "NPR E-mail Templates";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Email Templates';
                }
                action("Config. Packages")
                {
                    Caption = 'Config. Packages';
                    Image = List;
                    RunObject = page "Config. Packages";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Config. Packages';
                }
                action("Import List")
                {
                    Caption = 'Import List';
                    Image = List;
                    RunObject = page "NPR Nc Import List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Import List';
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
                    ToolTip = 'View or edit the Sent to Store Orders';
                }
                action("Collect in Store Orders")
                {
                    Caption = 'Collect in Store Orders';
                    Image = List;
                    RunObject = page "NPR NpCs Coll. Store Orders";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Collect in Store Orders';
                }
                action("Archived Collect Document List")
                {
                    Caption = 'Archived Collect Document List';
                    Image = List;
                    RunObject = page "NPR NpCs Arch. Doc. List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Archived Collect Document List';
                }
                action("Collect Stores")
                {
                    Caption = 'Collect Stores';
                    Image = List;
                    RunObject = page "NPR NpCs Stores";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Collect Stores';
                }
                action("Collect Workflows")
                {
                    Caption = 'Collect Workflows';
                    Image = List;
                    RunObject = page "NPR NpCs Workflows";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Collect Workflows';
                }
                action("Collect Store Opening Hour Sets")
                {
                    Caption = 'Collect Store Opening Hour Sets';
                    Image = List;
                    RunObject = page "NPR NpCs Open. Hour Sets";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Collect Store Opening Hour Sets';
                }
                action("Collect Workflows Modules")
                {
                    Caption = 'Collect Workflows Modules';
                    Image = List;
                    RunObject = page "NPR NpCs Workflow Modules";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Collect Workflows Modules';
                }
                action("Collect Document Mapping")
                {
                    Caption = 'Collect Document Mapping';
                    Image = List;
                    RunObject = page "NPR NpCs Document Mapping";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Collect Document Mapping';
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
                    ToolTip = 'View or edit the Members';
                }
                action(Memberships)
                {
                    Caption = 'Memberships';
                    Image = List;
                    RunObject = page "NPR MM Memberships";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Memberships';
                }
                action("Member Cards")
                {
                    Caption = 'Member Cards';
                    Image = List;
                    RunObject = page "NPR MM Member Card List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Member Cards';
                }
                action("MCS Person")
                {
                    Caption = 'MCS Person';
                    Image = List;
                    RunObject = page "NPR MCS Person";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the MCS Person';
                }
                action("MCS Faces")
                {
                    Caption = 'MCS Faces';
                    Image = List;
                    RunObject = page "NPR MCS Faces";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the MCS Faces';
                }
                action("MCS Person Business Entries")
                {
                    Caption = 'MCS Person Business Entries';
                    Image = List;
                    RunObject = page "NPR MCS Person Bus. Entities";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the MCS Person Business Entries';
                }
                action("Create Membership")
                {
                    Caption = 'Create Membership';
                    Image = List;
                    RunObject = page "NPR MM Create Membership";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Create Membership';
                }
                action("Membership Alteration Journal")
                {
                    Caption = 'Membership Alteration Journal';
                    Image = List;
                    RunObject = page "NPR MM Members. Alteration Jnl";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Membership Alteration Journal';
                }
                action("Membership Auto Renew List")
                {
                    Caption = 'Membership Auto Renew List';
                    Image = List;
                    RunObject = page "NPR MM Members. AutoRenew List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Membership Auto Renew List';
                }
                action("Membership Offline Print Journal")
                {
                    Caption = 'Membership Offline Print Journal';
                    Image = List;
                    RunObject = page "NPR MM Membership Print Jnl";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Membership Offline Print Journal';
                }
                action("Membership Status")
                {
                    Caption = 'Membership Status';
                    Image = List;
                    RunObject = report "NPR MM Membership Status";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Membership Status';
                }
                action("Membership Not Renewed")
                {
                    Caption = 'Membership Not Renewed';
                    Image = List;
                    RunObject = report "NPR MM Membership Not Renewed";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Membership Not Renewed';
                }
                action("Membership Sales Setup")
                {
                    Caption = 'Membership Sales Setup';
                    Image = List;
                    RunObject = page "NPR MM Membership Sales Setup";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Membership Sales Setup';
                }
                action("Membership Alteration")
                {
                    Caption = 'Membership Alteration';
                    Image = List;
                    RunObject = page "NPR MM Membership Alter.";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Membership Alteration';
                }
                action("Member Community")
                {
                    Caption = 'Member Community';
                    Image = List;
                    RunObject = page "NPR MM Member Community";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Member Community';
                }
                action("Membership Setup")
                {
                    Caption = 'Membership Setup';
                    Image = List;
                    RunObject = page "NPR MM Membership Setup";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Membership Setup';
                }
                action("MCS Person Group Setup")
                {
                    Caption = 'MCS Person Group Setup';
                    Image = List;
                    RunObject = page "NPR MCS Person Group Setup";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the MCS Person Group Setup';
                }
                action("MCS Person Groups")
                {
                    Caption = 'MCS Person Groups';
                    Image = List;
                    RunObject = page "NPR MCS Person Groups";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the MCS Person Groups';
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
                    ToolTip = 'View or edit the Coupons';
                }
                action("Coupon Types")
                {
                    Caption = 'Coupon Types';
                    Image = List;
                    RunObject = page "NPR NpDc Coupon Types";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Coupon Types';
                }
                action("Open/Archived Coupon Statistics")
                {
                    Caption = 'Open/Archived Coupon Statistics';
                    Image = List;
                    RunObject = report "NPR Open/Archive Coupon Stat.";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Open/Archived Coupon Statistics';
                }
                action("Archived Coupons")
                {
                    Caption = 'Archived Coupons';
                    Image = List;
                    RunObject = page "NPR NpDc Arch. Coupons";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Archived Coupons';
                }
                action("Coupon Setup")
                {
                    Caption = 'Coupon Setup';
                    Image = List;
                    RunObject = page "NPR NpDc Coupon Setup";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Coupon Setup';
                }
                action("Coupon Modules")
                {
                    Caption = 'Coupon Modules';
                    Image = List;
                    RunObject = page "NPR NpDc Coupon Modules";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Coupon Modules';
                }
            }
        }

        area(Creation)
        {
            action(Items)
            {
                Caption = 'Items';
                RunObject = Page "Item List";

                ToolTip = 'View or edit the Item List';
                ApplicationArea = NPRRetail;
            }
            action("Sales &Order")
            {
                Caption = 'Sales &Order';
                Image = Document;
                RunObject = Page "Sales Order";
                RunPageMode = Create;

                ToolTip = 'View or edit the Sales &Order';
                ApplicationArea = NPRRetail;
            }
        }
    }
}