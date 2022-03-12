pageextension 6014408 "NPR Purch.Return Order Subform" extends "Purchase Return Order Subform"
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
                    if not ItemVariant.IsEmpty() then
                        VRTWrapper.PurchLineShowVariety(Rec, 0);
                end;
            end;
        }
    }
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
                ToolTip = 'View the variety matrix for the item used on the Purchase Order Line.';

                trigger OnAction()
                var
                    VarietyWrapper: Codeunit "NPR Variety Wrapper";
                begin
                    VarietyWrapper.PurchLineShowVariety(Rec, 0);
                end;
            }
        }
    }
}