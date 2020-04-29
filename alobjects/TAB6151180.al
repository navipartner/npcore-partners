table 6151180 "Retail Cross Reference"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created

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

