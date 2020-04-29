table 6151558 "NpXml Field Value Buffer"
{
    // NC1.08/MH/20150310  CASE 206395 Object created
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    Caption = 'NpXml Field Value Buffer';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
        field(10;"Field Value";Text[250])
        {
            Caption = 'Field Value';
        }
        field(100;Description;Text[250])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

