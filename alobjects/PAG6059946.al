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
                field("Transaction No.";"Transaction No.")
                {
                }
                field("Register No.";"Register No.")
                {
                }
                field("Sales Ticket No.";"Sales Ticket No.")
                {
                }
                field("Sales Line No.";"Sales Line No.")
                {
                }
                field("CK Error Code";"CK Error Code")
                {
                }
                field("CK Error Description";"CK Error Description")
                {
                }
                field("Order ID";"Order ID")
                {
                }
                field("Payment Type";"Payment Type")
                {
                }
                field(Amount;Amount)
                {
                }
                field("Action";Action)
                {
                }
                field("Value In Cents";"Value In Cents")
                {
                }
                field("Paid In Value";"Paid In Value")
                {
                }
                field("Paid Out Value";"Paid Out Value")
                {
                }
                field(Status;Status)
                {
                }
                field(Reversed;Reversed)
                {
                }
            }
        }
    }

    actions
    {
    }
}

