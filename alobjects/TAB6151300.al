table 6151300 "NpEc Store"
{
    // NPR5.53/MHA /20191205  CASE 380837 Object created - NaviPartner General E-Commerce
    // NPR5.54/MHA /20200129  CASE 367842 Added fields 160 "Allow Create Customers", 170 "Update Customers from Sales Order"

    Caption = 'Np E-commerce Store';
    DrillDownPageID = "NpEc Stores";
    LookupPageID = "NpEc Stores";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(10;Name;Text[50])
        {
            Caption = 'Name';
        }
        field(100;"Salesperson/Purchaser Code";Code[10])
        {
            Caption = 'Salesperson/Purchaser Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(110;"Location Code";Code[20])
        {
            Caption = 'Location Code';
            TableRelation = Location.Code;
        }
        field(120;"Global Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));
        }
        field(130;"Global Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));
        }
        field(140;"Customer Mapping";Option)
        {
            Caption = 'Customer Mapping';
            OptionCaption = 'E-mail,Phone No.,E-mail AND Phone No.,E-mail OR Phone No.,Customer No.';
            OptionMembers = "E-mail","Phone No.","E-mail AND Phone No.","E-mail OR Phone No.","Customer No.";
        }
        field(150;"Customer Config. Template Code";Code[10])
        {
            Caption = 'Customer Config. Template Code';
            TableRelation = "Config. Template Header".Code WHERE ("Table ID"=CONST(18));
        }
        field(160;"Allow Create Customers";Boolean)
        {
            Caption = 'Allow Create Customers';
            Description = 'NPR5.54';
            InitValue = true;
        }
        field(170;"Update Customers from S. Order";Boolean)
        {
            Caption = 'Update Customers from Sales Order';
            Description = 'NPR5.54';
            InitValue = true;
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

