pageextension 6014458 "NPR Item Variants" extends "Item Variants"
{
    layout
    {
        addafter("Description 2")
        {
            field("NPR Blocked"; Rec."NPR Blocked")
            {
                ToolTip = 'Specifies if the Item Variant is blocked or not';
                ApplicationArea = NPRRetail;
#IF NOT (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
                ObsoleteState = Pending;
                ObsoleteTag = 'NPR31.0';
                ObsoleteReason = 'Replaced with standard Microsoft field "Blocked"';
                Visible = false;
                Enabled = false;
#ENDIF
            }
        }
    }
}