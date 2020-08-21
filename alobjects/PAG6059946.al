page 6059946 "CashKeeper Transaction"
{
    // NPR5.29\CLVA\20161108 CASE NPR5.29 Object Created
    // NPR5.40/CLVA/20180307 CASE 291921 Added field "Payment Type"

    Caption = 'CashKeeper Transaction';
    Editable = false;
    PageType = List;
    SourceTable = "CashKeeper Transaction";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Transaction No."; "Transaction No.")
                {
                    ApplicationArea = All;
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Sales Line No."; "Sales Line No.")
                {
                    ApplicationArea = All;
                }
                field("CK Error Code"; "CK Error Code")
                {
                    ApplicationArea = All;
                }
                field("CK Error Description"; "CK Error Description")
                {
                    ApplicationArea = All;
                }
                field("Order ID"; "Order ID")
                {
                    ApplicationArea = All;
                }
                field("Payment Type"; "Payment Type")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Action"; Action)
                {
                    ApplicationArea = All;
                }
                field("Value In Cents"; "Value In Cents")
                {
                    ApplicationArea = All;
                }
                field("Paid In Value"; "Paid In Value")
                {
                    ApplicationArea = All;
                }
                field("Paid Out Value"; "Paid Out Value")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field(Reversed; Reversed)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

