table 6150641 "POS Info Subcode"
{
    // NPR5.26/OSFI/20160810 CASE 246167 Object Created

    Caption = 'POS Info Subcode';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Subcode; Code[20])
        {
            Caption = 'Subcode';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code", Subcode)
        {
        }
    }

    fieldgroups
    {
    }
}

