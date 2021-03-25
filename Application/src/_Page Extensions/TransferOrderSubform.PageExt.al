pageextension 6014463 "NPR Transfer Order Subform" extends "Transfer Order Subform"
{
    layout
    {
        addafter("Item No.")
        {
            field("NPR Cross-Reference No."; Rec."NPR Cross-Reference No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Cross-Reference No. field';
            }
        }
        addafter("Variant Code")
        {
            field("NPR Vendor Item No."; Rec."NPR Vendor Item No.")
            {
                ApplicationArea = All;
                Visible = false;
                ToolTip = 'Specifies the value of the NPR Vendor Item No. field';
            }
        }
        addafter(Description)
        {
            field("NPR Description 2"; Rec."Description 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Description 2 field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Variety action';
            }
        }
    }
}