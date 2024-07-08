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
    }
}