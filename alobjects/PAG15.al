pageextension 6014420 pageextension6014420 extends "Location List"
{
    // NPR5.26/JLK /20160905  CASE 251231 Added field Store Group Code
    layout
    {
        addafter(Name)
        {
            field("Store Group Code"; "Store Group Code")
            {
                ApplicationArea = All;
                Enabled = true;
                Visible = false;
            }
        }
    }
}

