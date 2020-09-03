pageextension 6014444 "NPR Sales Credit Memo" extends "Sales Credit Memo"
{
    // NPR5.23/TS/20160603 CASE 2430085 Added field Posting Description
    // NPR5.29/TJ/20160113 CASE 262797 Restored standard values of property ToolTipML on some actions
    // NPR5.36/THRO/20170908 CASE 285645 Added action PostAndSendPdf2Nav
    // NPR5.38/BR  /20171117 CASE 295255 Added Action POS Entries
    // NPR5.49/BHR /20190227 CASE 346899 Add Action Import Scanner
    // MAG2.23/MHA /20190911 CASE 355841 Added "Magento Payment Amount"
    // NPR5.55/BHR /20200525 CASE 405953 Added Fields"Bill-to E-mail","Document Processing"
    layout
    {
        addafter("Responsibility Center")
        {
            field("NPR NPRPostingDescription1"; "Posting Description")
            {
                ApplicationArea = All;
            }
        }
        addafter("Payment Method Code")
        {
            field("NPR Bill-to E-mail"; "NPR Bill-to E-mail")
            {
                ApplicationArea = All;
            }
            field("NPR Document Processing"; "NPR Document Processing")
            {
                ApplicationArea = All;
            }
        }
        addafter("EU 3-Party Trade")
        {
            field("NPR Magento Payment Amount"; "NPR Magento Payment Amount")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addafter(DocAttach)
        {
            action("NPR POS Entry")
            {
                Caption = 'POS Entry';
                Image = Entry;
            }
        }
        addafter("Move Negative Lines")
        {
            action("NPR ImportFromScanner")
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
            action("NPR PostAndSendPdf2Nav")
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

