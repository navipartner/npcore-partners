xmlport 6151500 "NPR Nc Import Entry"
{
    Caption = 'Nc Import Entry';

    schema
    {
        textelement(import_entries)
        {
            tableelement(tempncimportentry; "NPR Nc Import Entry")
            {
                XmlName = 'import_entry';
                UseTemporary = true;
                fieldattribute(name; TempNcImportEntry."Document Name")
                {

                    trigger OnBeforePassField()
                    var
                        InStr: InStream;
                        BufferText: Text;
                    begin
                        Clear(TempNcImportEntry."Document Source");
                        TempNcImportEntry."Document Source".CreateInStream(InStr, TextEncoding::UTF8);
                        while not InStr.EOS do begin
                            InStr.ReadText(BufferText);
                            document_source += BufferText;
                        end;
                    end;

                    trigger OnAfterAssignField()
                    var
                        OutStream: OutStream;
                    begin
                        Clear(TempNcImportEntry."Document Source");
                        TempNcImportEntry."Document Source".CreateOutStream(OutStream, TextEncoding::UTF8);
                        OutStream.WriteText(document_source);
                    end;
                }
                fieldattribute(id; TempNcImportEntry."Document ID")
                {
                }
                textelement(document_source)
                {
                }

                trigger OnAfterInitRecord()
                begin
                    EntryNo += 1;
                    TempNcImportEntry."Entry No." := EntryNo;
                end;
            }
        }
    }

    var
        EntryNo: Integer;

    procedure CopySourceTable(var TempNcImportEntryCopy: Record "NPR Nc Import Entry" temporary)
    begin
        TempNcImportEntryCopy.Copy(TempNcImportEntry, true);
    end;
}

