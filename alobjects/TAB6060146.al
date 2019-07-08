table 6060146 "MM NPR Remote Endpoint Setup"
{
    // MM1.23/TSA /20171025 CASE 257011 Initial Version
    // #334163/JDH /20181109 CASE 334163 Added caption to object
    // MM1.36/NPKNAV/20190125  CASE 343948 Transport MM1.36 - 25 January 2019
    // MM1.37/TSA /20190228 CASE 343053 Added Loylaty Services

    Caption = 'MM NPR Remote Endpoint Setup';

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(2;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Member Services,Loyalty Services';
            OptionMembers = MemberServices,LoyaltyServices;
        }
        field(5;"Community Code";Code[20])
        {
            Caption = 'Community Code';
            TableRelation = "MM Member Community";
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(20;"Credentials Type";Option)
        {
            Caption = 'Credentials Type';
            OptionCaption = 'SYSTEM,NAMED';
            OptionMembers = SYSTEM,NAMED;
        }
        field(21;"User Domain";Text[30])
        {
            Caption = 'User Domain';
        }
        field(22;"User Account";Text[50])
        {
            Caption = 'User Account';
        }
        field(23;"User Password";Text[30])
        {
            Caption = 'User Password';
        }
        field(30;"Endpoint URI";Text[200])
        {
            Caption = 'Endpoint URI';
        }
        field(40;Disabled;Boolean)
        {
            Caption = 'Disabled';
        }
        field(50;"Connection Timeout (ms)";Integer)
        {
            Caption = 'Connection Timeout (ms)';
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

