pageextension 50239 pageextension50239 extends "Item Journal" 
{
    // NPR5.43/TS  /20180625 CASE 317852  Added Function PriceLabel
    actions
    {
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

