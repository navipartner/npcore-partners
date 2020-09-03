page 6184473 "NPR EFT Trx Log Factbox"
{
    // NPR5.53/MMV /20191120 CASE 377533 Created object

    Caption = 'EFT Transaction Logs';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR EFT Transaction Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Logged At"; "Logged At")
                {
                    ApplicationArea = All;
                }
                field("Log.HASVALUE"; Log.HasValue)
                {
                    ApplicationArea = All;
                    Caption = 'Has Log File';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Download)
            {
                Caption = 'Download';
                Image = CreateXMLFile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    InStream: InStream;
                    FileName: Text;
                begin
                    if not Log.HasValue then
                        exit;
                    CalcFields(Log);
                    Log.CreateInStream(InStream);
                    FileName := StrSubstNo('EFT_Log_%1_%2', "Transaction Entry No.", "Log Entry No.");
                    DownloadFromStream(InStream, 'Log Download', '', 'All Files (*.*)|*.*', FileName);
                end;
            }
        }
    }
}

