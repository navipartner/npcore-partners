table 6014458 "E-mail Attachment"
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    //   - This Table contains fixed Attachments connected to E-mail Templates.
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj -field 1

    Caption = 'E-mail Attachment';

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(10; "Primary Key"; Text[200])
        {
            Caption = 'Primary Key';
        }
        field(20; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(30; "Attached File"; BLOB)
        {
            Caption = 'Attached data';

            trigger OnLookup()
            var
                TempBlob: Codeunit "Temp Blob";
                FileName: Text[1024];
                RecRef: RecordRef;
            begin
                CalcFields("Attached File");
                if "Attached File".HasValue then
                    if not Confirm(Text001, false) then
                        exit;

                FileName := FileMgt.BLOBImport(TempBlob, '*.*');
                if FileName = '' then
                    exit;
                RecRef.GetTable(Rec);
                TempBlob.ToRecordRef(RecRef, FieldNo("Attached File"));
                RecRef.SetTable(Rec);

                while StrPos(FileName, '\') <> 0 do
                    FileName := CopyStr(FileName, StrPos(FileName, '\') + 1, StrLen(FileName) - StrPos(FileName, '\'));
                Description := FileName;
            end;
        }
        field(40; Description; Text[250])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Table No.", "Primary Key", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        FileMgt: Codeunit "File Management";
        Text001: Label 'Replace the existing file?';
}

