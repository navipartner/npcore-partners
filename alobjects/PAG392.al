pageextension 6014436 pageextension6014436 extends "Phys. Inventory Journal"
{
    // NPR5.48/TS  /20190109  CASE 341904 Added field Vendor No.
    layout
    {
        addafter("Location Code")
        {
            field("Vendor No."; "Vendor No.")
            {
                ApplicationArea = All;
            }
        }
    }
}

