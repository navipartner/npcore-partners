table 6060092 "MM Admission Service Log"
{
    // NPR5.31/NPKNAV/20170502  CASE 263737 Transport NPR5.31 - 2 May 2017
    // NPR5.38/MHA /20180104  CASE 301054 Removed TableRelation to Table51011 from field 11 "Entry No."

    Caption = 'MM Admission Service Log';

    fields
    {
        field(1;"No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'No.';
        }
        field(10;"Action";Option)
        {
            Caption = 'Action';
            OptionCaption = 'Guest Validation,Guest Arrival';
            OptionMembers = "Guest Validation","Guest Arrival";
        }
        field(11;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
            Description = 'NPR5.38';
        }
        field(12;"Created Date";DateTime)
        {
            Caption = 'Created Date';
        }
        field(13;Token;Code[50])
        {
            Caption = 'Token';
        }
        field(14;"Key";Code[20])
        {
            Caption = 'Key';
        }
        field(15;"Scanner Station Id";Code[10])
        {
            Caption = 'Scanner Station Id';
        }
        field(100;"Request Barcode";Text[50])
        {
            Caption = 'Request Barcode';
            Description = 'Guest Validation';
        }
        field(101;"Request Scanner Station Id";Code[10])
        {
            Caption = 'Request Scanner Station Id';
            Description = 'Guest Validation';
        }
        field(102;"Request No";Code[20])
        {
            Caption = 'Request No';
            Description = 'Guest Arrival';
        }
        field(103;"Request Token";Code[50])
        {
            Caption = 'Request Token';
            Description = 'Guest Arrival';
        }
        field(110;"Response No";Code[20])
        {
            Caption = 'Response No';
            Description = 'Guest Validation';
        }
        field(111;"Response Token";Code[50])
        {
            Caption = 'Response Token';
            Description = 'Guest Validation';
        }
        field(112;"Response Name";Text[250])
        {
            Caption = 'Response Name';
            Description = 'Guest Arrival';
        }
        field(113;"Response PictureBase64";Boolean)
        {
            Caption = 'Response PictureBase64';
            Description = 'Guest Arrival';
        }
        field(300;"Error Number";Code[10])
        {
            Caption = 'Error Number';
        }
        field(301;"Error Description";Text[250])
        {
            Caption = 'Error Description';
        }
        field(302;"Return Value";Boolean)
        {
            Caption = 'Return Value';
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
    }

    fieldgroups
    {
    }
}

