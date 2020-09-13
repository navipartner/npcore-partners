table 6014460 "NPR E-mail Log"
{
    // NPR6.000.000, 19-01-11, Job 93865, MH - Created.
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    //   - This Table contains a Log of every E-mail send by PDF2NAV.
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)

    Caption = 'E-mail Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
            DataClassification = CustomerContent;
        }
        field(5; "Primary Key"; Text[250])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Recipient E-mail"; Text[250])
        {
            Caption = 'Recipient E-mail';
            DataClassification = CustomerContent;
        }
        field(11; "From E-mail"; Text[250])
        {
            Caption = 'From E-mail';
            DataClassification = CustomerContent;
        }
        field(12; "E-mail subject"; Text[200])
        {
            Caption = 'E-mail subject';
            DataClassification = CustomerContent;
        }
        field(14; Filename; Text[200])
        {
            Caption = 'Filename';
            DataClassification = CustomerContent;
        }
        field(50; "Sent Time"; Time)
        {
            Caption = 'Sent time';
            DataClassification = CustomerContent;
        }
        field(51; "Sent Date"; Date)
        {
            Caption = 'Sent Date';
            DataClassification = CustomerContent;
        }
        field(52; "Sent Username"; Text[250])
        {
            Caption = 'Sent by Username';
            DataClassification = CustomerContent;
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

