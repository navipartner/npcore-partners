pageextension 6014456 pageextension6014456 extends "Location Card" 
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

