page 6014558 "NPR Retail - Mngr. Role Center"
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
                part(Control6150640; "NPR Sale POS Activities")
                {
                    ApplicationArea = All;
                }
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
                RunObject = Page "NPR Retail Item List";
                ApplicationArea = All;
            }
            action("Magento Item List")
            {
                Caption = 'Magento Items';
                RunObject = Page "NPR Retail Item List";
                RunPageLink = "NPR Magento Item" = CONST(true);
                ApplicationArea = All;
            }
            action("Item Groups")
            {
                Caption = 'Item Groups';
                RunObject = Page "NPR Item Group Tree";
                ApplicationArea = All;
            }
            action("Retail Journal")
            {
                Caption = 'Retail Journal';
                RunObject = Page "NPR Retail Journal List";
                ApplicationArea = All;
            }
            action("Retail Documents")
            {
                Caption = 'Retail Documents';
                RunObject = Page "NPR Retail Document List";
                ApplicationArea = All;
            }
            action("Audit Roll")
            {
                Caption = 'Audit Roll';
                RunObject = Page "NPR Audit Roll";
                ApplicationArea = All;
            }
            action("POS Entry List")
            {
                Caption = 'POS Entry List';
                RunObject = Page "NPR POS Entry List";
                ApplicationArea = All;
            }
            action("Gift Vouchers")
            {
                Caption = 'Gift Vouchers';
                RunObject = Page "NPR Gift Voucher List";
                ApplicationArea = All;
            }
            action("Credit Vouchers")
            {
                Caption = 'Credit Vouchers';
                RunObject = Page "NPR Credit Voucher List";
                ApplicationArea = All;
            }
            action("Sales Ticket Statistics")
            {
                Caption = 'Sales Ticket Statistics';
                RunObject = Page "NPR Sales Ticket Statistics";
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
            action(MixedDiscounts)
            {
                Caption = 'Mixed Discounts';
                RunObject = Page "NPR Mixed Discount List";
                ApplicationArea = All;
            }
            action(PeriodDiscounts)
            {
                Caption = 'Period Discounts';
                RunObject = Page "NPR Campaign Discount List";
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

