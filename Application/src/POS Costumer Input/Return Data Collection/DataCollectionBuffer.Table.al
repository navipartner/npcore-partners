table 6059885 "NPR Data Collection Buffer"
{
    Access = Internal;
    Caption = 'Data Collection Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(10; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(20; "Signature Data"; Blob)
        {
            Caption = 'Signature Data';
            DataClassification = CustomerContent;
        }
        field(30; "Phone No."; Text[50])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
        field(40; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
            DataClassification = CustomerContent;
        }
        field(50; Context; Enum "NPR POS Costumer Input Context")
        {
            Caption = 'Context';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Sales Ticket No.", "Line No.")
        {
            Clustered = true;
        }
    }

    internal procedure ReadSignatureData() SignatureText: Text
    var
        InStr: InStream;
    begin
        Rec.CalcFields("Signature Data");
        Rec."Signature Data".CreateInStream(InStr);
        InStr.ReadText(SignatureText);
    end;

    internal procedure WriteSignatureData(SignatureText: Text)
    var
        OutStr: OutStream;
    begin
        Rec."Signature Data".CreateOutStream(OutStr);
        OutStr.WriteText(SignatureText);
    end;
}
