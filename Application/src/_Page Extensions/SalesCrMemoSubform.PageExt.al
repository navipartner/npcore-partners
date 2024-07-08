pageextension 6014491 "NPR Sales Cr. Memo Subform" extends "Sales Cr. Memo Subform"
{
    actions
    {
        addafter(DeferralSchedule)
        {
            action("NPR Variety")
            {
                Caption = 'Variety';
                Image = ItemVariant;
                ShortCutKey = 'Ctrl+Alt+V';

                ToolTip = 'View the variety matrix for the item used on the Sales Credit Memo Line.';
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