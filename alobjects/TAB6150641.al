table 6150641 "POS Info Subcode"
{
    // NPR5.26/OSFI/20160810 CASE 246167 Object Created

    Caption = 'POS Info Subcode';

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
        }
        field(2;Subcode;Code[20])
        {
            Caption = 'Subcode';
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"Code",Subcode)
        {
        }
    }

    fieldgroups
    {
    }
}

