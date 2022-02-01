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

                ToolTip = 'Executes the Variety action and opens Edit - Variety Matrix page';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    VarietyWrapper: Codeunit "NPR Variety Wrapper";
                begin
                    VarietyWrapper.ItemJnlLineShowVariety(Rec, 0);
                end;
            }
        }
        addafter("Page")
        {
            action("NPR PriceLabel")
            {
                Caption = 'Price Label';
                Image = BinContent;

                ToolTip = 'Print the Price Label document.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ReportSelectionRetail: Record "NPR Report Selection Retail";
                    LabelLibrary: Codeunit "NPR Label Library";
                begin
                    LabelLibrary.PrintLabel(Rec, ReportSelectionRetail."Report Type"::"Price Label");
                end;
            }
        }
    }
}