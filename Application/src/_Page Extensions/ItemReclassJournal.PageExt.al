pageextension 6014437 "NPR Item Reclass. Journal" extends "Item Reclass. Journal"
{
    actions
    {
        addafter("Get Bin Content")
        {
            action("NPR Variety")
            {
                Caption = 'Variety';
                Image = ItemVariant;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+Alt+V';

                ToolTip = 'Enable viewing the variety matrix/varieties for the item number used in the Reclass Journal line.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    VarietyWrapper: Codeunit "NPR Variety Wrapper";
                begin
                    VarietyWrapper.ItemJnlLineShowVariety(Rec, 0);
                end;
            }
        }
    }
}