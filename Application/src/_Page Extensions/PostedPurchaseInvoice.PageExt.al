pageextension 6014514 "NPR Posted Purchase Invoice" extends "Posted Purchase Invoice"
{
    actions
    {
        addafter(AttachAsPDF)
        {
            action("NPR PrintRetailPrice")
            {
                Caption = 'Print Purchase Price Calculation';
                ToolTip = 'Runs a Purchase Price Calculation report.';
                ApplicationArea = NPRRSRLocal;
                Image = Print;

                trigger OnAction()
                var
                    RetailPurchPriceCalc: Report "NPR RS Ret. Purch. Price Calc.";
                begin
                    RetailPurchPriceCalc.SetFilters(Rec."No.", Rec."Posting Date");
                    RetailPurchPriceCalc.RunModal();
                end;
            }
        }
    }
}