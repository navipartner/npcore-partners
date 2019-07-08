pageextension 70000359 pageextension70000359 extends "Location Card" 
{
    // NPR5.26/JLK /20160905  CASE 251231 Added field Store Group Code
    layout
    {
        addafter("Use As In-Transit")
        {
            field("Store Group Code";"Store Group Code")
            {
            }
        }
    }
}

