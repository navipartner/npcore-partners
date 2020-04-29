table 6014542 "RFID Print Buffer"
{
    // NPR5.48/MMV /20181206 CASE 327107 Object created

    Caption = 'RFID Print Buffer';

    fields
    {
        field(1;"Tag No.";Integer)
        {
            Caption = 'Tag No.';
        }
        field(2;"Item No.";Code[20])
        {
            Caption = 'Item No.';
        }
        field(3;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
        }
        field(4;"Serial No.";Code[20])
        {
            Caption = 'Serial No.';
        }
        field(5;"Read EPC";Text[50])
        {
            Caption = 'Read EPC';
        }
        field(6;"Read TID";Text[50])
        {
            Caption = 'Read TID';
        }
        field(7;"EPC To Write";Text[50])
        {
            Caption = 'EPC To Write';
        }
        field(8;"Print Job";BLOB)
        {
            Caption = 'Print Job';
        }
    }

    keys
    {
        key(Key1;"Tag No.")
        {
        }
    }

    fieldgroups
    {
    }
}

