table 6151030 "NpRv Sending Log"
{
    // NPR5.55/MHA /20200702  CASE 407070 Object created

    Caption = 'Retail Voucher Sending Log';
    DrillDownPageID = "NpRv Sending Log";
    LookupPageID = "NpRv Sending Log";

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(10;"Voucher No.";Code[20])
        {
            Caption = 'Voucher No.';
            TableRelation = "NpRv Voucher";
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
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Voucher No.","Error during Send")
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

