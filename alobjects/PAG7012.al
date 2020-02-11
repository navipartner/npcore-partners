pageextension 6014470 pageextension6014470 extends "Purchase Prices" 
{
    // VRT1.00/JDH/20150304 CASE 271133 Show Variety Matrix
    // NPR5.31/NPKNAV/20170502  CASE 271133 Transport NPR5.31 - 2 May 2017
    actions
    {
        addafter(CopyPrices)
        {
            group(Variants)
            {
                Caption = 'Variants';
                action(Variety)
                {
                    Caption = 'Variety';
                    Image = ItemVariant;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Ctrl+Alt+V';
                }
            }
        }
    }
}

