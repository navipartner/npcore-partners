pageextension 6014484 "NPR Sales Invoice List" extends "Sales Invoice List"
{
    // NPR5.36/THRO/20170908 CASE 285645 Added action PostAndSendPdf2Nav
    actions
    {
        addafter(PostAndSend)
        {
            action("NPR PostAndSendPdf2Nav")
            {
                Caption = 'Post and Pdf2Nav';
                Image = PostSendTo;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                ToolTip = 'Post and handle as set up in ''Document Processing''';
                ApplicationArea=All;
            }
        }
    }
}

