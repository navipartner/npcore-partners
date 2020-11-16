table 6060061 "NPR Catalog Supplier"
{
    // NPR5.39/BR  /20171212 CASE 295322 Object Created
    // NPR5.42/RA/20180522  CASE 313503 Added field 30 and 40
    // NPR5.48/JDH /20181109 CASE 334163 Added caption to fields

    Caption = 'Catalog Supplier';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Catalog Suppliers";
    LookupPageID = "NPR Catalog Suppliers";

    fields
    {
        field(10; "Code"; Code[4])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(20; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
        field(30; "Send Sales Statistics"; Boolean)
        {
            Caption = 'Send Sales Statistics';
            DataClassification = CustomerContent;
        }
        field(40; "Trade Number"; Code[20])
        {
            Caption = 'Trade Number';
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

