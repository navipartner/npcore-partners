pageextension 6014461 pageextension6014461 extends "Item Cross Reference Entries"
{
    // NPR5.47/CLVA/20181019 CASE 318296 New field Rfid Tag
    layout
    {
        addafter("Discontinue Bar Code")
        {
            field("Is Retail Serial No."; "Is Retail Serial No.")
            {
                ApplicationArea = All;
            }
        }
    }
}

