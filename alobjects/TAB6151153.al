table 6151153 "Authentication Log"
{
    // NPR5.48/TSA /20181211 CASE 320425 Initial Version
    // NPR5.49/TSA /20190401 CASE 320425 Added object caption

    Caption = 'Authentication Log';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(10;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Authenticate,Password Reset Request,Password Change,OTP Created';
            OptionMembers = AUTHENTICATE,RESET_PASSWORD_REQUEST,PASSWORD_CHANGE,OTP_CREATE;
        }
        field(11;"Created At";DateTime)
        {
            Caption = 'Created At';
        }
        field(12;"Account Id";Text[80])
        {
            Caption = 'Account Id';
        }
        field(13;Status;Option)
        {
            Caption = 'Status';
            OptionCaption = ' ,OK,Unsuccessful';
            OptionMembers = NA,OK,FAIL;
        }
        field(14;"Result Message";Text[250])
        {
            Caption = 'Result Message';
        }
        field(20;UserId;Text[50])
        {
            Caption = 'UserId';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

