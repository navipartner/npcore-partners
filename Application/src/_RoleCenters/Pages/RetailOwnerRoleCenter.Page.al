page 6014559 "NPR Retail - Owner Role Center"
{
    Caption = 'Role Center';
    PageType = RoleCenter;
    UsageCategory = None;
    layout
    {
        area(rolecenter)
        {
            group(Control6150641)
            {
                ShowCaption = false;
                part(Control6150638; "NPR Discount Activities")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                group(Control6151401)
                {
                    ShowCaption = false;
                    part(Control6150616; "NPR Retail Sales Chart")
                    {
                        ApplicationArea = All;
                    }
                    part(Control6014400; "NPR My Reports")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(Control6151404)
            {
                ShowCaption = false;
                part(Control6150615; "NPR Retail Top 10 Customers")
                {
                    ApplicationArea = All;
                }
                part(Control6150614; "NPR Retail 10 Items by Qty.")
                {
                    ApplicationArea = All;
                }
                part(Control6150613; "NPR Retail Top 10 S.person")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(embedding)
        {
            action("Item List")
            {
                Caption = 'Item List';
                RunObject = Page "Item List";
                ApplicationArea = All;
                ToolTip = 'Executes the Item List action';
            }
            action("Magento Item List")
            {
                Caption = 'Magento Items';
                RunObject = Page "Item List";
                RunPageLink = "NPR Magento Item" = CONST(true);
                ApplicationArea = All;
                ToolTip = 'Executes the Magento Items action';
            }
            action("Item Groups")
            {
                Caption = 'Item Groups';
                RunObject = Page "NPR Item Group Tree";
                ApplicationArea = All;
                ToolTip = 'Executes the Item Groups action';
            }
            action("Retail Journal")
            {
                Caption = 'Retail Journal';
                RunObject = Page "NPR Retail Journal List";
                ApplicationArea = All;
                ToolTip = 'Executes the Retail Journal action';
            }
            action("POS Entry List")
            {
                Caption = 'POS Entry List';
                RunObject = Page "NPR POS Entry List";
                ApplicationArea = All;
                ToolTip = 'Executes the POS Entry List action';
            }
            action("Sales Ticket Statistics")
            {
                Caption = 'Sales Ticket Statistics';
                RunObject = Page "NPR Sales Ticket Statistics";
                ApplicationArea = All;
                ToolTip = 'Executes the Sales Ticket Statistics action';
            }
            action(Contacts)
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
            action(MixedDiscounts)
            {
                Caption = 'Mixed Discounts';
                RunObject = Page "NPR Mixed Discount List";
                ApplicationArea = All;
                ToolTip = 'Executes the Mixed Discounts action';
            }
            action(PeriodDiscounts)
            {
                Caption = 'Period Discounts';
                RunObject = Page "NPR Campaign Discount List";
                ApplicationArea = All;
                ToolTip = 'Executes the Period Discounts action';
            }
            action("Magento Item Groups")
            {
                Caption = 'Magento Item Groups';
                RunObject = Page "NPR Magento Categories";
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Magento Item Groups action';
            }
            action(Brands)
            {
                Caption = 'Brands';
                RunObject = Page "NPR Magento Brands";
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Brands action';
            }
            action(Attributes)
            {
                Caption = 'Attributes';
                RunObject = Page "NPR Magento Attributes";
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Attributes action';
            }
            action("Attribute Sets")
            {
                Caption = 'Attribute Sets';
                RunObject = Page "NPR Magento Attribute Sets";
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Attribute Sets action';
            }
            action(Pictures)
            {
                Caption = 'Pictures';
                RunObject = Page "NPR Magento Pictures";
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Pictures action';
            }
        }
    }
}