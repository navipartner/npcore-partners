table 6060090 "NPR MM Admis. Service Setup"
{
    Access = Internal;

    Caption = 'MM Admission Service Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[10])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            Editable = false;
            NotBlank = true;
        }
        field(11; "Validate Members"; Boolean)
        {
            Caption = 'Validate Members';
            DataClassification = CustomerContent;
        }
        field(12; "Validate Tickes"; Boolean)
        {
            Caption = 'Validate Tickes';
            DataClassification = CustomerContent;
        }
        field(13; "Validate Re-Scan"; Boolean)
        {
            Caption = 'Validate Re-Scan';
            DataClassification = CustomerContent;
        }
        field(14; "Allowed Re-Scan Interval"; Duration)
        {
            Caption = 'Allowed Re-Scan Interval';
            DataClassification = CustomerContent;
        }
        field(15; "Guest Avatar"; BLOB)
        {
            Caption = 'Guest Avatar';
            DataClassification = CustomerContent;
            SubType = Bitmap;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'This field won''t be used anymore. Replaced by "Guest Avatar Image" field';
        }
        field(16; "Web Service Is Published"; Boolean)
        {
            CalcFormula = Exist("Web Service Aggregate" WHERE("Object Type" = CONST(Codeunit),
                                                     "Service Name" = CONST('admission_service')));
            Caption = 'Web Service Is Published';
            Editable = false;
            FieldClass = FlowField;

            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Web Service is not in use any more by Cloud and Web Service Aggregate is Temp table. This logic is moved on Page Field.';
        }
        field(17; "Validate Scanner Station"; Boolean)
        {
            Caption = 'Validate Scanner Station';
            DataClassification = CustomerContent;
        }
        field(18; "Turnstile Default Image"; BLOB)
        {
            Caption = 'Turnstile Default Image';
            DataClassification = CustomerContent;
            SubType = Bitmap;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'This field won''t be used anymore. Replaced by "Default Turnstile Image" field';
        }
        field(19; "Turnstile Error Image"; BLOB)
        {
            Caption = 'Turnstile Error Image';
            DataClassification = CustomerContent;
            SubType = Bitmap;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'This field won''t be used anymore. Replaced by "Error Image of Turnstile" field';
        }
        field(20; "Guest Avatar Image"; Media)
        {
            Caption = 'Guest Avatar';
            DataClassification = CustomerContent;
        }
        field(21; "Default Turnstile Image"; Media)
        {
            Caption = 'Default Turnstile Image';
            DataClassification = CustomerContent;
        }
        field(22; "Error Image of Turnstile"; Media)
        {
            Caption = 'Turnstile Error Image';
            DataClassification = CustomerContent;
        }
        field(30; "Show Sensitive Info"; Boolean)
        {
            Caption = 'Show Sensitive Info';
            DataClassification = CustomerContent;
        }
        field(35; "Use Foreign Membership"; Boolean)
        {
            Caption = 'Use Foreign Membership';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }
}

