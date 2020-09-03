pageextension 6014420 "NPR Location List" extends "Location List"
{
    // NPR5.26/JLK /20160905  CASE 251231 Added field Store Group Code
    layout
    {
        addafter(Name)
        {
            field("NPR Store Group Code"; "NPR Store Group Code")
            {
                ApplicationArea = All;
                Enabled = true;
                Visible = false;
            }
        }
    }
}

