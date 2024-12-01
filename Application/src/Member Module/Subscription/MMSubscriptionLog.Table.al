table 6150925 "NPR MM Subscription Log"
{
    Access = Internal;
    Caption = 'Subscription Log';
    DataClassification = CustomerContent;
    //DrillDownPageId = ;
    //LookupPageId = ;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(10; "Subscription Entry No."; Integer)
        {
            Caption = 'Subscription Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Subscription"."Entry No.";
        }
        field(11; "Subscr. Request Entry No."; BigInteger)
        {
            Caption = 'Subscription Request Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Subscr. Request"."Entry No.";
        }
        field(12; "Subscr. Pmt. Request Entry No."; BigInteger)
        {
            Caption = 'Subscr. Pmt. Request Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Subscr. Payment Request"."Entry No.";
        }
        field(20; "Entry Type"; Enum "NPR Message Severity")
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
        }
        field(30; "Message Text"; Blob)
        {
            Caption = 'Message';
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

    internal procedure SetMessage(NewMessageText: Text)
    var
        OutStr: OutStream;
    begin
        Clear("Message Text");
        if NewMessageText = '' then
            exit;
        "Message Text".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(NewMessageText);
    end;

    internal procedure GetMessage(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
        MessageText: Text;
        NoMessageTxt: Label 'No message was recorded for the log entry.';
    begin
        MessageText := '';
        if "Message Text".HasValue() then begin
            CalcFields("Message Text");
            "Message Text".CreateInStream(InStream, TextEncoding::UTF8);
            MessageText := TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator());
        end;
        if MessageText = '' then
            MessageText := NoMessageTxt;
        exit(MessageText);
    end;
}