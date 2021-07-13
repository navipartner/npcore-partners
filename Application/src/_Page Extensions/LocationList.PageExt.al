pageextension 6014420 "NPR Location List" extends "Location List"
{
    layout
    {
        addafter(Name)
        {
            field("NPR Store Group Code"; Rec."NPR Store Group Code")
            {

                Enabled = true;
                Visible = false;
                ToolTip = 'Specifies the value of the NPR Store Group Code field';
                ApplicationArea = NPRRetail;
            }
        }
    }
}