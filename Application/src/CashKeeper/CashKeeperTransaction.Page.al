page 6059946 "NPR CashKeeper Transaction"
{
    // NPR5.29\CLVA\20161108 CASE NPR5.29 Object Created
    // NPR5.40/CLVA/20180307 CASE 291921 Added field "Payment Type"

    Caption = 'CashKeeper Transaction';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR CashKeeper Transaction";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Transaction No."; "Transaction No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction No. field';
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("Sales Line No."; "Sales Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Line No. field';
                }
                field("CK Error Code"; "CK Error Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the CK Error Code field';
                }
                field("CK Error Description"; "CK Error Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the CK Error Description field';
                }
                field("Order ID"; "Order ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order ID field';
                }
                field("Payment Type"; "Payment Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Type field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Action"; Action)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Action field';
                }
                field("Value In Cents"; "Value In Cents")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Value In Cents field';
                }
                field("Paid In Value"; "Paid In Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Paid In Value field';
                }
                field("Paid Out Value"; "Paid Out Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Paid Out Value field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field(Reversed; Reversed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reversed field';
                }
            }
        }
    }

    actions
    {
    }
}

