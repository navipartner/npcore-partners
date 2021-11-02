pageextension 6014465 "NPR Posted Transfer Shipment" extends "Posted Transfer Shipment"
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