table 6151557 "NpXml Custom Value Buffer"
{
    // NC1.01/MH/20150122  CASE 199932 Object created - Value from Custom Codeunit should be stored here (Use Temp Table).
    // NC1.07/MH/20150309  CASE 208131 Updated captions
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    Caption = 'NpXml Custom Value Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(3; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
            Description = 'NC1.07';
        }
        field(5; "Record Position"; Text[200])
        {
            Caption = 'Record Position';
            DataClassification = CustomerContent;
            Description = 'NC1.07';
        }
        field(100; Value; BLOB)
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
        }
        field(6059850; "Xml Template Code"; Code[20])
        {
            Caption = 'Xml Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NpXml Template";
        }
        field(6059851; "Xml Element Line No."; Integer)
        {
            Caption = 'Xml Element Line No.';
            DataClassification = CustomerContent;
            Description = 'NC1.07';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

