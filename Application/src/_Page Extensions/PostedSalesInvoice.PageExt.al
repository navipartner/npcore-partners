pageextension 6014405 "NPR Posted Sales Invoice" extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("NPR Sell-to Customer Name 2"; Rec."Sell-to Customer Name 2")
            {

                ToolTip = 'Specifies the Sell-to Customer Name 2 that will appear on the new sales document.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Payment Method Code")
        {
            field("NPR Magento Payment Amount"; Rec."NPR Magento Payment Amount")
            {

                ToolTip = 'Specifies the sum of Payment Lines attached to the Posted Sales Invoice.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Ship-to Name")
        {
            field("NPR Ship-to Name 2"; Rec."Ship-to Name 2")
            {

                ToolTip = 'Specifies the additional name of the customer that you shipped the items on the invoice to.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Bill-to Name")
        {
            field("NPR Bill-to Name 2"; Rec."Bill-to Name 2")
            {

                ToolTip = 'Specifies the additinal name of the customer that the invoice was sent to.';
                ApplicationArea = NPRRetail;
            }
        }
    }
}