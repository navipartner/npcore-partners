pageextension 6014466 "NPR Posted Transfer Receipt" extends "Posted Transfer Receipt"
{
    // NPR5.46/JDH /20181002 CASE 294354 added RetailPrint and PriceLabel
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
                PromotedCategory = Process;
                ApplicationArea=All;
            }
            action("NPR PriceLabel")
            {
                Caption = 'Price Label';
                Image = BinContent;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;
            }
        }
    }
}

