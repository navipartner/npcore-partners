pageextension 6014447 "NPR Sales Order Subform" extends "Sales Order Subform"
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
        addafter(Description)
        {
            field("NPR Description 2"; Rec."Description 2")
            {

                Visible = false;
                ToolTip = 'Specifies an extended description of the product entry to be sold. To add a non-transactional text line, fill in the Description field only.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Unit Cost (LCY)")
        {
            field("NPR Units per Parcel"; Rec."Units per Parcel")
            {

                Visible = false;
                ToolTip = 'Specifies how many units are packed in one parcel.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Inv. Discount Amount")
        {
            field("NPR Net Weight"; Rec."Net Weight")
            {

                Importance = Additional;
                ToolTip = 'Specifies the Net Weight of the item to be sold.';
                ApplicationArea = NPRRetail;
            }
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
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+Alt+V';

                ToolTip = 'View the variety matrix for the item used on the Purchase Order Line.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    VarietyWrapper: Codeunit "NPR Variety Wrapper";
                begin
                    VarietyWrapper.SalesLineShowVariety(Rec, 0);
                end;
            }
        }
    }
}