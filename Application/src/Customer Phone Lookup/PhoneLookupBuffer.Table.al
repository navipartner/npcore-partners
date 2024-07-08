table 6014432 "NPR Phone Lookup Buffer"
{
    Access = Internal;

    Caption = 'TDC Names & Numbers Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ID; Code[10])
        {
            Caption = 'ID';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(2; Title; Text[100])
        {
            Caption = 'Title';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(3; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(4; "Post Code"; Code[100])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
        }
        field(5; City; Text[100])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(6; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(7; "Phone No."; Text[100])
        {
            Caption = 'Phone No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(8; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
            ExtendedDatatype = EMail;
            DataClassification = CustomerContent;
        }
        field(9; "Home Page"; Text[80])
        {
            Caption = 'Home Page';
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
        }
        field(10; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }
        field(11; "VAT Registration No."; Text[20])
        {
            Caption = 'VAT Registration No.';
            DataClassification = CustomerContent;
        }
        field(14; "No. Info Functions"; Code[20])
        {
            Caption = 'Number Info Functions';
            Description = 'NPR5.23';
            DataClassification = CustomerContent;
        }
        field(15; "No. Info TableID"; Integer)
        {
            Caption = 'Number Info TableID';
            Description = 'NPR5.23';
            DataClassification = CustomerContent;
        }
        field(16; "Create Contact"; Boolean)
        {
            Caption = 'Create Contact';
            Description = 'NPR5.23';
            DataClassification = CustomerContent;
        }
        field(17; "Create Customer"; Boolean)
        {
            Caption = 'Create Customer';
            Description = 'NPR5.23';
            DataClassification = CustomerContent;
        }
        field(18; "Create Vendor"; Boolean)
        {
            Caption = 'Create Vendor';
            Description = 'NPR5.23';
            DataClassification = CustomerContent;
        }
        field(30; "Mobile Phone No."; Text[30])
        {
            Caption = 'Customer Template';
            Description = 'NPR5.26';
            DataClassification = CustomerContent;
        }
        field(40; "First Name"; Text[50])
        {
            Caption = 'First Name';
            Description = 'NPR5.40';
            DataClassification = CustomerContent;
        }
        field(41; "Last Name"; Text[50])
        {
            Caption = 'Last Name';
            Description = 'NPR5.40';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; ID)
        {
        }
    }
}

