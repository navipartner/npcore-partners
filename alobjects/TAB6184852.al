table 6184852 "FR POS Audit Log Aux. Info"
{
    // NPR5.48/MMV /20181025 CASE 318028 Created object

    Caption = 'FR POS Audit Log Aux. Info';

    fields
    {
        field(1;"POS Entry No.";Integer)
        {
            Caption = 'POS Entry No.';
            TableRelation = "POS Entry";
        }
        field(2;"NPR Version";Text[250])
        {
            Caption = 'NPR Version';
        }
        field(3;"Store Name";Text[50])
        {
            Caption = 'Store Name';
        }
        field(4;"Store Name 2";Text[50])
        {
            Caption = 'Store Name 2';
        }
        field(5;"Store Address";Text[50])
        {
            Caption = 'Store Address';
        }
        field(6;"Store Address 2";Text[50])
        {
            Caption = 'Store Address 2';
        }
        field(7;"Store Post Code";Code[20])
        {
            Caption = 'Store Post Code';
        }
        field(8;"Store City";Text[30])
        {
            Caption = 'Store City';
        }
        field(9;"Store Siret";Text[20])
        {
            Caption = 'Store Siret';
        }
        field(10;APE;Code[10])
        {
            Caption = 'APE';
        }
        field(11;"Intra-comm. VAT ID";Text[20])
        {
            Caption = 'Intra-comm. VAT ID';
        }
        field(12;"Salesperson Name";Text[50])
        {
            Caption = 'Salesperson Name';
        }
        field(13;"Store Country/Region Code";Code[10])
        {
            Caption = 'Store Country/Region Code';
            TableRelation = "Country/Region";
        }
    }

    keys
    {
        key(Key1;"POS Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

