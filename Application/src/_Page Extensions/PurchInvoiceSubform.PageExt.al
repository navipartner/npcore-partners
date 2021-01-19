pageextension 6014459 "NPR Purch. Invoice Subform" extends "Purch. Invoice Subform"
{
    layout
    {
        addafter("No.")
        {
            field("NPR Vendor Item No."; "Vendor Item No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Vendor Item No. field';
            }
        }
        addafter("Line No.")
        {
            field("NPR Exchange Label"; "NPR Exchange Label")
            {
                ApplicationArea = All;
                Visible = false;
                ToolTip = 'Specifies the value of the NPR Exchange Label field';
            }
        }
    }
    actions
    {
        addafter("Related Information")
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

