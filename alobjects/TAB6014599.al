table 6014599 "Connection Profile"
{
    // 220508/TSA/2015-11-27 CASE 220508 Proxy Print - Added "Hosting Type" Web Client
    // NPR5.00/NPKNAV/20160113  CASE 220508 NP Retail 2016

    Caption = 'Connection Profile';
    LookupPageID = "Connection Profiles";

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

