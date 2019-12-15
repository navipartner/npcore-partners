table 6150907 "POS HC Endpoint Setup"
{
    // NPR5.38/TSA /20171205 CASE 297946 Initial Version
    // NPR5.38/NPKNAV/20180126  CASE 297859 Transport NPR5.38 - 26 January 2018
    // NPR5.45/MHA /20180816  CASE 324963 Increased length of field 21,22,23
    // NPR5.48/TS  /20180811  CASE 334198 Removed Page 89203 as DrillDown and Lookup

    Caption = 'Endpoint Setup';

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(5;Active;Boolean)
        {
            Caption = 'Active';
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(20;"Credentials Type";Option)
        {
            Caption = 'Credentials Type';
            OptionCaption = 'System,Named';
            OptionMembers = SYSTEM,NAMED;
        }
        field(21;"User Domain";Text[100])
        {
            Caption = 'User Domain';
            Description = 'NPR5.45';
        }
        field(22;"User Account";Text[100])
        {
            Caption = 'User Account';
            Description = 'NPR5.45';
        }
        field(23;"User Password";Text[100])
        {
            Caption = 'User Password';
            Description = 'NPR5.45';
        }
        field(30;"Endpoint URI";Text[200])
        {
            Caption = 'Endpoint URI';
        }
        field(50;"Connection Timeout (ms)";Integer)
        {
            Caption = 'Connection Timeout (ms)';
            InitValue = 4000;
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

