pageextension 6014419 "NPR Sales Return Order Subform" extends "Sales Return Order Subform"
{
    layout
    {
        modify("No.")
        {
            trigger OnAfterValidate()
            var
                Item: Record Item;
                NPRVarietySetup: Record "NPR Variety Setup";
                VRTWrapper: Codeunit "NPR Variety Wrapper";
            begin
                if not NPRVarietySetup.Get() then
                    exit;
                if not NPRVarietySetup."Pop up Variety Matrix" then
                    exit;
                if (Rec.Type = Rec.Type::Item) and Item.Get(Rec."No.") then begin
                    Item.CalcFields("NPR Has Variants");
                    if Item."NPR Has Variants" then
                        VRTWrapper.SalesLineShowVariety(Rec, 0);
                end;
            end;
        }
    }
}