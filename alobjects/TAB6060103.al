table 6060103 "BLOB buffer"
{
    // NPR4.000.000, 16-07-09, MH - Oprettet i forbindelse med billedindlæsning til rapporter.

    Caption = 'BLOB buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; "Buffer 1"; BLOB)
        {
            Caption = 'Buffer 1';
            DataClassification = CustomerContent;
        }
        field(3; "Buffer 2"; BLOB)
        {
            Caption = 'Buffer 2';
            DataClassification = CustomerContent;
        }
        field(4; "Buffer 3"; BLOB)
        {
            Caption = 'Buffer 3';
            DataClassification = CustomerContent;
        }
        field(5; "Buffer 4"; BLOB)
        {
            Caption = 'Buffer 4';
            DataClassification = CustomerContent;
        }
        field(6; "Buffer 5"; BLOB)
        {
            Caption = 'Buffer 5';
            DataClassification = CustomerContent;
        }
        field(7; "Buffer 6"; BLOB)
        {
            Caption = 'Buffer 6';
            DataClassification = CustomerContent;
        }
        field(8; "Buffer 7"; BLOB)
        {
            Caption = 'Buffer 7';
            DataClassification = CustomerContent;
        }
        field(9; "Buffer 8"; BLOB)
        {
            Caption = 'Buffer 8';
            DataClassification = CustomerContent;
        }
        field(10; "Buffer 9"; BLOB)
        {
            Caption = 'Buffer 9';
            DataClassification = CustomerContent;
        }
        field(11; "Buffer 10"; BLOB)
        {
            Caption = 'Buffer 10';
            DataClassification = CustomerContent;
        }
        field(12; "Buffer 11"; BLOB)
        {
            Caption = 'Buffer 11';
            DataClassification = CustomerContent;
        }
        field(13; "Buffer 12"; BLOB)
        {
            Caption = 'Buffer 12';
            DataClassification = CustomerContent;
        }
        field(14; "Buffer 13"; BLOB)
        {
            Caption = 'Buffer 13';
            DataClassification = CustomerContent;
        }
        field(15; "Buffer 14"; BLOB)
        {
            Caption = 'Buffer 14';
            DataClassification = CustomerContent;
        }
        field(16; "Buffer 15"; BLOB)
        {
            Caption = 'Buffer 15';
            DataClassification = CustomerContent;
        }
        field(17; "Buffer 16"; BLOB)
        {
            Caption = 'Buffer 16';
            DataClassification = CustomerContent;
        }
        field(18; "Buffer 17"; BLOB)
        {
            Caption = 'Buffer 17';
            DataClassification = CustomerContent;
        }
        field(19; "Buffer 18"; BLOB)
        {
            Caption = 'Buffer 18';
            DataClassification = CustomerContent;
        }
        field(20; "Buffer 19"; BLOB)
        {
            Caption = 'Buffer 19';
            DataClassification = CustomerContent;
        }
        field(21; "Buffer 20"; BLOB)
        {
            Caption = 'Buffer 20';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure GetFromTempBlob(var TempBlob: Codeunit "Temp Blob"; BlobNo: Integer)
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        RecRef.GetTable(Rec);
        FldRef := RecRef.Field(BlobNo + 1);
        TempBlob.ToFieldRef(FldRef);
        RecRef.SetTable(Rec);
    end;
}

