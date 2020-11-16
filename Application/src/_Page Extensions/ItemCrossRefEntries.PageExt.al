pageextension 6014461 "NPR Item Cross Ref. Entries" extends "Item Cross Reference Entries"
{
    // NPR5.47/CLVA/20181019 CASE 318296 New field Rfid Tag
    layout
    {
        addafter("Discontinue Bar Code")
        {
            field("NPR Is Retail Serial No."; "NPR Is Retail Serial No.")
            {
                ApplicationArea = All;
            }
        }
    }
}

