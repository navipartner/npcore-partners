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
#if not (BC1700 or BC1701 or BC1702 or BC1703 or BC1704 or BC1800 or BC1801 or BC1802 or BC1803 or BC1804)
                    ForceTotalsCalculation();
#ENDIF                    
                end;
            }
        }
    }
}