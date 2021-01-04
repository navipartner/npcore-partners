pageextension 6014438 "NPR Item Journal" extends "Item Journal"
{
    // NPR5.43/TS  /20180625 CASE 317852  Added Function PriceLabel
    // NPR5.51/BHR /20190826 CASE 366143  Action for Variety Matrix
    actions
    {
        addafter("Ledger E&ntries")
        {
            action("NPR Variety")
            {
                Caption = 'Variety';
                Image = ItemVariant;
                ShortCutKey = 'Ctrl+Alt+V';
                ApplicationArea = All;
                ToolTip = 'Executes the Variety action';
            }
        }
        addafter("Page")
        {
            action("NPR PriceLabel")
            {
                Caption = 'Price Label';
                Image = BinContent;
                ApplicationArea = All;
                ToolTip = 'Executes the Price Label action';
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

