#if not BC17
table 6150883 "NPR Spfy Webhook Notification"
{
    Access = Public;
    Caption = 'Shopify Webhook Notification';
    DataClassification = CustomerContent;
    LookupPageId = "NPR Spfy Webhook Notifications";
    DrillDownPageId = "NPR Spfy Webhook Notifications";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(10; "Event ID"; Guid)
        {
            Caption = 'Event ID';
            DataClassification = CustomerContent;
        }
        field(20; "Webhook ID"; Guid)
        {
            Caption = 'Webhook ID';
            DataClassification = CustomerContent;
        }
        field(30; "Topic (Received)"; Text[50])
        {
            Caption = 'Topic';
            DataClassification = CustomerContent;
        }
        field(35; Topic; Enum "NPR Spfy Webhook Topic")
        {
            Caption = 'Topic (Enum)';
            DataClassification = CustomerContent;
        }
        field(40; "Shop Domain"; Text[200])
        {
            Caption = 'Shop Domain';
            DataClassification = CustomerContent;
        }
        field(50; "Api Version"; Text[10])
        {
            Caption = 'Api Version';
            DataClassification = CustomerContent;
        }
        field(60; "Triggered At"; DateTime)
        {
            Caption = 'Triggered At';
            DataClassification = CustomerContent;
        }
        field(70; "Triggered for Source ID"; Text[30])
        {
            Caption = 'Triggered for Source ID';
            DataClassification = CustomerContent;
        }
        field(200; "Notification Payload"; Blob)
        {
            Caption = 'Notification Payload';
            DataClassification = CustomerContent;
        }
        field(210; "AF Raw Payload"; Blob)
        {
            Caption = 'AF Raw Payload';
            DataClassification = CustomerContent;
        }
        field(300; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionMembers = New,Error,Processed,Cancelled;
            OptionCaption = 'New,Error,Processed,Cancelled';
        }
        field(310; "Last Error Message"; Blob)
        {
            Caption = 'Last Error Message';
            DataClassification = CustomerContent;
        }
        field(320; "Number of Process Attempts"; Integer)
        {
            Caption = 'Number of Process Attempts';
            DataClassification = CustomerContent;
        }
        field(330; "Processed at"; DateTime)
        {
            Caption = 'Processed at';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(BtShopifyEventID; "Event ID") { }
        key(ByStatus; Status) { }
    }

    internal procedure SetAFRawPayload(NewPayload: Text)
    var
        OutStr: OutStream;
    begin
        Clear("AF Raw Payload");
        if NewPayload = '' then
            exit;
        "AF Raw Payload".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(NewPayload);
    end;

    procedure GetAFRawPayloadStream() InStr: InStream
    begin
        CalcFields("AF Raw Payload");
        "AF Raw Payload".CreateInStream(InStr, TextEncoding::UTF8);
    end;

    procedure GetAFRawPayload(): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        if not "AF Raw Payload".HasValue() then
            exit('');
        exit(TypeHelper.ReadAsTextWithSeparator(GetAfRawPayloadStream(), TypeHelper.LFSeparator()));
    end;

    internal procedure SetPayload(NewPayload: JsonToken)
    var
        OutStr: OutStream;
    begin
        Clear("Notification Payload");
        "Notification Payload".CreateOutStream(OutStr, TextEncoding::UTF8);
        NewPayload.WriteTo(OutStr);
    end;

    procedure GetPayloadStream() InStr: InStream
    begin
        CalcFields("Notification Payload");
        "Notification Payload".CreateInStream(InStr, TextEncoding::UTF8);
    end;

    procedure GetPayload(): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        if not "Notification Payload".HasValue() then
            exit('');
        exit(TypeHelper.ReadAsTextWithSeparator(GetPayloadStream(), TypeHelper.LFSeparator()));
    end;

    internal procedure SetErrorMessage(NewErrorText: Text)
    var
        OutStr: OutStream;
    begin
        Clear("Last Error Message");
        if NewErrorText = '' then
            exit;
        "Last Error Message".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(NewErrorText);
    end;

    procedure GetErrorMessage(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
        ErrorText: Text;
        NoErrorMessageTxt: Label 'No details were provided for the error.';
    begin
        if not (Status in [Status::Error, Status::Cancelled]) then
            exit('');
        ErrorText := '';
        if "Last Error Message".HasValue() then begin
            CalcFields("Last Error Message");
            "Last Error Message".CreateInStream(InStream, TextEncoding::UTF8);
            ErrorText := TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator());
        end;
        if ErrorText = '' then
            ErrorText := NoErrorMessageTxt;
        exit(ErrorText);
    end;
}
#endif