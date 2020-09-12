pageextension 6014486 "NPR Sales Return Order List" extends "Sales Return Order List"
{
    // NPR5.36/THRO/20170908 CASE 285645 Added action PostAndSendPdf2Nav
    actions
    {
        addafter("Post and Email")
        {
            action("NPR PostAndSendPdf2Nav")
            {
                Caption = 'Post and Pdf2Nav';
                Image = PostSendTo;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Post and handle as set up in ''Document Processing''';
                ApplicationArea = All;
            }
        }
    }
}

