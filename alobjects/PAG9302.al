pageextension 70000665 pageextension70000665 extends "Sales Credit Memos" 
{
    // NPR5.36/THRO/20170908 CASE 285645 Added action PostAndSendPdf2Nav
    actions
    {
        addafter(FinanceReports)
        {
            action(PostAndSendPdf2Nav)
            {
                Caption = 'Post and Pdf2Nav';
                Image = PostSendTo;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                ToolTip = 'Post and handle as set up in ''Document Processing''';
            }
        }
    }
}

