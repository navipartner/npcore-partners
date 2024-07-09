page 6151244 "NPR Retail Web Manager RC"
{
    Extensible = False;
    Caption = 'NP Retail Web Manag. Role Center';
    PageType = RoleCenter;
    UsageCategory = None;
    ObsoleteState = Pending;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Not used anymore';

    layout
    {
        area(rolecenter)
        {
            part(NPRETAILACTIVITIES; "NPR Activities")
            {
                ApplicationArea = NPRRetail;
            }
            part(Control6014400; "NPR My Reports")
            {
                ApplicationArea = NPRRetail;
            }
            part(Control21; "Report Inbox Part")
            {
                AccessByPermission = TableData "Report Inbox" = R;
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

            group("Magento Content")
            {
                Caption = 'Magento Content';
                action(Attributes)
                {
                    Caption = 'Attributes';
                    Image = List;
                    RunObject = page "NPR Magento Attributes";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Magento Attributes';
                }
                action("Attribute Sets")
                {
                    Caption = 'Attribute Sets';
                    Image = List;
                    RunObject = page "NPR Magento Attribute Sets";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Magento Attribute Sets';
                }
                action("Attribute Groups")
                {
                    Caption = 'Attribute Groups';
                    Image = List;
                    RunObject = page "NPR Magento Attr. Group List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Magento Attribute Groups';
                }

                action(Categories)
                {
                    Caption = 'Categories';
                    Image = List;
                    RunObject = page "NPR Magento Categories";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Magento Categories';
                }


                action(Brands)
                {
                    Caption = 'Brands';
                    Image = List;
                    RunObject = page "NPR Magento Brands";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Magento Brands';
                }
                action("Magento Setup")
                {
                    Caption = 'Magento Setup';
                    Image = List;
                    RunObject = page "NPR Magento Setup";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Magento Setup';
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

                action("Sales Orders")
                {
                    Caption = 'Sales Orders';
                    Image = List;
                    RunObject = page "Sales Order List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Sales Orders';
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
                    ToolTip = 'View or edit the Sales Invoices';
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
                action("Archived Coupons")
                {
                    Caption = 'Archived Coupons';
                    Image = List;
                    RunObject = page "NPR NpDc Arch. Coupons";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Archived Coupons';
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
            action("Import List")
            {
                Caption = 'Import List';
                RunObject = Page "NPR Nc Import List";

                ToolTip = 'View or edit the Import List';
                ApplicationArea = NPRRetail;
            }
        }
    }
}
