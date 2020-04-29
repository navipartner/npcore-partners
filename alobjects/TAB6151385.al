table 6151385 "CS Rfid Tag Models"
{
    // NPR5.47/CLVA/20181015 CASE 318296 Object created

    Caption = 'CS Rfid Tag Models';

    fields
    {
        field(1;Family;Code[10])
        {
            Caption = 'Family';
        }
        field(2;Model;Code[10])
        {
            Caption = 'Model';
        }
        field(10;Discontinued;Boolean)
        {
            Caption = 'Discontinue';
        }
        field(11;"Tag Chip";Code[10])
        {
            Caption = 'Tag Chip';
        }
    }

    keys
    {
        key(Key1;Family,Model)
        {
        }
    }

    fieldgroups
    {
    }
}

