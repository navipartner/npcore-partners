#if not BC17
table 6151027 "NPR Spfy App Request"
{
    Access = Internal;
    Caption = 'Shopify App Request';
    DataClassification = CustomerContent;
    LookupPageId = "NPR Spfy App Requests";
    DrillDownPageId = "NPR Spfy App Requests";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(10; Type; Enum "NPR Spfy App Request Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(100; Payload; Blob)
        {
            Caption = 'Notification Payload';
            DataClassification = CustomerContent;
        }
        field(200; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionMembers = New,Error,Processed;
            OptionCaption = 'New,Error,Processed';
        }
        field(210; "Last Error Message"; Blob)
        {
            Caption = 'Last Error Message';
            DataClassification = CustomerContent;
        }
        field(220; "Processed at"; DateTime)
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
    }

    internal procedure SetPayload(NewPayload: JsonToken)
    var
        OutStr: OutStream;
    begin
        Clear(Payload);
        Payload.CreateOutStream(OutStr, TextEncoding::UTF8);
        NewPayload.WriteTo(OutStr);
    end;

    procedure GetPayloadStream() InStr: InStream
    begin
        CalcFields(Payload);
        Payload.CreateInStream(InStr, TextEncoding::UTF8);
    end;

    procedure GetPayload(): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        if not Payload.HasValue() then
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
        NoErrorMessageTxt: Label 'An error occurred while processing the request. No details were provided for the error.';
    begin
        if Status <> Status::Error then
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