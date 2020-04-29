table 6150649 "POS Entity Group"
{
    // NPR5.31/AP/20170418  CASE 272321  New table for multi-purpose grouping of POS Entities like POS Store, POS Unit, POS Payment Method etc.
    //                                   Grouping may be for either functional (e.g. POS Layout grouping) or for BI/Reporting purpose.

    Caption = 'POS Entity Group';
    LookupPageID = "POS Entity Groups";

    fields
    {
        field(1;"Table ID";Integer)
        {
            Caption = 'Table ID';
            NotBlank = true;
        }
        field(2;"Field No.";Integer)
        {
            Caption = 'Field No.';
            NotBlank = true;
        }
        field(3;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(4;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(10;Sorting;Decimal)
        {
            Caption = 'Sorting';
            DecimalPlaces = 0:5;
        }
    }

    keys
    {
        key(Key1;"Table ID","Field No.","Code")
        {
        }
        key(Key2;"Table ID",Sorting)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;"Code",Description)
        {
        }
    }
}

