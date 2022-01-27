table 6014483 "NPR RFID Setup"
{
    Access = Internal;
    // NPR5.48/MMV /20181206 Object created

    Caption = 'RFID Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "RFID Value No. Series"; Code[20])
        {
            Caption = 'RFID Value No. Series';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NoSeries: Record "No. Series";
            begin
                if "RFID Value No. Series" <> '' then begin
                    NoSeries.Get("RFID Value No. Series");
                    NoSeries.TestField("Default Nos.", true);
                end;
            end;
        }
        field(11; "RFID Hex Value Length"; Integer)
        {
            Caption = 'RFID Hex Value Length';
            DataClassification = CustomerContent;
        }
        field(12; "RFID Hex Value Prefix"; Text[30])
        {
            Caption = 'RFID Hex Value Prefix';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

