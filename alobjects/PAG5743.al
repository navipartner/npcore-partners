pageextension 50058 pageextension50058 extends "Posted Transfer Shipment" 
{
    // NPR5.46/EMGO/20180910 CASE 324737 Added Page Actions RetailPrint and PriceLabel
    // NPR5.46/JDH /20181002 CASE 294354 Removed code on RetailPrint and PriceLabel. Made them publishers so its the same functionality all around our solution
    actions
    {
        addafter("&Navigate")
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

    var
        LabelLibrarySubMgt: Codeunit "Label Library Sub. Mgt.";
}

