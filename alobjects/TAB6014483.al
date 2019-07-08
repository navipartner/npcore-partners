table 6014483 "RFID Setup"
{
    // NPR5.48/MMV /20181206 Object created

    Caption = 'RFID Setup';

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10;"RFID Value No. Series";Code[10])
        {
            Caption = 'RFID Value No. Series';
            TableRelation = "No. Series";

            trigger OnValidate()
            var
                NoSeries: Record "No. Series";
            begin
                if "RFID Value No. Series" <> '' then begin
                  NoSeries.Get("RFID Value No. Series");
                  NoSeries.TestField("Default Nos.",true);
                end;
            end;
        }
        field(11;"RFID Hex Value Length";Integer)
        {
            Caption = 'RFID Hex Value Length';
        }
        field(12;"RFID Hex Value Prefix";Text[30])
        {
            Caption = 'RFID Hex Value Prefix';
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

