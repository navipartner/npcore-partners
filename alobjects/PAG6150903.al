page 6150903 "HC Register List"
{
    // NPR5.37/BR  /20171027 CASE 267552 HQ Connector Created Object
    // NPR5.48/TJ  /20181112 CASE 331992 New action Default Dimension

    Caption = 'HC Register List';
    PageType = List;
    SourceTable = "HC Register";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No.";"Register No.")
                {
                }
                field("Opening Cash";"Opening Cash")
                {
                }
                field("Location Code";"Location Code")
                {
                }
                field(Account;Account)
                {
                }
                field("Gift Voucher Account";"Gift Voucher Account")
                {
                }
                field("Credit Voucher Account";"Credit Voucher Account")
                {
                }
                field("Difference Account";"Difference Account")
                {
                }
                field("Balanced Type";"Balanced Type")
                {
                }
                field("Balance Account";"Balance Account")
                {
                }
                field("Difference Account - Neg.";"Difference Account - Neg.")
                {
                }
                field("Gift Voucher Discount Account";"Gift Voucher Discount Account")
                {
                }
                field(Rounding;Rounding)
                {
                }
                field("Register Change Account";"Register Change Account")
                {
                }
                field("Date Filter";"Date Filter")
                {
                }
                field("Global Dimension 1 Filter";"Global Dimension 1 Filter")
                {
                }
                field("Global Dimension 2 Filter";"Global Dimension 2 Filter")
                {
                }
                field("Global Dimension 1 Code";"Global Dimension 1 Code")
                {
                }
                field("Global Dimension 2 Code";"Global Dimension 2 Code")
                {
                }
                field("Sales Ticket Filter";"Sales Ticket Filter")
                {
                }
                field("Sales Person Filter";"Sales Person Filter")
                {
                }
                field(Description;Description)
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Payment Posting Setup")
            {
                Caption = 'Payment Posting Setup';
                Image = GeneralPostingSetup;
                RunObject = Page "HC Payment Types Posting Setup";
                RunPageLink = "BC Register No."=FIELD("Register No.");
                RunPageView = SORTING("BC Payment Type POS No.","BC Register No.")
                              ORDER(Ascending);
            }
            action("Default Dimension")
            {
                Caption = 'Default Dimension';
                Image = DefaultDimension;
                Promoted = true;
                RunObject = Page "Default Dimensions";
                RunPageLink = "Table ID"=CONST(6150902),
                              "No."=FIELD("Register No.");
            }
        }
    }
}

