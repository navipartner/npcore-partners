pageextension 6014528 "NPR Sales Return Order List" extends "Sales Return Order List"
{
    actions
    {
        addlast(navigation)
        {
            group("NPR PayByLink")
            {
                Caption = 'Pay by Link';
                Image = Payment;
                action("NPR Payment Lines")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Payment Lines';
                    Image = PaymentHistory;
                    ToolTip = 'View Pay by Link Payment Lines';


                    trigger OnAction()
                    begin
                        Rec.OpenMagentPaymentLines();
                    end;
                }
            }
        }
    }
}