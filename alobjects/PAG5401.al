pageextension 6014452 pageextension6014452 extends "Item Variants" 
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

