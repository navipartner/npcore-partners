pageextension 6014436 "NPR Phys. Inventory Journal" extends "Phys. Inventory Journal"
{
    // NPR5.48/TS  /20190109  CASE 341904 Added field Vendor No.
    layout
    {
        addafter("Location Code")
        {
            field("NPR Vendor No."; "NPR Vendor No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Vendor No. field';
            }
        }
    }
}

