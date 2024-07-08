table 6150880 "NPR Adyen Webhook"
{
    Access = Internal;
    Caption = 'Adyen Webhook Request';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(10; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR35.0';
            ObsoleteReason = 'SystemCreatedAt field is used instead.';
        }
        field(20; "Event Date"; DateTime)
        {
            Caption = 'Event Date';
            DataClassification = CustomerContent;
        }
        field(25; "Processed Date"; DateTime)
        {
            Caption = 'Processed Date';
            DataClassification = CustomerContent;
        }
        field(30; "Event Code"; Enum "NPR Adyen Webhook Event Code")
        {
            Caption = 'Event Code';
            DataClassification = CustomerContent;
        }
        field(35; Status; Enum "NPR Adyen Webhook Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            InitValue = New;
        }
        field(40; "Merchant Account Name"; Text[80])
        {
            Caption = 'Merchant Account Name';
            DataClassification = CustomerContent;
        }
        field(50; Success; Boolean)
        {
            Caption = 'Success';
            DataClassification = CustomerContent;
        }
        field(60; "PSP Reference"; Text[100])
        {
            Caption = 'PSP Reference';
            DataClassification = CustomerContent;
        }
        field(70; "Request Data"; Blob)
        {
            Caption = 'Webhook Data';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR35.0';
            ObsoleteReason = 'Not used.';
        }
        field(80; Live; Boolean)
        {
            Caption = 'Live';
            DataClassification = CustomerContent;
        }
        field(90; "Webhook Data"; Blob)
        {
            Caption = 'Webhook Data';
            DataClassification = CustomerContent;
        }
        field(100; "Webhook Reference"; Code[80])
        {
            Caption = 'Webhook Reference';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Event Code", Status)
        {
        }
    }

    procedure GetAdyenData(): Text
    var
        TypeHelper: Codeunit "Type Helper";
#IF BC17
        InStr: InStream;
#ENDIF
    begin
#IF BC17
        GetAdyenDataStream(InStr);
        exit(TypeHelper.ReadAsTextWithSeparator(InStr, TypeHelper.LFSeparator()));
#ELSE
        exit(TypeHelper.ReadAsTextWithSeparator(GetAdyenDataStream(), TypeHelper.LFSeparator()));
#ENDIF
    end;

#IF BC17
    procedure GetAdyenDataStream(var InStr: InStream)
#ELSE
    procedure GetAdyenDataStream() InStr: InStream
#ENDIF
    begin
        if "Webhook Data".HasValue then begin
            CalcFields("Webhook Data");
            "Webhook Data".CreateInStream(InStr, TextEncoding::UTF8);
        end;
    end;
}
