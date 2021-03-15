pageextension 6014459 "NPR Purch. Invoice Subform" extends "Purch. Invoice Subform"
{
    layout
    {
        addafter("No.")
        {
            field("NPR Vendor Item No."; Rec."Vendor Item No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Vendor Item No. field';
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

