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
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Promised Delivery Date field';
            }
        }
        addafter("External Document No.")
        {
            field("NPR Magento Coupon"; Rec."NPR Magento Coupon")
            {
                ApplicationArea = All;
                Editable = false;
                Visible = false;
                ToolTip = 'Specifies the value of the NPR Magento Coupon field';
            }
        }
    }
    actions
    {
        addafter(Post)
        {
            action("NPR PostAndSendPdf2Nav")
            {
                Caption = 'Post and Pdf2Nav';
                Image = PostSendTo;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Post and handle as set up in ''Document Processing''';
                ApplicationArea = All;
            }
        }
    }

    var
        [InDataSet]
        HasNotes: Boolean;
}