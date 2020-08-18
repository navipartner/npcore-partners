pageextension 6014458 pageextension6014458 extends "Item Variants" 
{
    // NPR5.51/YAHA/20190816 NPR5.51 Display field Blocked.
    layout
    {
        addafter("Description 2")
        {
            field(Blocked;Blocked)
            {
            }
        }
    }
}

