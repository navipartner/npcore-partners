table 6059840 "NPR HL Webhook Request"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;
    Caption = 'HeyLoyalty Webhook Request';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(10; "HL Member ID"; Text[50])
        {
            Caption = 'HL Member ID';
            DataClassification = CustomerContent;
        }
        field(20; "HL List ID"; Integer)
        {
            Caption = 'HL List ID';
            DataClassification = CustomerContent;
        }
        field(30; "HL Reference ID"; Integer)
        {
            Caption = 'HL Reference ID';
            DataClassification = CustomerContent;
        }
        field(40; "HL Webhook ID"; Integer)
        {
            Caption = 'HL Webhook ID';
            DataClassification = CustomerContent;
        }
        field(50; "HL Queued at"; Text[50])
        {
            Caption = 'HL Queued at';
            DataClassification = CustomerContent;
        }
        field(60; "HL Message Type"; Text[100])
        {
            Caption = 'HL Message Type';
            DataClassification = CustomerContent;
        }
        field(70; "HL Request Type"; Text[100])
        {
            Caption = 'HL Request Type';
            DataClassification = CustomerContent;
        }
        field(80; "HL Signature"; Text[50])
        {
            Caption = 'HL Request Type';
            DataClassification = CustomerContent;
        }
        field(100; "HL Request Data"; Blob)
        {
            Caption = 'HL Request Data';
            DataClassification = CustomerContent;
        }
        field(200; "Processing Status"; Option)
        {
            Caption = 'Processing Status';
            DataClassification = CustomerContent;
            OptionMembers = " ",New,"In-Process","Processed",Error;
            OptionCaption = ' ,New,In-Process,Processed,Error';
        }
        field(210; "Last Error Message"; Blob)
        {
            Caption = 'Last Error Message';
            DataClassification = CustomerContent;
        }
        field(230; "Processed at"; DateTime)
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
        key(ByStatus; "Processing Status") { }
    }

    trigger OnInsert()
    begin
        "Processing Status" := "Processing Status"::New;
    end;

    procedure SetHLRequestData(NewRequestData: Text)
    var
        OutStr: OutStream;
    begin
        Clear("HL Request Data");
        if NewRequestData = '' then
            exit;
        "HL Request Data".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(NewRequestData);
    end;

#IF BC17
    procedure GetHLRequestDataStream(var InStr: InStream)
#ELSE
    procedure GetHLRequestDataStream() InStr: InStream
#ENDIF
    begin
        CalcFields("HL Request Data");
        "HL Request Data".CreateInStream(InStr, TextEncoding::UTF8);
    end;

    procedure GetHLRequestData(): Text
    var
        TypeHelper: Codeunit "Type Helper";
#IF BC17
        InStr: InStream;
#ENDIF
    begin
        if not "HL Request Data".HasValue then
            exit('');
#IF BC17
        GetHLRequestDataStream(InStr);
        exit(TypeHelper.ReadAsTextWithSeparator(InStr, TypeHelper.LFSeparator()));
#ELSE
        exit(TypeHelper.ReadAsTextWithSeparator(GetHLRequestDataStream(), TypeHelper.LFSeparator()));
#ENDIF
    end;

    internal procedure SetErrorMessage(NewErrorText: Text)
    var
        OutStream: OutStream;
    begin
        Clear("Last Error Message");
        if NewErrorText = '' then
            exit;
        "Last Error Message".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NewErrorText);
    end;

    internal procedure GetErrorMessage(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
        ErrorText: Text;
        NoErrorMessageTxt: Label 'No details were provided for the error.';
    begin
        if "Processing Status" <> "Processing Status"::Error then
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

    internal procedure SetStatusInProcess()
    begin
        if "Last Error Message".HasValue() then
            Clear("Last Error Message");
        "Processing Status" := "Processing Status"::"In-Process";
        Modify();
        Commit();
    end;

    internal procedure SetStatusFinished()
    begin
        "Processing Status" := "Processing Status"::Processed;
        "Processed at" := CurrentDateTime();
        Modify();
        Commit();
    end;

    internal procedure SetStatusError(ErrorText: Text)
    begin
        "Processing Status" := "Processing Status"::Error;
        SetErrorMessage(ErrorText);
        Modify();
        Commit();
    end;
}