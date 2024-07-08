pageextension 6014463 "NPR Transfer Order Subform" extends "Transfer Order Subform"
{
    layout
    {
        modify("Item No.")
        {
            trigger OnAfterValidate()
            var
                Item: Record Item;
                NPRVarietySetup: Record "NPR Variety Setup";
                VRTWrapper: Codeunit "NPR Variety Wrapper";
            begin
                if not NPRVarietySetup.Get() then
                    exit;
                if not NPRVarietySetup."Variety Enabled" then
                    exit;
                if not NPRVarietySetup."Pop up Variety Matrix" then
                    exit;
                if not NPRVarietySetup."Pop up on Transfer Order" then
                    exit;
                if Item.Get(Rec."Item No.") then begin
                    Item.CalcFields("NPR Has Variants");
                    if Item."NPR Has Variants" then begin
                        CurrPage.Update(); //required when the Item No. is first added, since the following line will show an error if quantity is set on the matrix page
                        VRTWrapper.TransferLineShowVariety(Rec, 0);
                    end;
                end;
            end;
        }
        addafter("Item No.")
        {
            field("NPR Cross-Reference No."; Rec."NPR Cross-Reference No.")
            {

                ToolTip = 'Specifies the cross-referenced item number. If you enter a cross reference between yours and your vendor''s or customer''s item number, then this number will override the standard item number when you enter the cross-reference number on a sales or purchase document.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Variant Code")
        {
            field("NPR Vendor Item No."; Rec."NPR Vendor Item No.")
            {

                Visible = false;
                ToolTip = 'Specifies the number that the vendor uses for this item.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter(Description)
        {
            field("NPR Description 2"; Rec."Description 2")
            {

                ToolTip = 'Specifies the extended description of the entry.';
                ApplicationArea = NPRRetail;
            }
        }
    }
    actions
    {
        addafter(Dimensions)
        {
            action("NPR Variety")
            {
                Caption = 'Variety';
                Image = ItemVariant;
                ShortCutKey = 'Ctrl+Alt+V';

                ToolTip = 'View the variety matrix for the item used on transfer order';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    VarietyWrapper: Codeunit "NPR Variety Wrapper";
                begin
                    VarietyWrapper.TransferLineShowVariety(Rec, 0);
                end;
            }
        }
    }
}