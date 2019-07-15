pageextension 50547 pageextension50547 extends "Inventory Put-away" 
{
    // NPR5.48/TS  /20181214  CASE 339845 Added Field Assigned User Id
    layout
    {
        addafter("External Document No.2")
        {
            field("Assigned User ID";"Assigned User ID")
            {
            }
        }
    }
}

