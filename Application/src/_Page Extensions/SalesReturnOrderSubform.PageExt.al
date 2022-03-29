pageextension 6014419 "NPR Sales Return Order Subform" extends "Sales Return Order Subform"
{
    layout
    {
        modify("No.")
        {
            trigger OnAfterValidate()
            var
                ItemVariant: Record "Item Variant";
                NPRVarietySetup: Record "NPR Variety Setup";
                VRTWrapper: Codeunit "NPR Variety Wrapper";
            begin
                if not NPRVarietySetup.Get() then
                    exit;
                if not NPRVarietySetup."Pop up Variety Matrix" then
                    exit;
                if Rec.Type = Rec.Type::Item then begin
                    ItemVariant.SetRange("Item No.", Rec."No.");
                    if not ItemVariant.IsEmpty() then begin
                        CurrPage.SaveRecord();
                        VRTWrapper.SalesLineShowVariety(Rec, 0);
                        ForceTotalsCalculation();
                    end;
                end;
            end;
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