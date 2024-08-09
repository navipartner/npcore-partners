pageextension 6014417 "NPR Posted S.Credit Memos" extends "Posted Sales Credit Memos"
{
    layout
    {
        addafter(Paid)
        {
            field("NPR Magento Coupon"; Rec."NPR Magento Coupon")
            {

                Editable = false;
                Visible = false;
                ToolTip = 'View the Magento Coupon used on this document.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter(Cancelled)
        {
            field("NPR RS Audit Entry"; RSAuxSalesCrMemoHeader."NPR RS Audit Entry")
            {
                ApplicationArea = NPRRSFiscal;
                ToolTip = 'Specifies the value of the RS Audit Entry field.';
                Editable = false;
            }
        }
    }

    actions
    {
        addlast(navigation)
        {
            group("NPR PayByLink")
            {
                Caption = 'Payments';
                Image = Payment;
                action("NPR Payment Lines")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Payment Lines';
                    Image = PaymentHistory;
                    ToolTip = 'View Payment Lines';
                    trigger OnAction()
                    begin
                        Rec.OpenMagentPaymentLines();
                    end;
                }
            }
        }
    }

    var
        RSAuxSalesCrMemoHeader: Record "NPR RS Aux Sales CrMemo Header";

    trigger OnAfterGetCurrRecord()
    begin
        RSAuxSalesCrMemoHeader.ReadRSAuxSalesCrMemoHeaderFields(Rec);
    end;
}