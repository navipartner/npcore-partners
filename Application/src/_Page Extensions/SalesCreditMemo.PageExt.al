pageextension 6014444 "NPR Sales Credit Memo" extends "Sales Credit Memo"
{
    layout
    {
        addafter("Responsibility Center")
        {
            field("NPR NPRPostingDescription1"; "Posting Description")
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
                ApplicationArea = All;
            }
        }
        addafter("Move Negative Lines")
        {
            action("NPR ImportFromScanner")
            {
                Caption = 'Import from scanner';
                Image = Import;
                Promoted = true;
                ApplicationArea = All;

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
                ApplicationArea = All;
            }
        }
    }
}

