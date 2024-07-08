pageextension 6014449 "NPR Sales Invoice Subform" extends "Sales Invoice Subform"
{
    actions
    {
        addafter("Related Information")
        {
            action("NPR Variety")
            {
                Caption = 'Variety';
                Image = ItemVariant;
                ShortCutKey = 'Ctrl+Alt+V';

                ToolTip = 'View the variety matrix for the item used on the Sales Invoice Line.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    VarietyWrapper: Codeunit "NPR Variety Wrapper";
                begin
                    VarietyWrapper.SalesLineShowVariety(Rec, 0);
                    ForceTotalsCalculation();
                end;
            }
        }
    }
#if BC17 or BC18
    trigger OnAfterGetCurrRecord()
    begin
        if TotalsCalculationForced then begin
            UnbindSubscription(VarietyTotals);
            TotalsCalculationForced := false;
        end;
    end;

    local procedure ForceTotalsCalculation()
    begin
        TotalsCalculationForced := BindSubscription(VarietyTotals);
    end;

    var
        VarietyTotals: Codeunit "NPR Variety Totals Calculation";
        TotalsCalculationForced: Boolean;
#endif


}