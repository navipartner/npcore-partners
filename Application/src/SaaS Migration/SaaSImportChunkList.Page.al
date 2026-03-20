page 6150807 "NPR SaaS Import Chunk List"
{
    Caption = 'SaaS Import Chunk List';
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR SaaS Import Chunk";
    Editable = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the ID of the chunk';

                }
                field("Error"; Rec."Error Reason")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Error Reason if the chunk import failed';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DownloadChunk)
            {
                ToolTip = 'Download the raw chunk to troubleshoot errors';
                ApplicationArea = NPRRetail;
                Image = Download;

                trigger OnAction()
                var
                    IStream: InStream;
                    FileName: Text;
                begin
                    Rec.CalcFields(Chunk);
                    Rec.Chunk.CreateInStream(IStream, TextEncoding::UTF8);
                    FileName := StrSubstNo('Chunk_%1.csv', Rec.ID);
                    DownloadFromStream(IStream, 'Download chunk', '', 'CSV File (*.csv)|*.csv', FileName);
                end;
            }
            action(ImportChunk)
            {
                ToolTip = 'Import the raw chunk to troubleshoot errors';
                ApplicationArea = NPRRetail;
                Image = Refresh;
                trigger OnAction()
                var
                    SaaSImportCSVParser: Codeunit "NPR SaaS Import CSV Parser";
                    ChunkImportedSuccessfullyLbl: Label 'Chunk imported successfully. Chunk is deleted.';
                    ChunkImportFailedLbl: Label 'Chunk import failed with error: %1';
                begin
                    Rec.CalcFields(Chunk);
                    if SaaSImportCSVParser.Run(Rec) then begin
                        Rec.Delete();
                        Message(ChunkImportedSuccessfullyLbl);
                    end else
                        Message(ChunkImportFailedLbl, GetLastErrorText());
                end;
            }
            action(UploadChunk)
            {
                ToolTip = 'Upload a CSV file and store it as a new import chunk.';
                ApplicationArea = NPRRetail;
                Image = Import;

                trigger OnAction()
                var
                    SaaSImportChunk: Record "NPR SaaS Import Chunk";
                    IStream: InStream;
                    OStream: OutStream;
                    FileName: Text;
                    UploadChunkLbl: Label 'Upload Chunk';
                    CsvFileFilterLbl: Label 'CSV File (*.csv)|*.csv';
                begin
                    if not UploadIntoStream(UploadChunkLbl, '', CsvFileFilterLbl, FileName, IStream) then
                        exit;

                    SaaSImportChunk.Init();
                    SaaSImportChunk.Chunk.CreateOutStream(OStream, TextEncoding::UTF8);
                    CopyStream(OStream, IStream);
                    SaaSImportChunk.Insert();

                    CurrPage.Update(false);
                end;
            }
            action(DeleteChunk)
            {
                ToolTip = 'Delete the selected chunk';
                ApplicationArea = NPRRetail;
                Image = Delete;
                trigger OnAction()
                var
                    ConfirmDeleteLbl: Label 'Delete the selected chunk?';
                begin
                    if not Confirm(ConfirmDeleteLbl) then
                        exit;
                    Rec.Delete();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}