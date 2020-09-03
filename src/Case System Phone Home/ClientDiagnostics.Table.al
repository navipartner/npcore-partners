table 6059999 "NPR Client Diagnostics"
{
    // NPR5.38/CLVA/20171109  CASE 293179 Collecting client-side information
    // NPR5.40/MHA /20180328  CASE 308907 Added Login Info fields, -License Info fields, -Computer Info fields, POS Info fields, Logout Info fields

    Caption = 'Client Diagnostics';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Client Diagnostics";
    LookupPageID = "NPR Client Diagnostics";

    fields
    {
        field(1; Username; Text[50])
        {
            Caption = 'Username';
            DataClassification = CustomerContent;
        }
        field(2; "Database Name"; Text[50])
        {
            Caption = 'Database Name';
            DataClassification = CustomerContent;
        }
        field(3; "Tenant ID"; Text[50])
        {
            Caption = 'Tenant ID';
            DataClassification = CustomerContent;
        }
        field(100; "Login Info"; Boolean)
        {
            Caption = 'Login Info';
            DataClassification = CustomerContent;
            Description = '#Login Info';
        }
        field(105; "Last Logon Date"; Date)
        {
            Caption = 'Last Logon Date';
            DataClassification = CustomerContent;
            Description = '#Login Info';
        }
        field(110; "Last Logon Time"; Time)
        {
            Caption = 'Last Logon Time';
            DataClassification = CustomerContent;
            Description = '#Login Info';
        }
        field(115; "Full Name"; Text[80])
        {
            Caption = 'Full Name';
            DataClassification = CustomerContent;
            Description = '#Login Info';
        }
        field(120; "Service Server Name"; Text[50])
        {
            Caption = 'Service Server Name';
            DataClassification = CustomerContent;
            Description = '#Login Info';
        }
        field(125; "Service Instance"; Text[50])
        {
            Caption = 'Service Instance';
            DataClassification = CustomerContent;
            Description = '#Login Info';
        }
        field(130; "Company Name"; Text[50])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
            Description = '#Login Info';
        }
        field(135; "Company ID"; Code[20])
        {
            Caption = 'Company ID';
            DataClassification = CustomerContent;
            Description = '#Login Info';
            TableRelation = Customer;
        }
        field(145; "User Security ID"; Text[100])
        {
            Caption = 'User Security ID';
            DataClassification = CustomerContent;
            Description = '#Login Info';
        }
        field(150; "Windows Security ID"; Text[100])
        {
            Caption = 'Windows Security ID';
            DataClassification = CustomerContent;
            Description = '#Login Info';
        }
        field(155; "User Login Type"; Option)
        {
            Caption = 'User Login Type';
            DataClassification = CustomerContent;
            Description = '#Login Info';
            OptionCaption = 'Windows,NAV';
            OptionMembers = Windows,NAV;
        }
        field(160; "Application Version"; Text[50])
        {
            Caption = 'Application Version';
            DataClassification = CustomerContent;
            Description = '#Login Info';
        }
        field(200; "License Info"; Boolean)
        {
            Caption = 'License Info';
            DataClassification = CustomerContent;
            Description = '#License Info';
        }
        field(205; "License Type"; Option)
        {
            Caption = 'License Type';
            DataClassification = CustomerContent;
            Description = '#License Info';
            OptionCaption = ' ,Full User,Limited User,Device Only User,Windows Group,External User';
            OptionMembers = " ","Full User","Limited User","Device Only User","Windows Group","External User";
        }
        field(210; "License Name"; Text[100])
        {
            Caption = 'License Name';
            DataClassification = CustomerContent;
            Description = '#License Info';
        }
        field(215; "No. of Full Users"; Integer)
        {
            Caption = 'No. of Full Users';
            DataClassification = CustomerContent;
            Description = '#License Info';
        }
        field(220; "No. of ISV Users"; Integer)
        {
            Caption = 'No. of ISV Users';
            DataClassification = CustomerContent;
            Description = '#License Info';
        }
        field(225; "No. of Limited Users"; Integer)
        {
            Caption = 'No. of Limited Users';
            DataClassification = CustomerContent;
            Description = '#License Info';
        }
        field(300; "Computer Info"; Boolean)
        {
            Caption = 'Computer Info';
            DataClassification = CustomerContent;
            Description = '#Computer Info';
        }
        field(305; "Client Name"; Text[50])
        {
            Caption = 'Client Name';
            DataClassification = CustomerContent;
            Description = '#Computer Info';
        }
        field(310; "Serial Number"; Code[10])
        {
            Caption = 'Serial Number';
            DataClassification = CustomerContent;
            Description = '#Computer Info';
        }
        field(315; "OS Version"; Text[50])
        {
            Caption = 'OS Version';
            DataClassification = CustomerContent;
            Description = '#Computer Info';
        }
        field(320; "Mac Adresses"; Text[200])
        {
            Caption = 'Mac Adresses';
            DataClassification = CustomerContent;
            Description = '#Computer Info';
        }
        field(325; "Platform Version"; Text[50])
        {
            Caption = 'Platform Version';
            DataClassification = CustomerContent;
            Description = '#Computer Info';
        }
        field(400; "POS Info"; Boolean)
        {
            Caption = 'POS Info';
            DataClassification = CustomerContent;
            Description = '#POS Info';
        }
        field(405; "POS Client Type"; Option)
        {
            Caption = 'POS Client Type';
            DataClassification = CustomerContent;
            Description = '#POS Info';
            OptionCaption = 'Unknown,Standard,Transcendence';
            OptionMembers = Unknown,Standard,Transcendence;
        }
        field(410; "IP Address"; Code[50])
        {
            Caption = 'IP Address';
            DataClassification = CustomerContent;
            Description = '#POS Info';
        }
        field(415; "Geolocation Latitude"; Decimal)
        {
            Caption = 'Geolocation Latitude';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 7;
            Description = '#POS Info';
        }
        field(420; "Geolocation Longitude"; Decimal)
        {
            Caption = 'Geolocation Longitude';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 7;
            Description = '#POS Info';
        }
        field(500; "Logout Info"; Boolean)
        {
            Caption = 'Logout Info';
            DataClassification = CustomerContent;
            Description = '#Logout Info';
        }
        field(505; "Last Logout Date"; Date)
        {
            Caption = 'Last Logout Date';
            DataClassification = CustomerContent;
            Description = '#Logout Info';
        }
        field(510; "Last Logout Time"; Time)
        {
            Caption = 'Last Logout Time';
            DataClassification = CustomerContent;
            Description = '#Logout Info';
        }
    }

    keys
    {
        key(Key1; Username, "Database Name", "Tenant ID")
        {
        }
    }

    fieldgroups
    {
    }
}

