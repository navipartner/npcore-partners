pageextension 50038 pageextension50038 extends "Sales Invoice" 
{
    // NPR5.23/JDH /20160513 CASE 240916 Deleted old VariaX Matrix Action
    // NPR5.23/TS/20160603 CASE 2430085 Added field Posting Description
    // NPR5.29/TJ  /20170113 CASE 262797 Restored standard values in property ToolTipML in some actions
    // NPR5.36/THRO/20170908 CASE 285645 Added action PostAndSendPdf2Nav
    // NPR5.38/BR  /20171117 CASE 295255 Added Action POS Entries
    // NPR5.49/BHR /20190227 CASE 346899 Add Action Import Scanner
    layout
    {
        addafter("Posting Date")
        {
            field(NPPostingDescription1;"Posting Description")
            {
                Visible = false;
            }
        }
    }
    actions
    {
        addafter("Co&mments")
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
        addafter("Remove From Job Queue")
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

