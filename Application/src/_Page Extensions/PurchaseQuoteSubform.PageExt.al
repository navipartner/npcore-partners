pageextension 6014439 "NPR Purchase Quote Subform" extends "Purchase Quote Subform"
{
    actions
    {
        addafter(DocAttach)
        {
            action("NPR Variety")
            {
                Caption = 'Variety';
                Image = ItemVariant;
                ShortCutKey = 'Ctrl+Alt+V';
                ApplicationArea = NPRRetail;
                ToolTip = 'View the variety matrix for the item used on the line.';

                trigger OnAction()
                var
                    VarietyWrapper: Codeunit "NPR Variety Wrapper";
                begin
                    VarietyWrapper.PurchLineShowVariety(Rec, 0);
#if not (BC17 or BC1800 or BC1801 or BC1802 or BC1803)                   
                    ForceTotalsCalculation();
#ENDIF
                end;
            }
        }
    }
}