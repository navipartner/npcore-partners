table 6151386 "NPR CS Rfid Data"
{
    Access = Internal;

    Caption = 'CS Rfid Data';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.';



    fields
    {
        field(1; "Key"; Text[30])
        {
            Caption = 'Key';
            DataClassification = CustomerContent;
        }
        field(11; "Cross-Reference Item No."; Code[20])
        {
            Caption = 'Cross-Reference Item No.';
            DataClassification = CustomerContent;
        }
        field(12; "Cross-Reference Variant Code"; Code[10])
        {
            Caption = 'Cross-Reference Variant Code';
            DataClassification = CustomerContent;
        }
        field(15; "Item Group Code"; Code[10])
        {
            Caption = 'Item Group Code';
            DataClassification = CustomerContent;
        }
        field(17; "Combined key"; Code[30])
        {
            Caption = 'Combined key';
            DataClassification = CustomerContent;
        }
        field(18; "Image Url"; Text[250])
        {
            Caption = 'Image Url';
            DataClassification = CustomerContent;
        }
        field(19; "Time Stamp"; BigInteger)
        {
            Caption = 'Time Stamp';
            DataClassification = CustomerContent;
            SQLTimestamp = true;
        }
        field(20; "Cross-Reference UoM"; Code[10])
        {
            Caption = 'Cross-Reference UoM';
            DataClassification = CustomerContent;
        }
        field(21; "Cross-Reference Description"; Text[50])
        {
            Caption = 'Cross-Reference Description';
            DataClassification = CustomerContent;
        }
        field(22; "Cross-Reference Discontinue"; Boolean)
        {
            Caption = 'Cross-Reference Discontinue';
            DataClassification = CustomerContent;
        }
        field(23; "Last Known Store Location"; Code[10])
        {
            Caption = 'Last Known Store Location';
            DataClassification = CustomerContent;
        }
        field(24; Created; DateTime)
        {
            Caption = 'Created';
            DataClassification = CustomerContent;
        }
        field(25; Heartbeat; DateTime)
        {
            Caption = 'Heartbeat';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Key")
        {
        }
    }

    fieldgroups
    {
    }


}

