table 6151031 "NpRv Arch. Sending Log"
{
    // NPR5.55/MHA /20200702  CASE 407070 Object created

    Caption = 'Retail Voucher Sending Log';
    DrillDownPageID = "NpRv Arch. Sending Log";
    LookupPageID = "NpRv Arch. Sending Log";

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(10;"Arch. Voucher No.";Code[20])
        {
            Caption = 'Arch. Voucher No.';
            TableRelation = "NpRv Arch. Voucher";
        }
        field(20;"Sending Type";Option)
        {
            Caption = 'Sending Type';
            OptionCaption = ' ,Print,E-mail,Sms';
            OptionMembers = " ",Print,"E-mail",SMS;
        }
        field(25;"Log Message";Text[100])
        {
            Caption = 'Log Message';
        }
        field(30;"Log Date";DateTime)
        {
            Caption = 'Log Date';
        }
        field(40;"Sent to";Text[80])
        {
            Caption = 'Sent to';
        }
        field(50;Amount;Decimal)
        {
            Caption = 'Amount';
        }
        field(60;"User ID";Code[50])
        {
            Caption = 'User ID';
        }
        field(70;"Error during Send";Boolean)
        {
            Caption = 'Error during Send';
        }
        field(80;"Error Message";BLOB)
        {
            Caption = 'Error Message';
        }
        field(85;"Original Entry No.";Integer)
        {
            Caption = 'Original Entry No.';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Arch. Voucher No.","Error during Send")
        {
        }
    }

    fieldgroups
    {
    }

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

