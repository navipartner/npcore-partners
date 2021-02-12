table 6059894 "NPR Data Log Processing Entry"
{
    DrillDownPageID = "NPR Data Log Process. Entries";
    LookupPageID = "NPR Data Log Process. Entries";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Inserted at"; DateTime)
        {
            Caption = 'Inserted at';
            DataClassification = CustomerContent;
        }
        field(10; "Subscriber Code"; Code[30])
        {
            Caption = 'Subscriber Code';
            DataClassification = CustomerContent;
        }
        field(20; "Table Number"; Integer)
        {
            Caption = 'Table Number';
            DataClassification = CustomerContent;
        }
        field(30; "Data Log Entry No."; BigInteger)
        {
            Caption = 'Data Log Entry No.';
            DataClassification = CustomerContent;
        }
        field(35; "Data Log Record Value"; Text[250])
        {
            Caption = 'Data Log Record Value';
            DataClassification = CustomerContent;
        }
        field(40; "Error Message"; BLOB)
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(50; "Processing Started at"; DateTime)
        {
            Caption = 'Processing Started at';
            DataClassification = CustomerContent;
        }
        field(60; "Processing Completed at"; DateTime)
        {
            Caption = 'Processing Completed at';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Subscriber Code", "Table Number", "Data Log Entry No.")
        {
        }
        key(Key3; "Data Log Entry No.")
        {
        }
    }

    procedure GetErrorMessage() ErrorMessage: Text
    var
        InStr: InStream;
        BufferText: Text;
    begin
        ErrorMessage := '';
        if not "Error Message".HasValue then
            exit('');

        CalcFields("Error Message");
        "Error Message".CreateInStream(InStr, TEXTENCODING::UTF8);
        BufferText := '';
        while not InStr.EOS do begin
            InStr.ReadText(BufferText);
            ErrorMessage += BufferText;
        end;
        exit(ErrorMessage);
    end;
}