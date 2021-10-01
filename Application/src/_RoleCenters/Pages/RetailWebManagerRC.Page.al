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

            group("Magento Content")
            {
                Caption = 'Magento Content';
                action(Items)
                {
                    Caption = 'Items';
                    RunObject = Page "Item List";

                    ToolTip = 'Executes the Item List action';
                    ApplicationArea = NPRRetail;
                }
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
    }
}
