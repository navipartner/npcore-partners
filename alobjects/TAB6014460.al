table 6014460 "E-mail Log"
{
    // NPR6.000.000, 19-01-11, Job 93865, MH - Created.
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    //   - This Table contains a Log of every E-mail send by PDF2NAV.
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)

    Caption = 'E-mail Log';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2;"Table No.";Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(5;"Primary Key";Text[250])
        {
            Caption = 'Primary Key';
        }
        field(10;"Recipient E-mail";Text[250])
        {
            Caption = 'Recipient E-mail';
        }
        field(11;"From E-mail";Text[250])
        {
            Caption = 'From E-mail';
        }
        field(12;"E-mail subject";Text[200])
        {
            Caption = 'E-mail subject';
        }
        field(14;Filename;Text[200])
        {
            Caption = 'Filename';
        }
        field(50;"Sent Time";Time)
        {
            Caption = 'Sent time';
        }
        field(51;"Sent Date";Date)
        {
            Caption = 'Sent Date';
        }
        field(52;"Sent Username";Text[250])
        {
            Caption = 'Sent by Username';
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

