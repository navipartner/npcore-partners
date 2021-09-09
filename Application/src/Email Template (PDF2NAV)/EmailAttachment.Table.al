table 6014458 "NPR E-mail Attachment"
{
    Caption = 'E-mail Attachment';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            DataClassification = CustomerContent;
        }
        field(10; "Primary Key"; Text[200])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(20; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(30; "Attached File"; BLOB)
        {
            Caption = 'Attached data';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                TempBlob: Codeunit "Temp Blob";
                FileName: Text[1024];
                RecRef: RecordRef;
            begin
                CalcFields("Attached File");
                if "Attached File".HasValue() then
                    if not Confirm(Text001, false) then
                        exit;

                FileName := CopyStr(FileMgt.BLOBImport(TempBlob, '*.*'), 1, MaxStrLen(FileName));
                if FileName = '' then
                    exit;
                RecRef.GetTable(Rec);
                TempBlob.ToRecordRef(RecRef, FieldNo("Attached File"));
                RecRef.SetTable(Rec);

                while StrPos(FileName, '\') <> 0 do
                    FileName := CopyStr(CopyStr(FileName, StrPos(FileName, '\') + 1, StrLen(FileName) - StrPos(FileName, '\')), 1, MaxStrLen(FileName));
                Description := CopyStr(FileName, 1, MaxStrLen(Description));
            end;
        }
        field(40; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Table No.", "Primary Key", "Line No.")
        {
        }
    }

    var
        FileMgt: Codeunit "File Management";
        Text001: Label 'Replace the existing file?';
}

