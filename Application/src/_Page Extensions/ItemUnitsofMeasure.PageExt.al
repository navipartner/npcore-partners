pageextension 6014471 "NPR Item Units of Measure" extends "Item Units of Measure"
{
    layout
    {
        addlast(Control1)
        {
            field("NPR Block on POS Sale"; Rec."NPR Block on POS Sale")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Block on POS Sale field.';
            }
        }
    }


}