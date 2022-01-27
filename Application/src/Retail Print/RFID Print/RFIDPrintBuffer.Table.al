table 6014542 "NPR RFID Print Buffer"
{
    Access = Internal;
    // NPR5.48/MMV /20181206 CASE 327107 Object created

    Caption = 'RFID Print Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tag No."; Integer)
        {
            Caption = 'Tag No.';
            DataClassification = CustomerContent;
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(3; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(4; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
            DataClassification = CustomerContent;
        }
        field(5; "Read EPC"; Text[50])
        {
            Caption = 'Read EPC';
            DataClassification = CustomerContent;
        }
        field(6; "Read TID"; Text[50])
        {
            Caption = 'Read TID';
            DataClassification = CustomerContent;
        }
        field(7; "EPC To Write"; Text[50])
        {
            Caption = 'EPC To Write';
            DataClassification = CustomerContent;
        }
        field(8; "Print Job"; BLOB)
        {
            Caption = 'Print Job';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Tag No.")
        {
        }
    }

    fieldgroups
    {
    }
}

