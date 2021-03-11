table 6014513 "NPR SMS Log"
{
    Caption = 'SMS Log';
    DataClassification = CustomerContent;
    LookupPageId = "NPR SMS Log";
    DrillDownPageId = "NPR SMS Log";
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(2; "Sender No."; Text[20])
        {
            Caption = 'Sender No';

            DataClassification = CustomerContent;
        }
        field(3; "Reciepient No."; Text[20])
        {
            Caption = 'Reciepient No.';
            DataClassification = CustomerContent;
        }
        field(4; "Message"; Blob)
        {
            Caption = 'Message';
            DataClassification = CustomerContent;
        }
        field(5; Status; Enum "NPR SMS Log Status")
        {
            Caption = 'Status';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6; "Error Message"; Blob)
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(7; "Send on Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'Send on Date Time';
        }

        field(8; "Date Time Sent"; DateTime)
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'Date Time Sent';
        }
        field(9; "Send Attempts"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Send Attempts';
            Editable = false;
        }
        field(10; "User Notified"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'User Notified';
            Editable = false;
        }
        field(11; "Last Send Attempt"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Send Attempt';
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key1; Status, "Send on Date Time")
        { }
    }
    procedure SetMessage(Message: Text)
    var
        OutStr: OutStream;
    begin
        Rec.Message.CreateOutStream(OutStr);
        Outstr.Write(Message);
    end;

    procedure SetError(Message: Text)
    var
        OutStr: OutStream;
    begin
        Rec."Error Message".CreateOutStream(OutStr);
        Outstr.Write(Message);
    end;

    procedure GetMessage(var Message: Text)
    var
        InStr: InStream;
    begin
        Rec.CalcFields(Message);
        Rec.Message.CreateInStream(InStr);
        InStr.Read(Message);
    end;

    procedure GetSetError(var Message: Text)
    var
        InStr: InStream;
    begin
        Rec.CalcFields("Error Message");
        Rec."Error Message".CreateInStream(InStr);
        InStr.Read(Message);
    end;
}
