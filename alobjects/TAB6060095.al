table 6060095 "MM Admission Scanner Stations"
{
    // NPR5.43/NPKNAV/20180629  CASE 318579 Transport NPR5.43 - 29 June 2018

    Caption = 'MM Admission Scanner Stations';

    fields
    {
        field(1;"Scanner Station Id";Code[10])
        {
            Caption = 'Scanner Station Id';
            TableRelation = "MM Admission Service Entry"."Scanner Station Id";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(10;"Guest Avatar";BLOB)
        {
            Caption = 'Guest Avatar';
            SubType = Bitmap;
        }
        field(11;"Turnstile Default Image";BLOB)
        {
            Caption = 'Turnstile Default Image';
            SubType = Bitmap;
        }
        field(12;"Turnstile Error Image";BLOB)
        {
            Caption = 'Turnstile Error Image';
            SubType = Bitmap;
        }
        field(13;Activated;Boolean)
        {
            Caption = 'Activated';
        }
    }

    keys
    {
        key(Key1;"Scanner Station Id")
        {
        }
    }

    fieldgroups
    {
    }
}

