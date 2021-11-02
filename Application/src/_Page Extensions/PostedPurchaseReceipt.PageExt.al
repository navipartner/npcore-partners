pageextension 6014409 "NPR Posted Purchase Receipt" extends "Posted Purchase Receipt"
{
    actions
    {
        addafter("&Navigate")
        {
            action("NPR RetailPrint")
            {
                Caption = 'Retail Print';
                Ellipsis = true;
                Image = BinContent;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Executes the Retail Print action';
                ApplicationArea = NPRRetail;
                trigger OnAction()
                var
                    LabelLibrary: Codeunit "NPR Label Library";
                begin
                    LabelLibrary.ChooseLabel(Rec);
                end;
            }
            action("NPR PriceLabel")
            {
                Caption = 'Price Label';
                Image = BinContent;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+Ctrl+L';

                ToolTip = 'Executes the Price Label action';
                ApplicationArea = NPRRetail;
                trigger OnAction()
                var
                    ReportSelectionRetail: Record "NPR Report Selection Retail";
                    LabelLibrary: Codeunit "NPR Label Library";
                begin
                    LabelLibrary.PrintLabel(Rec, ReportSelectionRetail."Report Type"::"Price Label");
                end;
            }
        }
    }
}