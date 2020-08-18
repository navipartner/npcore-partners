table 6014495 "Archive Retail Cross Reference"
{
    // The purpose of this table:
    //   All existing unfinished sale transactions have been moved to archive tables
    //   The table may be deleted later, when it is no longer relevant.
    // 
    // NPR5.54/ALPO/20200203 CASE 364658 Resume POS Sale
    // NPR5.55/ALPO/20200423 CASE 401611 5.54 upgrade performace optimization

    Caption = 'Retail Cross Reference';
    DrillDownPageID = "Retail Cross References";
    LookupPageID = "Retail Cross References";

    fields
    {
        field(1;"Retail ID";Guid)
        {
            Caption = 'Retail ID';
        }
        field(5;"Reference No.";Code[50])
        {
            Caption = 'Reference No.';
        }
        field(10;"Table ID";Integer)
        {
            Caption = 'Table ID';
        }
        field(15;"Record Value";Text[100])
        {
            Caption = 'Record Value';
        }
    }

    keys
    {
        key(Key1;"Retail ID")
        {
        }
        key(Key2;"Reference No.","Table ID")
        {
        }
    }

    fieldgroups
    {
    }
}

