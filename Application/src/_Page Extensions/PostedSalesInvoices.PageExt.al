pageextension 6014416 "NPR Posted Sales Invoices" extends "Posted Sales Invoices"
{
    layout
    {
        addafter("Shipment Date")
        {
            field("NPR Magento Coupon"; Rec."NPR Magento Coupon")
            {

                Editable = false;
                Visible = false;
                ToolTip = 'View the Magento Coupon used on this document.';
                ApplicationArea = NPRMagento;
            }
        }
    }

    actions
    {
        addafter(Statistics)
        {
            action("NPR Filter Open")
            {
                Caption = 'Filter Open Invoices';
                Image = Filter;

                ToolTip = 'Filer Open Invoices';
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                trigger OnAction()
                begin
                    Rec.SetRange(Closed, false);
                end;
            }
        }
        addlast(processing)
        {
            group("NPR PayByLink")
            {
                Caption = 'Pay by Link';
                Image = Payment;

                action("NPR Pay by Link")
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
                action("NPR Payment Lines")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Payment Lines';
                    Image = PaymentHistory;
                    ToolTip = 'View Payment Lines';
                    trigger OnAction()
                    var
                        MagentoPaymentLine: Record "NPR Magento Payment Line";
                    begin
                        MagentoPaymentLine.Reset();
                        MagentoPaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
                        MagentoPaymentLine.SetRange("Document No.", Rec."No.");
                        Page.Run(Page::"NPR Magento Payment Line List", MagentoPaymentLine);
                    end;
                }
            }
        }

    }
}