pageextension 70000100 pageextension70000100 extends "Location List" 
{
    // NPR5.26/JLK /20160905  CASE 251231 Added field Store Group Code
    layout
    {
        addafter(Name)
        {
            field("Store Group Code";"Store Group Code")
            {
                Enabled = true;
                Visible = false;
            }
        }
    }
}

