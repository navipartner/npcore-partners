page 6151480 "Magento Manag. Role Center"
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
                part(Control6151408;"Discount Activities")
                {
                    Visible = false;
                }
                group(Control6151407)
                {
                    ShowCaption = false;
                    part(Control6151406;"Magento Retail Activities")
                    {
                    }
                }
            }
            group(Control6151405)
            {
                ShowCaption = false;
                part(Control6151404;"Magento Top 10 Customers")
                {
                }
                part(Control6151403;"Magento Top 10 Items by Qty")
                {
                }
                part(Control6151402;"Magento Top 10 SalesPerson")
                {
                }
            }
            group(Control6151401)
            {
                ShowCaption = false;
                part(Control6151400;"Magento Sales Chart")
                {
                }
                part(Control6151409;"RSS Reader Activities")
                {
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
                RunObject = Page "Retail Item List";
            }
            action("Internet Item List")
            {
                Caption = 'Internet Items';
                RunObject = Page "Retail Item List";
                RunPageLink = "Magento Item"=CONST(true);
            }
            action("Magento Item Groups")
            {
                Caption = 'Magento Item Groups';
                RunObject = Page "Magento Item Groups";
                Visible = false;
            }
            action(Brands)
            {
                Caption = 'Brands';
                RunObject = Page "Magento Brands";
                Visible = false;
            }
            action(Attributes)
            {
                Caption = 'Attributes';
                RunObject = Page "Magento Attributes";
                Visible = false;
            }
            action("Attribute Sets")
            {
                Caption = 'Attribute Sets';
                RunObject = Page "Magento Attribute Sets";
                Visible = false;
            }
            action(Pictures)
            {
                Caption = 'Pictures';
                RunObject = Page "Magento Pictures";
                Visible = false;
            }
        }
    }
}

