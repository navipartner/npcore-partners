table 6150793 "NPR NPRE Notification Entry"
{
    Access = Internal;
    Caption = 'Restaurant Notification Entry';
    DataClassification = CustomerContent;
    LookupPageId = "NPR NPRE Notification Entries";
    DrillDownPageId = "NPR NPRE Notification Entries";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Notification Trigger"; Enum "NPR NPRE Notification Trigger")
        {
            Caption = 'Notification Trigger';
            DataClassification = CustomerContent;
        }
        field(20; "Notify at Date-Time"; DateTime)
        {
            Caption = 'Not Before Date-Time';
            DataClassification = CustomerContent;
        }
        field(30; "Expires at Date-Time"; DateTime)
        {
            Caption = 'Expires at Date-Time';
            DataClassification = CustomerContent;
        }
        field(40; "Notification Method"; Enum "NPR NPRE Notification Method")
        {
            Caption = 'Notification Method';
            DataClassification = CustomerContent;
        }
        field(50; Recipient; Enum "NPR NPRE Notif. Recipient")
        {
            Caption = 'Recipient';
            DataClassification = CustomerContent;
        }
        field(60; "Notification Template"; Code[20])
        {
            Caption = 'Notification Template';
            DataClassification = CustomerContent;
            TableRelation = if ("Notification Method" = const(EMAIL)) "NPR E-mail Template Header".Code where("Table No." = const(6150793)) else
            if ("Notification Method" = const(SMS)) "NPR SMS Template Header".Code where("Table No." = const(6150793));
        }
        field(70; "Notification Address"; Text[100])
        {
            Caption = 'Notification Address';
            DataClassification = CustomerContent;
        }
        field(80; "Setup Entry No."; Integer)
        {
            Caption = 'Notification Setup Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Notification Setup"."Entry No.";
        }
        field(100; "Notification Send Status"; Enum "NPR NPRE Notification Status")
        {
            Caption = 'Notification Send Status';
            DataClassification = CustomerContent;
        }
        field(110; "Sent at"; DateTime)
        {
            Caption = 'Notification Sent at';
            DataClassification = CustomerContent;
        }
        field(120; "Sent By"; Code[50])
        {
            Caption = 'Notification Sent By User';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(130; "Sending Result Message"; Text[250])
        {
            Caption = 'Sending Result Message';
            DataClassification = CustomerContent;
        }
        field(140; "Sending Result Details"; Blob)
        {
            Caption = 'Sending Result Details';
            DataClassification = CustomerContent;
        }
        field(150; "From Message Log Entry No."; Integer)
        {
            Caption = 'From Message Log Entry No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Notification Method" = const(EMAIL)) "NPR SMS Log"."Entry No.";
        }
        field(160; "To Message Log Entry No."; Integer)
        {
            Caption = 'To Message Log Entry No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Notification Method" = const(EMAIL)) "NPR SMS Log"."Entry No.";
        }
        field(200; "Kitchen Order ID"; BigInteger)
        {
            Caption = 'Kitchen Order ID';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Kitchen Order"."Order ID";
        }
        field(210; "Kitchen Request No."; BigInteger)
        {
            Caption = 'Kitchen Request No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Kitchen Request"."Request No.";
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Kitchen Order ID", "Notification Trigger", Recipient) { }
        key(Key3; "Kitchen Request No.") { }
        key(Key4; "Notification Send Status", "Notify at Date-Time") { }
    }

    internal procedure GetErrorMessage(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
        ErrorText: Text;
        NoErrorMessageTxt: Label 'No details were provided for the error.';
    begin
        if not SendingFailed() then
            exit;

        ErrorText := '';
        if "Sending Result Details".HasValue() then begin
            CalcFields("Sending Result Details");
            "Sending Result Details".CreateInStream(InStream, TextEncoding::UTF8);
            ErrorText := TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator());
        end;
        if ErrorText = '' then
            ErrorText := "Sending Result Message";
        if ErrorText = '' then
            ErrorText := NoErrorMessageTxt;

        exit(ErrorText);
    end;

    internal procedure SendingFailed(): Boolean
    begin
        exit(
            "Notification Send Status" in
                ["Notification Send Status"::QUEUED,
                 "Notification Send Status"::CANCELED,
                 "Notification Send Status"::FAILED,
                 "Notification Send Status"::NOT_SENT]);
    end;

    internal procedure DrillDownRelatedLogEntries()
    var
        SMSLog: Record "NPR SMS Log";
    begin
        if ("From Message Log Entry No." = 0) and ("To Message Log Entry No." = 0) then
            exit;
        case "Notification Method" of
            "Notification Method"::SMS:
                begin
                    case true of
                        ("From Message Log Entry No." <> 0) and ("To Message Log Entry No." <> 0):
                            SMSLog.SetRange("Entry No.", "From Message Log Entry No.", "To Message Log Entry No.");
                        ("From Message Log Entry No." <> 0):
                            SMSLog.SetRange("Entry No.", "From Message Log Entry No.");
                        ("To Message Log Entry No." <> 0):
                            SMSLog.SetRange("Entry No.", "To Message Log Entry No.");
                    end;
                    Page.Run(0, SMSLog);
                end;
        end;
    end;
}