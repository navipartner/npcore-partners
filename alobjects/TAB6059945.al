table 6059945 "CashKeeper Setup"
{
    // NPR5.29\CLVA\20161108 CASE NPR5.29 Object Created
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.40/CLVA/20180307 CASE 291921 Added field "Payment Type"

    Caption = 'CashKeeper Setup';

    fields
    {
        field(1;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
            TableRelation = Register;
        }
        field(10;"CashKeeper IP";Text[20])
        {
            Caption = 'CashKeeper IP';
        }
        field(11;"Debug Mode";Boolean)
        {
            Caption = 'Debug Mode';
        }
        field(12;"Payment Type";Code[20])
        {
            Caption = 'Payment Type';
            TableRelation = "Payment Type POS"."No.";
        }
    }

    keys
    {
        key(Key1;"Register No.")
        {
        }
    }

    fieldgroups
    {
    }
}

