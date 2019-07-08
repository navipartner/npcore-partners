table 6151152 "M2 Account Com. Template"
{
    // NPR5.48/TSA /20181211 CASE 320425 Initial Version

    Caption = 'Account Com. Template';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(5;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,Welcome,Password Reset';
            OptionMembers = NA,WELCOME,PW_RESET;
        }
        field(10;"Company Name";Text[50])
        {
            Caption = 'Company Name';
        }
        field(11;"First Name";Text[50])
        {
            Caption = 'First Name';
        }
        field(12;"Last Name";Text[50])
        {
            Caption = 'Last Name';
        }
        field(15;"E-Mail";Text[80])
        {
            Caption = 'E-Mail';
        }
        field(80;"Security Token";Text[40])
        {
            Caption = 'Security Token';
        }
        field(81;"B64 Email";Text[120])
        {
            Caption = 'B64 Email';
        }
        field(90;URL1;Text[250])
        {
            Caption = 'URL1';
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

