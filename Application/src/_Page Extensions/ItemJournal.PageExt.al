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
            }
        }
    }
}