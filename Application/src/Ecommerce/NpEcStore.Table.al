table 6151300 "NPR NpEc Store"
{
    Caption = 'E-commerce Store';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpEc Stores";
    LookupPageID = "NPR NpEc Stores";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(100; "Salesperson/Purchaser Code"; Code[20])
        {
            Caption = 'Salesperson/Purchaser Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
        }
        field(110; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location.Code;
        }
        field(120; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(130; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(140; "Customer Mapping"; Option)
        {
            Caption = 'Customer Mapping';
            DataClassification = CustomerContent;
            OptionCaption = 'E-mail,Phone No.,E-mail AND Phone No.,E-mail OR Phone No.,Customer No.';
            OptionMembers = "E-mail","Phone No.","E-mail AND Phone No.","E-mail OR Phone No.","Customer No.";
        }
        field(150; "Customer Config. Template Code"; Code[10])
        {
            Caption = 'Customer Config. Template Code';
            DataClassification = CustomerContent;
            TableRelation = "Config. Template Header".Code WHERE("Table ID" = CONST(18));
        }
        field(160; "Allow Create Customers"; Boolean)
        {
            Caption = 'Allow Create Customers';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            InitValue = true;
        }
        field(170; "Update Customers from S. Order"; Boolean)
        {
            Caption = 'Update Customers from Sales Order';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            InitValue = true;
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

