pageextension 70000252 pageextension70000252 extends "Sales Credit Memo" 
{
    // NPR5.23/TS/20160603 CASE 2430085 Added field Posting Description
    // NPR5.29/TJ/20160113 CASE 262797 Restored standard values of property ToolTipML on some actions
    // NPR5.36/THRO/20170908 CASE 285645 Added action PostAndSendPdf2Nav
    // NPR5.38/BR  /20171117 CASE 295255 Added Action POS Entries
    // NPR5.49/BHR /20190227 CASE 346899 Add Action Import Scanner
    layout
    {
        addafter("Responsibility Center")
        {
            field(NPRPostingDescription1;"Posting Description")
            {
            }
        }
    }
    actions
    {
        addafter(DocAttach)
        {
            action("POS Entry")
            {
                Caption = 'POS Entry';
                Image = Entry;
            }
        }
        addafter("Move Negative Lines")
        {
            action(ImportFromScanner)
            {
                Caption = 'Import from scanner';
                Image = Import;
                Promoted = true;

                trigger OnAction()
                begin
                    //-NPR5.49 [346899]
                    //-NPR5.49 [346899]
                end;
            }
        }
        addafter("Preview Posting")
        {
            action(PostAndSendPdf2Nav)
            {
                Caption = 'Post and Pdf2Nav';
                Image = PostSendTo;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                ToolTip = 'Post and handle as set up in ''Document Processing''';
            }
        }
    }
}

