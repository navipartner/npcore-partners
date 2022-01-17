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
                ToolTip = 'Specifies the value of the NPR Magento Coupon field';
                ApplicationArea = NPRRetail;
            }
        }
    }
    var
        [InDataSet]
        HasNotes: Boolean;
}