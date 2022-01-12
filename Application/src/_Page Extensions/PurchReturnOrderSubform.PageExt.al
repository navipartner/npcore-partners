pageextension 6014408 "NPR Purch.Return Order Subform" extends "Purchase Return Order Subform"
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
                ToolTip = 'Executes the Variety action';

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