table 6150682 "NPRE Kitchen Station"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant

    Caption = 'Kitchen Station';
    DrillDownPageID = "NPRE Kitchen Stations";
    LookupPageID = "NPRE Kitchen Stations";

    fields
    {
        field(1;"Restaurant Code";Code[20])
        {
            Caption = 'Restaurant Code';
            TableRelation = "NPRE Restaurant";
        }
        field(2;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(11;"Description 2";Text[50])
        {
            Caption = 'Description 2';
        }
    }

    keys
    {
        key(Key1;"Restaurant Code","Code")
        {
        }
    }

    fieldgroups
    {
    }
}

