pageextension 70000666 pageextension70000666 extends "Sales Return Order List" 
{
    // NPR5.36/THRO/20170908 CASE 285645 Added action PostAndSendPdf2Nav
    actions
    {
        addafter("Post and Email")
        {
            action(PostAndSendPdf2Nav)
            {
                Caption = 'Post and Pdf2Nav';
                Image = PostSendTo;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Post and handle as set up in ''Document Processing''';
            }
        }
    }
}

