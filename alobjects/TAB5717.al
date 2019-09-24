tableextension 50044 tableextension50044 extends "Item Cross Reference" 
{
    // NPR5.47/CLVA/20181019 CASE 318296 New field Rfid Tag
    // NPR5.48/CLVA/20181019 CASE 318296 New field Time Stamp
    fields
    {
        field(6014440;"Rfid Tag";Boolean)
        {
            Caption = 'Rfid Tag';
            Description = 'NPR5.47';
            Editable = false;
        }
        field(6014441;"Time Stamp";BigInteger)
        {
            Caption = 'Time Stamp';
        }
    }
}

