table 6150963 "NPR MM Subs Pay Req Log Entry"
{
    Access = Internal;
    Caption = 'Subscriptions Payment Request Log Entry';
    DataClassification = CustomerContent;
    LookupPageId = "NPR MM Sub Pay Req Log Entries";
    DrillDownPageId = "NPR MM Sub Pay Req Log Entries";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }

        field(2; "Payment Request Entry No."; BigInteger)
        {
            Caption = 'Payment Request Entry No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Payment Request Id"; Guid)
        {
            Caption = 'Payment Request System Id';
            DataClassification = SystemMetadata;
        }
        field(4; Status; Enum "NPR MM Payment Request Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(6; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(7; "Processing Status"; Enum "NPR MM SubsPayReqLogProcStatus")
        {
            Caption = 'Processing Status';
            DataClassification = SystemMetadata;
        }

        field(10; Request; Blob)
        {
            Caption = 'Request';
            DataClassification = SystemMetadata;
        }
        field(11; Response; Blob)
        {
            Caption = 'Response';
            DataClassification = SystemMetadata;
        }
        field(12; "Subs. Payment Gateway Code"; Code[10])
        {
            Caption = 'Subscriptions Payment Gateway Code';
            DataClassification = SystemMetadata;
            TableRelation = "NPR MM Subs. Payment Gateway".Code;
        }
        field(13; Manual; Boolean)
        {
            Caption = 'Manual';
            DataClassification = SystemMetadata;
        }
        field(14; "Webhook Request Entry No."; Integer)
        {
            Caption = 'Webhook Request Entry No.';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    internal procedure SetRequest(RequestText: Text)
    var
        OutStream: OutStream;
    begin
        Rec.CalcFields(Request);
        Rec.Request.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(RequestText);
    end;

    internal procedure GetRequest() RequestText: Text
    var
        InStream: InStream;
        LineText: Text;
    begin
        Rec.CalcFields(Request);
        Rec.Request.CreateInStream(InStream, TextEncoding::UTF8);
        while not InStream.EOS do begin
            InStream.ReadText(LineText);
            RequestText += LineText;
        end;
    end;

    internal procedure SetResponse(ResponseText: Text)
    var
        OutStream: OutStream;
    begin
        Rec.CalcFields(Response);
        Rec.Response.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(ResponseText);
    end;

    internal procedure GetResponse() ResponseText: Text
    var
        InStream: InStream;
        LineText: Text;
    begin
        Rec.CalcFields(Response);
        Rec.Response.CreateInStream(InStream, TextEncoding::UTF8);
        while not InStream.EOS do begin
            InStream.ReadText(LineText);
            ResponseText += LineText;
        end;
    end;
}

