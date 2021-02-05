page 6150903 "NPR HC Register List"
{
    Caption = 'HC Register List';
    PageType = List;
    SourceTable = "NPR HC Register";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Opening Cash"; "Opening Cash")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Opening Cash field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field(Account; Account)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account field';
                }
                field("Gift Voucher Account"; "Gift Voucher Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gift Voucher Account field';
                }
                field("Credit Voucher Account"; "Credit Voucher Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Voucher Account field';
                }
                field("Difference Account"; "Difference Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Difference Account field';
                }
                field("Balanced Type"; "Balanced Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balanced Type field';
                }
                field("Balance Account"; "Balance Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balance Account field';
                }
                field("Difference Account - Neg."; "Difference Account - Neg.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Difference Account - Neg. field';
                }
                field("Gift Voucher Discount Account"; "Gift Voucher Discount Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gift Voucher Discount Account field';
                }
                field(Rounding; Rounding)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding field';
                }
                field("Register Change Account"; "Register Change Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Change G/L Account No. field';
                }
                field("Date Filter"; "Date Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date Filter field';
                }
                field("Global Dimension 1 Filter"; "Global Dimension 1 Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Filter field';
                }
                field("Global Dimension 2 Filter"; "Global Dimension 2 Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Filter field';
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                }
                field("Sales Ticket Filter"; "Sales Ticket Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket Filter field';
                }
                field("Sales Person Filter"; "Sales Person Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Person Filter field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Payment Posting Setup action';
            }
            action("Default Dimension")
            {
                Caption = 'Default Dimension';
                Image = DefaultDimension;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = Page "Default Dimensions";
                RunPageLink = "Table ID" = CONST(6150902),
                              "No." = FIELD("Register No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Default Dimension action';
            }
        }
    }
}

