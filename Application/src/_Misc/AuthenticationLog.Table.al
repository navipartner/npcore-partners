table 6151153 "NPR Authentication Log"
{
    // NPR5.48/TSA /20181211 CASE 320425 Initial Version
    // NPR5.49/TSA /20190401 CASE 320425 Added object caption

    Caption = 'Authentication Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Authenticate,Password Reset Request,Password Change,OTP Created';
            OptionMembers = AUTHENTICATE,RESET_PASSWORD_REQUEST,PASSWORD_CHANGE,OTP_CREATE;
        }
        field(11; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }
        field(12; "Account Id"; Text[80])
        {
            Caption = 'Account Id';
            DataClassification = CustomerContent;
        }
        field(13; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = ' ,OK,Unsuccessful';
            OptionMembers = NA,OK,FAIL;
        }
        field(14; "Result Message"; Text[250])
        {
            Caption = 'Result Message';
            DataClassification = CustomerContent;
        }
        field(20; "UserId"; Text[50])
        {
            Caption = 'UserId';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

