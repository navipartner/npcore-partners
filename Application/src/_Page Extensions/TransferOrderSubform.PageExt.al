pageextension 6014463 "NPR Transfer Order Subform" extends "Transfer Order Subform"
{
    layout
    {
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