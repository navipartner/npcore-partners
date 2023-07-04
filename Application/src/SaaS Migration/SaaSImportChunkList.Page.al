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
                    FileName := '';
                    DownloadFromStream(IStream, 'Download chunk', '', 'CSV File (*.csv)|*.csv', FileName);
                end;
            }
        }
    }

}