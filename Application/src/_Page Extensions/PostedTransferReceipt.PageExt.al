pageextension 6014466 "NPR Posted Transfer Receipt" extends "Posted Transfer Receipt"
{
    actions
    {
        addafter("&Print")
        {
            action("NPR RetailPrint")
            {
                Caption = 'Retail Print';
                Ellipsis = true;
                Image = BinContent;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Displays the Retail Journal Print page where different labels can be printed';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    LabelManagement: Codeunit "NPR Label Management";
                begin
                    LabelManagement.ChooseLabel(Rec);
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

                ToolTip = 'Print the Price Label document.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    LabelManagement: Codeunit "NPR Label Management";
                begin
                    LabelManagement.PrintLabel(Rec, "NPR Report Selection Type"::"Price Label".AsInteger());
                end;
            }

            action("NPR PrintRetailPrice")
            {
                Caption = 'Print Transfer Receipt Calculation';
                ToolTip = 'Runs a Transfer Receipt Calculation report.';
                ApplicationArea = NPRRSRLocal;
                Image = Print;

                trigger OnAction()
                var
                    TransRecPurchPriceCalc: Report "NPR RS Ret. Trans. Rec. Calc.";
                begin
                    TransRecPurchPriceCalc.SetFilters(Rec."No.", Rec."Posting Date");
                    TransRecPurchPriceCalc.RunModal();
                end;
            }
        }
    }
}