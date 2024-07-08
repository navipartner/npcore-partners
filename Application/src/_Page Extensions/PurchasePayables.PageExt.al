pageextension 6014461 "NPR Purchase Payables" extends "Purchases & Payables Setup"
{
    layout
    {
        addlast(General)
        {
            field("NPR Only Qty. On Retail Print"; Rec."NPR Only Qty. On Retail Print")
            {
                ToolTip = 'Specifies if only Quantity will be printed on Retail Print';
                ApplicationArea = NPRRetail;
            }
        }
    }
}