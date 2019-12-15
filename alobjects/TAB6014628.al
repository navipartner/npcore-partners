table 6014628 "Lookup Cache Log"
{
    // NPR5.22/VB/20160316 CASE 236519 Added support for configurable lookup templates and caching.

    Caption = 'Lookup Cache Log';

    fields
    {
        field(1;"Table No.";Integer)
        {
            Caption = 'Table No.';
        }
        field(2;"Last Change";DateTime)
        {
            Caption = 'Last Change';
        }
    }

    keys
    {
        key(Key1;"Table No.")
        {
        }
    }

    fieldgroups
    {
    }
}

