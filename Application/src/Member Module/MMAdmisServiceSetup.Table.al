table 6060090 "NPR MM Admis. Service Setup"
{

    Caption = 'MM Admission Service Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[10])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            Editable = false;
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
        }
        field(16; "Web Service Is Published"; Boolean)
        {
            CalcFormula = Exist ("Web Service" WHERE("Object Type" = CONST(Codeunit),
                                                     "Service Name" = CONST('admission_service')));
            Caption = 'Web Service Is Published';
            Editable = false;
            FieldClass = FlowField;
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
        }
        field(19; "Turnstile Error Image"; BLOB)
        {
            Caption = 'Turnstile Error Image';
            DataClassification = CustomerContent;
            SubType = Bitmap;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
    }
}

