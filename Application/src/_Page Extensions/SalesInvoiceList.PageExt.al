pageextension 6014526 "NPR Sales Invoice List" extends "Sales Invoice List"
{

    actions
    {
        addafter("P&osting")
        {
            group("NPR PayByLink")
            {
                Caption = 'Pay by Link';
                Image = Payment;

                action("NPR Pay by link")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Pay by Link';
                    ToolTip = 'Pay by Link.';
                    Image = LinkWeb;

                    trigger OnAction()
                    var
                        PaybyLink: Interface "NPR Pay by Link";
                        AdyenSetup: Record "NPR Adyen Setup";
                        MagentoPaymentGateway: Record "NPR Magento Payment Gateway";
                    begin
                        AdyenSetup.Get();
                        MagentoPaymentGateway.Get(AdyenSetup."Pay By Link Gateaway Code");
                        PaybyLink := MagentoPaymentGateway."Integration Type";
                        PaybyLink.SetDocument(Rec);
                        PaybyLink.SetShowDialog();
                        PaybyLink.IssuePayByLink();
                    end;
                }
            }
        }
        addlast(navigation)
        {
            group("NPR PayByLink Navigation")
            {
                Caption = 'Payments';
                Image = Payment;
                ToolTip = 'Payments';
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


}