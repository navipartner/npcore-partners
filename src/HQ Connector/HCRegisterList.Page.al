page 6150903 "NPR HC Register List"
{
    // NPR5.37/BR  /20171027 CASE 267552 HQ Connector Created Object
    // NPR5.48/TJ  /20181112 CASE 331992 New action Default Dimension

    Caption = 'HC Register List';
    PageType = List;
    SourceTable = "NPR HC Register";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Opening Cash"; "Opening Cash")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field(Account; Account)
                {
                    ApplicationArea = All;
                }
                field("Gift Voucher Account"; "Gift Voucher Account")
                {
                    ApplicationArea = All;
                }
                field("Credit Voucher Account"; "Credit Voucher Account")
                {
                    ApplicationArea = All;
                }
                field("Difference Account"; "Difference Account")
                {
                    ApplicationArea = All;
                }
                field("Balanced Type"; "Balanced Type")
                {
                    ApplicationArea = All;
                }
                field("Balance Account"; "Balance Account")
                {
                    ApplicationArea = All;
                }
                field("Difference Account - Neg."; "Difference Account - Neg.")
                {
                    ApplicationArea = All;
                }
                field("Gift Voucher Discount Account"; "Gift Voucher Discount Account")
                {
                    ApplicationArea = All;
                }
                field(Rounding; Rounding)
                {
                    ApplicationArea = All;
                }
                field("Register Change Account"; "Register Change Account")
                {
                    ApplicationArea = All;
                }
                field("Date Filter"; "Date Filter")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Filter"; "Global Dimension 1 Filter")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 2 Filter"; "Global Dimension 2 Filter")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket Filter"; "Sales Ticket Filter")
                {
                    ApplicationArea = All;
                }
                field("Sales Person Filter"; "Sales Person Filter")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
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
                RunObject = Page "NPR HC Paym.Types Post. Setup";
                RunPageLink = "BC Register No." = FIELD("Register No.");
                RunPageView = SORTING("BC Payment Type POS No.", "BC Register No.")
                              ORDER(Ascending);
            }
            action("Default Dimension")
            {
                Caption = 'Default Dimension';
                Image = DefaultDimension;
                Promoted = true;
                RunObject = Page "Default Dimensions";
                RunPageLink = "Table ID" = CONST(6150902),
                              "No." = FIELD("Register No.");
            }
        }
    }
}

