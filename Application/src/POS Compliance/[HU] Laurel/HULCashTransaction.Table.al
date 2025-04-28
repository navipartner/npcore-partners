table 6151044 "NPR HU L Cash Transaction"
{
    Access = Internal;
    Caption = 'HU Laurel Cash Transaction';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR HU L Cash Transactions";
    LookupPageId = "NPR HU L Cash Transactions";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
            OptionMembers = moneyIn,moneyOut;
            OptionCaption = 'Money In,Money Out';
        }
        field(10; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store";
        }
        field(11; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(12; "POS Payment Method Code"; Code[10])
        {
            Caption = 'POS Payment Method';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
        field(15; "Cash Amount"; Decimal)
        {
            Caption = 'Cash Amount';
            DataClassification = CustomerContent;
        }
        field(16; "Rounding Amount"; Decimal)
        {
            Caption = 'Rounding Amount';
            DataClassification = CustomerContent;
        }
        field(20; "FCU ID"; Code[9])
        {
            Caption = 'FCU ID';
            DataClassification = CustomerContent;
        }
        field(21; "FCU Document No."; Integer)
        {
            Caption = 'FCU Document No.';
            DataClassification = CustomerContent;
        }
        field(22; "FCU Full Document No."; Text[50])
        {
            Caption = 'FCU Full Document No.';
            DataClassification = CustomerContent;
        }
        field(23; "FCU Timestamp"; Text[20])
        {
            Caption = 'FCU Timestamp';
            DataClassification = CustomerContent;
        }
        field(24; "FCU Closure No."; Integer)
        {
            Caption = 'FCU Closure No.';
            DataClassification = CustomerContent;
        }
        field(25; "Request Content"; Media)
        {
            Caption = 'Request Content';
            DataClassification = CustomerContent;
        }
        field(27; "Response Content"; Media)
        {
            Caption = 'Response Content';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.") { }
    }

    internal procedure GetLastEntryNo(): Integer;
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo("Entry No.")))
    end;

    internal procedure GetRequestText() RequestText: Text;
    var
        JSONManagement: Codeunit "JSON Management";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
        RequestTextLine: Text;
    begin
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        "Request Content".ExportStream(OutStream);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        while not InStream.EOS do begin
            InStream.ReadText(RequestTextLine);
            RequestText += RequestTextLine;
        end;

        if RequestText <> '' then begin
            JSONManagement.InitializeFromString(RequestText);
            RequestText := JSONManagement.WriteObjectToString();
        end;
    end;

    internal procedure SetRequestText(RequestText: Text)
    var
        TenantMedia: Record "Tenant Media";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
    begin
        if "Request Content".HasValue() then
            if TenantMedia.Get("Request Content".MediaId) then
                TenantMedia.Delete(true);

        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(RequestText);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        "Request Content".ImportStream(InStream, FieldCaption("Request Content"));
    end;

    internal procedure GetResponseText() ResponseText: Text;
    var
        JSONManagement: Codeunit "JSON Management";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
        ResponseTextLine: Text;
    begin
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        "Response Content".ExportStream(OutStream);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        while not InStream.EOS do begin
            InStream.ReadText(ResponseTextLine);
            ResponseText += ResponseTextLine;
        end;

        if ResponseText <> '' then begin
            JSONManagement.InitializeFromString(ResponseText);
            ResponseText := JSONManagement.WriteObjectToString();
        end;
    end;

    internal procedure SetResponseText(ResponseText: Text)
    var
        TenantMedia: Record "Tenant Media";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
    begin
        if "Response Content".HasValue() then
            if TenantMedia.Get("Response Content".MediaId) then
                TenantMedia.Delete(true);

        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(ResponseText);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        "Response Content".ImportStream(InStream, FieldCaption("Response Content"));
    end;
}