pageextension 6014527 "NPR Sales Credit Memos" extends "Sales Credit Memos"
{

    actions
    {
        addlast(navigation)
        {
            group("NPR PayByLink Navigation")
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