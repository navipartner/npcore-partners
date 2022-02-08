table 6060095 "NPR MM Admis. Scanner Stations"
{
    Access = Internal;

    Caption = 'MM Admission Scanner Stations';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Scanner Station Id"; Code[10])
        {
            Caption = 'Scanner Station Id';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Admis. Service Entry"."Scanner Station Id";

            ValidateTableRelation = false;
        }
        field(10; "Guest Avatar"; BLOB)
        {
            Caption = 'Guest Avatar';
            DataClassification = CustomerContent;
            SubType = Bitmap;
            ObsoleteState = Removed;
            ObsoleteReason = 'This field won''t be used anymore. Replaced by "Guest Avatar Image" field';
            ObsoleteTag = 'Deprecated field type';
        }
        field(11; "Turnstile Default Image"; BLOB)
        {
            Caption = 'Turnstile Default Image';
            DataClassification = CustomerContent;
            SubType = Bitmap;
            ObsoleteState = Removed;
            ObsoleteReason = 'This field won''t be used anymore. Replaced by "Default Turnstile Image" field';
            ObsoleteTag = 'Deprecated field type';
        }
        field(12; "Turnstile Error Image"; BLOB)
        {
            Caption = 'Turnstile Error Image';
            DataClassification = CustomerContent;
            SubType = Bitmap;
            ObsoleteState = Removed;
            ObsoleteReason = 'This field won''t be used anymore. Replaced by "Error Image of Turnstile" field';
            ObsoleteTag = 'Deprecated field type';
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
        field(15; "Guest Avatar Image"; Media)
        {
            Caption = 'Guest Avatar';
            DataClassification = CustomerContent;
        }
        field(16; "Default Turnstile Image"; Media)
        {
            Caption = 'Default Turnstile Image';
            DataClassification = CustomerContent;
        }
        field(17; "Error Image of Turnstile"; Media)
        {
            Caption = 'Turnstile Error Image';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Scanner Station Id")
        {
        }
    }
}

