pageextension 6014434 pageextension6014434 extends "Item Journal" 
{
    // NPR5.43/TS  /20180625 CASE 317852  Added Function PriceLabel
    // NPR5.51/BHR /20190826 CASE 366143  Action for Variety Matrix
    actions
    {
        addafter("Ledger E&ntries")
        {
            action(Variety)
            {
                Caption = 'Variety';
                Image = ItemVariant;
                ShortCutKey = 'Ctrl+Alt+V';
            }
        }
        addafter("Page")
        {
            action(PriceLabel)
            {
                Caption = 'Price Label';
                Image = BinContent;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;

                trigger OnAction()
                begin
                    //-NPR5.43 [317852]
                    //+NPR5.43 [317852]
                end;
            }
        }
    }
}

