pageextension 6014463 "NPR Transfer Order Subform" extends "Transfer Order Subform"
{
    layout
    {
        addafter("Item No.")
        {
            field("NPR Cross-Reference No."; Rec."NPR Cross-Reference No.")
            {

                ToolTip = 'Specifies the value of the NPR Cross-Reference No. field';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Variant Code")
        {
            field("NPR Vendor Item No."; Rec."NPR Vendor Item No.")
            {

                Visible = false;
                ToolTip = 'Specifies the value of the NPR Vendor Item No. field';
                ApplicationArea = NPRRetail;
            }
        }
        addafter(Description)
        {
            field("NPR Description 2"; Rec."Description 2")
            {

                ToolTip = 'Specifies the value of the Description 2 field';
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

                ToolTip = 'Executes the Variety action';
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