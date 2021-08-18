pageextension 6014487 "NPR Sales Order List" extends "Sales Order List"
{
    layout
    {
        modify("No.")
        {
            Style = Attention;
            StyleExpr = HasNotes;
        }
        addafter("Requested Delivery Date")
        {
            field("NPR Promised Delivery Date"; Rec."Promised Delivery Date")
            {

                ToolTip = 'Specifies the value of the Promised Delivery Date field';
                ApplicationArea = NPRRetail;
            }
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
    actions
    {
        addafter(Documents)
        {
            action("NPR TransferOrders")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Category9;
                Caption = 'Transfer Orders';
                ToolTip = 'Displays Transfer Orders which have External Document No. equal as Order No.';
                Image = TransferOrder;

                trigger OnAction()
                var
                    TransferHeader: Record "Transfer Header";
                begin
                    TransferHeader.SetRange("External Document No.", Rec."No.");
                    Page.Run(Page::"Transfer Orders", TransferHeader);
                end;
            }
        }
    }

    var
        [InDataSet]
        HasNotes: Boolean;
}