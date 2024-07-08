table 6060092 "NPR MM Admis. Service Log"
{
    Access = Internal;

    Caption = 'MM Admission Service Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(10; "Action"; Option)
        {
            Caption = 'Action';
            DataClassification = CustomerContent;
            OptionCaption = 'Guest Validation,Guest Arrival';
            OptionMembers = "Guest Validation","Guest Arrival";
        }
        field(11; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }
        field(12; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            DataClassification = CustomerContent;
        }
        field(13; Token; Code[50])
        {
            Caption = 'Token';
            DataClassification = CustomerContent;
        }
        field(14; "Key"; Code[20])
        {
            Caption = 'Key';
            DataClassification = CustomerContent;
        }
        field(15; "Scanner Station Id"; Code[10])
        {
            Caption = 'Scanner Station Id';
            DataClassification = CustomerContent;
        }
        field(100; "Request Barcode"; Text[50])
        {
            Caption = 'Request Barcode';
            DataClassification = CustomerContent;
            Description = 'Guest Validation';
        }
        field(101; "Request Scanner Station Id"; Code[10])
        {
            Caption = 'Request Scanner Station Id';
            DataClassification = CustomerContent;
            Description = 'Guest Validation';
        }
        field(102; "Request No"; Code[20])
        {
            Caption = 'Request No';
            DataClassification = CustomerContent;
            Description = 'Guest Arrival';
        }
        field(103; "Request Token"; Code[50])
        {
            Caption = 'Request Token';
            DataClassification = CustomerContent;
            Description = 'Guest Arrival';
        }
        field(110; "Response No"; Code[20])
        {
            Caption = 'Response No';
            DataClassification = CustomerContent;
            Description = 'Guest Validation';
        }
        field(111; "Response Token"; Code[50])
        {
            Caption = 'Response Token';
            DataClassification = CustomerContent;
            Description = 'Guest Validation';
        }
        field(112; "Response Name"; Text[250])
        {
            Caption = 'Response Name';
            DataClassification = CustomerContent;
            Description = 'Guest Arrival';
        }
        field(113; "Response PictureBase64"; Boolean)
        {
            Caption = 'Response PictureBase64';
            DataClassification = CustomerContent;
            Description = 'Guest Arrival';
        }
        field(300; "Error Number"; Code[10])
        {
            Caption = 'Error Number';
            DataClassification = CustomerContent;
        }
        field(301; "Error Description"; Text[250])
        {
            Caption = 'Error Description';
            DataClassification = CustomerContent;
        }
        field(302; "Return Value"; Boolean)
        {
            Caption = 'Return Value';
            DataClassification = CustomerContent;
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

