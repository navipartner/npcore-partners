table 6014432 "NPR Phone Lookup Buffer"
{
    // NPR5.23/BHR/20160309 CASE 222711 Added fields 14..18
    // NPR5.26/MHA /20160921  CASE 252881 Added field 30 Mobile Phone No. and deleted unused field 18 P and functions
    // NPR5.27/TJ/20160926 CASE 248292 Removing unused variables and fields, renaming fields and variables to use standard naming procedures
    // NPR5.40/LS  /20180226  CASE 305526 Adding Fields 40..41
    // NPR5.40/JDH /20180330 CASE 309516 Removed unused functions

    Caption = 'TDC Names & Numbers Buffer';

    fields
    {
        field(1; ID; Code[10])
        {
            Caption = 'ID';
            Editable = false;
        }
        field(2; Title; Text[100])
        {
            Caption = 'Title';
            Editable = false;
        }
        field(3; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(4; "Post Code"; Code[100])
        {
            Caption = 'Post Code';
        }
        field(5; City; Text[100])
        {
            Caption = 'City';
        }
        field(6; Address; Text[100])
        {
            Caption = 'Address';
        }
        field(7; "Phone No."; Text[100])
        {
            Caption = 'Phone No.';
            Editable = false;
        }
        field(8; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
            ExtendedDatatype = EMail;
        }
        field(9; "Home Page"; Text[80])
        {
            Caption = 'Home Page';
            ExtendedDatatype = URL;
        }
        field(10; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(11; "VAT Registration No."; Text[20])
        {
            Caption = 'VAT Registration No.';
        }
        field(14; "No. Info Functions"; Code[20])
        {
            Caption = 'Number Info Functions';
            Description = 'NPR5.23';
        }
        field(15; "No. Info TableID"; Integer)
        {
            Caption = 'Number Info TableID';
            Description = 'NPR5.23';
        }
        field(16; "Create Contact"; Boolean)
        {
            Caption = 'Create Contact';
            Description = 'NPR5.23';
        }
        field(17; "Create Customer"; Boolean)
        {
            Caption = 'Create Customer';
            Description = 'NPR5.23';
        }
        field(18; "Create Vendor"; Boolean)
        {
            Caption = 'Create Vendor';
            Description = 'NPR5.23';
        }
        field(30; "Mobile Phone No."; Text[30])
        {
            Caption = 'Customer Template';
            Description = 'NPR5.26';
        }
        field(40; "First Name"; Text[50])
        {
            Caption = 'First Name';
            Description = 'NPR5.40';
        }
        field(41; "Last Name"; Text[50])
        {
            Caption = 'Last Name';
            Description = 'NPR5.40';
        }
    }

    keys
    {
        key(Key1; ID)
        {
        }
    }

    fieldgroups
    {
    }
}

