pageextension 6014487 "NPR Sales Order List" extends "Sales Order List"
{
    layout
    {
        modify("No.")
        {
            Style = Attention;
            StyleExpr = HasNotes;
        }
        addafter("External Document No.")
        {
            field("NPR Magento Coupon"; Rec."NPR Magento Coupon")
            {

                Editable = false;
                Visible = false;
                ToolTip = 'View the Magento Coupon used on this document.';
                ApplicationArea = NPRRetail;
            }
        }
        addlast(Control1)
        {
            field("NPR Group Code"; Rec."NPR Group Code")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Group Code field.';
            }
        }
    }

    actions
    {
        addlast(navigation)
        {
            group("NPR PayByLink Navigation")
            {
                Caption = 'Payments';
                Image = Payment;
                action("NPR Payment Lines")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Payment Lines';
                    ToolTip = 'View Payment Lines';
                    Image = PaymentHistory;
                    trigger OnAction()
                    begin
                        Rec.OpenMagentPaymentLines();
                    end;
                }
            }
        }
        addafter("&Print")
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
    }
    var
        HasNotes: Boolean;
}