xmlport 6151500 "Nc Import Entry"
{
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    Caption = 'Nc Import Entry';

    schema
    {
        textelement(import_entries)
        {
            tableelement(tempncimportentry;"Nc Import Entry")
            {
                XmlName = 'import_entry';
                UseTemporary = true;
                fieldattribute(name;TempNcImportEntry."Document Name")
                {

                    trigger OnBeforePassField()
                    var
                        InStream: InStream;
                        StreamReader: DotNet npNetStreamReader;
                    begin
                        Clear(TempNcImportEntry."Document Source");
                        TempNcImportEntry."Document Source".CreateInStream(InStream,TEXTENCODING::UTF8);
                        StreamReader := StreamReader.StreamReader(InStream);
                        document_source := StreamReader.ReadToEnd;
                    end;

                    trigger OnAfterAssignField()
                    var
                        OutStream: OutStream;
                    begin
                        Clear(TempNcImportEntry."Document Source");
                        TempNcImportEntry."Document Source".CreateOutStream(OutStream,TEXTENCODING::UTF8);
                        OutStream.WriteText(document_source);
                    end;
                }
                fieldattribute(id;TempNcImportEntry."Document ID")
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

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    var
        XmlPortVariant: Variant;
        EntryNo: Integer;

    procedure CopySourceTable(var TempNcImportEntryCopy: Record "Nc Import Entry" temporary)
    begin
        TempNcImportEntryCopy.Copy(TempNcImportEntry,true);
    end;
}

