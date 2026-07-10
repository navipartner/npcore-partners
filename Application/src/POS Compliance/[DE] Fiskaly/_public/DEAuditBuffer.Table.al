table 6059977 "NPR DE Audit Buffer"
{
    Caption = 'DE Audit Buffer';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry"."Entry No.";
        }
        field(10; "QR Data"; Media)
        {
            Caption = 'QR Data';
            DataClassification = CustomerContent;
        }
        field(20; "Transaction Number"; BigInteger)
        {
            Caption = 'Transaction Number';
            DataClassification = CustomerContent;
        }
        field(30; "Start Time"; DateTime)
        {
            Caption = 'Start Time';
            DataClassification = CustomerContent;
        }
        field(40; "Finish Time"; DateTime)
        {
            Caption = 'Finish Time';
            DataClassification = CustomerContent;
        }
        field(50; "Time Format"; Text[250])
        {
            Caption = 'Time Format';
            DataClassification = CustomerContent;
        }
        field(60; "Signature Count"; BigInteger)
        {
            Caption = 'Signature Count';
            DataClassification = CustomerContent;
        }
        field(70; Signature; Text[512])
        {
            Caption = 'Signature';
            DataClassification = CustomerContent;
        }
        field(80; "Signature Algorithm"; Text[250])
        {
            Caption = 'Signature Algorithm';
            DataClassification = CustomerContent;
        }
        field(90; "Public Key"; Text[1024])
        {
            Caption = 'Public Key';
            DataClassification = CustomerContent;
        }
        field(100; "TSS Serial Number"; Text[100])
        {
            Caption = 'TSS Serial Number';
            DataClassification = CustomerContent;
        }
        field(110; "Client Serial Number"; Text[250])
        {
            Caption = 'Client Serial Number';
            DataClassification = CustomerContent;
        }
        field(120; "Is Cancellation"; Boolean)
        {
            Caption = 'Is Cancellation';
            DataClassification = CustomerContent;
        }
        field(130; "Fiscalization Failed"; Boolean)
        {
            Caption = 'Fiscalization Failed';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "POS Entry No.")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// Reads the KassenSichV QR code payload stored in the <see cref="QR Data"/> media field as UTF8 text.
    /// </summary>
    /// <returns>The QR code text, or an empty string when no QR data was stored.</returns>
    procedure GetQRData() QRData: Text
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
    begin
        if not Rec."QR Data".HasValue() then
            exit(QRData);
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        Rec."QR Data".ExportStream(OutStream);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        InStream.ReadText(QRData);
    end;

    internal procedure SetQRData(QRData: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(QRData);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        Rec."QR Data".ImportStream(InStream, Rec.FieldCaption("QR Data"));
    end;
}
