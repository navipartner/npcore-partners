page 6151480 "NPR Magento Manag. Role Center"
{
    Caption = 'Role Center';
    PageType = RoleCenter;
    UsageCategory = None;
    layout
    {
        area(rolecenter)
        {
            group(Control6151410)
            {
                ShowCaption = false;
                part(Control6151408; "NPR Discount Activities")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                group(Control6151407)
                {
                    ShowCaption = false;
                    part(Control6151406; "NPR Magento Retail Activities")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(Control6151405)
            {
                ShowCaption = false;
                part(Control6151404; "NPR Magento Top 10 Customers")
                {
                    ApplicationArea = All;
                }
                part(Control6151403; "NPR Magento Top10 Items by Qty")
                {
                    ApplicationArea = All;
                }
                part(Control6151402; "NPR Magento Top 10 S.Person")
                {
                    ApplicationArea = All;
                }
            }
            group(Control6151401)
            {
                ShowCaption = false;
                part(Control6151400; "NPR Magento Sales Chart")
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
            action("Internet Item List")
            {
                Caption = 'Internet Items';
                RunObject = Page "Item List";
                RunPageLink = "NPR Magento Item" = CONST(true);
                ApplicationArea = All;
                ToolTip = 'Executes the Internet Items action';
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

