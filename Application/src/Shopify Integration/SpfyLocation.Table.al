#if not BC17
table 6150809 "NPR Spfy Location"
{
    Access = Internal;
    Caption = 'Shopify Location';
    DataClassification = CustomerContent;
    LookupPageId = "NPR Spfy Locations";
    DrillDownPageId = "NPR Spfy Locations";

    fields
    {
        field(1; ID; Text[30])
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(4; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(5; City; Text[30])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(6; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
        }
        field(7; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            DataClassification = CustomerContent;
        }
        field(20; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
}
#endif