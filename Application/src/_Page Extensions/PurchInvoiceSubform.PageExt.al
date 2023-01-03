pageextension 6014434 "NPR Purch. Invoice Subform" extends "Purch. Invoice Subform"
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
#IF NOT (BC1700 or BC1704)                    
                    ForceTotalsCalculation();
#ENDIF                    
                end;
            }
        }
    }
}