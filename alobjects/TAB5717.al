tableextension 6014443 tableextension6014443 extends "Item Cross Reference"
{
    // NPR5.47/CLVA/20181019 CASE 318296 New field Rfid Tag
    // NPR5.48/CLVA/20181019 CASE 318296 New field Time Stamp
    // NPR5.52/TSA /20190925 CASE 369231 Renamed field "Rfid Tag" to "Retail Serial No."
    fields
    {
        field(6014440; "Is Retail Serial No."; Boolean)
        {
            Caption = 'Is Retail Serial No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.47';
        }
        field(6014441; "Time Stamp"; BigInteger)
        {
            Caption = 'Time Stamp';
            DataClassification = CustomerContent;
        }
    }
}

