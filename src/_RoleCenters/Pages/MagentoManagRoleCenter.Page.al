page 6151480 "NPR Magento Manag. Role Center"
{
    // MAG1.17/MH/20150423  CASE 212263 Created NaviConnect Role Center
    // MAG1.17/BHR/20150428 CASE 212069 Removed "retail Document Activities
    // MAG1.20/BHR/20150925 CASE 223709 Added part 'NaviConnect Top 10 SalesPerson'
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.00/TS/20160627 CASE 245496 Removed Part Sale POS Activities
    // MAG2.00/TS/20160715 CASE 246438 Added Rss Activities

    Caption = 'Role Center';
    PageType = RoleCenter;

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
                part(Control6151409; "NPR RSS Reader Activ.")
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
                RunObject = Page "NPR Retail Item List";
                ApplicationArea = All;
            }
            action("Internet Item List")
            {
                Caption = 'Internet Items';
                RunObject = Page "NPR Retail Item List";
                RunPageLink = "NPR Magento Item" = CONST(true);
                ApplicationArea = All;
            }
            action("Magento Item Groups")
            {
                Caption = 'Magento Item Groups';
                RunObject = Page "NPR Magento Categories";
                Visible = false;
                ApplicationArea = All;
            }
            action(Brands)
            {
                Caption = 'Brands';
                RunObject = Page "NPR Magento Brands";
                Visible = false;
                ApplicationArea = All;
            }
            action(Attributes)
            {
                Caption = 'Attributes';
                RunObject = Page "NPR Magento Attributes";
                Visible = false;
                ApplicationArea = All;
            }
            action("Attribute Sets")
            {
                Caption = 'Attribute Sets';
                RunObject = Page "NPR Magento Attribute Sets";
                Visible = false;
                ApplicationArea = All;
            }
            action(Pictures)
            {
                Caption = 'Pictures';
                RunObject = Page "NPR Magento Pictures";
                Visible = false;
                ApplicationArea = All;
            }
        }
    }
}

