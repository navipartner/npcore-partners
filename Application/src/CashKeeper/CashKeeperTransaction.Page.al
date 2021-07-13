page 6059946 "NPR CashKeeper Transaction"
{
    // NPR5.29\CLVA\20161108 CASE NPR5.29 Object Created
    // NPR5.40/CLVA/20180307 CASE 291921 Added field "Payment Type"

    Caption = 'CashKeeper Transaction';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR CashKeeper Transaction";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Transaction No."; Rec."Transaction No.")
                {

                    ToolTip = 'Specifies the value of the Transaction No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {

                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Line No."; Rec."Sales Line No.")
                {

                    ToolTip = 'Specifies the value of the Sales Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("CK Error Code"; Rec."CK Error Code")
                {

                    ToolTip = 'Specifies the value of the CK Error Code field';
                    ApplicationArea = NPRRetail;
                }
                field("CK Error Description"; Rec."CK Error Description")
                {

                    ToolTip = 'Specifies the value of the CK Error Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Order ID"; Rec."Order ID")
                {

                    ToolTip = 'Specifies the value of the Order ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Type"; Rec."Payment Type")
                {

                    ToolTip = 'Specifies the value of the Payment Type field';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Rec.Amount)
                {

                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Action"; Rec.Action)
                {

                    ToolTip = 'Specifies the value of the Action field';
                    ApplicationArea = NPRRetail;
                }
                field("Value In Cents"; Rec."Value In Cents")
                {

                    ToolTip = 'Specifies the value of the Value In Cents field';
                    ApplicationArea = NPRRetail;
                }
                field("Paid In Value"; Rec."Paid In Value")
                {

                    ToolTip = 'Specifies the value of the Paid In Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Paid Out Value"; Rec."Paid Out Value")
                {

                    ToolTip = 'Specifies the value of the Paid Out Value field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field(Reversed; Rec.Reversed)
                {

                    ToolTip = 'Specifies the value of the Reversed field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

