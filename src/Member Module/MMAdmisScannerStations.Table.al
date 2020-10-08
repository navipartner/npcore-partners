table 6060095 "NPR MM Admis. Scanner Stations"
{

    Caption = 'MM Admission Scanner Stations';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Scanner Station Id"; Code[10])
        {
            Caption = 'Scanner Station Id';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Admis. Service Entry"."Scanner Station Id";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(10; "Guest Avatar"; BLOB)
        {
            Caption = 'Guest Avatar';
            DataClassification = CustomerContent;
            SubType = Bitmap;
        }
        field(11; "Turnstile Default Image"; BLOB)
        {
            Caption = 'Turnstile Default Image';
            DataClassification = CustomerContent;
            SubType = Bitmap;
        }
        field(12; "Turnstile Error Image"; BLOB)
        {
            Caption = 'Turnstile Error Image';
            DataClassification = CustomerContent;
            SubType = Bitmap;
        }
        field(13; Activated; Boolean)
        {
            Caption = 'Activated';
            DataClassification = CustomerContent;
        }
        field(14; "Admission Code"; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Admission";
        }
    }

    keys
    {
        key(Key1; "Scanner Station Id")
        {
        }
    }

    fieldgroups
    {
    }
}

