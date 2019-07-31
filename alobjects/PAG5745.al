pageextension 50059 pageextension50059 extends "Posted Transfer Receipt" 
{
    // NPR5.46/JDH /20181002 CASE 294354 added RetailPrint and PriceLabel
    actions
    {
        addafter("&Print")
        {
            action(RetailPrint)
            {
                Caption = 'Retail Print';
                Ellipsis = true;
                Image = BinContent;
                Promoted = true;
                PromotedCategory = Process;
            }
            action(PriceLabel)
            {
                Caption = 'Price Label';
                Image = BinContent;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
            }
        }
    }
}

