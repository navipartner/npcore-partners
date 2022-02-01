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
                ApplicationArea = NPRRetail;
            }
        }
    }
}