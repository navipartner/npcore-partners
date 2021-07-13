pageextension 6014438 "NPR Item Journal" extends "Item Journal"
{
    actions
    {
        addafter("Ledger E&ntries")
        {
            action("NPR Variety")
            {
                Caption = 'Variety';
                Image = ItemVariant;
                ShortCutKey = 'Ctrl+Alt+V';

                ToolTip = 'Executes the Variety action';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Page")
        {
            action("NPR PriceLabel")
            {
                Caption = 'Price Label';
                Image = BinContent;

                ToolTip = 'Executes the Price Label action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}