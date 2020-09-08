table 6014599 "NPR Connection Profile"
{
    Caption = 'Connection Profile';
    ObsoleteState = Removed;
    ObsoleteReason = 'Table has not been used since NAV2015';

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(10;"Hosting type";Option)
        {
            Caption = 'Hosting Type';
            Description = 'Opsætter printervalg afhængig af hostingtype.';
            OptionCaption = 'Client,Citrix,Terminal Server,Terminal Server 2008,Web Client';
            OptionMembers = Client,Citrix,"Terminal Server","Terminal Server 2008",WebClient;
        }
        field(20;"Credit Card Extension";Text[50])
        {
            Caption = 'Credit Card Extension';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }
}

