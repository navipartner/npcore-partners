pageextension 6014431 pageextension6014431 extends "Phys. Inventory Journal" 
{
    // NPR5.48/TS  /20190109  CASE 341904 Added field Vendor No.
    layout
    {
        addafter("Location Code")
        {
            field("Vendor No.";"Vendor No.")
            {
            }
        }
    }
}

