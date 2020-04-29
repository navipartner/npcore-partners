page 6014558 "Retail - Manager Role Center"
{
    // NC1.17/MH/20150423       CASE 212263 Created NaviConnect Role Center
    // NC1.17/BHR/20150428      CASE 212069 Removed "retail Document Activities
    // NC1.20/BHR/20150925      CASE 223709 Added part 'NaviConnect Top 10 SalesPerson'
    // NPR5.23/TS/20160509      CASE 240912 Removed Naviconnect Activities
    // NPR5.23.03/MHA/20160726  CASE 242557 Magento references updated according to MAG2.00
    // NPR5.31/TS  /20170328  CASE 270740 My Reports added
    // NPR5.32/MHA /20170515  CASE 276241 Charts group moved into first column to reduce total column qty. from 3 to 2
    // NPR5.38/BR  /20180118  CASE 302790 Added POS Entry List

    Caption = 'Role Center';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            group(Control6150641)
            {
                ShowCaption = false;
                part(Control6150640;"Sale POS Activities")
                {
                }
                part(Control6150638;"Discount Activities")
                {
                    Visible = false;
                }
                group(Control6151401)
                {
                    ShowCaption = false;
                    part(Control6150616;"Retail Sales Chart")
                    {
                    }
                    part(Control6014400;"My Reports")
                    {
                    }
                }
            }
            group(Control6151404)
            {
                ShowCaption = false;
                part(Control6150615;"Retail Top 10 Customers")
                {
                }
                part(Control6150614;"Retail 10 Items by Qty.")
                {
                }
                part(Control6150613;"Retail Top 10 Salesperson")
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
            action("Magento Item List")
            {
                Caption = 'Magento Items';
                RunObject = Page "Retail Item List";
                RunPageLink = "Magento Item"=CONST(true);
            }
            action("Item Groups")
            {
                Caption = 'Item Groups';
                RunObject = Page "Item Group Tree";
            }
            action("Retail Journal")
            {
                Caption = 'Retail Journal';
                RunObject = Page "Retail Journal List";
            }
            action("Retail Documents")
            {
                Caption = 'Retail Documents';
                RunObject = Page "Retail Document List";
            }
            action("Audit Roll")
            {
                Caption = 'Audit Roll';
                RunObject = Page "Audit Roll";
            }
            action("POS Entry List")
            {
                Caption = 'POS Entry List';
                RunObject = Page "POS Entry List";
            }
            action("Gift Vouchers")
            {
                Caption = 'Gift Vouchers';
                RunObject = Page "Gift Voucher List";
            }
            action("Credit Vouchers")
            {
                Caption = 'Credit Vouchers';
                RunObject = Page "Credit Voucher List";
            }
            action("Sales Ticket Statistics")
            {
                Caption = 'Sales Ticket Statistics';
                RunObject = Page "Sales Ticket Statistics";
            }
            action("Contacts ")
            {
                Caption = 'Contact List';
                RunObject = Page "Contact List";
            }
            action(Customers)
            {
                Caption = 'Customer List';
                RunObject = Page "Customer List";
            }
            action(MixedDiscounts)
            {
                Caption = 'Mixed Discounts';
                RunObject = Page "Mixed Discount List";
            }
            action(PeriodDiscounts)
            {
                Caption = 'Period Discounts';
                RunObject = Page "Campaign Discount List";
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

