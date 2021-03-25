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
                ApplicationArea = All;
                ToolTip = 'Executes the Retail Print action';
                trigger OnAction()
                var
                    LabelLibrarySubMgt: Codeunit "NPR Label Library Sub. Mgt.";
                begin
                    LabelLibrarySubMgt.ChooseLabel(Rec);
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
                ApplicationArea = All;
                ToolTip = 'Executes the Price Label action';
                trigger OnAction()
                var
                    LabelLibrarySubMgt: Codeunit "NPR Label Library Sub. Mgt.";
                    ReportSelectionRetail: Record "NPR Report Selection Retail";
                begin
                    LabelLibrarySubMgt.PrintLabel(Rec, ReportSelectionRetail."Report Type"::"Price Label");
                end;
            }
        }
    }
}