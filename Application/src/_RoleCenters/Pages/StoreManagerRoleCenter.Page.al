page 6059981 "NPR Store Manager Role Center"
{
    // NPR4.10/JDH/20150515 CASE 213618 Removed weather widget, since it created problems with ClickOnce deployments
    // NPR5.31/TS  /20170328  CASE 270740 My Reports added
    // NPR5.38/BR  /20180118  CASE 302790 Added POS Entry List

    Caption = 'Role Center';
    PageType = RoleCenter;
    UsageCategory = Administration;

    layout
    {
        area(rolecenter)
        {
            group(Control6150620)
            {
                ShowCaption = false;
                part(Control6150619; "NPR Sale POS Activities")
                {
                    ApplicationArea = All;
                }
                part(Control6150618; "NPR Store Manager Activ.")
                {
                    ApplicationArea = All;
                }
                part(Control6150617; "NPR Discount Activities")
                {
                    ApplicationArea = All;
                }
            }
            group(Control6150616)
            {
                ShowCaption = false;
                part(Control6150615; "NPR Sale Stats Activities")
                {
                    ApplicationArea = All;
                }
                part(Control6014400; "NPR My Reports")
                {
                    ApplicationArea = All;
                }
                systempart(Control6150613; MyNotes)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(reporting)
        {
            action("Sale Statistics")
            {
                Caption = 'Sale Statistics';
                Image = "Report";
                RunObject = Report "NPR Sales Ticket Stat.";
                ApplicationArea = All;
                ToolTip = 'Executes the Sale Statistics action';
            }
            action("Discount Statistics")
            {
                Caption = 'Discount Statistics';
                Image = "Report";
                RunObject = Report "NPR Discount Statistics";
                ApplicationArea = All;
                ToolTip = 'Executes the Discount Statistics action';
            }
            action("Customer Analysis")
            {
                Caption = 'Customer Analysis';
                Image = "Report";
                RunObject = Report "NPR Customer Analysis";
                ApplicationArea = All;
                ToolTip = 'Executes the Customer Analysis action';
            }
            action("Gift Voucher/Credit Voucher")
            {
                Caption = 'Gift Voucher/Credit Voucher';
                Image = "Report";
                RunObject = Report "NPR Gift/Credit Voucher";
                ApplicationArea = All;
                ToolTip = 'Executes the Gift Voucher/Credit Voucher action';
            }
            action("Sales Person Top 20")
            {
                Caption = 'Sales Person Top 20';
                Image = "Report";
                RunObject = Report "NPR Sales Person Top 20";
                ApplicationArea = All;
                ToolTip = 'Executes the Sales Person Top 20 action';
            }
            action("Sale Statistics per Vendor")
            {
                Caption = 'Sale Statistics per Vendor';
                Image = "Report";
                RunObject = Report "NPR Sale Statistics per Vendor";
                ApplicationArea = All;
                ToolTip = 'Executes the Sale Statistics per Vendor action';
            }
            action("Vendor/Salesperson")
            {
                Caption = 'Vendor/Salesperson';
                Image = "Report";
                RunObject = Report "NPR Vendor/Salesperson";
                ApplicationArea = All;
                ToolTip = 'Executes the Vendor/Salesperson action';
            }
            action("Item Group Overview")
            {
                Caption = 'Item Group Overview';
                Image = "Report";
                RunObject = Report "NPR Item Group Overview";
                ApplicationArea = All;
                ToolTip = 'Executes the Item Group Overview action';
            }
        }
        area(embedding)
        {
            action("Item List")
            {
                Caption = 'Item List';
                RunObject = Page "Item List";
                ApplicationArea = All;
                ToolTip = 'Executes the Item List action';
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
            action("Retail Documents")
            {
                Caption = 'Retail Documents';
                RunObject = Page "NPR Retail Document List";
                ApplicationArea = All;
                ToolTip = 'Executes the Retail Documents action';
            }
            action("Audit Roll")
            {
                Caption = 'Audit Roll';
                RunObject = Page "NPR Audit Roll";
                ApplicationArea = All;
                ToolTip = 'Executes the Audit Roll action';
            }
            action("POS Entry List")
            {
                Caption = 'POS Entry List';
                RunObject = Page "NPR POS Entry List";
                ApplicationArea = All;
                ToolTip = 'Executes the POS Entry List action';
            }
            action("Gift Vouchers")
            {
                Caption = 'Gift Vouchers';
                RunObject = Page "NPR Gift Voucher List";
                ApplicationArea = All;
                ToolTip = 'Executes the Gift Vouchers action';
            }
            action("Credit Vouchers")
            {
                Caption = 'Credit Vouchers';
                RunObject = Page "NPR Credit Voucher List";
                ApplicationArea = All;
                ToolTip = 'Executes the Credit Vouchers action';
            }
            action("Sales Ticket Statistics")
            {
                Caption = 'Sales Ticket Statistics';
                RunObject = Page "NPR Sales Ticket Statistics";
                ApplicationArea = All;
                ToolTip = 'Executes the Sales Ticket Statistics action';
            }
            action("Contacts ")
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
        }
        area(sections)
        {
            group(Statistics)
            {
                Caption = 'Statistics';
                Image = Statistics;
            }
        }
    }
}

