table 6151199 "NpCs Document Log Entry"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Collect Document Log Entry';
    DrillDownPageID = "NpCs Document Log Entries";
    LookupPageID = "NpCs Document Log Entries";

    fields
    {
        field(1;"Entry No.";BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(5;"Log Date";DateTime)
        {
            Caption = 'Log Date';
        }
        field(13;"Workflow Type";Option)
        {
            Caption = 'Workflow Type';
            OptionCaption = 'Send Order,Order Status,Post Processing';
            OptionMembers = "Send Order","Order Status","Post Processing";
        }
        field(15;"Workflow Module";Code[20])
        {
            Caption = 'Workflow Module';
            TableRelation = "NpCs Workflow Module".Code WHERE (Type=FIELD("Workflow Type"));
        }
        field(20;"Log Message";Text[250])
        {
            Caption = 'Log Message';
        }
        field(25;"Error Message";BLOB)
        {
            Caption = 'Error Message';
        }
        field(30;"Error Entry";Boolean)
        {
            Caption = 'Error Entry';
        }
        field(35;"User ID";Code[50])
        {
            Caption = 'User ID';
        }
        field(40;"Store Code";Code[20])
        {
            Caption = 'Store Code';
        }
        field(45;"Store Log Entry No.";BigInteger)
        {
            Caption = 'Store Log Entry No.';
        }
        field(100;"Document Entry No.";Integer)
        {
            Caption = 'Document Entry No.';
            TableRelation = "NpCs Document";
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Document Entry No.")
        {
        }
        key(Key3;"Store Code","Store Log Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "Log Date" = 0DT then
          "Log Date" := CurrentDateTime;
        if "User ID" = '' then
          "User ID" := UserId;
    end;

    procedure GetErrorMessage() FullLogMessage: Text
    var
        StreamReader: DotNet npNetStreamReader;
        InStr: InStream;
    begin
        FullLogMessage := '';
        if not "Error Message".HasValue then
          exit('');

        CalcFields("Error Message");
        "Error Message".CreateInStream(InStr,TEXTENCODING::UTF8);
        StreamReader := StreamReader.StreamReader(InStr);
        FullLogMessage := StreamReader.ReadToEnd();
        exit(FullLogMessage);
    end;
}

