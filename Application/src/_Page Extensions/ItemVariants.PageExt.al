pageextension 6014458 "NPR Item Variants" extends "Item Variants"
{
    // NPR5.51/YAHA/20190816 NPR5.51 Display field Blocked.
    layout
    {
        addafter("Description 2")
        {
            field("NPR Blocked"; "NPR Blocked")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Blocked field';
            }
        }
    }
}

