table 6060146 "NPR MM NPR Remote Endp. Setup"
{
    // MM1.23/TSA /20171025 CASE 257011 Initial Version
    // #334163/JDH /20181109 CASE 334163 Added caption to object
    // MM1.36/NPKNAV/20190125  CASE 343948 Transport MM1.36 - 25 January 2019
    // MM1.37/TSA /20190228 CASE 343053 Added Loylaty Services
    // MM1.40/TSA /20190604 CASE 357360 Added the option "Basic Authentication" to credentials type

    Caption = 'MM NPR Remote Endpoint Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Member Services,Loyalty Services';
            OptionMembers = MemberServices,LoyaltyServices;
        }
        field(5; "Community Code"; Code[20])
        {
            Caption = 'Community Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Member Community";
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Credentials Type"; Option)
        {
            Caption = 'Credentials Type';
            DataClassification = CustomerContent;
            OptionCaption = 'System,Named,Basic Authentication';
            OptionMembers = SYSTEM,NAMED,BASIC;
        }
        field(21; "User Domain"; Text[30])
        {
            Caption = 'User Domain';
            DataClassification = CustomerContent;
        }
        field(22; "User Account"; Text[50])
        {
            Caption = 'User Account';
            DataClassification = CustomerContent;
        }
        field(23; "User Password"; Text[30])
        {
            Caption = 'User Password';
            DataClassification = CustomerContent;
        }
        field(30; "Endpoint URI"; Text[200])
        {
            Caption = 'Endpoint URI';
            DataClassification = CustomerContent;
        }
        field(40; Disabled; Boolean)
        {
            Caption = 'Disabled';
            DataClassification = CustomerContent;
        }
        field(50; "Connection Timeout (ms)"; Integer)
        {
            Caption = 'Connection Timeout (ms)';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

