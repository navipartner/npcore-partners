table 6151031 "NPR NpRv Arch. Sending Log"
{
    Caption = 'Retail Voucher Sending Log';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpRv Arch. Sending Log";
    LookupPageID = "NPR NpRv Arch. Sending Log";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Arch. Voucher No."; Code[20])
        {
            Caption = 'Arch. Voucher No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpRv Arch. Voucher";
        }
        field(20; "Sending Type"; Option)
        {
            Caption = 'Sending Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Print,E-mail,Sms';
            OptionMembers = " ",Print,"E-mail",SMS;
        }
        field(25; "Log Message"; Text[100])
        {
            Caption = 'Log Message';
            DataClassification = CustomerContent;
        }
        field(30; "Log Date"; DateTime)
        {
            Caption = 'Log Date';
            DataClassification = CustomerContent;
        }
        field(40; "Sent to"; Text[80])
        {
            Caption = 'Sent to';
            DataClassification = CustomerContent;
        }
        field(50; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(60; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(70; "Error during Send"; Boolean)
        {
            Caption = 'Error during Send';
            DataClassification = CustomerContent;
        }
        field(80; "Error Message"; BLOB)
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(85; "Original Entry No."; Integer)
        {
            Caption = 'Original Entry No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Arch. Voucher No.", "Error during Send")
        {
        }
    }

    procedure GetErrorMessage() FullLogMessage: Text
    var
        InStr: InStream;
        BufferText: Text;
    begin
        FullLogMessage := '';
        if not "Error Message".HasValue() then
            exit('');

        CalcFields("Error Message");
        "Error Message".CreateInStream(InStr, TEXTENCODING::UTF8);
        while not InStr.EOS do begin
            InStr.ReadText(BufferText);
            FullLogMessage += BufferText;
        end;
        exit(FullLogMessage);
    end;
}

